using System.Text.Json;
using System.Text.Json.Serialization;

namespace Chantier.Core.Sync;

/// <summary>Noms des entites synchronisees (ADR 0009). Un client ignore une entite qu'il ne connait pas.</summary>
public static class SyncEntities
{
    public const string Site = "site";
    public const string Zone = "zone";
    public const string Member = "member";
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
/// Une ligne a envoyer au client. <see cref="Data"/> est <b>le meme objet que la reponse REST</b> de l'entite ;
/// <c>null</c> = pierre tombale (la ligne a ete supprimee ou retiree pour cet utilisateur).
/// </summary>
public sealed record SyncChangeRow(string Entity, Guid Id, Guid SiteId, ulong Version, object? Data)
{
    public bool IsTombstone => Data is null;
}

/// <summary>Ligne <c>member</c> de la synchronisation : une affectation (nom et rôle, jamais de téléphone, H-17).</summary>
/// <param name="Id">Identifiant de l'affectation (celui des pierres tombales <c>member</c>).</param>
public sealed record SyncMemberData(Guid Id, Guid SiteId, Guid UserId, string FullName, string Role, DateTimeOffset AssignedAt);

/// <summary>Ligne créée ou modifiée depuis le curseur.</summary>
/// <param name="Entity"><c>site</c>, <c>zone</c> ou <c>member</c> ; un client ignore une entité qu'il ne connaît pas.</param>
/// <param name="Id">Identifiant de la ligne.</param>
/// <param name="SiteId">Chantier de la ligne (pour un chantier : son propre identifiant).</param>
/// <param name="Version">Version serveur (entier décimal en chaîne) : n'appliquer la ligne que si elle est plus grande que celle déjà connue.</param>
public sealed record SyncChange(string Entity, Guid Id, Guid SiteId, string Version, object Data);

/// <summary>Pierre tombale : le client supprime la ligne (et, pour un chantier, tous ses enfants).</summary>
/// <param name="Entity"><c>site</c>, <c>zone</c> ou <c>member</c>.</param>
/// <param name="Id">Identifiant de la ligne supprimée.</param>
/// <param name="SiteId">Chantier de la ligne.</param>
/// <param name="Version">Version serveur de la suppression.</param>
public sealed record SyncDeletion(string Entity, Guid Id, Guid SiteId, string Version);

/// <summary>Une page de changements.</summary>
/// <param name="Changes">Lignes créées ou modifiées, par version croissante.</param>
/// <param name="Deleted">Pierres tombales.</param>
/// <param name="Cursor">Curseur à renvoyer au prochain appel (donné par le serveur, jamais l'horloge du téléphone).</param>
/// <param name="HasMore">Vrai s'il reste des changements : rappeler tout de suite avec ce curseur.</param>
public sealed record SyncPullResponse(IReadOnlyList<SyncChange> Changes, IReadOnlyList<SyncDeletion> Deleted, string Cursor, bool HasMore);

/// <summary>Une operation du lot envoye par le telephone. <c>BaseVersion</c> sert aux modifications (inutilisee au socle).</summary>
public sealed record SyncOperation(Guid ClientId, string Entity, string Operation, Guid? SiteId, JsonElement? Payload, string? BaseVersion);

/// <summary>
/// Résultat d'une opération, dans l'ordre d'envoi : <c>applied</c>, <c>duplicate</c> (déjà reçue, éventuellement
/// <c>merged</c> avec une ressource identique), <c>conflict</c> (avec <c>current</c>) ou <c>rejected</c> (avec <c>code</c>).
/// </summary>
/// <param name="ClientId">Identifiant de l'opération côté téléphone.</param>
/// <param name="Status"><c>applied</c>, <c>duplicate</c>, <c>conflict</c> ou <c>rejected</c>.</param>
/// <param name="Resource">Ressource créée ou déjà existante (<c>applied</c>, <c>duplicate</c>).</param>
/// <param name="Current">État du serveur (<c>conflict</c>).</param>
/// <param name="Code">Code d'erreur du catalogue (<c>rejected</c>) : <c>INTROUVABLE</c>, <c>INTERDIT</c>, <c>CHANTIER_ARCHIVE</c>, <c>VALIDATION</c>, <c>ZONE_EXISTANTE</c>, <c>ENTITE_NON_SYNCHRONISABLE</c>.</param>
/// <param name="Merged">Vrai si une ressource identique, créée par un autre téléphone, a été retenue : y rattacher les saisies, sans erreur affichée.</param>
/// <param name="Errors">Détail par champ (<c>rejected</c> avec <c>VALIDATION</c>).</param>
public sealed record SyncPushResult(
    Guid ClientId,
    string Status,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] object? Resource = null,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] object? Current = null,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? Code = null,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] bool? Merged = null,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] IReadOnlyDictionary<string, string[]>? Errors = null)
{
    public static SyncPushResult Applied(Guid clientId, object resource) => new(clientId, SyncStatuses.Applied, resource);

    public static SyncPushResult Duplicate(Guid clientId, object resource, bool merged = false)
        => new(clientId, SyncStatuses.Duplicate, resource, Merged: merged ? true : null);

    public static SyncPushResult Conflict(Guid clientId, object? current) => new(clientId, SyncStatuses.Conflict, Current: current);

    public static SyncPushResult Rejected(Guid clientId, string code, IReadOnlyDictionary<string, string[]>? errors = null)
        => new(clientId, SyncStatuses.Rejected, Code: code, Errors: errors);
}

/// <summary>Un résultat par opération, dans l'ordre d'envoi.</summary>
public sealed record SyncPushResponse(IReadOnlyList<SyncPushResult> Results);
