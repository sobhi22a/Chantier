using Chantier.Core.Entities.Identity;
using Chantier.Core.Identity;

namespace Chantier.UnitTests.Identity;

/// <summary>
/// CT-MAT-15 : la matrice par defaut est exactement le tableau « Permissions » de <c>docs/api/demandes-materiaux-livraisons.md</c> (ADR 0012).
/// Ce tableau est recopie ici ligne a ligne : modifier une permission change d'abord le contrat, puis ce test.
/// </summary>
[TestFixture]
public class MaterialPermissionMatrixTests
{
    private const string Admin = RoleNames.Admin;
    private const string Direction = RoleNames.Direction;
    private const string Conducteur = RoleNames.ConducteurTravaux;
    private const string Achats = RoleNames.Achats;
    private const string Chef = RoleNames.ChefChantier;
    private const string Equipe = RoleNames.ChefEquipe;

    private static readonly string[] Everyone = [Admin, Direction, Conducteur, Achats, Chef, Equipe];

    /// <summary>Contrat : permission, puis roles qui la portent.</summary>
    private static readonly Dictionary<string, string[]> Contract = new()
    {
        [Permissions.ProductsView] = Everyone,
        [Permissions.SuppliersView] = Everyone,
        [Permissions.ProductsCreate] = [Admin, Achats],
        [Permissions.ProductsUpdate] = [Admin, Achats],
        [Permissions.SuppliersCreate] = [Admin, Achats],
        [Permissions.SuppliersUpdate] = [Admin, Achats],
        [Permissions.SupplierPhoneView] = [Admin, Conducteur, Achats, Chef],
        [Permissions.PricesView] = [Admin, Direction, Conducteur, Achats],
        [Permissions.RequestsView] = Everyone,
        [Permissions.DeliveriesView] = Everyone,
        [Permissions.RequestsCreate] = [Admin, Conducteur, Chef, Equipe],
        [Permissions.RequestsUpdate] = [Admin, Conducteur, Chef, Equipe],
        [Permissions.RequestsUpdateAny] = [Admin, Conducteur, Chef],
        [Permissions.RequestsApprove] = [Admin, Conducteur],
        [Permissions.RequestsCancel] = [Admin, Conducteur, Chef, Equipe],
        [Permissions.RequestsCancelAny] = [Admin, Conducteur],
        [Permissions.RequestsReceive] = [Admin, Chef],
        [Permissions.RequestsSettle] = [Admin, Conducteur, Achats],
        [Permissions.RequestsArchive] = [Admin, Conducteur],
        [Permissions.RequestsLinkProduct] = [Admin, Achats],
        [Permissions.OrdersCreate] = [Admin, Achats],
        [Permissions.OrdersUpdate] = [Admin, Achats],
        [Permissions.OrdersCancel] = [Admin, Achats],
        [Permissions.DeliveriesCreate] = [Admin, Conducteur, Achats, Chef],
        [Permissions.DeliveriesUpdate] = [Admin, Conducteur, Achats, Chef],
        [Permissions.DeliveriesAttach] = [Admin, Conducteur, Achats, Chef],
        [Permissions.DeliveryPhotosCreate] = [Admin, Conducteur, Achats, Chef],
        [Permissions.DeliveryPhotosView] = [Admin, Direction, Conducteur, Achats, Chef],
    };

    public static IEnumerable<TestCaseData> Cells()
        => from role in Everyone
           from permission in Contract.Keys
           select new TestCaseData(role, permission, Contract[permission].Contains(role)).SetName($"{role} / {permission}");

    [TestCaseSource(nameof(Cells))]
    public void A_role_holds_a_materials_permission_exactly_when_the_contract_says_so(string role, string permission, bool expected)
        => Assert.That(RolePermissionMatrix.For(role).Contains(permission), Is.EqualTo(expected));

    [Test]
    public void The_contract_table_and_the_code_catalogue_list_the_same_permissions()
        => Assert.That(Contract.Keys, Is.EquivalentTo(Permissions.Materials));

    [Test]
    public void Direction_never_writes_anything_in_this_feature()
    {
        var writes = RolePermissionMatrix.For(Direction)
            .Where(permission => permission.StartsWith("Requests.", StringComparison.Ordinal)
                || permission.StartsWith("Orders.", StringComparison.Ordinal)
                || permission.StartsWith("Deliveries.", StringComparison.Ordinal)
                || permission.StartsWith("DeliveryPhotos.", StringComparison.Ordinal)
                || permission.StartsWith("Products.", StringComparison.Ordinal)
                || permission.StartsWith("Suppliers.", StringComparison.Ordinal))
            .Where(permission => !permission.EndsWith(".View", StringComparison.Ordinal));

        Assert.That(writes, Is.Empty);
    }

    [Test]
    public void Prices_are_never_given_to_the_field_roles()
    {
        // H-MAT-15, ADR 0012 : ni ChefChantier ni ChefEquipe ne voient un prix ; ils n'en ecrivent pas non plus (Orders.*).
        foreach (var role in new[] { Chef, Equipe })
        {
            Assert.That(RolePermissionMatrix.For(role), Does.Not.Contain(Permissions.PricesView).And.Not.Contain(Permissions.OrdersCreate).And.Not.Contain(Permissions.OrdersUpdate), role);
        }
    }

    [Test]
    public void The_chef_chantier_does_not_cancel_the_requests_of_his_team_but_a_team_member_cancels_his_own()
    {
        // Q-MAT-01 c : Requests.CancelAny n'est pas donnee au ChefChantier ; Requests.Cancel (« la sienne ») l'est aux trois roles de saisie.
        Assert.Multiple(() =>
        {
            Assert.That(RolePermissionMatrix.For(Chef), Does.Not.Contain(Permissions.RequestsCancelAny));
            Assert.That(RolePermissionMatrix.For(Chef), Does.Contain(Permissions.RequestsCancel));
            Assert.That(RolePermissionMatrix.For(Equipe), Does.Contain(Permissions.RequestsCancel));
            Assert.That(RolePermissionMatrix.For(Equipe), Does.Not.Contain(Permissions.RequestsUpdateAny));
        });
    }

    [Test]
    public void Every_permission_added_by_the_feature_is_a_resource_dot_action_of_the_catalogue()
        => Assert.That(Permissions.Materials, Has.All.Matches(@"^[A-Za-z]+\.[A-Za-z]+$"));
}
