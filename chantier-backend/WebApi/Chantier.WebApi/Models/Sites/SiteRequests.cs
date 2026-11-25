using System.ComponentModel.DataAnnotations;
using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Sites;

namespace Chantier.WebApi.Models.Sites;

/// <summary>
/// Champs modifiables d'un chantier. Ne contient volontairement ni identifiant, ni statut, ni archivage, ni champ d'audit
/// (cree par, modifie par, dates) : le client ne peut pas les fixer (protection contre l'affectation de masse).
/// </summary>
public abstract class SiteRequestBase
{
    /// <summary>Nom du chantier (français).</summary>
    /// <example>École UV18</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? Name { get; set; }

    /// <summary>Nom en arabe (facultatif) : affiché à la place du nom français s'il est présent.</summary>
    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? NameAr { get; set; }

    /// <summary>Type d'ouvrage.</summary>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public SiteType? Type { get; set; }

    /// <summary>Wilaya (liste de référence).</summary>
    /// <example>Blida</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(100, ErrorMessage = "Trop long (100 caractères au maximum).")]
    public string? Wilaya { get; set; }

    /// <summary>Commune (liste de la wilaya ; une saisie libre est acceptée).</summary>
    /// <example>Boufarik</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(100, ErrorMessage = "Trop long (100 caractères au maximum).")]
    public string? Commune { get; set; }

    /// <summary>Latitude en degrés décimaux (va avec la longitude).</summary>
    /// <example>36.575</example>
    public decimal? Latitude { get; set; }

    /// <summary>Longitude en degrés décimaux (va avec la latitude).</summary>
    /// <example>2.912</example>
    public decimal? Longitude { get; set; }

    /// <summary>Maître d'ouvrage.</summary>
    /// <example>Direction des équipements publics (fictive)</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? Owner { get; set; }

    /// <summary>Numéro du marché.</summary>
    /// <example>M-2026-UV18-001</example>
    [StringLength(100, ErrorMessage = "Trop long (100 caractères au maximum).")]
    public string? ContractNumber { get; set; }

    /// <summary>Montant du marché en DZD, 2 décimales.</summary>
    /// <example>185000000</example>
    public decimal? ContractAmount { get; set; }

    /// <summary>Délai en jours calendaires (entier supérieur à 0).</summary>
    /// <example>540</example>
    public int? DelayDays { get; set; }

    /// <summary>Date complète de l'ordre de service de démarrage ; une date incomplète (<c>../03/2026</c>) donne <c>DATE_INVALIDE</c>.</summary>
    /// <example>2026-03-02</example>
    public DateOnly? OdsDate { get; set; }

    protected SiteInput ToInput() => new(
        Name!, NameAr, Type!.Value, Wilaya!, Commune!, Latitude, Longitude, Owner!, ContractNumber, ContractAmount, DelayDays, OdsDate);
}

public sealed class CreateSiteRequest : SiteRequestBase
{
    /// <summary>Code unique et immuable, proposé par <c>GET /sites/code-suggestion</c>.</summary>
    /// <example>CH-ECO-UV18</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(30, ErrorMessage = "Trop long (30 caractères au maximum).")]
    public string? Code { get; set; }

    public CreateSiteDto ToDto() => new(Code!, ToInput());
}

/// <summary>Modification : pas de <c>code</c> (immuable). <c>version</c> est la valeur lue, pour détecter une modification concurrente.</summary>
public sealed class UpdateSiteRequest : SiteRequestBase
{
    /// <summary>Version lue avec le chantier ; une version périmée donne 409 <c>CONFLIT_VERSION</c>.</summary>
    /// <example>48213</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(30, ErrorMessage = "La version est invalide.")]
    public string? Version { get; set; }

    public UpdateSiteDto ToDto() => new(Version!, ToInput());
}
