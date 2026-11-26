using System.Globalization;
using Chantier.Core.Entities.Common;
using Chantier.Core.Exceptions;
using Chantier.Core.Materials;

namespace Chantier.Core.Entities.Materials;

/// <summary>
/// Livraison d'un camion (LIV-001...) : <b>un fait de chantier</b>, jamais refusee a cause du statut d'une demande (elle est alors enregistree non rattachee, avec son motif).
/// Creable hors ligne (<see cref="ClientId"/>). Annulee, elle reste visible et n'entre plus dans aucun total ; son numero n'est jamais reutilise.
/// <see cref="QuantityInRequestUnit"/> et <see cref="Amount"/> sont des <b>caches recalcules</b> par le seul <c>RequestRecalculator</c> ; l'objet <c>commercial</c>
/// (montant) n'est rendu qu'avec <c>Prices.View</c>. La livraison n'a pas de prix propre : prix de la commande x quantite convertie (H-ARCH-07).
/// </summary>
public class Delivery : BasicEntity, ISiteScoped, IHasClientId
{
    // EF Core
    private Delivery()
    {
    }

    public Guid SiteId { get; private set; }

    public Guid? ClientId { get; private set; }

    public DateTimeOffset? ClientCreatedAt { get; private set; }

    /// <summary>Numero <c>LIV-nnn</c> attribue par le serveur, dans la transaction de la creation.</summary>
    public string Number { get; private set; } = string.Empty;

    /// <summary>Demande liee ; <c>null</c> = non rattachee (voir <see cref="UnattachedReason"/>).</summary>
    public Guid? RequestId { get; private set; }

    public UnattachedReason? UnattachedReason { get; private set; }

    public Guid? SupplierId { get; private set; }

    public string? FreeSupplierName { get; private set; }

    public Guid? ProductId { get; private set; }

    public string? FreeProductName { get; private set; }

    public decimal QuantityValue { get; private set; }

    public MeasureUnit Unit { get; private set; }

    /// <summary>Cache : quantite convertie dans l'unite de la demande (seulement si rattachee).</summary>
    public decimal? QuantityInRequestUnit { get; private set; }

    public DateOnly DeliveryDate { get; private set; }

    public string? DeliveryNoteNumber { get; private set; }

    public Conformity Conformity { get; private set; }

    public string? ReserveReasonCode { get; private set; }

    public string? ReserveNote { get; private set; }

    public DeliveryStatus Status { get; private set; }

    public string? CancelReasonCode { get; private set; }

    public string? CancelReasonNote { get; private set; }

    public DateTimeOffset? CancelledAt { get; private set; }

    public Guid? CancelledBy { get; private set; }

    /// <summary>Cache commercial : <c>QuantityInRequestUnit</c> x prix de la commande, arrondi au centime. Jamais rendu sans <c>Prices.View</c>.</summary>
    public decimal? Amount { get; private set; }

    public Guid? PossibleDuplicateOfId { get; private set; }

    /// <summary>
    /// Cache : nombre de photos du bon <b>dont le fichier est recu</b> (R2-05 : une metadonnee sans fichier n'est pas une photo) ; sert au badge « BL manquant » et au filtre sans
    /// recharger les photos. La limite de 5 photos se calcule a part, sur les photos recues et les envois recents en attente.
    /// </summary>
    public int PhotoCount { get; private set; }

    public bool IsAttached => RequestId is not null;

    public bool IsCancelled => Status == DeliveryStatus.Cancelled;

    public Quantity Delivered => new(QuantityValue, Unit);

    /// <summary>« Ni n° de BL ni photo » : badge « BL manquant » et filtre « A completer ».</summary>
    public bool IsNoteMissing => DeliveryNoteNumber is null && PhotoCount == 0;

    public static Delivery Create(
        Guid siteId,
        string number,
        Guid? clientId,
        DateTimeOffset? clientCreatedAt,
        ValidatedDeliveryFields fields,
        Guid? requestId,
        UnattachedReason? unattachedReason,
        Guid? possibleDuplicateOfId)
    {
        var delivery = new Delivery
        {
            SiteId = siteId,
            ClientId = clientId,
            ClientCreatedAt = clientCreatedAt,
            Number = number,
            RequestId = requestId,
            UnattachedReason = requestId is null ? unattachedReason ?? global::Chantier.Core.Entities.Materials.UnattachedReason.NoRequestChosen : null,
            SupplierId = fields.SupplierId,
            FreeSupplierName = fields.FreeSupplierName,
            ProductId = fields.ProductId,
            FreeProductName = fields.FreeProductName,
            Status = DeliveryStatus.Recorded,
            PossibleDuplicateOfId = possibleDuplicateOfId,
        };
        delivery.AssignEditable(fields);
        return delivery;
    }

    /// <summary>Champs actuels, dans la forme de saisie.</summary>
    public DeliveryFields CurrentFields() => new(
        SupplierId, FreeSupplierName, ProductId, FreeProductName, QuantityValue, Unit, DeliveryDate, DeliveryNoteNumber, Conformity, ReserveReasonCode, ReserveNote);

    /// <summary>Champs que <paramref name="next"/> modifierait (noms de <see cref="DeliveryFieldNames"/>) : sert a ne rien ecrire quand rien ne change.</summary>
    public IReadOnlyList<string> ChangedFields(ValidatedDeliveryFields next)
    {
        var changed = new List<string>();
        if (next.Quantity.Value != QuantityValue || next.Quantity.Unit != Unit)
        {
            changed.Add(DeliveryFieldNames.Quantity);
        }

        if (next.DeliveryDate != DeliveryDate)
        {
            changed.Add(DeliveryFieldNames.DeliveryDate);
        }

        if (next.DeliveryNoteNumber != DeliveryNoteNumber)
        {
            changed.Add(DeliveryFieldNames.DeliveryNoteNumber);
        }

        if (next.Conformity != Conformity)
        {
            changed.Add(DeliveryFieldNames.Conformity);
        }

        if (next.ReserveReasonCode != ReserveReasonCode)
        {
            changed.Add(DeliveryFieldNames.ReserveReasonCode);
        }

        if (next.ReserveNote != ReserveNote)
        {
            changed.Add(DeliveryFieldNames.ReserveNote);
        }

        return changed;
    }

    /// <summary>Corrige quantite, date, n° de BL, conformite et reserve ; renvoie l'historique « ancienne -&gt; nouvelle valeur » (jamais un prix). Une livraison annulee ne se corrige pas.</summary>
    public IReadOnlyList<FieldChange> ApplyEdit(ValidatedDeliveryFields next)
    {
        if (IsCancelled)
        {
            throw new DomainRuleException(ErrorCodes.TransitionInterdite, "Une livraison annulée ne se corrige pas.");
        }

        var changes = new List<FieldChange>();
        foreach (var field in ChangedFields(next))
        {
            changes.Add(field switch
            {
                DeliveryFieldNames.Quantity => new FieldChange(field, MaterialRequest.Describe(Delivered), MaterialRequest.Describe(next.Quantity)),
                DeliveryFieldNames.DeliveryDate => new FieldChange(field, Format(DeliveryDate), Format(next.DeliveryDate)),
                DeliveryFieldNames.DeliveryNoteNumber => new FieldChange(field, DeliveryNoteNumber, next.DeliveryNoteNumber),
                DeliveryFieldNames.Conformity => new FieldChange(field, Conformity.ToString(), next.Conformity.ToString()),
                DeliveryFieldNames.ReserveReasonCode => new FieldChange(field, ReserveReasonCode, next.ReserveReasonCode),
                _ => new FieldChange(field, ReserveNote, next.ReserveNote),
            });
        }

        AssignEditable(next);
        return changes;
    }

    /// <summary>Annule avec un motif ; deja annulee : idempotent, le premier motif est conserve.</summary>
    public TransitionOutcome Cancel(string reasonCode, string? reasonNote, Guid by, DateTimeOffset at)
    {
        if (IsCancelled)
        {
            return TransitionOutcome.AlreadyDone;
        }

        Status = DeliveryStatus.Cancelled;
        CancelReasonCode = reasonCode;
        CancelReasonNote = reasonNote;
        CancelledAt = at;
        CancelledBy = by;
        return TransitionOutcome.Applied;
    }

    /// <summary>Rattache a une demande (une seule fois, H-MAT-23) : le motif de non-rattachement disparait. Les regles (produit, unite, statut) sont verifiees par l'appelant.</summary>
    public void Attach(Guid requestId)
    {
        if (IsCancelled)
        {
            throw new DomainRuleException(ErrorCodes.TransitionInterdite, "Une livraison annulée ne se rattache pas.");
        }

        if (IsAttached)
        {
            throw new DomainRuleException(ErrorCodes.LivraisonDejaRattachee, "Cette livraison est déjà rattachée à une demande.");
        }

        RequestId = requestId;
        UnattachedReason = null;
    }

    /// <summary>Une photo recue de plus (fichier stocke) : appele par le service des photos, dans la transaction qui marque la photo envoyee.</summary>
    public void AddPhoto() => PhotoCount++;

    /// <summary>Ecrit les caches : <b>seul le recalcul l'appelle</b>.</summary>
    public void ApplyComputed(decimal? quantityInRequestUnit, decimal? amount)
    {
        QuantityInRequestUnit = quantityInRequestUnit;
        Amount = amount;
    }

    private static string Format(DateOnly date) => date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    private void AssignEditable(ValidatedDeliveryFields fields)
    {
        QuantityValue = fields.Quantity.Value;
        Unit = fields.Quantity.Unit;
        DeliveryDate = fields.DeliveryDate;
        DeliveryNoteNumber = fields.DeliveryNoteNumber;
        Conformity = fields.Conformity;
        ReserveReasonCode = fields.ReserveReasonCode;
        ReserveNote = fields.ReserveNote;
    }
}
