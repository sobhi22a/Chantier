using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Chantier.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddPullRowVersionIndexes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Photos_RowVersion",
                table: "Photos",
                column: "RowVersion");

            migrationBuilder.CreateIndex(
                name: "IX_MaterialRequests_RowVersion",
                table: "MaterialRequests",
                column: "RowVersion");

            migrationBuilder.CreateIndex(
                name: "IX_Deliveries_RowVersion",
                table: "Deliveries",
                column: "RowVersion");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Photos_RowVersion",
                table: "Photos");

            migrationBuilder.DropIndex(
                name: "IX_MaterialRequests_RowVersion",
                table: "MaterialRequests");

            migrationBuilder.DropIndex(
                name: "IX_Deliveries_RowVersion",
                table: "Deliveries");
        }
    }
}
