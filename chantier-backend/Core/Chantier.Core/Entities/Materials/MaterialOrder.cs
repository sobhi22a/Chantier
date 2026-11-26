using Chantier.Core.Entities.Common;
using Chantier.Core.Materials;

namespace Chantier.Core.Entities.Materials;

/// <summary>
/// Commande d'une demande validee (une seule commande active par demande, sans numero propre) : fournisseur, date, date de livraison prevue, prix.
/// <b>Prix unitaire, montant et numero de bon de commande sont des donnees commerciales</b> : jamais rendus sans <c>Prices.View</c>, jamais synchronises (ADR 0012) ;
/// l'objet <c>commercial</c> n'est construit que par <see cref="CommercialProjection"/>. Quantite et unite sont celles de la demande (non modifiables).
/// Annulee, elle reste en base (historique) et libere la demande ; une nouvelle commande est alors possible.
/// </summary>
public class MaterialOrder : BasicEntity, ISiteScoped
{
    public const int PurchaseOrderNumberMaxLength = 50;

    // EF Core
    private MaterialOrder()
    {
    }

    public Guid SiteId { get; private set; }

    public Guid RequestId { get; private set; }

    public Guid? ClientId { get; private set; }

    public Guid SupplierId { get; private set; }

    public DateOnly OrderDate { get; private set; }

    public DateOnly? ExpectedDeliveryDate { get; private set; }

    /// <summary>Prix unitaire hors taxes par unite de commande, en DZD (commercial).</summary>
    public decimal? UnitPrice { get; private set; }

    /// <summary>Montant = quantite de la demande x prix unitaire, arrondi au centime (commercial, calcule par le serveur).</summary>
    public decimal? Amount { get; private set; }

    public string? PurchaseOrderNumber { get; private set; }

    public string? Note { get; private set; }

    public DateTimeOffset? CancelledAt { get; private set; }

    public Guid? CancelledBy { get; private set; }

    public string? CancelReasonCode { get; private set; }

    public string? CancelReasonNote { get; private set; }

    public bool IsActive => CancelledAt is null;

    public static MaterialOrder Create(Guid siteId, Guid requestId, Guid? clientId, ValidatedOrderFields fields, Quantity ordered)
    {
        var order = new MaterialOrder { SiteId = siteId, RequestId = requestId, ClientId = clientId, OrderDate = fields.OrderDate };
        order.Assign(fields, ordered);
        return order;
    }

    /// <summary>Champs actuels, dans la forme de saisie (la date de commande ne se modifie pas).</summary>
    public OrderFields CurrentFields() => new(SupplierId, OrderDate, ExpectedDeliveryDate, UnitPrice, PurchaseOrderNumber, Note);

    /// <summary>
    /// Applique des champs valides et renvoie les deux historiques : modifications <b>non commerciales</b> (fournisseur, date prevue, remarque) et modifications
    /// <b>commerciales</b> (prix, n° de bon de commande ; evenement sensible, jamais montre sans <c>Prices.View</c>).
    /// </summary>
    public (IReadOnlyList<FieldChange> General, IReadOnlyList<FieldChange> Commercial) ApplyEdit(ValidatedOrderFields next, Quantity ordered)
    {
        var general = new List<FieldChange>();
        var commercial = new List<FieldChange>();

        if (next.SupplierId != SupplierId)
        {
            general.Add(new FieldChange(OrderFieldNames.SupplierId, SupplierId.ToString(), next.SupplierId.ToString()));
        }

        if (next.ExpectedDeliveryDate != ExpectedDeliveryDate)
        {
            general.Add(new FieldChange(OrderFieldNames.ExpectedDeliveryDate, Format(ExpectedDeliveryDate), Format(next.ExpectedDeliveryDate)));
        }

        if (next.Note != Note)
        {
            general.Add(new FieldChange(OrderFieldNames.Note, Note, next.Note));
        }

        if (next.UnitPrice != UnitPrice)
        {
            commercial.Add(new FieldChange(OrderFieldNames.UnitPrice, UnitPrice?.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture), next.UnitPrice?.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture)));
        }

        if (next.PurchaseOrderNumber != PurchaseOrderNumber)
        {
            commercial.Add(new FieldChange(OrderFieldNames.PurchaseOrderNumber, PurchaseOrderNumber, next.PurchaseOrderNumber));
        }

        Assign(next, ordered);
        return (general, commercial);
    }

    public void Cancel(string reasonCode, string? reasonNote, Guid by, DateTimeOffset at)
    {
        CancelledAt = at;
        CancelledBy = by;
        CancelReasonCode = reasonCode;
        CancelReasonNote = reasonNote;
    }

    private static string? Format(DateOnly? date) => date?.ToString("yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture);

    private void Assign(ValidatedOrderFields fields, Quantity ordered)
    {
        SupplierId = fields.SupplierId;
        ExpectedDeliveryDate = fields.ExpectedDeliveryDate;
        UnitPrice = fields.UnitPrice;
        Amount = fields.UnitPrice is { } price ? Money.Amount(ordered.Value, price) : null;
        PurchaseOrderNumber = fields.PurchaseOrderNumber;
        Note = fields.Note;
    }
}
