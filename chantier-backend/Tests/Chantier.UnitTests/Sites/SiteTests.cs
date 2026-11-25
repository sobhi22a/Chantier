using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Exceptions;

namespace Chantier.UnitTests.Sites;

/// <summary>Regles du chantier sans base ni HTTP : fin contractuelle (CT-18), validations, archivage, immuabilite du code.</summary>
[TestFixture]
public class SiteTests
{
    private static SiteInput Input(
        string name = "École UV18",
        int? delayDays = 540,
        DateOnly? odsDate = null,
        decimal? amount = 185_000_000.00m,
        decimal? latitude = null,
        decimal? longitude = null)
        => new(name, null, SiteType.School, "Blida", "Boufarik", latitude, longitude, "Direction des équipements publics (fictive)", "M-2026-UV18-001", amount, delayDays, odsDate ?? new DateOnly(2026, 3, 2));

    private static Site NewSite(SiteInput? input = null) => Site.Create("CH-ECO-UV18", input ?? Input());

    // --- CT-18 : fin contractuelle = ODS + delai en jours calendaires (cas de calculs.md, section 7) ---

    [TestCase(2026, 3, 2, 540, 2027, 8, 24, TestName = "ODS 02/03/2026 + 540 j = 24/08/2027")]
    [TestCase(2026, 6, 15, 420, 2027, 8, 9, TestName = "ODS 15/06/2026 + 420 j = 09/08/2027")]
    [TestCase(2026, 1, 15, 30, 2026, 2, 14, TestName = "ODS 15/01/2026 + 30 j = 14/02/2026")]
    [TestCase(2027, 3, 1, 366, 2028, 3, 1, TestName = "ODS 01/03/2027 + 366 j = 01/03/2028 (2028 bissextile)")]
    public void Contractual_end_date_is_ods_plus_calendar_days(int year, int month, int day, int delay, int endYear, int endMonth, int endDay)
    {
        var site = NewSite(Input(delayDays: delay, odsDate: new DateOnly(year, month, day)));

        Assert.That(site.ContractualEndDate, Is.EqualTo(new DateOnly(endYear, endMonth, endDay)));
    }

    [Test]
    public void Contractual_end_date_is_null_without_ods_or_delay()
    {
        var withoutDelay = Site.Create("CH-ECO-A1", new SiteInput("A", null, SiteType.School, "Blida", "Boufarik", null, null, "MO", null, null, null, new DateOnly(2026, 3, 2)));
        var withoutOds = Site.Create("CH-ECO-A2", new SiteInput("A", null, SiteType.School, "Blida", "Boufarik", null, null, "MO", null, null, 540, null));
        var withNeither = Site.Create("CH-ECO-A3", new SiteInput("A", null, SiteType.School, "Blida", "Boufarik", null, null, "MO", null, null, null, null));

        Assert.Multiple(() =>
        {
            Assert.That(withoutDelay.ContractualEndDate, Is.Null, "« À définir », pas de date inventée.");
            Assert.That(withoutOds.ContractualEndDate, Is.Null);
            Assert.That(withNeither.ContractualEndDate, Is.Null);
        });
    }

    [TestCase(0)]
    [TestCase(-1)]
    [TestCase(-540)]
    public void Delay_zero_or_negative_is_QUANTITE_INVALIDE(int delay)
    {
        var exception = Assert.Throws<DomainRuleException>(() => NewSite(Input(delayDays: delay)));

        Assert.That(exception!.Code, Is.EqualTo("QUANTITE_INVALIDE"));
    }

    [Test]
    public void Delay_above_the_limit_is_a_validation_error()
    {
        var exception = Assert.Throws<Chantier.Core.Exceptions.ValidationException>(() => NewSite(Input(delayDays: Site.MaxDelayDays + 1)));

        Assert.That(exception!.Errors, Contains.Key("delayDays"));
    }

    [TestCase(1999)]
    [TestCase(2101)]
    public void Impossible_ods_year_is_DATE_INVALIDE(int year)
    {
        var exception = Assert.Throws<Chantier.Core.Exceptions.ValidationException>(() => NewSite(Input(odsDate: new DateOnly(year, 3, 2))));

        Assert.Multiple(() =>
        {
            Assert.That(exception!.Code, Is.EqualTo("DATE_INVALIDE"));
            Assert.That(exception.Errors, Contains.Key("odsDate"));
        });
    }

    // --- Code : immuable, normalise, format ---

    [TestCase("CH-ECO-UV18")]
    [TestCase("ABC")]
    [TestCase("A1-B2-C3")]
    public void Valid_codes_are_accepted(string code) => Assert.That(Site.IsValidCode(code), Is.True);

    [TestCase("")]
    [TestCase("AB")]
    [TestCase("-ABC")]
    [TestCase("CH ECO")]
    [TestCase("ch-eco")]
    [TestCase("CH_ECO")]
    [TestCase("CH-ÉCO-UV18")]
    public void Invalid_codes_are_refused(string code) => Assert.That(Site.IsValidCode(code), Is.False);

    [Test]
    public void Code_is_normalized_to_upper_case_and_trimmed()
        => Assert.That(Site.Create("  ch-eco-uv18 ", Input()).Code, Is.EqualTo("CH-ECO-UV18"));

    [Test]
    public void Code_longer_than_30_characters_is_refused()
    {
        var exception = Assert.Throws<Chantier.Core.Exceptions.ValidationException>(() => Site.Create("CH-" + new string('A', 30), Input()));

        Assert.That(exception!.Errors, Contains.Key("code"));
    }

    [Test]
    public void Code_cannot_change_after_creation()
    {
        var site = NewSite();

        site.Update(Input(name: "Nouveau nom"));

        Assert.Multiple(() =>
        {
            Assert.That(site.Code, Is.EqualTo("CH-ECO-UV18"));
            Assert.That(site.Name, Is.EqualTo("Nouveau nom"));
            Assert.That(typeof(Site).GetProperty(nameof(Site.Code))!.SetMethod!.IsPublic, Is.False);
        });
    }

    // --- Validation des champs ---

    [Test]
    public void Missing_required_fields_are_reported_together_by_field()
    {
        var input = new SiteInput("  ", null, SiteType.School, "", "", null, null, "", null, null, null, null);

        var exception = Assert.Throws<Chantier.Core.Exceptions.ValidationException>(() => Site.Create("CH-ECO-UV18", input));

        Assert.That(exception!.Errors.Keys, Is.SupersetOf(new[] { "name", "wilaya", "commune", "owner" }));
    }

    [Test]
    public void Invalid_site_type_is_refused()
    {
        var input = Input() with { Type = (SiteType)99 };

        var exception = Assert.Throws<Chantier.Core.Exceptions.ValidationException>(() => NewSite(input));

        Assert.That(exception!.Errors, Contains.Key("type"));
    }

    [Test]
    public void Latitude_and_longitude_go_together_and_stay_in_range()
    {
        Assert.Multiple(() =>
        {
            Assert.That(() => NewSite(Input(latitude: 36.575m)), Throws.TypeOf<Chantier.Core.Exceptions.ValidationException>());
            Assert.That(() => NewSite(Input(longitude: 2.9m)), Throws.TypeOf<Chantier.Core.Exceptions.ValidationException>());
            Assert.That(() => NewSite(Input(latitude: 91m, longitude: 2m)), Throws.TypeOf<Chantier.Core.Exceptions.ValidationException>());
            Assert.That(() => NewSite(Input(latitude: 36m, longitude: 181m)), Throws.TypeOf<Chantier.Core.Exceptions.ValidationException>());
            Assert.That(() => NewSite(Input(latitude: 36.575m, longitude: 2.912m)), Throws.Nothing);
        });
    }

    [Test]
    public void Negative_amount_is_refused_and_amount_is_rounded_away_from_zero_to_two_decimals()
    {
        Assert.That(() => NewSite(Input(amount: -1m)), Throws.TypeOf<Chantier.Core.Exceptions.ValidationException>());

        // L'arrondi par defaut de .NET est bancaire : 100,005 donnerait 100,00. Le metier exige « loin de zero » (regle 4).
        Assert.Multiple(() =>
        {
            Assert.That(NewSite(Input(amount: 100.005m)).ContractAmount, Is.EqualTo(100.01m));
            Assert.That(NewSite(Input(amount: 100.015m)).ContractAmount, Is.EqualTo(100.02m));
            Assert.That(NewSite(Input(amount: 185_000_000.00m)).ContractAmount, Is.EqualTo(185_000_000.00m));
            Assert.That(NewSite(Input(amount: null)).ContractAmount, Is.Null);
        });
    }

    [Test]
    public void Text_fields_are_trimmed_and_blank_optional_fields_become_null()
    {
        var site = NewSite(Input(name: "  École UV18  ") with { NameAr = "   ", ContractNumber = "" });

        Assert.Multiple(() =>
        {
            Assert.That(site.Name, Is.EqualTo("École UV18"));
            Assert.That(site.NameAr, Is.Null);
            Assert.That(site.ContractNumber, Is.Null);
        });
    }

    [Test]
    public void A_failed_update_changes_nothing()
    {
        var site = NewSite();

        Assert.Throws<DomainRuleException>(() => site.Update(Input(name: "Autre", delayDays: 0)));

        Assert.That(site.Name, Is.EqualTo("École UV18"));
    }

    // --- Archivage ---

    [Test]
    public void Archive_is_traced_idempotent_and_makes_the_site_read_only()
    {
        var site = NewSite();
        var actor = Guid.CreateVersion7();
        var first = new DateTimeOffset(2026, 11, 24, 8, 0, 0, TimeSpan.Zero);

        site.Archive(actor, first);
        site.Archive(Guid.CreateVersion7(), first.AddHours(1));
        var exception = Assert.Throws<DomainRuleException>(() => site.EnsureWritable());

        Assert.Multiple(() =>
        {
            Assert.That(site.IsArchived, Is.True);
            Assert.That(site.ArchivedBy, Is.EqualTo(actor), "Le second archivage ne réécrit pas la trace.");
            Assert.That(site.ArchivedAt, Is.EqualTo(first));
            Assert.That(exception!.Code, Is.EqualTo("CHANTIER_ARCHIVE"));
        });
    }

    [Test]
    public void Restore_makes_the_site_writable_again()
    {
        var site = NewSite();
        site.Archive(Guid.CreateVersion7(), DateTimeOffset.UtcNow);

        site.Restore();

        Assert.Multiple(() =>
        {
            Assert.That(site.IsArchived, Is.False);
            Assert.That(site.ArchivedBy, Is.Null);
            Assert.That(() => site.EnsureWritable(), Throws.Nothing);
        });
    }

    [Test]
    public void Identifier_is_a_time_ordered_guid_version_7()
    {
        var first = NewSite();
        var second = NewSite();

        Assert.Multiple(() =>
        {
            Assert.That(first.Id.Version, Is.EqualTo(7));
            Assert.That(first.Id, Is.Not.EqualTo(second.Id));
        });
    }
}
