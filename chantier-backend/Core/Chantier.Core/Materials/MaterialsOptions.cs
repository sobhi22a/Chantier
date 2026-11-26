using Chantier.Core.Exceptions;
using Chantier.Core.Validation;

namespace Chantier.Core.Materials;

/// <summary>
/// Reglages des demandes de materiaux (section <c>Materials</c>, H-ARCH-15) : valeurs parametrables, jamais codees en dur ailleurs.
/// Les listes de motifs vivent dans <see cref="ReasonLists"/> (valeurs par defaut en code : ne pas les surcharger par un tableau de configuration,
/// le binder ajoute aux tableaux au lieu de les remplacer).
/// </summary>
public sealed class MaterialsOptions
{
    public const string SectionName = "Materials";

    /// <summary>Date de besoin proposee = aujourd'hui + ce nombre de jours (H-MAT-05).</summary>
    public int DefaultNeededByDays { get; set; } = 3;

    /// <summary>Tolerance de « livraison complete » en pourcentage de la quantite commandee (H-MAT-10, Q-MAT-04 : 0 %).</summary>
    public decimal DeliveryTolerancePercent { get; set; }

    public int MaxPhotosPerDelivery { get; set; } = 5;

    /// <summary>
    /// Une photo dont le fichier n'est jamais arrive (refus 415/422, application tuee) occupe l'une des places de la livraison pendant ce nombre d'heures (le temps d'un envoi
    /// differe), puis la place est liberee (R2-05). Au-dela de <see cref="PendingPhotoExpiryDays"/> jours, la ligne est supprimee par la tache de nettoyage.
    /// </summary>
    public int PendingPhotoHoldHours { get; set; } = 24;

    public int PendingPhotoExpiryDays { get; set; } = 7;

    /// <summary>Longueur maximale d'une remarque ou d'une remarque de motif.</summary>
    public int NoteMaxLength { get; set; } = 200;

    public int DeliveryNoteMaxLength { get; set; } = 30;

    public int FreeNameMinLength { get; set; } = 3;

    public int FreeNameMaxLength { get; set; } = 100;

    public ReasonLists Reasons { get; set; } = new();
}

/// <summary>Cas qui exigent un motif choisi dans une liste (H-MAT-18).</summary>
public enum ReasonKind
{
    Rejection,
    RequestCancellation,
    OrderCancellation,
    Settle,
    DeliveryCancellation,
    Reserve,
}

/// <summary>Listes de motifs par cas ; « Other » impose une remarque. Listes ouvertes : un client affiche tel quel un code qu'il ne connait pas.</summary>
public sealed class ReasonLists
{
    public string[] Rejection { get; set; } = ["AlreadyOrdered", "StockSufficient", "QuantityToReview", "OverBudget", ReasonRules.Other];

    public string[] RequestCancellation { get; set; } = ["EntryError", "NoLongerNeeded", "Duplicate", ReasonRules.Other];

    public string[] OrderCancellation { get; set; } = ["SupplierUnavailable", "PriceRefused", ReasonRules.Other];

    public string[] Settle { get; set; } = ["SupplierWillNotDeliver", "QuantitySufficient", ReasonRules.Other];

    public string[] DeliveryCancellation { get; set; } = ["DoubleEntry", "QuantityError", "RefusedAtReception", ReasonRules.Other];

    public string[] Reserve { get; set; } = ["QuantityMissing", "DamagedProduct", "WrongProduct", ReasonRules.Other];

    public IReadOnlyList<string> For(ReasonKind kind) => kind switch
    {
        ReasonKind.Rejection => Rejection,
        ReasonKind.RequestCancellation => RequestCancellation,
        ReasonKind.OrderCancellation => OrderCancellation,
        ReasonKind.Settle => Settle,
        ReasonKind.DeliveryCancellation => DeliveryCancellation,
        ReasonKind.Reserve => Reserve,
        _ => throw new ArgumentOutOfRangeException(nameof(kind), kind, "Cas de motif inconnu."),
    };
}

public static class ReasonRules
{
    public const string Other = "Other";

    /// <summary>
    /// Motif choisi dans la liste du cas, remarque obligatoire pour « Other ». Leve <c>VALIDATION</c> (400) avec <c>reasonCode</c> ou <c>reasonNote</c>.
    /// Renvoie la remarque nettoyee (ou <c>null</c>).
    /// </summary>
    public static string? Validate(ReasonKind kind, string? code, string? note, MaterialsOptions options)
    {
        var errors = new ErrorCollector();
        var trimmedNote = string.IsNullOrWhiteSpace(note) ? null : note.Trim();

        if (string.IsNullOrWhiteSpace(code))
        {
            errors.Add("reasonCode", "Le motif est obligatoire.");
        }
        else if (!options.Reasons.For(kind).Contains(code, StringComparer.Ordinal))
        {
            errors.Add("reasonCode", "Ce motif n'existe pas pour cette action.");
        }
        else if (code == Other && trimmedNote is null)
        {
            errors.Add("reasonNote", "Une remarque est obligatoire pour le motif « Autre ».");
        }

        if (trimmedNote is not null && trimmedNote.Length > options.NoteMaxLength)
        {
            errors.Add("reasonNote", $"Trop long ({options.NoteMaxLength} caractères au maximum).");
        }

        errors.ThrowIfAny();
        return trimmedNote;
    }
}

/// <summary>Un champ modifie, tel qu'il apparait dans l'historique : « quantity : 300 sac -&gt; 200 sac ». Jamais un prix (ADR 0012).</summary>
public sealed record FieldChange(string Field, string? Old, string? New);
