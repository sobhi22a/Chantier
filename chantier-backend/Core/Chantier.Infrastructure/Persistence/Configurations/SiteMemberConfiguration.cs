using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Sites;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Chantier.Infrastructure.Persistence.Configurations;

public sealed class SiteMemberConfiguration : BasicEntityConfiguration<SiteMember>
{
    public override void Configure(EntityTypeBuilder<SiteMember> builder)
    {
        base.Configure(builder);

        builder.ToTable("SiteMembers");

        builder.Property(member => member.SiteId).IsRequired();
        builder.Property(member => member.UserId).IsRequired();

        builder.HasOne<AppUser>()
            .WithMany()
            .HasForeignKey(member => member.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        // Une seule affectation active par (chantier, utilisateur) ; un retrait (suppression logique) libere le couple.
        builder.HasIndex(member => new { member.SiteId, member.UserId })
            .IsUnique()
            .HasFilter("[DeletedAt] IS NULL");

        builder.HasIndex(member => member.UserId);
        builder.HasIndex(member => new { member.SiteId, member.RowVersion });
    }
}
