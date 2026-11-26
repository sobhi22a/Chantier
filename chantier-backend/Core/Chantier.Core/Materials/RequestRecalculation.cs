using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;

namespace Chantier.Core.Materials;

/// <summary>
/// Ecrit les evenements de l'historique d'une demande ou d'une livraison, dans la transaction de l'action. <b>Toute ecriture d'evenement modifie aussi la ligne de son
/// sujet</b> (elle avance sa version) : la synchronisation envoie la ligne avec son historique, un evenement ecrit sans toucher la ligne resterait invisible des
/// telephones. L'auteur et l'heure sont ceux de l'audit (serveur), jamais ceux du telephone (<c>DeviceAt</c> n'est qu'une information).
/// </summary>
public interface IRequestEventWriter
{
    void Add(
        MaterialRequest request,
        MaterialEventType type,
        RequestActionContext context,
        RequestStatus? fromStatus = null,
        RequestStatus? toStatus = null,
        string? reasonCode = null,
        string? note = null,
        IReadOnlyList<FieldChange>? changes = null);

    void Add(
        Delivery delivery,
        MaterialEventType type,
        RequestActionContext context,
        string? reasonCode = null,
        string? note = null,
        IReadOnlyList<FieldChange>? changes = null);
}

/// <summary>Ce qui a declenche un recalcul : sert de <c>reasonCode</c> a l'evenement <c>StatusRecomputed</c> (le client le traduit : « Recalcul suite a l'annulation de LIV-006 »).</summary>
public static class RecalculationTriggers
{
    public const string OrderPlaced = "OrderPlaced";
    public const string DeliveryRegistered = "DeliveryRegistered";
    public const string DeliveryEdited = "DeliveryEdited";
    public const string DeliveryCancelled = "DeliveryCancelled";
    public const string DeliveryAttached = "DeliveryAttached";
    public const string BagMassChanged = "BagMassChanged";
}

/// <summary>
/// <b>Seul ecrivain</b> des colonnes calculees d'une demande (recu cumule, statut apres <c>Ordered</c>, solde) et des caches de ses livraisons (quantite convertie,
/// montant) : ils se recalculent a chaque creation, correction, annulation, rattachement de livraison, creation de commande et changement de masse de sac,
/// <b>dans la transaction de l'appelant</b>, dans les deux sens, d'apres les livraisons non annulees (<see cref="RequestStatusCalculator"/>).
/// </summary>
public interface IRequestRecalculator
{
    /// <summary>
    /// Recalcule la demande (deja chargee et suivie, verrouillee par l'appelant). Une demande validee garde son statut (livraisons « retenues » : seul le recu change) ;
    /// une demande non commandee ou deja receptionnee n'est pas touchee. Un changement de statut ajoute un evenement <c>StatusRecomputed</c>.
    /// </summary>
    /// <param name="trigger">Un de <see cref="RecalculationTriggers"/>.</param>
    /// <param name="reference">N° de la livraison a l'origine du recalcul (<c>LIV-006</c>), si elle existe.</param>
    Task RecomputeAsync(MaterialRequest request, string trigger, string? reference, RequestActionContext context, CancellationToken cancellationToken = default);
}
