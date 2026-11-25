using Chantier.Core.Identity;

namespace Chantier.UnitTests.Identity;

[TestFixture]
public class JwtSettingsTests
{
    [TestCase("")]
    [TestCase("   ")]
    [TestCase("trop-court-31-octets-aaaaaaaaa")]
    public void Missing_or_short_key_is_refused(string key)
    {
        var settings = new JwtSettings { Key = key };

        var error = settings.ValidateKey();

        Assert.That(error, Is.Not.Null);
        if (key.Trim().Length > 0)
        {
            Assert.That(error, Does.Not.Contain(key.Trim()), "Le message ne doit jamais contenir la clé.");
        }
    }

    [Test]
    public void Key_of_32_bytes_is_accepted()
        => Assert.That(new JwtSettings { Key = new string('k', 32) }.ValidateKey(), Is.Null);

    [Test]
    public void Key_length_is_counted_in_bytes_not_characters()
    {
        // 16 caracteres de 2 octets = 32 octets : accepte ; 15 = 30 octets : refuse.
        Assert.Multiple(() =>
        {
            Assert.That(new JwtSettings { Key = new string('é', 16) }.ValidateKey(), Is.Null);
            Assert.That(new JwtSettings { Key = new string('é', 15) }.ValidateKey(), Is.Not.Null);
        });
    }

    [Test]
    public void Defaults_follow_the_adr()
    {
        var settings = new JwtSettings();

        Assert.Multiple(() =>
        {
            Assert.That(settings.AccessTokenDurationInMinutes, Is.EqualTo(15));
            Assert.That(settings.RefreshTokenDurationInDays, Is.EqualTo(14));
        });
    }
}
