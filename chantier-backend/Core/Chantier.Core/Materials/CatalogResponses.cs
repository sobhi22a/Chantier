using System.Text.Json.Serialization;
using Chantier.Core.Entities.Materials;

namespace Chantier.Core.Materials;

/// <summary>Produit du catalogue tel que renvoye par l'API et par la synchronisation (meme JSON, globale : sans chantier).</summary>
/// <param name="NameFr">Nom en français.</param>
/// <param name="NameAr">Nom en arabe, s'il existe (sinon le nom français est affiché).</param>
/// <param name="Category">Catégorie du catalogue.</param>
/// <param name="AllowedUnits">Unités autorisées (codes du référentiel : <c>sac</c>, <c>t</c>, <c>kg</c>...), jamais du texte libre.</param>
/// <param name="DefaultUnit">Unité proposée par défaut ; fait partie de <c>allowedUnits</c>.</param>
/// <param name="BagMassKg">Masse d'un sac en kg (50 pour le ciment) ; obligatoire si l'unité <c>sac</c> est autorisée. Sert aux conversions sac, kg, T.</param>
/// <param name="IsActive">Un produit désactivé reste affiché dans l'historique mais ne peut plus être demandé ni livré.</param>
/// <param name="Version">Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification.</param>
public sealed record ProductResponse(
    Guid Id,
    string NameFr,
    string? NameAr,
    ProductCategory Category,
    IReadOnlyList<MeasureUnit> AllowedUnits,
    MeasureUnit DefaultUnit,
    decimal? BagMassKg,
    bool IsActive,
    DateTimeOffset? DeactivatedAt,
    string Version,
    DateTimeOffset CreatedAt,
    string? CreatedByName,
    DateTimeOffset? UpdatedAt,
    string? UpdatedByName)
{
    public static ProductResponse From(Product product, IReadOnlyDictionary<Guid, string> names) => new(
        product.Id, product.NameFr, product.NameAr, product.Category, product.AllowedUnits, product.DefaultUnit,
        product.BagMassKg is { } mass ? DecimalScale.Normalize(mass) : null,
        product.IsActive, product.DeactivatedAt, product.Version, product.CreatedAt, NameOf(names, product.CreatedBy),
        product.UpdatedAt, NameOf(names, product.UpdatedBy));

    public static IEnumerable<Guid> AuditUsers(Product product) => new[] { product.CreatedBy, product.UpdatedBy }.OfType<Guid>();

    private static string? NameOf(IReadOnlyDictionary<Guid, string> names, Guid? id)
        => id is { } key && names.TryGetValue(key, out var name) ? name : null;
}

/// <summary>
/// Fournisseur. <c>phone</c> est <b>absent</b> (clé non écrite) sans la permission <c>SupplierPhone.View</c> et n'existe jamais dans les données de
/// synchronisation ni dans un journal (ADR 0012).
/// </summary>
/// <param name="Phone">Téléphone au format algérien (<c>0550 00 00 21</c>) ; donnée sensible.</param>
/// <param name="ProductIds">Produits fournis (liste indicative).</param>
public sealed record SupplierResponse(
    Guid Id,
    string Name,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? Phone,
    IReadOnlyList<Guid> ProductIds,
    bool IsActive,
    DateTimeOffset? DeactivatedAt,
    string Version,
    DateTimeOffset CreatedAt,
    string? CreatedByName,
    DateTimeOffset? UpdatedAt,
    string? UpdatedByName)
{
    public static SupplierResponse From(Supplier supplier, bool includePhone, IReadOnlyDictionary<Guid, string> names) => new(
        supplier.Id, supplier.Name, includePhone ? supplier.Phone : null, supplier.ProductIds, supplier.IsActive, supplier.DeactivatedAt,
        supplier.Version, supplier.CreatedAt, NameOf(names, supplier.CreatedBy), supplier.UpdatedAt, NameOf(names, supplier.UpdatedBy));

    public static IEnumerable<Guid> AuditUsers(Supplier supplier) => new[] { supplier.CreatedBy, supplier.UpdatedBy }.OfType<Guid>();

    private static string? NameOf(IReadOnlyDictionary<Guid, string> names, Guid? id)
        => id is { } key && names.TryGetValue(key, out var name) ? name : null;
}

/// <summary>
/// Ligne <c>supplier</c> de la synchronisation : le fournisseur <b>sans téléphone</b>. Le champ n'existe pas dans ce type : un téléphone ne peut pas
/// atteindre un téléphone mobile par la synchronisation, quel que soit le rôle (ADR 0012).
/// </summary>
public sealed record SupplierSyncData(
    Guid Id,
    string Name,
    IReadOnlyList<Guid> ProductIds,
    bool IsActive,
    DateTimeOffset? DeactivatedAt,
    string Version,
    DateTimeOffset CreatedAt,
    string? CreatedByName,
    DateTimeOffset? UpdatedAt,
    string? UpdatedByName)
{
    public static SupplierSyncData From(Supplier supplier, IReadOnlyDictionary<Guid, string> names) => new(
        supplier.Id, supplier.Name, supplier.ProductIds, supplier.IsActive, supplier.DeactivatedAt, supplier.Version, supplier.CreatedAt,
        names.TryGetValue(supplier.CreatedBy, out var created) ? created : null,
        supplier.UpdatedAt,
        supplier.UpdatedBy is { } updatedBy && names.TryGetValue(updatedBy, out var updated) ? updated : null);
}

/// <summary>Listes de motifs par cas (listes ouvertes : un client affiche tel quel un code qu'il ne connaît pas).</summary>
public sealed record MaterialReasonsResponse(
    IReadOnlyList<string> Rejection,
    IReadOnlyList<string> RequestCancellation,
    IReadOnlyList<string> OrderCancellation,
    IReadOnlyList<string> Settle,
    IReadOnlyList<string> DeliveryCancellation,
    IReadOnlyList<string> Reserve);

/// <summary>Réglages lus par le mobile à chaque synchronisation (hors ligne : dernière copie).</summary>
/// <param name="DefaultNeededByDays">Date de besoin proposée = aujourd'hui + ce nombre de jours.</param>
/// <param name="DeliveryTolerancePercent">Tolérance de « livraison complète » en pourcentage de la quantité commandée.</param>
/// <param name="MaxPhotosPerDelivery">Nombre maximal de photos de bon de livraison par livraison.</param>
/// <param name="MaxPhotoBytes">Taille maximale d'une photo, en octets.</param>
/// <param name="NoteMaxLength">Longueur maximale d'une remarque.</param>
public sealed record MaterialSettingsResponse(
    int DefaultNeededByDays,
    decimal DeliveryTolerancePercent,
    int MaxPhotosPerDelivery,
    long MaxPhotoBytes,
    int NoteMaxLength,
    MaterialReasonsResponse Reasons)
{
    public static MaterialSettingsResponse From(MaterialsOptions options, long maxPhotoBytes) => new(
        options.DefaultNeededByDays,
        DecimalScale.Normalize(options.DeliveryTolerancePercent),
        options.MaxPhotosPerDelivery,
        maxPhotoBytes,
        options.NoteMaxLength,
        new MaterialReasonsResponse(
            options.Reasons.Rejection, options.Reasons.RequestCancellation, options.Reasons.OrderCancellation,
            options.Reasons.Settle, options.Reasons.DeliveryCancellation, options.Reasons.Reserve));
}

/// <summary>Stockage et limites des photos de bon de livraison (section <c>Storage</c>, ADR 0013).</summary>
public sealed class PhotoStorageOptions
{
    public const string SectionName = "Storage";

    /// <summary>5 Mo par défaut (cible 2 Mo après réduction côté client, ADR 0013).</summary>
    public long MaxPhotoBytes { get; set; } = 5 * 1024 * 1024;

    /// <summary>Racine du stockage des fichiers : <b>hors</b> de tout dossier servi par le web ; volume dédié et sauvegardé en production.</summary>
    /// <remarks>En production, un <b>chemin absolu hors du dossier de l'application</b> est obligatoire (le demarrage est refuse sinon, R2-10).</remarks>
    public string PhotosRoot { get; set; } = "./Storage/Photos";

    /// <summary>Delai avant la premiere passe de maintenance apres le demarrage (minutes) : evite de charger le demarrage.</summary>
    public int MaintenanceInitialDelayMinutes { get; set; } = 5;

    /// <summary>Intervalle entre deux passes de maintenance (minutes) ; <c>0</c> = maintenance desactivee.</summary>
    public int MaintenanceIntervalMinutes { get; set; } = 60;

    /// <summary>Age (minutes) au-dela duquel un fichier temporaire <c>.part</c> est considere comme abandonne.</summary>
    public int StagingMaxAgeMinutes { get; set; } = 60;
}
