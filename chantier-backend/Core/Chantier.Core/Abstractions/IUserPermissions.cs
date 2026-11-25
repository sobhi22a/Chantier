namespace Chantier.Core.Abstractions;

/// <summary>Permissions de l'utilisateur de la requete en cours (via son role), pour les controles fins dans les services.</summary>
public interface IUserPermissions
{
    Task<IReadOnlySet<string>> GetAsync(CancellationToken cancellationToken = default);

    Task<bool> HasAsync(string permission, CancellationToken cancellationToken = default);
}
