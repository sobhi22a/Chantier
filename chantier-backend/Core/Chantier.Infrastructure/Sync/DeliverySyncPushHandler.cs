using System.Globalization;
using System.Text.Json;
using Ardalis.Specification;
using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Entities.Sync;
using Chantier.Core.Exceptions;
using Chantier.Core.Materials;
using Chantier.Core.Sites;
using Chantier.Core.Specifications.Materials;
using Chantier.Core.Sync;
using Chantier.Core.Validation;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Operations <c>delivery</c> du telephone : <c>create</c> (idempotente par l'index unique de la livraison ; <b>jamais refusee a cause du statut de la demande</b> : fait de chantier,
/// non rattachee avec son motif ; une demande designee par un <c>clientId</c> introuvable donne <c>RequestMissing</c>), <c>update</c> (comparaison a trois valeurs par champ,
/// tout ou rien, premiere arrivee retenue) et <c>transition</c> <c>cancel</c> (ADR 0011).
/// <b>Aucune regle n'est ecrite ici</b> : tout passe par <see cref="IDeliveryService"/> (droits, produit, unites, dates, recalcul, historique), comme l'API REST. Etat du serveur change
/// (livraison annulee, demande receptionnee, champ corrige ailleurs) = <c>conflict</c> avec l'etat courant ; refus jamais legitime = <c>rejected</c>. Les formes rendues sont celles de la
/// synchronisation (jamais un montant).
/// </summary>
public sealed class DeliverySyncPushHandler(
    ISiteAccess siteAccess,
    ICurrentUser currentUser,
    IDeliveryService deliveries,
    IRepositoryBase<Delivery> deliveryRepository,
    IRepositoryBase<MaterialRequest> requestRepository,
    SyncOperationLogService journal,
    ApplicationDbContext db) : ISyncPushHandler
{
    private static readonly string[] StateConflictCodes = [ErrorCodes.TransitionInterdite, ErrorCodes.DemandeNonOuverte];

    public string Entity => SyncEntities.Delivery;

    public Task<SyncPushResult> HandleAsync(SyncOperation operation, CancellationToken cancellationToken = default) => operation.Operation switch
    {
        SyncOperations.Create => CreateAsync(operation, cancellationToken),
        SyncOperations.Update => LoggedAsync(operation, (siteId, scope) => UpdateAsync(operation, siteId, scope, cancellationToken), cancellationToken),
        SyncOperations.Transition => LoggedAsync(operation, (siteId, scope) => CancelAsync(operation, siteId, scope, cancellationToken), cancellationToken),
        _ => Task.FromResult(SyncPushResult.Rejected(operation.ClientId, ErrorCodes.EntiteNonSynchronisable)),
    };

    // --- create ---

    private async Task<SyncPushResult> CreateAsync(SyncOperation operation, CancellationToken cancellationToken)
    {
        var siteId = RequireSite(operation);
        await siteAccess.EnsureAsync(siteId, cancellationToken);

        var payload = ReadPayload<CreatePayload>(operation);
        var errors = new ErrorCollector();
        var date = ParseDate(payload.DeliveryDate, "deliveryDate", errors);
        errors.ThrowIfAny();

        // Demande creee hors ligne dans le meme lot : designee par son clientId. Introuvable : la livraison est quand meme enregistree, non rattachee.
        var requestId = payload.RequestId;
        UnattachedReason? reason = null;
        if (requestId is null && payload.RequestClientId is { } requestClientId)
        {
            requestId = (await requestRepository.FirstOrDefaultAsync(new RequestByClientIdSpecification(siteId, requestClientId), cancellationToken))?.Id;
            reason = requestId is null ? UnattachedReason.RequestMissing : null;
        }

        var fields = new DeliveryFields(
            payload.SupplierId, payload.FreeSupplierName, payload.ProductId, payload.FreeProductName, payload.Quantity?.Value, payload.Quantity?.Unit,
            date, payload.DeliveryNoteNumber, payload.Conformity, payload.ReserveReasonCode, payload.ReserveNote);

        try
        {
            var created = await deliveries.CreateAsync(
                siteId,
                new CreateDeliveryDto(operation.ClientId, payload.ClientCreatedAt, requestId, fields, reason),
                new RequestActionContext(MaterialEventSource.Sync, payload.ClientCreatedAt),
                cancellationToken);

            var data = DeliverySyncData.From(created.Delivery);
            return created.Created ? SyncPushResult.Applied(operation.ClientId, data) : SyncPushResult.Duplicate(operation.ClientId, data);
        }
        catch (DomainException exception)
        {
            db.ChangeTracker.Clear();
            return SyncPushResult.Rejected(operation.ClientId, exception.Code, (exception as Core.Exceptions.ValidationException)?.Errors);
        }
    }

    // --- update et transition : journal d'operations ---

    private sealed record OperationOutcome(SyncPushResult Result, Guid? DeliveryId);

    private sealed class OperationScope
    {
        public Guid? DeliveryId { get; set; }
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
                journal.Add(operation, stored, result.Code, outcome.DeliveryId, result.ConflictFields);
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
            db.ChangeTracker.Clear();
            var current = exception.Current is DeliveryDetailResponse detail ? DeliverySyncData.From(detail) : null;
            return new OperationOutcome(SyncPushResult.Conflict(operation.ClientId, current, exception.Code, exception.Fields), scope.DeliveryId);
        }
        catch (DomainRuleException exception) when (StateConflictCodes.Contains(exception.Code))
        {
            // Livraison annulee ou demande receptionnee entre-temps : le serveur gagne, l'etat courant est renvoye.
            db.ChangeTracker.Clear();
            var current = scope.DeliveryId is { } deliveryId ? DeliverySyncData.From(await deliveries.GetAsync(siteId, deliveryId, cancellationToken)) : null;
            return new OperationOutcome(SyncPushResult.Conflict(operation.ClientId, current, exception.Code), scope.DeliveryId);
        }
        catch (DomainException exception)
        {
            db.ChangeTracker.Clear();
            return new OperationOutcome(
                SyncPushResult.Rejected(operation.ClientId, exception.Code, (exception as Core.Exceptions.ValidationException)?.Errors), scope.DeliveryId);
        }
    }

    private async Task<SyncPushResult> ReplayAsync(SyncOperationLog log, SyncOperation operation, CancellationToken cancellationToken)
    {
        if (log.UserId != currentUser.Id)
        {
            return SyncPushResult.Rejected(operation.ClientId, ErrorCodes.Validation, new Dictionary<string, string[]> { ["clientId"] = ["L'identifiant client est déjà utilisé."] });
        }

        if (log.Outcome == SyncOperationLog.OutcomeRejected || log.SiteId is not { } siteId || log.ResourceId is not { } deliveryId)
        {
            return SyncPushResult.Rejected(operation.ClientId, log.Code ?? ErrorCodes.Validation);
        }

        // L'affectation est reverifiee : un acces retire depuis coupe aussi les renvois.
        await siteAccess.EnsureAsync(siteId, cancellationToken);
        var data = DeliverySyncData.From(await deliveries.GetAsync(siteId, deliveryId, cancellationToken));

        return log.Outcome == SyncOperationLog.OutcomeConflict
            ? SyncPushResult.Conflict(operation.ClientId, data, log.Code, log.ConflictFields?.Split(',', StringSplitOptions.RemoveEmptyEntries))
            : SyncPushResult.Duplicate(operation.ClientId, data);
    }

    // --- update ---

    private async Task<OperationOutcome> UpdateAsync(SyncOperation operation, Guid siteId, OperationScope scope, CancellationToken cancellationToken)
    {
        var payload = operation.Payload is { ValueKind: JsonValueKind.Object } element ? element : throw InvalidPayload();
        var deliveryId = await ResolveDeliveryAsync(siteId, payload, cancellationToken);
        scope.DeliveryId = deliveryId;

        if (!payload.TryGetProperty("changes", out var changesElement) || !payload.TryGetProperty("base", out var baseElement))
        {
            throw new Core.Exceptions.ValidationException("changes", "Les modifications et leurs valeurs de départ sont obligatoires.");
        }

        var changes = ParseChanges(changesElement, "changes");
        var baseValues = ParseChanges(baseElement, "base");

        var delivery = await deliveryRepository.FirstOrDefaultAsync(new DeliveryBySiteAndIdSpecification(siteId, deliveryId), cancellationToken) ?? throw new NotFoundException();

        // L'etat decide d'abord (annulee, demande receptionnee : conflit), avant la comparaison des champs.
        if (delivery.IsCancelled)
        {
            throw new DomainRuleException(ErrorCodes.TransitionInterdite, "Une livraison annulée ne se corrige pas.");
        }

        if (delivery.RequestId is { } requestId
            && (await requestRepository.FirstOrDefaultAsync(new RequestBySiteAndIdSpecification(siteId, requestId), cancellationToken))?.Status == RequestStatus.Received)
        {
            throw new DomainRuleException(ErrorCodes.DemandeNonOuverte, "Cette demande est réceptionnée : ses livraisons ne se modifient plus.");
        }

        var proposed = DeliveryCanonical.Of(changes);
        var start = DeliveryCanonical.Of(baseValues);
        var errors = new ErrorCollector();
        foreach (var field in proposed.Keys.Where(field => !start.ContainsKey(field)))
        {
            errors.Add($"base.{field}", "La valeur de départ est obligatoire pour chaque champ modifié.");
        }

        errors.ThrowIfAny();

        var merge = FieldMergeEvaluator.Evaluate(DeliveryCanonical.Of(delivery), start, proposed);
        if (merge.HasConflict)
        {
            throw new ConflictException(await deliveries.GetAsync(siteId, deliveryId, cancellationToken), ErrorCodes.ConflitVersion) { Fields = merge.Conflicts };
        }

        var detail = await deliveries.UpdateAsync(siteId, deliveryId, new UpdateDeliveryDto(delivery.Version, changes), new RequestActionContext(MaterialEventSource.Sync, ReadClientCreatedAt(payload)), cancellationToken);
        var data = DeliverySyncData.From(detail);
        return new OperationOutcome(
            merge.ToApply.Count == 0 ? SyncPushResult.Duplicate(operation.ClientId, data) : SyncPushResult.Applied(operation.ClientId, data),
            deliveryId);
    }

    private static DeliveryChanges ParseChanges(JsonElement element, string section)
    {
        if (element.ValueKind != JsonValueKind.Object)
        {
            throw new Core.Exceptions.ValidationException(section, "Un objet est attendu.");
        }

        var errors = new ErrorCollector();
        QuantityInput? quantity = null;
        DateOnly? date = null;
        string? note = null;
        Conformity? conformity = null;
        string? reserveCode = null;
        string? reserveNote = null;

        foreach (var property in element.EnumerateObject())
        {
            var path = $"{section}.{property.Name}";
            var value = property.Value;
            switch (property.Name)
            {
                case DeliveryFieldNames.Quantity:
                    quantity = ParseQuantity(value, path, errors);
                    break;

                case DeliveryFieldNames.DeliveryDate:
                    date = ParseDate(value.ValueKind == JsonValueKind.String ? value.GetString() : null, path, errors, required: true);
                    break;

                case DeliveryFieldNames.DeliveryNoteNumber:
                    note = ParseString(value, path, errors);
                    break;

                case DeliveryFieldNames.Conformity:
                    conformity = Enum.TryParse<Conformity>(value.ValueKind == JsonValueKind.String ? value.GetString() : null, out var parsed) && Enum.IsDefined(parsed)
                        ? parsed
                        : AddError<Conformity?>(errors, path, "La conformité est inconnue.");
                    break;

                case DeliveryFieldNames.ReserveReasonCode:
                    reserveCode = ParseString(value, path, errors);
                    break;

                case DeliveryFieldNames.ReserveNote:
                    reserveNote = ParseString(value, path, errors);
                    break;

                default:
                    errors.Add(path, "Ce champ ne se modifie pas.");
                    break;
            }
        }

        errors.ThrowIfAny();
        return new DeliveryChanges(quantity, date, note, conformity, reserveCode, reserveNote);
    }

    // --- transition ---

    private async Task<OperationOutcome> CancelAsync(SyncOperation operation, Guid siteId, OperationScope scope, CancellationToken cancellationToken)
    {
        var payload = operation.Payload is { ValueKind: JsonValueKind.Object } element ? element : throw InvalidPayload();
        var body = ReadPayload<TransitionPayload>(operation);

        var deliveryId = await ResolveDeliveryAsync(siteId, payload, cancellationToken);
        scope.DeliveryId = deliveryId;
        if (body.Action != "cancel")
        {
            throw new Core.Exceptions.ValidationException("action", "L'action est inconnue (cancel).");
        }

        var result = await deliveries.CancelAsync(
            siteId, deliveryId, body.ReasonCode, body.ReasonNote, new RequestActionContext(MaterialEventSource.Sync, body.ClientCreatedAt), cancellationToken);
        var data = DeliverySyncData.From(result.Delivery);
        return new OperationOutcome(
            result.Applied ? SyncPushResult.Applied(operation.ClientId, data) : SyncPushResult.Duplicate(operation.ClientId, data),
            deliveryId);
    }

    // --- outils ---

    /// <summary>La livraison visee par son identifiant serveur ou par le <c>clientId</c> de sa creation (encore en attente d'envoi cote telephone).</summary>
    private async Task<Guid> ResolveDeliveryAsync(Guid siteId, JsonElement payload, CancellationToken cancellationToken)
    {
        if (payload.TryGetProperty("deliveryId", out var id) && id.ValueKind == JsonValueKind.String && Guid.TryParse(id.GetString(), out var deliveryId))
        {
            return deliveryId;
        }

        if (payload.TryGetProperty("deliveryClientId", out var clientId) && clientId.ValueKind == JsonValueKind.String && Guid.TryParse(clientId.GetString(), out var deliveryClientId))
        {
            return (await deliveryRepository.FirstOrDefaultAsync(new DeliveryByClientIdSpecification(siteId, deliveryClientId), cancellationToken))?.Id
                ?? throw new NotFoundException();
        }

        throw new Core.Exceptions.ValidationException("deliveryId", "La livraison visée est obligatoire (deliveryId ou deliveryClientId).");
    }

    private static DateTimeOffset? ReadClientCreatedAt(JsonElement payload)
        => payload.TryGetProperty("clientCreatedAt", out var value) && value.ValueKind == JsonValueKind.String && value.TryGetDateTimeOffset(out var at) ? at : null;

    private static Guid RequireSite(SyncOperation operation)
        => operation.SiteId is { } siteId && siteId != Guid.Empty
            ? siteId
            : throw new Core.Exceptions.ValidationException("siteId", "Le chantier est obligatoire.");

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

    private static DateOnly? ParseDate(string? text, string field, ErrorCollector errors, bool required = false)
    {
        if (text is null)
        {
            if (required)
            {
                errors.AddInvalidDate(field, "La date est incomplète ou impossible.");
            }

            return null;
        }

        if (DateOnly.TryParseExact(text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var date))
        {
            return date;
        }

        errors.AddInvalidDate(field, "La date est incomplète ou impossible.");
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

    /// <summary>Champs acceptes a la creation : aucun numero, statut, montant, motif de non-rattachement ni date d'audit (affectation de masse).</summary>
    private sealed record CreatePayload(
        DateTimeOffset? ClientCreatedAt,
        Guid? RequestId,
        Guid? RequestClientId,
        Guid? SupplierId,
        string? FreeSupplierName,
        Guid? ProductId,
        string? FreeProductName,
        QuantityPayload? Quantity,
        string? DeliveryDate,
        string? DeliveryNoteNumber,
        Conformity? Conformity,
        string? ReserveReasonCode,
        string? ReserveNote);

    private sealed record QuantityPayload(decimal? Value, MeasureUnit? Unit);

    private sealed record TransitionPayload(DateTimeOffset? ClientCreatedAt, string? Action, string? ReasonCode, string? ReasonNote);
}

/// <summary>
/// Operation <c>photo</c> / <c>create</c> : metadonnees seulement (idempotentes par <c>clientId</c>) ; le fichier JPEG part ensuite par <c>PUT</c> direct, un a la fois
/// (hors synchronisation de lot, ADR 0013). <b>Aucune regle ici</b> : tout passe par <see cref="IPhotoService"/>.
/// </summary>
public sealed class PhotoSyncPushHandler(
    ISiteAccess siteAccess,
    IPhotoService photos,
    IRepositoryBase<Delivery> deliveryRepository,
    ApplicationDbContext db) : ISyncPushHandler
{
    public string Entity => SyncEntities.Photo;

    public async Task<SyncPushResult> HandleAsync(SyncOperation operation, CancellationToken cancellationToken = default)
    {
        if (operation.Operation != SyncOperations.Create)
        {
            return SyncPushResult.Rejected(operation.ClientId, ErrorCodes.EntiteNonSynchronisable);
        }

        var siteId = operation.SiteId is { } id && id != Guid.Empty
            ? id
            : throw new Core.Exceptions.ValidationException("siteId", "Le chantier est obligatoire.");
        await siteAccess.EnsureAsync(siteId, cancellationToken);

        var payload = ReadPayload(operation);

        try
        {
            var deliveryId = payload.DeliveryId;
            if (deliveryId is null && payload.DeliveryClientId is { } deliveryClientId)
            {
                deliveryId = (await deliveryRepository.FirstOrDefaultAsync(new DeliveryByClientIdSpecification(siteId, deliveryClientId), cancellationToken))?.Id;
            }

            var created = await photos.CreateAsync(
                siteId,
                deliveryId ?? throw new NotFoundException(),
                new CreatePhotoDto(operation.ClientId, payload.ClientCreatedAt, payload.TakenAt, payload.ContentType, payload.SizeBytes, payload.Sha256),
                new RequestActionContext(MaterialEventSource.Sync, payload.ClientCreatedAt),
                cancellationToken);

            return created.Created ? SyncPushResult.Applied(operation.ClientId, created.Photo) : SyncPushResult.Duplicate(operation.ClientId, created.Photo);
        }
        catch (DomainException exception)
        {
            db.ChangeTracker.Clear();
            return SyncPushResult.Rejected(operation.ClientId, exception.Code, (exception as Core.Exceptions.ValidationException)?.Errors);
        }
    }

    private static PhotoPayload ReadPayload(SyncOperation operation)
    {
        try
        {
            return operation.Payload?.Deserialize<PhotoPayload>(SyncJson.Options) ?? throw new Core.Exceptions.ValidationException("payload", "Le contenu de l'opération est invalide.");
        }
        catch (JsonException)
        {
            throw new Core.Exceptions.ValidationException("payload", "Le contenu de l'opération est invalide.");
        }
    }

    private sealed record PhotoPayload(
        Guid? DeliveryId,
        Guid? DeliveryClientId,
        DateTimeOffset? ClientCreatedAt,
        DateTimeOffset? TakenAt,
        string? ContentType,
        long? SizeBytes,
        string? Sha256);
}
