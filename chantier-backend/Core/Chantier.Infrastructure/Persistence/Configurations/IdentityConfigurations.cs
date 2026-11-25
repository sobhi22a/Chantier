using Chantier.Core.Entities.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Chantier.Infrastructure.Persistence.Configurations;

public sealed class AppUserConfiguration : IEntityTypeConfiguration<AppUser>
{
    public void Configure(EntityTypeBuilder<AppUser> builder)
    {
        builder.Property(user => user.Id).ValueGeneratedNever();
        builder.Property(user => user.FullName).HasMaxLength(200).IsRequired();
        builder.Property(user => user.Language).HasMaxLength(2).IsRequired().HasDefaultValue(AppUser.French);
        builder.Property(user => user.PhoneNumber).HasMaxLength(30);
        builder.Property(user => user.IsActive).HasDefaultValue(true);
    }
}

public sealed class AppRoleConfiguration : IEntityTypeConfiguration<AppRole>
{
    public void Configure(EntityTypeBuilder<AppRole> builder)
    {
        builder.Property(role => role.Id).ValueGeneratedNever();
    }
}
