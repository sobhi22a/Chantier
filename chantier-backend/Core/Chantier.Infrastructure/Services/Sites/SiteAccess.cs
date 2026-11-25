using Ardalis.Specification;
using Chantier.Core.Abstractions;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.Core.Sites;
using Chantier.Core.Specifications.Sites;

namespace Chantier.Infrastructure.Services.Sites;

/// <summary>
/// Le role decide de l'<b>action</b>, l'affectation decide du <b>perimetre</b> ; les deux sont verifiees a chaque requete, sans cache
/// pour l'affectation : un retrait coupe l'acces tout de suite (CA-005.4). Chantier inexistant et chantier non affecte donnent
/// la meme <see cref="NotFoundException"/> : meme statut, meme corps (CA-006.2).
/// </summary>
public sealed class SiteAccess(IRepositoryBase<Site> sites, ICurrentUser currentUser, IUserPermissions permissions) : ISiteAccess
{
    public async Task EnsureAsync(Guid siteId, CancellationToken cancellationToken = default)
    {
        if (currentUser.Id is not { } userId)
        {
            throw new NotFoundException();
        }

        var seeAll = await permissions.HasAsync(Permissions.AllSitesView, cancellationToken);
        if (!await sites.AnyAsync(new SiteVisibleToUserByIdSpecification(siteId, userId, seeAll), cancellationToken))
        {
            throw new NotFoundException();
        }
    }
}
