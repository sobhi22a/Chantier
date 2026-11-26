using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Common;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Exceptions;
using Chantier.Core.Materials;
using Chantier.Core.Sync;

namespace Chantier.UnitTests.Materials;

/// <summary>Domaine pur des demandes : validation d'une saisie, verrouillage par le statut, formes canoniques et comparaison a trois valeurs (CT-MAT-03, 06, 18).</summary>
[TestFixture]
public class RequestDomainTests
{
    private static readonly MaterialsOptions Options = new();

    private static Product Cement() => Product.Create(new ProductInput("Ciment CPJ 42,5", null, ProductCategory.Binders, [MeasureUnit.Bag, MeasureUnit.Tonne, MeasureUnit.Kilogram], MeasureUnit.Bag, 50m));

    private static RequestFields Fields(
        Guid? productId = null,
        string? freeName = null,
        decimal? value = 300m,
        MeasureUnit? unit = MeasureUnit.Bag,
        DateOnly? neededBy = null,
        Priority? priority = null,
        string? note = null)
        => new(productId ?? (freeName is null ? Guid.NewGuid() : null), freeName, value, unit, null, neededBy ?? new DateOnly(2026, 11, 28), priority, note);

    private static string CodeOf(Action action) => Assert.Throws<DomainRuleException>(action)!.Code;

    private static MaterialRequest NewRequest(decimal value = 300m)
    {
        var validated = RequestRules.Validate(Fields(value: value), null, Options);
        return MaterialRequest.Create(Guid.NewGuid(), "DEM-001", Guid.NewGuid(), null, validated, null);
    }

    // --- Validation de saisie ---

    [Test]
    public void A_complete_input_is_valid_and_normalised()
    {
        var validated = RequestRules.Validate(Fields(note: "  Dalle +10,20  ", priority: Priority.Urgent), Cement(), Options);

        Assert.Multiple(() =>
        {
            Assert.That(validated.Quantity, Is.EqualTo(new Quantity(300m, MeasureUnit.Bag)));
            Assert.That(validated.Note, Is.EqualTo("Dalle +10,20"));
            Assert.That(validated.Priority, Is.EqualTo(Priority.Urgent));
        });
    }

    [Test]
    public void The_default_priority_is_normal_and_a_blank_note_is_no_note()
    {
        var validated = RequestRules.Validate(Fields(note: "   "), null, Options);

        Assert.Multiple(() =>
        {
            Assert.That(validated.Priority, Is.EqualTo(Priority.Normal));
            Assert.That(validated.Note, Is.Null);
        });
    }

    [Test]
    public void A_missing_unit_is_UNITE_OBLIGATOIRE_and_comes_before_the_quantity_checks()
    {
        Assert.That(CodeOf(() => RequestRules.Validate(Fields(value: 0m, unit: null), null, Options)), Is.EqualTo("UNITE_OBLIGATOIRE"));
    }

    [TestCase(0, "QUANTITE_INVALIDE")]
    [TestCase(-3, "QUANTITE_INVALIDE")]
    [TestCase(2.5, "QUANTITE_ENTIERE_REQUISE")]
    public void A_bag_quantity_must_be_a_positive_whole_number(double value, string code)
        => Assert.That(CodeOf(() => RequestRules.Validate(Fields(value: (decimal)value), null, Options)), Is.EqualTo(code));

    [Test]
    public void An_inactive_product_or_a_unit_outside_the_list_is_refused_unless_the_product_check_is_skipped()
    {
        var inactive = Cement();
        inactive.Deactivate(DateTimeOffset.UtcNow);

        Assert.Multiple(() =>
        {
            Assert.That(CodeOf(() => RequestRules.Validate(Fields(), inactive, Options)), Is.EqualTo("PRODUIT_INACTIF"));
            Assert.That(CodeOf(() => RequestRules.Validate(Fields(unit: MeasureUnit.CubicMeter, value: 5m), Cement(), Options)), Is.EqualTo("UNITE_NON_AUTORISEE"));
            Assert.DoesNotThrow(() => RequestRules.Validate(Fields(), inactive, Options, checkProduct: false), "une correction de date ne bloque pas sur un produit desactive depuis");
        });
    }

    [Test]
    public void Exactly_one_of_a_product_or_a_free_name_of_three_to_one_hundred_characters()
    {
        var neither = new RequestFields(null, null, 1m, MeasureUnit.Piece, null, new DateOnly(2026, 11, 28), null, null);
        var both = new RequestFields(Guid.NewGuid(), "Ciment", 1m, MeasureUnit.Piece, null, new DateOnly(2026, 11, 28), null, null);

        Assert.Multiple(() =>
        {
            Assert.That(Assert.Throws<Core.Exceptions.ValidationException>(() => RequestRules.Validate(neither, null, Options))!.Errors, Contains.Key("productId"));
            Assert.That(Assert.Throws<Core.Exceptions.ValidationException>(() => RequestRules.Validate(both, null, Options))!.Errors, Contains.Key("freeProductName"));
            Assert.That(Assert.Throws<Core.Exceptions.ValidationException>(() => RequestRules.Validate(Fields(freeName: "ab", unit: MeasureUnit.Piece, value: 1m), null, Options))!.Errors, Contains.Key("freeProductName"));
            Assert.That(Assert.Throws<Core.Exceptions.ValidationException>(() => RequestRules.Validate(Fields(freeName: new string('x', 101), unit: MeasureUnit.Piece, value: 1m), null, Options))!.Errors, Contains.Key("freeProductName"));
            Assert.DoesNotThrow(() => RequestRules.Validate(Fields(freeName: "  Poignees  ", unit: MeasureUnit.Piece, value: 4m), null, Options));
        });
    }

    [Test]
    public void A_missing_date_gives_DATE_INVALIDE_and_a_past_date_is_accepted()
    {
        var missing = new RequestFields(Guid.NewGuid(), null, 1m, MeasureUnit.Piece, null, null, null, null);

        var error = Assert.Throws<Core.Exceptions.ValidationException>(() => RequestRules.Validate(missing, null, Options))!;

        Assert.Multiple(() =>
        {
            Assert.That(error.Code, Is.EqualTo("DATE_INVALIDE"));
            Assert.DoesNotThrow(() => RequestRules.Validate(Fields(neededBy: new DateOnly(2020, 1, 1)), null, Options));
        });
    }

    // --- Verrouillage et statuts ---

    [Test]
    public void A_new_request_is_requested_and_every_field_is_editable()
    {
        var request = NewRequest();

        Assert.DoesNotThrow(() => request.EnsureEditable(RequestFieldNames.All));
        Assert.That(request.Status, Is.EqualTo(RequestStatus.Requested));
    }

    [Test]
    public void After_validation_only_date_priority_and_note_stay_editable()
    {
        var request = NewRequest();
        request.Approve(null, out _);

        Assert.Multiple(() =>
        {
            Assert.DoesNotThrow(() => request.EnsureEditable([RequestFieldNames.NeededBy, RequestFieldNames.Priority, RequestFieldNames.Note]));
            foreach (var locked in new[] { RequestFieldNames.ProductId, RequestFieldNames.FreeProductName, RequestFieldNames.Quantity, RequestFieldNames.ZoneId })
            {
                Assert.That(CodeOf(() => request.EnsureEditable([locked])), Is.EqualTo("DEMANDE_VERROUILLEE"), locked);
            }
        });
    }

    [Test]
    public void A_closed_request_is_not_editable_at_all()
    {
        var request = NewRequest();
        request.Cancel("EntryError", null);

        Assert.That(CodeOf(() => request.EnsureEditable([RequestFieldNames.Note])), Is.EqualTo("TRANSITION_INTERDITE"));
    }

    [Test]
    public void Approving_with_an_adjusted_quantity_records_the_old_and_new_values_and_keeps_the_unit()
    {
        var request = NewRequest(300m);

        var outcome = request.Approve(new Quantity(200m, MeasureUnit.Bag), out var adjustment);

        Assert.Multiple(() =>
        {
            Assert.That(outcome, Is.EqualTo(TransitionOutcome.Applied));
            Assert.That(request.QuantityValue, Is.EqualTo(200m));
            Assert.That(adjustment, Is.EqualTo(new FieldChange("quantity", "300 sac", "200 sac")));
            Assert.That(CodeOf(() => NewRequest().Approve(new Quantity(15m, MeasureUnit.Tonne), out _)), Is.EqualTo("UNITES_INCOMPATIBLES"));
        });
    }

    [Test]
    public void Approve_cancel_and_reject_are_idempotent_and_the_first_reason_is_kept()
    {
        var approved = NewRequest();
        approved.Approve(null, out _);
        var cancelled = NewRequest();
        cancelled.Cancel("EntryError", "premiere");
        var rejected = NewRequest();
        rejected.Reject("OverBudget", null);

        Assert.Multiple(() =>
        {
            Assert.That(approved.Approve(null, out _), Is.EqualTo(TransitionOutcome.AlreadyDone));
            Assert.That(cancelled.Cancel("Duplicate", "seconde"), Is.EqualTo(TransitionOutcome.AlreadyDone));
            Assert.That(cancelled.StatusReasonCode, Is.EqualTo("EntryError"));
            Assert.That(cancelled.StatusReasonNote, Is.EqualTo("premiere"));
            Assert.That(rejected.Reject("StockSufficient", null), Is.EqualTo(TransitionOutcome.AlreadyDone));
            Assert.That(rejected.StatusReasonCode, Is.EqualTo("OverBudget"));
        });
    }

    [Test]
    public void An_open_request_cannot_be_archived_and_a_closed_one_can_be_archived_and_restored()
    {
        var open = NewRequest();
        var closed = NewRequest();
        closed.Cancel("EntryError", null);
        var by = Guid.NewGuid();

        Assert.Multiple(() =>
        {
            Assert.That(CodeOf(() => open.Archive(by, DateTimeOffset.UtcNow)), Is.EqualTo("TRANSITION_INTERDITE"));
            Assert.That(closed.Archive(by, DateTimeOffset.UtcNow), Is.EqualTo(TransitionOutcome.Applied));
            Assert.That(closed.ArchivedBy, Is.EqualTo(by));
            Assert.That(closed.Archive(by, DateTimeOffset.UtcNow), Is.EqualTo(TransitionOutcome.AlreadyDone));
            Assert.That(closed.Restore(), Is.EqualTo(TransitionOutcome.Applied));
            Assert.That(closed.Restore(), Is.EqualTo(TransitionOutcome.AlreadyDone));
            Assert.That(closed.Status, Is.EqualTo(RequestStatus.Cancelled));
        });
    }

    [Test]
    public void Changed_fields_see_only_real_differences()
    {
        var request = NewRequest(300m);
        var same = RequestRules.Validate(request.CurrentFields(), null, Options);
        var other = RequestRules.Validate(request.CurrentFields() with { QuantityValue = 400m, Note = "x" }, null, Options);

        Assert.Multiple(() =>
        {
            Assert.That(request.ChangedFields(same), Is.Empty);
            Assert.That(request.ChangedFields(other), Is.EquivalentTo(new[] { RequestFieldNames.Quantity, RequestFieldNames.Note }));
            Assert.That(request.ChangedFields(request.CurrentFields() with { Priority = null }), Is.Empty, "une urgence absente est « normale »");
        });
    }

    [Test]
    public void The_unit_of_a_quantity_change_counts_as_a_quantity_change()
    {
        var request = NewRequest(300m);

        var changed = request.ChangedFields(request.CurrentFields() with { Unit = MeasureUnit.Tonne });

        Assert.That(changed, Is.EqualTo(new[] { RequestFieldNames.Quantity }));
    }

    // --- Modification partielle ---

    [Test]
    public void Changes_overlay_only_the_fields_that_are_present()
    {
        var current = Fields(value: 300m, note: "Dalle");
        var changes = new RequestChanges(null, null, new QuantityInput(400m, MeasureUnit.Bag), null, false, null, Priority.Urgent, null);

        var next = changes.ApplyTo(current);

        Assert.Multiple(() =>
        {
            Assert.That(next.QuantityValue, Is.EqualTo(400m));
            Assert.That(next.Priority, Is.EqualTo(Priority.Urgent));
            Assert.That(next.Note, Is.EqualTo("Dalle"));
            Assert.That(next.ProductId, Is.EqualTo(current.ProductId));
        });
    }

    [Test]
    public void Choosing_a_product_drops_the_free_name_and_choosing_a_free_name_drops_the_product()
    {
        var withProduct = Fields();
        var withFree = Fields(freeName: "Poignees", unit: MeasureUnit.Piece, value: 4m);
        var newProduct = Guid.NewGuid();

        var toProduct = new RequestChanges(newProduct, null, null, null, false, null, null, null).ApplyTo(withFree);
        var toFree = new RequestChanges(null, "Autre", null, null, false, null, null, null).ApplyTo(withProduct);

        Assert.Multiple(() =>
        {
            Assert.That(toProduct.ProductId, Is.EqualTo(newProduct));
            Assert.That(toProduct.FreeProductName, Is.Null);
            Assert.That(toFree.ProductId, Is.Null);
            Assert.That(toFree.FreeProductName, Is.EqualTo("Autre"));
        });
    }

    [Test]
    public void A_zone_can_be_cleared_only_explicitly_and_an_empty_note_clears_the_note()
    {
        var zone = Guid.NewGuid();
        var current = Fields(note: "Dalle") with { ZoneId = zone };

        var kept = new RequestChanges(null, null, null, null, false, null, null, null).ApplyTo(current);
        var cleared = new RequestChanges(null, null, null, null, true, null, null, string.Empty).ApplyTo(current);

        Assert.Multiple(() =>
        {
            Assert.That(kept.ZoneId, Is.EqualTo(zone));
            Assert.That(cleared.ZoneId, Is.Null);
            Assert.That(RequestRules.Validate(cleared, null, Options).Note, Is.Null);
        });
    }

    // --- Formes canoniques et trois valeurs ---

    [Test]
    public void Equivalent_quantities_have_the_same_canonical_form()
    {
        var a = RequestCanonical.Of(new RequestChanges(null, null, new QuantityInput(300m, MeasureUnit.Bag), null, false, null, null, null));
        var b = RequestCanonical.Of(new RequestChanges(null, null, new QuantityInput(300.000m, MeasureUnit.Bag), null, false, null, null, null));
        var c = RequestCanonical.Of(new RequestChanges(null, null, new QuantityInput(300m, MeasureUnit.Tonne), null, false, null, null, null));

        Assert.Multiple(() =>
        {
            Assert.That(a[RequestFieldNames.Quantity], Is.EqualTo("300 sac"));
            Assert.That(b[RequestFieldNames.Quantity], Is.EqualTo(a[RequestFieldNames.Quantity]));
            Assert.That(c[RequestFieldNames.Quantity], Is.EqualTo("300 t"));
        });
    }

    [Test]
    public void The_canonical_form_of_changes_holds_only_the_present_fields_and_a_cleared_note_is_null()
    {
        var values = RequestCanonical.Of(new RequestChanges(null, null, null, null, true, new DateOnly(2026, 12, 1), Priority.Blocking, "  "));

        Assert.Multiple(() =>
        {
            Assert.That(values.Keys, Is.EquivalentTo(new[] { RequestFieldNames.ZoneId, RequestFieldNames.NeededBy, RequestFieldNames.Priority, RequestFieldNames.Note }));
            Assert.That(values[RequestFieldNames.ZoneId], Is.Null);
            Assert.That(values[RequestFieldNames.NeededBy], Is.EqualTo("2026-12-01"));
            Assert.That(values[RequestFieldNames.Priority], Is.EqualTo("Blocking"));
            Assert.That(values[RequestFieldNames.Note], Is.Null);
        });
    }

    private static Dictionary<string, string?> Values(params (string Field, string? Value)[] pairs) => pairs.ToDictionary(pair => pair.Field, pair => pair.Value);

    [Test]
    public void The_three_value_comparison_applies_unchanged_and_conflicting_fields_as_documented()
    {
        var current = Values(("neededBy", "2026-12-12"), ("note", "Dalle"), ("priority", "Urgent"), ("zoneId", null));
        var start = Values(("neededBy", "2026-12-10"), ("note", "Dalle"), ("priority", "Normal"), ("zoneId", null));
        var proposed = Values(("neededBy", "2026-12-15"), ("note", "Dalle haute"), ("priority", "Urgent"), ("zoneId", null));

        var result = FieldMergeEvaluator.Evaluate(current, start, proposed);

        Assert.Multiple(() =>
        {
            Assert.That(result.Conflicts, Is.EqualTo(new[] { "neededBy" }), "changee ailleurs vers une autre valeur");
            Assert.That(result.ToApply, Is.EqualTo(new[] { "note" }), "valeur de depart inchangee : s'applique");
            Assert.That(result.AlreadyApplied, Is.EquivalentTo(new[] { "priority", "zoneId" }), "deja a la valeur voulue (y compris null)");
            Assert.That(result.HasConflict, Is.True);
        });
    }

    [Test]
    public void The_evaluator_holds_no_conflict_when_nothing_moved_since_the_start()
    {
        var values = Values(("note", "Dalle"));

        var result = FieldMergeEvaluator.Evaluate(values, values, Values(("note", "Dalle haute")));

        Assert.Multiple(() =>
        {
            Assert.That(result.HasConflict, Is.False);
            Assert.That(result.ToApply, Is.EqualTo(new[] { "note" }));
        });
    }

    // --- Divers ---

    [Test]
    public void Monotonic_ids_are_strictly_increasing_even_inside_one_millisecond()
    {
        var ids = Enumerable.Range(0, 2000).Select(_ => MonotonicGuid.Next()).ToList();

        Assert.That(ids, Is.Ordered, "ordre des GUID .NET = ordre de creation");
        Assert.That(ids, Is.Unique);
    }

    [Test]
    public void A_conflict_result_carries_the_code_and_the_fields_and_omits_them_when_absent()
    {
        var plain = SyncPushResult.Conflict(Guid.NewGuid(), null);
        var rich = SyncPushResult.Conflict(Guid.NewGuid(), null, "CONFLIT_VERSION", ["neededBy"]);

        Assert.Multiple(() =>
        {
            Assert.That(plain.Code, Is.Null);
            Assert.That(plain.ConflictFields, Is.Null);
            Assert.That(rich.Code, Is.EqualTo("CONFLIT_VERSION"));
            Assert.That(rich.ConflictFields, Is.EqualTo(new[] { "neededBy" }));
        });
    }

    [TestCase("0550 00 00 21", "0550 00 00 21")]
    [TestCase("0550000021", "0550 00 00 21")]
    [TestCase(" 0661 22 33 44 ", "0661 22 33 44")]
    [TestCase("0770123456", "0770 12 34 56")]
    [TestCase("0150 00 00 21", null)]
    [TestCase("055000002", null)]
    [TestCase("+213550000021", null)]
    public void Supplier_phones_follow_the_algerian_format(string input, string? expected)
        => Assert.That(Supplier.NormalizePhone(input), Is.EqualTo(expected));

    [Test]
    public void The_mass_of_the_bag_is_dropped_when_the_bag_unit_is_not_allowed()
    {
        var steel = Product.Create(new ProductInput("Rond HA", null, ProductCategory.Steel, [MeasureUnit.Tonne], MeasureUnit.Tonne, 50m));

        Assert.That(steel.BagMassKg, Is.Null);
    }
}
