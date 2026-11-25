using Chantier.Core.Entities.Sites;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Chantier.Infrastructure.Persistence.Configurations;

public sealed class SiteConfiguration : BasicEntityConfiguration<Site>
{
    public override void Configure(EntityTypeBuilder<Site> builder)
    {
        base.Configure(builder);

        builder.ToTable("Sites");

        builder.Property(site => site.Code).HasMaxLength(30).IsRequired();
        builder.Property(site => site.Name).HasMaxLength(200).IsRequired();
        builder.Property(site => site.NameAr).HasMaxLength(200);
        builder.Property(site => site.Type).IsRequired();
        builder.Property(site => site.Wilaya).HasMaxLength(100).IsRequired();
        builder.Property(site => site.Commune).HasMaxLength(100).IsRequired();
        builder.Property(site => site.Latitude).HasPrecision(9, 6);
        builder.Property(site => site.Longitude).HasPrecision(9, 6);
        builder.Property(site => site.Owner).HasMaxLength(200).IsRequired();
        builder.Property(site => site.ContractNumber).HasMaxLength(100);
        builder.Property(site => site.ContractAmount).HasPrecision(18, 2);
        builder.Property(site => site.OdsDate).HasColumnType("date");

        // Fin contractuelle calculee par le serveur, jamais stockee.
        builder.Ignore(site => site.ContractualEndDate);

        // Code unique parmi les chantiers non supprimes (archive = toujours reserve).
        builder.HasIndex(site => site.Code).IsUnique().HasFilter("[DeletedAt] IS NULL");
        builder.HasIndex(site => site.RowVersion);

        builder.HasMany(site => site.Members)
            .WithOne()
            .HasForeignKey(member => member.SiteId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
