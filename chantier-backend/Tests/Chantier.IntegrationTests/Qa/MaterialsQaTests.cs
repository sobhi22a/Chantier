using System.Net;
using System.Text.Json;
using System.Text.Json.Nodes;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Materials;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.MaterialsSyncKit;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Qa;

/// <summary>
/// Q3 (demandes de materiaux et livraisons) : cas limites ecrits par la QA, independants des tests des developpeurs. Donnees extremes (quantite 0, negative, tres grande,
/// montant qui deborde), texte arabe long et caracteres speciaux, corps nuls ou malformes, dates incompletes, idempotence avec d'autres valeurs, concurrence
/// (statut contre statut, version contre version) et balayages derives du contrat OpenAPI (isolation par chantier, prix et telephone absents).
/// Chaque test cree ses propres donnees ; un test rouge ici est un defaut a corriger, jamais un test a desactiver.
/// </summary>
[TestFixture]
public class MaterialsQaTests : DeliveryFixtureBase
{
    private const string FieldPhone = "0550 00 00 21";

    private static string ProblemCode(string body)
    {
        using var document = JsonDocument.Parse(body);
        return document.RootElement.TryGetProperty("code", out var code) ? code.GetString() ?? string.Empty : string.Empty;
    }

    private static string CreateRequestJson(Guid productId, string quantityLiteral, string unit, string? note = null, string? freeName = null, string? neededByLiteral = null)
    {
        var product = freeName is null ? $"\"productId\":\"{productId}\",\"freeProductName\":null" : $"\"productId\":null,\"freeProductName\":{JsonSerializer.Serialize(freeName)}";
        return $$"""{"clientId":"{{Guid.NewGuid()}}","clientCreatedAt":"2026-11-25T06:58:00Z",{{product}},"quantity":{"value":{{quantityLiteral}},"unit":"{{unit}}"},"zoneId":null,"neededBy":{{neededByLiteral ?? $"\"{FutureDate()}\""}},"priority":"Normal","note":{{(note is null ? "null" : JsonSerializer.Serialize(note))}}}""";
    }

    // --- Donnees extremes : quantites -----------------------------------------------------------------

    [TestCase("0", "sac")]
    [TestCase("-5", "sac")]
    [TestCase("-0.001", "kg")]
    [TestCase("0.0004", "kg")]
    [TestCase("2.5004", "kg")]
    [TestCase("1000000000.001", "kg")]
    [TestCase("999999999999999.999", "kg")]
    [TestCase("1e15", "kg")]
    [TestCase("79228162514264337593543950335", "kg")]
    [TestCase("1e40", "kg")]
    [TestCase("2.5", "sac")]
    [TestCase("100.5", "sac")]
    [TestCase("null", "sac")]
    [TestCase("true", "sac")]
    [TestCase("[1]", "sac")]
    public async Task An_absurd_quantity_is_refused_with_a_problem_and_a_code_and_creates_nothing(string literal, string unit)
    {
        var before = await Factory.CountRequestsAsync(Site.Id);
        var productId = unit == "sac" ? CementId : SteelId;

        var response = await Chef.SendRawAsync(HttpMethod.Post, RequestsUrl(Site.Id), CreateRequestJson(productId, literal, unit));
        var body = await response.Content.ReadAsStringAsync();
        var after = await Factory.CountRequestsAsync(Site.Id);

        Assert.Multiple(() =>
        {
            Assert.That((int)response.StatusCode, Is.EqualTo(400).Or.EqualTo(422), body);
            Assert.That(response.Content.Headers.ContentType?.MediaType, Is.EqualTo("application/problem+json"));
            Assert.That(ProblemCode(body), Is.Not.Empty, "code metier stable dans le Problem Details");
            Assert.That(body, Does.Not.Contain("Exception").And.Not.Contain("   at "), "aucune trace interne");
            Assert.That(after, Is.EqualTo(before), "rien n'est enregistre");
        });
    }

    [Test]
    public async Task The_largest_quantity_at_the_largest_price_gives_the_exact_amount_and_an_overflow_is_never_a_server_error()
    {
        var site = await NewSiteAsync();
        var id = await Chef.NewRequestIdAsync(site.Id, SteelId, 1_000_000_000m, "kg");
        Assert.That((await Conducteur.PostAsync($"{RequestUrl(site.Id, id)}/approve")).StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var order = await Achats.PostAsync(OrderUrl(site.Id, id), OrderBody(SupplierId, 9_999_999.99m));
        var orderJson = await order.JsonAsync();
        var amount = orderJson.GetProperty("order").GetProperty("commercial").GetProperty("amount").GetDecimal();

        var exact = await Chef.PostAsync(DeliveriesUrl(site.Id), DeliveryBody(id, 1_000_000_000m, "kg", Factory.Today(), SupplierId));
        var overflow = await Chef.PostAsync(DeliveriesUrl(site.Id), DeliveryBody(id, 1_000_000_000m, "t", Factory.Today(), SupplierId));
        var overflowBody = await overflow.Content.ReadAsStringAsync();
        var detail = await Achats.GetAsync(RequestUrl(site.Id, id));

        Assert.Multiple(() =>
        {
            Assert.That(order.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(amount, Is.EqualTo(9_999_999_990_000_000.00m), "1 000 000 000 kg x 9 999 999,99 DZD");
            Assert.That(exact.StatusCode, Is.EqualTo(HttpStatusCode.Created), "la livraison exacte tient dans les colonnes");
            Assert.That((int)overflow.StatusCode, Is.LessThan(500), "1 milliard de tonnes recues pour une commande au prix maximal : un refus clair, jamais une erreur serveur : " + overflowBody + " | " + string.Join(" | ", Factory.Logs.Entries.Where(entry => entry.StartsWith("[Error]", StringComparison.Ordinal)).TakeLast(1).Select(entry => entry.Length > 700 ? entry[..700] : entry)));
            Assert.That(overflow.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity), "D-1 : refus metier 422");
            Assert.That(overflowBody, Does.Contain("QUANTITE_INVALIDE"));
            Assert.That(detail.StatusCode, Is.EqualTo(HttpStatusCode.OK), "la demande reste lisible apres l'essai");
        });
    }

    // --- Donnees extremes : texte ---------------------------------------------------------------------

    private const string Specials = "إسمنت CPJ 42,5 « Ø12 » <b>&amp;</b> ' \" % _ [x] \\ ؟ ٣٠٠";

    [Test]
    public async Task Arabic_text_of_the_maximum_length_and_special_characters_come_back_exactly_and_one_character_more_is_refused()
    {
        var note = Specials + new string('ع', 200 - Specials.Length);
        var freeName = new string('ع', 100);

        var created = await Chef.CreateRequestAsync(Site.Id, RequestBody(null, 12m, "m3", freeName: freeName, note: note));
        var reread = await (await Chef.GetAsync(RequestUrl(Site.Id, created.Id()))).JsonAsync();
        var tooLongNote = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, note: note + "ع"));
        var tooLongName = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(null, 12m, "m3", freeName: freeName + "ع"));
        var bricks = string.Concat(Enumerable.Repeat("🧱", 100));
        var emoji = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, note: bricks));

        Assert.Multiple(() =>
        {
            Assert.That(reread.GetProperty("note").GetString(), Is.EqualTo(note), "ni encodage HTML, ni perte, ni inversion");
            Assert.That(reread.GetProperty("product").GetProperty("freeName").GetString(), Is.EqualTo(freeName));
            Assert.That(tooLongNote.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(tooLongName.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(emoji.StatusCode, Is.EqualTo(HttpStatusCode.Created), "100 emojis (200 unites UTF-16) tiennent dans 200 caracteres");
        });
    }

    [Test]
    public async Task Search_jokers_and_brackets_are_plain_text_and_never_break_the_list()
    {
        var site = await NewSiteAsync();
        var special = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "remise 8 % sur [lot] a_b"));
        var plain = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "rien de special"));

        var results = new Dictionary<string, List<Guid>>();
        foreach (var q in new[] { "%", "_", "[lot]", "[", "'", "\"", "<b>", "a_b", "; DROP TABLE MaterialRequests;--", "ø", "إسمنت" })
        {
            var response = await Chef.GetAsync($"{RequestsUrl(site.Id)}?q={Uri.EscapeDataString(q)}");
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), $"q={q} : " + await response.Content.ReadAsStringAsync());
            results[q] = (await response.JsonAsync()).GetProperty("items").EnumerateArray().Select(item => item.Id()).ToList();
        }

        Assert.Multiple(() =>
        {
            Assert.That(results["%"], Is.EqualTo(new[] { special.Id() }), "% est un caractere, pas un joker");
            Assert.That(results["_"], Is.EqualTo(new[] { special.Id() }), "_ est un caractere, pas un joker");
            Assert.That(results["[lot]"], Is.EqualTo(new[] { special.Id() }), "les crochets ne forment pas une classe de caracteres");
            Assert.That(results["a_b"], Is.EqualTo(new[] { special.Id() }));
            Assert.That(results["; DROP TABLE MaterialRequests;--"], Is.Empty);
            Assert.That(results.Values.SelectMany(ids => ids), Does.Not.Contain(plain.Id()), "la demande sans caractere special n'est jamais trouvee par un joker");
        });
    }

    // --- Corps nuls ou malformes ----------------------------------------------------------------------

    [TestCase("null")]
    [TestCase("{}")]
    [TestCase("[]")]
    [TestCase("\"texte\"")]
    [TestCase("{")]
    [TestCase("")]
    [TestCase("{\"clientId\":\"pas-un-guid\"}")]
    [TestCase("{\"clientId\":null,\"quantity\":null}")]
    [TestCase("{\"quantity\":{\"value\":null,\"unit\":null}}")]
    [TestCase("{\"quantity\":{\"value\":1,\"unit\":\"parpaing\"},\"productId\":null}")]
    public async Task A_null_or_malformed_body_is_a_4xx_problem_on_every_creation_route_never_a_500(string json)
    {
        var requestId = await ValidatedAsync();
        var urls = new[]
        {
            (HttpMethod.Post, RequestsUrl(Site.Id)),
            (HttpMethod.Post, OrderUrl(Site.Id, requestId)),
            (HttpMethod.Post, DeliveriesUrl(Site.Id)),
            (HttpMethod.Put, RequestUrl(Site.Id, requestId)),
            (HttpMethod.Post, $"{RequestUrl(Site.Id, requestId)}/reject"),
            (HttpMethod.Post, $"{RequestUrl(Site.Id, requestId)}/cancel"),
            (HttpMethod.Post, $"{RequestsUrl(Site.Id)}/batch/approve"),
            (HttpMethod.Post, PushUrl),
        };

        foreach (var (method, url) in urls)
        {
            var response = await Admin.SendRawAsync(method, url, json);
            var body = await response.Content.ReadAsStringAsync();
            Assert.That((int)response.StatusCode, Is.GreaterThanOrEqualTo(400).And.LessThan(500), $"{method} {url} avec {json} : {body}");
            Assert.That(response.Content.Headers.ContentType?.MediaType, Is.EqualTo("application/problem+json"), $"{method} {url}");
            Assert.That(body, Does.Not.Contain("   at "), $"{method} {url} : pas de trace de pile");
        }
    }

    // --- Dates ------------------------------------------------------------------------------------------

    [TestCase("\"../08/2026\"")]
    [TestCase("\"31/11/2026\"")]
    [TestCase("\"2026-02-30\"")]
    [TestCase("\"2026-13-01\"")]
    [TestCase("\"2026/12/01\"")]
    [TestCase("\"2026-12-1\"")]
    [TestCase("\"\"")]
    [TestCase("\" \"")]
    [TestCase("\"0000-00-00\"")]
    [TestCase("\"2026-12-01T00:00:00Z\"")]
    [TestCase("\"20261201\"")]
    [TestCase("20261201")]
    [TestCase("\"9999-99-99\"")]
    public async Task An_incomplete_or_impossible_date_is_DATE_INVALIDE_on_the_delivery_the_order_and_the_request(string literal)
    {
        var site = await NewSiteAsync();
        var validated = await ValidatedAsync(siteId: site.Id);
        var delivery = $$"""{"clientId":"{{Guid.NewGuid()}}","requestId":null,"supplierId":null,"freeSupplierName":"Fournisseur libre","productId":null,"freeProductName":"Gravier libre","quantity":{"value":10,"unit":"t"},"deliveryDate":{{literal}},"deliveryNoteNumber":null,"conformity":"Conform"}""";
        var order = $$"""{"clientId":"{{Guid.NewGuid()}}","supplierId":"{{SupplierId}}","orderDate":{{literal}},"unitPrice":780}""";
        var planned = $$"""{"clientId":"{{Guid.NewGuid()}}","supplierId":"{{SupplierId}}","orderDate":"{{Iso(Factory.Today())}}","expectedDeliveryDate":{{literal}},"unitPrice":780}""";

        var responses = new Dictionary<string, HttpResponseMessage>
        {
            ["livraison"] = await Chef.SendRawAsync(HttpMethod.Post, DeliveriesUrl(site.Id), delivery),
            ["commande (date de commande)"] = await Achats.SendRawAsync(HttpMethod.Post, OrderUrl(site.Id, validated), order),
            ["commande (livraison prevue)"] = await Achats.SendRawAsync(HttpMethod.Post, OrderUrl(site.Id, validated), planned),
            ["demande"] = await Chef.SendRawAsync(HttpMethod.Post, RequestsUrl(site.Id), CreateRequestJson(CementId, "10", "sac", neededByLiteral: literal)),
        };

        foreach (var (name, response) in responses)
        {
            var body = await response.Content.ReadAsStringAsync();
            Assert.That((int)response.StatusCode, Is.EqualTo(400), $"{name} : {body}");
            Assert.That(ProblemCode(body), Is.EqualTo("DATE_INVALIDE"), name);
        }

        Assert.That((await ReadRequestAsync(validated, siteId: site.Id)).StatusOf(), Is.EqualTo("Validated"), "aucune commande n'est passee");
    }

    [TestCase("0001-01-01")]
    [TestCase("9999-12-31")]
    public async Task Extreme_but_valid_dates_do_not_break_the_lists_or_the_overdue_calculation(string date)
    {
        var site = await NewSiteAsync();

        var created = await Chef.PostAsync(RequestsUrl(site.Id), RequestBody(CementId, neededBy: date));
        var list = await Chef.GetAsync($"{RequestsUrl(site.Id)}?view=late");
        var followUp = await Chef.GetAsync(FollowUpUrl(site.Id));
        var all = await Chef.GetAsync($"/api/v1/requests?sort=neededBy");

        Assert.Multiple(() =>
        {
            Assert.That((int)created.StatusCode, Is.LessThan(500));
            Assert.That(list.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(followUp.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((int)all.StatusCode, Is.LessThan(500));
        });
    }

    // --- Idempotence avec d'autres valeurs ------------------------------------------------------------

    [Test]
    public async Task The_same_client_id_with_other_values_returns_the_first_request_untouched_and_burns_no_number()
    {
        var site = await NewSiteAsync();
        var clientId = Guid.NewGuid();

        var first = await Chef.PostAsync(RequestsUrl(site.Id), RequestBody(CementId, 300m, "sac", clientId: clientId));
        var other = await Chef.PostAsync(RequestsUrl(site.Id), RequestBody(SteelId, 5m, "t", clientId: clientId, priority: "Blocking", note: "autre contenu"));
        var next = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));
        var firstJson = await first.JsonAsync();
        var otherJson = await other.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(other.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(otherJson.Id(), Is.EqualTo(firstJson.Id()));
            Assert.That(otherJson.GetProperty("quantity").GetProperty("value").GetDecimal(), Is.EqualTo(300m), "le premier envoi fait foi");
            Assert.That(otherJson.GetProperty("priority").GetString(), Is.EqualTo("Normal"));
            Assert.That(otherJson.Property("note"), Is.Null);
            Assert.That(next.Number(), Is.EqualTo("DEM-002"), "le renvoi n'a consomme aucun numero");
        });
    }

    [Test]
    public async Task The_same_client_id_for_a_delivery_or_an_order_with_other_values_changes_nothing()
    {
        var site = await NewSiteAsync();
        var requestId = await ValidatedAsync(600m, siteId: site.Id);
        var orderClient = Guid.NewGuid();
        var deliveryClient = Guid.NewGuid();

        var order = await Achats.PostAsync(OrderUrl(site.Id, requestId), OrderBody(SupplierId, 780m, clientId: orderClient));
        var otherOrder = await Achats.PostAsync(OrderUrl(site.Id, requestId), OrderBody(SupplierId, 999m, clientId: orderClient));
        var delivery = await Chef.PostAsync(DeliveriesUrl(site.Id), DeliveryBody(requestId, 10m, "t", Factory.Today(), SupplierId, clientId: deliveryClient));
        var otherDelivery = await Chef.PostAsync(DeliveriesUrl(site.Id), DeliveryBody(requestId, 99m, "t", Factory.Today(), SupplierId, clientId: deliveryClient));
        var detail = await ReadRequestAsync(requestId, Achats, site.Id);
        var deliveryJson = await delivery.JsonAsync();
        var otherDeliveryJson = await otherDelivery.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(order.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(otherOrder.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(delivery.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(otherDelivery.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(otherDeliveryJson.Id(), Is.EqualTo(deliveryJson.Id()));
            Assert.That(otherDeliveryJson.Property("number"), Is.EqualTo(deliveryJson.Property("number")));
            Assert.That(detail.GetProperty("order").GetProperty("commercial").GetProperty("unitPrice").GetDecimal(), Is.EqualTo(780m), "le prix du premier envoi");
            Assert.That(detail.Received(), Is.EqualTo(200m), "10 T = 200 sacs, une seule fois");
            Assert.That(detail.GetProperty("deliveries").GetArrayLength(), Is.EqualTo(1));
        });
    }

    // --- Concurrence ----------------------------------------------------------------------------------

    [Test]
    public async Task Approving_and_cancelling_at_the_same_instant_always_end_cancelled_with_a_coherent_history()
    {
        for (var round = 0; round < 8; round++)
        {
            var site = await NewSiteAsync();
            var id = await Chef.NewRequestIdAsync(site.Id, CementId);

            var approve = Conducteur.PostAsync($"{RequestUrl(site.Id, id)}/approve");
            var cancel = Chef.PostAsync($"{RequestUrl(site.Id, id)}/cancel", new { reasonCode = "NoLongerNeeded" });
            var results = await Task.WhenAll(approve, cancel);
            var detail = await ReadRequestAsync(id, siteId: site.Id);
            var types = detail.HistoryTypes().ToList();

            Assert.Multiple(() =>
            {
                Assert.That(results[1].StatusCode, Is.EqualTo(HttpStatusCode.OK), $"tour {round} : annuler marche depuis Demandee comme depuis Validee");
                Assert.That((int)results[0].StatusCode, Is.EqualTo(200).Or.EqualTo(422), $"tour {round}");
                Assert.That(detail.StatusOf(), Is.EqualTo("Cancelled"), $"tour {round} : aucune mise a jour perdue");
                Assert.That(types.Count(type => type == "Cancelled"), Is.EqualTo(1), $"tour {round}");
                Assert.That(types.Count(type => type == "Approved"), Is.EqualTo(results[0].StatusCode == HttpStatusCode.OK ? 1 : 0), $"tour {round} : la validation annoncee est tracee, la refusee ne l'est pas");
                Assert.That(types.Last(), Is.EqualTo("Cancelled"), $"tour {round}");
            });
        }
    }

    [Test]
    public async Task An_edit_of_the_quantity_racing_with_the_approval_never_changes_a_locked_quantity()
    {
        for (var round = 0; round < 8; round++)
        {
            var site = await NewSiteAsync();
            var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 300m, "sac"));
            var id = created.Id();

            var approve = Conducteur.PostAsync($"{RequestUrl(site.Id, id)}/approve");
            var edit = Chef.PutAsync(RequestUrl(site.Id, id), new { version = created.Version(), quantity = new { value = 400m, unit = "sac" } });
            var results = await Task.WhenAll(approve, edit);
            var detail = await ReadRequestAsync(id, siteId: site.Id);
            var history = detail.GetProperty("history").EnumerateArray().Select(item => item.GetProperty("type").GetString()).ToList();
            var edited = results[1].StatusCode == HttpStatusCode.OK;
            var quantity = detail.GetProperty("quantity").GetProperty("value").GetDecimal();

            Assert.Multiple(() =>
            {
                Assert.That(results[0].StatusCode, Is.EqualTo(HttpStatusCode.OK), $"tour {round}");
                Assert.That((int)results[1].StatusCode, Is.EqualTo(200).Or.EqualTo(409).Or.EqualTo(422), $"tour {round} : {results[1].StatusCode}");
                Assert.That(detail.StatusOf(), Is.EqualTo("Validated"), $"tour {round}");
                Assert.That(quantity, Is.EqualTo(edited ? 400m : 300m), $"tour {round} : la quantite finale est celle de la derniere ecriture acceptee");
                if (edited)
                {
                    Assert.That(history.IndexOf("Edited"), Is.LessThan(history.IndexOf("Approved")), $"tour {round} : une quantite ne se modifie jamais apres la validation");
                }
            });
        }
    }

    [Test]
    public async Task Six_corrections_of_a_delivery_or_an_order_on_the_same_version_give_one_success_and_five_conflicts()
    {
        var site = await NewSiteAsync();
        var requestId = await OrderedRequestAsync(600m, siteId: site.Id);
        // 7,5 t au depart : aucune des six corrections (1 a 6 t) ne redemande la valeur actuelle (un « aucun changement » repond 200 sans ecrire, ce qui masquerait la course).
        var delivery = await DeliverAsync(requestId, 7.5m, "t", siteId: site.Id);
        var order = (await ReadRequestAsync(requestId, Achats, site.Id)).GetProperty("order");

        var deliveryEdits = await Task.WhenAll(Enumerable.Range(1, 6).Select(index => Chef.PutAsync(
            DeliveryUrl(site.Id, delivery.Id()), new { version = delivery.Version(), quantity = new { value = (decimal)index, unit = "t" } })));
        var orderEdits = await Task.WhenAll(Enumerable.Range(1, 6).Select(index => Achats.PutAsync(
            $"{OrderUrl(site.Id, requestId)}", new { version = order.Version(), unitPrice = 700m + index })));
        var deliveryCodes = deliveryEdits.Select(response => (int)response.StatusCode).OrderBy(code => code).ToList();
        var orderCodes = orderEdits.Select(response => (int)response.StatusCode).OrderBy(code => code).ToList();
        var finalDelivery = await (await Chef.GetAsync(DeliveryUrl(site.Id, delivery.Id()))).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(deliveryCodes, Is.EqualTo(new[] { 200, 409, 409, 409, 409, 409 }), "livraison : une seule modification sur la meme version : " + string.Join(",", deliveryCodes));
            Assert.That(orderCodes, Is.EqualTo(new[] { 200, 409, 409, 409, 409, 409 }), "commande : une seule modification sur la meme version : " + string.Join(",", orderCodes));
            Assert.That(finalDelivery.GetProperty("quantity").GetProperty("value").GetDecimal(), Is.InRange(1m, 6m), "la valeur finale est celle de la seule correction acceptee");
        });
    }

    // --- Numerotation ------------------------------------------------------------------------------------

    [Test]
    public async Task A_cancelled_then_archived_request_never_gives_its_number_again()
    {
        var site = await NewSiteAsync();
        var first = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));
        Assert.That((await Chef.PostAsync($"{RequestUrl(site.Id, first.Id())}/cancel", new { reasonCode = "EntryError" })).StatusCode, Is.EqualTo(HttpStatusCode.OK));
        Assert.That((await Conducteur.PostAsync($"{RequestUrl(site.Id, first.Id())}/archive")).StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var second = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));
        var delivery = await Chef.CreateDeliveryAsync(site.Id, DeliveryBody(null, 1m, "t", Factory.Today(), freeSupplier: "Libre fournisseur", freeProduct: "Gravier libre"));
        await Chef.PostAsync($"{DeliveryUrl(site.Id, delivery.Id())}/cancel", new { reasonCode = "DoubleEntry" });
        var nextDelivery = await Chef.CreateDeliveryAsync(site.Id, DeliveryBody(null, 1m, "t", Factory.Today(), freeSupplier: "Libre fournisseur", freeProduct: "Gravier libre"));

        Assert.Multiple(() =>
        {
            Assert.That(first.Number(), Is.EqualTo("DEM-001"));
            Assert.That(second.Number(), Is.EqualTo("DEM-002"), "le numero d'une demande annulee et archivee n'est jamais reattribue");
            Assert.That(delivery.Property("number"), Is.EqualTo("LIV-001"));
            Assert.That(nextDelivery.Property("number"), Is.EqualTo("LIV-002"), "le numero d'une livraison annulee n'est jamais reattribue");
        });
    }

    // --- Balayages derives du contrat OpenAPI ---------------------------------------------------------

    private static JsonObject CommittedPaths()
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null)
        {
            var candidate = Path.Combine(directory.FullName, "docs", "api", "openapi.json");
            if (File.Exists(candidate))
            {
                return JsonNode.Parse(File.ReadAllText(candidate))!["paths"]!.AsObject();
            }

            directory = directory.Parent;
        }

        throw new FileNotFoundException("docs/api/openapi.json introuvable.");
    }

    private static IEnumerable<(string Path, string Method)> Operations(Func<string, string, bool> keep)
        => CommittedPaths()
            .SelectMany(item => item.Value!.AsObject().Select(operation => (Path: item.Key, Method: operation.Key.ToUpperInvariant())))
            .Where(operation => keep(operation.Path, operation.Method));

    private static string Fill(string template, Guid siteId, IReadOnlyDictionary<string, Guid>? known = null)
    {
        var url = template.Replace("{siteId}", siteId.ToString(), StringComparison.Ordinal);
        foreach (var token in System.Text.RegularExpressions.Regex.Matches(url, "\\{(\\w+)\\}").Select(match => match.Groups[1].Value).Distinct().ToList())
        {
            var value = known is not null && known.TryGetValue(token, out var id) ? id : Guid.NewGuid();
            url = url.Replace("{" + token + "}", value.ToString(), StringComparison.Ordinal);
        }

        return url;
    }

    private static HttpMethod MethodOf(string method) => new(method);

    [Test]
    public async Task Every_site_route_of_the_contract_gives_a_user_who_is_not_assigned_the_same_answer_as_an_unknown_site()
    {
        var outsider = await NewSiteAsync();
        var operations = Operations((path, _) => path.StartsWith("/api/v1/sites/{siteId}/", StringComparison.Ordinal)).ToList();
        var different = new List<string>();
        var neither404Nor403 = new List<string>();
        var notFound = 0;

        // Trois roles qui, a eux trois, ont le droit de toutes les actions : sans le droit, la reponse est 403 (identique pour un chantier inconnu, aucune fuite) ;
        // avec le droit, un chantier non affecte doit repondre 404.
        foreach (var role in new[] { RoleNames.ConducteurTravaux, RoleNames.Achats, RoleNames.ChefChantier })
        {
            var lonely = await Factory.SignInAsync(role);
            foreach (var (path, method) in operations)
            {
                var body = method is "POST" or "PUT" or "PATCH" ? "{}" : string.Empty;

                async Task<(HttpStatusCode Status, string Body)> CallAsync(Guid siteId)
                {
                    var response = await lonely.SendRawAsync(MethodOf(method), Fill(path, siteId), body);
                    var text = await response.Content.ReadAsStringAsync();
                    return (response.StatusCode, text.Length == 0 ? text : AuthTestHelpers.WithoutTraceId(JsonDocument.Parse(text).RootElement));
                }

                var notAssigned = await CallAsync(outsider.Id);
                var unknown = await CallAsync(Guid.NewGuid());
                if (notAssigned != unknown)
                {
                    different.Add($"{role} {method} {path} : chantier non affecte {(int)notAssigned.Status} / inconnu {(int)unknown.Status}");
                }

                notFound += notAssigned.Status == HttpStatusCode.NotFound ? 1 : 0;
                if (notAssigned.Status is not (HttpStatusCode.NotFound or HttpStatusCode.Forbidden))
                {
                    neither404Nor403.Add($"{role} {method} {path} : {(int)notAssigned.Status}");
                }
            }
        }

        Assert.Multiple(() =>
        {
            Assert.That(operations, Has.Count.GreaterThanOrEqualTo(30), "le balayage lit bien les routes du contrat");
            Assert.That(different, Is.Empty, "reponse differente entre un chantier non affecte et un chantier inconnu : " + string.Join(" ; ", different));
            Assert.That(neither404Nor403, Is.Empty, "une route de chantier repond autre chose que 404 (ou 403 sans le droit) : " + string.Join(" ; ", neither404Nor403));
            Assert.That(notFound, Is.GreaterThanOrEqualTo(operations.Count), "chaque route a ete essayee avec un role qui y a droit : au moins une reponse 404 par route");
        });
    }

    [Test]
    public async Task Every_route_of_the_contract_refuses_an_anonymous_caller_except_the_documented_public_ones()
    {
        var publicRoutes = new[] { "/api/v1/auth/login", "/api/v1/auth/refresh", "/api/v1/auth/web/login", "/api/v1/auth/web/refresh", "/api/v1/auth/logout", "/health", "/api/v1/auth/web/logout" };
        using var client = Factory.CreateClient();
        var open = new List<string>();
        var checkedRoutes = 0;

        foreach (var (path, method) in Operations((path, _) => path.StartsWith("/api/v1/", StringComparison.Ordinal) && !publicRoutes.Any(route => path.StartsWith(route, StringComparison.Ordinal))))
        {
            using var request = new HttpRequestMessage(MethodOf(method), Fill(path, Site.Id));
            if (method is "POST" or "PUT")
            {
                request.Content = new StringContent("{}", System.Text.Encoding.UTF8, "application/json");
            }

            var response = await client.SendAsync(request);
            checkedRoutes++;
            if (response.StatusCode != HttpStatusCode.Unauthorized)
            {
                open.Add($"{method} {path} : {(int)response.StatusCode}");
            }
        }

        Assert.Multiple(() =>
        {
            Assert.That(checkedRoutes, Is.GreaterThanOrEqualTo(60));
            Assert.That(open, Is.Empty, "routes accessibles sans jeton : " + string.Join(" ; ", open));
        });
    }

    [Test]
    public async Task No_route_and_no_synchronisation_shows_a_price_to_the_field_or_a_supplier_phone_to_those_who_may_not_see_it()
    {
        var site = await NewSiteAsync();
        var requestId = await OrderedRequestAsync(600m, siteId: site.Id);
        var delivery = await DeliverAsync(requestId, 10m, "t", siteId: site.Id, note: "BL-QA-1");
        var jpeg = Jpeg(7);
        var photo = await (await Chef.PostAsync(PhotosUrl(site.Id, delivery.Id()), new { clientId = Guid.NewGuid(), takenAt = "2026-11-25T08:10:00Z", contentType = "image/jpeg", sizeBytes = jpeg.Length, sha256 = Sha256Hex(jpeg) })).JsonAsync();
        Assert.That((await Chef.PutBytesAsync(PhotoContentUrl(site.Id, photo.Id()), jpeg)).StatusCode, Is.EqualTo(HttpStatusCode.OK));
        await Chef.PostAsync($"{DeliveryUrl(site.Id, delivery.Id())}/cancel", new { reasonCode = "DoubleEntry" });
        await Achats.PutAsync(OrderUrl(site.Id, requestId), new { version = (await ReadRequestAsync(requestId, Achats, site.Id)).GetProperty("order").Version(), unitPrice = 800m, purchaseOrderNumber = "BC-QA-9" });

        var known = new Dictionary<string, Guid>
        {
            ["requestId"] = requestId,
            ["deliveryId"] = delivery.Id(),
            ["photoId"] = photo.Id(),
            ["productId"] = CementId,
            ["supplierId"] = SupplierId,
        };
        var routes = Operations((path, method) => method == "GET" && path.StartsWith("/api/v1/", StringComparison.Ordinal) && !path.Contains("/sync/", StringComparison.Ordinal)
            && System.Text.RegularExpressions.Regex.Matches(path, "\\{(\\w+)\\}").Select(match => match.Groups[1].Value).All(token => token == "siteId" || known.ContainsKey(token))
            && (path.Contains("/requests", StringComparison.Ordinal) || path.Contains("/deliveries", StringComparison.Ordinal) || path.Contains("/photos", StringComparison.Ordinal)
                || path.Contains("/follow-up", StringComparison.Ordinal) || path.Contains("/suppliers", StringComparison.Ordinal) || path.Contains("/products", StringComparison.Ordinal)
                || path.Contains("/settings", StringComparison.Ordinal))).ToList();

        string[] priceWords = ["commercial", "unitPrice", "orderedAmount", "receivedValue", "purchaseOrderNumber", "BC-2026-044", "BC-QA-9", "\"amount\""];
        string[] phoneWords = [FieldPhone, "0550000021", "\"phone\""];
        var leaks = new List<string>();
        var fetched = 0;

        async Task ScanAsync(string role, ApiSession session, bool pricesAllowed, bool phoneAllowed)
        {
            foreach (var (path, _) in routes)
            {
                var response = await session.GetAsync(Fill(path, site.Id, known));
                fetched++;
                if (response.Content.Headers.ContentType?.MediaType?.Contains("json", StringComparison.OrdinalIgnoreCase) != true)
                {
                    continue;
                }

                var text = await response.Content.ReadAsStringAsync();
                leaks.AddRange(priceWords.Where(word => !pricesAllowed && text.Contains(word, StringComparison.Ordinal)).Select(word => $"{role} {path} : « {word} »"));
                leaks.AddRange(phoneWords.Where(word => !phoneAllowed && text.Contains(word, StringComparison.Ordinal)).Select(word => $"{role} {path} : « {word} »"));
            }

            // Synchronisation : aucun prix ni telephone pour AUCUN role (formes sans champ commercial, fournisseur sans telephone).
            var (changes, _, _) = await session.PullAllAsync();
            var pulled = string.Join('\n', changes.Select(change => change.GetRawText()));
            leaks.AddRange(priceWords.Concat(phoneWords).Where(word => pulled.Contains(word, StringComparison.Ordinal)).Select(word => $"{role} sync/changes : « {word} »"));
        }

        await ScanAsync("ChefChantier", Chef, pricesAllowed: false, phoneAllowed: true);
        await ScanAsync("ChefEquipe", Equipe, pricesAllowed: false, phoneAllowed: false);
        await ScanAsync("Direction", Direction, pricesAllowed: true, phoneAllowed: false);
        await ScanAsync("Achats", Achats, pricesAllowed: true, phoneAllowed: true);
        await ScanAsync("Conducteur", Conducteur, pricesAllowed: true, phoneAllowed: true);
        var photoForTeam = await Equipe.GetAsync(PhotoContentUrl(site.Id, photo.Id()));
        var photoForChef = await Chef.GetAsync(PhotoContentUrl(site.Id, photo.Id()));

        Assert.Multiple(() =>
        {
            Assert.That(routes, Has.Count.GreaterThanOrEqualTo(12), "le balayage lit bien les routes de lecture du contrat");
            Assert.That(fetched, Is.GreaterThanOrEqualTo(40));
            Assert.That(leaks, Is.Empty, string.Join(" ; ", leaks));
            Assert.That(photoForTeam.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "le chef d'equipe ne voit pas la photo du bon");
            Assert.That(photoForChef.StatusCode, Is.EqualTo(HttpStatusCode.OK), "le chef de chantier la voit (Q-MAT-03)");
        });
    }

    // --- Requetes SQL : pas de N+1 (R2-14) ------------------------------------------------------------

    private static async Task<int> SqlCountOfAsync(ChantierWebApplicationFactory counting, ApiSession session, string url)
    {
        await session.GetAsync(url);
        var before = counting.Logs.Entries.Count(entry => entry.Contains("Microsoft.EntityFrameworkCore.Database.Command: Executed DbCommand", StringComparison.Ordinal));
        var response = await session.GetAsync(url);
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), url);
        return counting.Logs.Entries.Count(entry => entry.Contains("Microsoft.EntityFrameworkCore.Database.Command: Executed DbCommand", StringComparison.Ordinal)) - before;
    }

    [Test]
    public async Task The_lists_run_the_same_few_sql_commands_for_five_lines_or_fifty_and_never_one_per_line()
    {
        // Hote derive de celui de la classe (meme base, meme cle) qui journalise les commandes SQL d'EF (Warning par defaut).
        await using var counting = new CountingFactory(Factory);
        var conductor = await counting.SignInAsync(RoleNames.ConducteurTravaux);
        var chef = await counting.SignInAsync(RoleNames.ChefChantier);
        var site = await counting.SeedSiteAsync(members: [conductor.Account.Id, chef.Account.Id]);
        for (var index = 0; index < 40; index++)
        {
            var id = await chef.NewRequestIdAsync(site.Id, index % 2 == 0 ? CementId : SteelId, 10m + index, index % 2 == 0 ? "sac" : "t");
            if (index < 25)
            {
                await conductor.PostAsync($"{RequestUrl(site.Id, id)}/approve");
            }
        }

        var small = await SqlCountOfAsync(counting.Factory, conductor, $"{RequestsUrl(site.Id)}?pageSize=5");
        var big = await SqlCountOfAsync(counting.Factory, conductor, $"{RequestsUrl(site.Id)}?pageSize=50");
        var crossSite = await SqlCountOfAsync(counting.Factory, conductor, "/api/v1/requests?pageSize=50");
        var deliveries = await SqlCountOfAsync(counting.Factory, chef, $"{DeliveriesUrl(site.Id)}?pageSize=50");

        TestContext.Out.WriteLine($"MESURE SQL : demandes 5 lignes={small} ; 50 lignes={big} ; transversale={crossSite} ; livraisons={deliveries}");
        Assert.Multiple(() =>
        {
            Assert.That(small, Is.GreaterThan(0), "le compteur lit bien les commandes SQL (sinon le test ne prouve rien)");
            Assert.That(big, Is.LessThanOrEqualTo(12), "au plus 12 commandes SQL pour une page de 40 demandes");
            Assert.That(big, Is.LessThanOrEqualTo(small + 1), "le nombre de commandes ne croit pas avec la taille de la page : pas de N+1");
            Assert.That(crossSite, Is.GreaterThan(0).And.LessThanOrEqualTo(12));
            Assert.That(deliveries, Is.GreaterThan(0).And.LessThanOrEqualTo(12));
        });
    }

    /// <summary>Hote de test derive : memes reglages et meme base que celui de la classe, avec le journal des commandes SQL d'EF au niveau Information.</summary>
    private sealed class CountingFactory : IAsyncDisposable
    {
        public CountingFactory(ChantierWebApplicationFactory parent)
        {
            Factory = new ChantierWebApplicationFactory();
            foreach (var (key, value) in parent.Settings)
            {
                Factory.Settings[key] = value;
            }

            Factory.Settings["Logging:LogLevel:Microsoft.EntityFrameworkCore.Database.Command"] = "Information";
        }

        public ChantierWebApplicationFactory Factory { get; }

        public ValueTask DisposeAsync() => Factory.DisposeAsync();

        public static implicit operator ChantierWebApplicationFactory(CountingFactory value) => value.Factory;

        public Task<ApiSession> SignInAsync(string role) => Factory.SignInAsync(role);

        public Task<SeededSite> SeedSiteAsync(params Guid[] members) => Factory.SeedSiteAsync(members: members);
    }

    // --- D-1 apres correction : le cumul recu et la synchronisation ne depassent jamais la colonne -----

    [Test]
    public async Task The_received_value_stops_exactly_at_the_column_limit_with_a_422_and_never_a_server_error()
    {
        var site = await NewSiteAsync();
        var id = await Chef.NewRequestIdAsync(site.Id, SteelId, 1_000_000_000m, "kg");
        Assert.That((await Conducteur.PostAsync($"{RequestUrl(site.Id, id)}/approve")).StatusCode, Is.EqualTo(HttpStatusCode.OK));
        Assert.That((await Achats.PostAsync(OrderUrl(site.Id, id), OrderBody(SupplierId, 9_999_999.99m))).StatusCode, Is.EqualTo(HttpStatusCode.Created));

        var first = await Chef.PostAsync(DeliveriesUrl(site.Id), DeliveryBody(id, 1_000_000_000m, "kg", Factory.Today(), SupplierId));
        // 9 999 999 990 000 000,00 + 1 kg x 9 999 999,99 = 9 999 999 999 999 999,99 : exactement la capacite de la colonne.
        var exactlyAtTheLimit = await Chef.PostAsync(DeliveriesUrl(site.Id), DeliveryBody(id, 1m, "kg", Factory.Today(), SupplierId));
        var overTheLimit = await Chef.PostAsync(DeliveriesUrl(site.Id), DeliveryBody(id, 2m, "kg", Factory.Today(), SupplierId));
        var overBody = await overTheLimit.Content.ReadAsStringAsync();
        var firstBody = await first.Content.ReadAsStringAsync();
        var detail = await ReadRequestAsync(id, Achats, site.Id);

        Assert.Multiple(() =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created), firstBody);
            Assert.That(exactlyAtTheLimit.StatusCode, Is.EqualTo(HttpStatusCode.Created), "valeur recue egale a la capacite : acceptee");
            Assert.That((int)overTheLimit.StatusCode, Is.EqualTo(422), overBody);
            Assert.That(ProblemCode(overBody), Is.EqualTo("QUANTITE_INVALIDE"));
            Assert.That(detail.GetProperty("deliveries").GetArrayLength(), Is.EqualTo(2), "la livraison refusee n'a rien ecrit");
            Assert.That(detail.StatusOf(), Is.EqualTo("Delivered"));
        });
    }

    [Test]
    public async Task An_oversized_delivery_sent_from_the_phone_is_rejected_with_its_code_and_the_rest_of_the_batch_goes_through()
    {
        var site = await NewSiteAsync();
        var id = await Chef.NewRequestIdAsync(site.Id, SteelId, 1_000_000_000m, "kg");
        Assert.That((await Conducteur.PostAsync($"{RequestUrl(site.Id, id)}/approve")).StatusCode, Is.EqualTo(HttpStatusCode.OK));
        Assert.That((await Achats.PostAsync(OrderUrl(site.Id, id), OrderBody(SupplierId, 9_999_999.99m))).StatusCode, Is.EqualTo(HttpStatusCode.Created));
        var oversized = Guid.NewGuid();
        var normal = Guid.NewGuid();

        var response = await Chef.PostAsync(PushUrl, new
        {
            operations = new[]
            {
                DeliveryCreate(oversized, site.Id, id, 1_000_000_000m, "t", Iso(Factory.Today()), SupplierId),
                DeliveryCreate(normal, site.Id, id, 1m, "t", Iso(Factory.Today()), SupplierId),
            },
        });
        var results = (await response.JsonAsync()).GetProperty("results");

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(results[0].GetProperty("status").GetString(), Is.EqualTo("rejected"), results[0].GetRawText());
            Assert.That(results[0].GetProperty("code").GetString(), Is.EqualTo("QUANTITE_INVALIDE"));
            Assert.That(results[1].GetProperty("status").GetString(), Is.EqualTo("applied"), "le reste du lot passe");
        });
    }

    [Test]
    public async Task A_pull_never_carries_the_reset_flag_for_an_up_to_date_phone_nor_for_a_first_pull()
    {
        var site = await NewSiteAsync();
        await Chef.NewRequestIdAsync(site.Id, CementId);

        var (first, _, cursor) = await Chef.PullAllAsync(siteId: site.Id);
        var firstPage = await Chef.PullAsync(null, site.Id);
        var idle = await Chef.PullAsync(cursor, site.Id);
        await Chef.NewRequestIdAsync(site.Id, CementId);
        var afterChange = await Chef.PullAsync(cursor, site.Id);

        bool Flag(JsonElement page) => page.TryGetProperty("resetRequired", out var value) && value.ValueKind == JsonValueKind.True;
        Assert.Multiple(() =>
        {
            Assert.That(first, Is.Not.Empty);
            Assert.That(Flag(firstPage), Is.False, "since vide : jamais de signal (un pull complet le voit forcement)");
            Assert.That(Flag(idle), Is.False, "telephone a jour : jamais de signal");
            Assert.That(Flag(afterChange), Is.False, "changement recent dans la fenetre : pas de signal");
            Assert.That(afterChange.GetProperty("changes").GetArrayLength(), Is.GreaterThan(0));
        });
    }

    // --- Horloge du telephone fausse, reprise apres plusieurs jours ----------------------------------

    [Test]
    public async Task A_phone_clock_in_2099_or_1999_changes_neither_the_server_dates_nor_the_order_of_the_numbers()
    {
        var site = await NewSiteAsync();
        var future = Guid.NewGuid();
        var past = Guid.NewGuid();
        var today = Factory.Time.GetUtcNow();

        var response = await Chef.PostAsync(PushUrl, new
        {
            operations = new[]
            {
                RequestCreate(future, site.Id, CementId, overrides: payload => payload["clientCreatedAt"] = "2099-01-01T00:00:00Z"),
                RequestCreate(past, site.Id, CementId, overrides: payload => payload["clientCreatedAt"] = "1999-01-01T00:00:00Z"),
            },
        });
        var results = (await response.JsonAsync()).GetProperty("results");
        var first = results[0].Resource();
        var second = results[1].Resource();

        Assert.Multiple(() =>
        {
            Assert.That(results[0].GetProperty("status").GetString(), Is.EqualTo("applied"));
            Assert.That(results[1].GetProperty("status").GetString(), Is.EqualTo("applied"));
            Assert.That(first.GetProperty("number").GetString(), Is.EqualTo("DEM-001"), "le numero suit l'ordre d'arrivee, pas l'heure du telephone");
            Assert.That(second.GetProperty("number").GetString(), Is.EqualTo("DEM-002"));
            Assert.That(first.GetProperty("createdAt").GetDateTimeOffset(), Is.EqualTo(today).Within(TimeSpan.FromMinutes(5)), "l'heure du serveur fait foi");
            Assert.That(second.GetProperty("createdAt").GetDateTimeOffset(), Is.EqualTo(today).Within(TimeSpan.FromMinutes(5)));
        });
    }

    [Test]
    public async Task Three_days_without_network_twenty_requests_and_five_deliveries_arrive_once_and_a_replay_changes_nothing()
    {
        var site = await NewSiteAsync();
        var requestClients = Enumerable.Range(0, 20).Select(_ => Guid.NewGuid()).ToList();
        var deliveryClients = Enumerable.Range(0, 5).Select(_ => Guid.NewGuid()).ToList();
        var threeDaysAgo = Iso(Factory.Today().AddDays(-3));
        var operations = requestClients
            .Select((client, index) => RequestCreate(client, site.Id, CementId, 10m + index, "sac", overrides: payload => payload["clientCreatedAt"] = Factory.Time.GetUtcNow().AddDays(-3).AddMinutes(index).ToString("O")))
            .Concat(deliveryClients.Select((client, index) => DeliveryCreate(client, site.Id, null, 1m + index, "t", threeDaysAgo, requestClientId: requestClients[index], overrides: payload => payload["freeSupplierName"] = "Fournisseur libre")))
            .ToList();

        var first = await (await Chef.PostAsync(PushUrl, new { operations })).JsonAsync();
        var replay = await (await Chef.PostAsync(PushUrl, new { operations })).JsonAsync();
        var firstResults = first.GetProperty("results").EnumerateArray().ToList();
        var replayResults = replay.GetProperty("results").EnumerateArray().ToList();
        var requests = await (await Chef.GetAsync($"{RequestsUrl(site.Id)}?pageSize=100")).JsonAsync();
        var deliveries = await (await Chef.GetAsync($"{DeliveriesUrl(site.Id)}?pageSize=100")).JsonAsync();
        var numbers = requests.GetProperty("items").EnumerateArray().Select(item => item.Number()).OrderBy(number => number).ToList();

        Assert.Multiple(() =>
        {
            Assert.That(firstResults.Select(result => result.GetProperty("status").GetString()), Is.All.EqualTo("applied"), string.Join(" | ", firstResults.Where(result => result.GetProperty("status").GetString() != "applied").Select(result => result.GetRawText())));
            Assert.That(replayResults.Select(result => result.GetProperty("status").GetString()), Is.All.EqualTo("duplicate"), "le renvoi du lot entier ne cree rien");
            Assert.That(requests.GetProperty("totalCount").GetInt32(), Is.EqualTo(20));
            Assert.That(deliveries.GetProperty("totalCount").GetInt32(), Is.EqualTo(5));
            Assert.That(numbers, Is.EqualTo(Enumerable.Range(1, 20).Select(index => $"DEM-{index:000}")), "numeros sans trou, dans l'ordre d'arrivee");
            Assert.That(firstResults.Take(20).Select(result => result.Resource().GetProperty("number").GetString()), Is.EqualTo(replayResults.Take(20).Select(result => result.Resource().GetProperty("number").GetString())), "meme reponse au renvoi");
        });
    }

    [Test]
    public async Task A_delivery_dated_tomorrow_by_a_fast_phone_is_rejected_with_its_code_and_a_delivery_from_five_days_ago_is_applied()
    {
        var site = await NewSiteAsync();
        var tomorrow = Guid.NewGuid();
        var old = Guid.NewGuid();

        var response = await Chef.PostAsync(PushUrl, new
        {
            operations = new[]
            {
                DeliveryCreate(tomorrow, site.Id, null, 1m, "t", Iso(Factory.Today().AddDays(1)), overrides: Free),
                DeliveryCreate(old, site.Id, null, 1m, "t", Iso(Factory.Today().AddDays(-5)), overrides: Free),
            },
        });
        var results = (await response.JsonAsync()).GetProperty("results");
        var list = await (await Chef.GetAsync(DeliveriesUrl(site.Id))).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(results[0].GetProperty("status").GetString(), Is.EqualTo("rejected"), results[0].GetRawText());
            Assert.That(results[0].GetProperty("code").GetString(), Is.EqualTo("DATE_INVALIDE"), "motif lisible dans « A verifier », jamais perdu en silence");
            Assert.That(results[1].GetProperty("status").GetString(), Is.EqualTo("applied"));
            Assert.That(list.GetProperty("totalCount").GetInt32(), Is.EqualTo(1));
        });
    }

    private static void Free(Dictionary<string, object?> payload)
    {
        payload["freeSupplierName"] = "Fournisseur libre";
        payload["freeProductName"] = "Gravier libre";
    }

    // --- Role sans droit ----------------------------------------------------------------------------

    [Test]
    public async Task A_team_leader_cannot_validate_reject_order_settle_archive_or_receive_and_nothing_is_written()
    {
        var site = await NewSiteAsync();
        var requested = await Chef.NewRequestIdAsync(site.Id, CementId);
        var ordered = await OrderedRequestAsync(600m, siteId: site.Id);
        var url = (Guid id, string action) => $"{RequestUrl(site.Id, id)}/{action}";

        var attempts = new Dictionary<string, HttpResponseMessage>
        {
            ["approve"] = await Equipe.PostAsync(url(requested, "approve")),
            ["reject"] = await Equipe.PostAsync(url(requested, "reject"), new { reasonCode = "OverBudget" }),
            ["order"] = await Equipe.PostAsync(OrderUrl(site.Id, ordered), OrderBody(SupplierId)),
            ["settle"] = await Equipe.PostAsync(url(ordered, "settle"), new { reasonCode = "QuantitySufficient" }),
            ["archive"] = await Equipe.PostAsync(url(requested, "archive")),
            ["receive"] = await Equipe.PostAsync(url(ordered, "receive")),
            ["batch"] = await Equipe.PostAsync($"{RequestsUrl(site.Id)}/batch/approve", new { requestIds = new[] { requested } }),
            ["delivery"] = await Equipe.PostAsync(DeliveriesUrl(site.Id), DeliveryBody(ordered, 1m, "t", Factory.Today(), SupplierId)),
        };
        var requestedAfter = await ReadRequestAsync(requested, siteId: site.Id);
        var events = await Factory.EventsOfAsync(requested);

        Assert.Multiple(() =>
        {
            foreach (var (name, response) in attempts)
            {
                Assert.That((int)response.StatusCode, Is.EqualTo(403), $"{name} : INTERDIT");
            }

            Assert.That(requestedAfter.StatusOf(), Is.EqualTo("Requested"));
            Assert.That(events.Select(item => item.Type.ToString()), Is.EqualTo(new[] { "Created" }));
        });
    }
}
