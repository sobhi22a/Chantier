using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Exceptions;
using Chantier.Core.Materials;
using static Chantier.UnitTests.Materials.MaterialVectors;

namespace Chantier.UnitTests.Materials;

/// <summary>
/// CT-MAT-01 : tous les vecteurs de <c>docs/api/vecteurs-materiaux.json</c> passent cote serveur, avec arrondi « loin de zero ».
/// Le meme fichier est lu par les suites Dart et TypeScript : une regle de calcul change d'abord ce fichier.
/// </summary>
[TestFixture]
public class MaterialVectorTests
{
    public static IEnumerable<TestCaseData> Conversions() => Cases("conversions");

    public static IEnumerable<TestCaseData> QuantityRulesCases() => Cases("quantityRules");

    public static IEnumerable<TestCaseData> Statuses() => Cases("status");

    public static IEnumerable<TestCaseData> Amounts() => Cases("amounts");

    public static IEnumerable<TestCaseData> ReceivedValues() => Cases("receivedValue");

    public static IEnumerable<TestCaseData> Overdue() => Cases("overdue");

    public static IEnumerable<TestCaseData> DefaultNeededBy() => Cases("defaultNeededBy");

    public static IEnumerable<TestCaseData> Aggregates() => Cases("aggregates");

    [Test]
    public void The_vector_file_covers_every_case_of_the_plan()
    {
        Assert.Multiple(() =>
        {
            Assert.That(Section("conversions").Count(), Is.EqualTo(12));
            Assert.That(Section("status").Count(), Is.EqualTo(11));
            Assert.That(Section("quantityRules").Count(), Is.GreaterThanOrEqualTo(7));
            Assert.That(Section("amounts").Count(), Is.GreaterThanOrEqualTo(8));
            Assert.That(Section("receivedValue"), Is.Not.Empty);
            Assert.That(Section("overdue").Count(), Is.EqualTo(4));
            Assert.That(Section("defaultNeededBy").Count(), Is.EqualTo(3));
            Assert.That(Section("aggregates").Count(), Is.EqualTo(3));
        });
    }

    [TestCaseSource(nameof(Conversions))]
    public void Conversion_follows_the_vector(JsonElement vector)
    {
        var from = Qty(vector.GetProperty("from"));
        var to = Unit(vector.GetProperty("to").GetString()!);
        var bagMass = OptionalDecimal(vector, "bagMassKg");

        if (HasError(vector, out var code))
        {
            var error = Assert.Throws<DomainRuleException>(() => UnitConverter.Convert(from, to, bagMass));
            Assert.That(error!.Code, Is.EqualTo(code));
            Assert.That(UnitConverter.TryConvert(from, to, bagMass, out _), Is.False);
            return;
        }

        var expected = Qty(vector.GetProperty("expected"));
        var converted = UnitConverter.Convert(from, to, bagMass);

        Assert.Multiple(() =>
        {
            Assert.That(converted.Value, Is.EqualTo(expected.Value), Name(vector));
            Assert.That(converted.Unit, Is.EqualTo(expected.Unit));
        });
    }

    [TestCaseSource(nameof(QuantityRulesCases))]
    public void Quantity_rules_follow_the_vector(JsonElement vector)
    {
        var quantity = Qty(vector.GetProperty("quantity"));

        if (HasError(vector, out var code))
        {
            Assert.That(QuantityRules.Check(quantity.Value, quantity.Unit), Is.EqualTo(code));
            Assert.That(Assert.Throws<DomainRuleException>(() => QuantityRules.Validate(quantity.Value, quantity.Unit))!.Code, Is.EqualTo(code));
        }
        else
        {
            Assert.That(QuantityRules.Check(quantity.Value, quantity.Unit), Is.Null);
            Assert.DoesNotThrow(() => QuantityRules.Validate(quantity.Value, quantity.Unit));
        }
    }

    [TestCaseSource(nameof(Statuses))]
    public void Status_follows_the_vector(JsonElement vector)
    {
        var ordered = Qty(vector.GetProperty("ordered"));
        var bagMass = OptionalDecimal(vector, "bagMassKg");
        var deliveries = vector.GetProperty("deliveries").EnumerateArray().Select(Qty).ToList();
        var tolerance = Decimal(vector.GetProperty("tolerancePercent"));

        if (HasError(vector, out var code))
        {
            var error = Assert.Throws<DomainRuleException>(() => RequestStatusCalculator.Compute(ordered, bagMass, deliveries, tolerance, isSettled: false));
            Assert.That(error!.Code, Is.EqualTo(code));
            return;
        }

        var expected = vector.GetProperty("expected");
        var result = RequestStatusCalculator.Compute(ordered, bagMass, deliveries, tolerance, isSettled: false);

        Assert.Multiple(() =>
        {
            Assert.That(result.Received, Is.EqualTo(Decimal(expected.GetProperty("received"))), "reçu");
            Assert.That(result.Remaining, Is.EqualTo(Decimal(expected.GetProperty("remaining"))), "reste");
            Assert.That(result.Variance, Is.EqualTo(Decimal(expected.GetProperty("variance"))), "écart");
            Assert.That(result.VariancePercent, Is.EqualTo(Decimal(expected.GetProperty("variancePercent"))), "écart %");
            Assert.That(result.Status.ToString(), Is.EqualTo(expected.GetProperty("status").GetString()), "statut");
            Assert.That(result.IsSettled, Is.False);
        });
    }

    [TestCaseSource(nameof(Amounts))]
    public void Amount_follows_the_vector(JsonElement vector)
    {
        var amount = Money.Amount(Decimal(vector.GetProperty("quantity")), Decimal(vector.GetProperty("unitPrice")));

        Assert.That(amount, Is.EqualTo(Decimal(vector.GetProperty("expected"))), Name(vector));
    }

    [TestCaseSource(nameof(ReceivedValues))]
    public void Received_value_is_the_sum_of_rounded_amounts(JsonElement vector)
    {
        var quantities = vector.GetProperty("deliveries").EnumerateArray().Select(Decimal).ToList();

        Assert.That(Money.ReceivedValue(Decimal(vector.GetProperty("unitPrice")), quantities), Is.EqualTo(Decimal(vector.GetProperty("expected"))));
    }

    [TestCaseSource(nameof(Overdue))]
    public void Overdue_days_follow_the_vector(JsonElement vector)
    {
        var days = OverdueCalculator.Days(Date(vector.GetProperty("due")), Date(vector.GetProperty("today")));

        Assert.That(days, Is.EqualTo(vector.GetProperty("expected").GetInt32()), Name(vector));
    }

    [TestCaseSource(nameof(DefaultNeededBy))]
    public void Default_needed_by_follows_the_vector(JsonElement vector)
    {
        var date = AlgeriaDate.DefaultNeededBy(Date(vector.GetProperty("today")), vector.GetProperty("days").GetInt32());

        Assert.That(date, Is.EqualTo(Date(vector.GetProperty("expected"))));
    }

    [TestCaseSource(nameof(Aggregates))]
    public void Aggregates_follow_the_vector(JsonElement vector)
    {
        var items = vector.GetProperty("items").EnumerateArray().Select(Qty).ToList();
        var lines = QuantityAggregator.Aggregate(items, Unit(vector.GetProperty("defaultUnit").GetString()!), OptionalDecimal(vector, "bagMassKg"));
        var expected = vector.GetProperty("expected").EnumerateArray().ToList();

        Assert.That(lines, Has.Count.EqualTo(expected.Count), Name(vector));
        for (var index = 0; index < expected.Count; index++)
        {
            var total = Qty(expected[index].GetProperty("total"));
            var mass = expected[index].GetProperty("massEquivalent");

            Assert.Multiple(() =>
            {
                Assert.That(lines[index].Total, Is.EqualTo(total));
                if (mass.ValueKind == JsonValueKind.Null)
                {
                    Assert.That(lines[index].MassEquivalent, Is.Null);
                }
                else
                {
                    Assert.That(lines[index].MassEquivalent, Is.EqualTo(Qty(mass)));
                }
            });
        }
    }

    [Test]
    public void A_settled_request_with_a_missing_quantity_is_delivered_only_while_a_delivery_remains()
    {
        var ordered = new Quantity(600m, MeasureUnit.Bag);
        var delivered = new[] { new Quantity(10m, MeasureUnit.Tonne) };

        var withDelivery = RequestStatusCalculator.Compute(ordered, 50m, delivered, 0m, isSettled: true);
        var withoutDelivery = RequestStatusCalculator.Compute(ordered, 50m, [], 0m, isSettled: true);

        Assert.Multiple(() =>
        {
            Assert.That(withDelivery.Status, Is.EqualTo(RequestStatus.Delivered));
            Assert.That(withDelivery.IsSettled, Is.True);
            Assert.That(withDelivery.Remaining, Is.EqualTo(400m), "le reste reste affiché même soldé");
            Assert.That(withoutDelivery.Status, Is.EqualTo(RequestStatus.Ordered), "H-ARCH-11 : toutes les livraisons annulées = retour à Commandée");
            Assert.That(withoutDelivery.IsSettled, Is.False);
        });
    }

    [Test]
    public void Quantities_are_serialised_with_the_stable_unit_code()
    {
        var json = JsonSerializer.Serialize(
            Quantity.Of(300.000m, MeasureUnit.Bag),
            new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase, Converters = { new System.Text.Json.Serialization.JsonStringEnumConverter(null, allowIntegerValues: false) } });

        Assert.That(json, Is.EqualTo("""{"value":300,"unit":"sac"}"""));
    }

    [Test]
    public void Every_unit_has_a_stable_code_that_parses_back()
    {
        var codes = MeasureUnits.All.Select(MeasureUnits.Code).ToList();

        Assert.Multiple(() =>
        {
            Assert.That(codes, Is.EqualTo(new[] { "u", "ml", "m2", "m3", "kg", "t", "sac", "l", "h", "j", "pj", "ft" }));
            foreach (var unit in MeasureUnits.All)
            {
                Assert.That(MeasureUnits.TryParse(MeasureUnits.Code(unit), out var parsed) && parsed == unit, Is.True);
            }

            Assert.That(MeasureUnits.TryParse("SAC", out _), Is.False, "les codes sont sensibles à la casse");
            Assert.That(MeasureUnits.TryParse(null, out _), Is.False);
            Assert.That(MeasureUnits.TryParse("m²", out _), Is.False);
        });
    }

    [Test]
    public void No_decimal_rounding_in_the_materials_domain_uses_the_default_banker_mode()
    {
        // Math.Round(x, 2) sans mode est bancaire : 613,125 deviendrait 613,12. Interdit dans Core/Materials.
        var folder = Path.GetDirectoryName(Architecture.ArchitectureTests.FindUp(Path.Combine("Core", "Chantier.Core", "Chantier.Core.csproj")))!;
        var offenders = Directory.EnumerateFiles(Path.Combine(folder, "Materials"), "*.cs")
            .SelectMany(file => File.ReadLines(file).Select((line, index) => (File: Path.GetFileName(file), Line: index + 1, Text: line)))
            .Where(entry => (entry.Text.Contains("Math.Round(") || entry.Text.Contains("decimal.Round("))
                && !entry.Text.Contains("MidpointRounding.AwayFromZero"))
            .Select(entry => $"{entry.File}:{entry.Line}")
            .ToList();

        var banker = Directory.EnumerateFiles(Path.Combine(folder, "Materials"), "*.cs")
            .Where(file => File.ReadAllText(file).Contains("MidpointRounding.ToEven"))
            .ToList();

        Assert.Multiple(() =>
        {
            Assert.That(offenders, Is.Empty, "Tout arrondi décimal doit préciser MidpointRounding.AwayFromZero.");
            Assert.That(banker, Is.Empty);
        });
    }
}
