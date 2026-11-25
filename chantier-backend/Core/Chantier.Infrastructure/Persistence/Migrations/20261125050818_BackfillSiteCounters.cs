using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Chantier.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class BackfillSiteCounters : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SiteCounters_Sites_SiteId",
                table: "SiteCounters");

            migrationBuilder.AddForeignKey(
                name: "FK_SiteCounters_Sites_SiteId",
                table: "SiteCounters",
                column: "SiteId",
                principalTable: "Sites",
                principalColumn: "Id");

            // Rattrapage (D-6) : les compteurs sont desormais crees avec le chantier ; les chantiers deja la en recoivent cinq a zero.
            // Prefixes ecrits en dur : une migration est figee et ne doit pas suivre une evolution future de NumberPrefixes.
            // Idempotent : un compteur existant (valeur deja avancee) n'est jamais touche.
            migrationBuilder.Sql(@"
INSERT INTO [SiteCounters] ([SiteId], [Prefix], [LastValue])
SELECT s.[Id], p.[Prefix], 0
FROM [Sites] AS s
CROSS JOIN (VALUES (N'DEM'), (N'LIV'), (N'T'), (N'PB'), (N'SIT')) AS p([Prefix])
WHERE NOT EXISTS (SELECT 1 FROM [SiteCounters] AS c WHERE c.[SiteId] = s.[Id] AND c.[Prefix] = p.[Prefix]);");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Les compteurs rattrapes restent : les supprimer effacerait des numeros deja attribues, et des compteurs a zero sont inoffensifs.
            migrationBuilder.DropForeignKey(
                name: "FK_SiteCounters_Sites_SiteId",
                table: "SiteCounters");

            migrationBuilder.AddForeignKey(
                name: "FK_SiteCounters_Sites_SiteId",
                table: "SiteCounters",
                column: "SiteId",
                principalTable: "Sites",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
