using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Entities.Sync;
using Chantier.Core.Materials;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace Chantier.Infrastructure.Persistence.Configurations;

/// <summary>Unite stockee par son code stable (<c>sac</c>, <c>m3</c>...) et non par le nom de l'enumeration : meme texte en base, en JSON et dans les vecteurs.</summary>
public sealed class MeasureUnitConverter()
    : ValueConverter<MeasureUnit, string>(unit => MeasureUnits.Code(unit), code => Parse(code))
{
    private static MeasureUnit Parse(string code)
        => MeasureUnits.TryParse(code, out var unit) ? unit : throw new InvalidOperationException("Code d'unité inconnu en base.");
}

public sealed class ProductConfiguration : BasicEntityConfiguration<Product>
{
    public override void Configure(EntityTypeBuilder<Product> builder)
    {
        base.Configure(builder);

        builder.ToTable("Products");

        builder.Property(product => product.NameFr).HasMaxLength(Product.NameMaxLength).IsRequired();
        builder.Property(product => product.NameAr).HasMaxLength(Product.NameMaxLength);
        builder.Property(product => product.NormalizedNameFr).HasMaxLength(Product.NameMaxLength * 2).IsRequired();
        builder.Property(product => product.DefaultUnit).HasConversion(new MeasureUnitConverter()).HasMaxLength(10);
        builder.Property(product => product.BagMassKg).HasPrecision(9, 3);

        // Unites autorisees : codes separes par des virgules (« sac,t,kg »), jamais de texte libre.
        builder.Property(product => product.AllowedUnits)
            .HasConversion(
                units => string.Join(',', units.Select(MeasureUnits.Code)),
                text => ParseUnits(text),
                new ValueComparer<IReadOnlyList<MeasureUnit>>(
                    (left, right) => left!.SequenceEqual(right!),
                    units => units.Aggregate(0, (hash, unit) => HashCode.Combine(hash, unit)),
                    units => units.ToList()))
            .HasMaxLength(100)
            .IsRequired();

        // Unicite du nom sans tenir compte de la casse, des accents ni des espaces superflus.
        builder.HasIndex(product => product.NormalizedNameFr).IsUnique().HasFilter("[DeletedAt] IS NULL");
        builder.HasIndex(product => new { product.Category, product.IsActive });
        builder.HasIndex(product => product.RowVersion);
    }

    private static IReadOnlyList<MeasureUnit> ParseUnits(string text)
        => text.Split(',', StringSplitOptions.RemoveEmptyEntries)
            .Select(code => MeasureUnits.TryParse(code, out var unit) ? unit : throw new InvalidOperationException("Code d'unité inconnu en base."))
            .ToList();
}

public sealed class SupplierConfiguration : BasicEntityConfiguration<Supplier>
{
    public override void Configure(EntityTypeBuilder<Supplier> builder)
    {
        base.Configure(builder);

        builder.ToTable("Suppliers");

        builder.Property(supplier => supplier.Name).HasMaxLength(Supplier.NameMaxLength).IsRequired();
        builder.Property(supplier => supplier.NormalizedName).HasMaxLength(Supplier.NameMaxLength * 2).IsRequired();
        builder.Property(supplier => supplier.Phone).HasMaxLength(30);
        builder.PrimitiveCollection(supplier => supplier.ProductIds);

        builder.HasIndex(supplier => supplier.NormalizedName).IsUnique().HasFilter("[DeletedAt] IS NULL");
        builder.HasIndex(supplier => supplier.RowVersion);
    }
}

public sealed class MaterialRequestConfiguration : BasicEntityConfiguration<MaterialRequest>
{
    private const int NumberMaxLength = 20;

    public override void Configure(EntityTypeBuilder<MaterialRequest> builder)
    {
        base.Configure(builder);

        builder.ToTable("MaterialRequests", table => table.HasCheckConstraint(
            "CK_MaterialRequests_Product",
            "[ProductId] IS NOT NULL OR [FreeProductName] IS NOT NULL"));

        builder.Property(request => request.SiteId).IsRequired();
        builder.Property(request => request.Number).HasMaxLength(NumberMaxLength).IsRequired();
        builder.Property(request => request.FreeProductName).HasMaxLength(100);
        builder.Property(request => request.QuantityValue).HasColumnName("Quantity").HasPrecision(18, 3);
        builder.Property(request => request.Unit).HasConversion(new MeasureUnitConverter()).HasMaxLength(10);
        builder.Property(request => request.Note).HasMaxLength(200);
        builder.Property(request => request.StatusReasonCode).HasMaxLength(50);
        builder.Property(request => request.StatusReasonNote).HasMaxLength(200);
        builder.Property(request => request.ReceivedQuantity).HasPrecision(18, 3);

        builder.HasOne<Site>().WithMany().HasForeignKey(request => request.SiteId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Product>().WithMany().HasForeignKey(request => request.ProductId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Zone>().WithMany().HasForeignKey(request => request.ZoneId).OnDelete(DeleteBehavior.Restrict);

        // Numero unique par chantier ; idempotence de la creation hors ligne (un renvoi du meme clientId ne cree rien).
        builder.HasIndex(request => new { request.SiteId, request.Number }).IsUnique().HasFilter("[DeletedAt] IS NULL");
        builder.HasIndex(request => new { request.SiteId, request.ClientId }).IsUnique().HasFilter("[ClientId] IS NOT NULL");

        // Listes et vues du suivi ; recherche de doublon ; curseur de synchronisation.
        builder.HasIndex(request => new { request.SiteId, request.Status, request.Priority, request.NeededBy });
        builder.HasIndex(request => new { request.SiteId, request.ProductId, request.ZoneId, request.Status });
        builder.HasIndex(request => new { request.SiteId, request.RowVersion });

        // Pull d'un utilisateur qui voit tous les chantiers (Admin) : aucun filtre de chantier, donc un index qui commence par la version (R2-08).
        builder.HasIndex(request => request.RowVersion);
    }
}

public sealed class MaterialOrderConfiguration : BasicEntityConfiguration<MaterialOrder>
{
    public override void Configure(EntityTypeBuilder<MaterialOrder> builder)
    {
        base.Configure(builder);

        builder.ToTable("MaterialOrders");

        builder.Property(order => order.SiteId).IsRequired();
        builder.Property(order => order.UnitPrice).HasPrecision(18, 2);
        builder.Property(order => order.Amount).HasPrecision(18, 2);
        builder.Property(order => order.PurchaseOrderNumber).HasMaxLength(MaterialOrder.PurchaseOrderNumberMaxLength);
        builder.Property(order => order.Note).HasMaxLength(200);
        builder.Property(order => order.CancelReasonCode).HasMaxLength(50);
        builder.Property(order => order.CancelReasonNote).HasMaxLength(200);

        builder.HasOne<Site>().WithMany().HasForeignKey(order => order.SiteId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<MaterialRequest>().WithMany().HasForeignKey(order => order.RequestId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Supplier>().WithMany().HasForeignKey(order => order.SupplierId).OnDelete(DeleteBehavior.Restrict);

        // Une seule commande active par demande (COMMANDE_EXISTANTE) : une commande annulee libere la demande.
        builder.HasIndex(order => order.RequestId).IsUnique().HasFilter("[DeletedAt] IS NULL AND [CancelledAt] IS NULL");

        // Idempotence de la creation (meme clientId renvoye : meme commande).
        builder.HasIndex(order => new { order.SiteId, order.ClientId }).IsUnique().HasFilter("[ClientId] IS NOT NULL");
        builder.HasIndex(order => new { order.SiteId, order.RowVersion });
    }
}

public sealed class DeliveryConfiguration : BasicEntityConfiguration<Delivery>
{
    private const int NumberMaxLength = 20;

    public override void Configure(EntityTypeBuilder<Delivery> builder)
    {
        base.Configure(builder);

        builder.ToTable("Deliveries", table =>
        {
            table.HasCheckConstraint("CK_Deliveries_Product", "[ProductId] IS NOT NULL OR [FreeProductName] IS NOT NULL");
            table.HasCheckConstraint("CK_Deliveries_Supplier", "[SupplierId] IS NOT NULL OR [FreeSupplierName] IS NOT NULL");
        });

        builder.Property(delivery => delivery.SiteId).IsRequired();
        builder.Property(delivery => delivery.Number).HasMaxLength(NumberMaxLength).IsRequired();
        builder.Property(delivery => delivery.FreeSupplierName).HasMaxLength(100);
        builder.Property(delivery => delivery.FreeProductName).HasMaxLength(100);
        builder.Property(delivery => delivery.QuantityValue).HasColumnName("Quantity").HasPrecision(18, 3);
        builder.Property(delivery => delivery.Unit).HasConversion(new MeasureUnitConverter()).HasMaxLength(10);
        builder.Property(delivery => delivery.QuantityInRequestUnit).HasPrecision(18, 3);
        builder.Property(delivery => delivery.DeliveryNoteNumber).HasMaxLength(30);
        builder.Property(delivery => delivery.ReserveReasonCode).HasMaxLength(50);
        builder.Property(delivery => delivery.ReserveNote).HasMaxLength(200);
        builder.Property(delivery => delivery.CancelReasonCode).HasMaxLength(50);
        builder.Property(delivery => delivery.CancelReasonNote).HasMaxLength(200);
        builder.Property(delivery => delivery.Amount).HasPrecision(18, 2);

        builder.HasOne<Site>().WithMany().HasForeignKey(delivery => delivery.SiteId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<MaterialRequest>().WithMany().HasForeignKey(delivery => delivery.RequestId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Supplier>().WithMany().HasForeignKey(delivery => delivery.SupplierId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Product>().WithMany().HasForeignKey(delivery => delivery.ProductId).OnDelete(DeleteBehavior.Restrict);

        // Numero unique par chantier ; idempotence de la creation hors ligne.
        builder.HasIndex(delivery => new { delivery.SiteId, delivery.Number }).IsUnique().HasFilter("[DeletedAt] IS NULL");
        builder.HasIndex(delivery => new { delivery.SiteId, delivery.ClientId }).IsUnique().HasFilter("[ClientId] IS NOT NULL");

        // Recalcul d'une demande ; livraisons a traiter (non rattachees) ; doublon de BL ; liste par date ; curseur de synchronisation.
        builder.HasIndex(delivery => new { delivery.SiteId, delivery.RequestId, delivery.Status });
        builder.HasIndex(delivery => new { delivery.SiteId, delivery.Status }).HasFilter("[RequestId] IS NULL");
        builder.HasIndex(delivery => new { delivery.SiteId, delivery.SupplierId, delivery.ProductId, delivery.DeliveryNoteNumber });
        builder.HasIndex(delivery => new { delivery.SiteId, delivery.DeliveryDate });
        builder.HasIndex(delivery => new { delivery.SiteId, delivery.RowVersion });
        builder.HasIndex(delivery => delivery.RowVersion);
    }
}

public sealed class PhotoConfiguration : BasicEntityConfiguration<Photo>
{
    public override void Configure(EntityTypeBuilder<Photo> builder)
    {
        base.Configure(builder);

        builder.ToTable("Photos");

        builder.Property(photo => photo.SiteId).IsRequired();
        builder.Property(photo => photo.ContentType).HasMaxLength(50).IsRequired();
        builder.Property(photo => photo.Sha256).HasMaxLength(64).IsFixedLength().IsRequired();
        builder.Property(photo => photo.StorageKey).HasMaxLength(200);

        builder.HasOne<Site>().WithMany().HasForeignKey(photo => photo.SiteId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Delivery>().WithMany().HasForeignKey(photo => photo.DeliveryId).OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(photo => new { photo.SiteId, photo.ClientId }).IsUnique().HasFilter("[ClientId] IS NOT NULL");
        builder.HasIndex(photo => photo.DeliveryId);
        builder.HasIndex(photo => new { photo.SiteId, photo.RowVersion });
        builder.HasIndex(photo => photo.RowVersion);
    }
}

public sealed class MaterialEventConfiguration : BasicEntityConfiguration<MaterialEvent>
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    public override void Configure(EntityTypeBuilder<MaterialEvent> builder)
    {
        base.Configure(builder);

        builder.ToTable("MaterialEvents");

        builder.Property(materialEvent => materialEvent.ReasonCode).HasMaxLength(50);
        builder.Property(materialEvent => materialEvent.ReasonNote).HasMaxLength(MaterialEvent.ReasonNoteMaxLength);

        // « [{field, old, new}] » : jamais un prix (les modifications commerciales ont leur type dedie).
        builder.Property(materialEvent => materialEvent.Changes)
            .HasConversion(
                changes => changes == null ? null : JsonSerializer.Serialize(changes, Json),
                text => text == null ? null : JsonSerializer.Deserialize<List<FieldChange>>(text, Json),
                new ValueComparer<IReadOnlyList<FieldChange>?>(
                    (left, right) => ReferenceEquals(left, right) || (left != null && right != null && left.SequenceEqual(right)),
                    changes => changes == null ? 0 : changes.Aggregate(0, (hash, change) => HashCode.Combine(hash, change)),
                    changes => changes == null ? null : changes.ToList()));

        builder.HasIndex(materialEvent => new { materialEvent.SubjectType, materialEvent.SubjectId, materialEvent.CreatedAt });
        builder.HasIndex(materialEvent => materialEvent.SiteId);
    }
}

public sealed class SyncOperationLogConfiguration : IEntityTypeConfiguration<SyncOperationLog>
{
    public void Configure(EntityTypeBuilder<SyncOperationLog> builder)
    {
        builder.ToTable("SyncOperationLogs");

        // Cle = identifiant de l'operation genere par le telephone : un renvoi retrouve son resultat.
        builder.HasKey(log => log.ClientId);
        builder.Property(log => log.ClientId).ValueGeneratedNever();
        builder.Property(log => log.Entity).HasMaxLength(30).IsRequired();
        builder.Property(log => log.Operation).HasMaxLength(30).IsRequired();
        builder.Property(log => log.Outcome).HasMaxLength(20).IsRequired();
        builder.Property(log => log.Code).HasMaxLength(50);
        builder.Property(log => log.ConflictFields).HasMaxLength(200);

        // Purge des operations anciennes (comme les pierres tombales).
        builder.HasIndex(log => log.CreatedAt);
    }
}
