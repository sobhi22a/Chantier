using System.ComponentModel.DataAnnotations;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;

namespace Chantier.WebApi.Models.Materials;

/// <summary>
/// Commande d'une demande validée. Quantité et unité sont celles de la demande (non modifiables) ; le montant est calculé par le serveur ; le client ne fixe ni le statut
/// ni l'auteur. Réservé aux rôles qui voient les prix (Achats, Admin).
/// </summary>
public sealed class CreateOrderRequest
{
    /// <summary>Identifiant généré par le client : un renvoi donne 200 et la même commande, sans nouvel effet.</summary>
    /// <example>7c1e6a52-0d3b-4c59-9a43-6f1f2b9d8e10</example>
    public Guid? ClientId { get; set; }

    /// <summary>Fournisseur du catalogue, actif (422 <c>FOURNISSEUR_INACTIF</c> sinon).</summary>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public Guid? SupplierId { get; set; }

    /// <summary>Date de commande complète, pas dans le futur (heure d'Algérie).</summary>
    /// <example>2026-11-25</example>
    public DateOnly? OrderDate { get; set; }

    /// <summary>Livraison prévue, complète et pas avant la date de commande. Au-delà de la date de besoin : avertissement (<c>plannedAfterNeedDays</c>), jamais un blocage.</summary>
    /// <example>2026-11-26</example>
    public DateOnly? ExpectedDeliveryDate { get; set; }

    /// <summary>Prix unitaire hors taxes par unité de commande, en DZD, supérieur à 0, 2 décimales au plus. Facultatif (« à renseigner »).</summary>
    /// <example>780.00</example>
    public decimal? UnitPrice { get; set; }

    /// <summary>N° du bon de commande (50 caractères au plus).</summary>
    /// <example>BC-2026-044</example>
    [StringLength(50, ErrorMessage = "Trop long (50 caractères au maximum).")]
    public string? PurchaseOrderNumber { get; set; }

    /// <summary>Remarque (200 caractères au plus).</summary>
    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? Note { get; set; }

    public CreateOrderDto ToDto() => new(ClientId, new OrderFields(SupplierId, OrderDate, ExpectedDeliveryDate, UnitPrice, PurchaseOrderNumber, Note));
}

/// <summary>
/// Modification d'une commande : seuls les champs présents changent (la date de commande, la quantité et l'unité ne se modifient pas ; une valeur déjà posée se remplace,
/// elle ne s'efface pas). <c>version</c> détecte une modification concurrente (409 <c>CONFLIT_VERSION</c>).
/// </summary>
public sealed class UpdateOrderRequest
{
    /// <summary>Version de la commande, lue dans <c>order.version</c>.</summary>
    /// <example>51002</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(30, ErrorMessage = "La version est invalide.")]
    public string? Version { get; set; }

    public Guid? SupplierId { get; set; }

    public DateOnly? ExpectedDeliveryDate { get; set; }

    /// <summary>Nouveau prix : recalcule le montant de la commande et de chaque livraison (événement sensible <c>OrderCommercialEdited</c>).</summary>
    public decimal? UnitPrice { get; set; }

    [StringLength(50, ErrorMessage = "Trop long (50 caractères au maximum).")]
    public string? PurchaseOrderNumber { get; set; }

    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? Note { get; set; }

    public UpdateOrderDto ToDto() => new(Version!, new OrderChanges(SupplierId, ExpectedDeliveryDate, UnitPrice, PurchaseOrderNumber, Note));
}

/// <summary>
/// Enregistrement d'une livraison, y compris hors ligne : <c>clientId</c> rend l'envoi idempotent. Le client ne fixe ni le numéro, ni le statut, ni le montant, ni le motif de
/// non-rattachement. Une livraison est un fait de chantier : elle n'est jamais refusée à cause du statut de la demande (elle est alors enregistrée non rattachée).
/// </summary>
public sealed class CreateDeliveryRequest
{
    /// <summary>Identifiant généré par le téléphone : un renvoi donne 200 et la même livraison, sans nouveau numéro.</summary>
    /// <example>7c1e6a52-0d3b-4c59-9a43-6f1f2b9d8e10</example>
    public Guid? ClientId { get; set; }

    /// <summary>Heure du téléphone (« saisi le ») : information seulement.</summary>
    public DateTimeOffset? ClientCreatedAt { get; set; }

    /// <summary>Demande livrée ; absente = livraison non rattachée. Une demande d'un autre chantier : 404.</summary>
    public Guid? RequestId { get; set; }

    /// <summary>Fournisseur du catalogue (par défaut celui de la commande) ; exactement un de <c>supplierId</c> et <c>freeSupplierName</c>.</summary>
    public Guid? SupplierId { get; set; }

    /// <summary>« Autre fournisseur » : nom libre de 3 à 100 caractères.</summary>
    [StringLength(100, ErrorMessage = "Trop long (100 caractères au maximum).")]
    public string? FreeSupplierName { get; set; }

    /// <summary>Produit du catalogue ; sans demande seulement (avec une demande, c'est celui de la demande : un autre produit donne 422 <c>PRODUIT_DIFFERENT</c>).</summary>
    public Guid? ProductId { get; set; }

    [StringLength(100, ErrorMessage = "Trop long (100 caractères au maximum).")]
    public string? FreeProductName { get; set; }

    /// <summary>Quantité reçue, dans l'unité de la demande ou une unité convertible (sac, kg, T) ; sinon 422 <c>UNITES_INCOMPATIBLES</c>.</summary>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public QuantityBody? Quantity { get; set; }

    /// <summary>Date de livraison complète, pas dans le futur (heure d'Algérie).</summary>
    /// <example>2026-11-25</example>
    public DateOnly? DeliveryDate { get; set; }

    /// <summary>N° du bon de livraison (30 caractères au plus), mis en majuscules.</summary>
    /// <example>BL-4471</example>
    [StringLength(30, ErrorMessage = "Trop long (30 caractères au maximum).")]
    public string? DeliveryNoteNumber { get; set; }

    /// <summary><c>Conform</c> (défaut) ou <c>WithReserve</c> (exige <c>reserveReasonCode</c>).</summary>
    public Conformity? Conformity { get; set; }

    /// <summary>Motif de réserve, de la liste de <c>GET /settings/materials</c> ; <c>Other</c> impose une remarque.</summary>
    [StringLength(50, ErrorMessage = "Trop long (50 caractères au maximum).")]
    public string? ReserveReasonCode { get; set; }

    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? ReserveNote { get; set; }

    public CreateDeliveryDto ToDto() => new(
        ClientId,
        ClientCreatedAt,
        RequestId,
        new DeliveryFields(
            SupplierId, FreeSupplierName, ProductId, FreeProductName, Quantity?.Value, Quantity?.Unit, DeliveryDate, DeliveryNoteNumber,
            Conformity, ReserveReasonCode, ReserveNote));
}

/// <summary>Correction d'une livraison : seuls les champs présents changent. <c>version</c> détecte une correction concurrente (409 <c>CONFLIT_VERSION</c>).</summary>
public sealed class UpdateDeliveryRequest
{
    /// <summary>Version lue avec la livraison.</summary>
    /// <example>49800</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(30, ErrorMessage = "La version est invalide.")]
    public string? Version { get; set; }

    public QuantityBody? Quantity { get; set; }

    public DateOnly? DeliveryDate { get; set; }

    /// <summary>N° de BL ; une valeur déjà posée se remplace, elle ne s'efface pas.</summary>
    [StringLength(30, ErrorMessage = "Trop long (30 caractères au maximum).")]
    public string? DeliveryNoteNumber { get; set; }

    public Conformity? Conformity { get; set; }

    [StringLength(50, ErrorMessage = "Trop long (50 caractères au maximum).")]
    public string? ReserveReasonCode { get; set; }

    [StringLength(200, ErrorMessage = "Trop long (200 caractères au maximum).")]
    public string? ReserveNote { get; set; }

    public UpdateDeliveryDto ToDto() => new(
        Version!,
        new DeliveryChanges(Quantity?.ToInput(), DeliveryDate, DeliveryNoteNumber, Conformity, ReserveReasonCode, ReserveNote));
}

/// <summary>Rattachement d'une livraison à une demande du même chantier et du même produit.</summary>
public sealed class AttachBody
{
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public Guid? RequestId { get; set; }
}

/// <summary>Métadonnées d'une photo de bon de livraison (créables hors ligne) ; le fichier JPEG est envoyé ensuite par <c>PUT .../content</c>.</summary>
public sealed class CreatePhotoRequest
{
    /// <summary>Identifiant généré par le téléphone : un renvoi donne 200 et les mêmes métadonnées.</summary>
    /// <example>7c1e6a52-0d3b-4c59-9a43-6f1f2b9d8e10</example>
    public Guid? ClientId { get; set; }

    public DateTimeOffset? ClientCreatedAt { get; set; }

    /// <summary>Heure de la prise de vue (téléphone) : information seulement.</summary>
    public DateTimeOffset? TakenAt { get; set; }

    /// <summary>Toujours <c>image/jpeg</c> (415 <c>TYPE_FICHIER_REFUSE</c> sinon).</summary>
    /// <example>image/jpeg</example>
    [StringLength(50, ErrorMessage = "Trop long (50 caractères au maximum).")]
    public string? ContentType { get; set; }

    /// <summary>Taille du fichier envoyé, en octets (413 <c>FICHIER_TROP_GROS</c> au-delà de <c>maxPhotoBytes</c>).</summary>
    public long? SizeBytes { get; set; }

    /// <summary>Empreinte SHA-256 du fichier envoyé (64 caractères hexadécimaux) : rend l'envoi du fichier idempotent et vérifie son intégrité.</summary>
    [StringLength(64, ErrorMessage = "L'empreinte doit comporter 64 caractères.")]
    public string? Sha256 { get; set; }

    public CreatePhotoDto ToDto() => new(ClientId, ClientCreatedAt, TakenAt, ContentType, SizeBytes, Sha256);
}
