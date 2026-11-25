namespace Chantier.Infrastructure.Persistence;

/// <summary>Noms des filtres de requete nommes (EF Core 10). <c>IgnoreQueryFilters([...])</c> seulement de facon ciblee et justifiee.</summary>
public static class QueryFilterNames
{
    /// <summary>Exclut les lignes supprimees logiquement ; la synchronisation le desactive pour lire les pierres tombales.</summary>
    public const string SoftDelete = "SoftDelete";
}
