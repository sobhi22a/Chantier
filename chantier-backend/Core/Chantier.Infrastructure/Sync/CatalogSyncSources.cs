using Chantier.Core.Entities.Materials;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Core.Sites;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Produits du catalogue : entite <b>globale</b> (<c>siteId</c> nul), recue par tous les utilisateurs authentifies, sans chantier affecte. Les produits
/// ne sont jamais supprimes (ils sont desactives et gardent leur ligne) : aucune pierre tombale (ADR 0012).
/// </summary>
public sealed class ProductSyncSource(ApplicationDbContext db, IUserDirectory directory) : ISyncSource
{
    public async Task<IReadOnlyList<SyncChangeRow>> ReadAsync(SyncScope scope, ulong since, ulong upper, int take, CancellationToken cancellationToken = default)
    {
        if (!scope.Permissions.Contains(Permissions.ProductsView))
        {
            return [];
        }

        var products = await db.Products.AsNoTracking()
            .Where(product => product.RowVersion > since && product.RowVersion < upper)
            .OrderBy(product => product.RowVersion)
            .Take(take)
            .ToListAsync(cancellationToken);
        var names = await directory.GetNamesAsync(products.SelectMany(ProductResponse.AuditUsers), cancellationToken);

        return products
            .Select(product => new SyncChangeRow(SyncEntities.Product, product.Id, null, product.RowVersion, ProductResponse.From(product, names)))
            .ToList();
    }
}

/// <summary>
/// Fournisseurs : entite <b>globale</b>. <see cref="SupplierSyncData"/> n'a <b>pas</b> de champ telephone : un telephone ne peut pas atteindre un telephone
/// mobile par la synchronisation, quel que soit le role (ADR 0012, H-ARCH-03).
/// </summary>
public sealed class SupplierSyncSource(ApplicationDbContext db, IUserDirectory directory) : ISyncSource
{
    public async Task<IReadOnlyList<SyncChangeRow>> ReadAsync(SyncScope scope, ulong since, ulong upper, int take, CancellationToken cancellationToken = default)
    {
        if (!scope.Permissions.Contains(Permissions.SuppliersView))
        {
            return [];
        }

        var suppliers = await db.Suppliers.AsNoTracking()
            .Where(supplier => supplier.RowVersion > since && supplier.RowVersion < upper)
            .OrderBy(supplier => supplier.RowVersion)
            .Take(take)
            .ToListAsync(cancellationToken);
        var names = await directory.GetNamesAsync(suppliers.SelectMany(SupplierResponse.AuditUsers), cancellationToken);

        return suppliers
            .Select(supplier => new SyncChangeRow(SyncEntities.Supplier, supplier.Id, null, supplier.RowVersion, SupplierSyncData.From(supplier, names)))
            .ToList();
    }
}
