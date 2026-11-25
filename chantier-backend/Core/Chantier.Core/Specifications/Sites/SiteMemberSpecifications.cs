using Ardalis.Specification;
using Chantier.Core.Entities.Sites;

namespace Chantier.Core.Specifications.Sites;

public sealed class SiteMembersBySiteSpecification : Specification<SiteMember>
{
    public SiteMembersBySiteSpecification(Guid siteId)
    {
        Query.Where(member => member.SiteId == siteId).OrderBy(member => member.CreatedAt).ThenBy(member => member.Id);
    }
}

/// <summary>Affectation active d'un utilisateur a un chantier (les retraits sont des suppressions logiques, masquees par le filtre).</summary>
public sealed class SiteMemberByUserSpecification : Specification<SiteMember>, ISingleResultSpecification<SiteMember>
{
    public SiteMemberByUserSpecification(Guid siteId, Guid userId)
    {
        Query.Where(member => member.SiteId == siteId && member.UserId == userId);
    }
}
