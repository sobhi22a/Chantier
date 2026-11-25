namespace Chantier.Core.Entities.Reference;

public class Commune
{
    public int Id { get; set; }

    public string WilayaCode { get; set; } = string.Empty;

    public string NameFr { get; set; } = string.Empty;

    public string NameAr { get; set; } = string.Empty;
}
