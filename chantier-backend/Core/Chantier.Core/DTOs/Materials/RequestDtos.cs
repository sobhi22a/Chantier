using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;

namespace Chantier.Core.DTOs.Materials;

/// <summary>Creation d'une demande (REST ou synchronisation) : <c>clientId</c> rend l'envoi idempotent.</summary>
public sealed record CreateRequestDto(Guid? ClientId, DateTimeOffset? ClientCreatedAt, RequestFields Fields);

/// <summary>Modification avec la version lue (REST) : une version perimee donne 409 <c>CONFLIT_VERSION</c>.</summary>
public sealed record UpdateRequestDto(string Version, RequestChanges Changes);

/// <summary>Quantite saisie : valeur et unite nullables pour que l'absence de l'une soit un code metier (<c>UNITE_OBLIGATOIRE</c>) et non une erreur de liaison.</summary>
public sealed record QuantityInput(decimal? Value, MeasureUnit? Unit);

/// <summary>
/// Champs a modifier : seuls ceux qui sont presents changent. Choisir <c>ProductId</c> ecarte le nom libre et inversement.
/// <c>ClearZone</c> retire la zone (seule la synchronisation sait distinguer « absent » de « null »).
/// </summary>
public sealed record RequestChanges(
    Guid? ProductId,
    string? FreeProductName,
    QuantityInput? Quantity,
    Guid? ZoneId,
    bool ClearZone,
    DateOnly? NeededBy,
    Priority? Priority,
    string? Note)
{
    /// <summary>Etat courant recouvert par les champs presents : la saisie complete que valide <see cref="RequestRules"/>.</summary>
    public RequestFields ApplyTo(RequestFields current) => new(
        ProductId ?? (FreeProductName is not null ? null : current.ProductId),
        FreeProductName ?? (ProductId is not null ? null : current.FreeProductName),
        Quantity is null ? current.QuantityValue : Quantity.Value,
        Quantity is null ? current.Unit : Quantity.Unit,
        ClearZone ? null : ZoneId ?? current.ZoneId,
        NeededBy ?? current.NeededBy,
        Priority ?? current.Priority,
        Note ?? current.Note);
}

/// <summary>D'ou vient l'action : l'historique garde « API » ou « Sync » et, pour une saisie hors ligne, le « saisi le » du telephone.</summary>
public sealed record RequestActionContext(MaterialEventSource Source = MaterialEventSource.Api, DateTimeOffset? DeviceAt = null)
{
    public static readonly RequestActionContext Api = new();
}

/// <summary>Filtres de la liste des demandes (par chantier ou transversale).</summary>
/// <param name="SiteId">Chantier demande ; <c>null</c> = tous les chantiers visibles (liste transversale).</param>
/// <param name="View">Vue du suivi (<c>toFollow</c> par defaut).</param>
/// <param name="Mine">Seulement mes demandes.</param>
public sealed record RequestListQuery(
    Guid? SiteId,
    string? View,
    bool Mine,
    RequestStatus? Status,
    Priority? Priority,
    Guid? ZoneId,
    Guid? ProductId,
    DateOnly? From,
    DateOnly? To,
    string? Search,
    string? Sort,
    int Page,
    int PageSize,
    Guid? SupplierId = null);
