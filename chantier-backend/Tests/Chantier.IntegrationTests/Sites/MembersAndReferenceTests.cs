using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;
using static Chantier.IntegrationTests.Support.SitesTestKit;

namespace Chantier.IntegrationTests.Sites;

/// <summary>Affectations (Admin, immediates, tracees, sans telephone) et referentiel geographique.</summary>
[TestFixture]
public class MembersAndReferenceTests
{
    private ChantierWebApplicationFactory _factory = null!;
    private ApiSession _admin = null!;

    [OneTimeSetUp]
    public async Task SetUp()
    {
        _factory = new ChantierWebApplicationFactory();
        _admin = await _factory.SignInAsync(RoleNames.Admin);
    }

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    [Test]
    public async Task Assign_gives_201_then_200_and_only_one_assignment_remains()
    {
        var site = await _factory.SeedSiteAsync();
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var url = $"{SiteBase}/{site.Id}/members/{chef.Account.Id}";

        var first = await _admin.PutAsync(url);
        var again = await _admin.PutAsync(url);
        var list = await (await _admin.GetAsync($"{SiteBase}/{site.Id}/members")).JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK), "« Déjà affecté »");
            Assert.That((await again.JsonAsync()).GetProperty("userId").GetGuid(), Is.EqualTo(chef.Account.Id));
            Assert.That(list.GetProperty("items").GetArrayLength(), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task Parallel_double_press_leaves_a_single_assignment()
    {
        var site = await _factory.SeedSiteAsync();
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var url = $"{SiteBase}/{site.Id}/members/{chef.Account.Id}";

        var responses = await Task.WhenAll(Enumerable.Range(0, 6).Select(_ => _admin.PutAsync(url)));
        var list = await (await _admin.GetAsync($"{SiteBase}/{site.Id}/members")).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(responses.Count(r => r.StatusCode == HttpStatusCode.Created), Is.EqualTo(1));
            Assert.That(responses.Count(r => r.StatusCode == HttpStatusCode.OK), Is.EqualTo(5));
            Assert.That(list.GetProperty("items").GetArrayLength(), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task Assigning_a_deactivated_account_is_422_COMPTE_DESACTIVE()
    {
        var site = await _factory.SeedSiteAsync();
        var inactive = await _factory.CreateUserAsync(isActive: false);

        var response = await _admin.PutAsync($"{SiteBase}/{site.Id}/members/{inactive.Id}");

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo((HttpStatusCode)422));
            Assert.That((await response.JsonAsync()).GetProperty("code").GetString(), Is.EqualTo("COMPTE_DESACTIVE"));
            Assert.That((await response.Content.ReadAsStringAsync()), Does.Not.Contain(inactive.UserName).And.Not.Contain(inactive.FullName));
        });
    }

    [Test]
    public async Task Assigning_an_unknown_user_is_404()
    {
        var site = await _factory.SeedSiteAsync();

        var response = await _admin.PutAsync($"{SiteBase}/{site.Id}/members/{Guid.NewGuid()}");

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
    }

    [Test]
    public async Task Members_list_has_names_and_roles_but_never_phone_or_login()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var conducteur = await _factory.SignInAsync(RoleNames.ConducteurTravaux);
        var site = await _factory.SeedSiteAsync(members: [chef.Account.Id, conducteur.Account.Id]);

        // Visible par un simple membre (SiteMembers.View) : meme contenu, jamais de donnee personnelle.
        var response = await chef.GetAsync($"{SiteBase}/{site.Id}/members");
        var text = await response.Content.ReadAsStringAsync();
        var items = JsonDocument.Parse(text).RootElement.GetProperty("items");

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(items.GetArrayLength(), Is.EqualTo(2));
            Assert.That(items.Strings("fullName"), Is.EquivalentTo(new[] { chef.Account.FullName, conducteur.Account.FullName }));
            Assert.That(items.Strings("role"), Is.EquivalentTo(new[] { RoleNames.ChefChantier, RoleNames.ConducteurTravaux }));
            Assert.That(text, Does.Not.Contain(chef.Account.Phone).And.Not.Contain(conducteur.Account.Phone), "Aucun téléphone (H-17, CT-14).");
            Assert.That(text, Does.Not.Contain(chef.Account.UserName).And.Not.Contain(conducteur.Account.UserName), "Aucun identifiant de connexion.");
            Assert.That(items[0].EnumerateObject().Select(p => p.Name), Is.EquivalentTo(new[] { "userId", "fullName", "role", "assignedAt" }));
        });
    }

    [Test]
    public async Task Remove_is_idempotent_traced_and_a_new_assignment_is_possible_afterwards()
    {
        var site = await _factory.SeedSiteAsync();
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var url = $"{SiteBase}/{site.Id}/members/{chef.Account.Id}";
        await _admin.PutAsync(url);

        var first = await _admin.DeleteAsync(url);
        var second = await _admin.DeleteAsync(url);
        var list = await (await _admin.GetAsync($"{SiteBase}/{site.Id}/members")).JsonAsync();
        var reassigned = await _admin.PutAsync(url);

        Assert.Multiple(() =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(second.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(list.GetProperty("items").GetArrayLength(), Is.Zero);
            Assert.That(reassigned.StatusCode, Is.EqualTo(HttpStatusCode.Created));
        });
    }

    [Test]
    public async Task A_removal_is_a_logical_deletion_with_who_and_when()
    {
        using var factory = new ChantierWebApplicationFactory();
        var admin = await factory.SignInAsync(RoleNames.Admin);
        var chef = await factory.SignInAsync(RoleNames.ChefChantier);
        var site = await factory.SeedSiteAsync();
        await admin.PutAsync($"{SiteBase}/{site.Id}/members/{chef.Account.Id}");
        factory.Time.Advance(TimeSpan.FromMinutes(10));
        var removedAt = factory.Time.GetUtcNow();

        await admin.DeleteAsync($"{SiteBase}/{site.Id}/members/{chef.Account.Id}");

        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var row = await db.SiteMembers.IgnoreQueryFilters([QueryFilterNames.SoftDelete]).SingleAsync(
            member => member.SiteId == site.Id && member.UserId == chef.Account.Id);

        Assert.Multiple(() =>
        {
            Assert.That(row.DeletedBy, Is.EqualTo(admin.Account.Id));
            Assert.That(row.DeletedAt, Is.EqualTo(removedAt));
            Assert.That(row.CreatedBy, Is.EqualTo(admin.Account.Id));
        });
    }

    [TestCase(RoleNames.Direction)]
    [TestCase(RoleNames.ConducteurTravaux)]
    [TestCase(RoleNames.Achats)]
    [TestCase(RoleNames.ChefChantier)]
    [TestCase(RoleNames.ChefEquipe)]
    public async Task Only_admin_assigns_and_removes(string role)
    {
        var user = await _factory.SignInAsync(role);
        var other = await _factory.SignInAsync(RoleNames.ChefEquipe);
        var site = await _factory.SeedSiteAsync(members: user.Account.Id);

        var assign = await user.PutAsync($"{SiteBase}/{site.Id}/members/{other.Account.Id}");
        var remove = await user.DeleteAsync($"{SiteBase}/{site.Id}/members/{user.Account.Id}");
        var read = await user.GetAsync($"{SiteBase}/{site.Id}/members");

        Assert.Multiple(() =>
        {
            Assert.That(assign.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(remove.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(read.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    [Test]
    public async Task An_unassigned_user_cannot_even_list_the_members()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync();

        var response = await chef.GetAsync($"{SiteBase}/{site.Id}/members");

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
    }

    [Test]
    public async Task An_archived_site_can_still_be_assigned_by_the_admin()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync(archived: true);

        var response = await _admin.PutAsync($"{SiteBase}/{site.Id}/members/{chef.Account.Id}");

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
    }

    // --- Referentiel ---

    [Test]
    public async Task Wilayas_are_listed_from_the_data_file_with_french_and_arabic_names()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);

        var response = await chef.GetAsync("/api/v1/reference/wilayas");
        var json = await response.JsonAsync();
        var blida = json.EnumerateArray().Single(w => w.GetProperty("code").GetString() == "09");

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(json.GetArrayLength(), Is.EqualTo(58));
            Assert.That(blida.GetProperty("nameFr").GetString(), Is.EqualTo("Blida"));
            Assert.That(blida.GetProperty("nameAr").GetString(), Is.EqualTo("البليدة"));
            Assert.That(json.Strings("code"), Is.Ordered);
        });
    }

    [Test]
    public async Task Communes_of_a_wilaya_and_404_for_an_unknown_code()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);

        var ok = await chef.GetAsync("/api/v1/reference/wilayas/09/communes");
        var unknown = await chef.GetAsync("/api/v1/reference/wilayas/99/communes");
        var communes = (await ok.JsonAsync()).Strings("nameFr").ToList();

        Assert.Multiple(() =>
        {
            Assert.That(ok.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(communes, Does.Contain("Boufarik"));
            Assert.That(communes, Is.Ordered);
            Assert.That(unknown.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
        });
    }

    [Test]
    public async Task Reference_data_requires_authentication()
    {
        using var client = _factory.CreateClient();

        Assert.Multiple(async () =>
        {
            Assert.That((await client.GetAsync("/api/v1/reference/wilayas")).StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That((await client.GetAsync("/api/v1/reference/wilayas/09/communes")).StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }
}
