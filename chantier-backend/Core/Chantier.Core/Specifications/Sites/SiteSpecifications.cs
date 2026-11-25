using Ardalis.Specification;
using Chantier.Core.Entities.Sites;

namespace Chantier.Core.Specifications.Sites;

/// <summary>
/// Chantiers visibles par l'utilisateur : ceux auxquels il est affecte (affectation active), ou tous si <c>seeAll</c>
/// (permission <c>AllSites.View</c>, Admin seul, H-02). Un chantier non affecte n'apparait jamais, pas meme dans la recherche (CT-3).
/// Tri (<c>name</c>, <c>-name</c>, <c>code</c>, <c>-code</c>, <c>createdAt</c>, <c>-createdAt</c>) et pagination ne servent que
/// pour <c>ListAsync</c> : <c>CountAsync</c> n'evalue que les criteres.
/// </summary>
public sealed class SitesVisibleToUserSpecification : Specification<Site>
{
    public static readonly string[] SortValues = ["name", "-name", "code", "-code", "createdAt", "-createdAt"];

    public SitesVisibleToUserSpecification(
        Guid userId,
        bool seeAll,
        string? search,
        SiteType? type,
        string? wilaya,
        bool includeArchived,
        string sort = "name",
        int page = 1,
        int pageSize = 50)
    {
        if (!seeAll)
        {
            Query.Where(site => site.Members.Any(member => member.UserId == userId));
        }

        if (!includeArchived)
        {
            Query.Where(site => site.ArchivedAt == null);
        }

        if (type is { } siteType)
        {
            Query.Where(site => site.Type == siteType);
        }

        if (!string.IsNullOrWhiteSpace(wilaya))
        {
            var wilayaName = wilaya.Trim();
            Query.Where(site => site.Wilaya == wilayaName);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var text = search.Trim();
            Query.Where(site => site.Code.Contains(text) || site.Name.Contains(text) || (site.NameAr != null && site.NameAr.Contains(text)));
        }

        switch (sort)
        {
            case "-name":
                Query.OrderByDescending(site => site.Name).ThenBy(site => site.Code);
                break;
            case "code":
                Query.OrderBy(site => site.Code);
                break;
            case "-code":
                Query.OrderByDescending(site => site.Code);
                break;
            case "createdAt":
                Query.OrderBy(site => site.CreatedAt).ThenBy(site => site.Code);
                break;
            case "-createdAt":
                Query.OrderByDescending(site => site.CreatedAt).ThenBy(site => site.Code);
                break;
            default:
                Query.OrderBy(site => site.Name).ThenBy(site => site.Code);
                break;
        }

        Query.Skip((page - 1) * pageSize).Take(pageSize);
    }
}

/// <summary>Un chantier precis, seulement s'il est visible par l'utilisateur (meme regle que la liste).</summary>
public sealed class SiteVisibleToUserByIdSpecification : Specification<Site>, ISingleResultSpecification<Site>
{
    public SiteVisibleToUserByIdSpecification(Guid siteId, Guid userId, bool seeAll)
    {
        Query.Where(site => site.Id == siteId);
        if (!seeAll)
        {
            Query.Where(site => site.Members.Any(member => member.UserId == userId));
        }
    }
}

/// <summary>Chantier par code (archives compris), pour l'unicite du code et sa suggestion.</summary>
public sealed class SiteByCodeSpecification : Specification<Site>, ISingleResultSpecification<Site>
{
    public SiteByCodeSpecification(string code)
    {
        Query.Where(site => site.Code == code);
    }
}
