namespace Chantier.Core.Abstractions;

/// <summary>
/// Stockage des fichiers photo (ADR 0004, 0013) : un fichier est d'abord ecrit dans un espace temporaire, puis <b>valide</b> (deplace) sous une cle aleatoire.
/// Jamais dans un dossier servi par le web. La cle est interne : elle n'est jamais exposee par l'API.
/// </summary>
public interface IPhotoStorage
{
    /// <summary>Ouvre un fichier temporaire a ecrire ; le liberer sans le valider le supprime.</summary>
    Task<IStagedPhoto> StageAsync(CancellationToken cancellationToken = default);

    /// <summary>Deplace le fichier temporaire sous une cle aleatoire <c>&lt;chantier&gt;/&lt;annee&gt;/&lt;mois&gt;/&lt;guid&gt;.jpg</c> et la renvoie.</summary>
    Task<string> CommitAsync(IStagedPhoto staged, Guid siteId, DateTimeOffset at, CancellationToken cancellationToken = default);

    /// <summary>Ouvre un fichier stocke en lecture ; <c>null</c> s'il n'existe plus. Une cle qui sortirait de la racine est refusee.</summary>
    Stream? OpenRead(string storageKey);

    /// <summary>Supprime un fichier stocke (nettoyage apres un echec) ; sans effet s'il n'existe pas.</summary>
    Task DeleteAsync(string storageKey, CancellationToken cancellationToken = default);

    /// <summary>Le fichier de cette cle existe-t-il ? (controle de coherence base / disque).</summary>
    bool Exists(string storageKey);

    /// <summary>Cles de tous les fichiers stockes (hors zone temporaire), pour le controle de coherence base / disque.</summary>
    IEnumerable<string> EnumerateKeys();

    /// <summary>Supprime les fichiers temporaires (<c>.part</c>) plus vieux que <paramref name="olderThan"/> (envoi interrompu par un arret brutal) ; renvoie leur nombre.</summary>
    int DeleteStaleStagingFiles(TimeSpan olderThan);
}

/// <summary>Fichier temporaire en cours d'ecriture ; le liberer sans l'avoir valide le supprime.</summary>
public interface IStagedPhoto : IAsyncDisposable
{
    Stream Stream { get; }
}
