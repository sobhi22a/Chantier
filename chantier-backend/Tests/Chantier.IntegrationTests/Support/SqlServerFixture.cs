using Microsoft.Data.SqlClient;
using Testcontainers.MsSql;

// Espace de noms racine de l'assemblage : un SetUpFixture s'applique a tous les tests de son espace de noms et en dessous.
namespace Chantier.IntegrationTests;

/// <summary>
/// Une base SQL Server <b>reelle</b> pour toute l'execution des tests (ADR 0010) : ni EF InMemory ni SQLite, qui ne
/// reproduisent ni <c>rowversion</c> ni les index filtres.
/// Par defaut : un conteneur Testcontainers jetable. Variable d'environnement <c>CHANTIER_TEST_SQL</c> (chaine de connexion
/// d'un serveur, sans base) : des bases temporaires y sont creees puis supprimees, ce qui evite un second conteneur sur un poste modeste.
/// Chaque test cree ses propres donnees (identifiants aleatoires) ; aucun test ne depend de l'ordre.
/// </summary>
[SetUpFixture]
public class SqlServerFixture
{
    public const string ServerConnectionVariable = "CHANTIER_TEST_SQL";

    private static MsSqlContainer? _container;
    private static string _serverConnection = string.Empty;
    private static string? _sharedDatabase;

    /// <summary>Chaine de connexion de la base partagee par la plupart des tests.</summary>
    public static string ConnectionString { get; private set; } = string.Empty;

    [OneTimeSetUp]
    public async Task StartAsync()
    {
        var external = Environment.GetEnvironmentVariable(ServerConnectionVariable);
        if (!string.IsNullOrWhiteSpace(external))
        {
            _serverConnection = external;
        }
        else
        {
            _container = new MsSqlBuilder("mcr.microsoft.com/mssql/server:2022-latest").Build();
            await _container.StartAsync();
            _serverConnection = _container.GetConnectionString();
        }

        ConnectionString = await CreateDatabaseAsync("shared");
        _sharedDatabase = new SqlConnectionStringBuilder(ConnectionString).InitialCatalog;
    }

    [OneTimeTearDown]
    public async Task StopAsync()
    {
        if (_container is not null)
        {
            await _container.DisposeAsync();
            return;
        }

        if (_sharedDatabase is not null)
        {
            await DropDatabaseAsync(ConnectionString);
        }
    }

    /// <summary>Cree une base vierge (le nom contient <paramref name="purpose"/> et un GUID) et renvoie sa chaine de connexion.</summary>
    public static async Task<string> CreateDatabaseAsync(string purpose)
    {
        var name = $"chantier_test_{purpose}_{Guid.NewGuid():N}";
        await ExecuteAsync(_serverConnection, $"CREATE DATABASE [{name}]");
        return new SqlConnectionStringBuilder(_serverConnection) { InitialCatalog = name }.ConnectionString;
    }

    public static async Task DropDatabaseAsync(string connectionString)
    {
        var name = new SqlConnectionStringBuilder(connectionString).InitialCatalog;
        SqlConnection.ClearAllPools();
        await ExecuteAsync(_serverConnection, $"IF DB_ID(N'{name}') IS NOT NULL BEGIN ALTER DATABASE [{name}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [{name}]; END");
    }

    private static async Task ExecuteAsync(string connectionString, string sql)
    {
        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();
        await using var command = connection.CreateCommand();
        command.CommandText = sql;
        await command.ExecuteNonQueryAsync();
    }
}
