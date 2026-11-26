using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;
using Chantier.Infrastructure.Persistence;
using Chantier.Infrastructure.SeedData.Demo;
using Chantier.IntegrationTests.Support;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;
using static Chantier.IntegrationTests.Support.SitesTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Persistence;

/// <summary>US-MAT-016 : jeu de demonstration « demandes et livraisons » de l'Ecole UV18 : ecrit directement (auteur « amorcage »), relancable, jamais ecrase l'existant.</summary>
[TestFixture]
public class MaterialsDemoDataTests
{
    private readonly List<string> _databases = [];

    [OneTimeTearDown]
    public async Task DropDatabases()
    {
        foreach (var database in _databases)
        {
            await SqlServerFixture.DropDatabaseAsync(database);
        }
    }

    private async Task<ChantierWebApplicationFactory> StartAsync(bool demo = true)
    {
        var connection = await SqlServerFixture.CreateDatabaseAsync("demomat");
        _databases.Add(connection);

        var factory = new ChantierWebApplicationFactory { EnvironmentName = "Development" };
        factory.Settings["ConnectionStrings:ChantierDb"] = connection;
        if (demo)
        {
            factory.Settings[DemoDataSeeder.EnabledKey] = "true";
        }

        _ = factory.Server; // migration + amorcage + demonstration
        return factory;
    }

    private static async Task<ApiSession> SignInDemoAsync(ChantierWebApplicationFactory factory, string userName)
    {
        var account = DemoData.Accounts.Single(candidate => candidate.UserName == userName);
        var password = factory.Services.GetRequiredService<IConfiguration>()[DemoDataSeeder.PasswordKey]!;
        return await factory.SignInAsync(new TestAccount(Guid.Empty, userName, password, account.FullName, account.Phone, account.Role));
    }

    private static async Task<Guid> SiteIdAsync(ChantierWebApplicationFactory factory, string code)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        return await scope.ServiceProvider.GetRequiredService<ApplicationDbContext>().Sites.Where(site => site.Code == code).Select(site => site.Id).SingleAsync();
    }

    private static async Task<(int Products, int Suppliers, int Requests, int Orders, int Deliveries, int Photos, int Events)> CountsAsync(ChantierWebApplicationFactory factory)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        return (
            await db.Products.CountAsync(),
            await db.Suppliers.CountAsync(),
            await db.MaterialRequests.CountAsync(),
            await db.MaterialOrders.CountAsync(),
            await db.Deliveries.CountAsync(),
            await db.Photos.CountAsync(),
            await db.MaterialEvents.CountAsync());
    }

    [Test]
    public async Task CA_016_1_loading_creates_13_products_5_suppliers_12_requests_and_10_deliveries_on_the_school_and_1_request_on_the_housing()
    {
        using var factory = await StartAsync();
        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        var housing = await SiteIdAsync(factory, DemoData.HousingCode);
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var requests = await db.MaterialRequests.ToListAsync();
        var deliveries = await db.Deliveries.ToListAsync();
        Assert.Multiple(async () =>
        {
            Assert.That(await db.Products.CountAsync(), Is.EqualTo(13));
            Assert.That(await db.Suppliers.CountAsync(), Is.EqualTo(5));
            Assert.That(requests.Count(request => request.SiteId == school), Is.EqualTo(12));
            Assert.That(deliveries.Count(delivery => delivery.SiteId == school), Is.EqualTo(10));
            Assert.That(requests.Count(request => request.SiteId == housing), Is.EqualTo(1));
            Assert.That(deliveries.Count(delivery => delivery.SiteId == housing), Is.Zero);
            Assert.That(requests.Where(request => request.SiteId == school).Select(request => request.Number), Is.EquivalentTo(Enumerable.Range(1, 12).Select(n => $"DEM-{n:D3}")));
            Assert.That(deliveries.Where(delivery => delivery.SiteId == school).Select(delivery => delivery.Number), Is.EquivalentTo(Enumerable.Range(1, 10).Select(n => $"LIV-{n:D3}")));
            Assert.That(requests.Single(request => request.SiteId == housing).Number, Is.EqualTo("DEM-001"), "CA-016.4 d : DEM-001 existe sur les deux chantiers, sans conflit.");
        });
    }

    [Test]
    public async Task The_requests_follow_the_status_table_of_the_user_story()
    {
        using var factory = await StartAsync();
        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var byNumber = (await db.MaterialRequests.Where(request => request.SiteId == school).ToListAsync()).ToDictionary(request => request.Number);

        Assert.Multiple(() =>
        {
            foreach (var number in new[] { "DEM-001", "DEM-002", "DEM-003", "DEM-004" })
            {
                Assert.That(byNumber[number].Status, Is.EqualTo(RequestStatus.Received), number);
            }

            Assert.That(byNumber["DEM-005"].Status, Is.EqualTo(RequestStatus.Delivered), "CA-016.4 f : livrée, à réceptionner.");
            Assert.That(byNumber["DEM-006"].Status, Is.EqualTo(RequestStatus.Requested));
            Assert.That(byNumber["DEM-007"].Status, Is.EqualTo(RequestStatus.Validated));
            Assert.That(byNumber["DEM-008"].Status, Is.EqualTo(RequestStatus.Rejected));
            Assert.That(byNumber["DEM-008"].StatusReasonCode, Is.EqualTo("StockSufficient"));
            Assert.That(byNumber["DEM-009"].Status, Is.EqualTo(RequestStatus.Ordered));
            Assert.That(byNumber["DEM-009"].Priority, Is.EqualTo(Priority.Blocking));
            Assert.That(byNumber["DEM-010"].Status, Is.EqualTo(RequestStatus.Cancelled));
            Assert.That(byNumber["DEM-010"].StatusReasonCode, Is.EqualTo("EntryError"));
            Assert.That(byNumber["DEM-011"].Status, Is.EqualTo(RequestStatus.PartiallyDelivered), "CA-016.4 g");
            Assert.That(byNumber["DEM-011"].ReceivedQuantity, Is.EqualTo(1.2m));
            Assert.That(byNumber["DEM-011"].QuantityValue - byNumber["DEM-011"].ReceivedQuantity, Is.EqualTo(0.8m), "Reste 0,8 T.");
            Assert.That(byNumber["DEM-012"].Status, Is.EqualTo(RequestStatus.Requested));
            Assert.That(byNumber["DEM-012"].ZoneId, Is.Not.Null, "Façade cantine : zone sans cote retrouvée.");
            Assert.That(byNumber.Values.All(request => request.ZoneId is not null), Is.True, "Toutes les zones du tableau existent dans les 26 zones du socle.");
        });
    }

    [Test]
    public async Task CA_016_4_e_the_cement_delivered_to_the_school_is_110_t_which_is_2200_bags_the_total_of_the_five_cement_requests()
    {
        using var factory = await StartAsync();
        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var cement = await db.Products.SingleAsync(product => product.NameFr == "Ciment CPJ 42,5");
        var deliveries = await db.Deliveries.Where(delivery => delivery.SiteId == school && delivery.ProductId == cement.Id).ToListAsync();
        var requests = await db.MaterialRequests.Where(request => request.SiteId == school && request.ProductId == cement.Id && request.Status != RequestStatus.Ordered).ToListAsync();

        Assert.Multiple(() =>
        {
            Assert.That(deliveries, Has.Count.EqualTo(8));
            Assert.That(deliveries.Sum(delivery => delivery.QuantityValue), Is.EqualTo(110m), "110 T.");
            Assert.That(deliveries.Select(delivery => delivery.Unit).Distinct(), Is.EqualTo(new[] { MeasureUnit.Tonne }));
            Assert.That(deliveries.Sum(delivery => delivery.QuantityInRequestUnit), Is.EqualTo(2200m), "110 T = 2 200 sacs (sac de 50 kg).");
            Assert.That(requests.Sum(request => request.QuantityValue), Is.EqualTo(2200m), "DEM-001 à DEM-005 = 800 + 400 + 200 + 200 + 600 sacs.");
        });
    }

    [Test]
    public async Task Orders_deliveries_and_amounts_are_recalculated_by_the_domain_with_the_prices_of_the_table()
    {
        using var factory = await StartAsync();
        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var requests = (await db.MaterialRequests.Where(request => request.SiteId == school).ToListAsync()).ToDictionary(request => request.Number, request => request.Id);
        var orders = (await db.MaterialOrders.Where(order => order.SiteId == school).ToListAsync()).ToDictionary(order => order.RequestId);
        var deliveries = (await db.Deliveries.Where(delivery => delivery.SiteId == school).ToListAsync()).ToDictionary(delivery => delivery.Number);

        Assert.Multiple(() =>
        {
            Assert.That(orders.Values.Select(order => order.Amount), Is.Not.Empty);
            Assert.That(orders[requests["DEM-001"]].Amount, Is.EqualTo(624_000.00m));
            Assert.That(orders[requests["DEM-002"]].Amount, Is.EqualTo(312_000.00m));
            Assert.That(orders[requests["DEM-003"]].Amount, Is.EqualTo(156_000.00m));
            Assert.That(orders[requests["DEM-004"]].Amount, Is.EqualTo(156_000.00m));
            Assert.That(orders[requests["DEM-005"]].Amount, Is.EqualTo(468_000.00m));
            Assert.That(orders[requests["DEM-009"]].Amount, Is.EqualTo(234_000.00m));
            Assert.That(orders[requests["DEM-011"]].Amount, Is.EqualTo(256_000.00m));
            Assert.That(orders, Has.Count.EqualTo(7), "Les demandes DEM-006, 007, 008, 010 et 012 n'ont pas de commande.");

            Assert.That(deliveries["LIV-006"].Amount, Is.EqualTo(156_000.00m), "10 T = 200 sacs x 780,00.");
            Assert.That(deliveries["LIV-009"].QuantityInRequestUnit, Is.EqualTo(1.2m));
            Assert.That(deliveries["LIV-009"].Amount, Is.EqualTo(153_600.00m), "1,2 T x 128 000,00.");
            Assert.That(deliveries["LIV-010"].RequestId, Is.Null, "LIV-010 : gravier, non rattachée.");
            Assert.That(deliveries["LIV-010"].UnattachedReason, Is.EqualTo(UnattachedReason.NoRequestChosen));
            Assert.That(deliveries["LIV-010"].IsNoteMissing, Is.True, "Sans n° de bon ni photo : badge « BL manquant ».");
            Assert.That(deliveries["LIV-010"].Amount, Is.Null);
            Assert.That(deliveries.Values.Where(delivery => delivery.RequestId is not null).Select(delivery => delivery.Conformity), Has.All.EqualTo(Conformity.Conform));
        });
    }

    [Test]
    public async Task The_history_of_a_received_request_tells_its_life_and_every_row_is_authored_by_the_seeding_actor()
    {
        using var factory = await StartAsync();
        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var first = await db.MaterialRequests.SingleAsync(request => request.SiteId == school && request.Number == "DEM-001");
        var types = (await db.MaterialEvents.Where(item => item.SubjectId == first.Id).OrderBy(item => item.RowVersion).ToListAsync()).Select(item => item.Type).ToList();

        Assert.Multiple(async () =>
        {
            Assert.That(types.First(), Is.EqualTo(MaterialEventType.Created));
            Assert.That(types, Does.Contain(MaterialEventType.Approved).And.Contain(MaterialEventType.Ordered).And.Contain(MaterialEventType.DeliveryRegistered));
            Assert.That(types.Last(), Is.EqualTo(MaterialEventType.Received));
            Assert.That(types.Count(type => type == MaterialEventType.DeliveryRegistered), Is.EqualTo(2), "LIV-001 et LIV-002.");
            Assert.That(types.Count(type => type == MaterialEventType.StatusRecomputed), Is.EqualTo(2), "Livrée partiellement après LIV-001, livrée après LIV-002.");
            Assert.That(await db.MaterialRequests.Select(request => request.CreatedBy).Distinct().ToListAsync(), Is.EqualTo(new[] { SystemActorId }), "Écritures hors requête : auteur = amorçage.");
            Assert.That(await db.Deliveries.Select(delivery => delivery.CreatedBy).Distinct().ToListAsync(), Is.EqualTo(new[] { SystemActorId }));
        });
    }

    [Test]
    public async Task The_fictitious_delivery_note_photo_of_LIV_006_is_stored_and_readable_by_purchasing()
    {
        using var factory = await StartAsync();
        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        Guid deliveryId;
        await using (var scope = factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            deliveryId = await db.Deliveries.Where(delivery => delivery.SiteId == school && delivery.Number == "LIV-006").Select(delivery => delivery.Id).SingleAsync();
            Assert.That(await db.Photos.CountAsync(), Is.EqualTo(1), "Une seule photo de bon fictive.");
            Assert.That(await db.Deliveries.CountAsync(delivery => delivery.PhotoCount > 0), Is.EqualTo(1));
        }

        var achats = await SignInDemoAsync(factory, "achats.dev");
        var detail = await (await achats.GetAsync(DeliveryUrl(school, deliveryId))).JsonAsync();
        var photo = detail.GetProperty("photos").EnumerateArray().Single();
        var content = await achats.GetAsync(PhotoContentUrl(school, photo.GetProperty("id").GetGuid()));
        var bytes = await content.Content.ReadAsByteArrayAsync();

        Assert.Multiple(() =>
        {
            Assert.That(photo.GetProperty("contentStatus").GetString(), Is.EqualTo("Uploaded"));
            Assert.That(content.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(content.Content.Headers.ContentType?.MediaType, Is.EqualTo("image/jpeg"));
            Assert.That(bytes.Take(3).ToArray(), Is.EqualTo(new byte[] { 0xFF, 0xD8, 0xFF }), "Octets magiques JPEG.");
            Assert.That(detail.Property("deliveryNoteNumber"), Is.EqualTo("BL-SIG-0561"));
        });
    }

    [Test]
    public async Task CA_016_4_what_each_demo_account_sees()
    {
        using var factory = await StartAsync();
        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        var housing = await SiteIdAsync(factory, DemoData.HousingCode);

        async Task<List<JsonElement>> AllRequestsAsync(ApiSession session, Guid siteId)
        {
            var all = new List<JsonElement>();
            foreach (var view in new[] { "toFollow", "received", "closed" })
            {
                var response = await session.GetAsync($"{RequestsUrl(siteId)}?view={view}&pageSize=200");
                Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), view);
                all.AddRange((await response.JsonAsync()).GetProperty("items").EnumerateArray());
            }

            return all;
        }

        var chef = await SignInDemoAsync(factory, "chef.dev");
        var achats = await SignInDemoAsync(factory, "achats.dev");
        var lonely = await SignInDemoAsync(factory, "nonaffecte.dev");

        var chefRequests = await AllRequestsAsync(chef, school);
        var chefDeliveries = await (await chef.GetAsync($"{DeliveriesUrl(school)}?pageSize=200")).JsonAsync();
        var achatsRequests = await AllRequestsAsync(achats, school);
        var achatsDeliveries = await (await achats.GetAsync($"{DeliveriesUrl(school)}?pageSize=200")).JsonAsync();
        var achatsOrder = achatsRequests.Single(request => request.Number() == "DEM-009");

        Assert.Multiple(async () =>
        {
            Assert.That(chefRequests, Has.Count.EqualTo(12), "a : chef.dev voit les 12 demandes…");
            Assert.That(chefDeliveries.GetProperty("items").GetArrayLength(), Is.EqualTo(10));
            Assert.That(JsonSerializer.Serialize(chefRequests) + chefDeliveries.GetRawText(), Does.Not.Contain("commercial").And.Not.Contain("unitPrice").And.Not.Contain("purchaseOrderNumber").And.Not.Contain("\"amount\""), "… et aucun prix.");

            Assert.That(achatsRequests, Has.Count.EqualTo(12));
            Assert.That(achatsOrder.GetProperty("order").GetProperty("commercial").GetProperty("amount").GetDecimal(), Is.EqualTo(234_000.00m), "b : achats.dev voit les prix.");
            Assert.That(achatsDeliveries.GetProperty("items").EnumerateArray().Any(item => item.TryGetProperty("commercial", out _)), Is.True);

            Assert.That((await lonely.GetAsync(RequestsUrl(school))).StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "c : nonaffecte.dev ne voit rien (404, comme un chantier inexistant).");
            Assert.That((await lonely.GetAsync(DeliveriesUrl(school))).StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That((await chef.GetAsync(RequestsUrl(housing))).StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "chef.dev n'est pas affecté aux logements : DEM-001 de CH-LOG-OL40 lui est invisible.");
            Assert.That((await (await lonely.GetAsync("/api/v1/requests?pageSize=200")).JsonAsync()).GetProperty("items").GetArrayLength(), Is.Zero);
            await Task.CompletedTask;
        });
    }

    [Test]
    public async Task The_phone_pull_of_the_foreman_carries_the_demo_without_any_price_or_supplier_phone()
    {
        using var factory = await StartAsync();
        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        var chef = await SignInDemoAsync(factory, "chef.dev");

        var (changes, _, _) = await chef.PullAllAsync(siteId: school);
        var counts = changes.GroupBy(change => change.GetProperty("entity").GetString()).ToDictionary(group => group.Key!, group => group.Count());
        var text = string.Concat(changes.Select(change => change.GetRawText()));

        Assert.Multiple(() =>
        {
            Assert.That(counts["request"], Is.EqualTo(12));
            Assert.That(counts["delivery"], Is.EqualTo(10));
            Assert.That(counts["photo"], Is.EqualTo(1));
            Assert.That(counts["product"], Is.EqualTo(13));
            Assert.That(counts["supplier"], Is.EqualTo(5));
            Assert.That(text, Does.Not.Contain("commercial").And.Not.Contain("unitPrice").And.Not.Contain("0550 00 00 2"), "Aucun prix, aucun téléphone de fournisseur en synchronisation (ADR 0012).");
        });
    }

    [Test]
    public async Task CA_016_2_loading_again_creates_no_duplicate_and_no_numbering_gap()
    {
        using var factory = await StartAsync();
        var first = await CountsAsync(factory);

        await DatabaseInitializer.InitializeAsync(factory.Services);
        await DatabaseInitializer.InitializeAsync(factory.Services);
        var third = await CountsAsync(factory);

        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var counters = await db.SiteCounters.Where(counter => counter.SiteId == school).ToDictionaryAsync(counter => counter.Prefix, counter => counter.LastValue);

        Assert.Multiple(() =>
        {
            Assert.That(third, Is.EqualTo(first), "Trois chargements, mêmes totaux.");
            Assert.That(first, Is.EqualTo((Products: 13, Suppliers: 5, Requests: 13, Orders: 7, Deliveries: 10, Photos: 1, Events: first.Events)));
            Assert.That(counters["DEM"], Is.EqualTo(12), "Pas de trou : le prochain numéro est DEM-013.");
            Assert.That(counters["LIV"], Is.EqualTo(10));
        });
    }

    [Test]
    public async Task A_second_host_on_the_same_database_adds_nothing()
    {
        using var first = await StartAsync();
        var before = await CountsAsync(first);

        using var second = new ChantierWebApplicationFactory { EnvironmentName = "Development" };
        second.Settings["ConnectionStrings:ChantierDb"] = first.Settings["ConnectionStrings:ChantierDb"];
        second.Settings[DemoDataSeeder.EnabledKey] = "true";
        _ = second.Server;

        Assert.That(await CountsAsync(second), Is.EqualTo(before));
    }

    [Test]
    public async Task Existing_data_is_never_modified_nor_recreated_even_after_a_soft_delete()
    {
        using var factory = await StartAsync();
        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        await using (var scope = factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var product = await db.Products.SingleAsync(candidate => candidate.NameFr == "Sable de maçonnerie");
            product.Update(new Chantier.Core.DTOs.Materials.ProductInput("Sable de maçonnerie", "رمل مغسول", ProductCategory.Aggregates, [MeasureUnit.CubicMeter], MeasureUnit.CubicMeter, null));

            // La corbeille compte : une demande supprimée n'est pas recréée (le jeu n'est écrit que sur un chantier sans demande ni livraison).
            var request = await db.MaterialRequests.SingleAsync(candidate => candidate.SiteId == school && candidate.Number == "DEM-006");
            db.MaterialRequests.Remove(request);
            await db.SaveChangesAsync();
        }

        var before = await CountsAsync(factory);
        await DatabaseInitializer.InitializeAsync(factory.Services);

        await using var verification = factory.Services.CreateAsyncScope();
        var check = verification.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var edited = await check.Products.SingleAsync(candidate => candidate.NameFr == "Sable de maçonnerie");
        Assert.Multiple(async () =>
        {
            Assert.That(await CountsAsync(factory), Is.EqualTo(before));
            Assert.That(edited.NameAr, Is.EqualTo("رمل مغسول"), "Un produit modifié à la main n'est pas remis à l'état du jeu.");
            Assert.That(edited.AllowedUnits, Is.EqualTo(new[] { MeasureUnit.CubicMeter }));
            Assert.That(await check.MaterialRequests.CountAsync(request => request.SiteId == school), Is.EqualTo(11));
            Assert.That(factory.Logs.AllText, Does.Contain("contiennent déjà des demandes ou des livraisons"), "Le chantier laissé tel quel est signalé, pas silencieux.");
        });
    }

    [Test]
    public async Task A_refused_rule_writes_nothing_for_that_site_and_does_not_stop_the_start()
    {
        // Base sans démonstration, avec un produit « Ciment » désactivé : le jeu de l'école ne peut plus s'appliquer (PRODUIT_INACTIF).
        using var plain = await StartAsync(demo: false);
        await using (var scope = plain.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var cement = Product.Create(new Chantier.Core.DTOs.Materials.ProductInput(
                "Ciment CPJ 42,5", null, ProductCategory.Binders, [MeasureUnit.Bag, MeasureUnit.Tonne, MeasureUnit.Kilogram], MeasureUnit.Bag, 50m));
            cement.Deactivate(DateTimeOffset.UtcNow);
            db.Products.Add(cement);
            await db.SaveChangesAsync();
        }

        using var factory = new ChantierWebApplicationFactory { EnvironmentName = "Development" };
        factory.Settings["ConnectionStrings:ChantierDb"] = plain.Settings["ConnectionStrings:ChantierDb"];
        factory.Settings[DemoDataSeeder.EnabledKey] = "true";
        _ = factory.Server;

        var school = await SiteIdAsync(factory, DemoData.SchoolCode);
        var housing = await SiteIdAsync(factory, DemoData.HousingCode);
        await using var verification = factory.Services.CreateAsyncScope();
        var check = verification.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        Assert.Multiple(async () =>
        {
            Assert.That(await check.MaterialRequests.CountAsync(request => request.SiteId == school), Is.Zero, "Le jeu de l'école est refusé en entier : rien d'écrit à moitié.");
            Assert.That(await check.Deliveries.CountAsync(), Is.Zero);
            Assert.That(await check.MaterialRequests.CountAsync(request => request.SiteId == housing), Is.EqualTo(1), "Les logements n'utilisent pas le ciment : leur demande est créée.");
            Assert.That(await check.Products.CountAsync(candidate => candidate.NameFr == "Ciment CPJ 42,5"), Is.EqualTo(1), "Le produit existant est réutilisé, jamais dupliqué.");
            Assert.That(factory.Logs.AllText, Does.Contain("PRODUIT_INACTIF"));
        });
    }

    [Test]
    public async Task Without_the_demo_flag_or_outside_development_no_material_is_written()
    {
        using var off = await StartAsync(demo: false);
        Assert.That(await CountsAsync(off), Is.EqualTo((0, 0, 0, 0, 0, 0, 0)), "Seed:Demo absent : aucun produit, fournisseur, demande ni livraison.");

        var connection = await SqlServerFixture.CreateDatabaseAsync("demomat");
        _databases.Add(connection);
        using var production = new ChantierWebApplicationFactory { EnvironmentName = "Production" };
        production.Settings["ConnectionStrings:ChantierDb"] = connection;
        production.Settings[DemoDataSeeder.EnabledKey] = "true";
        _ = production.Server;
        Assert.That(await CountsAsync(production), Is.EqualTo((0, 0, 0, 0, 0, 0, 0)), "Seed:Demo = true hors Development est ignoré.");
    }

    [Test]
    public async Task Loading_logs_only_counts_never_a_supplier_phone_nor_a_price()
    {
        using var factory = await StartAsync();
        var everything = factory.Logs.AllText;

        Assert.Multiple(() =>
        {
            Assert.That(everything, Does.Contain("Données de démonstration des matériaux"));
            foreach (var supplier in MaterialsDemoData.Suppliers)
            {
                Assert.That(everything, Does.Not.Contain(supplier.Phone), supplier.Key);
            }

            Assert.That(everything, Does.Not.Contain("780").And.Not.Contain("128000").And.Not.Contain("BC-UV18"));
        });
    }

    [Test]
    public void The_demo_catalogue_phones_are_fictitious_and_every_unit_is_allowed_by_its_product()
    {
        Assert.Multiple(() =>
        {
            foreach (var supplier in MaterialsDemoData.Suppliers)
            {
                Assert.That(supplier.Phone, Does.StartWith("0550 00 00 2"), supplier.Name);
                Assert.That(supplier.ProductKeys.All(key => MaterialsDemoData.Products.Any(product => product.Key == key)), Is.True, supplier.Name);
            }

            var products = MaterialsDemoData.Products.ToDictionary(product => product.Key);
            foreach (var site in MaterialsDemoData.Sites)
            {
                foreach (var request in site.Requests)
                {
                    Assert.That(products[request.ProductKey].Units, Does.Contain(request.Unit), request.ProductKey);
                }

                foreach (var delivery in site.Deliveries)
                {
                    Assert.That(products[delivery.ProductKey].Units, Does.Contain(delivery.Unit), delivery.ProductKey);
                }
            }
        });
    }
}
