namespace Chantier.Core.Sync;

/// <summary>Reglages de la synchronisation (section <c>Sync</c>).</summary>
public sealed class SyncOptions
{
    public const string SectionName = "Sync";

    /// <summary>
    /// Fenetre de synchronisation (R2-02, decision de l'orchestrateur : 60 jours). Une demande close (refusee, annulee ou receptionnee, archivee ou non) dont la derniere
    /// modification date de plus de ce nombre de jours n'est plus envoyee au telephone, ni ses livraisons ni leurs photos ; une livraison annulee depuis plus longtemps non plus.
    /// <c>0</c> ou moins : pas de fenetre (tout est envoye). Une demande ouverte est toujours envoyee, quel que soit son age.
    /// </summary>
    public int ClosedRetentionDays { get; set; } = 60;

    /// <summary>
    /// Duree de conservation du journal d'operations (<c>SyncOperationLogs</c> : un renvoi retrouve son resultat). Au-dela, la ligne est purgee (R2-10) : un telephone qui
    /// renverrait une operation aussi ancienne la rejouerait comme neuve (idempotence par <c>clientId</c> des creations, controle de version des modifications).
    /// <c>0</c> ou moins : pas de purge.
    /// </summary>
    public int OperationLogRetentionDays { get; set; } = 90;
}
