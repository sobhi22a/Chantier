using System.Reflection;
using System.Text.RegularExpressions;
using Chantier.Core.Exceptions;
using Chantier.WebApi.Errors;

namespace Chantier.UnitTests.Errors;

/// <summary>Catalogue des erreurs (B6) : le code, le catalogue serveur et <c>docs/api/codes-erreur.md</c> ne se contredisent jamais.</summary>
[TestFixture]
public partial class ErrorCatalogTests
{
    private const string FallbackTitle = "Règle métier non respectée";

    private static readonly string[] Codes = typeof(ErrorCodes)
        .GetFields(BindingFlags.Public | BindingFlags.Static)
        .Where(field => field.IsLiteral && field.FieldType == typeof(string))
        .Select(field => (string)field.GetRawConstantValue()!)
        .ToArray();

    [GeneratedRegex("`([A-Z][A-Z_]+)`")]
    private static partial Regex CodePattern();

    private static string DocumentPath()
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null)
        {
            var candidate = Path.Combine(directory.FullName, "docs", "api", "codes-erreur.md");
            if (File.Exists(candidate))
            {
                return candidate;
            }

            directory = directory.Parent;
        }

        throw new FileNotFoundException("docs/api/codes-erreur.md");
    }

    /// <summary>Lignes du tableau : codes de la premiere cellule, statut HTTP de la deuxieme (absent si ce n'est pas un nombre).</summary>
    private static List<(string[] Codes, int? Status)> DocumentedRows()
        => File.ReadAllLines(DocumentPath())
            .Where(line => line.StartsWith("| `", StringComparison.Ordinal))
            .Select(line => line.Split('|', StringSplitOptions.TrimEntries))
            .Select(cells => (
                Codes: CodePattern().Matches(cells[1]).Select(match => match.Groups[1].Value).ToArray(),
                Status: int.TryParse(cells[2], out var status) ? (int?)status : null))
            .ToList();

    [Test]
    public void Every_code_has_a_catalogue_entry()
    {
        var missing = Codes.Where(code => ErrorCatalog.Get(code).Title == FallbackTitle);

        Assert.That(missing, Is.Empty, "Ajouter l'entrée dans ErrorCatalog (statut, titre, message français).");
    }

    [Test]
    public void Every_code_is_documented_and_every_documented_code_exists()
    {
        var documented = DocumentedRows().SelectMany(row => row.Codes).ToList();

        Assert.Multiple(() =>
        {
            Assert.That(Codes.Except(documented), Is.Empty, "Code absent de docs/api/codes-erreur.md.");
            Assert.That(documented.Except(Codes), Is.Empty, "Code documenté mais absent de ErrorCodes.");
            Assert.That(documented, Is.Unique);
        });
    }

    [Test]
    public void Documented_http_statuses_match_the_catalogue()
    {
        var offenders = DocumentedRows()
            .Where(row => row.Status is not null)
            .SelectMany(row => row.Codes.Select(code => (Code: code, Documented: row.Status!.Value, Actual: ErrorCatalog.Get(code).Status)))
            .Where(entry => entry.Documented != entry.Actual)
            .Select(entry => $"{entry.Code} : document {entry.Documented}, serveur {entry.Actual}");

        Assert.That(offenders, Is.Empty);
    }

    [Test]
    public void Codes_are_upper_snake_case_and_messages_hold_no_personal_data_placeholder()
    {
        Assert.Multiple(() =>
        {
            Assert.That(Codes, Has.All.Matches("^[A-Z][A-Z_]+$"));
            Assert.That(Codes, Is.Unique);
            foreach (var code in Codes)
            {
                var entry = ErrorCatalog.Get(code);
                Assert.That(entry.Detail, Does.Not.Contain("{").And.Not.Contain("@"), code);
                Assert.That(entry.Title, Is.Not.Empty, code);
            }
        });
    }

    [Test]
    public void The_framework_status_to_code_mapping_only_returns_known_codes()
    {
        var statuses = new[] { 400, 401, 403, 404, 409, 413, 429, 500, 503 };

        Assert.That(statuses.Select(ErrorCatalog.CodeForStatus).Distinct(), Is.SubsetOf(Codes));
    }
}
