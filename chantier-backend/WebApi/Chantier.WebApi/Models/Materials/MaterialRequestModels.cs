using System.ComponentModel.DataAnnotations;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;

namespace Chantier.WebApi.Models.Materials;

/// <summary>Quantité saisie : valeur et unité. L'unité est toujours obligatoire (422 <c>UNITE_OBLIGATOIRE</c> sinon, jamais une quantité sans unité).</summary>
public sealed class QuantityBody
{
    /// <summary>Valeur strictement positive, 3 décimales au plus ; entier pour <c>sac</c> et <c>u</c> (422 <c>QUANTITE_INVALIDE</c>, <c>QUANTITE_ENTIERE_REQUISE</c>).</summary>
    /// <example>300</example>
    public decimal? Value { get; set; }

    /// <summary>Unité du référentiel : <c>u ml m2 m3 kg t sac l h j pj ft</c>.</summary>
    /// <example>sac</example>
    public MeasureUnit? Unit { get; set; }

    public QuantityInput ToInput() => new(Value, Unit);
}

/// <summary>
/// Création d'une demande, y compris hors ligne : <c>clientId</c> rend l'envoi idempotent. Le client ne fixe jamais le statut, le numéro, l'auteur,
/// les dates d'audit ni le doublon possible : le serveur les calcule.
/// </summary>
public sealed class CreateRequestRequest
{
    /// <summary>Identifiant généré par le téléphone : un renvoi avec le même <c>clientId</c> donne 200 et la même demande, sans nouveau numéro.</summary>
    /// <example>7c1e6a52-0d3b-4c59-9a43-6f1f2b9d8e10</example>
    public Guid? ClientId { get; set; }

    /// <summary>Heure du téléphone à la saisie (« saisi le ») : information seulement, jamais utilisée pour trier ou décider.</summary>
    /// <example>2026-11-25T06:58:00Z</example>
    public DateTimeOffset? ClientCreatedAt { get; set; }

    /// <summary>Produit du catalogue (actif). Exactement un de <c>productId</c> et <c>freeProductName</c>.</summary>
    public Guid? ProductId { get; set; }

    /// <summary>« Autre produit » : nom libre de 3 à 100 caractères.</summary>
    /// <example>Poignées de porte</example>
    [StringLength(100, ErrorMessage = "Trop long (100 caractères au maximum).")]
    public string? FreeProductName { get; set; }

    /// <summary>Quantité demandée avec son unité (une unité autorisée du produit).</summary>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public QuantityBody? Quantity { get; set; }

    /// <summary>Zone du chantier (facultative) ; 422 <c>ZONE_HORS_CHANTIER</c> si elle appartient à un autre chantier.</summary>
    public Guid? ZoneId { get; set; }

    /// <summary>Date de besoin complète (« pour le ») ; une date passée est acceptée (avertissement côté client).</summary>
    /// <example>2026-11-28</example>
    public DateOnly? NeededBy { get; set; }

    /// <summary><c>Normal</c> (défaut), <c>Urgent</c> ou <c>Blocking</c> (le chantier s'arrête).</summary>
    public Priority? Priority { get; set; }

    /// <summary>Usage ou remarque (200 caractères au plus).</summary>
    /// <example>Dalle +10,20</example>
    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? Note { get; set; }

    public CreateRequestDto ToDto() => new(
        ClientId,
        ClientCreatedAt,
        new RequestFields(ProductId, FreeProductName, Quantity?.Value, Quantity?.Unit, ZoneId, NeededBy, Priority, Note));
}

/// <summary>Modification : seuls les champs présents changent. <c>version</c> détecte une modification concurrente (409 <c>CONFLIT_VERSION</c>).</summary>
public sealed class UpdateRequestRequest
{
    /// <summary>Version lue avec la demande.</summary>
    /// <example>51010</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(30, ErrorMessage = "La version est invalide.")]
    public string? Version { get; set; }

    /// <summary>Produit du catalogue ; écarte le nom libre. Verrouillé après la validation (422 <c>DEMANDE_VERROUILLEE</c>).</summary>
    public Guid? ProductId { get; set; }

    /// <summary>Nom libre ; écarte le produit du catalogue. Verrouillé après la validation.</summary>
    [StringLength(100, ErrorMessage = "Trop long (100 caractères au maximum).")]
    public string? FreeProductName { get; set; }

    /// <summary>Quantité et unité. Verrouillées après la validation.</summary>
    public QuantityBody? Quantity { get; set; }

    /// <summary>Zone. Verrouillée après la validation.</summary>
    public Guid? ZoneId { get; set; }

    /// <summary>Date de besoin : modifiable jusqu'à la livraison (droit <c>Requests.UpdateAny</c> après la validation).</summary>
    public DateOnly? NeededBy { get; set; }

    public Priority? Priority { get; set; }

    /// <summary>Remarque ; une chaîne vide l'efface.</summary>
    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? Note { get; set; }

    public UpdateRequestDto ToDto() => new(
        Version!,
        new RequestChanges(ProductId, FreeProductName, Quantity?.ToInput(), ZoneId, ClearZone: false, NeededBy, Priority, Note));
}

/// <summary>Validation d'une demande, avec une quantité ajustée facultative (même unité).</summary>
public sealed class ApproveBody
{
    /// <summary>Quantité validée si elle diffère de la demande (ancienne et nouvelle valeurs sont tracées dans l'historique).</summary>
    public QuantityBody? Quantity { get; set; }
}

/// <summary>Motif d'un refus, d'une annulation ou d'un solde : une valeur de la liste du cas (<c>GET /settings/materials</c>) ; <c>Other</c> impose une remarque.</summary>
public sealed class ReasonBody
{
    /// <example>StockSufficient</example>
    [StringLength(50, ErrorMessage = "Trop long (50 caractères au maximum).")]
    public string? ReasonCode { get; set; }

    /// <summary>Remarque (200 caractères au plus), obligatoire pour <c>Other</c>.</summary>
    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? ReasonNote { get; set; }
}

/// <summary>Réception d'une demande livrée.</summary>
public sealed class ReceiveBody
{
    /// <summary>Remarque facultative (200 caractères au plus).</summary>
    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? Note { get; set; }
}

/// <summary>Rattachement d'un produit du catalogue à une demande en nom libre.</summary>
public sealed class LinkProductBody
{
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public Guid? ProductId { get; set; }
}

/// <summary>Lot de demandes : 50 au plus pour valider, 100 au plus pour archiver.</summary>
public sealed class RequestIdsBody
{
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public List<Guid>? RequestIds { get; set; }
}
