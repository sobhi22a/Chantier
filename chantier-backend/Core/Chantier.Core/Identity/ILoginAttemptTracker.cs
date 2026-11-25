namespace Chantier.Core.Identity;

/// <summary>
/// Compte les echecs de connexion <b>par identifiant normalise, existant ou non</b> (ADR 0005) : le verrouillage d'Identity
/// ne protege que les comptes existants et en revele l'existence. 5 echecs en 15 minutes (parametrable) bloquent
/// l'identifiant, meme avec le bon mot de passe. Memoire, instance unique : le compteur est perdu au redemarrage (accepte).
/// </summary>
public interface ILoginAttemptTracker
{
    /// <summary>Delai restant avant la fin du blocage, ou <c>null</c> si l'identifiant n'est pas bloque.</summary>
    TimeSpan? GetRetryAfter(string identifier);

    void RegisterFailure(string identifier);

    /// <summary>Remet le compteur a zero apres une connexion reussie.</summary>
    void Reset(string identifier);
}
