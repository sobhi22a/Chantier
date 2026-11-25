namespace Chantier.Core.Paging;

/// <summary>Liste paginee par numero de page avec total (back-office seulement).</summary>
public sealed record PagedResult<T>(IReadOnlyList<T> Items, int Page, int PageSize, int TotalCount);

/// <summary>Liste paginee par curseur (listes de terrain) : <c>nextCursor</c> absent = derniere page.</summary>
public sealed record CursorPage<T>(IReadOnlyList<T> Items, string? NextCursor);

/// <summary>Liste sans pagination (petite liste bornee, par exemple les personnes affectees a un chantier).</summary>
public sealed record ItemsResponse<T>(IReadOnlyList<T> Items);

public static class PagingRules
{
    public const int DefaultPageSize = 50;
    public const int MaxPageSize = 200;
}
