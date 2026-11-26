using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.SitesTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>B3 : catalogue des produits et fournisseurs (CT-MAT-13, 15, 16), reglages, droits par role.</summary>
[TestFixture]
public class CatalogTests
{
    private ChantierWebApplicationFactory _factory = null!;
    private ApiSession _admin = null!;
    private ApiSession _achats = null!;

    private string _database = string.Empty;

    [OneTimeSetUp]
    public async Task CreateFactory()
    {
        // Base propre a la classe : le catalogue est global, ses produits apparaitraient dans toutes les synchronisations de la base partagee.
        _database = await SqlServerFixture.CreateDatabaseAsync("catalog");
        _factory = new ChantierWebApplicationFactory();
        _factory.Settings["ConnectionStrings:ChantierDb"] = _database;
    }

    [SetUp]
    public async Task SetUp()
    {
        _admin = await _factory.SignInAsync(RoleNames.Admin);
        _achats = await _factory.SignInAsync(RoleNames.Achats);
    }

    [OneTimeTearDown]
    public async Task TearDown()
    {
        _factory.Dispose();
        await SqlServerFixture.DropDatabaseAsync(_database);
    }

    private static async Task<string> CodeOf(HttpResponseMessage response) => (await response.JsonAsync()).GetProperty("code").GetString()!;

    // --- Produits ---

    [Test]
    public async Task Achats_creates_a_cement_with_its_units_and_bag_mass()
    {
        var response = await _achats.PostAsync(Products, ProductBody("Ciment CPJ 42,5 " + Guid.NewGuid().ToString("N")[..6]));
        var json = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(response.Headers.Location!.ToString(), Does.Contain($"/products/{json.Id()}"));
            Assert.That(json.GetProperty("allowedUnits").EnumerateArray().Select(unit => unit.GetString()), Is.EqualTo(new[] { "sac", "t", "kg" }));
            Assert.That(json.GetProperty("defaultUnit").GetString(), Is.EqualTo("sac"));
            Assert.That(json.GetProperty("bagMassKg").GetDecimal(), Is.EqualTo(50m));
            Assert.That(json.GetProperty("isActive").GetBoolean(), Is.True);
            Assert.That(json.GetProperty("category").GetString(), Is.EqualTo("Binders"));
            Assert.That(json.GetProperty("createdByName").GetString(), Is.EqualTo(_achats.Account.FullName));
        });
    }

    [Test]
    public async Task A_product_without_a_bag_mass_is_refused_when_the_bag_unit_is_allowed()
    {
        var response = await _admin.PostAsync(Products, ProductBody(bagMassKg: null));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo("MASSE_SAC_OBLIGATOIRE"));
        });
    }

    [Test]
    public async Task The_default_unit_must_be_one_of_the_allowed_units()
    {
        var response = await _admin.PostAsync(Products, ProductBody(units: ["t", "kg"], defaultUnit: "sac", bagMassKg: null));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo("UNITE_NON_AUTORISEE"));
        });
    }

    [Test]
    public async Task A_free_text_unit_is_refused_and_so_are_missing_fields_with_one_error_per_field()
    {
        var freeText = await _admin.PostRawAsync(Products, """{"nameFr":"Test","category":"Other","allowedUnits":["boite"],"defaultUnit":"boite"}""");
        var empty = await _admin.PostAsync(Products, new { });
        var json = await empty.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(freeText.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest), "l'unite vient du referentiel, jamais du texte libre");
            Assert.That(empty.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(json.GetProperty("code").GetString(), Is.EqualTo("VALIDATION"));
            Assert.That(json.GetProperty("errors").EnumerateObject().Select(error => error.Name), Is.SupersetOf(new[] { "nameFr", "category", "allowedUnits", "defaultUnit" }));
        });
    }

    [Test]
    public async Task A_bag_mass_must_be_positive()
    {
        var response = await _admin.PostAsync(Products, ProductBody(bagMassKg: 0m));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        Assert.That((await response.JsonAsync()).GetProperty("errors").TryGetProperty("bagMassKg", out _), Is.True);
    }

    [TestCase("ciment cpj 42,5")]
    [TestCase("CIMENT  CPJ 42,5")]
    [TestCase("  Ciment CPJ 42,5  ")]
    [TestCase("Cïment CPJ 42,5")]
    public async Task A_name_that_differs_only_by_case_accents_or_spaces_is_a_duplicate(string variant)
    {
        var unique = Guid.NewGuid().ToString("N")[..8];
        await _admin.CreateProductAsync(ProductBody($"Ciment CPJ 42,5 {unique}"));

        var response = await _admin.PostAsync(Products, ProductBody(variant.Replace("42,5", $"42,5 {unique}")));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo("PRODUIT_EXISTANT"));
        });
    }

    [Test]
    public async Task Two_parallel_creations_of_the_same_name_give_one_product_and_one_refusal()
    {
        var name = UniqueName("Sable");
        var results = await Task.WhenAll(Enumerable.Range(0, 6).Select(_ => _admin.PostAsync(Products, ProductBody(name, ["m3", "t"], "m3", null, "Aggregates"))));

        var statuses = results.Select(result => (int)result.StatusCode).OrderBy(status => status).ToList();
        Assert.Multiple(() =>
        {
            Assert.That(statuses.Count(status => status == 201), Is.EqualTo(1));
            Assert.That(statuses.Count(status => status == 422), Is.EqualTo(5));
        });
    }

    [Test]
    public async Task A_product_is_updated_with_its_version_and_a_stale_version_gives_409_with_the_current_state()
    {
        var product = await _admin.CreateProductAsync();
        var body = ProductBody(product.GetProperty("nameFr").GetString(), bagMassKg: 40m);
        body["version"] = product.Version();

        var updated = await _admin.PutAsync($"{Products}/{product.Id()}", body);
        var stale = await _admin.PutAsync($"{Products}/{product.Id()}", body);
        var current = await stale.JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(updated.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await updated.JsonAsync()).GetProperty("bagMassKg").GetDecimal(), Is.EqualTo(40m));
            Assert.That(stale.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
            Assert.That(current.GetProperty("code").GetString(), Is.EqualTo("CONFLIT_VERSION"));
            Assert.That(current.GetProperty("current").GetProperty("bagMassKg").GetDecimal(), Is.EqualTo(40m));
        });
    }

    [Test]
    public async Task Renaming_a_product_onto_another_name_is_refused()
    {
        var first = await _admin.CreateProductAsync();
        var second = await _admin.CreateProductAsync();
        var body = ProductBody(first.GetProperty("nameFr").GetString());
        body["version"] = second.Version();

        var response = await _admin.PutAsync($"{Products}/{second.Id()}", body);

        Assert.That(await CodeOf(response), Is.EqualTo("PRODUIT_EXISTANT"));
    }

    [Test]
    public async Task A_product_is_deactivated_never_deleted_and_both_actions_are_idempotent()
    {
        var product = await _admin.CreateProductAsync();
        var url = $"{Products}/{product.Id()}";

        var first = await _admin.PostAsync(url + "/deactivate");
        var again = await _admin.PostAsync(url + "/deactivate");
        var read = await (await _admin.GetAsync(url)).JsonAsync();
        var back = await _admin.PostAsync(url + "/activate");
        var active = await _admin.GetAsync($"{Products}?isActive=true&q={Uri.EscapeDataString(product.GetProperty("nameFr").GetString()!)}");
        var inactive = await _admin.GetAsync($"{Products}?isActive=false&q={Uri.EscapeDataString(product.GetProperty("nameFr").GetString()!)}");

        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(read.GetProperty("isActive").GetBoolean(), Is.False, "le produit reste lisible");
            Assert.That(read.GetProperty("deactivatedAt").ValueKind, Is.EqualTo(JsonValueKind.String));
            Assert.That((await back.JsonAsync()).GetProperty("isActive").GetBoolean(), Is.True);
            Assert.That((await active.JsonAsync()).GetProperty("totalCount").GetInt32(), Is.EqualTo(1));
            Assert.That((await inactive.JsonAsync()).GetProperty("totalCount").GetInt32(), Is.Zero);
        });
    }

    [Test]
    public async Task Search_ignores_case_and_accents_and_the_list_is_paged_with_a_total()
    {
        var tag = Guid.NewGuid().ToString("N")[..8];
        foreach (var name in new[] { $"Brique creuse {tag} A", $"Brique creuse {tag} B", $"Brique pleine {tag}" })
        {
            await _admin.CreateProductAsync(ProductBody(name, ["u"], "u", null, "Masonry"));
        }

        var page = await (await _admin.GetAsync($"{Products}?q={Uri.EscapeDataString($"BRÏQUE CREUSE {tag}")}&pageSize=1&page=2")).JsonAsync();
        var bad = await _admin.GetAsync($"{Products}?pageSize=500");
        var badSort = await _admin.GetAsync($"{Products}?sort=colonne");

        Assert.Multiple(() =>
        {
            Assert.That(page.GetProperty("totalCount").GetInt32(), Is.EqualTo(2));
            Assert.That(page.GetProperty("items").GetArrayLength(), Is.EqualTo(1));
            Assert.That(page.GetProperty("page").GetInt32(), Is.EqualTo(2));
            Assert.That(bad.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(badSort.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    [Test]
    public async Task The_catalogue_is_readable_by_every_role_but_writable_by_achats_and_admin_only()
    {
        var product = await _admin.CreateProductAsync();
        var results = new List<(string Role, HttpStatusCode Read, HttpStatusCode Write)>();

        foreach (var role in AllRoles)
        {
            var session = await _factory.SignInAsync(role);
            var read = await session.GetAsync($"{Products}/{product.Id()}");
            var write = await session.PostAsync(Products, ProductBody());
            results.Add((role, read.StatusCode, write.StatusCode));
        }

        Assert.Multiple(() =>
        {
            foreach (var (role, read, write) in results)
            {
                Assert.That(read, Is.EqualTo(HttpStatusCode.OK), role);
                var canWrite = role is RoleNames.Admin or RoleNames.Achats;
                Assert.That(write, canWrite ? Is.EqualTo(HttpStatusCode.Created) : Is.EqualTo(HttpStatusCode.Forbidden), role);
            }
        });
    }

    [Test]
    public async Task An_unknown_product_is_a_404_and_an_anonymous_call_a_401()
    {
        var unknown = await _admin.GetAsync($"{Products}/{Guid.NewGuid()}");
        using var anonymous = _factory.CreateClient();
        var noToken = await anonymous.GetAsync(Products);

        Assert.Multiple(() =>
        {
            Assert.That(unknown.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(noToken.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task Three_hundred_products_and_a_hundred_suppliers_are_listed_in_under_two_seconds()
    {
        var tag = Guid.NewGuid().ToString("N")[..8];
        await using (var scope = _factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<Chantier.Infrastructure.Persistence.ApplicationDbContext>();
            for (var index = 0; index < 300; index++)
            {
                db.Products.Add(Chantier.Core.Entities.Materials.Product.Create(new Chantier.Core.DTOs.Materials.ProductInput(
                    $"Produit {tag} {index:000}", null, Chantier.Core.Entities.Materials.ProductCategory.Other, [Chantier.Core.Materials.MeasureUnit.Piece], Chantier.Core.Materials.MeasureUnit.Piece, null)));
            }

            for (var index = 0; index < 100; index++)
            {
                db.Suppliers.Add(Chantier.Core.Entities.Materials.Supplier.Create(new Chantier.Core.DTOs.Materials.SupplierInput($"Fournisseur {tag} {index:000}", null, null)));
            }

            await db.SaveChangesAsync();
        }

        var watch = System.Diagnostics.Stopwatch.StartNew();
        var products = await (await _admin.GetAsync($"{Products}?q={tag}&pageSize=200")).JsonAsync();
        var suppliers = await (await _admin.GetAsync($"{Suppliers}?q={tag}&pageSize=200")).JsonAsync();
        watch.Stop();

        Assert.Multiple(() =>
        {
            Assert.That(products.GetProperty("totalCount").GetInt32(), Is.EqualTo(300));
            Assert.That(suppliers.GetProperty("totalCount").GetInt32(), Is.EqualTo(100));
            Assert.That(watch.Elapsed, Is.LessThan(TimeSpan.FromSeconds(2)));
        });
    }

    // --- Fournisseurs ---

    [Test]
    public async Task A_supplier_is_created_with_a_phone_in_the_algerian_format_and_known_products()
    {
        var product = await _admin.CreateProductAsync();
        var supplier = await _achats.CreateSupplierAsync(phone: "0550000021", productIds: [product.Id()]);

        Assert.Multiple(() =>
        {
            Assert.That(supplier.GetProperty("phone").GetString(), Is.EqualTo("0550 00 00 21"), "le numero est enregistre avec ses espaces d'affichage");
            Assert.That(supplier.GetProperty("productIds").EnumerateArray().Select(id => id.GetGuid()), Is.EqualTo(new[] { product.Id() }));
            Assert.That(supplier.GetProperty("isActive").GetBoolean(), Is.True);
        });
    }

    [TestCase("0150 00 00 21")]
    [TestCase("055000002")]
    [TestCase("abcdefghij")]
    [TestCase("+213 550 00 00 21")]
    public async Task A_phone_outside_the_algerian_format_is_refused_without_echoing_it(string phone)
    {
        var response = await _admin.PostAsync(Suppliers, new { name = UniqueName("F"), phone });
        var text = await response.Content.ReadAsStringAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(text, Does.Not.Contain(phone), "un telephone ne s'echappe jamais vers une reponse d'erreur");
        });
    }

    [Test]
    public async Task An_unknown_product_in_the_supplier_list_is_refused()
    {
        var response = await _admin.PostAsync(Suppliers, new { name = UniqueName("F"), productIds = new[] { Guid.NewGuid() } });

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        Assert.That((await response.JsonAsync()).GetProperty("errors").TryGetProperty("productIds", out _), Is.True);
    }

    [Test]
    public async Task A_supplier_name_is_unique_without_case_accents_or_spaces()
    {
        var tag = Guid.NewGuid().ToString("N")[..8];
        await _admin.CreateSupplierAsync($"Société Béton {tag}");

        var duplicate = await _admin.PostAsync(Suppliers, new { name = $"  societe  BETON {tag} " });

        Assert.Multiple(async () =>
        {
            Assert.That(duplicate.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(duplicate), Is.EqualTo("FOURNISSEUR_EXISTANT"));
        });
    }

    [Test]
    public async Task The_supplier_phone_is_visible_for_admin_achats_conducteur_and_chef_chantier_only()
    {
        var supplier = await _admin.CreateSupplierAsync(phone: "0661 22 33 44");
        var expected = new Dictionary<string, bool>
        {
            [RoleNames.Admin] = true,
            [RoleNames.Achats] = true,
            [RoleNames.ConducteurTravaux] = true,
            [RoleNames.ChefChantier] = true,
            [RoleNames.Direction] = false,
            [RoleNames.ChefEquipe] = false,
        };

        var seen = new Dictionary<string, (bool Detail, bool List)>();
        foreach (var role in expected.Keys)
        {
            var session = await _factory.SignInAsync(role);
            var detail = await (await session.GetAsync($"{Suppliers}/{supplier.Id()}")).JsonAsync();
            var list = await (await session.GetAsync($"{Suppliers}?q={Uri.EscapeDataString(supplier.GetProperty("name").GetString()!)}")).JsonAsync();
            seen[role] = (detail.TryGetProperty("phone", out _), list.GetProperty("items")[0].TryGetProperty("phone", out _));
        }

        Assert.Multiple(() =>
        {
            foreach (var (role, visible) in expected)
            {
                Assert.That(seen[role].Detail, Is.EqualTo(visible), $"détail {role}");
                Assert.That(seen[role].List, Is.EqualTo(visible), $"liste {role}");
            }
        });
    }

    [Test]
    public async Task A_supplier_is_updated_with_its_version_and_deactivated_never_deleted()
    {
        var supplier = await _admin.CreateSupplierAsync();
        var url = $"{Suppliers}/{supplier.Id()}";

        var updated = await _admin.PutAsync(url, new { name = supplier.GetProperty("name").GetString() + " bis", phone = (string?)null, productIds = Array.Empty<Guid>(), version = supplier.Version() });
        var stale = await _admin.PutAsync(url, new { name = "Autre", version = supplier.Version() });
        var off = await _admin.PostAsync(url + "/deactivate");
        var read = await (await _admin.GetAsync(url)).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(updated.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(stale.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
            Assert.That(off.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(read.GetProperty("isActive").GetBoolean(), Is.False);
        });
    }

    [Test]
    public async Task Only_achats_and_admin_write_suppliers()
    {
        var statuses = new Dictionary<string, HttpStatusCode>();
        foreach (var role in AllRoles)
        {
            var session = await _factory.SignInAsync(role);
            statuses[role] = (await session.PostAsync(Suppliers, new { name = UniqueName("F") })).StatusCode;
        }

        Assert.Multiple(() =>
        {
            foreach (var (role, status) in statuses)
            {
                Assert.That(status, role is RoleNames.Admin or RoleNames.Achats ? Is.EqualTo(HttpStatusCode.Created) : Is.EqualTo(HttpStatusCode.Forbidden), role);
            }
        });
    }

    [Test]
    public async Task The_supplier_phone_never_reaches_the_logs()
    {
        var phone = "0771 23 45 67";
        using var factory = new ChantierWebApplicationFactory();
        factory.Settings["ConnectionStrings:ChantierDb"] = _database;
        var admin = await factory.SignInAsync(RoleNames.Admin);

        var created = await admin.CreateSupplierAsync(phone: phone);
        await admin.GetAsync($"{Suppliers}/{created.Id()}");
        await admin.PostAsync(Suppliers, new { name = created.GetProperty("name").GetString(), phone });
        await admin.PutAsync($"{Suppliers}/{created.Id()}", new { name = "X", phone, version = "1" });

        var logged = string.Join('\n', factory.Logs.Entries);
        Assert.That(logged.Replace(" ", string.Empty), Does.Not.Contain("0771234567"));
    }

    // --- Reglages ---

    [Test]
    public async Task Settings_are_readable_by_any_signed_in_user_and_carry_the_reason_lists()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefEquipe);

        var json = await (await chef.GetAsync("/api/v1/settings/materials")).JsonAsync();
        using var anonymous = _factory.CreateClient();
        var noToken = await anonymous.GetAsync("/api/v1/settings/materials");

        Assert.Multiple(() =>
        {
            Assert.That(json.GetProperty("defaultNeededByDays").GetInt32(), Is.EqualTo(3));
            Assert.That(json.GetProperty("deliveryTolerancePercent").GetDecimal(), Is.Zero);
            Assert.That(json.GetProperty("maxPhotosPerDelivery").GetInt32(), Is.EqualTo(5));
            Assert.That(json.GetProperty("maxPhotoBytes").GetInt64(), Is.EqualTo(5L * 1024 * 1024));
            Assert.That(json.GetProperty("noteMaxLength").GetInt32(), Is.EqualTo(200));
            Assert.That(json.GetProperty("reasons").GetProperty("rejection").EnumerateArray().Select(reason => reason.GetString()), Is.EqualTo(new[] { "AlreadyOrdered", "StockSufficient", "QuantityToReview", "OverBudget", "Other" }));
            Assert.That(json.GetProperty("reasons").EnumerateObject().Select(property => property.Name), Is.EquivalentTo(new[] { "rejection", "requestCancellation", "orderCancellation", "settle", "deliveryCancellation", "reserve" }));
            Assert.That(noToken.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }
}
