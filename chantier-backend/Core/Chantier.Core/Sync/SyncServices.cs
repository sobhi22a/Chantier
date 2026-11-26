namespace Chantier.Core.Sync;

/// <summary>Ce qu'une source de synchronisation a le droit de lire pour l'utilisateur de la requete.</summary>
/// <param name="UserId">Utilisateur connecte.</param>
/// <param name="VisibleSiteIds">Chantiers visibles ; <c>null</c> = tous (permission <c>AllSites.View</c>, sans filtre de chantier demande).</param>
/// <param name="SiteFilter">Chantier demande par <c>siteId</c> ; <c>null</c> = tous les chantiers visibles.</param>
/// <param name="Permissions">Permissions de l'utilisateur : le montant du marche est absent de <c>data</c> sans <c>ContractAmount.View</c>.</param>
public sealed record SyncScope(Guid UserId, IReadOnlyList<Guid>? VisibleSiteIds, Guid? SiteFilter, IReadOnlySet<string> Permissions);

/// <summary>
/// Une entite synchronisee en lecture. Ajouter une entite = une source de plus (et son inscription dans <see cref="ISyncTouch"/>).
/// Une ligne ne produit <b>qu'une</b> ligne de reponse : la version sert de curseur et ne doit pas etre dupliquee.
/// Une source <b>globale</b> (produits, fournisseurs : <c>SyncChangeRow.SiteId</c> nul) ignore le filtre de chantier de <see cref="SyncScope"/> :
/// tous les utilisateurs authentifies recoivent ses lignes, meme sans chantier affecte.
/// </summary>
public interface ISyncSource
{
    /// <summary>Lignes de version strictement comprise entre <paramref name="since"/> et <paramref name="upper"/>, par version croissante, au plus <paramref name="take"/>.</summary>
    Task<IReadOnlyList<SyncChangeRow>> ReadAsync(SyncScope scope, ulong since, ulong upper, int take, CancellationToken cancellationToken = default);
}

/// <summary>Horloge de synchronisation : la borne haute sure du curseur (ADR 0003, ADR 0009). Specifique au moteur de base.</summary>
public interface ISyncClock
{
    /// <summary>
    /// Plus petite version encore portee par une transaction ouverte (<c>MIN_ACTIVE_ROWVERSION()</c>) :
    /// toute ligne de version strictement inferieure est definitivement visible ou n'existera jamais.
    /// </summary>
    Task<ulong> SafeUpperBoundAsync(CancellationToken cancellationToken = default);
}

/// <summary>
/// « Toucher » : fait avancer la version des lignes d'un chantier sans rien modifier, pour qu'un utilisateur nouvellement
/// affecte recoive aussi les lignes anciennes (ADR 0009). A appeler dans la transaction de l'affectation, dans cet ordre :
/// <see cref="LockSiteAsync"/> (avant d'ecrire l'affectation), puis <see cref="TouchLinesAsync"/> (apres).
/// </summary>
public interface ISyncTouch
{
    /// <summary>
    /// Met en file les affectations simultanees d'un meme chantier (verrou applicatif) puis « touche » la ligne du chantier, ce qui prend son
    /// verrou d'ecriture jusqu'a la fin de la transaction. <b>Le chantier est verrouille en premier</b> : c'est l'ordre dans lequel toutes les lectures
    /// (controle d'affectation) et ecritures (creation de zone, cle etrangere) le prennent aussi ; l'inverse provoque des interblocages (mesure sur vraie base).
    /// </summary>
    Task LockSiteAsync(Guid siteId, CancellationToken cancellationToken = default);

    /// <summary>
    /// « Touche » les lignes du chantier (zones, affectations). Les zones <b>en cours d'ecriture par une autre transaction sont ignorees</b> : leur version
    /// sera de toute facon posterieure au curseur de tout lecteur (nouvelle ligne ou modification), elles ne sont donc jamais perdues, et attendre leur verrou
    /// provoquerait un interblocage avec leur controle de cle etrangere sur le chantier.
    /// </summary>
    Task TouchLinesAsync(Guid siteId, CancellationToken cancellationToken = default);
}

/// <summary>Un handler d'ecriture par entite (<c>zone</c>...) ; les refus sont des exceptions du domaine, converties en <c>rejected</c> par le service.</summary>
public interface ISyncPushHandler
{
    string Entity { get; }

    Task<SyncPushResult> HandleAsync(SyncOperation operation, CancellationToken cancellationToken = default);
}

public interface ISyncPullService
{
    /// <summary><paramref name="since"/> : curseur recu du serveur (chaine opaque), absent ou <c>0</c> = premiere synchronisation.</summary>
    Task<SyncPullResponse> PullAsync(string? since, Guid? siteId, int limit, CancellationToken cancellationToken = default);
}

public interface ISyncPushService
{
    /// <summary>Applique le lot dans l'ordre ; chaque operation a sa propre transaction et son propre resultat.</summary>
    Task<SyncPushResponse> PushAsync(IReadOnlyList<SyncOperation> operations, CancellationToken cancellationToken = default);
}
