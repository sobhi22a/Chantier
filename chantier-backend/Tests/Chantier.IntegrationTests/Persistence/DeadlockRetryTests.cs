using Chantier.Core.Exceptions;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Chantier.Infrastructure.Sync;
using Chantier.IntegrationTests.Support;
using Chantier.WebApi.Middlewares;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;

namespace Chantier.IntegrationTests.Persistence;

/// <summary>
/// R2-01 : un interblocage SQL (1205) est rejoue par <see cref="DbTransactions"/> ; une erreur de base ne fait jamais perdre un lot de synchronisation
/// (resultat par operation) ; un echec momentane qui subsiste donne 503 et non 500. Les erreurs SQL sont <b>reelles</b> (aucune fabrication par reflexion).
/// </summary>
[TestFixture]
public class DeadlockRetryTests
{
    // Constante : la base de test est neuve a chaque execution (pas de collision), et aucune chaine interpolee n'atteint le SQL.
    private const string Probe = "DeadlockProbe";

    [OneTimeSetUp]
    public async Task CreateProbeTable()
    {
        await using var db = TestDb.Create();
        await db.Database.ExecuteSqlRawAsync("CREATE TABLE [" + Probe + "] (Id int NOT NULL PRIMARY KEY, Value int NOT NULL); INSERT INTO [" + Probe + "] VALUES (1, 0), (2, 0);");
    }

    [OneTimeTearDown]
    public async Task DropProbeTable()
    {
        await using var db = TestDb.Create();
        await db.Database.ExecuteSqlRawAsync("DROP TABLE IF EXISTS [" + Probe + "]");
    }

    [Test]
    public async Task The_migrations_turn_on_row_versioning_for_reads()
    {
        await TestDb.EnsureMigratedAsync();
        await using var db = TestDb.Create();

        var enabled = await db.Database
            .SqlQueryRaw<bool>("SELECT is_read_committed_snapshot_on AS [Value] FROM sys.databases WHERE name = DB_NAME()")
            .SingleAsync();

        Assert.That(enabled, Is.True, "une lecture n'attend plus un ecrivain : plus d'interblocage lecture contre insertion (R2-01)");
    }

    [Test]
    public async Task The_startup_check_warns_when_row_versioning_is_off_and_stays_silent_when_it_is_on()
    {
        var logs = new CapturingLoggerProvider();

        // Base neuve : CREATE DATABASE la laisse sans versionnement (seules les migrations l'activent).
        var plain = await SqlServerFixture.CreateDatabaseAsync("rcsi");
        try
        {
            await DatabaseInitializer.WarnIfRowVersioningIsOffAsync(ProviderFor(plain, logs));
            var warned = logs.Entries.Count(entry => entry.StartsWith("[Warning]", StringComparison.Ordinal) && entry.Contains("READ_COMMITTED_SNAPSHOT"));

            Assert.That(warned, Is.EqualTo(1), "S-1 : avertissement journalise quand le versionnement est inactif");
        }
        finally
        {
            await SqlServerFixture.DropDatabaseAsync(plain);
        }

        await TestDb.EnsureMigratedAsync();
        var quiet = new CapturingLoggerProvider();
        await DatabaseInitializer.WarnIfRowVersioningIsOffAsync(ProviderFor(SqlServerFixture.ConnectionString, quiet));
        Assert.That(quiet.Entries.Count(entry => entry.Contains("READ_COMMITTED_SNAPSHOT")), Is.Zero, "base migree : aucun avertissement");
    }

    private static IServiceProvider ProviderFor(string connectionString, CapturingLoggerProvider logs)
    {
        var services = new ServiceCollection();
        services.AddLogging(builder => builder.AddProvider(logs));
        services.AddDbContext<ApplicationDbContext>(options => options.UseSqlServer(connectionString));
        return services.BuildServiceProvider();
    }

    [Test]
    public async Task A_transaction_chosen_as_deadlock_victim_is_replayed_and_commits()
    {
        var aHoldsFirstRow = new TaskCompletionSource();
        var bHoldsSecondRow = new TaskCompletionSource();
        var attempts = 0;

        // A : modifie la ligne 1 puis la ligne 2, avec la plus faible priorite : victime designee au premier essai.
        await using var contextA = TestDb.Create();
        var transactionA = DbTransactions.RunAsync(contextA, async () =>
        {
            attempts++;
            if (attempts == 1)
            {
                await contextA.Database.ExecuteSqlRawAsync("SET DEADLOCK_PRIORITY LOW");
                await contextA.Database.ExecuteSqlRawAsync("UPDATE [" + Probe + "] SET Value = Value + 1 WHERE Id = 1");
                aHoldsFirstRow.SetResult();
                await bHoldsSecondRow.Task;
                await contextA.Database.ExecuteSqlRawAsync("UPDATE [" + Probe + "] SET Value = Value + 1 WHERE Id = 2");
            }
            else
            {
                await contextA.Database.ExecuteSqlRawAsync("UPDATE [" + Probe + "] SET Value = Value + 1 WHERE Id IN (1, 2)");
            }

            return attempts;
        });

        // B : l'autre sens (ligne 2 puis ligne 1), priorite haute : jamais victime.
        await using var contextB = TestDb.Create();
        await using var transactionB = await contextB.Database.BeginTransactionAsync();
        await contextB.Database.ExecuteSqlRawAsync("SET DEADLOCK_PRIORITY HIGH");
        await aHoldsFirstRow.Task;
        await contextB.Database.ExecuteSqlRawAsync("UPDATE [" + Probe + "] SET Value = Value + 100 WHERE Id = 2");
        bHoldsSecondRow.SetResult();
        await contextB.Database.ExecuteSqlRawAsync("UPDATE [" + Probe + "] SET Value = Value + 100 WHERE Id = 1");
        await transactionB.CommitAsync();

        var result = await transactionA;

        await using var reader = TestDb.Create();
        var values = await reader.Database.SqlQueryRaw<int>("SELECT Value AS [Value] FROM [" + Probe + "] ORDER BY Id").ToListAsync();
        Assert.Multiple(() =>
        {
            Assert.That(result, Is.EqualTo(2), "la victime a ete rejouee une fois");
            Assert.That(values, Is.EqualTo(new[] { 101, 101 }), "B (+100) et le rejeu de A (+1) sont ecrits, l'essai annule de A n'a laisse aucune trace");
        });
    }

    [Test]
    public async Task An_error_that_is_not_a_deadlock_is_never_replayed()
    {
        await using var db = TestDb.Create();
        var attempts = 0;

        var failure = Assert.ThrowsAsync<SqlException>(async () => await DbTransactions.RunAsync(db, async () =>
        {
            attempts++;
            await db.Database.ExecuteSqlRawAsync("SELECT 1/0");
            return 0;
        }));

        Assert.Multiple(() =>
        {
            Assert.That(attempts, Is.EqualTo(1), "une erreur qui n'est pas un interblocage n'est jamais rejouee");
            Assert.That(SqlErrors.IsDeadlock(failure!), Is.False);
            Assert.That(SqlErrors.IsTransient(failure!), Is.False);
        });
    }

    [Test]
    public async Task A_database_failure_in_one_operation_does_not_lose_the_rest_of_the_batch()
    {
        await using var db = TestDb.Create();
        var handler = new ScriptedHandler(db);
        var service = new SyncPushService([handler], db, NullLogger<SyncPushService>.Instance);
        var first = Guid.NewGuid();
        var slow = Guid.NewGuid();
        var broken = Guid.NewGuid();
        var last = Guid.NewGuid();

        var response = await service.PushAsync(
        [
            Operation(first, "ok"),
            Operation(slow, "timeout"),
            Operation(broken, "divide"),
            Operation(last, "ok"),
        ]);

        Assert.Multiple(() =>
        {
            Assert.That(response.Results.Select(result => result.ClientId), Is.EqualTo(new[] { first, slow, broken, last }), "un resultat par operation, dans l'ordre");
            Assert.That(response.Results.Select(result => result.Status), Is.EqualTo(new[] { SyncStatuses.Applied, SyncStatuses.Retry, SyncStatuses.Rejected, SyncStatuses.Applied }));
            Assert.That(response.Results[1].Code, Is.EqualTo(ErrorCodes.ErreurTemporaire), "delai depasse : a renvoyer telle quelle");
            Assert.That(response.Results[2].Code, Is.EqualTo(ErrorCodes.ErreurInterne), "erreur SQL non momentanee : refusee, jamais renvoyee en boucle");
        });
    }

    [Test]
    public async Task Operations_that_depend_on_a_retried_creation_are_retried_too_in_order_and_never_handled()
    {
        // R3-01 : creation de demande a rejouer, puis sa modification, une livraison qui la reference, la photo de cette livraison, et une operation sans lien.
        await using var db = TestDb.Create();
        var requests = new ScriptedHandler(db, "request");
        var deliveries = new ScriptedHandler(db, "delivery");
        var photos = new ScriptedHandler(db, "photo");
        var service = new SyncPushService([requests, deliveries, photos], db, NullLogger<SyncPushService>.Instance);
        var requestCreate = Guid.NewGuid();
        var requestUpdate = Guid.NewGuid();
        var deliveryCreate = Guid.NewGuid();
        var photoCreate = Guid.NewGuid();
        var unrelated = Guid.NewGuid();
        var otherUpdate = Guid.NewGuid();
        var siteId = Guid.NewGuid();

        var response = await service.PushAsync(
        [
            Operation(requestCreate, "timeout", "request"),
            Operation(requestUpdate, "ok", "request", SyncOperations.Update, new { requestClientId = requestCreate }),
            Operation(deliveryCreate, "ok", "delivery", payload: new { requestClientId = requestCreate }),
            Operation(photoCreate, "ok", "photo", payload: new { deliveryClientId = deliveryCreate }),
            Operation(unrelated, "ok", "request"),
            Operation(otherUpdate, "ok", "request", SyncOperations.Update, new { requestId = siteId }),
        ]);

        Assert.Multiple(() =>
        {
            Assert.That(response.Results.Select(result => result.ClientId), Is.EqualTo(new[] { requestCreate, requestUpdate, deliveryCreate, photoCreate, unrelated, otherUpdate }), "un resultat par operation, dans l'ordre");
            Assert.That(
                response.Results.Select(result => result.Status),
                Is.EqualTo(new[] { SyncStatuses.Retry, SyncStatuses.Retry, SyncStatuses.Retry, SyncStatuses.Retry, SyncStatuses.Applied, SyncStatuses.Applied }));
            Assert.That(response.Results.Take(4).Select(result => result.Code), Is.All.EqualTo(ErrorCodes.ErreurTemporaire));
            Assert.That(requests.Handled, Is.EqualTo(new[] { requestCreate, unrelated, otherUpdate }), "les operations dependantes ne sont jamais traitees");
            Assert.That(deliveries.Handled, Is.Empty);
            Assert.That(photos.Handled, Is.Empty);
        });
    }

    [Test]
    public async Task A_transient_failure_that_remains_gives_503_with_a_retry_delay_and_other_database_errors_stay_500()
    {
        await using var db = TestDb.Create();
        var timeout = await RealSqlFailureAsync(db, "timeout");
        var divide = await RealSqlFailureAsync(db, "divide");
        var context = new DefaultHttpContext();

        var (transient, retryAfter) = GlobalExceptionMiddleware.Map(context, timeout);
        var (other, otherRetry) = GlobalExceptionMiddleware.Map(context, divide);
        var (wrapped, _) = GlobalExceptionMiddleware.Map(context, new DbUpdateException("save failed", timeout));

        Assert.Multiple(() =>
        {
            Assert.That(transient.Status, Is.EqualTo(503));
            Assert.That(transient.Extensions["code"], Is.EqualTo(ErrorCodes.ErreurTemporaire));
            Assert.That(retryAfter, Is.EqualTo(TimeSpan.FromSeconds(1)));
            Assert.That(wrapped.Status, Is.EqualTo(503), "une erreur de sauvegarde dont la cause est momentanee");
            Assert.That(other.Status, Is.EqualTo(500));
            Assert.That(otherRetry, Is.Null);
        });
    }

    // --- Outils ---

    private static SyncOperation Operation(Guid clientId, string script, string entity = "probe", string operation = SyncOperations.Create, object? payload = null)
    {
        var body = new Dictionary<string, object?> { ["payload"] = script };
        foreach (var property in (payload ?? new { }).GetType().GetProperties())
        {
            body[property.Name] = property.GetValue(payload);
        }

        return new(clientId, entity, operation, null, System.Text.Json.JsonSerializer.SerializeToElement(body), null);
    }

    /// <summary>Erreur SQL reelle : delai de commande depasse (-2) ou division par zero (8134).</summary>
    private static async Task<SqlException> RealSqlFailureAsync(ApplicationDbContext db, string kind)
    {
        try
        {
            db.Database.SetCommandTimeout(1);
            await db.Database.ExecuteSqlRawAsync(kind == "timeout" ? "WAITFOR DELAY '00:00:04'" : "SELECT 1/0");
        }
        catch (SqlException exception)
        {
            return exception;
        }
        finally
        {
            db.Database.SetCommandTimeout(15);
        }

        throw new InvalidOperationException("L'erreur SQL attendue ne s'est pas produite.");
    }

    private sealed class ScriptedHandler(ApplicationDbContext db, string entity = "probe") : ISyncPushHandler
    {
        public string Entity => entity;

        public List<Guid> Handled { get; } = [];

        public async Task<SyncPushResult> HandleAsync(SyncOperation operation, CancellationToken cancellationToken = default)
        {
            Handled.Add(operation.ClientId);
            var payload = operation.Payload!.Value.GetProperty("payload").GetString();
            if (payload != "ok")
            {
                throw await RealSqlFailureAsync(db, payload!);
            }

            return SyncPushResult.Applied(operation.ClientId, new { });
        }
    }
}
