namespace Chantier.Core.Identity;

/// <summary>
/// Permissions d'un role, resolues cote serveur avec un cache memoire de 5 minutes : elles ne sont pas dans le jeton
/// (ADR 0005). Une permission ajoutee a la main a un role en base est prise en compte apres l'expiration du cache.
/// </summary>
public interface IPermissionService
{
    Task<IReadOnlySet<string>> GetForRoleAsync(string role, CancellationToken cancellationToken = default);

    /// <summary>Vide le cache (apres une modification des permissions d'un role).</summary>
    void Invalidate();
}

public static class PermissionVersion
{
    /// <summary>Empreinte stable des permissions (8 caracteres hexadecimaux) : si elle change, le mobile repart de zero pour la synchro.</summary>
    public static string Compute(IEnumerable<string> permissions)
    {
        var joined = string.Join('\n', permissions.OrderBy(permission => permission, StringComparer.Ordinal));
        return Convert.ToHexStringLower(System.Security.Cryptography.SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(joined)))[..8];
    }
}
