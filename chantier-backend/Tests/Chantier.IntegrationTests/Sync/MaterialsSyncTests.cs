using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Materials;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Materials;
using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.MaterialsSyncKit;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;
using static Chantier.IntegrationTests.Support.SitesTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Sync;

/// <summary>
/// B9 (CT-MAT-17, 18) : synchronisation des demandes. Lecture : produits et fournisseurs globaux (<c>siteId</c> nul, jamais de telephone), demandes des chantiers
/// affectes. Ecriture : creation idempotente, modification a trois valeurs (premiere arrivee retenue, tout ou rien), transitions (le serveur gagne), journal
/// d'operations (un renvoi ne fait jamais de faux conflit).
/// </summary>
[TestFixture]
public class MaterialsSyncTests : MaterialsFixtureBase
{
    private async Task<JsonElement> PushOneAsync(ApiSession session, object operation)
    {
        var response = await session.PostAsync(PushUrl, new { operations = new[] { operation } });
        Assert.That((int)response.StatusCode, Is.EqualTo(200), string.Join(" | ", Factory.Logs.Entries.Where(entry => entry.StartsWith("[Error]", StringComparison.Ordinal)).TakeLast(2).Select(entry => entry.Length > 1500 ? entry[..1500] : entry)));
        return (await response.JsonAsync()).GetProperty("results")[0];
    }

    private async Task<JsonElement> RequestAsync(ApiSession session, Guid siteId, Guid requestId)
        => await (await session.GetAsync(RequestUrl(siteId, requestId))).JsonAsync();

    // --- Lecture ---

    [Test]
    public async Task Products_and_suppliers_reach_every_user_without_a_site_and_a_supplier_never_carries_a_phone()
    {
        var product = await Admin.CreateProductAsync();
        var supplier = await Admin.CreateSupplierAsync(phone: "0550 11 22 33");
        var withoutSite = await Factory.SignInAsync(RoleNames.ChefEquipe);

        var (changes, deleted, _) = await withoutSite.PullAllAsync();
        var products = changes.Of("product").ToList();
        var suppliers = changes.Of("supplier").ToList();
        var theProduct = products.Single(row => row.GetProperty("id").GetGuid() == product.Id());
        var theSupplier = suppliers.Single(row => row.GetProperty("id").GetGuid() == supplier.Id());

        Assert.Multiple(() =>
        {
            Assert.That(theProduct.GetProperty("siteId").ValueKind, Is.EqualTo(JsonValueKind.Null), "entite globale : pas de chantier");
            Assert.That(theSupplier.GetProperty("siteId").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(theProduct.GetProperty("data").GetProperty("allowedUnits").GetArrayLength(), Is.EqualTo(3));
            Assert.That(theProduct.GetProperty("data").GetProperty("bagMassKg").GetDecimal(), Is.EqualTo(50m));
            Assert.That(theSupplier.GetProperty("data").GetProperty("name").GetString(), Is.EqualTo(supplier.GetProperty("name").GetString()));
            Assert.That(theSupplier.GetRawText(), Does.Not.Contain("phone").And.Not.Contain("0550"), "jamais de telephone dans la synchronisation");
            Assert.That(deleted.Of("product").Concat(deleted.Of("supplier")), Is.Empty, "pas de pierre tombale : on desactive");
        });
    }

    [Test]
    public async Task A_supplier_row_has_no_phone_even_for_the_roles_that_read_it_online()
    {
        var supplier = await Admin.CreateSupplierAsync(phone: "0661 44 55 66");

        foreach (var session in new[] { Admin, Achats, Conducteur, Chef })
        {
            var online = await (await session.GetAsync($"{Suppliers}/{supplier.Id()}")).JsonAsync();
            var (changes, _, _) = await session.PullAllAsync();
            var row = changes.Of("supplier").Single(candidate => candidate.GetProperty("id").GetGuid() == supplier.Id());

            Assert.Multiple(() =>
            {
                Assert.That(online.TryGetProperty("phone", out _), Is.True, $"{session.Account.Role} le lit en ligne");
                Assert.That(row.GetRawText(), Does.Not.Contain("phone").And.Not.Contain("0661"), $"{session.Account.Role} : jamais dans la synchronisation");
            });
        }
    }

    [Test]
    public async Task A_deactivated_product_is_resent_with_its_new_state_and_never_as_a_tombstone()
    {
        var product = await Admin.CreateProductAsync();
        var (_, _, cursor) = await Chef.PullAllAsync();

        await Admin.PostAsync($"{Products}/{product.Id()}/deactivate");
        var (changes, deleted, _) = await Chef.PullAllAsync(cursor);

        var row = changes.Of("product").Single(candidate => candidate.GetProperty("id").GetGuid() == product.Id());
        Assert.Multiple(() =>
        {
            Assert.That(row.GetProperty("data").GetProperty("isActive").GetBoolean(), Is.False);
            Assert.That(deleted.Of("product"), Is.Empty);
        });
    }

    [Test]
    public async Task Requests_reach_the_assigned_users_only_in_the_synchronisation_form()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "Dalle"));
        await Conducteur.PostAsync($"{RequestUrl(site.Id, created.Id())}/approve");
        var outsider = await Factory.SignInAsync(RoleNames.ChefChantier);

        var (mine, _, _) = await Equipe.PullAllAsync(siteId: site.Id);
        var (theirs, _, _) = await outsider.PullAllAsync();
        var row = mine.Of("request").Single();
        var data = row.GetProperty("data");

        Assert.Multiple(async () =>
        {
            Assert.That(row.GetProperty("siteId").GetGuid(), Is.EqualTo(site.Id));
            Assert.That(row.GetProperty("id").GetGuid(), Is.EqualTo(created.Id()));
            Assert.That(data.GetProperty("number").GetString(), Is.EqualTo("DEM-001"));
            Assert.That(data.GetProperty("status").GetString(), Is.EqualTo("Validated"));
            Assert.That(data.TryGetProperty("siteCode", out _), Is.False, "forme de synchronisation : pas de code de chantier");
            Assert.That(data.GetProperty("history").GetArrayLength(), Is.Zero, "R2-02 : aucun historique dans la synchronisation");
            Assert.That((await (await Conducteur.GetAsync(RequestUrl(site.Id, created.Id()))).JsonAsync()).HistoryTypes(), Is.EqualTo(new[] { "Created", "Approved" }), "l'historique se lit a la demande");
            Assert.That(theirs.Of("request"), Is.Empty, "un chantier non affecte n'envoie aucune demande");
        });
    }

    [Test]
    public async Task Archived_requests_are_still_sent_with_their_archive_date_and_no_tombstone()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));
        await Conducteur.PostAsync($"{RequestUrl(site.Id, created.Id())}/cancel", new { reasonCode = "EntryError" });
        await Conducteur.PostAsync($"{RequestUrl(site.Id, created.Id())}/archive");

        var (changes, deleted, _) = await Chef.PullAllAsync(siteId: site.Id);

        var data = changes.Of("request").Single().GetProperty("data");
        Assert.Multiple(() =>
        {
            Assert.That(data.GetProperty("archivedAt").ValueKind, Is.EqualTo(JsonValueKind.String));
            Assert.That(deleted.Of("request"), Is.Empty);
        });
    }

    [Test]
    public async Task A_new_assignment_on_a_site_with_old_requests_sends_them_and_a_removal_cuts_the_access()
    {
        var site = await NewSiteAsync();
        await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));
        await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 100m));
        var newcomer = await Factory.SignInAsync(RoleNames.ChefEquipe);
        var (_, _, before) = await newcomer.PullAllAsync();

        var assigned = await Admin.PutAsync($"{SiteBase}/{site.Id}/members/{newcomer.Account.Id}");
        var (afterAssignment, _, cursor) = await newcomer.PullAllAsync(before);
        await Admin.DeleteAsync($"{SiteBase}/{site.Id}/members/{newcomer.Account.Id}");
        var (afterRemoval, deleted, _) = await newcomer.PullAllAsync(cursor);

        Assert.Multiple(() =>
        {
            Assert.That(assigned.IsSuccessStatusCode, Is.True);
            Assert.That(afterAssignment.Of("request"), Has.Exactly(2).Items, "les demandes anciennes sont renvoyees au nouvel affecte");
            Assert.That(deleted.Of("site").Select(row => row.GetProperty("id").GetGuid()), Does.Contain(site.Id), "le retrait supprime le chantier cote telephone");
            Assert.That(afterRemoval.Of("request"), Is.Empty);
        });
    }

    [Test]
    public async Task No_price_phone_or_commercial_field_is_ever_in_the_rows_a_chef_chantier_or_achats_receives()
    {
        var site = await NewSiteAsync();
        var supplier = await Admin.CreateSupplierAsync(phone: "0770 12 34 56");
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "Livraison lundi"));
        await Conducteur.PostAsync($"{RequestUrl(site.Id, created.Id())}/approve");
        await Chef.PushAsync(RequestUpdate(Guid.NewGuid(), site.Id, new() { ["note"] = "Mardi" }, new() { ["note"] = "Livraison lundi" }, requestId: created.Id()));

        foreach (var session in new[] { Chef, Achats, Conducteur, Admin })
        {
            var (changes, _, _) = await session.PullAllAsync(siteId: site.Id);
            var text = string.Join('\n', changes.Select(row => row.GetRawText()));

            Assert.Multiple(() =>
            {
                Assert.That(changes.Of("request"), Is.Not.Empty, session.Account.Role);
                foreach (var word in ForbiddenWords)
                {
                    Assert.That(text, Does.Not.Contain(word), $"{session.Account.Role} : « {word} » ne doit jamais atteindre le telephone");
                }
            });
        }

        Assert.That(supplier.Id(), Is.Not.EqualTo(Guid.Empty));
    }

    // --- Creation ---

    [Test]
    public async Task A_request_created_offline_is_applied_once_with_its_number_and_a_resend_answers_duplicate()
    {
        var site = await NewSiteAsync();
        var clientId = Guid.NewGuid();
        var operation = RequestCreate(clientId, site.Id, CementId, 300m, "sac", note: "Dalle");

        var first = await PushOneAsync(Equipe, operation);
        var again = await PushOneAsync(Equipe, operation);
        var next = await PushOneAsync(Equipe, RequestCreate(Guid.NewGuid(), site.Id, CementId, 50m));

        Assert.Multiple(async () =>
        {
            Assert.That(first.Status(), Is.EqualTo("applied"));
            Assert.That(first.Resource().GetProperty("number").GetString(), Is.EqualTo("DEM-001"));
            Assert.That(first.Resource().GetProperty("clientId").GetGuid(), Is.EqualTo(clientId));
            Assert.That(first.Resource().GetProperty("status").GetString(), Is.EqualTo("Requested"));
            Assert.That(first.Resource().GetProperty("history").GetArrayLength(), Is.Zero, "R2-02 : aucun historique dans la reponse de synchronisation");
            var history = (await (await Equipe.GetAsync(RequestUrl(site.Id, first.Resource().Id()))).JsonAsync()).GetProperty("history");
            Assert.That(history.GetArrayLength(), Is.EqualTo(1));
            Assert.That(history[0].GetProperty("source").GetString(), Is.EqualTo("Sync"));
            Assert.That(history[0].GetProperty("deviceAt").GetDateTimeOffset(), Is.EqualTo(DateTimeOffset.Parse("2026-11-25T06:58:00Z")), "« saisi le » du telephone");
            Assert.That(again.Status(), Is.EqualTo("duplicate"));
            Assert.That(again.Resource().GetProperty("id").GetGuid(), Is.EqualTo(first.Resource().GetProperty("id").GetGuid()));
            Assert.That(next.Resource().GetProperty("number").GetString(), Is.EqualTo("DEM-002"), "le renvoi n'a consomme aucun numero");
            Assert.That(await Factory.CountRequestsAsync(site.Id), Is.EqualTo(2));
        });
    }

    [Test]
    public async Task A_create_answers_in_the_synchronisation_form_without_the_site_code_or_any_commercial_field()
    {
        var site = await NewSiteAsync();

        var result = await PushOneAsync(Chef, RequestCreate(Guid.NewGuid(), site.Id, CementId));

        Assert.That(ForbiddenWords.Where(word => result.GetRawText().Contains(word, StringComparison.Ordinal)), Is.Empty);
    }

    [Test]
    public async Task A_zone_created_offline_in_the_same_batch_is_designated_by_its_client_id()
    {
        var site = await NewSiteAsync();
        var zoneClientId = Guid.NewGuid();

        var results = await Chef.PushAsync(
            ZoneOperation(zoneClientId, site.Id, "Bloc 05"),
            RequestCreate(Guid.NewGuid(), site.Id, CementId, zoneClientId: zoneClientId));

        Assert.Multiple(() =>
        {
            Assert.That(results[0].Status(), Is.EqualTo("applied"));
            Assert.That(results[1].Status(), Is.EqualTo("applied"));
            Assert.That(results[1].Resource().GetProperty("zoneId").GetGuid(), Is.EqualTo(results[0].Resource().GetProperty("id").GetGuid()));
        });
    }

    [Test]
    public async Task An_unknown_zone_client_id_is_rejected_as_not_found_and_nothing_is_written()
    {
        var site = await NewSiteAsync();

        var result = await PushOneAsync(Chef, RequestCreate(Guid.NewGuid(), site.Id, CementId, zoneClientId: Guid.NewGuid()));

        Assert.Multiple(async () =>
        {
            Assert.That(result.Status(), Is.EqualTo("rejected"));
            Assert.That(result.Code(), Is.EqualTo("INTROUVABLE"));
            Assert.That(await Factory.CountRequestsAsync(site.Id), Is.Zero);
        });
    }

    [Test]
    public async Task A_create_with_invalid_content_is_rejected_with_the_business_code()
    {
        var site = await NewSiteAsync();
        var foreignZone = await Factory.SeedZoneAsync((await NewSiteAsync()).Id);

        var cases = new (string Name, object Operation, string Code)[]
        {
            ("sans unite", RequestCreate(Guid.NewGuid(), site.Id, CementId, unit: null), "UNITE_OBLIGATOIRE"),
            ("quantite nulle", RequestCreate(Guid.NewGuid(), site.Id, CementId, value: 0m), "QUANTITE_INVALIDE"),
            ("sac decimal", RequestCreate(Guid.NewGuid(), site.Id, CementId, value: 2.5m), "QUANTITE_ENTIERE_REQUISE"),
            ("date incomplete", RequestCreate(Guid.NewGuid(), site.Id, CementId, neededBy: "../12/2026"), "DATE_INVALIDE"),
            ("date impossible", RequestCreate(Guid.NewGuid(), site.Id, CementId, neededBy: "2026-11-31"), "DATE_INVALIDE"),
            ("unite hors liste", RequestCreate(Guid.NewGuid(), site.Id, SteelId, unit: "sac"), "UNITE_NON_AUTORISEE"),
            ("zone d'un autre chantier", RequestCreate(Guid.NewGuid(), site.Id, CementId, zoneId: foreignZone), "ZONE_HORS_CHANTIER"),
            ("ni produit ni nom", RequestCreate(Guid.NewGuid(), site.Id, null), "VALIDATION"),
        };

        var results = await Chef.PushAsync(cases.Select(entry => entry.Operation).ToArray());

        Assert.Multiple(() =>
        {
            for (var index = 0; index < cases.Length; index++)
            {
                Assert.That(results[index].Status(), Is.EqualTo("rejected"), cases[index].Name);
                Assert.That(results[index].Code(), Is.EqualTo(cases[index].Code), cases[index].Name);
            }
        });
    }

    [Test]
    public async Task A_create_on_a_site_that_is_not_assigned_is_rejected_as_not_found_and_on_an_archived_site_as_archived()
    {
        var outsider = await NewSiteAsync();
        var lonely = await Factory.SignInAsync(RoleNames.ChefChantier);
        var archived = await NewSiteAsync(archived: true);

        var notAssigned = await PushOneAsync(lonely, RequestCreate(Guid.NewGuid(), outsider.Id, CementId));
        var unknownSite = await PushOneAsync(lonely, RequestCreate(Guid.NewGuid(), Guid.NewGuid(), CementId));
        var onArchived = await PushOneAsync(Chef, RequestCreate(Guid.NewGuid(), archived.Id, CementId));

        Assert.Multiple(() =>
        {
            Assert.That(notAssigned.Code(), Is.EqualTo("INTROUVABLE"));
            Assert.That(unknownSite.Code(), Is.EqualTo("INTROUVABLE"), "meme refus qu'un chantier inexistant");
            Assert.That(onArchived.Status(), Is.EqualTo("rejected"));
            Assert.That(onArchived.Code(), Is.EqualTo("CHANTIER_ARCHIVE"));
        });
    }

    [Test]
    public async Task A_role_without_the_right_to_create_is_rejected_and_the_rest_of_the_batch_goes_through()
    {
        var site = await NewSiteAsync();

        var denied = await PushOneAsync(Direction, RequestCreate(Guid.NewGuid(), site.Id, CementId));
        var achats = await PushOneAsync(Achats, RequestCreate(Guid.NewGuid(), site.Id, CementId));
        var mixed = await Equipe.PushAsync(
            RequestCreate(Guid.NewGuid(), site.Id, CementId, unit: null),
            RequestCreate(Guid.NewGuid(), site.Id, CementId, 40m));

        Assert.Multiple(() =>
        {
            Assert.That(denied.Code(), Is.EqualTo("INTERDIT"));
            Assert.That(achats.Code(), Is.EqualTo("INTERDIT"));
            Assert.That(mixed[0].Status(), Is.EqualTo("rejected"));
            Assert.That(mixed[1].Status(), Is.EqualTo("applied"), "un lot reussit partiellement");
        });
    }

    [Test]
    public async Task The_phone_cannot_set_the_status_the_number_or_the_author_through_the_payload()
    {
        var site = await NewSiteAsync();
        var operation = RequestCreate(Guid.NewGuid(), site.Id, CementId, overrides: payload =>
        {
            payload["status"] = "Delivered";
            payload["number"] = "DEM-999";
            payload["createdBy"] = Admin.Account.Id;
            payload["isSettled"] = true;
        });

        var result = await PushOneAsync(Equipe, operation);

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("applied"));
            Assert.That(result.Resource().GetProperty("status").GetString(), Is.EqualTo("Requested"));
            Assert.That(result.Resource().GetProperty("number").GetString(), Is.EqualTo("DEM-001"));
            Assert.That(result.Resource().GetProperty("requestedById").GetGuid(), Is.EqualTo(Equipe.Account.Id));
        });
    }

    [Test]
    public async Task Twenty_requests_and_a_lot_of_duplicates_sent_at_once_give_twenty_numbers_without_gap()
    {
        var site = await NewSiteAsync();
        var operations = Enumerable.Range(1, 20).Select(index => RequestCreate(Guid.NewGuid(), site.Id, CementId, index)).ToList();

        var first = await Chef.PushAsync(operations.Cast<object>().ToArray());
        var replay = await Chef.PushAsync(operations.Cast<object>().ToArray());

        Assert.Multiple(async () =>
        {
            Assert.That(first.EnumerateArray().Select(result => result.Resource().GetProperty("number").GetString()), Is.EqualTo(Enumerable.Range(1, 20).Select(index => $"DEM-{index:000}")));
            Assert.That(replay.EnumerateArray().Select(result => result.Status()), Has.All.EqualTo("duplicate"));
            Assert.That(await Factory.CountRequestsAsync(site.Id), Is.EqualTo(20));
        });
    }

    // --- Modification (CA-MAT-010.2 a 010.5) ---

    [Test]
    public async Task A_request_edited_offline_then_validated_meanwhile_gives_a_conflict_and_nothing_is_applied()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 300m));
        await Conducteur.PostAsync($"{RequestUrl(site.Id, created.Id())}/approve");

        var result = await PushOneAsync(Chef, RequestUpdate(
            Guid.NewGuid(), site.Id, new() { ["quantity"] = new { value = 400, unit = "sac" } }, new() { ["quantity"] = new { value = 300, unit = "sac" } }, requestId: created.Id()));
        var after = await RequestAsync(Chef, site.Id, created.Id());

        Assert.Multiple(async () =>
        {
            Assert.That(result.Status(), Is.EqualTo("conflict"));
            Assert.That(result.Code(), Is.EqualTo("DEMANDE_VERROUILLEE"));
            Assert.That(result.Current().GetProperty("status").GetString(), Is.EqualTo("Validated"), "l'etat du serveur est renvoye");
            Assert.That(result.Current().GetProperty("quantity").GetProperty("value").GetDecimal(), Is.EqualTo(300m));
            Assert.That(after.GetProperty("quantity").GetProperty("value").GetDecimal(), Is.EqualTo(300m), "rien n'est applique");
            Assert.That(after.HistoryTypes(), Is.EqualTo(new[] { "Created", "Approved" }));
            Assert.That(await Factory.CountRequestsAsync(site.Id), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task A_quantity_adjusted_by_the_conductor_is_also_a_locked_conflict()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 300m));
        await Conducteur.PostAsync($"{RequestUrl(site.Id, created.Id())}/approve", new { quantity = new { value = 200, unit = "sac" } });

        var result = await PushOneAsync(Chef, RequestUpdate(
            Guid.NewGuid(), site.Id, new() { ["quantity"] = new { value = 400, unit = "sac" } }, new() { ["quantity"] = new { value = 300, unit = "sac" } }, requestId: created.Id()));

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("conflict"));
            Assert.That(result.Code(), Is.EqualTo("DEMANDE_VERROUILLEE"));
            Assert.That(result.Current().GetProperty("quantity").GetProperty("value").GetDecimal(), Is.EqualTo(200m));
        });
    }

    [Test]
    public async Task Two_phones_changing_the_same_date_keep_the_first_and_the_second_goes_to_review()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, neededBy: "2026-12-10"));
        var original = new Dictionary<string, object?> { ["neededBy"] = "2026-12-10" };

        var first = await PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["neededBy"] = "2026-12-12" }, original, requestId: created.Id()));
        var second = await PushOneAsync(Conducteur, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["neededBy"] = "2026-12-15" }, original, requestId: created.Id()));
        var after = await RequestAsync(Chef, site.Id, created.Id());

        Assert.Multiple(() =>
        {
            Assert.That(first.Status(), Is.EqualTo("applied"));
            Assert.That(second.Status(), Is.EqualTo("conflict"));
            Assert.That(second.Code(), Is.EqualTo("CONFLIT_VERSION"));
            Assert.That(second.ConflictFields(), Is.EqualTo(new[] { "neededBy" }));
            Assert.That(second.Current().GetProperty("neededBy").GetString(), Is.EqualTo("2026-12-12"));
            Assert.That(after.GetProperty("neededBy").GetString(), Is.EqualTo("2026-12-12"), "premiere arrivee retenue");
        });
    }

    [Test]
    public async Task Two_phones_changing_different_fields_have_both_changes_applied()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "Dalle", priority: "Normal"));

        var first = await PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["note"] = "Dalle haute" }, new() { ["note"] = "Dalle" }, requestId: created.Id()));
        var second = await PushOneAsync(Conducteur, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["priority"] = "Urgent" }, new() { ["priority"] = "Normal" }, requestId: created.Id()));
        var after = await RequestAsync(Chef, site.Id, created.Id());

        Assert.Multiple(() =>
        {
            Assert.That(first.Status(), Is.EqualTo("applied"));
            Assert.That(second.Status(), Is.EqualTo("applied"));
            Assert.That(after.GetProperty("note").GetString(), Is.EqualTo("Dalle haute"));
            Assert.That(after.GetProperty("priority").GetString(), Is.EqualTo("Urgent"));
        });
    }

    [Test]
    public async Task Both_phones_wanting_the_same_value_is_not_a_conflict()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, priority: "Normal"));
        var change = new Dictionary<string, object?> { ["priority"] = "Urgent" };
        var start = new Dictionary<string, object?> { ["priority"] = "Normal" };

        var first = await PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), site.Id, change, start, requestId: created.Id()));
        var second = await PushOneAsync(Conducteur, RequestUpdate(Guid.NewGuid(), site.Id, change, start, requestId: created.Id()));

        Assert.Multiple(() =>
        {
            Assert.That(first.Status(), Is.EqualTo("applied"));
            Assert.That(second.Status(), Is.EqualTo("duplicate"), "deja a la valeur voulue : rien a faire");
        });
    }

    [Test]
    public async Task One_conflicting_field_refuses_the_whole_operation_even_if_another_field_would_apply()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "Dalle", neededBy: "2026-12-10"));
        await Conducteur.PutAsync(RequestUrl(site.Id, created.Id()), new { version = created.Version(), neededBy = "2026-12-20" });

        var result = await PushOneAsync(Chef, RequestUpdate(
            Guid.NewGuid(),
            site.Id,
            new() { ["neededBy"] = "2026-12-12", ["note"] = "Dalle haute" },
            new() { ["neededBy"] = "2026-12-10", ["note"] = "Dalle" },
            requestId: created.Id()));
        var after = await RequestAsync(Chef, site.Id, created.Id());

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("conflict"));
            Assert.That(result.ConflictFields(), Is.EqualTo(new[] { "neededBy" }));
            Assert.That(after.GetProperty("note").GetString(), Is.EqualTo("Dalle"), "tout ou rien : la remarque n'est pas appliquee non plus");
        });
    }

    [Test]
    public async Task A_resent_update_never_makes_a_false_conflict_even_after_the_request_moved_on()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "Dalle"));
        var operationId = Guid.NewGuid();
        var operation = RequestUpdate(operationId, site.Id, new() { ["note"] = "Dalle haute" }, new() { ["note"] = "Dalle" }, requestId: created.Id());

        var first = await PushOneAsync(Chef, operation);
        await Conducteur.PutAsync(RequestUrl(site.Id, created.Id()), new { version = (await RequestAsync(Chef, site.Id, created.Id())).Version(), note = "Autre remarque" });
        var replay = await PushOneAsync(Chef, operation);
        var after = await RequestAsync(Chef, site.Id, created.Id());

        Assert.Multiple(() =>
        {
            Assert.That(first.Status(), Is.EqualTo("applied"));
            Assert.That(replay.Status(), Is.EqualTo("duplicate"), "la meme operation rend le meme resultat, jamais un faux conflit");
            Assert.That(after.GetProperty("note").GetString(), Is.EqualTo("Autre remarque"), "le renvoi n'ecrase rien");
            Assert.That(after.HistoryTypes().Count(type => type == "Edited"), Is.EqualTo(2));
        });
    }

    [Test]
    public async Task A_resent_conflict_gives_the_same_conflict_with_the_same_fields()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, neededBy: "2026-12-10"));
        await Conducteur.PutAsync(RequestUrl(site.Id, created.Id()), new { version = created.Version(), neededBy = "2026-12-20" });
        var operation = RequestUpdate(Guid.NewGuid(), site.Id, new() { ["neededBy"] = "2026-12-12" }, new() { ["neededBy"] = "2026-12-10" }, requestId: created.Id());

        var first = await PushOneAsync(Chef, operation);
        var replay = await PushOneAsync(Chef, operation);

        Assert.Multiple(() =>
        {
            Assert.That(replay.Status(), Is.EqualTo("conflict"));
            Assert.That(replay.Code(), Is.EqualTo(first.Code()));
            Assert.That(replay.ConflictFields(), Is.EqualTo(first.ConflictFields()));
            Assert.That(replay.Current().GetProperty("neededBy").GetString(), Is.EqualTo("2026-12-20"));
        });
    }

    [Test]
    public async Task A_resent_rejection_is_rejected_again_and_an_operation_id_taken_by_someone_else_is_refused()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));
        var operation = RequestTransition(Guid.NewGuid(), site.Id, "approve", requestId: created.Id());

        var denied = await PushOneAsync(Equipe, operation);
        var replay = await PushOneAsync(Equipe, operation);
        var stolen = await PushOneAsync(Chef, operation);

        Assert.Multiple(() =>
        {
            Assert.That(denied.Code(), Is.EqualTo("INTERDIT"));
            Assert.That(replay.Status(), Is.EqualTo("rejected"));
            Assert.That(replay.Code(), Is.EqualTo("INTERDIT"));
            Assert.That(stolen.Status(), Is.EqualTo("rejected"));
            Assert.That(stolen.GetRawText(), Does.Not.Contain(created.Number()), "aucun etat n'est rendu a quelqu'un d'autre");
        });
    }

    [Test]
    public async Task The_same_update_sent_twice_in_parallel_is_applied_once()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "Dalle"));
        var operation = RequestUpdate(Guid.NewGuid(), site.Id, new() { ["note"] = "Dalle haute" }, new() { ["note"] = "Dalle" }, requestId: created.Id());

        var results = await Task.WhenAll(Enumerable.Range(0, 4).Select(_ => PushOneAsync(Chef, operation)));
        var after = await RequestAsync(Chef, site.Id, created.Id());

        Assert.Multiple(() =>
        {
            Assert.That(results.Select(result => result.Status()), Has.None.EqualTo("conflict"));
            Assert.That(results.Count(result => result.Status() == "applied"), Is.EqualTo(1));
            Assert.That(after.HistoryTypes().Count(type => type == "Edited"), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task Two_phones_pushing_the_same_field_at_the_same_time_keep_one_and_report_the_other()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, neededBy: "2026-12-10"));
        var start = new Dictionary<string, object?> { ["neededBy"] = "2026-12-10" };

        var results = await Task.WhenAll(
            PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["neededBy"] = "2026-12-11" }, start, requestId: created.Id())),
            PushOneAsync(Conducteur, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["neededBy"] = "2026-12-12" }, start, requestId: created.Id())),
            PushOneAsync(Admin, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["neededBy"] = "2026-12-13" }, start, requestId: created.Id())));

        Assert.Multiple(() =>
        {
            Assert.That(results.Count(result => result.Status() == "applied"), Is.EqualTo(1));
            Assert.That(results.Count(result => result.Status() == "conflict"), Is.EqualTo(2));
        });
    }

    [Test]
    public async Task An_update_refuses_unknown_or_protected_fields_and_a_missing_start_value()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));

        var status = await PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["status"] = "Delivered" }, new() { ["status"] = "Requested" }, requestId: created.Id()));
        var noBase = await PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["note"] = "x" }, new(), requestId: created.Id()));
        var badDate = await PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["neededBy"] = "31/11/2026" }, new() { ["neededBy"] = "2026-12-10" }, requestId: created.Id()));
        var noTarget = await PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["note"] = "x" }, new() { ["note"] = null }));
        var after = await RequestAsync(Chef, site.Id, created.Id());

        Assert.Multiple(() =>
        {
            Assert.That(status.Status(), Is.EqualTo("rejected"));
            Assert.That(status.Code(), Is.EqualTo("VALIDATION"));
            Assert.That(noBase.Code(), Is.EqualTo("VALIDATION"));
            Assert.That(badDate.Code(), Is.EqualTo("DATE_INVALIDE"));
            Assert.That(noTarget.Code(), Is.EqualTo("VALIDATION"));
            Assert.That(after.StatusOf(), Is.EqualTo("Requested"));
        });
    }

    [Test]
    public async Task A_request_created_and_edited_and_cancelled_in_one_batch_keeps_the_order_and_the_history()
    {
        var site = await NewSiteAsync();
        var requestClientId = Guid.NewGuid();

        var results = await Equipe.PushAsync(
            RequestCreate(requestClientId, site.Id, CementId, 300m, note: "Dalle"),
            RequestUpdate(Guid.NewGuid(), site.Id, new() { ["note"] = "Dalle haute" }, new() { ["note"] = "Dalle" }, requestClientId: requestClientId),
            RequestTransition(Guid.NewGuid(), site.Id, "cancel", requestClientId: requestClientId, reasonCode: "NoLongerNeeded"));
        var final = results[2].Resource();
        var detail = await (await Equipe.GetAsync(RequestUrl(site.Id, final.Id()))).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(results.EnumerateArray().Select(result => result.Status()), Is.EqualTo(new[] { "applied", "applied", "applied" }));
            Assert.That(final.GetProperty("status").GetString(), Is.EqualTo("Cancelled"));
            Assert.That(final.GetProperty("note").GetString(), Is.EqualTo("Dalle haute"));
            Assert.That(detail.HistoryTypes(), Is.EqualTo(new[] { "Created", "Edited", "Cancelled" }));
        });
    }

    [Test]
    public async Task A_team_member_editing_his_own_request_after_validation_is_in_conflict_for_the_locked_fields_and_rejected_for_the_rest()
    {
        var site = await NewSiteAsync();
        var created = await Equipe.CreateRequestAsync(site.Id, RequestBody(CementId, 300m, note: "Dalle"));
        await Conducteur.PostAsync($"{RequestUrl(site.Id, created.Id())}/approve");

        var locked = await PushOneAsync(Equipe, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["quantity"] = new { value = 400, unit = "sac" } }, new() { ["quantity"] = new { value = 300, unit = "sac" } }, requestId: created.Id()));
        var note = await PushOneAsync(Equipe, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["note"] = "Nouvelle" }, new() { ["note"] = "Dalle" }, requestId: created.Id()));
        var byChef = await PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["note"] = "Nouvelle" }, new() { ["note"] = "Dalle" }, requestId: created.Id()));

        Assert.Multiple(() =>
        {
            Assert.That(locked.Status(), Is.EqualTo("conflict"));
            Assert.That(locked.Code(), Is.EqualTo("DEMANDE_VERROUILLEE"));
            Assert.That(note.Status(), Is.EqualTo("rejected"), "date, urgence et remarque apres validation : UpdateAny");
            Assert.That(note.Code(), Is.EqualTo("INTERDIT"));
            Assert.That(byChef.Status(), Is.EqualTo("applied"));
        });
    }

    [Test]
    public async Task An_update_on_a_closed_request_is_a_conflict_and_on_another_site_it_is_not_found()
    {
        var site = await NewSiteAsync();
        var other = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "Dalle"));
        await Conducteur.PostAsync($"{RequestUrl(site.Id, created.Id())}/cancel", new { reasonCode = "Duplicate" });

        var closed = await PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), site.Id, new() { ["note"] = "x" }, new() { ["note"] = "Dalle" }, requestId: created.Id()));
        var wrongSite = await PushOneAsync(Chef, RequestUpdate(Guid.NewGuid(), other.Id, new() { ["note"] = "x" }, new() { ["note"] = "Dalle" }, requestId: created.Id()));

        Assert.Multiple(() =>
        {
            Assert.That(closed.Status(), Is.EqualTo("conflict"));
            Assert.That(closed.Code(), Is.EqualTo("TRANSITION_INTERDITE"));
            Assert.That(closed.Current().GetProperty("status").GetString(), Is.EqualTo("Cancelled"));
            Assert.That(wrongSite.Status(), Is.EqualTo("rejected"));
            Assert.That(wrongSite.Code(), Is.EqualTo("INTROUVABLE"));
        });
    }

    // --- Transitions (CA-MAT-003.5) ---

    [Test]
    public async Task A_validation_after_the_cancellation_is_a_conflict_and_the_server_state_wins()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));
        await Chef.PostAsync($"{RequestUrl(site.Id, created.Id())}/cancel", new { reasonCode = "EntryError" });

        var result = await PushOneAsync(Conducteur, RequestTransition(Guid.NewGuid(), site.Id, "approve", requestId: created.Id()));

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("conflict"));
            Assert.That(result.Code(), Is.EqualTo("TRANSITION_INTERDITE"));
            Assert.That(result.Current().GetProperty("status").GetString(), Is.EqualTo("Cancelled"));
            Assert.That(result.Current().GetProperty("statusReason").GetProperty("code").GetString(), Is.EqualTo("EntryError"));
        });
    }

    [Test]
    public async Task A_transition_to_a_state_already_reached_is_a_duplicate()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));
        await Conducteur.PostAsync($"{RequestUrl(site.Id, created.Id())}/approve");

        var result = await PushOneAsync(Admin, RequestTransition(Guid.NewGuid(), site.Id, "approve", requestId: created.Id()));

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("duplicate"), "« deja validee »");
            Assert.That(result.Resource().GetProperty("status").GetString(), Is.EqualTo("Validated"));
        });
    }

    [Test]
    public async Task Each_offline_transition_is_applied_with_the_rights_of_the_role_and_recorded_as_a_sync_event()
    {
        var site = await NewSiteAsync();
        var toApprove = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 300m));
        var toReject = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 20m));
        var toCancel = await Equipe.CreateRequestAsync(site.Id, RequestBody(CementId, 30m));
        var toReceive = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 40m));
        await Factory.SetStatusAsync(toReceive.Id(), RequestStatus.Delivered);

        var approved = await PushOneAsync(Conducteur, RequestTransition(Guid.NewGuid(), site.Id, "approve", requestId: toApprove.Id(), quantity: new { value = 200, unit = "sac" }));
        var rejected = await PushOneAsync(Conducteur, RequestTransition(Guid.NewGuid(), site.Id, "reject", requestId: toReject.Id(), reasonCode: "Other", reasonNote: "Stock suffisant"));
        var cancelled = await PushOneAsync(Equipe, RequestTransition(Guid.NewGuid(), site.Id, "cancel", requestId: toCancel.Id(), reasonCode: "EntryError"));
        var received = await PushOneAsync(Chef, RequestTransition(Guid.NewGuid(), site.Id, "receive", requestId: toReceive.Id(), note: "Conforme"));
        var approvedHistory = (await (await Conducteur.GetAsync(RequestUrl(site.Id, toApprove.Id()))).JsonAsync()).GetProperty("history").EnumerateArray().ToList();

        Assert.Multiple(() =>
        {
            Assert.That(approved.Status(), Is.EqualTo("applied"));
            Assert.That(approved.Resource().GetProperty("quantity").GetProperty("value").GetDecimal(), Is.EqualTo(200m));
            Assert.That(approvedHistory.Select(item => item.GetProperty("type").GetString()), Is.EqualTo(new[] { "Created", "QuantityAdjusted", "Approved" }));
            Assert.That(rejected.Resource().GetProperty("status").GetString(), Is.EqualTo("Rejected"));
            Assert.That(cancelled.Resource().GetProperty("status").GetString(), Is.EqualTo("Cancelled"));
            Assert.That(received.Resource().GetProperty("status").GetString(), Is.EqualTo("Received"));
            Assert.That(approvedHistory.Last().GetProperty("source").GetString(), Is.EqualTo("Sync"));
        });
    }

    [Test]
    public async Task A_transition_without_the_right_or_with_a_bad_reason_is_rejected_and_writes_nothing()
    {
        var site = await NewSiteAsync();
        var created = await Equipe.CreateRequestAsync(site.Id, RequestBody(CementId));
        var teams = await Equipe.CreateRequestAsync(site.Id, RequestBody(CementId, 10m));

        var teamApproves = await PushOneAsync(Equipe, RequestTransition(Guid.NewGuid(), site.Id, "approve", requestId: created.Id()));
        var chefCancelsTeams = await PushOneAsync(Chef, RequestTransition(Guid.NewGuid(), site.Id, "cancel", requestId: teams.Id(), reasonCode: "EntryError"));
        var noReason = await PushOneAsync(Conducteur, RequestTransition(Guid.NewGuid(), site.Id, "reject", requestId: created.Id()));
        var unknownAction = await PushOneAsync(Conducteur, RequestTransition(Guid.NewGuid(), site.Id, "settle", requestId: created.Id()));
        var wrongUnit = await PushOneAsync(Conducteur, RequestTransition(Guid.NewGuid(), site.Id, "approve", requestId: created.Id(), quantity: new { value = 15, unit = "t" }));

        Assert.Multiple(async () =>
        {
            Assert.That(teamApproves.Code(), Is.EqualTo("INTERDIT"));
            Assert.That(chefCancelsTeams.Code(), Is.EqualTo("INTERDIT"), "Q-MAT-01 c");
            Assert.That(noReason.Status(), Is.EqualTo("rejected"));
            Assert.That(noReason.Code(), Is.EqualTo("VALIDATION"));
            Assert.That(unknownAction.Code(), Is.EqualTo("VALIDATION"));
            Assert.That(wrongUnit.Code(), Is.EqualTo("UNITES_INCOMPATIBLES"));
            Assert.That((await RequestAsync(Chef, site.Id, created.Id())).StatusOf(), Is.EqualTo("Requested"));
            Assert.That((await RequestAsync(Chef, site.Id, teams.Id())).StatusOf(), Is.EqualTo("Requested"));
        });
    }

    [Test]
    public async Task A_transition_on_an_archived_site_is_rejected()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));
        await using (var scope = Factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            (await db.Sites.FindAsync(site.Id))!.Archive(SystemActorId, DateTimeOffset.UtcNow);
            await db.SaveChangesAsync();
        }

        var result = await PushOneAsync(Conducteur, RequestTransition(Guid.NewGuid(), site.Id, "approve", requestId: created.Id()));

        Assert.Multiple(async () =>
        {
            Assert.That(result.Status(), Is.EqualTo("rejected"));
            Assert.That(result.Code(), Is.EqualTo("CHANTIER_ARCHIVE"));
            Assert.That(await Factory.EventsOfAsync(created.Id()), Has.Count.EqualTo(1), "l'evenement ajoute avant le refus n'est pas ecrit");
        });
    }

    // --- Journal ---

    [Test]
    public async Task Update_and_transition_operations_are_journalised_and_creates_are_not()
    {
        var site = await NewSiteAsync();
        var createId = Guid.NewGuid();
        var updateId = Guid.NewGuid();
        var transitionId = Guid.NewGuid();
        var rejectedId = Guid.NewGuid();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "Dalle"));

        await Chef.PushAsync(
            RequestCreate(createId, site.Id, CementId, 10m),
            RequestUpdate(updateId, site.Id, new() { ["note"] = "Dalle haute" }, new() { ["note"] = "Dalle" }, requestId: created.Id()),
            RequestTransition(transitionId, site.Id, "cancel", requestId: created.Id(), reasonCode: "EntryError"),
            RequestTransition(rejectedId, site.Id, "approve", requestId: created.Id()));

        await using var scope = Factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var logs = await db.SyncOperationLogs.AsNoTracking().Where(log => log.SiteId == site.Id).ToDictionaryAsync(log => log.ClientId);

        Assert.Multiple(() =>
        {
            Assert.That(logs.ContainsKey(createId), Is.False, "une creation est idempotente par son index unique");
            Assert.That(logs[updateId].Outcome, Is.EqualTo("applied"));
            Assert.That(logs[transitionId].Outcome, Is.EqualTo("applied"));
            Assert.That(logs[rejectedId].Outcome, Is.EqualTo("rejected").Or.EqualTo("conflict"));
            Assert.That(logs[updateId].UserId, Is.EqualTo(Chef.Account.Id));
            Assert.That(logs[updateId].ResourceId, Is.EqualTo(created.Id()));
        });
    }

    [Test]
    public async Task The_journal_keeps_no_content_neither_price_nor_phone_nor_note()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "Secret de chantier"));
        await Chef.PushAsync(RequestUpdate(Guid.NewGuid(), site.Id, new() { ["note"] = "Autre secret" }, new() { ["note"] = "Secret de chantier" }, requestId: created.Id()));

        await using var scope = Factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var columns = db.Model.FindEntityType(typeof(Chantier.Core.Entities.Sync.SyncOperationLog))!.GetProperties().Select(property => property.Name).ToList();

        Assert.That(columns, Is.EquivalentTo(new[] { "ClientId", "UserId", "SiteId", "Entity", "Operation", "Outcome", "Code", "ResourceId", "ConflictFields", "CreatedAt" }));
    }

    // --- Concurrence avec les affectations ---

    [Test]
    public async Task Requests_created_while_people_are_assigned_never_deadlock_and_every_newcomer_gets_every_request()
    {
        var site = await NewSiteAsync();
        for (var index = 0; index < 5; index++)
        {
            await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 10 + index));
        }

        var newcomers = new List<ApiSession>();
        for (var index = 0; index < 5; index++)
        {
            newcomers.Add(await Factory.SignInAsync(RoleNames.ChefEquipe));
        }

        var assignments = newcomers.Select(newcomer => Task.Run(() => Admin.PutAsync($"{SiteBase}/{site.Id}/members/{newcomer.Account.Id}")));
        var creations = Enumerable.Range(0, 10).Select(index => Task.Run(() => Chef.PostAsync(RequestsUrl(site.Id), RequestBody(CementId, 100 + index))));
        var responses = await Task.WhenAll(assignments.Concat(creations));

        Assert.That(responses.Select(response => (int)response.StatusCode), Has.All.LessThan(500), string.Join(" | ", Factory.Logs.Entries.Where(entry => entry.StartsWith("[Error] Chantier", StringComparison.Ordinal)).Take(2).Select(entry => entry.Length > 1000 ? entry[..1000] : entry)));
        Assert.That(responses.Count(response => response.StatusCode == HttpStatusCode.Created), Is.EqualTo(15), "10 demandes et 5 affectations");

        foreach (var newcomer in newcomers)
        {
            var (changes, _, _) = await newcomer.PullAllAsync(siteId: site.Id);
            Assert.That(changes.Of("request"), Has.Exactly(15).Items, "5 anciennes + 10 nouvelles demandes, sans perte ni doublon.");
        }
    }
}
