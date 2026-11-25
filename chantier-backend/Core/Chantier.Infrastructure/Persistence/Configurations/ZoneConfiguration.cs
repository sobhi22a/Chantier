using Chantier.Core.Entities.Sites;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Chantier.Infrastructure.Persistence.Configurations;

public sealed class ZoneConfiguration : BasicEntityConfiguration<Zone>
{
    public override void Configure(EntityTypeBuilder<Zone> builder)
    {
        base.Configure(builder);

        builder.ToTable("Zones");

        builder.Property(zone => zone.SiteId).IsRequired();
        builder.Property(zone => zone.Block).HasMaxLength(50).IsRequired();
        builder.Property(zone => zone.Elevation).HasPrecision(7, 2);
        builder.Property(zone => zone.RoomLabel).HasMaxLength(100);

        builder.HasOne<Site>()
            .WithMany()
            .HasForeignKey(zone => zone.SiteId)
            .OnDelete(DeleteBehavior.Restrict);

        // Une meme combinaison (bloc, cote, local, numero, libelle) une seule fois par chantier parmi les zones actives.
        // SQL Server traite NULL comme une valeur egale dans un index unique : les valeurs absentes comptent bien dans l'unicite.
        // Une zone archivee libere sa combinaison ; la restaurer peut donc se heurter a ZONE_EXISTANTE.
        builder.HasIndex(zone => new { zone.SiteId, zone.Block, zone.Elevation, zone.RoomType, zone.RoomNumber, zone.RoomLabel })
            .IsUnique()
            .HasFilter("[DeletedAt] IS NULL AND [ArchivedAt] IS NULL");

        // Idempotence de la creation hors ligne.
        builder.HasIndex(zone => new { zone.SiteId, zone.ClientId })
            .IsUnique()
            .HasFilter("[ClientId] IS NOT NULL");

        // Curseur de synchronisation par chantier.
        builder.HasIndex(zone => new { zone.SiteId, zone.RowVersion });
    }
}
