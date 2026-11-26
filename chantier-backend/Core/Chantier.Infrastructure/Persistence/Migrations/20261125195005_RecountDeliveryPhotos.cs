using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Chantier.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class RecountDeliveryPhotos : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // R2-05 : Deliveries.PhotoCount ne compte plus que les photos dont le fichier est recu (une metadonnee sans fichier n'est pas une photo : elle effacait l'alerte
            // « BL manquant »). Migration de DONNEES, sans changement de schema : le compteur de chaque livraison est recalcule depuis les photos. Idempotente. Le curseur de
            // synchronisation avance (rowversion) pour que les telephones recoivent le compteur corrige ; l'audit (UpdatedAt) n'est pas touche.
            migrationBuilder.Sql(@"
UPDATE d
SET d.[PhotoCount] = c.[Uploaded]
FROM [Deliveries] AS d
CROSS APPLY (SELECT COUNT(*) AS [Uploaded] FROM [Photos] AS p WHERE p.[DeliveryId] = d.[Id] AND p.[DeletedAt] IS NULL AND p.[ContentStatus] = N'Uploaded') AS c
WHERE d.[PhotoCount] <> c.[Uploaded];");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Le compteur d'avant comptait aussi les photos en attente : le recalculer en arriere n'a pas de sens, et un compteur exact reste correct.
        }
    }
}
