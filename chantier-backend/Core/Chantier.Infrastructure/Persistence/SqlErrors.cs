using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Persistence;

public static class SqlErrors
{
    /// <summary>Interblocage : SQL Server a choisi cette transaction comme victime et l'a annulee.</summary>
    private const int Deadlock = 1205;

    /// <summary>
    /// Echecs momentanes : interblocage (1205), delai de verrou depasse (1222), delai de commande depasse (-2), service surcharge ou en bascule (Azure SQL, pools).
    /// Rien n'est ecrit (la transaction est annulee) : la meme action rejouee peut reussir.
    /// </summary>
    private static readonly HashSet<int> TransientNumbers = [Deadlock, 1222, -2, 10928, 10929, 40197, 40501, 40613, 49918, 49919, 49920];

    /// <summary>Violation d'un index unique (2601) ou d'une contrainte unique (2627) : course entre deux creations identiques.</summary>
    public static bool IsUniqueViolation(this DbUpdateException exception)
        => exception.InnerException is SqlException { Number: 2601 or 2627 };

    /// <summary>Cette exception, ou l'une de ses causes, est un interblocage SQL (1205) : la transaction a ete annulee, la rejouer est sans danger.</summary>
    public static bool IsDeadlock(Exception exception) => Find(exception) is { Number: Deadlock };

    /// <summary>L'echec est momentane (interblocage, delai depasse, surcharge) : le client peut rejouer plus tard. Les autres erreurs SQL ne se rejouent pas.</summary>
    public static bool IsTransient(Exception exception) => Find(exception) is { } sql && TransientNumbers.Contains(sql.Number);

    /// <summary>Erreur SQL a l'origine de l'exception (la sienne ou celle d'une cause), <c>null</c> si l'exception ne vient pas de la base.</summary>
    public static SqlException? Find(Exception? exception)
    {
        for (var current = exception; current is not null; current = current.InnerException)
        {
            if (current is SqlException sql)
            {
                return sql;
            }
        }

        return null;
    }
}
