using System.Reflection;
using Chantier.Core.Exceptions;

namespace Chantier.UnitTests.Architecture;

/// <summary>Tests d'architecture par reflexion, sans bibliotheque (ADR 0010).</summary>
[TestFixture]
public class ArchitectureTests
{
    private static readonly string[] ForbiddenInCore =
    [
        "Microsoft.EntityFrameworkCore",
        "Microsoft.Data.SqlClient",
        "Microsoft.AspNetCore",
        "Oracle",
    ];

    private static readonly string[] ForbiddenPackages =
    [
        "AutoMapper", "MediatR", "FluentAssertions", "MassTransit", "SixLabors", "Oracle",
    ];

    [Test]
    public void Core_does_not_reference_ef_sql_or_aspnet()
    {
        var referenced = typeof(ErrorCodes).Assembly.GetReferencedAssemblies()
            .Select(a => a.Name ?? string.Empty)
            .ToList();

        var offenders = referenced
            .Where(name => ForbiddenInCore.Any(prefix => name.StartsWith(prefix, StringComparison.Ordinal)))
            .ToList();

        Assert.That(offenders, Is.Empty, "Chantier.Core ne doit référencer ni EF Core, ni SQL, ni ASP.NET.");
    }

    [Test]
    public void No_forbidden_package_is_loaded()
    {
        var loaded = AppDomain.CurrentDomain.GetAssemblies()
            .Concat(new[] { typeof(ErrorCodes).Assembly, typeof(Chantier.WebApi.Errors.ErrorCatalog).Assembly })
            .SelectMany(a => a.GetReferencedAssemblies().Select(r => r.Name ?? string.Empty))
            .Where(name => ForbiddenPackages.Any(prefix => name.StartsWith(prefix, StringComparison.Ordinal)))
            .Distinct()
            .ToList();

        Assert.That(loaded, Is.Empty);
    }

    [Test]
    public void Directory_packages_props_contains_no_forbidden_package()
    {
        var path = FindUp("Directory.Packages.props");
        var content = File.ReadAllText(path);

        foreach (var forbidden in ForbiddenPackages)
        {
            Assert.That(content, Does.Not.Contain($"Include=\"{forbidden}"), $"Paquet interdit sans ADR : {forbidden}");
        }
    }

    internal static string FindUp(string fileName)
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null)
        {
            var candidate = Path.Combine(directory.FullName, fileName);
            if (File.Exists(candidate))
            {
                return candidate;
            }

            directory = directory.Parent;
        }

        throw new FileNotFoundException(fileName);
    }
}
