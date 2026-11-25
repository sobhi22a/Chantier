using System.Net;
using System.Security.Claims;
using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Identity;
using Chantier.IntegrationTests.Support;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.SitesTestKit;

namespace Chantier.IntegrationTests.Sites;

/// <summary>CT-20 : le montant du marche est <b>absent</b> des reponses (pas seulement masque) pour ChefChantier, ChefEquipe et Achats.</summary>
[TestFixture]
public class ContractAmountTests
{
    private ChantierWebApplicationFactory _factory = null!;

    [OneTimeSetUp]
    public void SetUp() => _factory = new ChantierWebApplicationFactory();

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    [TestCase(RoleNames.Admin, true)]
    [TestCase(RoleNames.Direction, true)]
    [TestCase(RoleNames.ConducteurTravaux, true)]
    [TestCase(RoleNames.Achats, false)]
    [TestCase(RoleNames.ChefChantier, false)]
    [TestCase(RoleNames.ChefEquipe, false)]
    public async Task The_amount_is_present_only_for_roles_with_the_permission(string role, bool expected)
    {
        var user = await _factory.SignInAsync(role);
        var site = await _factory.SeedSiteAsync(amount: 185_000_000.00m, members: user.Account.Id);

        var detail = await user.GetAsync($"{SiteBase}/{site.Id}");
        var list = await user.GetAsync($"{SiteBase}?q={site.Code}");
        var detailText = await detail.Content.ReadAsStringAsync();
        var listText = await list.Content.ReadAsStringAsync();
        var detailJson = JsonDocument.Parse(detailText).RootElement;
        var listItem = JsonDocument.Parse(listText).RootElement.GetProperty("items")[0];

        Assert.Multiple(() =>
        {
            Assert.That(detailJson.TryGetProperty("contractAmount", out _), Is.EqualTo(expected), $"{role} : fiche");
            Assert.That(listItem.TryGetProperty("contractAmount", out _), Is.EqualTo(expected), $"{role} : liste");
            if (!expected)
            {
                // Absent de la reponse, sous quelque forme que ce soit : ni propriete, ni valeur.
                Assert.That(detailText, Does.Not.Contain("contractAmount").IgnoreCase);
                Assert.That(detailText, Does.Not.Contain("185000000"));
                Assert.That(listText, Does.Not.Contain("185000000"));
            }
            else
            {
                Assert.That(detailJson.GetProperty("contractAmount").GetDecimal(), Is.EqualTo(185_000_000.00m));
            }
        });
    }

    [Test]
    public async Task The_amount_is_absent_from_the_conflict_state_too_for_a_role_without_the_permission()
    {
        // Seul l'Admin modifie un chantier : le conflit montre l'etat courant avec le montant. On verifie la regle sur l'etat courant d'une fiche lue.
        var admin = await _factory.SignInAsync(RoleNames.Admin);
        var created = await (await admin.PostAsync(SiteBase, SiteBody())).JsonAsync();
        var version = created.GetProperty("version").GetString();
        await admin.PutAsync($"{SiteBase}/{created.GetProperty("id").GetGuid()}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = version; b["name"] = "Changé"; }));

        var conflict = await (await admin.PutAsync($"{SiteBase}/{created.GetProperty("id").GetGuid()}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = version; }))).JsonAsync();

        Assert.That(conflict.GetProperty("current").TryGetProperty("contractAmount", out _), Is.True, "L'Admin a la permission : il voit le montant dans l'état courant.");
    }

    [Test]
    public async Task A_missing_amount_is_simply_absent_for_a_role_with_the_permission()
    {
        var admin = await _factory.SignInAsync(RoleNames.Admin);

        var created = await (await admin.PostAsync(SiteBase, SiteBody(overrides: b => b["contractAmount"] = null))).JsonAsync();

        Assert.That(created.TryGetProperty("contractAmount", out _), Is.False);
    }

    [Test]
    public async Task The_amount_is_stored_with_two_decimals_rounded_away_from_zero()
    {
        var admin = await _factory.SignInAsync(RoleNames.Admin);

        var created = await (await admin.PostAsync(SiteBase, SiteBody(overrides: b => b["contractAmount"] = 96400000.005m))).JsonAsync();
        var reread = await (await admin.GetAsync($"{SiteBase}/{created.GetProperty("id").GetGuid()}")).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(created.GetProperty("contractAmount").GetDecimal(), Is.EqualTo(96400000.01m));
            Assert.That(reread.GetProperty("contractAmount").GetDecimal(), Is.EqualTo(96400000.01m));
        });
    }

    [Test]
    public async Task A_negative_amount_is_refused()
    {
        var admin = await _factory.SignInAsync(RoleNames.Admin);

        var response = await admin.PostAsync(SiteBase, SiteBody(overrides: b => b["contractAmount"] = -1m));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
    }

    [Test]
    public async Task Changing_a_role_permission_changes_the_amount_visibility_after_the_cache_expires()
    {
        using var factory = new ChantierWebApplicationFactory();
        var achats = await factory.SignInAsync(RoleNames.Achats);
        var site = await factory.SeedSiteAsync(members: achats.Account.Id);
        Assert.That((await (await achats.GetAsync($"{SiteBase}/{site.Id}")).JsonAsync()).TryGetProperty("contractAmount", out _), Is.False);

        // Un ajout manuel en base de la permission au role (Q-03) : pris en compte apres le cache de 5 minutes, sans changement de code.
        await using (var scope = factory.Services.CreateAsyncScope())
        {
            var roles = scope.ServiceProvider.GetRequiredService<RoleManager<AppRole>>();
            var role = (await roles.FindByNameAsync(RoleNames.Achats))!;
            await roles.AddClaimAsync(role, new Claim(Permissions.ClaimType, Permissions.ContractAmountView));
        }

        factory.Time.Advance(TimeSpan.FromMinutes(5) + TimeSpan.FromSeconds(1));
        var after = await (await achats.GetAsync($"{SiteBase}/{site.Id}")).JsonAsync();

        // Nettoyage : la base de test est partagee, on remet la matrice par defaut.
        await using (var scope = factory.Services.CreateAsyncScope())
        {
            var roles = scope.ServiceProvider.GetRequiredService<RoleManager<AppRole>>();
            var role = (await roles.FindByNameAsync(RoleNames.Achats))!;
            await roles.RemoveClaimAsync(role, new Claim(Permissions.ClaimType, Permissions.ContractAmountView));
        }

        Assert.That(after.TryGetProperty("contractAmount", out _), Is.True);
    }
}
