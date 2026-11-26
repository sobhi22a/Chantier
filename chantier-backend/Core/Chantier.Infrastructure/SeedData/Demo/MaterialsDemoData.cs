using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Materials;

namespace Chantier.Infrastructure.SeedData.Demo;

/// <summary>
/// Jeu de donnees de demonstration « demandes de materiaux et livraisons » (US-MAT-016) : exactement la section « Donnees de test » de
/// <c>docs/metier/demandes-materiaux-livraisons.md</c> : 13 produits, 5 fournisseurs, 12 demandes et 10 livraisons sur l'Ecole UV18, 1 demande sur les 40 logements.
/// Tout est <b>fictif</b> (fournisseurs, telephones, prix, numeros de bon de livraison et de commande) : aucune donnee reelle. Les prix sont des donnees commerciales :
/// ils ne sortent que par les roles « prix » (ADR 0012), jamais d'un jeton de chef de chantier ou de chef d'equipe.
/// </summary>
public static class MaterialsDemoData
{
    public enum DemoOutcome
    {
        /// <summary>Reste « Demandee ».</summary>
        Requested,

        /// <summary>Validee par le conducteur, puis commandee, livree... selon <see cref="DemoRequest.Order"/> et les livraisons.</summary>
        Approved,

        Rejected,
        Cancelled,
    }

    public sealed record DemoProduct(
        string Key,
        string NameFr,
        string? NameAr,
        ProductCategory Category,
        IReadOnlyList<MeasureUnit> Units,
        MeasureUnit DefaultUnit,
        decimal? BagMassKg);

    /// <param name="Phone">Numero fictif <c>0550 00 00 2x</c> : jamais un vrai numero.</param>
    public sealed record DemoSupplier(string Key, string Name, string Phone, IReadOnlyList<string> ProductKeys);

    /// <param name="Price">Prix unitaire hors taxes par unite de commande, en DZD (fictif).</param>
    public sealed record DemoOrder(string SupplierKey, DateOnly OrderDate, DateOnly ExpectedDelivery, decimal Price, string PurchaseOrderNumber);

    public sealed record DemoRequest(
        string ProductKey,
        decimal Quantity,
        MeasureUnit Unit,
        ZoneInput? Zone,
        DateOnly NeededBy,
        Priority Priority,
        DemoOutcome Outcome,
        string? ReasonCode = null,
        DemoOrder? Order = null,
        bool Receive = false);

    /// <param name="RequestNumber">Rang de la demande dans le chantier (5 = DEM-005) ; <c>null</c> : livraison non rattachee.</param>
    public sealed record DemoDelivery(
        int? RequestNumber,
        string ProductKey,
        decimal Quantity,
        MeasureUnit Unit,
        DateOnly Date,
        string SupplierKey,
        string? NoteNumber,
        bool WithPhoto = false);

    public sealed record DemoSiteMaterials(string SiteCode, IReadOnlyList<DemoRequest> Requests, IReadOnlyList<DemoDelivery> Deliveries);

    private const string Cement = "ciment";
    private const string Monocouche = "monocouche";
    private const string Brick8 = "brique8";
    private const string Brick12 = "brique12";
    private const string Sand = "sable";
    private const string Gravel = "gravier";
    private const string Admixture = "adjuvant";
    private const string TieWire = "fil";
    private const string Steel8 = "ha8";
    private const string Steel10 = "ha10";
    private const string Steel12 = "ha12";
    private const string Steel14 = "ha14";
    private const string Steel16 = "ha16";

    public const string Sigma = "sigma";
    public const string Delta = "delta";
    public const string Epsilon = "epsilon";
    public const string Zeta = "zeta";
    public const string Eta = "eta";

    /// <summary>Catalogue de 13 produits (P-01 a P-13). Les noms arabes ne portent que le vocabulaire releve du tableau de l'US (H-MAT-24) : le reste s'affiche en francais.</summary>
    public static IReadOnlyList<DemoProduct> Products { get; } =
    [
        new(Cement, "Ciment CPJ 42,5", "إسمنت CPJ 42,5", ProductCategory.Binders, [MeasureUnit.Bag, MeasureUnit.Tonne, MeasureUnit.Kilogram], MeasureUnit.Bag, 50m),
        new(Steel8, "Rond à béton HA Ø8", "حديد التسليح HA Ø8", ProductCategory.Steel, [MeasureUnit.Tonne, MeasureUnit.Kilogram], MeasureUnit.Tonne, null),
        new(Steel10, "Rond à béton HA Ø10", "حديد التسليح HA Ø10", ProductCategory.Steel, [MeasureUnit.Tonne, MeasureUnit.Kilogram], MeasureUnit.Tonne, null),
        new(Steel12, "Rond à béton HA Ø12", "حديد التسليح HA Ø12", ProductCategory.Steel, [MeasureUnit.Tonne, MeasureUnit.Kilogram], MeasureUnit.Tonne, null),
        new(Steel14, "Rond à béton HA Ø14", "حديد التسليح HA Ø14", ProductCategory.Steel, [MeasureUnit.Tonne, MeasureUnit.Kilogram], MeasureUnit.Tonne, null),
        new(Steel16, "Rond à béton HA Ø16", "حديد التسليح HA Ø16", ProductCategory.Steel, [MeasureUnit.Tonne, MeasureUnit.Kilogram], MeasureUnit.Tonne, null),
        new(Brick8, "Brique creuse 8 trous", "آجر مجوف 8 ثقوب", ProductCategory.Masonry, [MeasureUnit.Piece], MeasureUnit.Piece, null),
        new(Brick12, "Brique creuse 12 trous", "آجر مجوف 12 ثقبًا", ProductCategory.Masonry, [MeasureUnit.Piece], MeasureUnit.Piece, null),
        new(Sand, "Sable de maçonnerie", "رمل", ProductCategory.Aggregates, [MeasureUnit.CubicMeter, MeasureUnit.Tonne], MeasureUnit.CubicMeter, null),
        new(Gravel, "Gravier 8/15", "حصى 8/15", ProductCategory.Aggregates, [MeasureUnit.CubicMeter, MeasureUnit.Tonne], MeasureUnit.CubicMeter, null),
        new(Admixture, "Adjuvant plastifiant", "مادة مضافة", ProductCategory.Admixtures, [MeasureUnit.Liter], MeasureUnit.Liter, null),
        new(Monocouche, "Mortier monocouche", null, ProductCategory.FinishingWorks, [MeasureUnit.Bag, MeasureUnit.Tonne, MeasureUnit.Kilogram], MeasureUnit.Bag, 25m),
        new(TieWire, "Fil d'attache", null, ProductCategory.Steel, [MeasureUnit.Kilogram], MeasureUnit.Kilogram, null),
    ];

    /// <summary>Les 5 fournisseurs fictifs (F-01 a F-05), telephones fictifs <c>0550 00 00 21</c> a <c>25</c>.</summary>
    public static IReadOnlyList<DemoSupplier> Suppliers { get; } =
    [
        new(Sigma, "Cimenterie Sigma (fictive)", "0550 00 00 21", [Cement, Monocouche]),
        new(Delta, "Aciers Delta (fictifs)", "0550 00 00 22", [Steel8, Steel10, Steel12, Steel14, Steel16, TieWire]),
        new(Epsilon, "Briqueterie Epsilon (fictive)", "0550 00 00 23", [Brick8, Brick12]),
        new(Zeta, "Sablière Zêta (fictive)", "0550 00 00 24", [Sand, Gravel]),
        new(Eta, "Adjuvants Êta (fictifs)", "0550 00 00 25", [Admixture]),
    ];

    public static IReadOnlyList<DemoSiteMaterials> Sites { get; } = [School(), Housing()];

    private static DemoSiteMaterials School()
    {
        var block1Ground = Zone("Bloc 01", 0.00m);
        var block1Level1 = Zone("Bloc 01", 3.40m);
        var block1Level2 = Zone("Bloc 01", 6.80m);
        var block1Level3 = Zone("Bloc 01", 10.20m);
        var canteen = Zone("Bloc 02", 0.00m, RoomType.Canteen);
        var refectory = Zone("Bloc 02", 0.00m, RoomType.Refectory);
        var canteenFacade = Zone("Bloc 02", null, RoomType.Other, "Façade cantine");

        // Ciment CPJ 42,5 a 780,00 DZD le sac (50 kg) ; rond HA a 128 000,00 DZD la tonne.
        DemoOrder Cement780(DateOnly ordered, DateOnly expected, string purchaseOrder) => new(Sigma, ordered, expected, 780.00m, purchaseOrder);

        DemoRequest[] requests =
        [
            // DEM-001 a DEM-004 : commandees, livrees puis receptionnees.
            new(Cement, 800, MeasureUnit.Bag, block1Ground, Day(2026, 7, 18), Priority.Urgent, DemoOutcome.Approved, Order: Cement780(Day(2026, 7, 10), Day(2026, 7, 18), "BC-UV18-001"), Receive: true),
            new(Cement, 400, MeasureUnit.Bag, block1Level1, Day(2026, 8, 19), Priority.Normal, DemoOutcome.Approved, Order: Cement780(Day(2026, 8, 10), Day(2026, 8, 19), "BC-UV18-002"), Receive: true),
            new(Cement, 200, MeasureUnit.Bag, block1Level2, Day(2026, 9, 21), Priority.Normal, DemoOutcome.Approved, Order: Cement780(Day(2026, 9, 10), Day(2026, 9, 21), "BC-UV18-003"), Receive: true),
            new(Cement, 200, MeasureUnit.Bag, block1Level3, Day(2026, 10, 21), Priority.Normal, DemoOutcome.Approved, Order: Cement780(Day(2026, 10, 12), Day(2026, 10, 21), "BC-UV18-004"), Receive: true),

            // DEM-005 : livree en trois camions, a receptionner.
            new(Cement, 600, MeasureUnit.Bag, canteen, Day(2026, 11, 4), Priority.Normal, DemoOutcome.Approved, Order: Cement780(Day(2026, 10, 28), Day(2026, 11, 4), "BC-UV18-005")),

            // DEM-006 : a valider.
            new(Steel12, 3.5m, MeasureUnit.Tonne, block1Level3, Day(2026, 12, 3), Priority.Urgent, DemoOutcome.Requested),

            // DEM-007 : validee, pas encore commandee.
            new(Brick8, 12_000, MeasureUnit.Piece, canteen, Day(2026, 12, 10), Priority.Normal, DemoOutcome.Approved),

            // DEM-008 : refusee.
            new(Sand, 24, MeasureUnit.CubicMeter, refectory, Day(2026, 11, 30), Priority.Normal, DemoOutcome.Rejected, ReasonCode: "StockSufficient"),

            // DEM-009 : commandee, livraison prevue le 26/11/2026, bloquante.
            new(Cement, 300, MeasureUnit.Bag, block1Level3, Day(2026, 11, 26), Priority.Blocking, DemoOutcome.Approved, Order: Cement780(Day(2026, 11, 23), Day(2026, 11, 26), "BC-UV18-009")),

            // DEM-010 : annulee.
            new(Admixture, 200, MeasureUnit.Liter, block1Level3, Day(2026, 11, 27), Priority.Normal, DemoOutcome.Cancelled, ReasonCode: "EntryError"),

            // DEM-011 : livree partiellement (1,2 T sur 2 T), en retard : c'est le cas a montrer dans la vue « en retard ».
            new(Steel10, 2, MeasureUnit.Tonne, block1Level3, Day(2026, 11, 19), Priority.Normal, DemoOutcome.Approved, Order: new(Delta, Day(2026, 11, 12), Day(2026, 11, 19), 128_000.00m, "BC-UV18-011")),

            // DEM-012 : a valider (sac de 25 kg), zone sans cote.
            new(Monocouche, 40, MeasureUnit.Bag, canteenFacade, Day(2026, 12, 6), Priority.Normal, DemoOutcome.Requested),
        ];

        // 8 livraisons de ciment = 110 T = 2 200 sacs (20 + 20 + 20 + 10 + 10 + 10 + 10 + 10 T), exactement les livraisons acceptees de donnees-test.md.
        DemoDelivery[] deliveries =
        [
            new(1, Cement, 20, MeasureUnit.Tonne, Day(2026, 7, 18), Sigma, "BL-SIG-0412"),
            new(1, Cement, 20, MeasureUnit.Tonne, Day(2026, 7, 21), Sigma, "BL-SIG-0419"),
            new(2, Cement, 20, MeasureUnit.Tonne, Day(2026, 8, 19), Sigma, "BL-SIG-0455"),
            new(3, Cement, 10, MeasureUnit.Tonne, Day(2026, 9, 21), Sigma, "BL-SIG-0502"),
            new(4, Cement, 10, MeasureUnit.Tonne, Day(2026, 10, 21), Sigma, "BL-SIG-0537"),
            new(5, Cement, 10, MeasureUnit.Tonne, Day(2026, 11, 4), Sigma, "BL-SIG-0561", WithPhoto: true),
            new(5, Cement, 10, MeasureUnit.Tonne, Day(2026, 11, 5), Sigma, "BL-SIG-0563"),
            new(5, Cement, 10, MeasureUnit.Tonne, Day(2026, 11, 14), Sigma, "BL-SIG-0577"),
            new(11, Steel10, 1.2m, MeasureUnit.Tonne, Day(2026, 11, 19), Delta, "BL-DEL-0208"),

            // LIV-010 : non rattachee, sans n° de bon ni photo (badge « BL manquant »).
            new(null, Gravel, 12, MeasureUnit.CubicMeter, Day(2026, 11, 22), Zeta, null),
        ];

        return new DemoSiteMaterials(DemoData.SchoolCode, requests, deliveries);
    }

    private static DemoSiteMaterials Housing()
    {
        // DEM-001 de ce chantier : meme numero que celui de l'ecole (la numerotation est par chantier), invisible de chef.dev.
        DemoRequest[] requests =
        [
            new(Brick12, 8_000, MeasureUnit.Piece, Zone("Bloc A", 0.00m), Day(2026, 12, 12), Priority.Normal, DemoOutcome.Requested),
        ];

        return new DemoSiteMaterials(DemoData.HousingCode, requests, []);
    }

    private static DateOnly Day(int year, int month, int day) => new(year, month, day);

    private static ZoneInput Zone(string block, decimal? elevation, RoomType? roomType = null, string? label = null)
        => new(block, elevation, roomType, null, label);
}
