using System.Text.Json.Serialization;
using Chantier.Core.Entities.Materials;

namespace Chantier.Core.Materials;

/// <summary>
/// Donnees commerciales d'une commande : prix unitaire HT (par unite de commande), montant (quantite x prix, arrondi au centime), valeur recue (somme des montants
/// arrondis des livraisons) et n° de bon de commande, en DZD. <b>Absent sans <c>Prices.View</c></b> et de toute synchronisation (ADR 0012).
/// </summary>
public sealed record OrderCommercialResponse(
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] decimal? UnitPrice,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] decimal? Amount,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] decimal? ReceivedValue,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? PurchaseOrderNumber);

/// <summary>
/// Commande active d'une demande (une seule, sans numero propre) : fournisseur, date de commande, livraison prevue. Une commande annulee n'apparait plus ici
/// (elle reste dans l'historique de la demande). Quantite et unite sont celles de la demande.
/// </summary>
/// <param name="PlannedAfterNeedDays">Jours entre la date de besoin et la livraison prevue quand elle la depasse (avertissement, jamais un blocage) ; 0 sinon.</param>
/// <param name="Note">
/// Remarque libre de la commande (200 caracteres), visible de tous les roles qui voient la demande, ChefChantier et ChefEquipe compris, et copiee sur leur telephone :
/// ne jamais y saisir de prix, de remise ni de condition commerciale (le prix a son champ reserve a <c>Prices.View</c>). Aucun controle automatique ne peut le garantir sur un texte libre.
/// </param>
/// <param name="Version">Jeton de concurrence de la commande (entier decimal en chaine).</param>
public sealed record OrderResponse(
    Guid Id,
    Guid SupplierId,
    string? SupplierName,
    DateOnly OrderDate,
    DateOnly? ExpectedDeliveryDate,
    int PlannedAfterNeedDays,
    string? Note,
    string Version)
{
    /// <summary>Prix, montant, valeur recue et n° de bon de commande ; absent sans <c>Prices.View</c> (construit uniquement par <see cref="CommercialProjection"/>).</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public OrderCommercialResponse? Commercial { get; init; }
}

/// <summary>Livraison d'une demande, resumee dans son detail : toutes, annulees comprises (une livraison annulee reste visible, barree).</summary>
/// <param name="QuantityInRequestUnit">Quantite convertie dans l'unite de la demande ; absente d'une livraison annulee.</param>
public sealed record RequestDeliveryItem(
    Guid Id,
    string Number,
    DateOnly DeliveryDate,
    Quantity Quantity,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] Quantity? QuantityInRequestUnit,
    DeliveryStatus Status,
    string? DeliveryNoteNumber,
    Conformity Conformity,
    int PhotoCount);

/// <summary>Montant d'une livraison : prix de la commande x quantite convertie, arrondi au centime (DZD). Absent sans <c>Prices.View</c>.</summary>
public sealed record DeliveryCommercialResponse(decimal Amount);

/// <summary>
/// <b>Seul endroit qui construit les objets <c>commercial</c></b> (prix, montants, n° de bon de commande) : ils sont omis sans <c>Prices.View</c> ;
/// la synchronisation ne les construit jamais (ADR 0012).
/// </summary>
public static class CommercialProjection
{
    public static OrderCommercialResponse? ForOrder(MaterialOrder order, decimal receivedValue, bool canViewPrices)
        => canViewPrices
            ? new OrderCommercialResponse(order.UnitPrice, order.Amount, order.UnitPrice is null ? null : receivedValue, order.PurchaseOrderNumber)
            : null;

    public static DeliveryCommercialResponse? ForDelivery(Delivery delivery, bool canViewPrices)
        => canViewPrices && delivery.Amount is { } amount ? new DeliveryCommercialResponse(amount) : null;

    public static FollowUpCommercialResponse? ForFollowUp(decimal orderedAmount, decimal receivedValue, bool canViewPrices)
        => canViewPrices ? new FollowUpCommercialResponse(orderedAmount, receivedValue) : null;
}
