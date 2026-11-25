using System.Text.RegularExpressions;
using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Common;
using Chantier.Core.Exceptions;
using Chantier.Core.Sites;
using Chantier.Core.Validation;

namespace Chantier.Core.Entities.Sites;

/// <summary>
/// Chantier. Le <see cref="Code"/> est immuable ; « supprimer » = archiver (lecture seule, restaurable, H-13).
/// Toutes les regles (code, delai, fin contractuelle, bornes) vivent ici, testables sans base ni HTTP.
/// </summary>
public partial class Site : BasicEntity
{
    public const int MaxDelayDays = 36500;
    public const int MinOdsYear = 2000;
    public const int MaxOdsYear = 2100;
    private const decimal MaxAmount = 999_999_999_999_999.99m;

    // EF Core
    private Site()
    {
    }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public string? NameAr { get; private set; }

    public SiteType Type { get; private set; }

    public string Wilaya { get; private set; } = string.Empty;

    public string Commune { get; private set; } = string.Empty;

    public decimal? Latitude { get; private set; }

    public decimal? Longitude { get; private set; }

    public string Owner { get; private set; } = string.Empty;

    public string? ContractNumber { get; private set; }

    /// <summary>Montant du marche en DZD, 2 decimales ; reserve aux roles ayant <c>ContractAmount.View</c>.</summary>
    public decimal? ContractAmount { get; private set; }

    /// <summary>Delai contractuel en jours calendaires (H-09).</summary>
    public int? DelayDays { get; private set; }

    /// <summary>Date de l'ordre de service de demarrage.</summary>
    public DateOnly? OdsDate { get; private set; }

    public DateTimeOffset? ArchivedAt { get; private set; }

    public Guid? ArchivedBy { get; private set; }

    public ICollection<SiteMember> Members { get; } = new List<SiteMember>();

    /// <summary>Compteurs de numerotation (DEM, LIV, T, PB, SIT), crees avec le chantier dans la meme ecriture ; jamais charges ni modifies par ce lien.</summary>
    public ICollection<SiteCounter> Counters { get; } = new List<SiteCounter>();

    public bool IsArchived => ArchivedAt is not null;

    /// <summary>Fin contractuelle = date de l'ODS + delai (jours calendaires) ; <c>null</c> si l'un des deux manque (« A definir »).</summary>
    public DateOnly? ContractualEndDate => OdsDate is { } ods && DelayDays is { } delay ? ods.AddDays(delay) : null;

    public static bool IsValidCode(string? code) => code is not null && CodePattern().IsMatch(code);

    public static Site Create(string code, SiteInput input)
    {
        var errors = new ErrorCollector();
        var normalizedCode = code?.Trim().ToUpperInvariant() ?? string.Empty;
        if (!IsValidCode(normalizedCode))
        {
            errors.Add("code", "Le code doit contenir de 3 à 30 caractères : lettres majuscules, chiffres et tirets.");
        }

        var site = new Site { Code = normalizedCode };
        foreach (var prefix in NumberPrefixes.All)
        {
            site.Counters.Add(SiteCounter.Create(prefix));
        }

        site.Apply(input, errors);
        return site;
    }

    public void Update(SiteInput input) => Apply(input, new ErrorCollector());

    public void Archive(Guid by, DateTimeOffset at)
    {
        if (IsArchived)
        {
            return;
        }

        ArchivedAt = at;
        ArchivedBy = by;
    }

    public void Restore()
    {
        ArchivedAt = null;
        ArchivedBy = null;
    }

    /// <summary>Un chantier archive est en lecture seule : plus aucune saisie (CHANTIER_ARCHIVE).</summary>
    public void EnsureWritable()
    {
        if (IsArchived)
        {
            throw new DomainRuleException(ErrorCodes.ChantierArchive, "Ce chantier est archivé : il est en lecture seule.");
        }
    }

    private void Apply(SiteInput input, ErrorCollector errors)
    {
        var name = Clean(input.Name);
        var nameAr = Clean(input.NameAr);
        var wilaya = Clean(input.Wilaya);
        var commune = Clean(input.Commune);
        var owner = Clean(input.Owner);
        var contractNumber = Clean(input.ContractNumber);

        Require(errors, "name", name, 200);
        Limit(errors, "nameAr", nameAr, 200);
        Require(errors, "wilaya", wilaya, 100);
        Require(errors, "commune", commune, 100);
        Require(errors, "owner", owner, 200);
        Limit(errors, "contractNumber", contractNumber, 100);

        if (!Enum.IsDefined(input.Type))
        {
            errors.Add("type", "Le type d'ouvrage est invalide.");
        }

        var hasLatitude = input.Latitude.HasValue;
        var hasLongitude = input.Longitude.HasValue;
        if (hasLatitude != hasLongitude)
        {
            errors.Add(hasLatitude ? "longitude" : "latitude", "La latitude et la longitude vont ensemble.");
        }

        if (input.Latitude is < -90m or > 90m)
        {
            errors.Add("latitude", "La latitude doit être comprise entre -90 et 90.");
        }

        if (input.Longitude is < -180m or > 180m)
        {
            errors.Add("longitude", "La longitude doit être comprise entre -180 et 180.");
        }

        if (input.ContractAmount is < 0m or > MaxAmount)
        {
            errors.Add("contractAmount", "Le montant doit être positif.");
        }

        if (input.DelayDays > MaxDelayDays)
        {
            errors.Add("delayDays", $"Le délai ne peut pas dépasser {MaxDelayDays} jours.");
        }

        if (input.OdsDate is { } ods && (ods.Year < MinOdsYear || ods.Year > MaxOdsYear))
        {
            errors.AddInvalidDate("odsDate", "La date de l'ODS est impossible.");
        }

        errors.ThrowIfAny();

        // Quantite <= 0 : regle metier (422), apres les erreurs de saisie (400).
        if (input.DelayDays is <= 0)
        {
            throw new DomainRuleException(ErrorCodes.QuantiteInvalide, "Le délai doit être un nombre entier de jours supérieur à zéro.");
        }

        Name = name!;
        NameAr = nameAr;
        Type = input.Type;
        Wilaya = wilaya!;
        Commune = commune!;
        Latitude = input.Latitude is { } latitude ? decimal.Round(latitude, 6, MidpointRounding.AwayFromZero) : null;
        Longitude = input.Longitude is { } longitude ? decimal.Round(longitude, 6, MidpointRounding.AwayFromZero) : null;
        Owner = owner!;
        ContractNumber = contractNumber;
        ContractAmount = input.ContractAmount is { } amount ? decimal.Round(amount, 2, MidpointRounding.AwayFromZero) : null;
        DelayDays = input.DelayDays;
        OdsDate = input.OdsDate;
    }

    private static string? Clean(string? value)
        => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    private static void Require(ErrorCollector errors, string field, string? value, int maxLength)
    {
        if (value is null)
        {
            errors.Add(field, "Le champ est obligatoire.");
            return;
        }

        Limit(errors, field, value, maxLength);
    }

    private static void Limit(ErrorCollector errors, string field, string? value, int maxLength)
    {
        if (value is not null && value.Length > maxLength)
        {
            errors.Add(field, $"Trop long ({maxLength} caractères au maximum).");
        }
    }

    [GeneratedRegex("^[A-Z0-9][A-Z0-9-]{2,29}$")]
    private static partial Regex CodePattern();
}
