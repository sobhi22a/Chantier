using System.Globalization;
using System.Text.Json;
using Ardalis.Specification;
using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Entities.Sync;
using Chantier.Core.Exceptions;
using Chantier.Core.Materials;
using Chantier.Core.Sites;
using Chantier.Core.Specifications.Materials;
using Chantier.Core.Specifications.Sites;
using Chantier.Core.Sync;
using Chantier.Core.Validation;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Operations <c>request</c> du telephone : <c>create</c> (idempotente par l'index unique de la demande), <c>update</c> (comparaison a trois valeurs, tout ou rien,
/// premiere arrivee retenue) et <c>transition</c> (<c>approve</c>, <c>reject</c>, <c>cancel</c>, <c>receive</c> : le serveur gagne toujours sur les statuts), ADR 0011.
/// <b>Aucune regle n'est ecrite ici</b> : tout passe par <see cref="IRequestService"/> (droits, verrous, validations, historique), comme l'API REST.
/// Le handler traduit : refus jamais legitime (droit, validation, chantier archive ou non affecte) = <c>rejected</c> ; etat du serveur change (demande validee,
/// annulee, commandee, champ modifie ailleurs) = <c>conflict</c> avec l'etat courant ; rien n'est alors applique. Les formes rendues sont celles de la
/// synchronisation (jamais un champ commercial).
/// </summary>
public sealed class RequestSyncPushHandler(
    ISiteAccess siteAccess,
    ICurrentUser currentUser,
    IRequestService requests,
    IRepositoryBase<MaterialRequest> requestRepository,
    IRepositoryBase<Zone> zones,
    SyncOperationLogService journal,
    ApplicationDbContext db) : ISyncPushHandler
{
    private static readonly string[] StateConflictCodes = [ErrorCodes.DemandeVerrouillee, ErrorCodes.TransitionInterdite, ErrorCodes.DemandeNonOuverte];

    public string Entity => SyncEntities.Request;

    public Task<SyncPushResult> HandleAsync(SyncOperation operation, CancellationToken cancellationToken = default) => operation.Operation switch
    {
        SyncOperations.Create => CreateAsync(operation, cancellationToken),
        SyncOperations.Update => LoggedAsync(operation, (siteId, scope) => UpdateAsync(operation, siteId, scope, cancellationToken), cancellationToken),
        SyncOperations.Transition => LoggedAsync(operation, (siteId, scope) => TransitionAsync(operation, siteId, scope, cancellationToken), cancellationToken),
        _ => Task.FromResult(SyncPushResult.Rejected(operation.ClientId, ErrorCodes.EntiteNonSynchronisable)),
    };

    // --- create ---

    private async Task<SyncPushResult> CreateAsync(SyncOperation operation, CancellationToken cancellationToken)
    {
        var siteId = RequireSite(operation);
        await siteAccess.EnsureAsync(siteId, cancellationToken);

        var payload = ReadPayload<CreatePayload>(operation);
        var errors = new ErrorCollector();
        var neededBy = ParseDate(payload.NeededBy, "neededBy", errors);
        errors.ThrowIfAny();

        // Zone creee hors ligne dans le meme lot : designee par son clientId, resolue ici (introuvable : rejected INTROUVABLE).
        var zoneId = payload.ZoneId;
        if (zoneId is null && payload.ZoneClientId is { } zoneClientId)
        {
            zoneId = (await zones.FirstOrDefaultAsync(new ZoneByClientIdSpecification(siteId, zoneClientId), cancellationToken))?.Id
                ?? throw new NotFoundException();
        }

        var fields = new RequestFields(
            payload.ProductId, payload.FreeProductName, payload.Quantity?.Value, payload.Quantity?.Unit, zoneId, neededBy, payload.Priority, payload.Note);
        var created = await requests.CreateAsync(
            siteId,
            new CreateRequestDto(operation.ClientId, payload.ClientCreatedAt, fields),
            new RequestActionContext(MaterialEventSource.Sync, payload.ClientCreatedAt),
            cancellationToken);

        var data = RequestSyncData.From(created.Request);
        return created.Created ? SyncPushResult.Applied(operation.ClientId, data) : SyncPushResult.Duplicate(operation.ClientId, data);
    }

    // --- update et transition : journal d'operations ---

    /// <summary>Resultat d'une operation et ce qu'il faut en garder dans le journal.</summary>
    private sealed record OperationOutcome(SyncPushResult Result, Guid? RequestId);

    /// <summary>Identifiant de la demande vise, retenu des qu'il est connu pour que le journal et les conflits puissent rendre son etat.</summary>
    private sealed class OperationScope
    {
        public Guid? RequestId { get; set; }
    }

    private async Task<SyncPushResult> LoggedAsync(SyncOperation operation, Func<Guid, OperationScope, Task<OperationOutcome>> action, CancellationToken cancellationToken)
    {
        // Renvoi apres une coupure : meme resultat, rien n'est rejoue.
        if (await journal.FindAsync(operation.ClientId, cancellationToken) is { } known)
        {
            return await ReplayAsync(known, operation, cancellationToken);
        }

        var siteId = RequireSite(operation);
        await siteAccess.EnsureAsync(siteId, cancellationToken);

        try
        {
            return await DbTransactions.RunAsync(db, async () =>
            {
                var scope = new OperationScope();
                var outcome = await ExecuteAsync(operation, siteId, scope, action, cancellationToken);

                var result = outcome.Result;
                var stored = result.Status == SyncStatuses.Duplicate ? SyncOperationLog.OutcomeApplied : result.Status;
                journal.Add(operation, stored, result.Code, outcome.RequestId, result.ConflictFields);
                await db.SaveChangesAsync(cancellationToken);
                return result;
            }, cancellationToken);
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            // La meme operation envoyee deux fois en parallele : la premiere a ecrit son journal, la seconde rend le meme resultat.
            db.ChangeTracker.Clear();
            if (await journal.FindAsync(operation.ClientId, cancellationToken) is { } winner)
            {
                return await ReplayAsync(winner, operation, cancellationToken);
            }

            throw;
        }
    }

    private async Task<OperationOutcome> ExecuteAsync(
        SyncOperation operation,
        Guid siteId,
        OperationScope scope,
        Func<Guid, OperationScope, Task<OperationOutcome>> action,
        CancellationToken cancellationToken)
    {
        try
        {
            return await action(siteId, scope);
        }
        catch (ConflictException exception)
        {
            // Champ change ailleurs depuis la valeur de depart : rien n'est applique, le serveur renvoie son etat.
            db.ChangeTracker.Clear();
            var current = exception.Current is MaterialRequestDetailResponse detail ? RequestSyncData.From(detail) : null;
            return new OperationOutcome(SyncPushResult.Conflict(operation.ClientId, current, exception.Code, exception.Fields), scope.RequestId);
        }
        catch (DomainRuleException exception) when (StateConflictCodes.Contains(exception.Code))
        {
            // Demande validee, annulee, commandee ou livree depuis la saisie : le serveur gagne, l'etat courant est renvoye.
            db.ChangeTracker.Clear();
            var current = scope.RequestId is { } requestId
                ? RequestSyncData.From(await requests.GetAsync(siteId, requestId, cancellationToken))
                : null;
            return new OperationOutcome(SyncPushResult.Conflict(operation.ClientId, current, exception.Code), scope.RequestId);
        }
        catch (DomainException exception)
        {
            // Droit manquant, validation, demande ou chantier introuvable, chantier archive : l'operation n'a jamais ete legitime.
            db.ChangeTracker.Clear();
            var errors = (exception as Core.Exceptions.ValidationException)?.Errors;
            return new OperationOutcome(SyncPushResult.Rejected(operation.ClientId, exception.Code, errors), scope.RequestId);
        }
    }

    private async Task<SyncPushResult> ReplayAsync(SyncOperationLog log, SyncOperation operation, CancellationToken cancellationToken)
    {
        // Un identifiant d'operation deja pris par quelqu'un d'autre : refus neutre, aucun etat n'est rendu.
        if (log.UserId != currentUser.Id)
        {
            return SyncPushResult.Rejected(operation.ClientId, ErrorCodes.Validation, new Dictionary<string, string[]> { ["clientId"] = ["L'identifiant client est déjà utilisé."] });
        }

        if (log.Outcome == SyncOperationLog.OutcomeRejected || log.SiteId is not { } siteId || log.ResourceId is not { } requestId)
        {
            return SyncPushResult.Rejected(operation.ClientId, log.Code ?? ErrorCodes.Validation);
        }

        // L'affectation est reverifiee : un acces retire depuis coupe aussi les renvois.
        await siteAccess.EnsureAsync(siteId, cancellationToken);
        var data = RequestSyncData.From(await requests.GetAsync(siteId, requestId, cancellationToken));

        return log.Outcome == SyncOperationLog.OutcomeConflict
            ? SyncPushResult.Conflict(operation.ClientId, data, log.Code, log.ConflictFields?.Split(',', StringSplitOptions.RemoveEmptyEntries))
            : SyncPushResult.Duplicate(operation.ClientId, data);
    }

    // --- update ---

    private async Task<OperationOutcome> UpdateAsync(SyncOperation operation, Guid siteId, OperationScope scope, CancellationToken cancellationToken)
    {
        var payload = operation.Payload is { ValueKind: JsonValueKind.Object } element ? element : throw InvalidPayload();

        var requestId = await ResolveRequestAsync(siteId, payload, cancellationToken);
        scope.RequestId = requestId;

        if (!payload.TryGetProperty("changes", out var changesElement) || !payload.TryGetProperty("base", out var baseElement))
        {
            throw new Core.Exceptions.ValidationException("changes", "Les modifications et leurs valeurs de départ sont obligatoires.");
        }

        var changes = ParseFields(changesElement, "changes");
        var baseValues = ParseFields(baseElement, "base");
        var clientCreatedAt = ReadClientCreatedAt(payload);

        var result = await requests.ApplyChangesAsync(
            siteId, requestId, changes, baseValues, new RequestActionContext(MaterialEventSource.Sync, clientCreatedAt), cancellationToken);

        return ToOutcome(operation, result, requestId);
    }

    private static RequestChanges ParseFields(JsonElement element, string section)
    {
        if (element.ValueKind != JsonValueKind.Object)
        {
            throw new Core.Exceptions.ValidationException(section, "Un objet est attendu.");
        }

        var errors = new ErrorCollector();
        Guid? productId = null;
        string? freeProductName = null;
        QuantityInput? quantity = null;
        Guid? zoneId = null;
        var clearZone = false;
        DateOnly? neededBy = null;
        Priority? priority = null;
        string? note = null;

        foreach (var property in element.EnumerateObject())
        {
            var path = $"{section}.{property.Name}";
            var value = property.Value;

            switch (property.Name)
            {
                case RequestFieldNames.ProductId:
                    productId = ParseGuid(value, path, errors, allowNull: true);
                    break;

                case RequestFieldNames.FreeProductName:
                    freeProductName = ParseString(value, path, errors);
                    break;

                case RequestFieldNames.Quantity:
                    quantity = ParseQuantity(value, path, errors);
                    break;

                case RequestFieldNames.ZoneId:
                    zoneId = ParseGuid(value, path, errors, allowNull: true);
                    clearZone = value.ValueKind == JsonValueKind.Null;
                    break;

                case RequestFieldNames.NeededBy:
                    neededBy = ParseDate(value.ValueKind == JsonValueKind.String ? value.GetString() : null, path, errors);
                    break;

                case RequestFieldNames.Priority:
                    priority = Enum.TryParse<Priority>(value.ValueKind == JsonValueKind.String ? value.GetString() : null, out var parsed) && Enum.IsDefined(parsed)
                        ? parsed
                        : AddError<Priority?>(errors, path, "L'urgence est inconnue.");
                    break;

                case RequestFieldNames.Note:
                    // Une remarque a null est une remarque effacee.
                    note = value.ValueKind == JsonValueKind.Null ? string.Empty : ParseString(value, path, errors);
                    break;

                default:
                    errors.Add(path, "Ce champ ne se modifie pas.");
                    break;
            }
        }

        errors.ThrowIfAny();
        return new RequestChanges(productId, freeProductName, quantity, zoneId, clearZone, neededBy, priority, note);
    }

    // --- transition ---

    private async Task<OperationOutcome> TransitionAsync(SyncOperation operation, Guid siteId, OperationScope scope, CancellationToken cancellationToken)
    {
        var payload = operation.Payload is { ValueKind: JsonValueKind.Object } element ? element : throw InvalidPayload();
        var body = ReadPayload<TransitionPayload>(operation);

        var requestId = await ResolveRequestAsync(siteId, payload, cancellationToken);
        scope.RequestId = requestId;
        var context = new RequestActionContext(MaterialEventSource.Sync, body.ClientCreatedAt);

        var result = body.Action switch
        {
            "approve" => await requests.ApproveAsync(
                siteId, requestId, body.Quantity is { } quantity ? new QuantityInput(quantity.Value, quantity.Unit) : null, context, cancellationToken),
            "reject" => await requests.RejectAsync(siteId, requestId, body.ReasonCode, body.ReasonNote, context, cancellationToken),
            "cancel" => await requests.CancelAsync(siteId, requestId, body.ReasonCode, body.ReasonNote, context, cancellationToken),
            "receive" => await requests.ReceiveAsync(siteId, requestId, body.Note, context, cancellationToken),
            _ => throw new Core.Exceptions.ValidationException("action", "L'action est inconnue (approve, reject, cancel ou receive)."),
        };

        return ToOutcome(operation, result, requestId);
    }

    // --- outils ---

    private static OperationOutcome ToOutcome(SyncOperation operation, RequestActionResult result, Guid requestId)
    {
        var data = RequestSyncData.From(result.Request);
        return new OperationOutcome(
            result.Applied ? SyncPushResult.Applied(operation.ClientId, data) : SyncPushResult.Duplicate(operation.ClientId, data),
            requestId);
    }

    /// <summary>La demande visee par son identifiant serveur ou par le <c>clientId</c> de sa creation (encore en attente d'envoi cote telephone).</summary>
    private async Task<Guid> ResolveRequestAsync(Guid siteId, JsonElement payload, CancellationToken cancellationToken)
    {
        if (payload.TryGetProperty("requestId", out var id) && id.ValueKind == JsonValueKind.String && Guid.TryParse(id.GetString(), out var requestId))
        {
            return requestId;
        }

        if (payload.TryGetProperty("requestClientId", out var clientId) && clientId.ValueKind == JsonValueKind.String && Guid.TryParse(clientId.GetString(), out var requestClientId))
        {
            return (await requestRepository.FirstOrDefaultAsync(new RequestByClientIdSpecification(siteId, requestClientId), cancellationToken))?.Id
                ?? throw new NotFoundException();
        }

        throw new Core.Exceptions.ValidationException("requestId", "La demande visée est obligatoire (requestId ou requestClientId).");
    }

    private static Guid RequireSite(SyncOperation operation)
        => operation.SiteId is { } siteId && siteId != Guid.Empty
            ? siteId
            : throw new Core.Exceptions.ValidationException("siteId", "Le chantier est obligatoire.");

    private static DateTimeOffset? ReadClientCreatedAt(JsonElement payload)
        => payload.TryGetProperty("clientCreatedAt", out var value) && value.ValueKind == JsonValueKind.String && value.TryGetDateTimeOffset(out var at) ? at : null;

    private static T ReadPayload<T>(SyncOperation operation)
        where T : class
    {
        try
        {
            return operation.Payload?.Deserialize<T>(SyncJson.Options) ?? throw InvalidPayload();
        }
        catch (JsonException)
        {
            // Pas d'echo de la valeur recue.
            throw InvalidPayload();
        }
    }

    private static Core.Exceptions.ValidationException InvalidPayload()
        => new("payload", "Le contenu de l'opération est invalide.");

    private static DateOnly? ParseDate(string? text, string field, ErrorCollector errors)
    {
        if (text is null)
        {
            return null;
        }

        if (DateOnly.TryParseExact(text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var date))
        {
            return date;
        }

        errors.AddInvalidDate(field, "La date est incomplète ou impossible.");
        return null;
    }

    private static Guid? ParseGuid(JsonElement value, string path, ErrorCollector errors, bool allowNull)
    {
        if (value.ValueKind == JsonValueKind.Null && allowNull)
        {
            return null;
        }

        if (value.ValueKind == JsonValueKind.String && Guid.TryParse(value.GetString(), out var id))
        {
            return id;
        }

        errors.Add(path, "L'identifiant est invalide.");
        return null;
    }

    private static string? ParseString(JsonElement value, string path, ErrorCollector errors)
    {
        if (value.ValueKind == JsonValueKind.Null)
        {
            return null;
        }

        if (value.ValueKind == JsonValueKind.String)
        {
            return value.GetString();
        }

        errors.Add(path, "Un texte est attendu.");
        return null;
    }

    private static QuantityInput? ParseQuantity(JsonElement value, string path, ErrorCollector errors)
    {
        if (value.ValueKind != JsonValueKind.Object)
        {
            errors.Add(path, "Une quantité avec son unité est attendue.");
            return null;
        }

        decimal? number = null;
        MeasureUnit? unit = null;
        foreach (var property in value.EnumerateObject())
        {
            switch (property.Name)
            {
                case "value" when property.Value.ValueKind == JsonValueKind.Number && property.Value.TryGetDecimal(out var parsed):
                    number = parsed;
                    break;

                case "value" when property.Value.ValueKind != JsonValueKind.Null:
                    errors.Add(path, "La valeur de la quantité est invalide.");
                    break;

                case "unit" when property.Value.ValueKind == JsonValueKind.String && MeasureUnits.TryParse(property.Value.GetString(), out var known):
                    unit = known;
                    break;

                case "unit" when property.Value.ValueKind != JsonValueKind.Null:
                    errors.Add(path, "L'unité est inconnue.");
                    break;
            }
        }

        return new QuantityInput(number, unit);
    }

    private static T? AddError<T>(ErrorCollector errors, string path, string message)
    {
        errors.Add(path, message);
        return default;
    }

    /// <summary>Champs acceptes a la creation : aucun statut, numero, auteur ni date d'audit (affectation de masse).</summary>
    private sealed record CreatePayload(
        DateTimeOffset? ClientCreatedAt,
        Guid? ProductId,
        string? FreeProductName,
        QuantityPayload? Quantity,
        Guid? ZoneId,
        Guid? ZoneClientId,
        string? NeededBy,
        Priority? Priority,
        string? Note);

    private sealed record QuantityPayload(decimal? Value, MeasureUnit? Unit);

    private sealed record TransitionPayload(
        DateTimeOffset? ClientCreatedAt,
        string? Action,
        QuantityPayload? Quantity,
        string? ReasonCode,
        string? ReasonNote,
        string? Note);
}
