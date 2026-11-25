namespace Chantier.Core.Entities.Reference;

/// <summary>
/// Wilaya du referentiel geographique. Les listes sont des <b>donnees</b> (fichiers modifiables, H-14), pas du code :
/// le decoupage officiel evolue et la liste officielle reste a confirmer (Q-11).
/// </summary>
public class Wilaya
{
    /// <summary>Code a deux chiffres (« 09 » pour Blida).</summary>
    public string Code { get; set; } = string.Empty;

    public string NameFr { get; set; } = string.Empty;

    public string NameAr { get; set; } = string.Empty;
}
