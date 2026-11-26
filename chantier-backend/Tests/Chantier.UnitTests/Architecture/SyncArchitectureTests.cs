using Chantier.Core.Entities.Common;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Sync;

namespace Chantier.UnitTests.Architecture;

/// <summary>ADR 0009 : toute entite d'un chantier doit etre inscrite dans le « toucher » de l'affectation et avoir une source de synchro.</summary>
[TestFixture]
public class SyncArchitectureTests
{
    [Test]
    public void Every_site_scoped_entity_is_touched_when_a_user_is_assigned()
    {
        var siteScoped = typeof(Site).Assembly.GetTypes()
            .Where(type => type is { IsAbstract: false, IsClass: true } && typeof(ISiteScoped).IsAssignableFrom(type))
            .ToList();

        Assert.That(siteScoped, Is.Not.Empty);
        Assert.That(SyncTouch.TouchedEntityTypes, Is.SupersetOf(siteScoped), "Ajouter l'entité à SyncTouch : sinon un nouvel affecté ne recevrait jamais ses lignes anciennes.");
    }

    [Test]
    public void Every_site_scoped_entity_has_a_sync_source_in_the_infrastructure()
    {
        // Une source par entite synchronisee ; une entite d'un chantier non synchronisee doit etre un choix explicite (liste d'exceptions vide au socle).
        var sources = typeof(SyncTouch).Assembly.GetTypes()
            .Where(type => type is { IsAbstract: false, IsClass: true } && typeof(ISyncSource).IsAssignableFrom(type))
            .Select(type => type.Name)
            .ToList();

        Assert.That(sources, Is.EquivalentTo(new[]
        {
            nameof(SiteSyncSource), nameof(ZoneSyncSource), nameof(MemberSyncSource),
            nameof(ProductSyncSource), nameof(SupplierSyncSource), nameof(RequestSyncSource), nameof(DeliverySyncSource), nameof(PhotoSyncSource),
        }));
    }
}
