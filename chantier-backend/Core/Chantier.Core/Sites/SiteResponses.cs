using System.Text.Json.Serialization;
using Chantier.Core.Entities.Sites;

namespace Chantier.Core.Sites;

/// <summary>
/// Chantier tel que renvoyé par l'API et par la synchronisation (même JSON). Le montant du marché (<c>contractAmount</c>) est
/// <b>absent</b> de la réponse (et non masqué) sans la permission <c>ContractAmount.View</c> (CT-20, CA-003.5).
/// </summary>
/// <param name="Code">Code unique et immuable, par exemple <c>CH-ECO-UV18</c>.</param>
/// <param name="NameAr">Nom en arabe, s'il existe.</param>
/// <param name="ContractAmount">Montant du marché en DZD (2 décimales) ; absent sans la permission <c>ContractAmount.View</c>.</param>
/// <param name="DelayDays">Délai contractuel en jours calendaires.</param>
/// <param name="OdsDate">Date de l'ordre de service de démarrage.</param>
/// <param name="ContractualEndDate">Fin contractuelle = date de l'ODS + délai, calculée par le serveur ; <c>null</c> si l'un des deux manque (« À définir »).</param>
/// <param name="ArchivedAt">Date d'archivage ; un chantier archivé est en lecture seule.</param>
/// <param name="ArchivedByName">Nom de la personne qui a archivé.</param>
/// <param name="Version">Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification.</param>
/// <param name="CreatedAt">Création (heure du serveur, UTC).</param>
/// <param name="CreatedByName">Nom du créateur.</param>
/// <param name="UpdatedAt">Dernière modification (heure du serveur, UTC).</param>
/// <param name="UpdatedByName">Nom de la dernière personne ayant modifié.</param>
public sealed record SiteResponse(
    Guid Id,
    string Code,
    string Name,
    string? NameAr,
    SiteType Type,
    string Wilaya,
    string Commune,
    decimal? Latitude,
    decimal? Longitude,
    string Owner,
    string? ContractNumber,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] decimal? ContractAmount,
    int? DelayDays,
    DateOnly? OdsDate,
    DateOnly? ContractualEndDate,
    DateTimeOffset? ArchivedAt,
    string? ArchivedByName,
    string Version,
    DateTimeOffset CreatedAt,
    string? CreatedByName,
    DateTimeOffset? UpdatedAt,
    string? UpdatedByName)
{
    public static SiteResponse From(Site site, bool includeContractAmount, IReadOnlyDictionary<Guid, string> names) => new(
        site.Id, site.Code, site.Name, site.NameAr, site.Type, site.Wilaya, site.Commune, site.Latitude, site.Longitude,
        site.Owner, site.ContractNumber, includeContractAmount ? site.ContractAmount : null, site.DelayDays, site.OdsDate,
        site.ContractualEndDate, site.ArchivedAt, NameOf(names, site.ArchivedBy), site.Version, site.CreatedAt,
        NameOf(names, site.CreatedBy), site.UpdatedAt, NameOf(names, site.UpdatedBy));

    public static IEnumerable<Guid> AuditUsers(Site site) => new[] { site.CreatedBy, site.UpdatedBy, site.ArchivedBy }.OfType<Guid>();

    private static string? NameOf(IReadOnlyDictionary<Guid, string> names, Guid? id)
        => id is { } key && names.TryGetValue(key, out var name) ? name : null;
}

/// <summary>Zone d'un chantier : bloc, cote (en mètres) et local. Identique à la ligne <c>zone</c> de la synchronisation.</summary>
/// <param name="ClientId">Identifiant généré par le téléphone qui a créé la zone (création hors ligne), sinon <c>null</c>.</param>
/// <param name="ClientCreatedAt">« Saisi le » du téléphone : information seulement, jamais utilisée pour trier ou décider.</param>
/// <param name="Block">Bloc, par exemple <c>Bloc 01</c>.</param>
/// <param name="Elevation">Cote en mètres, 2 décimales (affichage signé côté client : −1,90 ; ±0,00 ; +3,40).</param>
/// <param name="RoomType">Type de local.</param>
/// <param name="RoomNumber">Numéro du local (classe 02).</param>
/// <param name="RoomLabel">Libellé libre, seulement si le type est <c>Other</c>.</param>
/// <param name="ArchivedAt">Date d'archivage ; une zone archivée n'est plus proposée à la saisie.</param>
/// <param name="ArchivedByName">Nom de la personne qui a archivé.</param>
/// <param name="Version">Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification.</param>
/// <param name="CreatedAt">Création (heure du serveur, UTC).</param>
/// <param name="CreatedByName">Nom du créateur.</param>
/// <param name="UpdatedAt">Dernière modification (heure du serveur, UTC).</param>
/// <param name="UpdatedByName">Nom de la dernière personne ayant modifié.</param>
public sealed record ZoneResponse(
    Guid Id,
    Guid SiteId,
    Guid? ClientId,
    DateTimeOffset? ClientCreatedAt,
    string Block,
    decimal? Elevation,
    RoomType? RoomType,
    int? RoomNumber,
    string? RoomLabel,
    DateTimeOffset? ArchivedAt,
    string? ArchivedByName,
    string Version,
    DateTimeOffset CreatedAt,
    string? CreatedByName,
    DateTimeOffset? UpdatedAt,
    string? UpdatedByName)
{
    public static ZoneResponse From(Zone zone, IReadOnlyDictionary<Guid, string> names) => new(
        zone.Id, zone.SiteId, zone.ClientId, zone.ClientCreatedAt, zone.Block, zone.Elevation, zone.RoomType, zone.RoomNumber,
        zone.RoomLabel, zone.ArchivedAt, NameOf(names, zone.ArchivedBy), zone.Version, zone.CreatedAt, NameOf(names, zone.CreatedBy),
        zone.UpdatedAt, NameOf(names, zone.UpdatedBy));

    public static IEnumerable<Guid> AuditUsers(Zone zone) => new[] { zone.CreatedBy, zone.UpdatedBy, zone.ArchivedBy }.OfType<Guid>();

    private static string? NameOf(IReadOnlyDictionary<Guid, string> names, Guid? id)
        => id is { } key && names.TryGetValue(key, out var name) ? name : null;
}

/// <summary>Personne affectée au chantier : nom et rôle, jamais de téléphone ni d'identifiant de connexion (H-17).</summary>
/// <param name="AssignedAt">Date d'affectation (heure du serveur, UTC).</param>
public sealed record SiteMemberResponse(Guid UserId, string FullName, string Role, DateTimeOffset AssignedAt);

/// <summary>Resultat d'une affectation : <c>Created = false</c> si la personne etait deja affectee (« Deja affecte »).</summary>
public sealed record AssignmentResult(SiteMemberResponse Member, bool Created);

/// <summary>Resultat d'une creation idempotente : <c>Created = false</c> si le meme <c>clientId</c> avait deja ete recu.</summary>
public sealed record ZoneCreationResult(ZoneResponse Zone, bool Created);

public sealed record WilayaResponse(string Code, string NameFr, string NameAr);

public sealed record CommuneResponse(string NameFr, string NameAr);

public sealed record SiteCodeSuggestion(string Code);
