using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Persistence;

public static class SqlErrors
{
    /// <summary>Violation d'un index unique (2601) ou d'une contrainte unique (2627) : course entre deux creations identiques.</summary>
    public static bool IsUniqueViolation(this DbUpdateException exception)
        => exception.InnerException is SqlException { Number: 2601 or 2627 };
}
