using System.Security.Cryptography;
using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Exceptions;
using Chantier.Core.Materials;
using Chantier.Core.Sites;
using Chantier.Infrastructure.Imaging;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.SeedData.Demo;

/// <summary>
/// Demonstration « demandes de materiaux et livraisons » (US-MAT-016), apres <see cref="DemoDataSeeder"/> : meme garde (<c>Seed:Demo = true</c> <b>et</b> Development,
/// controlee par <see cref="DatabaseInitializer"/>). <b>Amorcage direct des entites</b> : aucun contexte d'acteur simule, aucun service qui exige un droit ; les ecritures
/// sont faites hors requete, auteur = <see cref="SystemActor"/> (« amorcage »). Les <b>regles</b> restent celles du domaine : numeros par <see cref="ISiteNumbering"/>,
/// transitions des methodes des entites, historique par <see cref="IRequestEventWriter"/>, statuts, recus et montants par le seul <see cref="IRequestRecalculator"/>.
/// <para>
/// <b>Relancable et sans ecrasement</b> : un produit ou un fournisseur existant (meme nom normalise) est reutilise tel quel ; les demandes et livraisons d'un chantier ne sont
/// creees que si ce chantier n'en a aucune (corbeille comprise) : le jeu est ecrit en une seule transaction, donc entierement ou pas du tout, et la numerotation reste
/// DEM-001... sans trou. Rien d'existant n'est modifie ni supprime. Un jeu qui ne peut plus s'appliquer (produit desactive depuis...) est ignore avec un avertissement,
/// il ne bloque pas le demarrage.
/// </para>
/// </summary>
public sealed class MaterialsDemoSeeder(
    ApplicationDbContext db,
    ISiteNumbering numbering,
    IRequestEventWriter events,
    IRequestRecalculator recalculator,
    IPhotoStorage storage,
    IOptions<MaterialsOptions> options,
    TimeProvider time,
    ILogger<MaterialsDemoSeeder> logger)
{
    private static readonly RequestActionContext Seeding = new(MaterialEventSource.System);

    private sealed record SiteTotals(int Requests, int Deliveries, bool Skipped = false);

    public async Task SeedAsync(CancellationToken cancellationToken = default)
    {
        var (products, suppliers, productsCreated, suppliersCreated) = await EnsureCatalogAsync(cancellationToken);

        var requests = 0;
        var deliveries = 0;
        var skipped = 0;
        foreach (var plan in MaterialsDemoData.Sites)
        {
            var siteId = await db.Sites.Where(site => site.Code == plan.SiteCode).Select(site => (Guid?)site.Id).FirstOrDefaultAsync(cancellationToken);
            if (siteId is null)
            {
                continue;
            }

            var keys = new List<string>();
            try
            {
                var totals = await DbTransactions.RunAsync(db, () => SeedSiteAsync(siteId.Value, plan, products, suppliers, keys, cancellationToken), cancellationToken);
                requests += totals.Requests;
                deliveries += totals.Deliveries;
                skipped += totals.Skipped ? 1 : 0;
            }
            catch (DomainException exception)
            {
                // Une regle du domaine ne s'applique plus (produit desactive, unite retiree...) : rien n'est ecrit pour ce chantier, le demarrage continue.
                db.ChangeTracker.Clear();
                await DeleteFilesAsync(keys);
                logger.LogWarning("Données de démonstration des matériaux ignorées pour un chantier : règle {Code} refusée.", exception.Code);
            }
            catch
            {
                await DeleteFilesAsync(keys);
                throw;
            }
        }

        logger.LogInformation(
            "Données de démonstration des matériaux : {Products} produits, {Suppliers} fournisseurs, {Requests} demandes, {Deliveries} livraisons ajoutés (le reste existait déjà)",
            productsCreated, suppliersCreated, requests, deliveries);

        if (skipped > 0)
        {
            // Pas une erreur : le jeu n'est ecrit que sur un chantier vide (jamais de melange avec des saisies reelles ou d'essai). Pour le recharger : base neuve (scripts/dev.ps1 -Reset).
            logger.LogInformation("Données de démonstration des matériaux : {Skipped} chantier(s) contiennent déjà des demandes ou des livraisons, laissés tels quels.", skipped);
        }
    }

    // --- Catalogue (global) ---

    private async Task<(Dictionary<string, Product> Products, Dictionary<string, Supplier> Suppliers, int ProductsCreated, int SuppliersCreated)> EnsureCatalogAsync(
        CancellationToken cancellationToken)
    {
        var productNames = MaterialsDemoData.Products.ToDictionary(product => product.Key, product => NameNormalizer.Normalize(product.NameFr));
        var known = await db.Products.IgnoreQueryFilters([QueryFilterNames.SoftDelete])
            .Where(product => productNames.Values.Contains(product.NormalizedNameFr))
            .ToListAsync(cancellationToken);

        var products = new Dictionary<string, Product>(StringComparer.Ordinal);
        var productsCreated = 0;
        foreach (var demo in MaterialsDemoData.Products)
        {
            var product = known.FirstOrDefault(candidate => candidate.NormalizedNameFr == productNames[demo.Key]);
            if (product is null)
            {
                product = Product.Create(new ProductInput(demo.NameFr, demo.NameAr, demo.Category, demo.Units, demo.DefaultUnit, demo.BagMassKg));
                db.Products.Add(product);
                productsCreated++;
            }

            products[demo.Key] = product;
        }

        var supplierNames = MaterialsDemoData.Suppliers.ToDictionary(supplier => supplier.Key, supplier => NameNormalizer.Normalize(supplier.Name));
        var knownSuppliers = await db.Suppliers.IgnoreQueryFilters([QueryFilterNames.SoftDelete])
            .Where(supplier => supplierNames.Values.Contains(supplier.NormalizedName))
            .ToListAsync(cancellationToken);

        var suppliers = new Dictionary<string, Supplier>(StringComparer.Ordinal);
        var suppliersCreated = 0;
        foreach (var demo in MaterialsDemoData.Suppliers)
        {
            var supplier = knownSuppliers.FirstOrDefault(candidate => candidate.NormalizedName == supplierNames[demo.Key]);
            if (supplier is null)
            {
                var productIds = demo.ProductKeys.Select(key => products[key].Id).ToList();
                supplier = Supplier.Create(new SupplierInput(demo.Name, demo.Phone, productIds));
                db.Suppliers.Add(supplier);
                suppliersCreated++;
            }

            suppliers[demo.Key] = supplier;
        }

        await db.SaveChangesAsync(cancellationToken);
        return (products, suppliers, productsCreated, suppliersCreated);
    }

    // --- Un chantier ---

    private async Task<SiteTotals> SeedSiteAsync(
        Guid siteId,
        MaterialsDemoData.DemoSiteMaterials plan,
        Dictionary<string, Product> products,
        Dictionary<string, Supplier> suppliers,
        List<string> storedFiles,
        CancellationToken cancellationToken)
    {
        // Deux hotes qui demarrent ensemble : le second attend, puis constate que le premier a fini.
        await AppLocks.AcquireAsync(db, $"demo-materials:{siteId:N}", cancellationToken);

        var ignoreDeleted = new[] { QueryFilterNames.SoftDelete };
        var hasMaterials = await db.MaterialRequests.IgnoreQueryFilters(ignoreDeleted).AnyAsync(request => request.SiteId == siteId, cancellationToken)
            || await db.MaterialOrders.IgnoreQueryFilters(ignoreDeleted).AnyAsync(order => order.SiteId == siteId, cancellationToken)
            || await db.Deliveries.IgnoreQueryFilters(ignoreDeleted).AnyAsync(delivery => delivery.SiteId == siteId, cancellationToken);
        if (hasMaterials)
        {
            return new SiteTotals(0, 0, Skipped: true);
        }

        var zones = await LoadZonesAsync(siteId, cancellationToken);

        // Demandes dans l'ordre du tableau : DEM-001, DEM-002...
        var requests = new List<MaterialRequest>();
        var orders = new Dictionary<Guid, MaterialOrder>();
        foreach (var demo in plan.Requests)
        {
            var request = await CreateRequestAsync(siteId, demo, products[demo.ProductKey], zones, cancellationToken);
            requests.Add(request);
            if (demo.Order is { } demoOrder)
            {
                orders[request.Id] = await PlaceOrderAsync(request, demoOrder, suppliers[demoOrder.SupplierKey], cancellationToken);
            }
        }

        // Livraisons dans l'ordre du tableau : LIV-001, LIV-002... (statuts, recus et montants recalcules a chaque livraison).
        foreach (var demo in plan.Deliveries)
        {
            var request = demo.RequestNumber is { } rank ? requests[rank - 1] : null;
            await CreateDeliveryAsync(siteId, demo, request, request is null ? null : orders.GetValueOrDefault(request.Id), products[demo.ProductKey], suppliers[demo.SupplierKey], storedFiles, cancellationToken);
        }

        // Receptions apres les livraisons (une demande ne se receptionne qu'une fois livree).
        for (var index = 0; index < plan.Requests.Count; index++)
        {
            if (plan.Requests[index].Receive)
            {
                await ReceiveAsync(requests[index], cancellationToken);
            }
        }

        return new SiteTotals(requests.Count, plan.Deliveries.Count);
    }

    private async Task<Dictionary<ZoneInput, Guid>> LoadZonesAsync(Guid siteId, CancellationToken cancellationToken)
    {
        var rows = await db.Zones.Where(zone => zone.SiteId == siteId)
            .Select(zone => new { zone.Id, zone.Block, zone.Elevation, zone.RoomType, zone.RoomNumber, zone.RoomLabel })
            .ToListAsync(cancellationToken);
        return rows
            .GroupBy(zone => new ZoneInput(zone.Block, zone.Elevation, zone.RoomType, zone.RoomNumber, zone.RoomLabel))
            .ToDictionary(group => group.Key, group => group.First().Id);
    }

    private async Task<MaterialRequest> CreateRequestAsync(
        Guid siteId,
        MaterialsDemoData.DemoRequest demo,
        Product product,
        Dictionary<ZoneInput, Guid> zones,
        CancellationToken cancellationToken)
    {
        // Memes regles que la saisie : produit actif, unite autorisee, quantite valide (entiere pour sac et unite).
        Guid? zoneId = demo.Zone is { } zone && zones.TryGetValue(zone, out var id) ? id : null;
        var fields = RequestRules.Validate(
            new RequestFields(product.Id, null, demo.Quantity, demo.Unit, zoneId, demo.NeededBy, demo.Priority, null), product, options.Value);

        var number = await numbering.NextAsync(siteId, NumberPrefixes.Request, cancellationToken);
        var request = MaterialRequest.Create(siteId, number, null, null, fields, null);
        db.MaterialRequests.Add(request);
        events.Add(request, MaterialEventType.Created, Seeding, toStatus: RequestStatus.Requested);

        var from = request.Status;
        switch (demo.Outcome)
        {
            case MaterialsDemoData.DemoOutcome.Approved:
                request.Approve(null, out _);
                events.Add(request, MaterialEventType.Approved, Seeding, from, request.Status);
                break;

            case MaterialsDemoData.DemoOutcome.Rejected:
                request.Reject(demo.ReasonCode!, null);
                events.Add(request, MaterialEventType.Rejected, Seeding, from, request.Status, demo.ReasonCode);
                break;

            case MaterialsDemoData.DemoOutcome.Cancelled:
                request.Cancel(demo.ReasonCode!, null);
                events.Add(request, MaterialEventType.Cancelled, Seeding, from, request.Status, demo.ReasonCode);
                break;
        }

        await db.SaveChangesAsync(cancellationToken);
        return request;
    }

    private async Task<MaterialOrder> PlaceOrderAsync(MaterialRequest request, MaterialsDemoData.DemoOrder demo, Supplier supplier, CancellationToken cancellationToken)
    {
        var fields = new ValidatedOrderFields(supplier.Id, demo.OrderDate, demo.ExpectedDelivery, demo.Price, demo.PurchaseOrderNumber, null);
        var order = MaterialOrder.Create(request.SiteId, request.Id, null, fields, request.Ordered);
        db.MaterialOrders.Add(order);

        var from = request.Status;
        request.PlaceOrder();
        events.Add(request, MaterialEventType.Ordered, Seeding, from, request.Status, changes: [new FieldChange(OrderFieldNames.SupplierId, null, supplier.Id.ToString())]);
        await db.SaveChangesAsync(cancellationToken);

        await recalculator.RecomputeAsync(request, RecalculationTriggers.OrderPlaced, null, Seeding, cancellationToken);
        await db.SaveChangesAsync(cancellationToken);
        return order;
    }

    private async Task CreateDeliveryAsync(
        Guid siteId,
        MaterialsDemoData.DemoDelivery demo,
        MaterialRequest? request,
        MaterialOrder? order,
        Product product,
        Supplier supplier,
        List<string> storedFiles,
        CancellationToken cancellationToken)
    {
        var quantity = new Quantity(demo.Quantity, demo.Unit);
        QuantityRules.Validate(quantity.Value, quantity.Unit);
        var fields = new ValidatedDeliveryFields(supplier.Id, null, product.Id, null, quantity, demo.Date, demo.NoteNumber, Conformity.Conform, null, null);

        decimal? converted = null;
        decimal? amount = null;
        if (request is not null)
        {
            converted = UnitConverter.Convert(quantity, request.Unit, product.BagMassKg).Value;
            amount = order?.UnitPrice is { } price ? Money.Amount(converted.Value, price) : null;
        }

        var number = await numbering.NextAsync(siteId, NumberPrefixes.Delivery, cancellationToken);
        var delivery = Delivery.Create(siteId, number, null, null, fields, request?.Id, UnattachedReason.NoRequestChosen, null);
        delivery.ApplyComputed(converted, amount);
        db.Deliveries.Add(delivery);

        events.Add(delivery, MaterialEventType.DeliveryRegistered, Seeding, request is null ? nameof(UnattachedReason.NoRequestChosen) : null, request?.Number);
        if (request is not null)
        {
            events.Add(request, MaterialEventType.DeliveryRegistered, Seeding, note: number);
        }

        await db.SaveChangesAsync(cancellationToken);

        if (demo.WithPhoto)
        {
            await AddPhotoAsync(siteId, delivery, storedFiles, cancellationToken);
        }

        if (request is not null)
        {
            await recalculator.RecomputeAsync(request, RecalculationTriggers.DeliveryRegistered, number, Seeding, cancellationToken);
            await db.SaveChangesAsync(cancellationToken);
        }
    }

    /// <summary>Photo fictive du bon : memes etapes que l'envoi (metadonnees, retrait des metadonnees EXIF, stockage hors du web, marquage « envoyee »).</summary>
    private async Task AddPhotoAsync(Guid siteId, Delivery delivery, List<string> storedFiles, CancellationToken cancellationToken)
    {
        var bytes = DemoDeliveryNoteImage.Bytes();
        var takenAt = new DateTimeOffset(delivery.DeliveryDate.ToDateTime(new TimeOnly(9, 30)), TimeSpan.FromHours(1));
        var photo = Photo.Create(siteId, delivery.Id, Guid.CreateVersion7(), null, takenAt, bytes.Length, Convert.ToHexStringLower(SHA256.HashData(bytes)));
        db.Photos.Add(photo);
        delivery.AddPhoto();
        events.Add(delivery, MaterialEventType.PhotoAdded, Seeding);
        await db.SaveChangesAsync(cancellationToken);

        string key;
        long storedBytes;
        await using (var staged = await storage.StageAsync(cancellationToken))
        {
            await using var input = new MemoryStream(bytes);
            storedBytes = await JpegMetadataStripper.StripAsync(input, staged.Stream, cancellationToken);
            key = await storage.CommitAsync(staged, siteId, time.GetUtcNow(), cancellationToken);
        }

        storedFiles.Add(key);
        photo.MarkUploaded(key, storedBytes, time.GetUtcNow());
        await db.SaveChangesAsync(cancellationToken);
    }

    private async Task ReceiveAsync(MaterialRequest request, CancellationToken cancellationToken)
    {
        var from = request.Status;
        request.Receive();
        events.Add(request, MaterialEventType.Received, Seeding, from, request.Status);
        await db.SaveChangesAsync(cancellationToken);
    }

    private async Task DeleteFilesAsync(IEnumerable<string> keys)
    {
        foreach (var key in keys)
        {
            await storage.DeleteAsync(key, CancellationToken.None);
        }
    }
}
