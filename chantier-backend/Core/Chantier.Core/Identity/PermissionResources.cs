namespace Chantier.Core.Identity;

/// <summary>Catalogue des ressources et actions de permission (en code, pas en base : ADR 0005).</summary>
public static class PermissionResources
{
    public const string AllSites = "AllSites";
    public const string Sites = "Sites";
    public const string Zones = "Zones";
    public const string SiteMembers = "SiteMembers";
    public const string ContractAmount = "ContractAmount";
    public const string Users = "Users";
}

public static class PermissionActions
{
    public const string View = "View";
    public const string Create = "Create";
    public const string Update = "Update";

    /// <summary><c>Delete</c> = archiver : aucune suppression physique (H-13).</summary>
    public const string Delete = "Delete";
}

/// <summary>Permissions du socle sous la forme <c>Ressource.Action</c>, telles qu'exposees par <c>GET /auth/me</c>.</summary>
public static class Permissions
{
    /// <summary>Type de claim de role qui porte une permission.</summary>
    public const string ClaimType = "Permission";

    public const string AllSitesView = "AllSites.View";
    public const string SitesView = "Sites.View";
    public const string SitesCreate = "Sites.Create";
    public const string SitesUpdate = "Sites.Update";
    public const string SitesDelete = "Sites.Delete";
    public const string ZonesView = "Zones.View";
    public const string ZonesCreate = "Zones.Create";
    public const string ZonesUpdate = "Zones.Update";
    public const string ZonesDelete = "Zones.Delete";
    public const string SiteMembersView = "SiteMembers.View";
    public const string SiteMembersUpdate = "SiteMembers.Update";
    public const string ContractAmountView = "ContractAmount.View";
    public const string UsersView = "Users.View";
    public const string UsersCreate = "Users.Create";
    public const string UsersUpdate = "Users.Update";

    public static string Of(string resource, string action) => $"{resource}.{action}";
}
