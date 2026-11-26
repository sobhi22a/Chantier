using Chantier.Core.Exceptions;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Push (ADR 0009) : un resultat par operation, dans l'ordre d'envoi. Chaque operation a sa propre transaction (celle de son handler) ;
/// un refus metier est un resultat <c>rejected</c> avec son <c>code</c>, pas une erreur HTTP, pour que le reste du lot passe.
/// </summary>
public sealed class SyncPushService(
    IEnumerable<ISyncPushHandler> handlers,
    ApplicationDbContext db,
    ILogger<SyncPushService> logger) : ISyncPushService
{
    public async Task<SyncPushResponse> PushAsync(IReadOnlyList<SyncOperation> operations, CancellationToken cancellationToken = default)
    {
        if (operations.Count > SyncLimits.MaxOperations)
        {
            throw new PayloadTooLargeException();
        }

        var byEntity = handlers.ToDictionary(handler => handler.Entity, StringComparer.Ordinal);
        var results = new List<SyncPushResult>(operations.Count);

        // R3-01 : une operation a rejouer (echec momentane) entraine, dans l'ordre, celles qui visent la meme ressource ou qui la referencent
        // (creation puis modification, livraison puis photo...) : les traiter avant elle les ferait echouer (INTROUVABLE) ou les appliquerait dans le desordre.
        var blocked = new HashSet<string>(StringComparer.Ordinal);

        foreach (var operation in operations)
        {
            var keys = SyncDependencies.KeysOf(operation);
            if (keys.Overlaps(blocked))
            {
                logger.LogInformation("Opération de synchronisation reportée {Entity} {Operation} : une opération dont elle dépend est à rejouer", operation.Entity, operation.Operation);
                results.Add(SyncPushResult.Retry(operation.ClientId, ErrorCodes.ErreurTemporaire));
                blocked.UnionWith(keys);
                continue;
            }

            var result = await ApplyAsync(operation, byEntity, cancellationToken);
            results.Add(result);
            if (result.Status == SyncStatuses.Retry)
            {
                blocked.UnionWith(keys);
            }

            // Une operation refusee ne doit laisser aucune entite a moitie suivie pour la suivante.
            db.ChangeTracker.Clear();
        }

        return new SyncPushResponse(results);
    }

    private async Task<SyncPushResult> ApplyAsync(
        SyncOperation operation,
        Dictionary<string, ISyncPushHandler> byEntity,
        CancellationToken cancellationToken)
    {
        if (operation.Entity is null || !byEntity.TryGetValue(operation.Entity, out var handler))
        {
            return Rejected(operation, ErrorCodes.EntiteNonSynchronisable);
        }

        if (operation.ClientId == Guid.Empty)
        {
            return Rejected(operation, ErrorCodes.Validation, Error("clientId", "L'identifiant client est obligatoire."));
        }

        if (!SyncOperations.IsKnown(operation.Operation))
        {
            return Rejected(operation, ErrorCodes.Validation, Error("operation", "L'opération est inconnue."));
        }

        try
        {
            return await handler.HandleAsync(operation, cancellationToken);
        }
        catch (Core.Exceptions.ValidationException exception)
        {
            return Rejected(operation, exception.Code, exception.Errors);
        }
        catch (ConflictException exception)
        {
            return SyncPushResult.Conflict(operation.ClientId, exception.Current, exception.Code, exception.Fields);
        }
        catch (DomainException exception)
        {
            return Rejected(operation, exception.Code);
        }
        catch (DbUpdateConcurrencyException)
        {
            return SyncPushResult.Conflict(operation.ClientId, null);
        }
        catch (Exception exception) when (SqlErrors.Find(exception) is not null && !cancellationToken.IsCancellationRequested)
        {
            // Une erreur de base (interblocage resté sans solution après les rejeux, délai dépassé...) ne doit jamais faire perdre le lot : les opérations déjà
            // validées le restent, celle-ci est annulée (sa transaction aussi) et le téléphone sait ce qu'il doit faire (R2-01).
            return DatabaseFailure(operation, exception);
        }
    }

    private SyncPushResult DatabaseFailure(SyncOperation operation, Exception exception)
    {
        var sqlNumber = SqlErrors.Find(exception)?.Number;

        // Ni message SQL (il peut contenir une valeur de colonne), ni contenu de l'opération : le type, le numéro d'erreur et l'entité suffisent.
        if (SqlErrors.IsTransient(exception))
        {
            logger.LogWarning(
                "Opération de synchronisation à rejouer {Entity} {Operation} sqlNumber={SqlNumber}",
                operation.Entity, operation.Operation, sqlNumber);
            return SyncPushResult.Retry(operation.ClientId, ErrorCodes.ErreurTemporaire);
        }

        logger.LogError(
            "Erreur de base de données pendant une opération de synchronisation {Entity} {Operation} {ExceptionType} sqlNumber={SqlNumber}",
            operation.Entity, operation.Operation, exception.GetType().Name, sqlNumber);
        return SyncPushResult.Rejected(operation.ClientId, ErrorCodes.ErreurInterne);
    }

    private SyncPushResult Rejected(SyncOperation operation, string code, IReadOnlyDictionary<string, string[]>? errors = null)
    {
        // Ni identifiant de chantier, ni contenu : seulement ce qui permet de comprendre le refus.
        logger.LogInformation("Opération de synchronisation rejetée {Entity} {Operation} {Code}", operation.Entity, operation.Operation, code);
        return SyncPushResult.Rejected(operation.ClientId, code, errors);
    }

    private static Dictionary<string, string[]> Error(string field, string message) => new() { [field] = [message] };
}
