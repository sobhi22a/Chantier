using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using Microsoft.Extensions.Options;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;

namespace Chantier.IntegrationTests.Security;

/// <summary>R1-06 : les cles qui signent et chiffrent les cookies sont chiffrees au repos (certificat) hors developpement.</summary>
[TestFixture]
public class DataProtectionTests
{
    private string _directory = null!;

    [SetUp]
    public void CreateDirectory() => _directory = Path.Combine(Path.GetTempPath(), "chantier-dp-tests", Guid.NewGuid().ToString("N"));

    [TearDown]
    public void DeleteDirectory()
    {
        if (Directory.Exists(_directory))
        {
            Directory.Delete(_directory, recursive: true);
        }
    }

    /// <summary>Certificat de test jetable, ecrit en PKCS#12 dans le dossier temporaire du test (jamais dans le depot).</summary>
    private string CreateCertificate(string password)
    {
        Directory.CreateDirectory(_directory);
        using var key = RSA.Create(2048);
        var request = new CertificateRequest("CN=chantier-test-dp", key, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
        using var certificate = request.CreateSelfSigned(DateTimeOffset.UtcNow.AddDays(-1), DateTimeOffset.UtcNow.AddDays(30));
        var path = Path.Combine(_directory, "cles.pfx");
        File.WriteAllBytes(path, certificate.Export(X509ContentType.Pfx, password));
        return path;
    }

    private ChantierWebApplicationFactory Factory(string environment, Action<Dictionary<string, string?>>? settings = null)
    {
        var factory = new ChantierWebApplicationFactory { EnvironmentName = environment };
        factory.Settings["Storage:DataProtectionKeys"] = Path.Combine(_directory, "keys");
        settings?.Invoke(factory.Settings);
        return factory;
    }

    /// <summary>
    /// Le certificat est lu dans la configuration deja chargee au demarrage (fichiers, variables d'environnement) : les reglages en memoire de la fabrique
    /// de test arrivent plus tard. On passe donc par les variables d'environnement, comme en production, le temps du demarrage de l'hote.
    /// </summary>
    private static void StartWithEnvironment(ChantierWebApplicationFactory factory, string path, string password)
    {
        Environment.SetEnvironmentVariable("DataProtection__CertificatePath", path);
        Environment.SetEnvironmentVariable("DataProtection__CertificatePassword", password);
        try
        {
            _ = factory.Server;
        }
        finally
        {
            Environment.SetEnvironmentVariable("DataProtection__CertificatePath", null);
            Environment.SetEnvironmentVariable("DataProtection__CertificatePassword", null);
        }
    }

    private string KeyFilesText() => string.Join('\n', Directory.GetFiles(Path.Combine(_directory, "keys"), "key-*.xml").Select(File.ReadAllText));

    [Test]
    public void Outside_development_keys_must_be_encrypted_unless_explicitly_waived()
    {
        using var factory = Factory("Production", settings => settings["DataProtection:AllowUnencryptedKeys"] = "false");

        var failure = Assert.Throws<OptionsValidationException>(() => _ = factory.Server);

        Assert.That(failure!.Message, Does.Contain("DataProtection").And.Contain("chiffrées"));
    }

    [Test]
    public async Task In_development_keys_may_stay_in_clear()
    {
        using var factory = Factory("Development", settings => settings["DataProtection:AllowUnencryptedKeys"] = "false");
        var account = await factory.CreateUserAsync(RoleNames.Direction);
        using var client = factory.CreateClient();

        (await client.LoginAsync(account.UserName, account.Password, mobile: false)).EnsureSuccessStatusCode();

        Assert.That(KeyFilesText(), Does.Contain("masterKey"), "Valeur par défaut du développement : clé en clair.");
    }

    [Test]
    public async Task With_a_certificate_keys_are_written_encrypted_and_cookies_keep_working()
    {
        const string password = "Certificat-Test-1";
        var path = CreateCertificate(password);
        using var factory = Factory("Production", settings => settings["DataProtection:AllowUnencryptedKeys"] = "false");
        StartWithEnvironment(factory, path, password);
        var account = await factory.CreateUserAsync(RoleNames.Direction);
        using var client = factory.CreateClient(new Microsoft.AspNetCore.Mvc.Testing.WebApplicationFactoryClientOptions { HandleCookies = false, BaseAddress = new Uri("https://localhost") });

        var login = await client.LoginAsync(account.UserName, account.Password, mobile: false);
        login.EnsureSuccessStatusCode();
        var cookie = login.Headers.GetValues("Set-Cookie").Single(header => header.StartsWith(".Chantier.Identity.Application=", StringComparison.Ordinal)).Split(';')[0];
        var request = new HttpRequestMessage(HttpMethod.Get, "/api/v1/auth/me");
        request.Headers.Add("Cookie", cookie);
        var me = await client.SendAsync(request);

        var text = KeyFilesText();
        Assert.Multiple(() =>
        {
            Assert.That(me.StatusCode, Is.EqualTo(System.Net.HttpStatusCode.OK));
            Assert.That(text, Does.Contain("EncryptedData"), "La clé est chiffrée avec le certificat.");
            Assert.That(text, Does.Not.Contain("<masterKey"), "Aucune clé maîtresse en clair dans le dossier.");
        });
    }

    [Test]
    public void A_wrong_certificate_password_refuses_to_start_without_echoing_it()
    {
        var path = CreateCertificate("Bon-Mot-De-Passe-1");
        using var factory = Factory("Production");

        var failure = Assert.Catch(() => StartWithEnvironment(factory, path, "Mauvais-Mot-De-Passe-2"));

        Assert.That(failure!.ToString(), Does.Not.Contain("Mauvais-Mot-De-Passe-2"));
    }
}
