using Chantier.Core.Entities.Identity;

namespace Chantier.Core.Identity;

/// <summary>
/// Matrice par defaut role -> permissions (ADR 0005, « Droits par rôle » de docs/metier/socle.md).
/// Un seeder idempotent <b>ajoute</b> les claims manquantes a la base sans jamais retirer un ajout manuel ;
/// Q-02 et Q-05 (Direction voit tout, ConducteurTravaux affecte) changent une ligne de ce tableau, pas du code metier.
/// </summary>
public static class RolePermissionMatrix
{
    private static readonly string[] ReadOnly =
    [
        Permissions.SitesView, Permissions.ZonesView, Permissions.SiteMembersView,
    ];

    private static readonly IReadOnlyDictionary<string, IReadOnlyList<string>> ByRole = new Dictionary<string, IReadOnlyList<string>>(StringComparer.Ordinal)
    {
        [RoleNames.Admin] =
        [
            Permissions.AllSitesView,
            Permissions.SitesView, Permissions.SitesCreate, Permissions.SitesUpdate, Permissions.SitesDelete,
            Permissions.ZonesView, Permissions.ZonesCreate, Permissions.ZonesUpdate, Permissions.ZonesDelete,
            Permissions.SiteMembersView, Permissions.SiteMembersUpdate,
            Permissions.ContractAmountView,
            Permissions.UsersView, Permissions.UsersCreate, Permissions.UsersUpdate,
        ],
        [RoleNames.Direction] = [.. ReadOnly, Permissions.ContractAmountView],
        [RoleNames.ConducteurTravaux] =
        [
            .. ReadOnly,
            Permissions.ContractAmountView,
            Permissions.ZonesCreate, Permissions.ZonesUpdate, Permissions.ZonesDelete,
        ],
        [RoleNames.Achats] = [.. ReadOnly],
        [RoleNames.ChefChantier] = [.. ReadOnly, Permissions.ZonesCreate, Permissions.ZonesUpdate],
        [RoleNames.ChefEquipe] = [.. ReadOnly],
    };

    public static IReadOnlyList<string> For(string role)
        => ByRole.TryGetValue(role, out var permissions) ? permissions : [];

    public static IReadOnlyCollection<string> Roles => ByRole.Keys.ToArray();
}
