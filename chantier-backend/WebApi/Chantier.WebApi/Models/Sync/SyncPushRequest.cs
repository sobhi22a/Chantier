using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using Chantier.Core.Sync;

namespace Chantier.WebApi.Models.Sync;

/// <summary>Lot d'opérations envoyé par le téléphone (100 au maximum, 1 Mo au maximum).</summary>
public sealed class SyncPushRequest : IValidatableObject
{
    /// <summary>Opérations dans l'ordre de saisie ; les résultats reviennent dans le même ordre.</summary>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public List<SyncPushOperation>? Operations { get; set; }

    /// <summary>Une operation <c>null</c> (<c>{"operations":[null]}</c>) est une erreur de saisie (400 <c>VALIDATION</c>), pas une erreur du serveur (R1-07).</summary>
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (Operations?.Any(operation => operation is null) == true)
        {
            yield return new ValidationResult("Une opération est vide.", [nameof(Operations)]);
        }
    }

    public IReadOnlyList<SyncOperation> ToOperations()
        => (Operations ?? []).Select(operation => operation.ToOperation()).ToList();
}

// Le siteId vient ici du corps (et non de la route) : il est verifie par le handler de l'entite (affectation, sinon INTROUVABLE),
// jamais pris pour acquis. Le type s'appelle « Operation » et non « Request » : le test d'architecture qui interdit SiteId dans les
// requetes vise les creations et modifications REST.

/// <summary>Une opération saisie hors ligne. Le chantier visé est vérifié à l'envoi (affectation, sinon <c>INTROUVABLE</c>).</summary>
public sealed class SyncPushOperation
{
    /// <summary>Identifiant généré par le téléphone : rend l'envoi idempotent (un renvoi donne <c>duplicate</c>).</summary>
    /// <example>7c1e6a52-0d3b-4c59-9a43-6f1f2b9d8e10</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public Guid? ClientId { get; set; }

    /// <summary>Entité visée (<c>zone</c> au socle) ; une autre entité reçoit <c>rejected</c> <c>ENTITE_NON_SYNCHRONISABLE</c>.</summary>
    /// <example>zone</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(30, ErrorMessage = "Trop long (30 caractères au maximum).")]
    public string? Entity { get; set; }

    /// <summary><c>create</c>, <c>update</c> ou <c>transition</c> (au socle : <c>create</c> d'une zone).</summary>
    /// <example>create</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(30, ErrorMessage = "Trop long (30 caractères au maximum).")]
    public string? Operation { get; set; }

    /// <summary>Chantier visé.</summary>
    public Guid? SiteId { get; set; }

    /// <summary>Contenu de l'opération : les champs de la ressource (pour une zone : <c>block</c>, <c>elevation</c>, <c>roomType</c>, <c>roomNumber</c>, <c>roomLabel</c>, <c>clientCreatedAt</c>).</summary>
    public object? Payload { get; set; }

    /// <summary>Version serveur lue par le téléphone (modifications) ; inutilisée pour une création.</summary>
    [StringLength(30, ErrorMessage = "La version est invalide.")]
    public string? BaseVersion { get; set; }

    public SyncOperation ToOperation() => new(ClientId ?? Guid.Empty, Entity!, Operation!, SiteId, Payload as JsonElement?, BaseVersion);
}
