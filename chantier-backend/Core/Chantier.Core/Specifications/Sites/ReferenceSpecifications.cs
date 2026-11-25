using Ardalis.Specification;
using Chantier.Core.Entities.Reference;
using Chantier.Core.Entities.Sites;

namespace Chantier.Core.Specifications.Sites;

public sealed class WilayasOrderedSpecification : Specification<Wilaya>
{
    public WilayasOrderedSpecification()
    {
        Query.OrderBy(wilaya => wilaya.Code);
    }
}

public sealed class WilayaByCodeSpecification : Specification<Wilaya>, ISingleResultSpecification<Wilaya>
{
    public WilayaByCodeSpecification(string code)
    {
        Query.Where(wilaya => wilaya.Code == code);
    }
}

public sealed class CommunesByWilayaSpecification : Specification<Commune>
{
    public CommunesByWilayaSpecification(string wilayaCode)
    {
        Query.Where(commune => commune.WilayaCode == wilayaCode).OrderBy(commune => commune.NameFr);
    }
}

/// <summary>Codes deja utilises qui commencent par un prefixe (suggestion d'un code libre).</summary>
public sealed class SiteCodesStartingWithSpecification : Specification<Site>
{
    public SiteCodesStartingWithSpecification(string prefix)
    {
        Query.Where(site => site.Code.StartsWith(prefix));
    }
}
