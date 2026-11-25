using Chantier.Core.Entities.Sites;
using Chantier.Core.Sites;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Chantier.Infrastructure.Persistence.Configurations;

public sealed class SiteCounterConfiguration : IEntityTypeConfiguration<SiteCounter>
{
    public void Configure(EntityTypeBuilder<SiteCounter> builder)
    {
        builder.ToTable("SiteCounters", table => table.HasCheckConstraint("CK_SiteCounters_LastValue", "[LastValue] >= 0"));

        // Un compteur par (chantier, prefixe).
        builder.HasKey(counter => new { counter.SiteId, counter.Prefix });
        builder.Property(counter => counter.Prefix).HasMaxLength(NumberPrefixes.MaxLength).IsRequired();
        builder.Property(counter => counter.LastValue).IsRequired();

        builder.HasOne<Site>()
            .WithMany(site => site.Counters)
            .HasForeignKey(counter => counter.SiteId)
            // Ni cascade ni erreur cote EF quand un chantier suivi est « supprime » (suppression logique) : les compteurs gardent leurs numeros.
            // Meme contrainte SQL (NO ACTION) que Restrict.
            .OnDelete(DeleteBehavior.ClientNoAction);
    }
}
