namespace Chantier.Core.Entities.Identity;

/// <summary>Les six roles fixes (un seul par utilisateur, H-01), amorces par le code.</summary>
public static class RoleNames
{
    public const string Admin = "Admin";
    public const string Direction = "Direction";
    public const string ConducteurTravaux = "ConducteurTravaux";
    public const string Achats = "Achats";
    public const string ChefChantier = "ChefChantier";
    public const string ChefEquipe = "ChefEquipe";

    public static readonly IReadOnlyList<string> All =
    [
        Admin, Direction, ConducteurTravaux, Achats, ChefChantier, ChefEquipe,
    ];
}
