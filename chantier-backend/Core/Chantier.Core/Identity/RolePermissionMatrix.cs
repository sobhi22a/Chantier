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

    // Tous les roles voient le catalogue, les demandes et les livraisons de leurs chantiers (prix, telephone et photos a part).
    private static readonly string[] MaterialsReadOnly =
    [
        Permissions.ProductsView, Permissions.SuppliersView, Permissions.RequestsView, Permissions.DeliveriesView,
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
            .. MaterialsReadOnly,
            Permissions.ProductsCreate, Permissions.ProductsUpdate, Permissions.SuppliersCreate, Permissions.SuppliersUpdate,
            Permissions.SupplierPhoneView, Permissions.PricesView,
            Permissions.RequestsCreate, Permissions.RequestsUpdate, Permissions.RequestsUpdateAny, Permissions.RequestsApprove,
            Permissions.RequestsCancel, Permissions.RequestsCancelAny, Permissions.RequestsReceive, Permissions.RequestsSettle,
            Permissions.RequestsArchive, Permissions.RequestsLinkProduct,
            Permissions.OrdersCreate, Permissions.OrdersUpdate, Permissions.OrdersCancel,
            Permissions.DeliveriesCreate, Permissions.DeliveriesUpdate, Permissions.DeliveriesAttach,
            Permissions.DeliveryPhotosCreate, Permissions.DeliveryPhotosView,
        ],
        [RoleNames.Direction] =
        [
            .. ReadOnly,
            Permissions.ContractAmountView,
            .. MaterialsReadOnly,
            Permissions.PricesView, Permissions.DeliveryPhotosView,
        ],
        [RoleNames.ConducteurTravaux] =
        [
            .. ReadOnly,
            Permissions.ContractAmountView,
            Permissions.ZonesCreate, Permissions.ZonesUpdate, Permissions.ZonesDelete,
            .. MaterialsReadOnly,
            Permissions.SupplierPhoneView, Permissions.PricesView,
            Permissions.RequestsCreate, Permissions.RequestsUpdate, Permissions.RequestsUpdateAny, Permissions.RequestsApprove,
            Permissions.RequestsCancel, Permissions.RequestsCancelAny, Permissions.RequestsSettle, Permissions.RequestsArchive,
            Permissions.DeliveriesCreate, Permissions.DeliveriesUpdate, Permissions.DeliveriesAttach,
            Permissions.DeliveryPhotosCreate, Permissions.DeliveryPhotosView,
        ],
        [RoleNames.Achats] =
        [
            .. ReadOnly,
            .. MaterialsReadOnly,
            Permissions.ProductsCreate, Permissions.ProductsUpdate, Permissions.SuppliersCreate, Permissions.SuppliersUpdate,
            Permissions.SupplierPhoneView, Permissions.PricesView,
            Permissions.RequestsSettle, Permissions.RequestsLinkProduct,
            Permissions.OrdersCreate, Permissions.OrdersUpdate, Permissions.OrdersCancel,
            Permissions.DeliveriesCreate, Permissions.DeliveriesUpdate, Permissions.DeliveriesAttach,
            Permissions.DeliveryPhotosCreate, Permissions.DeliveryPhotosView,
        ],
        [RoleNames.ChefChantier] =
        [
            .. ReadOnly,
            Permissions.ZonesCreate, Permissions.ZonesUpdate,
            .. MaterialsReadOnly,
            Permissions.SupplierPhoneView,
            Permissions.RequestsCreate, Permissions.RequestsUpdate, Permissions.RequestsUpdateAny, Permissions.RequestsCancel, Permissions.RequestsReceive,
            Permissions.DeliveriesCreate, Permissions.DeliveriesUpdate, Permissions.DeliveriesAttach,
            Permissions.DeliveryPhotosCreate, Permissions.DeliveryPhotosView,
        ],
        [RoleNames.ChefEquipe] =
        [
            .. ReadOnly,
            .. MaterialsReadOnly,
            Permissions.RequestsCreate, Permissions.RequestsUpdate, Permissions.RequestsCancel,
        ],
    };

    public static IReadOnlyList<string> For(string role)
        => ByRole.TryGetValue(role, out var permissions) ? permissions : [];

    public static IReadOnlyCollection<string> Roles => ByRole.Keys.ToArray();
}
