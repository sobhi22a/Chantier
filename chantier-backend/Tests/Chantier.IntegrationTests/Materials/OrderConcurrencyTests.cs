using System.Net;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>
/// R2-01 : commandes simultanees sur des demandes DIFFERENTES, sur une base neuve (la table des commandes est presque vide : c'est la que le plan d'execution
/// balayait l'index cluster et que deux transactions s'interbloquaient, SQL 1205 devenu une erreur 500). La classe a sa propre base : ne rien y ajouter qui
/// remplisse la table des commandes avant ce test.
/// </summary>
[TestFixture]
public class OrderConcurrencyTests : DeliveryFixtureBase
{
    private const int Workers = 8;
    private const int Rounds = 6;

    [Test]
    public async Task Eight_purchasers_ordering_different_requests_at_once_on_a_new_database_never_get_a_server_error()
    {
        var ids = new List<Guid>();
        for (var index = 0; index < Workers * Rounds; index++)
        {
            ids.Add(await ValidatedAsync(100m));
        }

        var statuses = new List<HttpStatusCode>();
        foreach (var round in ids.Chunk(Workers))
        {
            var responses = await Task.WhenAll(round.Select(id => Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId))));
            statuses.AddRange(responses.Select(response => response.StatusCode));
        }

        Assert.Multiple(() =>
        {
            Assert.That(statuses, Has.Count.EqualTo(Workers * Rounds));
            Assert.That(statuses.Count(status => status == HttpStatusCode.Created), Is.EqualTo(Workers * Rounds), "toutes les commandes sont creees");
            Assert.That(statuses, Does.Not.Contain(HttpStatusCode.InternalServerError), "aucun interblocage (1205) ne remonte en erreur 500");
        });

        var ordered = 0;
        foreach (var id in ids)
        {
            ordered += (await ReadRequestAsync(id)).StatusOf() == "Ordered" ? 1 : 0;
        }

        Assert.That(ordered, Is.EqualTo(Workers * Rounds), "chaque demande est commandee une seule fois");
    }
}
