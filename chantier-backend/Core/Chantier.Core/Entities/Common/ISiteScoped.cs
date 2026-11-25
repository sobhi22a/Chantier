namespace Chantier.Core.Entities.Common;

/// <summary>Entite appartenant a un chantier : toujours lue par (<see cref="SiteId"/>, id), jamais par id seul (OWASP API1).</summary>
public interface ISiteScoped
{
    Guid SiteId { get; }
}
