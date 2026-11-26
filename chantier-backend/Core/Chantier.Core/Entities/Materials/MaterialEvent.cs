using Chantier.Core.Entities.Common;
using Chantier.Core.Materials;

namespace Chantier.Core.Entities.Materials;

/// <summary>
/// Evenement de l'historique d'une demande ou d'une livraison : <b>immuable</b>, ecrit dans la transaction de l'action (qui, quand, ancien -&gt; nouveau statut, motif).
/// L'auteur et l'heure du serveur sont ceux de l'audit (<see cref="BasicEntity.CreatedBy"/>, <see cref="BasicEntity.CreatedAt"/>), jamais ceux du telephone.
/// Pas <see cref="ISiteScoped"/> : il est lu par son sujet, jamais seul.
/// Aucun prix dans <see cref="Changes"/> ; les modifications commerciales d'une commande ont leur propre type, filtre par type (ADR 0012).
/// </summary>
public class MaterialEvent : BasicEntity
{
    public const int ReasonNoteMaxLength = 200;

    // EF Core
    private MaterialEvent()
    {
    }

    public Guid SiteId { get; private set; }

    public MaterialSubjectType SubjectType { get; private set; }

    public Guid SubjectId { get; private set; }

    public MaterialEventType Type { get; private set; }

    public RequestStatus? FromStatus { get; private set; }

    public RequestStatus? ToStatus { get; private set; }

    public string? ReasonCode { get; private set; }

    public string? ReasonNote { get; private set; }

    public IReadOnlyList<FieldChange>? Changes { get; private set; }

    /// <summary>« Saisi le » du telephone pour un evenement issu d'une saisie hors ligne : information seulement.</summary>
    public DateTimeOffset? DeviceAt { get; private set; }

    public MaterialEventSource Source { get; private set; }

    /// <summary>Evenement reserve aux roles qui voient les prix : jamais rendu aux autres, jamais synchronise.</summary>
    public bool IsSensitive => Type == MaterialEventType.OrderCommercialEdited;

    public static MaterialEvent Create(
        Guid siteId,
        MaterialSubjectType subjectType,
        Guid subjectId,
        MaterialEventType type,
        RequestStatus? fromStatus = null,
        RequestStatus? toStatus = null,
        string? reasonCode = null,
        string? reasonNote = null,
        IReadOnlyList<FieldChange>? changes = null,
        DateTimeOffset? deviceAt = null,
        MaterialEventSource source = MaterialEventSource.Api)
        => new()
        {
            Id = MonotonicGuid.Next(),
            SiteId = siteId,
            SubjectType = subjectType,
            SubjectId = subjectId,
            Type = type,
            FromStatus = fromStatus,
            ToStatus = toStatus,
            ReasonCode = reasonCode,
            ReasonNote = reasonNote,
            Changes = changes is { Count: > 0 } ? changes : null,
            DeviceAt = deviceAt,
            Source = source,
        };
}
