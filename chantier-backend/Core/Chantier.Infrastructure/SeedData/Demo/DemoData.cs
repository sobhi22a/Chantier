using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Sites;

namespace Chantier.Infrastructure.SeedData.Demo;

/// <summary>
/// Jeu de donnees de demonstration « Ecole UV18 » : exactement la section « Donnees de demonstration » de <c>docs/metier/socle.md</c>.
/// Tout est <b>fictif</b> (noms, telephones, maitres d'ouvrage, marches) : aucune donnee reelle (CA-017.5).
/// </summary>
public static class DemoData
{
    public const string SchoolCode = "CH-ECO-UV18";
    public const string HousingCode = "CH-LOG-OL40";

    public const string AdminUser = "admin.dev";
    public const string DirectionUser = "direction.dev";
    public const string SiteManagerUser = "conducteur.dev";
    public const string PurchasingUser = "achats.dev";
    public const string ForemanUser = "chef.dev";
    public const string CrewLeaderUser = "equipe.dev";
    public const string UnassignedUser = "nonaffecte.dev";

    public sealed record DemoSite(string Code, SiteInput Input, IReadOnlyList<ZoneInput> Zones);

    /// <param name="SiteCodes">Chantiers affectes ; l'Admin n'en a pas : il voit tout par sa permission (H-02).</param>
    public sealed record DemoAccount(string UserName, string FullName, string Role, string Phone, IReadOnlyList<string> SiteCodes);

    public static IReadOnlyList<DemoSite> Sites { get; } =
    [
        new(
            SchoolCode,
            new SiteInput(
                "École UV18", null, SiteType.School, "Blida", "Boufarik", 36.575m, 2.912m,
                "Direction des équipements publics (fictive)", "M-2026-UV18-001", 185_000_000.00m, 540, new DateOnly(2026, 3, 2)),
            SchoolZones()),
        new(
            HousingCode,
            new SiteInput(
                "40 logements Les Oliviers", null, SiteType.Housing, "Blida", "Boufarik", 36.571m, 2.905m,
                "Office de promotion immobilière (fictif)", "M-2026-OL40-007", 96_400_000.00m, 420, new DateOnly(2026, 6, 15)),
            HousingZones()),
    ];

    public static IReadOnlyList<DemoAccount> Accounts { get; } =
    [
        new(AdminUser, "Farid L.", RoleNames.Admin, "0550 00 00 11", []),
        new(DirectionUser, "Meriem S.", RoleNames.Direction, "0550 00 00 12", [SchoolCode, HousingCode]),
        new(SiteManagerUser, "Slimane H.", RoleNames.ConducteurTravaux, "0550 00 00 13", [SchoolCode, HousingCode]),
        new(PurchasingUser, "Amel R.", RoleNames.Achats, "0550 00 00 14", [SchoolCode, HousingCode]),
        new(ForemanUser, "Mourad B.", RoleNames.ChefChantier, "0550 00 00 15", [SchoolCode]),
        new(CrewLeaderUser, "Toufik G.", RoleNames.ChefEquipe, "0550 00 00 16", [SchoolCode]),
        new(UnassignedUser, "Nadia Z.", RoleNames.ChefChantier, "0550 00 00 17", []),
    ];

    /// <summary>26 zones : 2 blocs + 5 cotes du bloc 01 + 7 locaux (±0,00) + 7 locaux (+3,40) + 1 cote du bloc 02 + 4 locaux du bloc 02.</summary>
    private static List<ZoneInput> SchoolZones()
    {
        var zones = new List<ZoneInput>
        {
            Zone("Bloc 01"),
            Zone("Bloc 02"),
        };

        zones.AddRange(new[] { -1.90m, 0.00m, 3.40m, 6.80m, 10.20m }.Select(elevation => Zone("Bloc 01", elevation)));
        zones.AddRange(BlockOneRooms(0.00m));
        zones.AddRange(BlockOneRooms(3.40m));

        zones.Add(Zone("Bloc 02", 0.00m));
        zones.Add(Zone("Bloc 02", 0.00m, RoomType.Canteen));
        zones.Add(Zone("Bloc 02", 0.00m, RoomType.Refectory));
        zones.Add(Zone("Bloc 02", 0.00m, RoomType.Kitchen));

        // « Façade cantine » : sans cote, nom libre (le type « Autre » porte le libellé tel que les situations de travaux le nomment).
        zones.Add(Zone("Bloc 02", null, RoomType.Other, null, "Façade cantine"));
        return zones;
    }

    private static IEnumerable<ZoneInput> BlockOneRooms(decimal elevation)
        => Enumerable.Range(1, 6)
            .Select(number => Zone("Bloc 01", elevation, RoomType.Classroom, number))
            .Append(Zone("Bloc 01", elevation, RoomType.Corridor));

    /// <summary>Bloc A (zone entiere), cote ±0,00 et cote +2,80.</summary>
    private static List<ZoneInput> HousingZones() => [Zone("Bloc A"), Zone("Bloc A", 0.00m), Zone("Bloc A", 2.80m)];

    private static ZoneInput Zone(string block, decimal? elevation = null, RoomType? roomType = null, int? roomNumber = null, string? roomLabel = null)
        => new(block, elevation, roomType, roomNumber, roomLabel);
}
