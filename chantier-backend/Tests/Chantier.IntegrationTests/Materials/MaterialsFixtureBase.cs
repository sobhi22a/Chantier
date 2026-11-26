using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.SitesTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>
/// Socle des tests des demandes : un hote, une session par role (jetons valables pour toute la classe), un chantier ou tous les roles sont affectes
/// (l'Admin voit tous les chantiers), un ciment (sac, T, kg), un rond a beton (T, kg) et une zone.
/// </summary>
public abstract class MaterialsFixtureBase
{
    private string _database = string.Empty;

    protected ChantierWebApplicationFactory Factory { get; private set; } = null!;

    protected ApiSession Admin { get; private set; } = null!;

    protected ApiSession Direction { get; private set; } = null!;

    protected ApiSession Conducteur { get; private set; } = null!;

    protected ApiSession Achats { get; private set; } = null!;

    protected ApiSession Chef { get; private set; } = null!;

    protected ApiSession Equipe { get; private set; } = null!;

    protected SeededSite Site { get; private set; } = null!;

    protected JsonElement Cement { get; private set; }

    protected Guid CementId => Cement.Id();

    protected Guid SteelId { get; private set; }

    protected Guid ZoneId { get; private set; }

    protected IEnumerable<ApiSession> AllSessions => [Admin, Direction, Conducteur, Achats, Chef, Equipe];

    [OneTimeSetUp]
    public async Task CreateFixture()
    {
        // Base propre a la classe : le catalogue est global, ses produits et fournisseurs apparaitraient dans toutes les synchronisations de la base partagee.
        _database = await SqlServerFixture.CreateDatabaseAsync("materials");
        Factory = new ChantierWebApplicationFactory();
        Factory.Settings["ConnectionStrings:ChantierDb"] = _database;
        Admin = await Factory.SignInAsync(RoleNames.Admin);
        Direction = await Factory.SignInAsync(RoleNames.Direction);
        Conducteur = await Factory.SignInAsync(RoleNames.ConducteurTravaux);
        Achats = await Factory.SignInAsync(RoleNames.Achats);
        Chef = await Factory.SignInAsync(RoleNames.ChefChantier);
        Equipe = await Factory.SignInAsync(RoleNames.ChefEquipe);

        Site = await NewSiteAsync();
        Cement = await Admin.CreateProductAsync();
        SteelId = (await Admin.CreateSteelAsync()).Id();
        ZoneId = await Factory.SeedZoneAsync(Site.Id);
    }

    [OneTimeTearDown]
    public async Task DisposeFixture()
    {
        Factory.Dispose();
        await SqlServerFixture.DropDatabaseAsync(_database);
    }

    /// <summary>Chantier neuf ou tous les roles (sauf l'Admin, qui voit tout) sont affectes.</summary>
    protected Task<SeededSite> NewSiteAsync(bool archived = false)
        => Factory.SeedSiteAsync(
            archived: archived,
            members: [Direction.Account.Id, Conducteur.Account.Id, Achats.Account.Id, Chef.Account.Id, Equipe.Account.Id]);

    protected static async Task<string> CodeOf(HttpResponseMessage response) => (await response.JsonAsync()).GetProperty("code").GetString()!;
}
