using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;

namespace Chantier.IntegrationTests.Persistence;

/// <summary>R2-08 : le pull d'un utilisateur qui voit tous les chantiers (Admin) n'a pas de filtre de chantier : sans index sur la version seule, balayage complet et tri a chaque appel.</summary>
[TestFixture]
public class PullIndexTests
{
    [TestCase("MaterialRequests")]
    [TestCase("Deliveries")]
    [TestCase("Photos")]
    [TestCase("Products")]
    [TestCase("Suppliers")]
    public async Task Each_pulled_table_has_an_index_that_starts_with_the_row_version(string table)
    {
        await TestDb.EnsureMigratedAsync();
        await using var db = TestDb.Create();

        var leading = await db.Database
            .SqlQuery<string>($"""
                SELECT c.name AS [Value]
                FROM sys.indexes AS i
                JOIN sys.index_columns AS ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal = 1
                JOIN sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                WHERE i.object_id = OBJECT_ID({table}) AND i.is_hypothetical = 0
                """)
            .ToListAsync();

        Assert.That(leading, Does.Contain("RowVersion"), $"{table} : index dont la premiere colonne est la version (pull sans filtre de chantier)");
    }
}
