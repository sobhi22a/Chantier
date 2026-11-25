using System.Text.Json;
using Chantier.WebApi.Errors;
using Chantier.WebApi.Json;

namespace Chantier.UnitTests.Errors;

[TestFixture]
public class ModelStateProblemFactoryTests
{
    [TestCase("$.odsDate", "odsDate")]
    [TestCase("OdsDate", "odsDate")]
    [TestCase("Request.Zone.Block", "request.zone.block")]
    [TestCase("", "body")]
    [TestCase("$", "body")]
    public void Keys_are_camel_cased(string key, string expected)
        => Assert.That(ModelStateProblemFactory.NormalizeKey(key), Is.EqualTo(expected));

    private sealed class Payload
    {
        public DateOnly? OdsDate { get; set; }
    }

    private static JsonSerializerOptions Options()
    {
        var options = new JsonSerializerOptions();
        JsonDefaults.Configure(options);
        return options;
    }

    [Test]
    public void Complete_date_is_accepted()
    {
        var payload = JsonSerializer.Deserialize<Payload>("""{ "odsDate": "2026-03-02" }""", Options());

        Assert.That(payload!.OdsDate, Is.EqualTo(new DateOnly(2026, 3, 2)));
    }

    [Test]
    public void Null_date_is_accepted()
    {
        var payload = JsonSerializer.Deserialize<Payload>("""{ "odsDate": null }""", Options());

        Assert.That(payload!.OdsDate, Is.Null);
    }

    [TestCase("../03/2026")]
    [TestCase("2026-03")]
    [TestCase("2026-02-30")]
    [TestCase("02/03/2026")]
    [TestCase("")]
    public void Incomplete_or_impossible_date_is_refused(string value)
    {
        var json = $$"""{ "odsDate": "{{value}}" }""";

        Assert.Throws<InvalidDateJsonException>(() => JsonSerializer.Deserialize<Payload>(json, Options()));
    }

    [Test]
    public void Number_instead_of_date_is_refused()
        => Assert.Throws<InvalidDateJsonException>(() => JsonSerializer.Deserialize<Payload>("""{ "odsDate": 20260302 }""", Options()));

    [Test]
    public void Date_is_written_without_time_zone()
        => Assert.That(JsonSerializer.Serialize(new Payload { OdsDate = new DateOnly(2027, 8, 24) }, Options()), Is.EqualTo("""{"odsDate":"2027-08-24"}"""));
}
