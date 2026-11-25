using System.Net;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.SitesTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Sync;

/// <summary>
/// Affecter « touche » le chantier et ses lignes dans une transaction. Ces tests verifient qu'elle ne s'interbloque ni avec des
/// affectations simultanees, ni avec des creations de zones, ni avec des retraits, et qu'aucune ligne n'est perdue.
/// </summary>
[TestFixture]
public class SyncConcurrencyTests
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
    public async Task Assignments_and_zone_creations_at_the_same_time_never_deadlock_and_every_newcomer_gets_every_zone()
    {
        var lead = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync(members: lead.Account.Id);
        for (var index = 0; index < 5; index++)
        {
            await _factory.SeedZoneAsync(site.Id, $"Ancien {index}");
        }

        var newcomers = new List<ApiSession>();
        for (var index = 0; index < 6; index++)
        {
            newcomers.Add(await _factory.SignInAsync(RoleNames.ChefEquipe));
        }

        var assignments = newcomers.Select(newcomer => Task.Run(() => _admin.PutAsync($"{SiteBase}/{site.Id}/members/{newcomer.Account.Id}")));
        var creations = Enumerable.Range(0, 10).Select(index => Task.Run(() => lead.PostAsync($"{SiteBase}/{site.Id}/zones", ZoneBody($"Nouveau {index}"))));
        var responses = await Task.WhenAll(assignments.Concat(creations));

        Assert.That(
            responses.Select(response => (int)response.StatusCode),
            Has.All.LessThan(500),
            "Aucun interblocage (500) entre affectation et création de zone. " + string.Join(" | ", _factory.Logs.Entries.Where(entry => entry.StartsWith("[Error] Chantier", StringComparison.Ordinal)).Take(2).Select(entry => entry.Length > 1100 ? entry[..1100] : entry)));
        Assert.That(responses.Count(response => response.StatusCode == HttpStatusCode.Created), Is.EqualTo(16));

        foreach (var newcomer in newcomers)
        {
            var (changes, _, _) = await newcomer.PullAllAsync();
            Assert.That(changes.Of("zone"), Has.Exactly(15).Items, "5 anciennes + 10 nouvelles zones, sans perte ni doublon.");
        }
    }

    [Test]
    public async Task Assigning_and_removing_the_same_people_at_the_same_time_is_always_consistent()
    {
        var site = await _factory.SeedSiteAsync();
        await _factory.SeedZoneAsync(site.Id, "Bloc 01");
        var people = new List<ApiSession>();
        for (var index = 0; index < 4; index++)
        {
            people.Add(await _factory.SignInAsync(RoleNames.ChefEquipe));
        }

        var work = people.SelectMany(person => new[]
        {
            Task.Run(() => _admin.PutAsync($"{SiteBase}/{site.Id}/members/{person.Account.Id}")),
            Task.Run(() => _admin.DeleteAsync($"{SiteBase}/{site.Id}/members/{person.Account.Id}")),
            Task.Run(() => _admin.PutAsync($"{SiteBase}/{site.Id}/members/{person.Account.Id}")),
        });
        var responses = await Task.WhenAll(work);

        Assert.That(responses.Select(response => (int)response.StatusCode), Has.All.LessThan(500), string.Join(" | ", _factory.Logs.Entries.Where(entry => entry.StartsWith("[Error] Chantier", StringComparison.Ordinal)).Take(2).Select(entry => entry.Length > 900 ? entry[..900] : entry)));

        // Etat final coherent : une personne affectee voit le chantier, une personne non affectee ne le voit pas, sans doublon d'affectation.
        var members = await (await _admin.GetAsync($"{SiteBase}/{site.Id}/members")).JsonAsync();
        var assigned = members.GetProperty("items").EnumerateArray().Select(item => item.GetProperty("userId").GetGuid()).ToList();
        Assert.That(assigned, Is.Unique);
        foreach (var person in people)
        {
            var visible = (await person.GetAsync($"{SiteBase}/{site.Id}")).StatusCode == HttpStatusCode.OK;
            Assert.That(visible, Is.EqualTo(assigned.Contains(person.Account.Id)), "Accès = affectation, immédiatement.");
        }
    }
}
