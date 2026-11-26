using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Chantier.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class EnableReadCommittedSnapshot : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // R2-01 : en lecture validee « verrouillante », la lecture de la commande active d'une demande attendait la ligne qu'une autre
            // transaction venait d'inserer, et inversement : interblocage (SQL 1205) a la creation simultanee de commandes. Avec le versionnement des lignes, une
            // lecture ne prend plus de verrou partage et n'attend plus un ecrivain. Les verrous applicatifs (sp_getapplock), les index uniques et la
            // borne MIN_ACTIVE_ROWVERSION() de la synchronisation ne dependent pas du niveau d'isolation. Chaque instruction voit les lignes validees au moment
            // ou elle demarre : apres un verrou applicatif obtenu, la relecture voit bien ce que la transaction precedente a valide.
            // ROLLBACK IMMEDIATE : le changement exige qu'aucune autre connexion n'utilise la base (deploiement : application arretee). Sans effet si deja actif.
            migrationBuilder.Sql(
                "IF EXISTS (SELECT 1 FROM sys.databases WHERE name = DB_NAME() AND is_read_committed_snapshot_on = 0) ALTER DATABASE CURRENT SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;",
                suppressTransaction: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "IF EXISTS (SELECT 1 FROM sys.databases WHERE name = DB_NAME() AND is_read_committed_snapshot_on = 1) ALTER DATABASE CURRENT SET READ_COMMITTED_SNAPSHOT OFF WITH ROLLBACK IMMEDIATE;",
                suppressTransaction: true);
        }
    }
}
