using System.Globalization;
using Chantier.Core.Entities.Common;
using Chantier.Core.Exceptions;
using Chantier.Core.Materials;

namespace Chantier.Core.Entities.Materials;

/// <summary>Resultat d'une transition : <c>AlreadyDone</c> = l'etat vise est deja atteint (idempotence : « Deja validee »), rien n'est ecrit.</summary>
public enum TransitionOutcome
{
    Applied,
    AlreadyDone,
}

/// <summary>
/// Demande de materiaux d'un chantier : un produit, une quantite avec son unite, une date de besoin (DEM-001...). Creable hors ligne (<see cref="ClientId"/>).
/// <b>Le statut ne change que par les methodes de cette classe</b> (jamais par le client) ; les colonnes calculees
/// (<see cref="ReceivedQuantity"/>, statut apres <see cref="RequestStatus.Ordered"/>) ont un seul ecrivain, le recalcul (B5).
/// </summary>
public class MaterialRequest : BasicEntity, ISiteScoped, IHasClientId
{
    // EF Core
    private MaterialRequest()
    {
    }

    public Guid SiteId { get; private set; }

    public Guid? ClientId { get; private set; }

    public DateTimeOffset? ClientCreatedAt { get; private set; }

    /// <summary>Numero <c>DEM-nnn</c> attribue par le serveur, dans la transaction de la creation.</summary>
    public string Number { get; private set; } = string.Empty;

    public Guid? ProductId { get; private set; }

    /// <summary>Nom libre (« Autre produit ») ; conserve apres le rattachement a un produit du catalogue.</summary>
    public string? FreeProductName { get; private set; }

    public decimal QuantityValue { get; private set; }

    public MeasureUnit Unit { get; private set; }

    public Guid? ZoneId { get; private set; }

    public DateOnly NeededBy { get; private set; }

    public Priority Priority { get; private set; }

    public string? Note { get; private set; }

    public RequestStatus Status { get; private set; }

    /// <summary>Motif du refus ou de l'annulation (<see cref="RequestStatus.Rejected"/>, <see cref="RequestStatus.Cancelled"/>).</summary>
    public string? StatusReasonCode { get; private set; }

    public string? StatusReasonNote { get; private set; }

    /// <summary>Cache : somme des livraisons non annulees, dans l'unite de la demande. Ecrit par le seul recalcul (B5).</summary>
    public decimal ReceivedQuantity { get; private set; }

    /// <summary>Manque definitif accepte par Achats ou le conducteur (« solde »).</summary>
    public bool IsSettled { get; private set; }

    public Guid? PossibleDuplicateOfId { get; private set; }

    public DateTimeOffset? ArchivedAt { get; private set; }

    public Guid? ArchivedBy { get; private set; }

    public bool IsArchived => ArchivedAt is not null;

    public Quantity Ordered => new(QuantityValue, Unit);

    /// <summary>Ouverte = pas encore terminee : demandee, validee, commandee, livree partiellement ou livree (pas encore receptionnee).</summary>
    public bool IsOpen => Status is RequestStatus.Requested or RequestStatus.Validated or RequestStatus.Ordered
        or RequestStatus.PartiallyDelivered or RequestStatus.Delivered;

    public static MaterialRequest Create(
        Guid siteId,
        string number,
        Guid? clientId,
        DateTimeOffset? clientCreatedAt,
        ValidatedRequestFields fields,
        Guid? possibleDuplicateOfId)
    {
        var request = new MaterialRequest
        {
            SiteId = siteId,
            ClientId = clientId,
            ClientCreatedAt = clientCreatedAt,
            Number = number,
            Status = RequestStatus.Requested,
            PossibleDuplicateOfId = possibleDuplicateOfId,
        };
        request.Assign(fields);
        return request;
    }

    /// <summary>Champs actuels, dans la forme de saisie (le nom libre n'est repris que sans produit du catalogue).</summary>
    public RequestFields CurrentFields() => new(
        ProductId,
        ProductId is null ? FreeProductName : null,
        QuantityValue,
        Unit,
        ZoneId,
        NeededBy,
        Priority,
        Note);

    /// <summary>
    /// Champs que la saisie <paramref name="wanted"/> changerait, <b>avant validation</b> : permet de refuser un verrou de statut (<see cref="EnsureEditable"/>)
    /// avant les validations de contenu (un produit change sur une demande validee est « verrouillee », pas « unite non autorisee »).
    /// </summary>
    public IReadOnlyList<string> ChangedFields(RequestFields wanted)
    {
        var changed = new List<string>();
        if (wanted.ProductId != ProductId)
        {
            changed.Add(RequestFieldNames.ProductId);
        }

        if (wanted.ProductId is null && Clean(wanted.FreeProductName) != FreeProductName)
        {
            changed.Add(RequestFieldNames.FreeProductName);
        }

        if (wanted.QuantityValue != QuantityValue || wanted.Unit != Unit)
        {
            changed.Add(RequestFieldNames.Quantity);
        }

        if (wanted.ZoneId != ZoneId)
        {
            changed.Add(RequestFieldNames.ZoneId);
        }

        if (wanted.NeededBy != NeededBy)
        {
            changed.Add(RequestFieldNames.NeededBy);
        }

        if ((wanted.Priority ?? Priority.Normal) != Priority)
        {
            changed.Add(RequestFieldNames.Priority);
        }

        if (Clean(wanted.Note) != Note)
        {
            changed.Add(RequestFieldNames.Note);
        }

        return changed;
    }

    private static string? Clean(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    /// <summary>Champs qui differeraient si <paramref name="next"/> etait applique (noms de <see cref="RequestFieldNames"/>).</summary>
    public IReadOnlyList<string> ChangedFields(ValidatedRequestFields next)
    {
        var changed = new List<string>();
        if (next.ProductId != ProductId)
        {
            changed.Add(RequestFieldNames.ProductId);
        }

        if (next.ProductId is null && next.FreeProductName != FreeProductName)
        {
            changed.Add(RequestFieldNames.FreeProductName);
        }

        if (next.Quantity.Value != QuantityValue || next.Quantity.Unit != Unit)
        {
            changed.Add(RequestFieldNames.Quantity);
        }

        if (next.ZoneId != ZoneId)
        {
            changed.Add(RequestFieldNames.ZoneId);
        }

        if (next.NeededBy != NeededBy)
        {
            changed.Add(RequestFieldNames.NeededBy);
        }

        if (next.Priority != Priority)
        {
            changed.Add(RequestFieldNames.Priority);
        }

        if (next.Note != Note)
        {
            changed.Add(RequestFieldNames.Note);
        }

        return changed;
    }

    /// <summary>
    /// Verifie qu'une modification de ces champs est encore possible : jusqu'a <c>Requested</c> tout, apres validation seulement date, urgence et remarque
    /// (<c>DEMANDE_VERROUILLEE</c>), et plus rien une fois livree ou close (<c>TRANSITION_INTERDITE</c>). Le droit de modifier (auteur, <c>UpdateAny</c>) est controle par le service.
    /// </summary>
    public void EnsureEditable(IEnumerable<string> changedFields)
    {
        switch (Status)
        {
            case RequestStatus.Requested:
                return;

            case RequestStatus.Validated or RequestStatus.Ordered or RequestStatus.PartiallyDelivered:
                if (changedFields.Any(RequestFieldNames.Locked.Contains))
                {
                    throw new DomainRuleException(
                        ErrorCodes.DemandeVerrouillee,
                        "Demande validée : la quantité et le produit ne se modifient plus. Annulez-la et créez-en une nouvelle.");
                }

                return;

            default:
                throw Forbidden();
        }
    }

    /// <summary>Applique des champs valides et renvoie l'historique « ancienne -&gt; nouvelle valeur » (jamais un prix).</summary>
    public IReadOnlyList<FieldChange> ApplyEdit(ValidatedRequestFields next)
    {
        var changes = new List<FieldChange>();
        foreach (var field in ChangedFields(next))
        {
            changes.Add(field switch
            {
                RequestFieldNames.ProductId => new FieldChange(field, ProductId?.ToString(), next.ProductId?.ToString()),
                RequestFieldNames.FreeProductName => new FieldChange(field, FreeProductName, next.FreeProductName),
                RequestFieldNames.Quantity => new FieldChange(field, Describe(Ordered), Describe(next.Quantity)),
                RequestFieldNames.ZoneId => new FieldChange(field, ZoneId?.ToString(), next.ZoneId?.ToString()),
                RequestFieldNames.NeededBy => new FieldChange(field, NeededBy.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture), next.NeededBy.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)),
                RequestFieldNames.Priority => new FieldChange(field, Priority.ToString(), next.Priority.ToString()),
                _ => new FieldChange(field, Note, next.Note),
            });
        }

        Assign(next);
        return changes;
    }

    /// <summary>Valide (avec, au besoin, une quantite ajustee dans la meme unite). Deja validee : idempotent ; deja validee avec une autre quantite : <c>DEMANDE_VERROUILLEE</c>.</summary>
    public TransitionOutcome Approve(Quantity? adjusted, out FieldChange? adjustment)
    {
        adjustment = null;

        if (Status == RequestStatus.Validated)
        {
            if (adjusted is { } requested && requested.Value != QuantityValue)
            {
                throw new DomainRuleException(ErrorCodes.DemandeVerrouillee, "Demande validée : la quantité et le produit ne se modifient plus. Annulez-la et créez-en une nouvelle.");
            }

            return TransitionOutcome.AlreadyDone;
        }

        if (Status != RequestStatus.Requested)
        {
            throw Forbidden();
        }

        if (adjusted is { } quantity)
        {
            if (quantity.Unit != Unit)
            {
                throw new DomainRuleException(ErrorCodes.UnitesIncompatibles, "La quantité ajustée doit être dans l'unité de la demande.");
            }

            QuantityRules.Validate(quantity.Value, quantity.Unit);
            if (quantity.Value != QuantityValue)
            {
                adjustment = new FieldChange(RequestFieldNames.Quantity, Describe(Ordered), Describe(quantity));
                QuantityValue = quantity.Value;
            }
        }

        Status = RequestStatus.Validated;
        return TransitionOutcome.Applied;
    }

    public TransitionOutcome Reject(string reasonCode, string? reasonNote)
    {
        if (Status == RequestStatus.Rejected)
        {
            return TransitionOutcome.AlreadyDone;
        }

        if (Status != RequestStatus.Requested)
        {
            throw Forbidden();
        }

        Status = RequestStatus.Rejected;
        StatusReasonCode = reasonCode;
        StatusReasonNote = reasonNote;
        return TransitionOutcome.Applied;
    }

    /// <summary>Annule une demande <c>Requested</c> ou <c>Validated</c> ; deja annulee : idempotent, le premier motif est conserve.</summary>
    public TransitionOutcome Cancel(string reasonCode, string? reasonNote)
    {
        if (Status == RequestStatus.Cancelled)
        {
            return TransitionOutcome.AlreadyDone;
        }

        if (Status is not (RequestStatus.Requested or RequestStatus.Validated))
        {
            throw Forbidden();
        }

        Status = RequestStatus.Cancelled;
        StatusReasonCode = reasonCode;
        StatusReasonNote = reasonNote;
        return TransitionOutcome.Applied;
    }

    public TransitionOutcome Receive()
    {
        if (Status == RequestStatus.Received)
        {
            return TransitionOutcome.AlreadyDone;
        }

        if (Status != RequestStatus.Delivered)
        {
            throw Forbidden();
        }

        Status = RequestStatus.Received;
        return TransitionOutcome.Applied;
    }

    /// <summary>
    /// Solde un manque definitif : <c>PartiallyDelivered</c> vers <c>Delivered</c>. Garde de statut seulement (la garde « au moins une livraison
    /// non annulee » vient avec les livraisons, B6).
    /// </summary>
    public TransitionOutcome Settle()
    {
        if (Status == RequestStatus.Delivered && IsSettled)
        {
            return TransitionOutcome.AlreadyDone;
        }

        if (Status != RequestStatus.PartiallyDelivered)
        {
            throw Forbidden();
        }

        Status = RequestStatus.Delivered;
        IsSettled = true;
        return TransitionOutcome.Applied;
    }

    /// <summary>Commande enregistree : <c>Validated</c> vers <c>Ordered</c> (les livraisons deja retenues sont prises en compte ensuite par le recalcul).</summary>
    public void PlaceOrder()
    {
        if (Status != RequestStatus.Validated)
        {
            throw Forbidden();
        }

        Status = RequestStatus.Ordered;
    }

    /// <summary>Commande annulee (sans livraison) : <c>Ordered</c> vers <c>Validated</c> ; la demande reapparait dans « A commander ».</summary>
    public void CancelOrder()
    {
        if (Status != RequestStatus.Ordered)
        {
            throw Forbidden();
        }

        Status = RequestStatus.Validated;
    }

    /// <summary>
    /// Ecrit le resultat du recalcul (<b>seul le <c>RequestRecalculator</c> l'appelle</b>) : le recu cumule toujours ; le statut et le solde seulement
    /// pour une demande commandee ou livree (une demande validee garde son statut : ses livraisons sont « retenues »). Renvoie vrai si le statut a change.
    /// </summary>
    public bool ApplyComputation(StatusComputation computation)
    {
        ReceivedQuantity = computation.Received;
        if (Status == RequestStatus.Validated)
        {
            return false;
        }

        var changed = Status != computation.Status;
        Status = computation.Status;
        IsSettled = computation.IsSettled;
        return changed;
    }

    /// <summary>Rattache un produit du catalogue a une demande ouverte en nom libre : le nom libre est conserve, quantite et unite sont reverifiees par l'appelant.</summary>
    public TransitionOutcome LinkProduct(Guid productId)
    {
        if (!IsOpen)
        {
            throw Forbidden();
        }

        if (ProductId == productId)
        {
            return TransitionOutcome.AlreadyDone;
        }

        if (ProductId is not null)
        {
            throw Forbidden();
        }

        ProductId = productId;
        return TransitionOutcome.Applied;
    }

    /// <summary>Archive une demande terminee (refusee, annulee ou receptionnee) ; une demande ouverte ne s'archive pas.</summary>
    public TransitionOutcome Archive(Guid by, DateTimeOffset at)
    {
        if (Status is not (RequestStatus.Rejected or RequestStatus.Cancelled or RequestStatus.Received))
        {
            throw Forbidden();
        }

        if (IsArchived)
        {
            return TransitionOutcome.AlreadyDone;
        }

        ArchivedAt = at;
        ArchivedBy = by;
        return TransitionOutcome.Applied;
    }

    public TransitionOutcome Restore()
    {
        if (!IsArchived)
        {
            return TransitionOutcome.AlreadyDone;
        }

        ArchivedAt = null;
        ArchivedBy = null;
        return TransitionOutcome.Applied;
    }

    /// <summary>« 300 sac », « 2,5 t » : valeur sans zeros inutiles puis code d'unite (forme des historiques).</summary>
    public static string Describe(Quantity quantity)
        => $"{DecimalScale.Normalize(quantity.Value).ToString(CultureInfo.InvariantCulture)} {MeasureUnits.Code(quantity.Unit)}";

    private void Assign(ValidatedRequestFields fields)
    {
        // Choisir un produit du catalogue ecarte le nom libre ; choisir un nom libre ecarte le produit. Un nom libre deja conserve
        // apres un rattachement reste en memoire tant que la demande garde son produit.
        if (fields.ProductId is not null)
        {
            if (ProductId != fields.ProductId)
            {
                FreeProductName = null;
            }

            ProductId = fields.ProductId;
        }
        else
        {
            ProductId = null;
            FreeProductName = fields.FreeProductName;
        }

        QuantityValue = fields.Quantity.Value;
        Unit = fields.Quantity.Unit;
        ZoneId = fields.ZoneId;
        NeededBy = fields.NeededBy;
        Priority = fields.Priority;
        Note = fields.Note;
    }

    private static DomainRuleException Forbidden()
        => new(ErrorCodes.TransitionInterdite, "Ce changement de statut n'est pas autorisé.");
}
