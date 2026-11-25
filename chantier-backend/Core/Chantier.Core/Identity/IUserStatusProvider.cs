namespace Chantier.Core.Identity;

/// <summary>Etat d'un compte tel que le serveur doit le verifier a chaque requete.</summary>
/// <param name="SecurityStamp">Version de session de l'utilisateur : change a la deconnexion web et au changement de mot de passe, ce qui invalide les cookies emis avant (R1-02).</param>
public sealed record UserStatus(bool IsActive, bool MustChangePassword, string? SecurityStamp);

/// <summary>
/// Etat « actif » d'un compte avec un cache memoire de 60 secondes au plus : un jeton encore valide d'un compte desactive
/// est refuse (401 <c>ACCES_RETIRE</c>) au plus tard apres ce delai (CT-19). Un compte inconnu vaut « inactif » (<c>null</c>).
/// </summary>
public interface IUserStatusProvider
{
    Task<UserStatus?> GetAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>A appeler apres toute modification de l'etat d'un compte (desactivation, changement de mot de passe).</summary>
    void Invalidate(Guid userId);
}
