using Chantier.Core.Entities.Sites;
using Chantier.Core.Sites;

namespace Chantier.UnitTests.Sites;

[TestFixture]
public class SiteCodeGeneratorTests
{
    [TestCase(SiteType.School, "École UV18", "CH-ECO-UV18")]
    [TestCase(SiteType.Housing, "40 logements Les Oliviers", "CH-LOG-OL40")]
    [TestCase(SiteType.School, "ÉCOLE   uv18  ", "CH-ECO-UV18")]
    [TestCase(SiteType.PublicFacility, "Centre de santé Ibn Sina", "CH-EQP-CESAIBSI")]
    [TestCase(SiteType.Other, "Mur de clôture", "CH-DIV-MUCL")]
    [TestCase(SiteType.School, "École", "CH-ECO-NEW")]
    [TestCase(SiteType.School, "", "CH-ECO-NEW")]
    [TestCase(SiteType.School, "###", "CH-ECO-NEW")]
    public void Suggests_a_code_from_the_type_and_the_name(SiteType type, string name, string expected)
        => Assert.That(SiteCodeGenerator.Build(type, name), Is.EqualTo(expected));

    [Test]
    public void Suggested_codes_respect_the_code_format()
    {
        foreach (var name in new[] { "École UV18", "A", "x", "Très long nom de chantier avec beaucoup de mots Alpha Beta Gamma 12 34", "حي الورود 40" })
        {
            foreach (var type in Enum.GetValues<SiteType>())
            {
                var code = SiteCodeGenerator.Build(type, name);
                Assert.That(Site.IsValidCode(code), Is.True, $"{type} / {name} -> {code}");
            }
        }
    }

    [Test]
    public void Suffix_is_added_while_the_code_is_taken()
    {
        var taken = new HashSet<string> { "CH-ECO-UV18", "CH-ECO-UV18-2" };

        Assert.Multiple(() =>
        {
            Assert.That(SiteCodeGenerator.MakeUnique("CH-ECO-UV18", taken.Contains), Is.EqualTo("CH-ECO-UV18-3"));
            Assert.That(SiteCodeGenerator.MakeUnique("CH-ECO-ZZ9", taken.Contains), Is.EqualTo("CH-ECO-ZZ9"));
        });
    }
}
