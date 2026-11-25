using Chantier.Core.Entities.Common;

namespace Chantier.Core.Entities.Sites;

/// <summary>
/// Affectation d'un utilisateur a un chantier (une seule ligne active par couple). Le retrait est une suppression
/// logique tracee (qui, quand) : l'acces est coupe immediatement car chaque requete verifie l'affectation (CA-005.4).
/// </summary>
public class SiteMember : BasicEntity, ISiteScoped
{
    // EF Core
    private SiteMember()
    {
    }

    public Guid SiteId { get; private set; }

    public Guid UserId { get; private set; }

    public static SiteMember Create(Guid siteId, Guid userId) => new() { SiteId = siteId, UserId = userId };
}
