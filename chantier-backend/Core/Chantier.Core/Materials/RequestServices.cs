using Chantier.Core.DTOs.Materials;
using Chantier.Core.Paging;

namespace Chantier.Core.Materials;

/// <summary>
/// Demandes de materiaux. <b>Toutes les regles vivent ici</b> (droits, verrouillage, transitions, doublons, historique) : l'API REST et la
/// synchronisation hors ligne appellent ce service, aucune regle n'est dupliquee. Le chantier est toujours fourni par l'appelant apres son controle
/// d'affectation (<c>[SiteScoped]</c> ou <c>ISiteAccess</c>) ; une demande est toujours lue par (chantier, identifiant) : un autre chantier donne 404.
/// </summary>
public interface IRequestService
{
    /// <summary>Liste par chantier ou transversale (<c>query.SiteId</c> nul : tous les chantiers visibles de l'utilisateur).</summary>
    Task<PagedResult<MaterialRequestResponse>> ListAsync(RequestListQuery query, CancellationToken cancellationToken = default);

    Task<MaterialRequestDetailResponse> GetAsync(Guid siteId, Guid requestId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Creation idempotente par (chantier, <c>clientId</c>) : un renvoi rend la meme demande et le meme numero. Le numero <c>DEM-nnn</c> est attribue
    /// dans la transaction, <b>apres</b> le controle du <c>clientId</c>.
    /// </summary>
    Task<RequestCreationResult> CreateAsync(Guid siteId, CreateRequestDto dto, RequestActionContext? context = null, CancellationToken cancellationToken = default);

    /// <summary>Modification avec la version lue : 409 <c>CONFLIT_VERSION</c> (avec l'etat courant) si elle est perimee.</summary>
    Task<MaterialRequestDetailResponse> UpdateAsync(Guid siteId, Guid requestId, UpdateRequestDto dto, CancellationToken cancellationToken = default);

    /// <summary>
    /// Modification sans controle de version, pour la synchronisation : memes droits, memes verrous et memes validations que <see cref="UpdateAsync"/>.
    /// <paramref name="baseValues"/> = valeurs de depart du telephone : chaque champ modifie est compare a trois valeurs (depart, actuelle, proposee) ; un champ change
    /// ailleurs vers une autre valeur leve <c>ConflictException</c> (<c>CONFLIT_VERSION</c>, avec les champs) et rien n'est applique (ADR 0011).
    /// <c>Applied = false</c> si rien ne change.
    /// </summary>
    Task<RequestActionResult> ApplyChangesAsync(Guid siteId, Guid requestId, RequestChanges changes, RequestChanges? baseValues, RequestActionContext context, CancellationToken cancellationToken = default);

    Task<RequestActionResult> ApproveAsync(Guid siteId, Guid requestId, QuantityInput? quantity, RequestActionContext? context = null, CancellationToken cancellationToken = default);

    Task<RequestActionResult> RejectAsync(Guid siteId, Guid requestId, string? reasonCode, string? reasonNote, RequestActionContext? context = null, CancellationToken cancellationToken = default);

    Task<RequestActionResult> CancelAsync(Guid siteId, Guid requestId, string? reasonCode, string? reasonNote, RequestActionContext? context = null, CancellationToken cancellationToken = default);

    Task<RequestActionResult> ReceiveAsync(Guid siteId, Guid requestId, string? note, RequestActionContext? context = null, CancellationToken cancellationToken = default);

    Task<RequestActionResult> SettleAsync(Guid siteId, Guid requestId, string? reasonCode, string? reasonNote, CancellationToken cancellationToken = default);

    Task<RequestActionResult> LinkProductAsync(Guid siteId, Guid requestId, Guid productId, CancellationToken cancellationToken = default);

    Task<RequestActionResult> ArchiveAsync(Guid siteId, Guid requestId, CancellationToken cancellationToken = default);

    Task<RequestActionResult> RestoreAsync(Guid siteId, Guid requestId, CancellationToken cancellationToken = default);

    /// <summary>Valide au plus <see cref="RequestBatchLimits.Approve"/> demandes ; chacune dans sa propre transaction, un resultat par demande.</summary>
    Task<BatchResponse> ApproveBatchAsync(Guid siteId, IReadOnlyList<Guid> requestIds, CancellationToken cancellationToken = default);

    Task<BatchResponse> ArchiveBatchAsync(Guid siteId, IReadOnlyList<Guid> requestIds, CancellationToken cancellationToken = default);
}

public static class RequestBatchLimits
{
    public const int Approve = 50;
    public const int Archive = 100;
}

/// <summary>Vues du suivi (<c>view</c>), definies par le serveur ; les demandes archivees sont exclues sauf pour <c>archived</c>.</summary>
public static class RequestViews
{
    public const string ToFollow = "toFollow";
    public const string ToApprove = "toApprove";
    public const string ToOrder = "toOrder";
    public const string Expected = "expected";
    public const string Late = "late";
    public const string ToReceive = "toReceive";
    public const string Received = "received";
    public const string Closed = "closed";
    public const string Archived = "archived";

    public static readonly IReadOnlyList<string> Available = [ToFollow, ToApprove, ToOrder, Expected, Late, ToReceive, Received, Closed, Archived];

    public static readonly string[] SortValues = ["default", "neededBy", "-neededBy", "number", "-number", "createdAt", "-createdAt", "priority"];
}
