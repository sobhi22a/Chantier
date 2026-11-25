using Chantier.Core.Entities.Reference;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Chantier.Infrastructure.Persistence.Configurations;

public sealed class WilayaConfiguration : IEntityTypeConfiguration<Wilaya>
{
    public void Configure(EntityTypeBuilder<Wilaya> builder)
    {
        builder.ToTable("Wilayas");
        builder.HasKey(wilaya => wilaya.Code);
        builder.Property(wilaya => wilaya.Code).HasMaxLength(2).IsRequired().ValueGeneratedNever();
        builder.Property(wilaya => wilaya.NameFr).HasMaxLength(100).IsRequired();
        builder.Property(wilaya => wilaya.NameAr).HasMaxLength(100).IsRequired();
    }
}

public sealed class CommuneConfiguration : IEntityTypeConfiguration<Commune>
{
    public void Configure(EntityTypeBuilder<Commune> builder)
    {
        builder.ToTable("Communes");
        builder.HasKey(commune => commune.Id);
        builder.Property(commune => commune.WilayaCode).HasMaxLength(2).IsRequired();
        builder.Property(commune => commune.NameFr).HasMaxLength(100).IsRequired();
        builder.Property(commune => commune.NameAr).HasMaxLength(100).IsRequired();

        builder.HasIndex(commune => new { commune.WilayaCode, commune.NameFr }).IsUnique();

        builder.HasOne<Wilaya>()
            .WithMany()
            .HasForeignKey(commune => commune.WilayaCode)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
