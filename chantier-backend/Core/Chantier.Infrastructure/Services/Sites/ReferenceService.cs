using Ardalis.Specification;
using Chantier.Core.Entities.Reference;
using Chantier.Core.Exceptions;
using Chantier.Core.Sites;
using Chantier.Core.Specifications.Sites;
using Microsoft.Extensions.Caching.Memory;

namespace Chantier.Infrastructure.Services.Sites;

/// <summary>Referentiel geographique lu en base (alimente par des fichiers de donnees, H-14) et mis en cache : il ne change presque jamais.</summary>
public sealed class ReferenceService(IRepositoryBase<Wilaya> wilayas, IRepositoryBase<Commune> communes, IMemoryCache cache) : IReferenceService
{
    private static readonly TimeSpan CacheDuration = TimeSpan.FromMinutes(10);

    public async Task<IReadOnlyList<WilayaResponse>> GetWilayasAsync(CancellationToken cancellationToken = default)
        => (await cache.GetOrCreateAsync("reference:wilayas", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheDuration;
            var rows = await wilayas.ListAsync(new WilayasOrderedSpecification(), cancellationToken);
            return rows.Select(wilaya => new WilayaResponse(wilaya.Code, wilaya.NameFr, wilaya.NameAr)).ToList();
        }))!;

    public async Task<IReadOnlyList<CommuneResponse>> GetCommunesAsync(string wilayaCode, CancellationToken cancellationToken = default)
    {
        var code = wilayaCode.Trim();
        if (!await wilayas.AnyAsync(new WilayaByCodeSpecification(code), cancellationToken))
        {
            throw new NotFoundException();
        }

        return (await cache.GetOrCreateAsync($"reference:communes:{code}", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheDuration;
            var rows = await communes.ListAsync(new CommunesByWilayaSpecification(code), cancellationToken);
            return rows.Select(commune => new CommuneResponse(commune.NameFr, commune.NameAr)).ToList();
        }))!;
    }
}
