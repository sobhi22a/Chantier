namespace Chantier.Core.Entities.Sites;

/// <summary>
/// Compteur de numerotation d'un type de document <b>par chantier</b> (DEM-001, LIV-001...). Une ligne par (chantier, prefixe),
/// creee avec le chantier (repli a la premiere utilisation pour un chantier sans compteur) ; <see cref="LastValue"/> est le dernier numero attribue et ne diminue jamais.
/// Pas un <c>BasicEntity</c> : ni audit, ni suppression logique, ni synchronisation (le numero est attribue par le serveur,
/// le telephone ne le calcule jamais, regle 5).
/// </summary>
public class SiteCounter
{
    // EF Core
    private SiteCounter()
    {
    }

    /// <summary>Compteur a zero pour un prefixe ; le chantier est rattache par la collection <c>Site.Counters</c> (meme ecriture, meme transaction).</summary>
    public static SiteCounter Create(string prefix) => new() { Prefix = prefix };

    public Guid SiteId { get; private set; }

    public string Prefix { get; private set; } = string.Empty;

    public int LastValue { get; private set; }
}
