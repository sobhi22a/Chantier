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
    public const string Products = "Products";
    public const string Suppliers = "Suppliers";
    public const string SupplierPhone = "SupplierPhone";
    public const string Prices = "Prices";
    public const string Requests = "Requests";
    public const string Orders = "Orders";
    public const string Deliveries = "Deliveries";
    public const string DeliveryPhotos = "DeliveryPhotos";
}

public static class PermissionActions
{
    public const string View = "View";
    public const string Create = "Create";
    public const string Update = "Update";

    /// <summary><c>Delete</c> = archiver : aucune suppression physique (H-13).</summary>
    public const string Delete = "Delete";

    // Actions metier des demandes, commandes et livraisons de materiaux (docs/api/demandes-materiaux-livraisons.md).
    public const string UpdateAny = "UpdateAny";
    public const string Approve = "Approve";
    public const string Cancel = "Cancel";
    public const string CancelAny = "CancelAny";
    public const string Receive = "Receive";
    public const string Settle = "Settle";
    public const string Archive = "Archive";
    public const string LinkProduct = "LinkProduct";
    public const string Attach = "Attach";
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

    // Demandes de materiaux, commandes, livraisons (le role decide de l'action, l'affectation du perimetre).
    public const string ProductsView = "Products.View";
    public const string ProductsCreate = "Products.Create";
    public const string ProductsUpdate = "Products.Update";
    public const string SuppliersView = "Suppliers.View";
    public const string SuppliersCreate = "Suppliers.Create";
    public const string SuppliersUpdate = "Suppliers.Update";
    public const string SupplierPhoneView = "SupplierPhone.View";
    public const string PricesView = "Prices.View";
    public const string RequestsView = "Requests.View";
    public const string RequestsCreate = "Requests.Create";
    public const string RequestsUpdate = "Requests.Update";
    public const string RequestsUpdateAny = "Requests.UpdateAny";
    public const string RequestsApprove = "Requests.Approve";
    public const string RequestsCancel = "Requests.Cancel";
    public const string RequestsCancelAny = "Requests.CancelAny";
    public const string RequestsReceive = "Requests.Receive";
    public const string RequestsSettle = "Requests.Settle";
    public const string RequestsArchive = "Requests.Archive";
    public const string RequestsLinkProduct = "Requests.LinkProduct";
    public const string OrdersCreate = "Orders.Create";
    public const string OrdersUpdate = "Orders.Update";
    public const string OrdersCancel = "Orders.Cancel";
    public const string DeliveriesView = "Deliveries.View";
    public const string DeliveriesCreate = "Deliveries.Create";
    public const string DeliveriesUpdate = "Deliveries.Update";
    public const string DeliveriesAttach = "Deliveries.Attach";
    public const string DeliveryPhotosCreate = "DeliveryPhotos.Create";
    public const string DeliveryPhotosView = "DeliveryPhotos.View";

    /// <summary>Toutes les permissions des demandes de materiaux (catalogue du contrat) : sert aux tests de la matrice.</summary>
    public static readonly IReadOnlyList<string> Materials =
    [
        ProductsView, ProductsCreate, ProductsUpdate, SuppliersView, SuppliersCreate, SuppliersUpdate, SupplierPhoneView, PricesView,
        RequestsView, RequestsCreate, RequestsUpdate, RequestsUpdateAny, RequestsApprove, RequestsCancel, RequestsCancelAny,
        RequestsReceive, RequestsSettle, RequestsArchive, RequestsLinkProduct, OrdersCreate, OrdersUpdate, OrdersCancel,
        DeliveriesView, DeliveriesCreate, DeliveriesUpdate, DeliveriesAttach, DeliveryPhotosCreate, DeliveryPhotosView,
    ];

    public static string Of(string resource, string action) => $"{resource}.{action}";
}
