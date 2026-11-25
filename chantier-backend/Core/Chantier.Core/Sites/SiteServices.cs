using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Paging;

namespace Chantier.Core.Sites;

/// <summary>Filtres de la liste « Mes chantiers » (back-office : pagination par page avec total).</summary>
public sealed record SiteListQuery(
    string? Search,
    SiteType? Type,
    string? Wilaya,
    bool IncludeArchived,
    string? Sort,
    int Page,
    int PageSize);

public sealed record ZoneListQuery(string? Block, string? Search, bool IncludeArchived, int PageSize, string? Cursor);

/// <summary>
/// Controle d'affectation (OWASP API1) : un utilisateur non affecte recoit <b>exactement</b> la meme <c>NotFoundException</c>
/// que pour un chantier inexistant. Appele par le filtre <c>[SiteScoped]</c> avant la liaison du corps de la requete.
/// </summary>
public interface ISiteAccess
{
    /// <summary>Verifie que le chantier existe ET est visible (affecte, ou permission <c>AllSites.View</c>). Aucun cache : le retrait coupe l'acces tout de suite.</summary>
    Task EnsureAsync(Guid siteId, CancellationToken cancellationToken = default);
}

public interface ISiteService
{
    Task<PagedResult<SiteResponse>> ListAsync(SiteListQuery query, CancellationToken cancellationToken = default);

    Task<SiteResponse> GetAsync(Guid siteId, CancellationToken cancellationToken = default);

    Task<SiteCodeSuggestion> SuggestCodeAsync(SiteType type, string name, CancellationToken cancellationToken = default);

    Task<SiteResponse> CreateAsync(CreateSiteDto dto, CancellationToken cancellationToken = default);

    Task<SiteResponse> UpdateAsync(Guid siteId, UpdateSiteDto dto, CancellationToken cancellationToken = default);

    Task<SiteResponse> ArchiveAsync(Guid siteId, CancellationToken cancellationToken = default);

    Task<SiteResponse> RestoreAsync(Guid siteId, CancellationToken cancellationToken = default);
}

public interface IZoneService
{
    Task<CursorPage<ZoneResponse>> ListAsync(Guid siteId, ZoneListQuery query, CancellationToken cancellationToken = default);

    Task<ZoneResponse> GetAsync(Guid siteId, Guid zoneId, CancellationToken cancellationToken = default);

    /// <summary>Creation idempotente par (<c>siteId</c>, <c>clientId</c>) ; <c>ZONE_EXISTANTE</c> si la meme position existe deja.</summary>
    Task<ZoneCreationResult> CreateAsync(Guid siteId, CreateZoneDto dto, CancellationToken cancellationToken = default);

    Task<ZoneResponse> UpdateAsync(Guid siteId, Guid zoneId, UpdateZoneDto dto, CancellationToken cancellationToken = default);

    Task<ZoneResponse> ArchiveAsync(Guid siteId, Guid zoneId, CancellationToken cancellationToken = default);

    Task<ZoneResponse> RestoreAsync(Guid siteId, Guid zoneId, CancellationToken cancellationToken = default);
}

public interface ISiteMemberService
{
    Task<IReadOnlyList<SiteMemberResponse>> ListAsync(Guid siteId, CancellationToken cancellationToken = default);

    Task<AssignmentResult> AssignAsync(Guid siteId, Guid userId, CancellationToken cancellationToken = default);

    /// <summary>Retire une affectation (suppression logique tracee) ; sans effet si la personne n'est pas affectee.</summary>
    Task RemoveAsync(Guid siteId, Guid userId, CancellationToken cancellationToken = default);
}

public interface IReferenceService
{
    Task<IReadOnlyList<WilayaResponse>> GetWilayasAsync(CancellationToken cancellationToken = default);

    /// <summary>Communes d'une wilaya ; <c>NotFoundException</c> si le code est inconnu.</summary>
    Task<IReadOnlyList<CommuneResponse>> GetCommunesAsync(string wilayaCode, CancellationToken cancellationToken = default);
}

/// <summary>Noms (et roles) des utilisateurs pour l'audit « cree par / modifie par » et la liste des personnes affectees.</summary>
public interface IUserDirectory
{
    Task<IReadOnlyDictionary<Guid, string>> GetNamesAsync(IEnumerable<Guid> userIds, CancellationToken cancellationToken = default);

    Task<IReadOnlyDictionary<Guid, (string FullName, string Role)>> GetNamesAndRolesAsync(IEnumerable<Guid> userIds, CancellationToken cancellationToken = default);

    /// <summary>Etat d'un compte a affecter : <c>null</c> s'il n'existe pas.</summary>
    Task<bool?> IsActiveAsync(Guid userId, CancellationToken cancellationToken = default);
}
