using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Chantier.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddSiteCounters : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "SiteCounters",
                columns: table => new
                {
                    SiteId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Prefix = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    LastValue = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SiteCounters", x => new { x.SiteId, x.Prefix });
                    table.CheckConstraint("CK_SiteCounters_LastValue", "[LastValue] >= 0");
                    table.ForeignKey(
                        name: "FK_SiteCounters_Sites_SiteId",
                        column: x => x.SiteId,
                        principalTable: "Sites",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SiteCounters");
        }
    }
}
