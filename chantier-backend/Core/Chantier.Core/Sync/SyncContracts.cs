using System.Text.Json;
using System.Text.Json.Serialization;

namespace Chantier.Core.Sync;

/// <summary>Noms des entites synchronisees (ADR 0009). Un client ignore une entite qu'il ne connait pas.</summary>
public static class SyncEntities
{
    public const string Site = "site";
    public const string Zone = "zone";
    public const string Member = "member";
    public const string Product = "product";
    public const string Supplier = "supplier";
    public const string Request = "request";
    public const string Delivery = "delivery";
    public const string Photo = "photo";
}

/// <summary>Limites du protocole (ADR 0009) : lot de 100 operations et 1 Mo, pages de 200 lignes (500 au maximum).</summary>
public static class SyncLimits
{
    public const int MaxOperations = 100;
    public const int MaxBodyBytes = 1_048_576;
    public const int DefaultPullLimit = 200;
    public const int MaxPullLimit = 500;
}

/// <summary>Resultats d'une operation de push. Un lot peut reussir partiellement.</summary>
public static class SyncStatuses
{
    public const string Applied = "applied";
    public const string Duplicate = "duplicate";
    public const string Conflict = "conflict";
    public const string Rejected = "rejected";

    /// <summary>Echec momentane du serveur (interblocage, delai depasse) : rien n'est ecrit, l'operation se renvoie telle quelle plus tard (idempotente).</summary>
    public const string Retry = "retry";
}

public static class SyncOperations
{
    public const string Create = "create";
    public const string Update = "update";
    public const string Transition = "transition";

    public static bool IsKnown(string? operation) => operation is Create or Update or Transition;
}

/// <summary>Lecture du <c>payload</c> d'une operation : memes regles JSON que l'API (camelCase, enumerations en chaines).</summary>
public static class SyncJson
{
    public static readonly JsonSerializerOptions Options = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true,
        Converters = { new JsonStringEnumConverter(namingPolicy: null, allowIntegerValues: false) },
    };
}

/// <summary>
/// Une ligne a envoyer au client. <see cref="Data"/> est <b>le meme objet que la reponse REST</b> de l'entite (hors champs reserves) ;
/// <c>null</c> = pierre tombale (la ligne a ete supprimee ou retiree pour cet utilisateur).
/// <see cref="SiteId"/> est <c>null</c> pour une entite <b>globale</b> (produit, fournisseur : communs a tous les chantiers, ADR 0012).
/// </summary>
public sealed record SyncChangeRow(string Entity, Guid Id, Guid? SiteId, ulong Version, object? Data)
{
    public bool IsTombstone => Data is null;
}

/// <summary>Ligne <c>member</c> de la synchronisation : une affectation (nom et rôle, jamais de téléphone, H-17).</summary>
/// <param name="Id">Identifiant de l'affectation (celui des pierres tombales <c>member</c>).</param>
public sealed record SyncMemberData(Guid Id, Guid SiteId, Guid UserId, string FullName, string Role, DateTimeOffset AssignedAt);

/// <summary>Ligne créée ou modifiée depuis le curseur.</summary>
/// <param name="Entity"><c>site</c>, <c>zone</c> ou <c>member</c> ; un client ignore une entité qu'il ne connaît pas.</param>
/// <param name="Id">Identifiant de la ligne.</param>
/// <param name="SiteId">Chantier de la ligne (pour un chantier : son propre identifiant) ; <c>null</c> pour une entité globale (<c>product</c>, <c>supplier</c>).</param>
/// <param name="Version">Version serveur (entier décimal en chaîne) : n'appliquer la ligne que si elle est plus grande que celle déjà connue.</param>
public sealed record SyncChange(string Entity, Guid Id, Guid? SiteId, string Version, object Data);

/// <summary>Pierre tombale : le client supprime la ligne (et, pour un chantier, tous ses enfants).</summary>
/// <param name="Entity"><c>site</c>, <c>zone</c> ou <c>member</c>.</param>
/// <param name="Id">Identifiant de la ligne supprimée.</param>
/// <param name="SiteId">Chantier de la ligne ; <c>null</c> pour une entité globale.</param>
/// <param name="Version">Version serveur de la suppression.</param>
public sealed record SyncDeletion(string Entity, Guid Id, Guid? SiteId, string Version);

/// <summary>Une page de changements.</summary>
/// <param name="Changes">Lignes créées ou modifiées, par version croissante.</param>
/// <param name="Deleted">Pierres tombales.</param>
/// <param name="Cursor">Curseur à renvoyer au prochain appel (donné par le serveur, jamais l'horloge du téléphone).</param>
/// <param name="HasMore">Vrai s'il reste des changements : rappeler tout de suite avec ce curseur.</param>
/// <param name="ResetRequired">
/// Absent (faux) sauf signal additif (R3-05) : des demandes ou livraisons ont change depuis ce curseur mais sont sorties de la fenetre de synchronisation
/// (<c>Sync:ClosedRetentionDays</c>, 60 jours) : le telephone en garde peut-etre une version perimee (une demande close qu'il croit ouverte) et ne la recevra jamais (aucune pierre tombale).
/// Le client vide alors ses donnees de synchronisation (hors file d'envoi) et recommence a <c>since</c> vide, en ignorant ce signal jusqu'a la fin de ce pull complet
/// (un pull depuis zero le voit forcement). Les autres champs de la page restent valides : un client qui ignore le signal continue de se synchroniser.
/// </param>
public sealed record SyncPullResponse(
    IReadOnlyList<SyncChange> Changes,
    IReadOnlyList<SyncDeletion> Deleted,
    string Cursor,
    bool HasMore,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingDefault)] bool ResetRequired = false);

/// <summary>Une operation du lot envoye par le telephone. <c>BaseVersion</c> sert aux modifications (inutilisee au socle).</summary>
public sealed record SyncOperation(Guid ClientId, string Entity, string Operation, Guid? SiteId, JsonElement? Payload, string? BaseVersion);

/// <summary>
/// Résultat d'une opération, dans l'ordre d'envoi : <c>applied</c>, <c>duplicate</c> (déjà reçue, éventuellement
/// <c>merged</c> avec une ressource identique), <c>conflict</c> (avec <c>current</c>), <c>rejected</c> (avec <c>code</c>) ou <c>retry</c> (echec momentane du serveur, rien n'est ecrit : renvoyer
/// l'operation telle quelle plus tard ; un client qui ne connait pas ce statut la renvoie comme une operation sans reponse).
/// </summary>
/// <param name="ClientId">Identifiant de l'opération côté téléphone.</param>
/// <param name="Status"><c>applied</c>, <c>duplicate</c>, <c>conflict</c>, <c>rejected</c> ou <c>retry</c>.</param>
/// <param name="Resource">Ressource créée ou déjà existante (<c>applied</c>, <c>duplicate</c>).</param>
/// <param name="Current">État du serveur (<c>conflict</c>).</param>
/// <param name="Code">Code d'erreur du catalogue (<c>rejected</c>) : <c>INTROUVABLE</c>, <c>INTERDIT</c>, <c>CHANTIER_ARCHIVE</c>, <c>VALIDATION</c>, <c>ZONE_EXISTANTE</c>, <c>ENTITE_NON_SYNCHRONISABLE</c>.</param>
/// <param name="Merged">Vrai si une ressource identique, créée par un autre téléphone, a été retenue : y rattacher les saisies, sans erreur affichée.</param>
/// <param name="Errors">Détail par champ (<c>rejected</c> avec <c>VALIDATION</c>).</param>
/// <param name="ConflictFields">Champs en désaccord (<c>conflict</c> avec <c>CONFLIT_VERSION</c>) : la valeur saisie et celle du serveur diffèrent de la valeur de départ.</param>
public sealed record SyncPushResult(
    Guid ClientId,
    string Status,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] object? Resource = null,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] object? Current = null,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? Code = null,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] bool? Merged = null,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] IReadOnlyDictionary<string, string[]>? Errors = null,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] IReadOnlyList<string>? ConflictFields = null)
{
    public static SyncPushResult Applied(Guid clientId, object resource) => new(clientId, SyncStatuses.Applied, resource);

    public static SyncPushResult Duplicate(Guid clientId, object resource, bool merged = false)
        => new(clientId, SyncStatuses.Duplicate, resource, Merged: merged ? true : null);

    /// <summary>
    /// <c>conflict</c> : l'état du serveur a changé, rien n'est appliqué (ADR 0011). <paramref name="code"/> : <c>DEMANDE_VERROUILLEE</c>, <c>TRANSITION_INTERDITE</c>,
    /// <c>DEMANDE_NON_OUVERTE</c> ou <c>CONFLIT_VERSION</c> (avec <paramref name="conflictFields"/>).
    /// </summary>
    public static SyncPushResult Conflict(Guid clientId, object? current, string? code = null, IReadOnlyList<string>? conflictFields = null)
        => new(clientId, SyncStatuses.Conflict, Current: current, Code: code, ConflictFields: conflictFields is { Count: > 0 } ? conflictFields : null);

    public static SyncPushResult Rejected(Guid clientId, string code, IReadOnlyDictionary<string, string[]>? errors = null)
        => new(clientId, SyncStatuses.Rejected, Code: code, Errors: errors);

    /// <summary><c>retry</c> : le serveur n'a pas pu traiter l'operation a cet instant, rien n'est ecrit ; la renvoyer telle quelle (meme <c>clientId</c>) a la prochaine synchronisation.</summary>
    public static SyncPushResult Retry(Guid clientId, string code) => new(clientId, SyncStatuses.Retry, Code: code);
}

/// <summary>Un résultat par opération, dans l'ordre d'envoi.</summary>
public sealed record SyncPushResponse(IReadOnlyList<SyncPushResult> Results);
