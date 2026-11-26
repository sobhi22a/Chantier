using Chantier.Core.Materials;
using Chantier.Infrastructure.Storage;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;

namespace Chantier.UnitTests.Materials;

/// <summary>R2-10 : en production, la racine des photos est un chemin absolu hors du dossier de l'application.</summary>
[TestFixture]
public class PhotoStorageOptionsValidatorTests
{
    private static readonly string Content = Path.Combine(Path.GetTempPath(), "chantier-app");

    private static bool Accepts(string environment, string root)
        => new PhotoStorageOptionsValidator(new Environment(environment)).Validate(null, new PhotoStorageOptions { PhotosRoot = root }).Succeeded;

    [Test]
    public void Production_refuses_a_relative_root_and_a_root_inside_the_application_folder()
    {
        var outside = Path.Combine(Path.GetTempPath(), "chantier-photos-volume");

        Assert.Multiple(() =>
        {
            Assert.That(Accepts("Production", "./Storage/Photos"), Is.False, "relatif : suit le dossier de lancement");
            Assert.That(Accepts("Production", ""), Is.False);
            Assert.That(Accepts("Production", Path.Combine(Content, "Storage", "Photos")), Is.False, "dans le dossier de l'application : ecrase au deploiement");
            Assert.That(Accepts("Production", outside), Is.True);
        });
    }

    [Test]
    public void Other_environments_keep_the_relative_default()
    {
        Assert.Multiple(() =>
        {
            Assert.That(Accepts("Development", "./Storage/Photos"), Is.True);
            Assert.That(Accepts("Staging", "./Storage/Photos"), Is.True);
        });
    }

    private sealed class Environment(string name) : IHostEnvironment
    {
        public string EnvironmentName { get; set; } = name;

        public string ApplicationName { get; set; } = "Chantier";

        public string ContentRootPath { get; set; } = Content;

        public IFileProvider ContentRootFileProvider { get; set; } = new NullFileProvider();
    }
}
