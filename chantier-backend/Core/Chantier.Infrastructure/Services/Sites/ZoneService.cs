using System.Buffers.Text;
using System.Globalization;
using System.Text;
using Ardalis.Specification;
using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Common;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Exceptions;
using Chantier.Core.Paging;
using Chantier.Core.Sites;
using Chantier.Core.Specifications.Sites;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Services.Sites;

/// <summary>
/// Zones d'un chantier. Toujours lues par (chantier, identifiant). Creation idempotente par (chantier, <c>clientId</c>) :
/// un renvoi retourne la meme zone sans effet de bord (regle 6). Un chantier archive est en lecture seule.
/// </summary>
public sealed class ZoneService(
    IRepositoryBase<Zone> zones,
    IRepositoryBase<Site> sites,
    ApplicationDbContext db,
    IOptions<ZoneOptions> options,
    ICurrentUser currentUser,
    IUserDirectory directory,
    TimeProvider time) : IZoneService
{
    private ZoneOptions Rules => options.Value;

    public async Task<CursorPage<ZoneResponse>> ListAsync(Guid siteId, ZoneListQuery query, CancellationToken cancellationToken = default)
    {
        if (query.PageSize is < 1 or > PagingRules.MaxPageSize)
        {
            throw new Core.Exceptions.ValidationException("pageSize", $"La taille de page doit être comprise entre 1 et {PagingRules.MaxPageSize}.");
        }

        var skip = DecodeCursor(query.Cursor);

        // Une ligne de plus que la page : sa presence dit s'il y a une suite.
        var rows = await zones.ListAsync(
            new ZonesBySiteSpecification(siteId, query.Block, query.Search, query.IncludeArchived, skip, query.PageSize + 1),
            cancellationToken);

        var hasMore = rows.Count > query.PageSize;
        var page = hasMore ? rows.Take(query.PageSize).ToList() : rows;
        var items = await ToResponsesAsync(page, cancellationToken);
        return new CursorPage<ZoneResponse>(items, hasMore ? EncodeCursor(skip + query.PageSize) : null);
    }

    public async Task<ZoneResponse> GetAsync(Guid siteId, Guid zoneId, CancellationToken cancellationToken = default)
        => await ToResponseAsync(await LoadAsync(siteId, zoneId, cancellationToken), cancellationToken);

    public async Task<ZoneCreationResult> CreateAsync(Guid siteId, CreateZoneDto dto, CancellationToken cancellationToken = default)
    {
        // Renvoi du meme clientId : meme ressource, aucun effet (meme si le chantier a ete archive depuis).
        if (dto.ClientId is { } clientId && clientId != Guid.Empty
            && await zones.FirstOrDefaultAsync(new ZoneByClientIdSpecification(siteId, clientId), cancellationToken) is { } existing)
        {
            return new ZoneCreationResult(await ToResponseAsync(existing, cancellationToken), Created: false);
        }

        var site = await sites.GetByIdAsync(siteId, cancellationToken) ?? throw new NotFoundException();
        site.EnsureWritable();

        var zone = Zone.Create(siteId, dto, Rules);

        if (await IsPositionTakenAsync(zone.SiteId, zone.Block, zone.Elevation, zone.RoomType, zone.RoomNumber, zone.RoomLabel, null, cancellationToken))
        {
            // Le meme clientId a pu etre traite entre-temps par une requete parallele (renvoi) : meme ressource, pas d'erreur.
            return await ResolveRaceAsync(siteId, dto.ClientId, cancellationToken);
        }

        try
        {
            await zones.AddAsync(zone, cancellationToken);
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            db.Entry(zone).State = EntityState.Detached;
            return await ResolveRaceAsync(siteId, dto.ClientId, cancellationToken);
        }

        return new ZoneCreationResult(await ToResponseAsync(zone, cancellationToken), Created: true);
    }

    public async Task<ZoneResponse> UpdateAsync(Guid siteId, Guid zoneId, UpdateZoneDto dto, CancellationToken cancellationToken = default)
    {
        var zone = await LoadAsync(siteId, zoneId, cancellationToken);
        await EnsureVersionAsync(zone, dto.Version, cancellationToken);
        await EnsureSiteWritableAsync(siteId, cancellationToken);

        var input = Zone.Normalize(dto.Data, Rules);
        await EnsurePositionFreeAsync(siteId, input, zone.Id, cancellationToken);
        zone.Update(input, Rules);

        try
        {
            await zones.UpdateAsync(zone, cancellationToken);
        }
        catch (DbUpdateConcurrencyException)
        {
            await db.Entry(zone).ReloadAsync(cancellationToken);
            throw new ConflictException(await ToResponseAsync(zone, cancellationToken));
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            throw ZoneAlreadyExists();
        }

        return await ToResponseAsync(zone, cancellationToken);
    }

    public async Task<ZoneResponse> ArchiveAsync(Guid siteId, Guid zoneId, CancellationToken cancellationToken = default)
    {
        var zone = await LoadAsync(siteId, zoneId, cancellationToken);
        await EnsureSiteWritableAsync(siteId, cancellationToken);
        if (!zone.IsArchived)
        {
            zone.Archive(currentUser.Id ?? throw new NotFoundException(), time.GetUtcNow());
            await zones.UpdateAsync(zone, cancellationToken);
        }

        return await ToResponseAsync(zone, cancellationToken);
    }

    public async Task<ZoneResponse> RestoreAsync(Guid siteId, Guid zoneId, CancellationToken cancellationToken = default)
    {
        var zone = await LoadAsync(siteId, zoneId, cancellationToken);
        await EnsureSiteWritableAsync(siteId, cancellationToken);
        if (zone.IsArchived)
        {
            // Une zone identique a pu etre creee depuis l'archivage : la restauration se heurte alors a ZONE_EXISTANTE.
            await EnsurePositionFreeAsync(zone, zone.Id, cancellationToken);
            zone.Restore();
            try
            {
                await zones.UpdateAsync(zone, cancellationToken);
            }
            catch (DbUpdateException exception) when (exception.IsUniqueViolation())
            {
                throw ZoneAlreadyExists();
            }
        }

        return await ToResponseAsync(zone, cancellationToken);
    }

    private async Task<Zone> LoadAsync(Guid siteId, Guid zoneId, CancellationToken cancellationToken)
        => await zones.FirstOrDefaultAsync(new ZoneBySiteAndIdSpecification(siteId, zoneId), cancellationToken) ?? throw new NotFoundException();

    private async Task EnsureSiteWritableAsync(Guid siteId, CancellationToken cancellationToken)
    {
        var site = await sites.GetByIdAsync(siteId, cancellationToken) ?? throw new NotFoundException();
        site.EnsureWritable();
    }

    private Task EnsurePositionFreeAsync(Zone zone, Guid? exceptZoneId, CancellationToken cancellationToken)
        => EnsurePositionFreeAsync(zone.SiteId, new ZoneInput(zone.Block, zone.Elevation, zone.RoomType, zone.RoomNumber, zone.RoomLabel), exceptZoneId, cancellationToken);

    private async Task EnsurePositionFreeAsync(Guid siteId, ZoneInput input, Guid? exceptZoneId, CancellationToken cancellationToken)
    {
        if (await IsPositionTakenAsync(siteId, input.Block, input.Elevation, input.RoomType, input.RoomNumber, input.RoomLabel, exceptZoneId, cancellationToken))
        {
            throw ZoneAlreadyExists();
        }
    }

    private Task<bool> IsPositionTakenAsync(Guid siteId, string block, decimal? elevation, RoomType? roomType, int? roomNumber, string? roomLabel, Guid? exceptZoneId, CancellationToken cancellationToken)
        => zones.AnyAsync(new ZoneByPositionSpecification(siteId, block, elevation, roomType, roomNumber, roomLabel, exceptZoneId), cancellationToken);

    /// <summary>
    /// Une creation a rencontre une zone identique. Si c'est la meme saisie renvoyee en parallele (meme <c>clientId</c>),
    /// c'est un renvoi : on rend la zone deja creee. Sinon la position est prise par une autre saisie : <c>ZONE_EXISTANTE</c>.
    /// </summary>
    private async Task<ZoneCreationResult> ResolveRaceAsync(Guid siteId, Guid? clientId, CancellationToken cancellationToken)
    {
        if (clientId is { } id
            && await zones.FirstOrDefaultAsync(new ZoneByClientIdSpecification(siteId, id), cancellationToken) is { } existing)
        {
            return new ZoneCreationResult(await ToResponseAsync(existing, cancellationToken), Created: false);
        }

        throw ZoneAlreadyExists();
    }

    private async Task EnsureVersionAsync(Zone zone, string version, CancellationToken cancellationToken)
    {
        if (!BasicEntity.TryParseVersion(version, out var parsed))
        {
            throw new Core.Exceptions.ValidationException("version", "La version est invalide.");
        }

        if (parsed != zone.RowVersion)
        {
            throw new ConflictException(await ToResponseAsync(zone, cancellationToken));
        }
    }

    private static DomainRuleException ZoneAlreadyExists()
        => new(ErrorCodes.ZoneExistante, "Une zone identique existe déjà sur ce chantier.");

    private async Task<ZoneResponse> ToResponseAsync(Zone zone, CancellationToken cancellationToken)
        => (await ToResponsesAsync([zone], cancellationToken))[0];

    private async Task<List<ZoneResponse>> ToResponsesAsync(IReadOnlyCollection<Zone> rows, CancellationToken cancellationToken)
    {
        var names = await directory.GetNamesAsync(rows.SelectMany(ZoneResponse.AuditUsers), cancellationToken);
        return rows.Select(zone => ZoneResponse.From(zone, names)).ToList();
    }

    private static string EncodeCursor(int skip)
        => Base64Url.EncodeToString(Encoding.UTF8.GetBytes("o:" + skip.ToString(CultureInfo.InvariantCulture)));

    private static int DecodeCursor(string? cursor)
    {
        if (string.IsNullOrWhiteSpace(cursor))
        {
            return 0;
        }

        try
        {
            var text = Encoding.UTF8.GetString(Base64Url.DecodeFromChars(cursor));
            if (text.StartsWith("o:", StringComparison.Ordinal)
                && int.TryParse(text.AsSpan(2), NumberStyles.None, CultureInfo.InvariantCulture, out var skip))
            {
                return skip;
            }
        }
        catch (FormatException)
        {
            // Curseur illisible : traite plus bas.
        }

        throw new Core.Exceptions.ValidationException("cursor", "Le curseur est illisible.", ErrorCodes.CurseurInvalide);
    }
}
