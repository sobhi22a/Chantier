using System.Text.Json;
using Chantier.Core.Entities.Reference;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Chantier.Infrastructure.Persistence;

/// <summary>
/// Charge wilayas et communes depuis <c>SeedData/Reference/*.json</c> : des <b>donnees</b> modifiables, pas du code (H-14).
/// Idempotent : n'ajoute que les lignes absentes, ne modifie ni ne supprime jamais l'existant.
/// La liste officielle (58 ou 69 wilayas) reste a confirmer sur le Journal officiel (Q-11).
/// </summary>
public sealed class ReferenceDataSeeder(ApplicationDbContext db, ILogger<ReferenceDataSeeder> logger)
{
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };

    public static string DefaultDirectory => Path.Combine(AppContext.BaseDirectory, "SeedData", "Reference");

    public async Task SeedAsync(string? directory = null, CancellationToken cancellationToken = default)
    {
        directory ??= DefaultDirectory;

        var wilayas = await ReadAsync<WilayaRecord>(Path.Combine(directory, "wilayas.json"), cancellationToken);
        var communes = await ReadAsync<CommuneRecord>(Path.Combine(directory, "communes.json"), cancellationToken);

        var knownWilayas = await db.Wilayas.Select(wilaya => wilaya.Code).ToListAsync(cancellationToken);
        var wilayaCodes = knownWilayas.ToHashSet(StringComparer.Ordinal);
        foreach (var record in wilayas.Where(record => wilayaCodes.Add(record.Code)))
        {
            db.Wilayas.Add(new Wilaya { Code = record.Code, NameFr = record.NameFr, NameAr = record.NameAr });
        }

        await db.SaveChangesAsync(cancellationToken);

        var knownCommunes = (await db.Communes.Select(commune => new { commune.WilayaCode, commune.NameFr }).ToListAsync(cancellationToken))
            .Select(commune => (commune.WilayaCode, commune.NameFr.ToLowerInvariant()))
            .ToHashSet();
        var added = 0;
        foreach (var record in communes)
        {
            if (!wilayaCodes.Contains(record.WilayaCode) || !knownCommunes.Add((record.WilayaCode, record.NameFr.ToLowerInvariant())))
            {
                continue;
            }

            db.Communes.Add(new Commune { WilayaCode = record.WilayaCode, NameFr = record.NameFr, NameAr = record.NameAr });
            added++;
        }

        await db.SaveChangesAsync(cancellationToken);
        logger.LogInformation("Référentiel géographique : {Wilayas} wilayas et {Communes} communes dans les fichiers, {Added} communes ajoutées", wilayas.Count, communes.Count, added);
    }

    private async Task<List<T>> ReadAsync<T>(string path, CancellationToken cancellationToken)
    {
        if (!File.Exists(path))
        {
            logger.LogWarning("Fichier de référence introuvable : {File}", Path.GetFileName(path));
            return [];
        }

        await using var stream = File.OpenRead(path);
        return await JsonSerializer.DeserializeAsync<List<T>>(stream, JsonOptions, cancellationToken) ?? [];
    }

    private sealed record WilayaRecord(string Code, string NameFr, string NameAr);

    private sealed record CommuneRecord(string WilayaCode, string NameFr, string NameAr);
}
