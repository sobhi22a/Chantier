namespace Chantier.Core.Entities.Sync;

/// <summary>
/// Journal des operations de synchronisation <c>update</c> et <c>transition</c> (ADR 0011) : un renvoi du meme <c>clientId</c> rend le meme resultat sans
/// rien rejouer. Ecrit <b>dans la transaction de l'operation</b>. Technique : ni <c>BasicEntity</c>, ni synchronise, ni lu par un client.
/// Ne contient jamais le contenu de l'operation (ni prix, ni telephone) : seulement son issue.
/// </summary>
public class SyncOperationLog
{
    public const string OutcomeApplied = "applied";
    public const string OutcomeConflict = "conflict";
    public const string OutcomeRejected = "rejected";

    // EF Core
    private SyncOperationLog()
    {
    }

    /// <summary>Identifiant de l'operation genere par le telephone : cle du journal.</summary>
    public Guid ClientId { get; private set; }

    public Guid UserId { get; private set; }

    public Guid? SiteId { get; private set; }

    public string Entity { get; private set; } = string.Empty;

    public string Operation { get; private set; } = string.Empty;

    public string Outcome { get; private set; } = string.Empty;

    public string? Code { get; private set; }

    /// <summary>Ressource visee (la demande, la livraison) : sert a rendre l'etat courant lors d'un renvoi.</summary>
    public Guid? ResourceId { get; private set; }

    /// <summary>Champs en desaccord d'un <c>conflict</c> (noms separes par des virgules), pour rendre le meme resultat a un renvoi.</summary>
    public string? ConflictFields { get; private set; }

    public DateTimeOffset CreatedAt { get; private set; }

    public static SyncOperationLog Create(
        Guid clientId,
        Guid userId,
        Guid? siteId,
        string entity,
        string operation,
        string outcome,
        string? code,
        Guid? resourceId,
        IReadOnlyList<string>? conflictFields,
        DateTimeOffset createdAt)
        => new()
        {
            ClientId = clientId,
            UserId = userId,
            SiteId = siteId,
            Entity = entity,
            Operation = operation,
            Outcome = outcome,
            Code = code,
            ResourceId = resourceId,
            ConflictFields = conflictFields is { Count: > 0 } ? string.Join(',', conflictFields) : null,
            CreatedAt = createdAt,
        };
}
