namespace Chantier.Core.Abstractions;

/// <summary>Utilisateur de la requete en cours, lu dans le jeton ou le cookie (jamais dans le corps de la requete).</summary>
public interface ICurrentUser
{
    /// <summary><c>null</c> hors requete (seeders, taches) ou sans authentification.</summary>
    Guid? Id { get; }

    string? Role { get; }

    bool IsAuthenticated { get; }
}
