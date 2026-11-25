using Chantier.Core.Sites;

namespace Chantier.UnitTests.Sites;

/// <summary>CT-22 (format) : au moins 3 chiffres, sans troncature au-dela de 999.</summary>
[TestFixture]
public class SiteNumberTests
{
    [TestCase("DEM", 1, "DEM-001")]
    [TestCase("DEM", 9, "DEM-009")]
    [TestCase("LIV", 42, "LIV-042")]
    [TestCase("T", 100, "T-100")]
    [TestCase("PB", 999, "PB-999")]
    [TestCase("SIT", 1000, "SIT-1000")]
    [TestCase("DEM", 12345, "DEM-12345")]
    public void Format_pads_to_three_digits_and_never_truncates(string prefix, int value, string expected)
        => Assert.That(SiteNumber.Format(prefix, value), Is.EqualTo(expected));

    [TestCase(0)]
    [TestCase(-1)]
    public void A_number_starts_at_one(int value)
        => Assert.Throws<ArgumentOutOfRangeException>(() => SiteNumber.Format("DEM", value));

    [Test]
    public void Format_is_independent_of_the_current_culture()
    {
        var previous = System.Globalization.CultureInfo.CurrentCulture;
        try
        {
            System.Globalization.CultureInfo.CurrentCulture = new System.Globalization.CultureInfo("ar-DZ");

            Assert.That(SiteNumber.Format("DEM", 7), Is.EqualTo("DEM-007"), "Chiffres 0-9, jamais les chiffres arabo-indiens.");
        }
        finally
        {
            System.Globalization.CultureInfo.CurrentCulture = previous;
        }
    }

    [Test]
    public void The_five_prefixes_of_the_rules_are_the_only_known_ones()
    {
        Assert.Multiple(() =>
        {
            Assert.That(NumberPrefixes.All, Is.EqualTo(new[] { "DEM", "LIV", "T", "PB", "SIT" }));
            Assert.That(NumberPrefixes.IsKnown("DEM"), Is.True);
            Assert.That(NumberPrefixes.IsKnown("dem"), Is.False);
            Assert.That(NumberPrefixes.IsKnown(null), Is.False);
            Assert.That(NumberPrefixes.All, Has.All.Length.LessThanOrEqualTo(NumberPrefixes.MaxLength));
        });
    }
}
