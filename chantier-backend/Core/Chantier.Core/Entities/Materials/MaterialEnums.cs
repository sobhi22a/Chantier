namespace Chantier.Core.Entities.Materials;

/// <summary>Statut d'une demande de materiaux : calcule et change par le serveur seulement (le client ne fixe jamais un statut).</summary>
public enum RequestStatus
{
    Requested,
    Validated,
    Rejected,
    Ordered,
    PartiallyDelivered,
    Delivered,
    Received,
    Cancelled,
}

/// <summary>Urgence : <c>Normal</c> par defaut ; <c>Blocking</c> = le chantier s'arrete (H-MAT-06).</summary>
public enum Priority
{
    Normal,
    Urgent,
    Blocking,
}

public enum ProductCategory
{
    Binders,
    Steel,
    Masonry,
    Aggregates,
    Admixtures,
    FinishingWorks,
    Other,
}

/// <summary>Type d'evenement de l'historique. <c>OrderCommercialEdited</c> est sensible : rendu seulement avec <c>Prices.View</c>, jamais synchronise.</summary>
public enum MaterialEventType
{
    Created,
    Edited,
    Approved,
    QuantityAdjusted,
    Rejected,
    Cancelled,
    Ordered,
    OrderEdited,
    OrderCommercialEdited,
    OrderCancelled,
    DeliveryRegistered,
    DeliveryEdited,
    DeliveryCancelled,
    DeliveryAttached,
    StatusRecomputed,
    Settled,
    Received,
    Archived,
    Restored,
    ProductLinked,
    PhotoAdded,
}

/// <summary>Origine d'un evenement : API directe, push de synchronisation, ou systeme (recalcul).</summary>
public enum MaterialEventSource
{
    Api,
    Sync,
    System,
}

public enum MaterialSubjectType
{
    Request,
    Delivery,
}

/// <summary>Etat d'une livraison : enregistree, ou annulee (elle reste visible mais n'entre plus dans aucun total).</summary>
public enum DeliveryStatus
{
    Recorded,
    Cancelled,
}

/// <summary>Conformite a la reception : « Avec reserve » exige un motif de la liste (quantite manquante, produit abime...).</summary>
public enum Conformity
{
    Conform,
    WithReserve,
}

/// <summary>Pourquoi une livraison n'est liee a aucune demande : aucune choisie, demande close ou annulee, demande introuvable (envoi hors ligne).</summary>
public enum UnattachedReason
{
    NoRequestChosen,
    RequestNotOpen,
    RequestMissing,
}

/// <summary>Etat du fichier d'une photo : les metadonnees existent (<c>Pending</c>), puis le binaire est envoye (<c>Uploaded</c>).</summary>
public enum PhotoContentStatus
{
    Pending,
    Uploaded,
}
