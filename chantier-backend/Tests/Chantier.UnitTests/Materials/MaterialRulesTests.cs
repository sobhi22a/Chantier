using Chantier.Core.Exceptions;
using Chantier.Core.Materials;
using Microsoft.Extensions.Time.Testing;

namespace Chantier.UnitTests.Materials;

[TestFixture]
public class MaterialRulesTests
{
    [TestCase("Ciment CPJ 42,5", "ciment cpj 42,5")]
    [TestCase("  Ciment   CPJ  42,5 ", "ciment cpj 42,5")]
    [TestCase("Brique creuse 12 trous", "brique creuse 12 trous")]
    [TestCase("Rond HA Ø12", "rond ha ø12")]
    [TestCase("Électricité fournie", "electricite fournie")]
    [TestCase("إِسْمَنْت", "اسمنت")]
    [TestCase("إســمنت", "اسمنت")]
    [TestCase("", "")]
    [TestCase(null, "")]
    public void Names_are_compared_without_case_accents_or_extra_spaces(string? input, string expected)
        => Assert.That(NameNormalizer.Normalize(input), Is.EqualTo(expected));

    [Test]
    public void Today_is_the_algerian_date_not_the_utc_date()
    {
        // 23 h 30 UTC = 0 h 30 le lendemain en Algérie (UTC+1) : une livraison datée « demain » le serait vraiment.
        var time = new FakeTimeProvider(new DateTimeOffset(2026, 11, 24, 23, 30, 0, TimeSpan.Zero));

        Assert.That(AlgeriaDate.Today(time), Is.EqualTo(new DateOnly(2026, 11, 25)));

        var summer = new FakeTimeProvider(new DateTimeOffset(2026, 7, 1, 22, 59, 59, TimeSpan.Zero));
        Assert.That(AlgeriaDate.Today(summer), Is.EqualTo(new DateOnly(2026, 7, 1)), "pas d'heure d'été : toujours UTC+1");
    }

    [Test]
    public void A_rejection_reason_must_come_from_the_list_and_other_needs_a_note()
    {
        var options = new MaterialsOptions();

        Assert.Multiple(() =>
        {
            Assert.That(ReasonRules.Validate(ReasonKind.Rejection, "StockSufficient", "  Stock du bloc 2  ", options), Is.EqualTo("Stock du bloc 2"));
            Assert.That(ReasonRules.Validate(ReasonKind.Rejection, "StockSufficient", null, options), Is.Null);

            var missing = Assert.Throws<Core.Exceptions.ValidationException>(() => ReasonRules.Validate(ReasonKind.Rejection, null, null, options))!;
            Assert.That(missing.Errors, Contains.Key("reasonCode"));

            var unknown = Assert.Throws<Core.Exceptions.ValidationException>(() => ReasonRules.Validate(ReasonKind.Rejection, "DoubleEntry", null, options))!;
            Assert.That(unknown.Errors, Contains.Key("reasonCode"), "un motif d'un autre cas est refusé");

            var other = Assert.Throws<Core.Exceptions.ValidationException>(() => ReasonRules.Validate(ReasonKind.RequestCancellation, "Other", "  ", options))!;
            Assert.That(other.Errors, Contains.Key("reasonNote"));
            Assert.That(other.Code, Is.EqualTo(ErrorCodes.Validation));

            var tooLong = Assert.Throws<Core.Exceptions.ValidationException>(() => ReasonRules.Validate(ReasonKind.Settle, "Other", new string('x', 201), options))!;
            Assert.That(tooLong.Errors, Contains.Key("reasonNote"));
        });
    }

    [Test]
    public void Every_reason_kind_has_the_list_of_the_contract()
    {
        var reasons = new MaterialsOptions().Reasons;

        Assert.Multiple(() =>
        {
            Assert.That(reasons.For(ReasonKind.Rejection), Is.EqualTo(new[] { "AlreadyOrdered", "StockSufficient", "QuantityToReview", "OverBudget", "Other" }));
            Assert.That(reasons.For(ReasonKind.RequestCancellation), Is.EqualTo(new[] { "EntryError", "NoLongerNeeded", "Duplicate", "Other" }));
            Assert.That(reasons.For(ReasonKind.OrderCancellation), Is.EqualTo(new[] { "SupplierUnavailable", "PriceRefused", "Other" }));
            Assert.That(reasons.For(ReasonKind.Settle), Is.EqualTo(new[] { "SupplierWillNotDeliver", "QuantitySufficient", "Other" }));
            Assert.That(reasons.For(ReasonKind.DeliveryCancellation), Is.EqualTo(new[] { "DoubleEntry", "QuantityError", "RefusedAtReception", "Other" }));
            Assert.That(reasons.For(ReasonKind.Reserve), Is.EqualTo(new[] { "QuantityMissing", "DamagedProduct", "WrongProduct", "Other" }));
        });
    }

    [Test]
    public void Defaults_match_the_plan()
    {
        var options = new MaterialsOptions();

        Assert.Multiple(() =>
        {
            Assert.That(options.DefaultNeededByDays, Is.EqualTo(3));
            Assert.That(options.DeliveryTolerancePercent, Is.Zero);
            Assert.That(options.MaxPhotosPerDelivery, Is.EqualTo(5));
            Assert.That(options.NoteMaxLength, Is.EqualTo(200));
            Assert.That(options.DeliveryNoteMaxLength, Is.EqualTo(30));
            Assert.That(options.FreeNameMinLength, Is.EqualTo(3));
            Assert.That(options.FreeNameMaxLength, Is.EqualTo(100));
        });
    }
}
