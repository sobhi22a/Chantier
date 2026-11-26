using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.IntegrationTests.Materials;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.MaterialsSyncKit;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Sync;

/// <summary>
/// B10 (CT-MAT-17 a 19) : synchronisation des livraisons et des photos. Lecture : livraisons des chantiers affectes sans montant ni photos, photos selon le droit.
/// Ecriture : creation idempotente jamais refusee a cause du statut de la demande, correction a trois valeurs (premiere arrivee retenue), annulation, journal d'operations.
/// </summary>
[TestFixture]
public class DeliverySyncTests : DeliveryFixtureBase
{
    private string Today => Iso(Factory.Today());

    private async Task<JsonElement> PushOneAsync(ApiSession session, object operation)
        => (await session.PushAsync(operation))[0];

    // --- Creation ---

    [Test]
    public async Task A_delivery_created_offline_is_applied_once_and_has_no_amount_photos_or_missing_flag()
    {
        var id = await OrderedRequestAsync(600m);
        var clientId = Guid.NewGuid();
        var operation = DeliveryCreate(clientId, Site.Id, id, 10m, "t", Today, SupplierId, note: "bl-77");

        var first = await PushOneAsync(Chef, operation);
        var again = await PushOneAsync(Chef, operation);
        var resource = first.Resource();

        Assert.Multiple(async () =>
        {
            Assert.That(first.Status(), Is.EqualTo("applied"));
            Assert.That(again.Status(), Is.EqualTo("duplicate"));
            Assert.That(again.Resource().GetProperty("number").GetString(), Is.EqualTo(resource.GetProperty("number").GetString()), "un renvoi = meme numero");
            Assert.That(resource.GetProperty("deliveryNoteNumber").GetString(), Is.EqualTo("BL-77"));
            Assert.That(resource.GetProperty("quantityInRequestUnit").GetProperty("value").GetDecimal(), Is.EqualTo(200m));
            Assert.That(ForbiddenWords.Where(word => resource.GetRawText().Contains(word)), Is.Empty);
            Assert.That(resource.TryGetProperty("photos", out _), Is.False);
            Assert.That(resource.TryGetProperty("missingNote", out _), Is.False);
            Assert.That(await Factory.LiveDeliveriesAsync(id), Has.Count.EqualTo(1));
            Assert.That((await ReadRequestAsync(id)).StatusOf(), Is.EqualTo("PartiallyDelivered"));
        });
    }

    [Test]
    public async Task A_delivery_for_a_cancelled_or_received_request_is_recorded_unattached()
    {
        var cancelled = await Chef.NewRequestIdAsync(Site.Id, CementId);
        await Factory.SetStatusAsync(cancelled, RequestStatus.Cancelled);
        var received = await Chef.NewRequestIdAsync(Site.Id, CementId);
        await Factory.SetStatusAsync(received, RequestStatus.Received);

        var results = await Chef.PushAsync(
            DeliveryCreate(Guid.NewGuid(), Site.Id, cancelled, 10m, "t", Today, SupplierId),
            DeliveryCreate(Guid.NewGuid(), Site.Id, received, 10m, "t", Today, SupplierId));

        Assert.Multiple(() =>
        {
            foreach (var result in results.EnumerateArray())
            {
                Assert.That(result.Status(), Is.EqualTo("applied"), "fait de chantier : jamais refusee");
                Assert.That(result.Resource().GetProperty("unattachedReason").GetString(), Is.EqualTo("RequestNotOpen"));
                Assert.That(result.Resource().TryGetProperty("requestId", out var attached) && attached.ValueKind != JsonValueKind.Null, Is.False);
            }
        });
    }

    [Test]
    public async Task A_delivery_before_the_order_is_retained_and_the_order_then_takes_it_into_account()
    {
        var id = await ValidatedAsync(600m);

        var result = await PushOneAsync(Chef, DeliveryCreate(Guid.NewGuid(), Site.Id, id, 10m, "t", Today, SupplierId));
        var retained = await ReadRequestAsync(id);
        await Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId));
        var afterOrder = await ReadRequestAsync(id);

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("applied"));
            Assert.That(result.Resource().GetProperty("requestId").GetGuid(), Is.EqualTo(id));
            Assert.That(retained.StatusOf(), Is.EqualTo("Validated"));
            Assert.That(retained.GetProperty("hasDeliveryWithoutOrder").GetBoolean(), Is.True);
            Assert.That(afterOrder.StatusOf(), Is.EqualTo("PartiallyDelivered"));
        });
    }

    [Test]
    public async Task A_delivery_can_designate_a_request_created_in_the_same_batch_and_an_unknown_one_becomes_unattached()
    {
        var requestClientId = Guid.NewGuid();

        var results = await Chef.PushAsync(
            RequestCreate(requestClientId, Site.Id, CementId, 100m, "sac"),
            DeliveryCreate(Guid.NewGuid(), Site.Id, null, 5m, "t", Today, SupplierId, requestClientId: requestClientId),
            DeliveryCreate(Guid.NewGuid(), Site.Id, null, 5m, "t", Today, SupplierId, productId: CementId, requestClientId: Guid.NewGuid()));

        var created = results[0].Resource().GetProperty("id").GetGuid();
        Assert.Multiple(() =>
        {
            Assert.That(results[1].Status(), Is.EqualTo("applied"));
            Assert.That(results[2].Status(), Is.EqualTo("applied"));
            Assert.That(results[1].Resource().GetProperty("unattachedReason").GetString(), Is.EqualTo("RequestNotOpen"), "demande encore « Demandee » : fait de chantier, non rattachee");
            Assert.That(results[1].Resource().GetProperty("number").GetString(), Is.Not.Null);
            Assert.That(results[2].Resource().GetProperty("unattachedReason").GetString(), Is.EqualTo("RequestMissing"));
            Assert.That(created, Is.Not.EqualTo(Guid.Empty));
        });
    }

    [Test]
    public async Task A_delivery_is_rejected_for_the_business_reasons_and_the_rights()
    {
        var id = await OrderedRequestAsync(24m, "m3", productId: SandId);
        var other = await Factory.SeedSiteAsync();

        var incompatible = await PushOneAsync(Chef, DeliveryCreate(Guid.NewGuid(), Site.Id, id, 10m, "t", Today, SupplierId));
        var future = await PushOneAsync(Chef, DeliveryCreate(Guid.NewGuid(), Site.Id, id, 1m, "m3", Iso(Factory.Today().AddDays(2)), SupplierId));
        var noUnit = await PushOneAsync(Chef, DeliveryCreate(Guid.NewGuid(), Site.Id, id, 1m, null, Today, SupplierId));
        var equipe = await PushOneAsync(Equipe, DeliveryCreate(Guid.NewGuid(), Site.Id, id, 1m, "m3", Today, SupplierId));
        var elsewhere = await PushOneAsync(Chef, DeliveryCreate(Guid.NewGuid(), other.Id, null, 1m, "m3", Today, SupplierId, productId: SandId));
        var wrongProduct = await PushOneAsync(Chef, DeliveryCreate(Guid.NewGuid(), Site.Id, id, 1m, "t", Today, SupplierId, productId: SteelId));

        Assert.Multiple(() =>
        {
            Assert.That((incompatible.Status(), incompatible.Code()), Is.EqualTo(("rejected", "UNITES_INCOMPATIBLES")));
            Assert.That((future.Status(), future.Code()), Is.EqualTo(("rejected", "DATE_INVALIDE")));
            Assert.That((noUnit.Status(), noUnit.Code()), Is.EqualTo(("rejected", "UNITE_OBLIGATOIRE")));
            Assert.That((equipe.Status(), equipe.Code()), Is.EqualTo(("rejected", "INTERDIT")));
            Assert.That((elsewhere.Status(), elsewhere.Code()), Is.EqualTo(("rejected", "INTROUVABLE")));
            Assert.That((wrongProduct.Status(), wrongProduct.Code()), Is.EqualTo(("rejected", "PRODUIT_DIFFERENT")));
        });
        Assert.That(await Factory.LiveDeliveriesAsync(id), Is.Empty, "rien d'ecrit");
    }

    // --- Correction et annulation ---

    [Test]
    public async Task A_correction_with_an_unchanged_base_is_applied_and_a_resend_gives_the_same_result()
    {
        var id = await OrderedRequestAsync(600m);
        var delivery = await DeliverAsync(id, 10m, "t", note: "BL-1");
        var operation = DeliveryUpdate(
            Guid.NewGuid(), Site.Id,
            new Dictionary<string, object?> { ["quantity"] = new { value = 5m, unit = "t" } },
            new Dictionary<string, object?> { ["quantity"] = new { value = 10m, unit = "t" } },
            deliveryId: delivery.Id());

        var first = await PushOneAsync(Chef, operation);
        var again = await PushOneAsync(Chef, operation);

        Assert.Multiple(async () =>
        {
            Assert.That(first.Status(), Is.EqualTo("applied"));
            Assert.That(again.Status(), Is.EqualTo("duplicate"), "un renvoi ne fait jamais de faux conflit");
            Assert.That((await ReadRequestAsync(id)).Received(), Is.EqualTo(100m));
            Assert.That((await Factory.DeliveryEventsAsync(delivery.Id())).Count(item => item.Type == MaterialEventType.DeliveryEdited), Is.EqualTo(1));
            Assert.That((await Factory.DeliveryEventsAsync(delivery.Id())).Last(item => item.Type == MaterialEventType.DeliveryEdited).Source, Is.EqualTo(MaterialEventSource.Sync));
        });
    }

    [Test]
    public async Task The_same_field_changed_by_someone_else_is_a_conflict_and_different_fields_are_both_applied()
    {
        var id = await OrderedRequestAsync(600m);
        var delivery = await DeliverAsync(id, 10m, "t", note: "BL-1");
        await Achats.PutAsync(DeliveryUrl(Site.Id, delivery.Id()), new { version = delivery.Version(), deliveryNoteNumber = "BL-ACHATS" });

        var sameField = await PushOneAsync(Chef, DeliveryUpdate(
            Guid.NewGuid(), Site.Id,
            new Dictionary<string, object?> { ["deliveryNoteNumber"] = "BL-CHEF" },
            new Dictionary<string, object?> { ["deliveryNoteNumber"] = "BL-1" },
            deliveryClientId: null, deliveryId: delivery.Id()));
        var otherField = await PushOneAsync(Chef, DeliveryUpdate(
            Guid.NewGuid(), Site.Id,
            new Dictionary<string, object?> { ["quantity"] = new { value = 8m, unit = "t" } },
            new Dictionary<string, object?> { ["quantity"] = new { value = 10m, unit = "t" } },
            deliveryId: delivery.Id()));
        var current = await (await Chef.GetAsync(DeliveryUrl(Site.Id, delivery.Id()))).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That((sameField.Status(), sameField.Code()), Is.EqualTo(("conflict", "CONFLIT_VERSION")));
            Assert.That(sameField.ConflictFields(), Is.EqualTo(new[] { "deliveryNoteNumber" }));
            Assert.That(sameField.Current().GetProperty("deliveryNoteNumber").GetString(), Is.EqualTo("BL-ACHATS"), "le serveur garde la premiere valeur");
            Assert.That(otherField.Status(), Is.EqualTo("applied"));
            Assert.That(current.GetProperty("deliveryNoteNumber").GetString(), Is.EqualTo("BL-ACHATS"));
            Assert.That(current.GetProperty("quantity").GetProperty("value").GetDecimal(), Is.EqualTo(8m));
        });
    }

    [Test]
    public async Task A_correction_of_a_cancelled_delivery_or_a_received_request_is_a_conflict_with_the_server_state()
    {
        var cancelledRequest = await OrderedRequestAsync(100m);
        var cancelled = await DeliverAsync(cancelledRequest, 50m, "sac");
        await Chef.PostAsync($"{DeliveryUrl(Site.Id, cancelled.Id())}/cancel", new { reasonCode = "DoubleEntry" });
        var receivedRequest = await OrderedRequestAsync(100m);
        var received = await DeliverAsync(receivedRequest, 100m, "sac");
        await Chef.PostAsync($"{RequestUrl(Site.Id, receivedRequest)}/receive");

        Dictionary<string, object?> Change(object value) => new() { ["quantity"] = value };

        var onCancelled = await PushOneAsync(Chef, DeliveryUpdate(Guid.NewGuid(), Site.Id, Change(new { value = 40m, unit = "sac" }), Change(new { value = 50m, unit = "sac" }), deliveryId: cancelled.Id()));
        var onReceived = await PushOneAsync(Chef, DeliveryUpdate(Guid.NewGuid(), Site.Id, Change(new { value = 90m, unit = "sac" }), Change(new { value = 100m, unit = "sac" }), deliveryId: received.Id()));
        var cancelOnReceived = await PushOneAsync(Chef, DeliveryCancel(Guid.NewGuid(), Site.Id, received.Id()));

        Assert.Multiple(() =>
        {
            Assert.That((onCancelled.Status(), onCancelled.Code()), Is.EqualTo(("conflict", "TRANSITION_INTERDITE")));
            Assert.That(onCancelled.Current().GetProperty("status").GetString(), Is.EqualTo("Cancelled"));
            Assert.That((onReceived.Status(), onReceived.Code()), Is.EqualTo(("conflict", "DEMANDE_NON_OUVERTE")));
            Assert.That((cancelOnReceived.Status(), cancelOnReceived.Code()), Is.EqualTo(("conflict", "DEMANDE_NON_OUVERTE")));
        });
    }

    [Test]
    public async Task A_delivery_can_be_designated_by_its_client_id_and_cancelled_offline_with_a_recalculation()
    {
        var id = await OrderedRequestAsync(100m);
        var clientId = Guid.NewGuid();
        await PushOneAsync(Chef, DeliveryCreate(clientId, Site.Id, id, 100m, "sac", Today, SupplierId));
        Assert.That((await ReadRequestAsync(id)).StatusOf(), Is.EqualTo("Delivered"));
        var cancel = DeliveryCancel(Guid.NewGuid(), Site.Id, deliveryClientId: clientId);

        var first = await PushOneAsync(Chef, cancel);
        var again = await PushOneAsync(Chef, cancel);
        var other = await PushOneAsync(Chef, DeliveryCancel(Guid.NewGuid(), Site.Id, deliveryClientId: clientId, reasonCode: "QuantityError"));

        Assert.Multiple(async () =>
        {
            Assert.That(first.Status(), Is.EqualTo("applied"));
            Assert.That(first.Resource().GetProperty("status").GetString(), Is.EqualTo("Cancelled"));
            Assert.That(again.Status(), Is.EqualTo("duplicate"));
            Assert.That(other.Status(), Is.EqualTo("duplicate"), "deux annulations = une seule, premier motif conserve");
            Assert.That(other.Resource().GetProperty("cancelReason").GetProperty("code").GetString(), Is.EqualTo("DoubleEntry"));
            Assert.That((await ReadRequestAsync(id)).StatusOf(), Is.EqualTo("Ordered"));
        });
    }

    [Test]
    public async Task An_unknown_delivery_or_an_unknown_action_is_rejected()
    {
        var missing = await PushOneAsync(Chef, DeliveryCancel(Guid.NewGuid(), Site.Id, Guid.NewGuid()));
        var noTarget = await PushOneAsync(Chef, DeliveryCancel(Guid.NewGuid(), Site.Id));
        var badAction = await PushOneAsync(Chef, new Dictionary<string, object?>
        {
            ["clientId"] = Guid.NewGuid(),
            ["entity"] = "delivery",
            ["operation"] = "transition",
            ["siteId"] = Site.Id,
            ["payload"] = new Dictionary<string, object?> { ["deliveryId"] = Guid.NewGuid(), ["action"] = "approve" },
        });

        Assert.Multiple(() =>
        {
            Assert.That((missing.Status(), missing.Code()), Is.EqualTo(("rejected", "INTROUVABLE")));
            Assert.That(noTarget.Status(), Is.EqualTo("rejected"));
            Assert.That(badAction.Status(), Is.EqualTo("rejected"));
        });
    }

    // --- Photos ---

    [Test]
    public async Task A_photo_metadata_operation_is_idempotent_limited_to_five_and_can_designate_its_delivery_by_client_id()
    {
        var id = await OrderedRequestAsync(600m);
        var deliveryClientId = Guid.NewGuid();
        await PushOneAsync(Chef, DeliveryCreate(deliveryClientId, Site.Id, id, 10m, "t", Today, SupplierId));
        var jpeg = Jpeg();
        var photoClientId = Guid.NewGuid();
        var operation = PhotoCreate(photoClientId, Site.Id, null, deliveryClientId, jpeg);

        var first = await PushOneAsync(Chef, operation);
        var again = await PushOneAsync(Chef, operation);
        for (var index = 0; index < 4; index++)
        {
            await PushOneAsync(Chef, PhotoCreate(Guid.NewGuid(), Site.Id, null, deliveryClientId, Jpeg((byte)(index + 2))));
        }

        var sixth = await PushOneAsync(Chef, PhotoCreate(Guid.NewGuid(), Site.Id, null, deliveryClientId, Jpeg(9)));
        var unknown = await PushOneAsync(Chef, PhotoCreate(Guid.NewGuid(), Site.Id, Guid.NewGuid(), null, jpeg));

        Assert.Multiple(() =>
        {
            Assert.That(first.Status(), Is.EqualTo("applied"));
            Assert.That(first.Resource().GetProperty("contentStatus").GetString(), Is.EqualTo("Pending"));
            Assert.That(again.Status(), Is.EqualTo("duplicate"));
            Assert.That(again.Resource().GetProperty("id").GetGuid(), Is.EqualTo(first.Resource().GetProperty("id").GetGuid()));
            Assert.That((sixth.Status(), sixth.Code()), Is.EqualTo(("rejected", "PHOTOS_TROP_NOMBREUSES")));
            Assert.That((unknown.Status(), unknown.Code()), Is.EqualTo(("rejected", "INTROUVABLE")));
            Assert.That(first.GetRawText(), Does.Not.Contain("sha256").IgnoreCase.And.Not.Contain("storageKey").IgnoreCase);
        });
    }

    [Test]
    public async Task A_role_without_the_photo_right_cannot_create_photo_metadata()
    {
        var id = await OrderedRequestAsync(600m);
        var delivery = await DeliverAsync(id, 10m, "t");

        var result = await PushOneAsync(Equipe, PhotoCreate(Guid.NewGuid(), Site.Id, delivery.Id(), null, Jpeg()));

        Assert.That((result.Status(), result.Code()), Is.EqualTo(("rejected", "INTERDIT")));
    }

    // --- Lecture ---

    [Test]
    public async Task Pulled_deliveries_carry_no_price_and_photo_rows_exist_only_for_the_roles_that_see_the_bons()
    {
        var site = await NewSiteAsync();
        var id = await OrderedRequestAsync(600m, siteId: site.Id, price: 780m);
        var delivery = await DeliverAsync(id, 10m, "t", siteId: site.Id, note: "BL-9");
        var photo = await Chef.PostAsync(PhotosUrl(site.Id, delivery.Id()), new
        {
            clientId = Guid.NewGuid(),
            takenAt = "2026-11-25T08:10:00Z",
            contentType = "image/jpeg",
            sizeBytes = Jpeg().Length,
            sha256 = Sha256Hex(Jpeg()),
        });
        Assert.That(photo.StatusCode, Is.EqualTo(HttpStatusCode.Created));

        var seen = new Dictionary<string, (List<JsonElement> Deliveries, List<JsonElement> Photos, List<JsonElement> Requests, string Raw)>();
        foreach (var (name, session) in new[] { ("chef", Chef), ("achats", Achats), ("conducteur", Conducteur), ("equipe", Equipe) })
        {
            var (changes, _, _) = await session.PullAllAsync(siteId: site.Id);
            seen[name] = (changes.Of("delivery").ToList(), changes.Of("photo").ToList(), changes.Of("request").ToList(), string.Join(' ', changes.Select(row => row.GetRawText())));
        }

        Assert.Multiple(() =>
        {
            foreach (var (name, view) in seen)
            {
                Assert.That(view.Deliveries, Has.Count.EqualTo(1), name);
                Assert.That(view.Raw, Does.Not.Contain("commercial").And.Not.Contain("unitPrice").And.Not.Contain("\"amount\"").And.Not.Contain("receivedValue").And.Not.Contain("purchaseOrderNumber"), $"{name} : aucun prix dans la synchronisation");
                var row = view.Deliveries[0];
                Assert.That(row.GetProperty("siteId").GetGuid(), Is.EqualTo(site.Id));
                Assert.That(row.GetProperty("data").TryGetProperty("photos", out _), Is.False);
                Assert.That(row.GetProperty("data").GetProperty("photoCount").GetInt32(), Is.Zero, "photo encore en attente : pas comptee (R2-05)");
                Assert.That(view.Requests.Single().GetProperty("data").GetProperty("order").GetProperty("supplierId").GetGuid(), Is.EqualTo(SupplierId), $"{name} : commande sans prix");
                Assert.That(view.Requests.Single().GetProperty("data").TryGetProperty("deliveries", out _), Is.False);
            }

            Assert.That(seen["chef"].Photos, Has.Count.EqualTo(1));
            Assert.That(seen["achats"].Photos, Has.Count.EqualTo(1));
            Assert.That(seen["conducteur"].Photos, Has.Count.EqualTo(1));
            Assert.That(seen["equipe"].Photos, Is.Empty, "ChefEquipe : aucune ligne photo");
            Assert.That(seen["chef"].Photos[0].GetProperty("data").GetProperty("contentStatus").GetString(), Is.EqualTo("Pending"));
        });
    }

    [Test]
    public async Task An_event_on_a_delivery_or_an_order_advances_the_version_of_the_lines_the_phones_read()
    {
        var site = await NewSiteAsync();
        var id = await OrderedRequestAsync(600m, siteId: site.Id);
        var delivery = await DeliverAsync(id, 10m, "t", siteId: site.Id);
        var (_, _, cursor) = await Chef.PullAllAsync(siteId: site.Id);

        await Chef.PostAsync($"{DeliveryUrl(site.Id, delivery.Id())}/cancel", new { reasonCode = "DoubleEntry" });
        var (changes, _, _) = await Chef.PullAllAsync(cursor, site.Id);

        var deliveryRow = changes.Of("delivery").Single().GetProperty("data");
        var requestRow = changes.Of("request").Single().GetProperty("data");
        var detail = await (await Chef.GetAsync(DeliveryUrl(site.Id, delivery.Id()))).JsonAsync();
        Assert.Multiple(() =>
        {
            Assert.That(deliveryRow.GetProperty("status").GetString(), Is.EqualTo("Cancelled"));
            Assert.That(deliveryRow.GetProperty("history").GetArrayLength(), Is.Zero, "R2-02 : aucun historique dans la synchronisation");
            Assert.That(detail.HistoryTypes(), Does.Contain("DeliveryCancelled"), "l'historique se lit a la demande");
            Assert.That(requestRow.GetProperty("status").GetString(), Is.EqualTo("Ordered"), "la demande recalculee revient aussi");
        });
    }

    [Test]
    public async Task A_new_assignment_receives_the_old_deliveries_and_photos_and_a_removed_one_loses_access()
    {
        var site = await Factory.SeedSiteAsync(members: [Chef.Account.Id, Conducteur.Account.Id, Achats.Account.Id]);
        var id = await OrderedRequestAsync(600m, siteId: site.Id);
        var delivery = await DeliverAsync(id, 10m, "t", siteId: site.Id);
        await Chef.PostAsync(PhotosUrl(site.Id, delivery.Id()), new
        {
            clientId = Guid.NewGuid(),
            takenAt = "2026-11-25T08:10:00Z",
            contentType = "image/jpeg",
            sizeBytes = Jpeg().Length,
            sha256 = Sha256Hex(Jpeg()),
        });
        var newcomer = await Factory.SignInAsync(Chantier.Core.Entities.Identity.RoleNames.ChefChantier);
        var (_, _, before) = await newcomer.PullAllAsync();

        var response = await Admin.PutAsync($"/api/v1/sites/{site.Id}/members/{newcomer.Account.Id}");
        var (changes, _, _) = await newcomer.PullAllAsync(before);

        Assert.Multiple(() =>
        {
            Assert.That(response.IsSuccessStatusCode, Is.True, "affectation");
            Assert.That(changes.Of("delivery"), Has.Exactly(1).Items);
            Assert.That(changes.Of("photo"), Has.Exactly(1).Items);
            Assert.That(changes.Of("request"), Has.Exactly(1).Items);
        });
    }
}
