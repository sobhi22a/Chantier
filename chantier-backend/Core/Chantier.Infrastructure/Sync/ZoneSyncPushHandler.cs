using System.Text.Json;
using Ardalis.Specification;
using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.Core.Sites;
using Chantier.Core.Specifications.Sites;
using Chantier.Core.Sync;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Creation d'une zone hors ligne (<c>zone</c> / <c>create</c>). Memes droits et memes validations que <c>POST /sites/{siteId}/zones</c>,
/// dont l'idempotence par (chantier, <c>clientId</c>) : un renvoi donne <c>duplicate</c>. Une zone <b>identique</b> deja creee par un
/// autre telephone n'est pas une erreur : la zone retenue est renvoyee avec <c>merged</c> et le client y rattache ses saisies (CA-011.6).
/// Ajout seul : jamais de conflit.
/// </summary>
public sealed class ZoneSyncPushHandler(
    ISiteAccess siteAccess,
    IUserPermissions permissions,
    IZoneService zones,
    IRepositoryBase<Zone> zoneRepository,
    IOptions<ZoneOptions> options) : ISyncPushHandler
{
    public string Entity => SyncEntities.Zone;

    public async Task<SyncPushResult> HandleAsync(SyncOperation operation, CancellationToken cancellationToken = default)
    {
        if (operation.Operation != SyncOperations.Create)
        {
            return SyncPushResult.Rejected(operation.ClientId, ErrorCodes.EntiteNonSynchronisable);
        }

        // Le role decide de l'action, puis l'affectation du perimetre : meme ordre que l'API REST.
        if (!await permissions.HasAsync(Permissions.ZonesCreate, cancellationToken))
        {
            throw new ForbiddenException();
        }

        var siteId = operation.SiteId ?? throw new Core.Exceptions.ValidationException("siteId", "Le chantier est obligatoire.");
        await siteAccess.EnsureAsync(siteId, cancellationToken);

        var payload = ReadPayload(operation);
        var dto = new CreateZoneDto(
            operation.ClientId,
            payload.ClientCreatedAt,
            new ZoneInput(payload.Block ?? string.Empty, payload.Elevation, payload.RoomType, payload.RoomNumber, payload.RoomLabel));

        try
        {
            var result = await zones.CreateAsync(siteId, dto, cancellationToken);
            return result.Created
                ? SyncPushResult.Applied(operation.ClientId, result.Zone)
                : SyncPushResult.Duplicate(operation.ClientId, result.Zone);
        }
        catch (DomainRuleException exception) when (exception.Code == ErrorCodes.ZoneExistante)
        {
            var input = Zone.Normalize(dto.Data, options.Value);
            var identical = await zoneRepository.FirstOrDefaultAsync(
                new ZoneByPositionSpecification(siteId, input.Block, input.Elevation, input.RoomType, input.RoomNumber, input.RoomLabel),
                cancellationToken);

            if (identical is null)
            {
                // Archivee entre-temps : le refus reste visible plutot qu'une fusion silencieuse.
                throw;
            }

            return SyncPushResult.Duplicate(operation.ClientId, await zones.GetAsync(siteId, identical.Id, cancellationToken), merged: true);
        }
    }

    private static ZonePayload ReadPayload(SyncOperation operation)
    {
        try
        {
            return operation.Payload?.Deserialize<ZonePayload>(SyncJson.Options)
                ?? throw new Core.Exceptions.ValidationException("payload", "Le contenu de l'opération est obligatoire.");
        }
        catch (JsonException)
        {
            // Pas d'echo de la valeur recue.
            throw new Core.Exceptions.ValidationException("payload", "Le contenu de l'opération est invalide.");
        }
    }

    /// <summary>Champs acceptes : aucun statut, archivage ni audit (protection contre l'affectation de masse).</summary>
    private sealed record ZonePayload(
        DateTimeOffset? ClientCreatedAt,
        string? Block,
        decimal? Elevation,
        RoomType? RoomType,
        int? RoomNumber,
        string? RoomLabel);
}
