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

        foreach (var operation in operations)
        {
            results.Add(await ApplyAsync(operation, byEntity, cancellationToken));

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
            return SyncPushResult.Conflict(operation.ClientId, exception.Current);
        }
        catch (DomainException exception)
        {
            return Rejected(operation, exception.Code);
        }
        catch (DbUpdateConcurrencyException)
        {
            return SyncPushResult.Conflict(operation.ClientId, null);
        }
    }

    private SyncPushResult Rejected(SyncOperation operation, string code, IReadOnlyDictionary<string, string[]>? errors = null)
    {
        // Ni identifiant de chantier, ni contenu : seulement ce qui permet de comprendre le refus.
        logger.LogInformation("Opération de synchronisation rejetée {Entity} {Operation} {Code}", operation.Entity, operation.Operation, code);
        return SyncPushResult.Rejected(operation.ClientId, code, errors);
    }

    private static Dictionary<string, string[]> Error(string field, string message) => new() { [field] = [message] };
}
