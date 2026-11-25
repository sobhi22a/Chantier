using Microsoft.AspNetCore.Identity;

namespace Chantier.Core.Entities.Identity;

public class AppRole : IdentityRole<Guid>
{
    public AppRole()
    {
    }

    public AppRole(string name)
    {
        Id = Guid.CreateVersion7();
        Name = name;
    }
}
