using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>B6, livraisons (CT-MAT-08 a 11, 14, 15) : creation, conversions, recalcul dans les deux sens, fait de chantier, correction, annulation, rattachement, droits.</summary>
[TestFixture]
public class DeliveryTests : DeliveryFixtureBase
{
    // --- Creation, statut calcule (CT-MAT-08, 09) ---

    [Test]
    public async Task A_partial_delivery_in_tonnes_is_converted_into_the_unit_of_the_order()
    {
        var id = await OrderedRequestAsync(600m);

        var delivery = await DeliverAsync(id, 10m, "t", note: "bl-4471");
        var request = await ReadRequestAsync(id);

        Assert.Multiple(() =>
        {
            Assert.That(delivery.GetProperty("number").GetString(), Does.Match(@"^LIV-\d{3,}$"));
            Assert.That(delivery.GetProperty("quantityInRequestUnit").GetProperty("value").GetDecimal(), Is.EqualTo(200m), "10 T = 200 sacs de 50 kg");
            Assert.That(delivery.GetProperty("quantityInRequestUnit").GetProperty("unit").GetString(), Is.EqualTo("sac"));
            Assert.That(delivery.GetProperty("deliveryNoteNumber").GetString(), Is.EqualTo("BL-4471"), "majuscules");
            Assert.That(delivery.GetProperty("requestId").GetGuid(), Is.EqualTo(id));
            Assert.That(delivery.Property("unattachedReason"), Is.Null);
            Assert.That(request.StatusOf(), Is.EqualTo("PartiallyDelivered"));
            Assert.That(request.Received(), Is.EqualTo(200m));
            Assert.That(request.GetProperty("remainingQuantity").GetProperty("value").GetDecimal(), Is.EqualTo(400m));
            Assert.That(request.GetProperty("variance").GetProperty("value").GetDecimal(), Is.EqualTo(-400m));
            Assert.That(request.GetProperty("deliveries").GetArrayLength(), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task Three_deliveries_complete_the_request_and_cancelling_the_last_goes_back_one_step()
    {
        var id = await OrderedRequestAsync(600m);
        await DeliverAsync(id, 10m, "t");
        await DeliverAsync(id, 10m, "t");
        var third = await DeliverAsync(id, 10m, "t");

        Assert.That((await ReadRequestAsync(id)).StatusOf(), Is.EqualTo("Delivered"), "600 sacs recus");

        var cancel = await Chef.PostAsync($"{DeliveryUrl(Site.Id, third.Id())}/cancel", new { reasonCode = "QuantityError" });
        var request = await ReadRequestAsync(id);
        var recomputed = request.GetProperty("history").EnumerateArray().Where(item => item.GetProperty("type").GetString() == "StatusRecomputed").ToList();

        Assert.Multiple(() =>
        {
            Assert.That(cancel.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(request.StatusOf(), Is.EqualTo("PartiallyDelivered"), "recalcul dans les deux sens");
            Assert.That(request.Received(), Is.EqualTo(400m));
            Assert.That(recomputed.Select(item => item.GetProperty("toStatus").GetString()), Is.EqualTo(new[] { "PartiallyDelivered", "Delivered", "PartiallyDelivered" }));
            Assert.That(recomputed.Last().GetProperty("reasonCode").GetString(), Is.EqualTo("DeliveryCancelled"));
            Assert.That(recomputed.Last().GetProperty("reasonNote").GetString(), Is.EqualTo(third.GetProperty("number").GetString()), "la livraison a l'origine du recalcul");
            Assert.That(request.GetProperty("deliveries").GetArrayLength(), Is.EqualTo(3), "la livraison annulee reste visible");
        });
    }

    [Test]
    public async Task Cancelling_every_delivery_goes_back_to_ordered()
    {
        var id = await OrderedRequestAsync(100m);
        var only = await DeliverAsync(id, 100m, "sac");
        Assert.That((await ReadRequestAsync(id)).StatusOf(), Is.EqualTo("Delivered"));

        await Chef.PostAsync($"{DeliveryUrl(Site.Id, only.Id())}/cancel", new { reasonCode = "DoubleEntry" });
        var request = await ReadRequestAsync(id);

        Assert.Multiple(() =>
        {
            Assert.That(request.StatusOf(), Is.EqualTo("Ordered"));
            Assert.That(request.Received(), Is.Zero);
        });
    }

    [Test]
    public async Task A_surplus_makes_the_request_delivered_with_a_positive_variance()
    {
        var id = await OrderedRequestAsync(20m, "t", productId: CementId);
        await DeliverAsync(id, 20.4m, "t");

        var request = await ReadRequestAsync(id);

        Assert.Multiple(() =>
        {
            Assert.That(request.StatusOf(), Is.EqualTo("Delivered"));
            Assert.That(request.GetProperty("variance").GetProperty("value").GetDecimal(), Is.EqualTo(0.4m));
            Assert.That(request.GetProperty("variance").GetProperty("percent").GetDecimal(), Is.EqualTo(2.00m));
            Assert.That(request.GetProperty("remainingQuantity").GetProperty("value").GetDecimal(), Is.Zero);
        });
    }

    [Test]
    public async Task Sand_ordered_in_cubic_metres_cannot_be_received_in_tonnes()
    {
        var id = await OrderedRequestAsync(24m, "m3", productId: SandId);

        var response = await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 10m, "t", Factory.Today(), SupplierId));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo("UNITES_INCOMPATIBLES"));
            Assert.That((await ReadRequestAsync(id)).StatusOf(), Is.EqualTo("Ordered"), "rien d'ecrit");
            Assert.That(await Factory.LiveDeliveriesAsync(id), Is.Empty);
        });
    }

    [Test]
    public async Task The_delivery_fields_are_validated()
    {
        var id = await OrderedRequestAsync(600m);
        var today = Factory.Today();

        var results = new Dictionary<string, (HttpResponseMessage Response, HttpStatusCode Status, string Code)>
        {
            ["sans unite"] = (await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 10m, null, today, SupplierId)), HttpStatusCode.UnprocessableEntity, "UNITE_OBLIGATOIRE"),
            ["quantite nulle"] = (await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 0m, "t", today, SupplierId)), HttpStatusCode.UnprocessableEntity, "QUANTITE_INVALIDE"),
            ["sac decimal"] = (await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 2.5m, "sac", today, SupplierId)), HttpStatusCode.UnprocessableEntity, "QUANTITE_ENTIERE_REQUISE"),
            ["demain"] = (await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 10m, "t", today.AddDays(1), SupplierId)), HttpStatusCode.BadRequest, "DATE_INVALIDE"),
            ["date absente"] = (await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 10m, "t", today, SupplierId, overrides: body => body["deliveryDate"] = null)), HttpStatusCode.BadRequest, "DATE_INVALIDE"),
            ["fournisseur absent"] = (await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 10m, "t", today, null, overrides: body => body.Remove("supplierId"))), HttpStatusCode.OK, "unused"),
            ["BL trop long"] = (await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 10m, "t", today, SupplierId, note: new string('x', 31))), HttpStatusCode.BadRequest, "VALIDATION"),
            ["reserve sans motif"] = (await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 10m, "t", today, SupplierId, overrides: body => body["conformity"] = "WithReserve")), HttpStatusCode.BadRequest, "VALIDATION"),
            ["reserve Autre sans remarque"] = (await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 10m, "t", today, SupplierId, overrides: body => { body["conformity"] = "WithReserve"; body["reserveReasonCode"] = "Other"; })), HttpStatusCode.BadRequest, "VALIDATION"),
        };

        Assert.Multiple(async () =>
        {
            foreach (var (name, (response, status, code)) in results.Where(entry => entry.Key != "fournisseur absent"))
            {
                Assert.That(response.StatusCode, Is.EqualTo(status), name);
                Assert.That(await CodeOf(response), Is.EqualTo(code), name);
            }

            // Le fournisseur de la commande est repris quand il n'est pas precise.
            Assert.That(results["fournisseur absent"].Response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
        });
    }

    [Test]
    public async Task A_delivery_older_than_the_request_is_accepted_and_a_reserve_is_recorded()
    {
        var id = await OrderedRequestAsync(600m);

        var json = await DeliverAsync(id, 10m, "t", date: Factory.Today().AddDays(-30), overrides: body =>
        {
            body["conformity"] = "WithReserve";
            body["reserveReasonCode"] = "DamagedProduct";
        });

        Assert.Multiple(() =>
        {
            Assert.That(json.GetProperty("conformity").GetString(), Is.EqualTo("WithReserve"));
            Assert.That(json.GetProperty("reserve").GetProperty("code").GetString(), Is.EqualTo("DamagedProduct"));
        });
    }

    [Test]
    public async Task The_product_is_the_one_of_the_request_and_another_one_is_refused()
    {
        var id = await OrderedRequestAsync(600m);

        var other = await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 10m, "t", Factory.Today(), SupplierId, productId: SteelId));
        var same = await DeliverAsync(id, 10m, "t", productId: CementId);

        Assert.Multiple(async () =>
        {
            Assert.That(await CodeOf(other), Is.EqualTo("PRODUIT_DIFFERENT"));
            Assert.That(same.GetProperty("product").GetProperty("productId").GetGuid(), Is.EqualTo(CementId));
        });
    }

    // --- Fait de chantier (CT-MAT-10) ---

    [Test]
    public async Task A_delivery_is_never_refused_because_of_the_status_of_the_request()
    {
        var results = new List<(string Name, string Reason, string? RequestId)>();
        foreach (var status in new[] { RequestStatus.Requested, RequestStatus.Rejected, RequestStatus.Cancelled, RequestStatus.Received })
        {
            var id = await Chef.NewRequestIdAsync(Site.Id, CementId);
            await Factory.SetStatusAsync(id, status);

            var delivery = await DeliverAsync(id, 10m, "t");
            results.Add((status.ToString(), delivery.Property("unattachedReason") ?? "-", delivery.Property("requestId")));
        }

        var noRequest = await DeliverAsync(null, 10m, "t", productId: CementId);

        Assert.Multiple(() =>
        {
            Assert.That(results.Select(result => result.Reason), Is.All.EqualTo("RequestNotOpen"));
            Assert.That(results.Select(result => result.RequestId), Is.All.Null, "non rattachee");
            Assert.That(noRequest.GetProperty("unattachedReason").GetString(), Is.EqualTo("NoRequestChosen"));
            Assert.That(noRequest.Property("quantityInRequestUnit"), Is.Null);
        });
    }

    [Test]
    public async Task A_delivery_before_the_order_is_retained_and_taken_into_account_when_the_order_is_placed()
    {
        var id = await ValidatedAsync(600m);

        var delivery = await DeliverAsync(id, 10m, "t");
        var retained = await ReadRequestAsync(id);

        Assert.Multiple(() =>
        {
            Assert.That(delivery.GetProperty("requestId").GetGuid(), Is.EqualTo(id), "retenue : rattachee");
            Assert.That(retained.StatusOf(), Is.EqualTo("Validated"), "la demande reste validee");
            Assert.That(retained.GetProperty("hasDeliveryWithoutOrder").GetBoolean(), Is.True);
            Assert.That(retained.Received(), Is.EqualTo(200m));
        });

        var order = await Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId, 780m));
        var json = await order.JsonAsync();
        var types = json.GetProperty("history").EnumerateArray().Select(item => item.GetProperty("type").GetString()).ToList();
        var recomputed = json.GetProperty("history").EnumerateArray().Single(item => item.GetProperty("type").GetString() == "StatusRecomputed");

        Assert.Multiple(() =>
        {
            Assert.That(json.StatusOf(), Is.EqualTo("PartiallyDelivered"));
            Assert.That(types, Is.SupersetOf(new[] { "Ordered", "StatusRecomputed" }), "deux evenements");
            Assert.That(recomputed.GetProperty("fromStatus").GetString(), Is.EqualTo("Ordered"));
            Assert.That(json.GetProperty("hasDeliveryWithoutOrder").GetBoolean(), Is.False);
            Assert.That(json.GetProperty("order").GetProperty("commercial").GetProperty("receivedValue").GetDecimal(), Is.EqualTo(156000.00m), "200 sacs x 780");
        });
    }

    [Test]
    public async Task A_retained_delivery_blocks_the_cancellation_of_the_request()
    {
        var id = await ValidatedAsync(600m);
        await DeliverAsync(id, 10m, "t");

        var response = await Conducteur.PostAsync($"{RequestUrl(Site.Id, id)}/cancel", new { reasonCode = "EntryError" });

        Assert.That(await CodeOf(response), Is.EqualTo("TRANSITION_INTERDITE"));
    }

    [Test]
    public async Task A_delivery_for_a_request_of_another_site_is_not_found()
    {
        var other = await NewSiteAsync();
        var foreign = await Chef.NewRequestIdAsync(other.Id, CementId);

        var response = await Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(foreign, 10m, "t", Factory.Today(), SupplierId));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
    }

    // --- Doublons, idempotence, concurrence ---

    [Test]
    public async Task The_same_client_id_gives_the_same_delivery_and_the_same_number()
    {
        var id = await OrderedRequestAsync(600m);
        var clientId = Guid.NewGuid();
        var body = DeliveryBody(id, 10m, "t", Factory.Today(), SupplierId, clientId: clientId);

        var first = await Chef.PostAsync(DeliveriesUrl(Site.Id), body);
        var again = await Chef.PostAsync(DeliveriesUrl(Site.Id), body);

        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await again.JsonAsync()).Id(), Is.EqualTo((await first.JsonAsync()).Id()));
            Assert.That(await Factory.LiveDeliveriesAsync(id), Has.Count.EqualTo(1));
            Assert.That((await ReadRequestAsync(id)).Received(), Is.EqualTo(200m), "pas compte deux fois");
        });
    }

    [Test]
    public async Task Simultaneous_deliveries_are_all_recorded_without_duplicate_or_gap_in_the_numbers()
    {
        var site = await NewSiteAsync();
        var id = await OrderedRequestAsync(1000m, siteId: site.Id);

        var responses = await Task.WhenAll(Enumerable.Range(0, 12).Select(_ =>
            Chef.PostAsync(DeliveriesUrl(site.Id), DeliveryBody(id, 10m, "sac", Factory.Today(), SupplierId))));
        var numbers = (await Task.WhenAll(responses.Select(async response => (await response.JsonAsync()).GetProperty("number").GetString()!))).Order().ToList();

        Assert.Multiple(async () =>
        {
            Assert.That(responses.Select(response => response.StatusCode), Is.All.EqualTo(HttpStatusCode.Created));
            Assert.That(numbers, Is.EqualTo(Enumerable.Range(1, 12).Select(n => $"LIV-{n:D3}")));
            Assert.That((await ReadRequestAsync(id, siteId: site.Id)).Received(), Is.EqualTo(120m));
        });
    }

    [Test]
    public async Task Simultaneous_sends_of_the_same_client_id_make_one_delivery()
    {
        var id = await OrderedRequestAsync(600m);
        var body = DeliveryBody(id, 10m, "sac", Factory.Today(), SupplierId, clientId: Guid.NewGuid());

        var responses = await Task.WhenAll(Enumerable.Range(0, 6).Select(_ => Chef.PostAsync(DeliveriesUrl(Site.Id), body)));
        var ids = (await Task.WhenAll(responses.Select(async response => (await response.JsonAsync()).Id()))).Distinct().ToList();

        Assert.Multiple(async () =>
        {
            Assert.That(responses.Count(response => response.StatusCode == HttpStatusCode.Created), Is.EqualTo(1));
            Assert.That(ids, Has.Count.EqualTo(1));
            Assert.That(await Factory.LiveDeliveriesAsync(id), Has.Count.EqualTo(1));
        });
    }

    [Test]
    public async Task Concurrent_creations_and_cancellations_leave_the_cache_equal_to_a_recompute_from_scratch()
    {
        var id = await OrderedRequestAsync(5000m);
        var seeded = new List<Guid>();
        for (var index = 0; index < 4; index++)
        {
            seeded.Add((await DeliverAsync(id, 10m, "sac")).Id());
        }

        var operations = new List<Task<HttpResponseMessage>>();
        operations.AddRange(seeded.Select(deliveryId => Chef.PostAsync($"{DeliveryUrl(Site.Id, deliveryId)}/cancel", new { reasonCode = "DoubleEntry" })));
        operations.AddRange(Enumerable.Range(0, 6).Select(_ => Chef.PostAsync(DeliveriesUrl(Site.Id), DeliveryBody(id, 25m, "sac", Factory.Today(), SupplierId))));
        var responses = await Task.WhenAll(operations);

        var row = await Factory.RequestRowAsync(id);
        var live = await Factory.LiveDeliveriesAsync(id);

        Assert.Multiple(() =>
        {
            Assert.That(responses.Select(response => response.StatusCode), Is.All.EqualTo(HttpStatusCode.OK).Or.EqualTo(HttpStatusCode.Created));
            Assert.That(row.ReceivedQuantity, Is.EqualTo(live.Sum(delivery => delivery.QuantityValue)), "cache = somme des livraisons non annulees");
            Assert.That(row.ReceivedQuantity, Is.EqualTo(150m));
        });
    }

    [Test]
    public async Task The_cache_always_matches_a_recompute_from_scratch_after_random_operations()
    {
        var random = new Random(20261125);
        var id = await OrderedRequestAsync(300m);
        var deliveries = new List<Guid>();
        var cancelled = new HashSet<Guid>();

        for (var step = 0; step < 30; step++)
        {
            switch (random.Next(3))
            {
                case 0:
                    deliveries.Add((await DeliverAsync(id, random.Next(1, 8) * 10, random.Next(2) == 0 ? "sac" : "kg")).Id());
                    break;
                case 1 when deliveries.Count > 0:
                    var victim = deliveries[random.Next(deliveries.Count)];
                    await Chef.PostAsync($"{DeliveryUrl(Site.Id, victim)}/cancel", new { reasonCode = "DoubleEntry" });
                    cancelled.Add(victim);
                    break;
                case 2 when deliveries.Count > 0:
                    var edited = deliveries[random.Next(deliveries.Count)];
                    var current = await (await Chef.GetAsync(DeliveryUrl(Site.Id, edited))).JsonAsync();
                    if (!cancelled.Contains(edited))
                    {
                        await Chef.PutAsync(DeliveryUrl(Site.Id, edited), new { version = current.Version(), quantity = new { value = random.Next(1, 20) * 10m, unit = "sac" } });
                    }

                    break;
            }

            var row = await Factory.RequestRowAsync(id);
            var live = await Factory.LiveDeliveriesAsync(id);
            var expected = live.Sum(delivery => delivery.Unit == Chantier.Core.Materials.MeasureUnit.Kilogram ? Math.Round(delivery.QuantityValue / 50m, 3, MidpointRounding.AwayFromZero) : delivery.QuantityValue);

            Assert.That(row.ReceivedQuantity, Is.EqualTo(expected), $"etape {step}");
            Assert.That(row.Status, Is.EqualTo(expected switch { 0m => RequestStatus.Ordered, >= 300m => RequestStatus.Delivered, _ => RequestStatus.PartiallyDelivered }), $"etape {step}");
        }
    }

    [Test]
    public async Task A_delivery_note_already_seen_is_a_warning_never_a_refusal()
    {
        var id = await OrderedRequestAsync(600m);
        var first = await DeliverAsync(id, 10m, "sac", note: "BL-DOUBLE");

        var second = await DeliverAsync(id, 10m, "sac", note: "bl-double");

        Assert.Multiple(() =>
        {
            Assert.That(second.GetProperty("possibleDuplicateOf").GetProperty("number").GetString(), Is.EqualTo(first.GetProperty("number").GetString()));
            Assert.That(first.Property("possibleDuplicateOf"), Is.Null);
        });
    }

    // --- Correction et annulation (CT-MAT-11) ---

    [Test]
    public async Task Correcting_a_delivery_recomputes_the_request_and_keeps_the_number_and_the_history()
    {
        var id = await OrderedRequestAsync(600m);
        var delivery = await DeliverAsync(id, 10m, "t");

        var response = await Chef.PutAsync(DeliveryUrl(Site.Id, delivery.Id()), new { version = delivery.Version(), quantity = new { value = 5m, unit = "t" }, deliveryNoteNumber = "bl-9" });
        var json = await response.JsonAsync();
        var edit = json.GetProperty("history").EnumerateArray().Last();

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), json.ToString());
            Assert.That(json.GetProperty("number").GetString(), Is.EqualTo(delivery.GetProperty("number").GetString()));
            Assert.That(edit.GetProperty("type").GetString(), Is.EqualTo("DeliveryEdited"));
            Assert.That(edit.GetProperty("changes").EnumerateArray().Select(change => change.GetProperty("field").GetString()), Is.EquivalentTo(new[] { "quantity", "deliveryNoteNumber" }));
            Assert.That(edit.GetProperty("changes")[0].GetProperty("old").GetString(), Is.EqualTo("10 t"));
            Assert.That(edit.GetProperty("changes")[0].GetProperty("new").GetString(), Is.EqualTo("5 t"));
            Assert.That((await ReadRequestAsync(id)).Received(), Is.EqualTo(100m));
        });
    }

    [Test]
    public async Task A_stale_version_gives_a_conflict_and_a_cancelled_delivery_cannot_be_corrected()
    {
        var id = await OrderedRequestAsync(600m);
        var delivery = await DeliverAsync(id, 10m, "t");
        await Chef.PutAsync(DeliveryUrl(Site.Id, delivery.Id()), new { version = delivery.Version(), deliveryNoteNumber = "BL-1" });

        var stale = await Chef.PutAsync(DeliveryUrl(Site.Id, delivery.Id()), new { version = delivery.Version(), deliveryNoteNumber = "BL-2" });
        var current = await (await Chef.GetAsync(DeliveryUrl(Site.Id, delivery.Id()))).JsonAsync();
        await Chef.PostAsync($"{DeliveryUrl(Site.Id, delivery.Id())}/cancel", new { reasonCode = "DoubleEntry" });
        var afterCancel = await (await Chef.GetAsync(DeliveryUrl(Site.Id, delivery.Id()))).JsonAsync();
        var editCancelled = await Chef.PutAsync(DeliveryUrl(Site.Id, delivery.Id()), new { version = afterCancel.Version(), deliveryNoteNumber = "BL-3" });

        Assert.Multiple(async () =>
        {
            Assert.That(stale.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
            Assert.That(await CodeOf(stale), Is.EqualTo("CONFLIT_VERSION"));
            Assert.That(current.GetProperty("deliveryNoteNumber").GetString(), Is.EqualTo("BL-1"));
            Assert.That(await CodeOf(editCancelled), Is.EqualTo("TRANSITION_INTERDITE"));
        });
    }

    [Test]
    public async Task A_correction_to_an_incompatible_unit_is_refused_and_writes_nothing()
    {
        var id = await OrderedRequestAsync(24m, "m3", productId: SandId);
        var delivery = await DeliverAsync(id, 5m, "m3", productId: SandId);

        var response = await Chef.PutAsync(DeliveryUrl(Site.Id, delivery.Id()), new { version = delivery.Version(), quantity = new { value = 5m, unit = "t" } });

        Assert.Multiple(async () =>
        {
            Assert.That(await CodeOf(response), Is.EqualTo("UNITES_INCOMPATIBLES"));
            Assert.That((await ReadRequestAsync(id)).Received(), Is.EqualTo(5m));
        });
    }

    [Test]
    public async Task Cancelling_needs_a_reason_and_two_taps_make_one_cancellation_with_the_first_reason()
    {
        var id = await OrderedRequestAsync(600m);
        var delivery = await DeliverAsync(id, 10m, "t");
        var url = $"{DeliveryUrl(Site.Id, delivery.Id())}/cancel";

        var none = await Chef.PostAsync(url, new { });
        var other = await Chef.PostAsync(url, new { reasonCode = "EntryError" });
        var first = await Chef.PostAsync(url, new { reasonCode = "QuantityError" });
        var second = await Chef.PostAsync(url, new { reasonCode = "DoubleEntry" });
        var json = await second.JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(none.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(other.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(second.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(json.GetProperty("cancelReason").GetProperty("code").GetString(), Is.EqualTo("QuantityError"));
            Assert.That(json.HistoryTypes().Count(type => type == "DeliveryCancelled"), Is.EqualTo(1));
            Assert.That(json.StatusOf(), Is.EqualTo("Cancelled"));
            Assert.That(json.GetProperty("number").GetString(), Is.EqualTo(delivery.GetProperty("number").GetString()), "numero conserve");
            Assert.That((await DeliverAsync(id, 10m, "t")).GetProperty("number").GetString(), Is.Not.EqualTo(delivery.GetProperty("number").GetString()), "numero jamais reutilise");
        });
    }

    [Test]
    public async Task A_received_request_refuses_correction_and_cancellation_of_its_deliveries()
    {
        var id = await OrderedRequestAsync(100m);
        var delivery = await DeliverAsync(id, 100m, "sac");
        Assert.That((await Chef.PostAsync($"{RequestUrl(Site.Id, id)}/receive")).StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var edit = await Chef.PutAsync(DeliveryUrl(Site.Id, delivery.Id()), new { version = delivery.Version(), deliveryNoteNumber = "BL-9" });
        var cancel = await Chef.PostAsync($"{DeliveryUrl(Site.Id, delivery.Id())}/cancel", new { reasonCode = "DoubleEntry" });

        Assert.Multiple(async () =>
        {
            Assert.That(edit.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(edit), Is.EqualTo("DEMANDE_NON_OUVERTE"));
            Assert.That(await CodeOf(cancel), Is.EqualTo("DEMANDE_NON_OUVERTE"));
            Assert.That((await ReadRequestAsync(id)).StatusOf(), Is.EqualTo("Received"), "ne se recalcule plus");
        });
    }

    // --- Solde ---

    [Test]
    public async Task Settling_needs_a_live_delivery_and_a_settled_request_returns_to_ordered_when_all_deliveries_are_cancelled()
    {
        var withoutDelivery = await OrderedRequestAsync(100m);
        await Factory.SetStatusAsync(withoutDelivery, RequestStatus.PartiallyDelivered);
        var refused = await Achats.PostAsync($"{RequestUrl(Site.Id, withoutDelivery)}/settle", new { reasonCode = "QuantitySufficient" });

        var id = await OrderedRequestAsync(600m);
        var delivery = await DeliverAsync(id, 100m, "sac");
        var settled = await Achats.PostAsync($"{RequestUrl(Site.Id, id)}/settle", new { reasonCode = "SupplierWillNotDeliver" });
        await Chef.PostAsync($"{DeliveryUrl(Site.Id, delivery.Id())}/cancel", new { reasonCode = "DoubleEntry" });
        var back = await ReadRequestAsync(id);

        Assert.Multiple(async () =>
        {
            Assert.That(await CodeOf(refused), Is.EqualTo("TRANSITION_INTERDITE"));
            Assert.That((await settled.JsonAsync()).StatusOf(), Is.EqualTo("Delivered"));
            Assert.That(back.StatusOf(), Is.EqualTo("Ordered"));
            Assert.That(back.GetProperty("isSettled").GetBoolean(), Is.False);
        });
    }

    // --- Rattachement ---

    [Test]
    public async Task An_unattached_delivery_is_attached_and_the_request_is_recomputed()
    {
        var id = await OrderedRequestAsync(600m);
        var loose = await DeliverAsync(null, 10m, "t", productId: CementId);

        var response = await Chef.PostAsync($"{DeliveryUrl(Site.Id, loose.Id())}/attach", new { requestId = id });
        var json = await response.JsonAsync();
        var request = await ReadRequestAsync(id);

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), json.ToString());
            Assert.That(json.GetProperty("requestId").GetGuid(), Is.EqualTo(id));
            Assert.That(json.Property("unattachedReason"), Is.Null);
            Assert.That(json.GetProperty("quantityInRequestUnit").GetProperty("value").GetDecimal(), Is.EqualTo(200m));
            Assert.That(json.HistoryTypes(), Does.Contain("DeliveryAttached"));
            Assert.That(request.StatusOf(), Is.EqualTo("PartiallyDelivered"));
            Assert.That(request.Received(), Is.EqualTo(200m));
        });
    }

    [Test]
    public async Task Attaching_checks_the_product_the_unit_the_status_and_the_site()
    {
        var cement = await OrderedRequestAsync(600m);
        var sand = await OrderedRequestAsync(24m, "m3", productId: SandId);
        var closed = await Chef.NewRequestIdAsync(Site.Id, CementId);
        await Factory.SetStatusAsync(closed, RequestStatus.Cancelled);
        var other = await NewSiteAsync();
        var foreign = await OrderedRequestAsync(100m, siteId: other.Id);

        var steel = await DeliverAsync(null, 1m, "t", productId: SteelId);
        var tonnesOfSand = await DeliverAsync(null, 5m, "t", productId: SandId);
        var plain = await DeliverAsync(null, 10m, "t", productId: CementId);

        var wrongProduct = await Chef.PostAsync($"{DeliveryUrl(Site.Id, steel.Id())}/attach", new { requestId = cement });
        var incompatible = await Chef.PostAsync($"{DeliveryUrl(Site.Id, tonnesOfSand.Id())}/attach", new { requestId = sand });
        var notOpen = await Chef.PostAsync($"{DeliveryUrl(Site.Id, plain.Id())}/attach", new { requestId = closed });
        var elsewhere = await Chef.PostAsync($"{DeliveryUrl(Site.Id, plain.Id())}/attach", new { requestId = foreign });
        var ok = await Chef.PostAsync($"{DeliveryUrl(Site.Id, plain.Id())}/attach", new { requestId = cement });
        var twice = await Chef.PostAsync($"{DeliveryUrl(Site.Id, plain.Id())}/attach", new { requestId = cement });

        Assert.Multiple(async () =>
        {
            Assert.That(await CodeOf(wrongProduct), Is.EqualTo("PRODUIT_DIFFERENT"));
            Assert.That(await CodeOf(incompatible), Is.EqualTo("UNITES_INCOMPATIBLES"));
            Assert.That(await CodeOf(notOpen), Is.EqualTo("DEMANDE_NON_OUVERTE"));
            Assert.That(elsewhere.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(ok.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(await CodeOf(twice), Is.EqualTo("LIVRAISON_DEJA_RATTACHEE"));
        });
    }

    // --- Listes ---

    [Test]
    public async Task The_list_filters_unattached_missing_note_reserve_and_status_and_searches_by_number()
    {
        var site = await NewSiteAsync();
        var id = await OrderedRequestAsync(600m, siteId: site.Id);
        var attached = await DeliverAsync(id, 10m, "sac", siteId: site.Id, note: "BL-1");
        var loose = await DeliverAsync(null, 5m, "t", siteId: site.Id, productId: CementId);
        var reserved = await DeliverAsync(id, 10m, "sac", siteId: site.Id, note: "BL-2", overrides: body => { body["conformity"] = "WithReserve"; body["reserveReasonCode"] = "WrongProduct"; });
        var cancelled = await DeliverAsync(id, 10m, "sac", siteId: site.Id, note: "BL-3");
        await Chef.PostAsync($"{DeliveryUrl(site.Id, cancelled.Id())}/cancel", new { reasonCode = "DoubleEntry" });

        async Task<List<string>> NumbersAsync(string query)
        {
            var json = await (await Chef.GetAsync($"{DeliveriesUrl(site.Id)}{query}")).JsonAsync();
            return json.GetProperty("items").EnumerateArray().Select(item => item.GetProperty("number").GetString()!).ToList();
        }

        Assert.Multiple(async () =>
        {
            Assert.That(await NumbersAsync("?unattached=true"), Is.EqualTo(new[] { loose.GetProperty("number").GetString() }));
            Assert.That(await NumbersAsync("?withReserve=true"), Is.EqualTo(new[] { reserved.GetProperty("number").GetString() }));
            Assert.That(await NumbersAsync("?missingNote=true"), Is.EqualTo(new[] { loose.GetProperty("number").GetString() }), "ni BL ni photo");
            Assert.That(await NumbersAsync("?status=Cancelled"), Is.EqualTo(new[] { cancelled.GetProperty("number").GetString() }));
            Assert.That(await NumbersAsync($"?requestId={id}"), Has.Count.EqualTo(3));
            Assert.That(await NumbersAsync($"?q={attached.GetProperty("number").GetString()!.ToLowerInvariant()}"), Is.EqualTo(new[] { attached.GetProperty("number").GetString() }));
            Assert.That(await NumbersAsync("?q=bl-2"), Is.EqualTo(new[] { reserved.GetProperty("number").GetString() }));
            Assert.That(await NumbersAsync("?pageSize=2&page=1"), Has.Count.EqualTo(2));
            Assert.That((await (await Chef.GetAsync($"{DeliveriesUrl(site.Id)}?pageSize=2")).JsonAsync()).GetProperty("totalCount").GetInt32(), Is.EqualTo(4));
        });
    }

    [Test]
    public async Task The_list_rejects_a_bad_page_or_sort()
    {
        var page = await Chef.GetAsync($"{DeliveriesUrl(Site.Id)}?page=0");
        var size = await Chef.GetAsync($"{DeliveriesUrl(Site.Id)}?pageSize=500");
        var sort = await Chef.GetAsync($"{DeliveriesUrl(Site.Id)}?sort=price");

        Assert.That(new[] { page.StatusCode, size.StatusCode, sort.StatusCode }, Is.All.EqualTo(HttpStatusCode.BadRequest));
    }

    // --- Droits, isolation (CT-MAT-14, 15) ---

    [Test]
    public async Task Only_the_receiving_roles_write_deliveries_and_everybody_reads_them()
    {
        var id = await OrderedRequestAsync(600m);
        var delivery = await DeliverAsync(id, 10m, "t");
        var body = () => DeliveryBody(id, 1m, "sac", Factory.Today(), SupplierId);

        var allowed = new[] { Admin, Conducteur, Achats, Chef };
        var denied = new[] { Direction, Equipe };
        var created = new List<HttpStatusCode>();
        foreach (var session in allowed)
        {
            created.Add((await session.PostAsync(DeliveriesUrl(Site.Id), body())).StatusCode);
        }

        var refused = new List<HttpStatusCode>();
        foreach (var session in denied)
        {
            refused.Add((await session.PostAsync(DeliveriesUrl(Site.Id), body())).StatusCode);
            refused.Add((await session.PostAsync($"{DeliveryUrl(Site.Id, delivery.Id())}/cancel", new { reasonCode = "DoubleEntry" })).StatusCode);
            refused.Add((await session.PutAsync(DeliveryUrl(Site.Id, delivery.Id()), new { version = delivery.Version(), deliveryNoteNumber = "X" })).StatusCode);
            refused.Add((await session.PostAsync($"{DeliveryUrl(Site.Id, delivery.Id())}/attach", new { requestId = id })).StatusCode);
        }

        var reads = new List<HttpStatusCode>();
        foreach (var session in AllSessions)
        {
            reads.Add((await session.GetAsync(DeliveriesUrl(Site.Id))).StatusCode);
            reads.Add((await session.GetAsync(DeliveryUrl(Site.Id, delivery.Id()))).StatusCode);
        }

        var anonymous = await Factory.CreateClient().GetAsync(DeliveriesUrl(Site.Id));

        Assert.Multiple(() =>
        {
            Assert.That(created, Is.All.EqualTo(HttpStatusCode.Created));
            Assert.That(refused, Is.All.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(reads, Is.All.EqualTo(HttpStatusCode.OK));
            Assert.That(anonymous.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
        Assert.That(await Factory.LiveDeliveriesAsync(id), Has.Count.EqualTo(5), "les refus n'ecrivent rien");
    }

    [Test]
    public async Task A_delivery_of_another_site_is_not_found_whatever_the_route()
    {
        var other = await NewSiteAsync();
        var id = await OrderedRequestAsync(100m, siteId: other.Id);
        var foreign = await DeliverAsync(id, 10m, "sac", siteId: other.Id);
        var site = await Factory.SeedSiteAsync();

        var routes = new[]
        {
            await Chef.GetAsync(DeliveryUrl(Site.Id, foreign.Id())),
            await Chef.PutAsync(DeliveryUrl(Site.Id, foreign.Id()), new { version = foreign.Version(), deliveryNoteNumber = "X" }),
            await Chef.PostAsync($"{DeliveryUrl(Site.Id, foreign.Id())}/cancel", new { reasonCode = "DoubleEntry" }),
            await Chef.PostAsync($"{DeliveryUrl(Site.Id, foreign.Id())}/attach", new { requestId = id }),
            await Chef.GetAsync(DeliveriesUrl(site.Id)),
            await Chef.GetAsync(DeliveryUrl(Guid.NewGuid(), foreign.Id())),
        };

        Assert.That(routes.Select(response => response.StatusCode), Is.All.EqualTo(HttpStatusCode.NotFound));
    }

    [Test]
    public async Task An_archived_site_refuses_a_new_delivery()
    {
        var site = await NewSiteAsync();
        var id = await OrderedRequestAsync(100m, siteId: site.Id);
        await Factory.ArchiveSiteAsync(site.Id);

        var response = await Chef.PostAsync(DeliveriesUrl(site.Id), DeliveryBody(id, 10m, "sac", Factory.Today(), SupplierId));

        Assert.That(await CodeOf(response), Is.EqualTo("CHANTIER_ARCHIVE"));
    }

    [Test]
    public async Task The_delivery_amount_follows_the_price_of_the_order_and_is_hidden_from_the_field()
    {
        var id = await OrderedRequestAsync(600m, price: 780m);
        var delivery = await DeliverAsync(id, 10m, "t");

        var asPurchasing = await (await Achats.GetAsync(DeliveryUrl(Site.Id, delivery.Id()))).JsonAsync();
        var asChef = await (await Chef.GetAsync(DeliveryUrl(Site.Id, delivery.Id()))).JsonAsync();

        var order = (await ReadRequestAsync(id)).GetProperty("order");
        await Achats.PutAsync(OrderUrl(Site.Id, id), new { version = order.Version(), unitPrice = 800m });
        var repriced = await (await Achats.GetAsync(DeliveryUrl(Site.Id, delivery.Id()))).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(asPurchasing.GetProperty("commercial").GetProperty("amount").GetDecimal(), Is.EqualTo(156000.00m), "200 sacs x 780");
            Assert.That(asChef.TryGetProperty("commercial", out _), Is.False);
            Assert.That(repriced.GetProperty("commercial").GetProperty("amount").GetDecimal(), Is.EqualTo(160000.00m), "le changement de prix recalcule la livraison");
        });
    }
}
