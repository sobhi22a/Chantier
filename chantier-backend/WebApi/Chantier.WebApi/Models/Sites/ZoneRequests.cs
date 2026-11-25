using System.ComponentModel.DataAnnotations;
using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Sites;

namespace Chantier.WebApi.Models.Sites;

/// <summary>Position d'une zone. Ni statut, ni archivage, ni champ d'audit : le client ne les fixe jamais.</summary>
public abstract class ZoneRequestBase
{
    /// <summary>Bloc du chantier (obligatoire).</summary>
    /// <example>Bloc 01</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(50, ErrorMessage = "Trop long (50 caractères au maximum).")]
    public string? Block { get; set; }

    /// <summary>Cote en mètres, 2 décimales, de -20,00 à +60,00 (paramétrable).</summary>
    /// <example>3.4</example>
    public decimal? Elevation { get; set; }

    /// <summary>Type de local (classe, couloir, cantine...).</summary>
    public RoomType? RoomType { get; set; }

    /// <summary>Numéro du local (1 à 999) ; exige un type de local.</summary>
    /// <example>2</example>
    public int? RoomNumber { get; set; }

    /// <summary>Libellé libre, seulement si <c>roomType = Other</c>.</summary>
    /// <example>Façade cantine</example>
    [StringLength(100, ErrorMessage = "Trop long (100 caractères au maximum).")]
    public string? RoomLabel { get; set; }

    protected ZoneInput ToInput() => new(Block!, Elevation, RoomType, RoomNumber, RoomLabel);
}

/// <summary>Création, y compris hors ligne : <c>clientId</c> rend l'envoi idempotent.</summary>
public sealed class CreateZoneRequest : ZoneRequestBase
{
    /// <summary>Identifiant généré par le téléphone : un renvoi avec le même <c>clientId</c> donne 200 et la même zone.</summary>
    /// <example>7c1e6a52-0d3b-4c59-9a43-6f1f2b9d8e10</example>
    public Guid? ClientId { get; set; }

    /// <summary>Heure du téléphone à la saisie (« saisi le ») : information seulement, jamais utilisée pour trier ou décider.</summary>
    /// <example>2026-11-24T06:58:00Z</example>
    public DateTimeOffset? ClientCreatedAt { get; set; }

    public CreateZoneDto ToDto() => new(ClientId, ClientCreatedAt, ToInput());
}

public sealed class UpdateZoneRequest : ZoneRequestBase
{
    /// <summary>Version lue avec la zone ; une version périmée donne 409 <c>CONFLIT_VERSION</c>.</summary>
    /// <example>48230</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(30, ErrorMessage = "La version est invalide.")]
    public string? Version { get; set; }

    public UpdateZoneDto ToDto() => new(Version!, ToInput());
}
