using System.Net;
using System.Text.Json;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>Socle des tests de commandes, livraisons, photos et suivi : un fournisseur, un sable (m3, t) et les enchainements demande validee puis commandee.</summary>
public abstract class DeliveryFixtureBase : MaterialsFixtureBase
{
    protected Guid SupplierId { get; private set; }

    protected Guid SandId { get; private set; }

    [OneTimeSetUp]
    public async Task CreateSupplierAndSand()
    {
        SupplierId = (await Admin.CreateSupplierAsync()).Id();
        SandId = (await Admin.CreateProductAsync(ProductBody(UniqueName("Sable"), ["m3", "t"], "m3", null, "Aggregates"))).Id();
    }

    /// <summary>Demande creee par le chef de chantier puis validee par le conducteur.</summary>
    protected async Task<Guid> ValidatedAsync(decimal value = 600m, string unit = "sac", Guid? siteId = null, Guid? productId = null)
    {
        var site = siteId ?? Site.Id;
        var id = await Chef.NewRequestIdAsync(site, productId ?? CementId, value, unit);
        var approved = await Conducteur.PostAsync($"{RequestUrl(site, id)}/approve");
        Assert.That(approved.StatusCode, Is.EqualTo(HttpStatusCode.OK), await approved.Content.ReadAsStringAsync());
        return id;
    }

    /// <summary>Demande validee puis commandee par les Achats (statut <c>Ordered</c>).</summary>
    protected async Task<Guid> OrderedRequestAsync(decimal value = 600m, string unit = "sac", decimal? price = 780m, Guid? productId = null, Guid? siteId = null, DateOnly? expected = null)
    {
        var site = siteId ?? Site.Id;
        var id = await ValidatedAsync(value, unit, site, productId);
        var response = await Achats.PostAsync(OrderUrl(site, id), OrderBody(SupplierId, price, orderDate: expected is { } planned && planned < Factory.Today() ? planned : null, expected: expected));
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created), await response.Content.ReadAsStringAsync());
        return id;
    }

    protected async Task<JsonElement> ReadRequestAsync(Guid requestId, ApiSession? session = null, Guid? siteId = null)
        => await (await (session ?? Conducteur).GetAsync(RequestUrl(siteId ?? Site.Id, requestId))).JsonAsync();

    /// <summary>Livraison enregistree par le chef de chantier (le fournisseur de la commande est repris si rien n'est precise).</summary>
    protected async Task<JsonElement> DeliverAsync(Guid? requestId, decimal value, string unit, Guid? siteId = null, Guid? productId = null, string? note = null, DateOnly? date = null, Action<Dictionary<string, object?>>? overrides = null)
        => await Chef.CreateDeliveryAsync(
            siteId ?? Site.Id,
            DeliveryBody(requestId, value, unit, date ?? Factory.Today(), SupplierId, productId, note, overrides: overrides));
}
