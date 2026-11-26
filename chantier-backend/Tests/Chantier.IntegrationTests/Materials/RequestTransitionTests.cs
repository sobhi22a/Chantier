using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;
using static Chantier.IntegrationTests.Support.SitesTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>B4, transitions (CT-MAT-05, 06, 15) : table complete (statut, action), droits par role, motifs, idempotence, concurrence, historique.</summary>
[TestFixture]
public class RequestTransitionTests : MaterialsFixtureBase
{
    private string Url(Guid requestId, string action = "") => RequestUrl(Site.Id, requestId) + (action.Length == 0 ? string.Empty : "/" + action);

    private async Task<Guid> RequestInAsync(RequestStatus status, ApiSession? author = null, bool settled = false)
    {
        var id = await (author ?? Chef).NewRequestIdAsync(Site.Id, CementId);
        if (status != RequestStatus.Requested)
        {
            await Factory.SetStatusAsync(id, status, settled);

            // Livree partiellement = au moins une livraison vivante (sinon « solder » n'a rien a solder : TRANSITION_INTERDITE).
            if (status == RequestStatus.PartiallyDelivered)
            {
                await Factory.SeedDeliveryRowAsync(Site.Id, id);
            }
        }

        return id;
    }

    /// <summary>L'action de la table, jouee par un role qui a le droit : le conducteur (tout sauf receptionner) ou le chef de chantier (receptionner).</summary>
    private Task<HttpResponseMessage> Act(string action, Guid id) => action switch
    {
        "approve" => Conducteur.PostAsync(Url(id, "approve")),
        "reject" => Conducteur.PostAsync(Url(id, "reject"), new { reasonCode = "StockSufficient" }),
        "cancel" => Conducteur.PostAsync(Url(id, "cancel"), new { reasonCode = "EntryError" }),
        "receive" => Chef.PostAsync(Url(id, "receive")),
        "settle" => Conducteur.PostAsync(Url(id, "settle"), new { reasonCode = "QuantitySufficient" }),
        "archive" => Conducteur.PostAsync(Url(id, "archive")),
        _ => throw new ArgumentOutOfRangeException(nameof(action)),
    };

    private static readonly Dictionary<string, RequestStatus[]> Permitted = new()
    {
        ["approve"] = [RequestStatus.Requested, RequestStatus.Validated],
        ["reject"] = [RequestStatus.Requested, RequestStatus.Rejected],
        ["cancel"] = [RequestStatus.Requested, RequestStatus.Validated, RequestStatus.Cancelled],
        ["receive"] = [RequestStatus.Delivered, RequestStatus.Received],
        ["settle"] = [RequestStatus.PartiallyDelivered],
        ["archive"] = [RequestStatus.Rejected, RequestStatus.Cancelled, RequestStatus.Received],
    };

    public static IEnumerable<TestCaseData> TransitionTable()
        => from action in Permitted.Keys
           from status in Enum.GetValues<RequestStatus>()
           select new TestCaseData(status, action, Permitted[action].Contains(status)).SetName($"{status} + {action}");

    [TestCaseSource(nameof(TransitionTable))]
    public async Task The_transition_table_permits_exactly_the_documented_pairs(RequestStatus status, string action, bool permitted)
    {
        var id = await RequestInAsync(status);

        var response = await Act(action, id);

        if (permitted)
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), await response.Content.ReadAsStringAsync());
        }
        else
        {
            Assert.Multiple(async () =>
            {
                Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
                Assert.That(await CodeOf(response), Is.EqualTo("TRANSITION_INTERDITE"));
            });
        }
    }

    [Test]
    public async Task A_refused_transition_writes_nothing()
    {
        var id = await RequestInAsync(RequestStatus.Rejected);
        var before = await Factory.EventsOfAsync(id);

        await Act("approve", id);
        await Act("receive", id);

        Assert.That(await Factory.EventsOfAsync(id), Has.Count.EqualTo(before.Count));
    }

    // --- Valider ---

    [Test]
    public async Task Approving_moves_to_validated_and_keeps_the_history()
    {
        var id = await RequestInAsync(RequestStatus.Requested);

        var json = await (await Conducteur.PostAsync(Url(id, "approve"))).JsonAsync();
        var history = json.GetProperty("history").EnumerateArray().ToList();

        Assert.Multiple(() =>
        {
            Assert.That(json.StatusOf(), Is.EqualTo("Validated"));
            Assert.That(json.HistoryTypes(), Is.EqualTo(new[] { "Created", "Approved" }));
            Assert.That(history[1].GetProperty("fromStatus").GetString(), Is.EqualTo("Requested"));
            Assert.That(history[1].GetProperty("toStatus").GetString(), Is.EqualTo("Validated"));
            Assert.That(history[1].GetProperty("actorName").GetString(), Is.EqualTo(Conducteur.Account.FullName));
            Assert.That(history[1].GetProperty("source").GetString(), Is.EqualTo("Api"));
            Assert.That(history[1].GetProperty("occurredAt").GetDateTimeOffset(), Is.EqualTo(Factory.Time.GetUtcNow()).Within(TimeSpan.FromSeconds(1)), "heure du serveur");
        });
    }

    [Test]
    public async Task Approving_twice_answers_200_without_a_second_event()
    {
        var id = await RequestInAsync(RequestStatus.Requested);

        var first = await Conducteur.PostAsync(Url(id, "approve"));
        var second = await Conducteur.PostAsync(Url(id, "approve"));

        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(second.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(await Factory.EventsOfAsync(id), Has.Count.EqualTo(2), "Created + Approved");
        });
    }

    [Test]
    public async Task Two_conductors_approving_in_parallel_write_one_approval_and_both_get_200()
    {
        var id = await RequestInAsync(RequestStatus.Requested);

        var responses = await Task.WhenAll(
            Conducteur.PostAsync(Url(id, "approve")),
            Admin.PostAsync(Url(id, "approve")),
            Conducteur.PostAsync(Url(id, "approve")),
            Admin.PostAsync(Url(id, "approve")));

        var events = await Factory.EventsOfAsync(id);
        Assert.Multiple(() =>
        {
            Assert.That(responses.Select(response => response.StatusCode), Is.All.EqualTo(HttpStatusCode.OK));
            Assert.That(events.Count(materialEvent => materialEvent.Type == MaterialEventType.Approved), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task Approving_with_another_quantity_records_the_old_and_new_values()
    {
        var id = await RequestInAsync(RequestStatus.Requested);

        var response = await Conducteur.PostAsync(Url(id, "approve"), new { quantity = new { value = 200, unit = "sac" } });
        var json = await response.JsonAsync();
        var adjusted = json.GetProperty("history").EnumerateArray().Single(item => item.GetProperty("type").GetString() == "QuantityAdjusted");
        var change = adjusted.GetProperty("changes")[0];

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(json.GetProperty("quantity").GetProperty("value").GetDecimal(), Is.EqualTo(200m));
            Assert.That(json.StatusOf(), Is.EqualTo("Validated"));
            Assert.That(json.HistoryTypes(), Is.EqualTo(new[] { "Created", "QuantityAdjusted", "Approved" }));
            Assert.That(change.GetProperty("field").GetString(), Is.EqualTo("quantity"));
            Assert.That(change.GetProperty("old").GetString(), Is.EqualTo("300 sac"));
            Assert.That(change.GetProperty("new").GetString(), Is.EqualTo("200 sac"));
        });
    }

    [Test]
    public async Task An_adjusted_quantity_must_keep_the_unit_and_stay_positive()
    {
        var id = await RequestInAsync(RequestStatus.Requested);

        var otherUnit = await Conducteur.PostAsync(Url(id, "approve"), new { quantity = new { value = 15, unit = "t" } });
        var noUnit = await Conducteur.PostAsync(Url(id, "approve"), new { quantity = new { value = 200 } });
        var zero = await Conducteur.PostAsync(Url(id, "approve"), new { quantity = new { value = 0, unit = "sac" } });
        var decimals = await Conducteur.PostAsync(Url(id, "approve"), new { quantity = new { value = 2.5, unit = "sac" } });

        Assert.Multiple(async () =>
        {
            Assert.That(await CodeOf(otherUnit), Is.EqualTo("UNITES_INCOMPATIBLES"));
            Assert.That(await CodeOf(noUnit), Is.EqualTo("UNITE_OBLIGATOIRE"));
            Assert.That(await CodeOf(zero), Is.EqualTo("QUANTITE_INVALIDE"));
            Assert.That(await CodeOf(decimals), Is.EqualTo("QUANTITE_ENTIERE_REQUISE"));
            Assert.That((await (await Conducteur.GetAsync(Url(id))).JsonAsync()).StatusOf(), Is.EqualTo("Requested"), "un refus n'a rien ecrit");
        });
    }

    [Test]
    public async Task Approving_an_already_validated_request_with_another_quantity_is_locked_but_with_the_same_quantity_is_a_no_op()
    {
        var id = await RequestInAsync(RequestStatus.Requested);
        await Conducteur.PostAsync(Url(id, "approve"));

        var other = await Conducteur.PostAsync(Url(id, "approve"), new { quantity = new { value = 100, unit = "sac" } });
        var same = await Conducteur.PostAsync(Url(id, "approve"), new { quantity = new { value = 300, unit = "sac" } });

        Assert.Multiple(async () =>
        {
            Assert.That(other.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(other), Is.EqualTo("DEMANDE_VERROUILLEE"));
            Assert.That(same.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    // --- Refuser, annuler, motifs ---

    [Test]
    public async Task A_reason_from_the_list_is_required_to_reject_cancel_and_settle()
    {
        var requested = await RequestInAsync(RequestStatus.Requested);
        var partial = await RequestInAsync(RequestStatus.PartiallyDelivered);

        var results = new Dictionary<string, HttpResponseMessage>
        {
            ["reject sans motif"] = await Conducteur.PostAsync(Url(requested, "reject"), new { }),
            ["reject motif d'un autre cas"] = await Conducteur.PostAsync(Url(requested, "reject"), new { reasonCode = "EntryError" }),
            ["reject autre sans remarque"] = await Conducteur.PostAsync(Url(requested, "reject"), new { reasonCode = "Other" }),
            ["cancel sans motif"] = await Conducteur.PostAsync(Url(requested, "cancel"), new { reasonCode = "" }),
            ["cancel remarque trop longue"] = await Conducteur.PostAsync(Url(requested, "cancel"), new { reasonCode = "Other", reasonNote = new string('x', 201) }),
            ["settle sans motif"] = await Conducteur.PostAsync(Url(partial, "settle"), new { }),
        };

        Assert.Multiple(async () =>
        {
            foreach (var (name, response) in results)
            {
                Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest), name);
                Assert.That(await CodeOf(response), Is.EqualTo("VALIDATION"), name);
            }

            Assert.That((await (await Conducteur.GetAsync(Url(requested))).JsonAsync()).StatusOf(), Is.EqualTo("Requested"));
        });
    }

    [Test]
    public async Task Rejecting_keeps_the_reason_and_the_note_in_the_response_and_the_history()
    {
        var id = await RequestInAsync(RequestStatus.Requested);

        var json = await (await Conducteur.PostAsync(Url(id, "reject"), new { reasonCode = "Other", reasonNote = "Stock suffisant au bloc 2" })).JsonAsync();
        var last = json.GetProperty("history").EnumerateArray().Last();

        Assert.Multiple(() =>
        {
            Assert.That(json.StatusOf(), Is.EqualTo("Rejected"));
            Assert.That(json.GetProperty("statusReason").GetProperty("code").GetString(), Is.EqualTo("Other"));
            Assert.That(json.GetProperty("statusReason").GetProperty("note").GetString(), Is.EqualTo("Stock suffisant au bloc 2"));
            Assert.That(last.GetProperty("type").GetString(), Is.EqualTo("Rejected"));
            Assert.That(last.GetProperty("reasonCode").GetString(), Is.EqualTo("Other"));
        });
    }

    [Test]
    public async Task Cancelling_twice_gives_200_and_keeps_the_first_reason()
    {
        var id = await RequestInAsync(RequestStatus.Requested);

        await Conducteur.PostAsync(Url(id, "cancel"), new { reasonCode = "EntryError" });
        var second = await Conducteur.PostAsync(Url(id, "cancel"), new { reasonCode = "NoLongerNeeded" });
        var json = await second.JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(second.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(json.GetProperty("statusReason").GetProperty("code").GetString(), Is.EqualTo("EntryError"));
            Assert.That((await Factory.EventsOfAsync(id)).Count(materialEvent => materialEvent.Type == MaterialEventType.Cancelled), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task An_ordered_request_cannot_be_cancelled_by_the_requester()
    {
        var id = await RequestInAsync(RequestStatus.Ordered, Equipe);

        var response = await Equipe.PostAsync(Url(id, "cancel"), new { reasonCode = "EntryError" });

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo("TRANSITION_INTERDITE"));
        });
    }

    [Test]
    public async Task A_team_member_cancels_his_own_request_but_not_a_colleagues_and_the_chef_chantier_does_not_cancel_his_teams()
    {
        var own = await RequestInAsync(RequestStatus.Requested, Equipe);
        var teams = await RequestInAsync(RequestStatus.Requested, Equipe);
        var chefs = await RequestInAsync(RequestStatus.Requested, Chef);

        var ownResult = await Equipe.PostAsync(Url(own, "cancel"), new { reasonCode = "EntryError" });
        var chefOnTeams = await Chef.PostAsync(Url(teams, "cancel"), new { reasonCode = "EntryError" });
        var teamOnChefs = await Equipe.PostAsync(Url(chefs, "cancel"), new { reasonCode = "EntryError" });
        var chefOnOwn = await Chef.PostAsync(Url(chefs, "cancel"), new { reasonCode = "EntryError" });
        var conducteurOnTeams = await Conducteur.PostAsync(Url(teams, "cancel"), new { reasonCode = "Duplicate" });

        Assert.Multiple(() =>
        {
            Assert.That(ownResult.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(chefOnTeams.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden), "Q-MAT-01 c : le chef de chantier n'annule que les siennes");
            Assert.That(teamOnChefs.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(chefOnOwn.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(conducteurOnTeams.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    // --- Droits par role ---

    public static IEnumerable<TestCaseData> RoleMatrix()
    {
        // (action, roles autorises) ; tous les autres roles : 403 et rien d'ecrit.
        var rows = new (string Action, string[] Allowed)[]
        {
            ("approve", [RoleNamesOf.Admin, RoleNamesOf.Conducteur]),
            ("reject", [RoleNamesOf.Admin, RoleNamesOf.Conducteur]),
            ("receive", [RoleNamesOf.Admin, RoleNamesOf.Chef]),
            ("settle", [RoleNamesOf.Admin, RoleNamesOf.Conducteur, RoleNamesOf.Achats]),
            ("archive", [RoleNamesOf.Admin, RoleNamesOf.Conducteur]),
            ("restore", [RoleNamesOf.Admin, RoleNamesOf.Conducteur]),
            ("link-product", [RoleNamesOf.Admin, RoleNamesOf.Achats]),
        };

        foreach (var (action, allowed) in rows)
        {
            foreach (var role in new[] { RoleNamesOf.Admin, RoleNamesOf.Direction, RoleNamesOf.Conducteur, RoleNamesOf.Achats, RoleNamesOf.Chef, RoleNamesOf.Equipe })
            {
                yield return new TestCaseData(action, role, allowed.Contains(role)).SetName($"{action} par {role}");
            }
        }
    }

    [TestCaseSource(nameof(RoleMatrix))]
    public async Task Each_action_is_reserved_to_its_roles_and_a_refusal_writes_nothing(string action, string role, bool allowed)
    {
        var session = AllSessions.Single(candidate => candidate.Account.Role == role);
        var steel = (await Admin.CreateSteelAsync()).Id();
        var id = action switch
        {
            "receive" => await RequestInAsync(RequestStatus.Delivered),
            "settle" => await RequestInAsync(RequestStatus.PartiallyDelivered),
            "archive" => await RequestInAsync(RequestStatus.Rejected),
            "restore" => await RequestInAsync(RequestStatus.Rejected),
            "link-product" => (await Chef.CreateRequestAsync(Site.Id, RequestBody(null, 2m, "t", freeName: "Rond maison"))).Id(),
            _ => await RequestInAsync(RequestStatus.Requested),
        };

        var before = (await Factory.EventsOfAsync(id)).Count;
        var response = await session.PostAsync(Url(id, action), action switch
        {
            "reject" => new { reasonCode = "StockSufficient" },
            "settle" => new { reasonCode = "QuantitySufficient" },
            "link-product" => new { productId = steel },
            _ => new { },
        });

        if (allowed)
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), await response.Content.ReadAsStringAsync());
        }
        else
        {
            Assert.Multiple(async () =>
            {
                Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
                Assert.That(await CodeOf(response), Is.EqualTo("INTERDIT"));
                Assert.That(await Factory.EventsOfAsync(id), Has.Count.EqualTo(before), "un refus n'ecrit rien");
            });
        }
    }

    private static class RoleNamesOf
    {
        public const string Admin = Chantier.Core.Entities.Identity.RoleNames.Admin;
        public const string Direction = Chantier.Core.Entities.Identity.RoleNames.Direction;
        public const string Conducteur = Chantier.Core.Entities.Identity.RoleNames.ConducteurTravaux;
        public const string Achats = Chantier.Core.Entities.Identity.RoleNames.Achats;
        public const string Chef = Chantier.Core.Entities.Identity.RoleNames.ChefChantier;
        public const string Equipe = Chantier.Core.Entities.Identity.RoleNames.ChefEquipe;
    }

    // --- Receptionner, solder, archiver ---

    [Test]
    public async Task Receiving_a_delivered_request_records_the_note_and_is_idempotent()
    {
        var id = await RequestInAsync(RequestStatus.Delivered);

        var first = await Chef.PostAsync(Url(id, "receive"), new { note = "Tout est conforme" });
        var second = await Chef.PostAsync(Url(id, "receive"));
        var json = await first.JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(json.StatusOf(), Is.EqualTo("Received"));
            Assert.That(json.GetProperty("history").EnumerateArray().Last().GetProperty("reasonNote").GetString(), Is.EqualTo("Tout est conforme"));
            Assert.That(second.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await Factory.EventsOfAsync(id)).Count(materialEvent => materialEvent.Type == MaterialEventType.Received), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task Settling_a_partially_delivered_request_marks_it_settled_and_delivered()
    {
        var id = await RequestInAsync(RequestStatus.PartiallyDelivered);

        var json = await (await Conducteur.PostAsync(Url(id, "settle"), new { reasonCode = "SupplierWillNotDeliver" })).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(json.StatusOf(), Is.EqualTo("Delivered"));
            Assert.That(json.GetProperty("isSettled").GetBoolean(), Is.True);
            Assert.That(json.HistoryTypes().Last(), Is.EqualTo("Settled"));
        });
    }

    [Test]
    public async Task Archiving_hides_a_closed_request_from_the_lists_and_restoring_brings_it_back_with_its_status()
    {
        var id = await RequestInAsync(RequestStatus.Cancelled);

        var archived = await (await Conducteur.PostAsync(Url(id, "archive"))).JsonAsync();
        var closed = await (await Conducteur.GetAsync($"{RequestsUrl(Site.Id)}?view=closed&pageSize=200")).JsonAsync();
        var inArchive = await (await Conducteur.GetAsync($"{RequestsUrl(Site.Id)}?view=archived&pageSize=200")).JsonAsync();
        var restored = await (await Conducteur.PostAsync(Url(id, "restore"))).JsonAsync();
        var again = await Conducteur.PostAsync(Url(id, "restore"));

        Assert.Multiple(() =>
        {
            Assert.That(archived.GetProperty("archivedAt").ValueKind, Is.EqualTo(JsonValueKind.String));
            Assert.That(archived.GetProperty("archivedByName").GetString(), Is.EqualTo(Conducteur.Account.FullName));
            Assert.That(closed.GetProperty("items").EnumerateArray().Select(item => item.Id()), Does.Not.Contain(id));
            Assert.That(inArchive.GetProperty("items").EnumerateArray().Select(item => item.Id()), Does.Contain(id));
            Assert.That(restored.GetProperty("archivedAt").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(restored.StatusOf(), Is.EqualTo("Cancelled"));
            Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    [Test]
    public async Task Batch_approve_gives_one_result_per_request_and_each_one_is_independent()
    {
        var fresh = await RequestInAsync(RequestStatus.Requested);
        var already = await RequestInAsync(RequestStatus.Validated);
        var cancelled = await RequestInAsync(RequestStatus.Cancelled);
        var unknown = Guid.NewGuid();

        var response = await Conducteur.PostAsync($"{RequestsUrl(Site.Id)}/batch/approve", new { requestIds = new[] { fresh, already, cancelled, unknown, fresh } });
        var results = (await response.JsonAsync()).GetProperty("results").EnumerateArray().ToDictionary(item => item.GetProperty("requestId").GetGuid());

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(results, Has.Count.EqualTo(4), "un identifiant en double n'est traite qu'une fois");
            Assert.That(results[fresh].GetProperty("outcome").GetString(), Is.EqualTo("applied"));
            Assert.That(results[already].GetProperty("outcome").GetString(), Is.EqualTo("duplicate"));
            Assert.That(results[cancelled].GetProperty("outcome").GetString(), Is.EqualTo("rejected"));
            Assert.That(results[cancelled].GetProperty("code").GetString(), Is.EqualTo("TRANSITION_INTERDITE"));
            Assert.That(results[unknown].GetProperty("code").GetString(), Is.EqualTo("INTROUVABLE"));
        });
    }

    [Test]
    public async Task A_batch_is_limited_to_fifty_approvals_or_one_hundred_archives_and_never_empty()
    {
        var tooMany = Enumerable.Range(0, 51).Select(_ => Guid.NewGuid()).ToArray();
        var tooManyArchives = Enumerable.Range(0, 101).Select(_ => Guid.NewGuid()).ToArray();

        var approve = await Conducteur.PostAsync($"{RequestsUrl(Site.Id)}/batch/approve", new { requestIds = tooMany });
        var archive = await Conducteur.PostAsync($"{RequestsUrl(Site.Id)}/batch/archive", new { requestIds = tooManyArchives });
        var empty = await Conducteur.PostAsync($"{RequestsUrl(Site.Id)}/batch/approve", new { requestIds = Array.Empty<Guid>() });
        var fifty = await Conducteur.PostAsync($"{RequestsUrl(Site.Id)}/batch/approve", new { requestIds = tooMany.Take(50) });

        Assert.Multiple(() =>
        {
            Assert.That(approve.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(archive.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(empty.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(fifty.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    [Test]
    public async Task A_batch_cannot_touch_the_requests_of_another_site()
    {
        var other = await NewSiteAsync();
        var foreign = await Chef.NewRequestIdAsync(other.Id, CementId);

        var response = await Conducteur.PostAsync($"{RequestsUrl(Site.Id)}/batch/approve", new { requestIds = new[] { foreign } });
        var item = (await response.JsonAsync()).GetProperty("results")[0];

        Assert.Multiple(async () =>
        {
            Assert.That(item.GetProperty("code").GetString(), Is.EqualTo("INTROUVABLE"));
            Assert.That((await (await Conducteur.GetAsync(RequestUrl(other.Id, foreign))).JsonAsync()).StatusOf(), Is.EqualTo("Requested"));
        });
    }

    [Test]
    public async Task An_archived_site_refuses_every_write_including_the_reception()
    {
        var site = await NewSiteAsync();
        var delivered = await Chef.NewRequestIdAsync(site.Id, CementId);
        var requested = await Chef.NewRequestIdAsync(site.Id, CementId);
        await Factory.SetStatusAsync(delivered, RequestStatus.Delivered);
        await using (var scope = Factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<Chantier.Infrastructure.Persistence.ApplicationDbContext>();
            (await db.Sites.FindAsync(site.Id))!.Archive(SystemActorId, DateTimeOffset.UtcNow);
            await db.SaveChangesAsync();
        }

        var receive = await Chef.PostAsync($"{RequestUrl(site.Id, delivered)}/receive");
        var approve = await Conducteur.PostAsync($"{RequestUrl(site.Id, requested)}/approve");
        var edit = await Chef.PutAsync(RequestUrl(site.Id, requested), new { version = "1", note = "x" });

        Assert.Multiple(async () =>
        {
            Assert.That(await CodeOf(receive), Is.EqualTo("CHANTIER_ARCHIVE"));
            Assert.That(await CodeOf(approve), Is.EqualTo("CHANTIER_ARCHIVE"));
            Assert.That(edit.StatusCode, Is.AnyOf(HttpStatusCode.Conflict, HttpStatusCode.UnprocessableEntity));
            Assert.That((await (await Chef.GetAsync(RequestUrl(site.Id, delivered))).JsonAsync()).StatusOf(), Is.EqualTo("Delivered"));
        });
    }

    // --- Rattacher un produit ---

    [Test]
    public async Task Achats_links_a_catalogue_product_to_a_free_name_request_and_the_free_name_is_kept()
    {
        var created = await Chef.CreateRequestAsync(Site.Id, RequestBody(null, 2m, "t", freeName: "Rond a beton"));
        var steel = await Admin.CreateSteelAsync();

        var response = await Achats.PostAsync(Url(created.Id(), "link-product"), new { productId = steel.Id() });
        var json = await response.JsonAsync();
        var again = await Achats.PostAsync(Url(created.Id(), "link-product"), new { productId = steel.Id() });

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(json.GetProperty("product").GetProperty("productId").GetGuid(), Is.EqualTo(steel.Id()));
            Assert.That(json.GetProperty("product").GetProperty("freeName").GetString(), Is.EqualTo("Rond a beton"));
            Assert.That(json.HistoryTypes(), Is.EqualTo(new[] { "Created", "ProductLinked" }));
            Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await Factory.EventsOfAsync(created.Id())).Count(materialEvent => materialEvent.Type == MaterialEventType.ProductLinked), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task Linking_checks_that_the_unit_is_allowed_and_the_product_active_and_known()
    {
        var created = await Chef.CreateRequestAsync(Site.Id, RequestBody(null, 2m, "m3", freeName: "Sable fin"));
        var steel = await Admin.CreateSteelAsync();
        var inactive = await Admin.CreateProductAsync(ProductBody(UniqueName("Sable"), ["m3"], "m3", null, "Aggregates"));
        await Admin.PostAsync($"{Products}/{inactive.Id()}/deactivate");

        var unitRefused = await Achats.PostAsync(Url(created.Id(), "link-product"), new { productId = steel.Id() });
        var inactiveRefused = await Achats.PostAsync(Url(created.Id(), "link-product"), new { productId = inactive.Id() });
        var unknown = await Achats.PostAsync(Url(created.Id(), "link-product"), new { productId = Guid.NewGuid() });
        var missing = await Achats.PostAsync(Url(created.Id(), "link-product"), new { });

        Assert.Multiple(async () =>
        {
            Assert.That(await CodeOf(unitRefused), Is.EqualTo("UNITE_NON_AUTORISEE"));
            Assert.That(await CodeOf(inactiveRefused), Is.EqualTo("PRODUIT_INACTIF"));
            Assert.That(unknown.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(missing.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }
}
