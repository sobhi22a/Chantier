using Chantier.Core.Entities.Common;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Chantier.Infrastructure.Persistence.Configurations;

/// <summary>Colonnes communes de <see cref="BasicEntity"/> : identifiant fourni par le code, audit, suppression logique, <c>rowversion</c>.</summary>
public abstract class BasicEntityConfiguration<T> : IEntityTypeConfiguration<T> where T : BasicEntity
{
    public virtual void Configure(EntityTypeBuilder<T> builder)
    {
        builder.HasKey(entity => entity.Id);
        builder.Property(entity => entity.Id).ValueGeneratedNever();

        builder.Property(entity => entity.CreatedAt).IsRequired();
        builder.Property(entity => entity.CreatedBy).IsRequired();
        builder.Property(entity => entity.UpdatedAt);
        builder.Property(entity => entity.UpdatedBy);
        builder.Property(entity => entity.DeletedAt);
        builder.Property(entity => entity.DeletedBy);

        // rowversion SQL Server lu en ulong gros-boutiste : jeton de concurrence ET curseur de synchronisation.
        builder.Property(entity => entity.RowVersion)
            .HasConversion(new RowVersionConverter())
            .HasColumnType("rowversion")
            .IsRowVersion();
    }
}
