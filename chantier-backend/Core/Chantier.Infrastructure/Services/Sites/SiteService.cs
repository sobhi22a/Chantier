using Ardalis.Specification;
using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Common;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.Core.Paging;
using Chantier.Core.Sites;
using Chantier.Core.Specifications.Sites;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Services.Sites;

/// <summary>
/// Chantiers : liste filtree par affectation, creation, modification avec version, archivage tracable (rien n'est supprime).
/// Le code est immuable ; le montant du marche n'est renvoye qu'avec <c>ContractAmount.View</c> (CT-20).
/// Les controles d'affectation sont faits avant (<c>[SiteScoped]</c>) : ici, un identifiant non visible est deja un 404.
/// </summary>
public sealed class SiteService(
    IRepositoryBase<Site> sites,
    ApplicationDbContext db,
    ICurrentUser currentUser,
    IUserPermissions permissions,
    IUserDirectory directory,
    TimeProvider time) : ISiteService
{
    public async Task<PagedResult<SiteResponse>> ListAsync(SiteListQuery query, CancellationToken cancellationToken = default)
    {
        var errors = new Core.Validation.ErrorCollector();
        if (query.Page < 1)
        {
            errors.Add("page", "La page doit être supérieure ou égale à 1.");
        }

        if (query.PageSize is < 1 or > PagingRules.MaxPageSize)
        {
            errors.Add("pageSize", $"La taille de page doit être comprise entre 1 et {PagingRules.MaxPageSize}.");
        }

        var sort = string.IsNullOrWhiteSpace(query.Sort) ? "name" : query.Sort;
        if (!SitesVisibleToUserSpecification.SortValues.Contains(sort))
        {
            errors.Add("sort", "Tri inconnu.");
        }

        errors.ThrowIfAny();

        var userId = currentUser.Id ?? throw new NotFoundException();
        var seeAll = await permissions.HasAsync(Permissions.AllSitesView, cancellationToken);

        var specification = new SitesVisibleToUserSpecification(
            userId, seeAll, query.Search, query.Type, query.Wilaya, query.IncludeArchived, sort, query.Page, query.PageSize);
        var total = await sites.CountAsync(specification, cancellationToken);
        var rows = await sites.ListAsync(specification, cancellationToken);

        var items = await ToResponsesAsync(rows, cancellationToken);
        return new PagedResult<SiteResponse>(items, query.Page, query.PageSize, total);
    }

    public async Task<SiteResponse> GetAsync(Guid siteId, CancellationToken cancellationToken = default)
        => await ToResponseAsync(await LoadAsync(siteId, cancellationToken), cancellationToken);

    public async Task<SiteCodeSuggestion> SuggestCodeAsync(SiteType type, string name, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            throw new Core.Exceptions.ValidationException("name", "Le champ est obligatoire.");
        }

        var baseCode = SiteCodeGenerator.Build(type, name);
        var taken = (await sites.ListAsync(new SiteCodesStartingWithSpecification(baseCode), cancellationToken))
            .Select(site => site.Code)
            .ToHashSet(StringComparer.Ordinal);

        return new SiteCodeSuggestion(SiteCodeGenerator.MakeUnique(baseCode, taken.Contains));
    }

    public async Task<SiteResponse> CreateAsync(CreateSiteDto dto, CancellationToken cancellationToken = default)
    {
        var site = Site.Create(dto.Code, dto.Data);

        if (await sites.AnyAsync(new SiteByCodeSpecification(site.Code), cancellationToken))
        {
            throw CodeAlreadyUsed();
        }

        try
        {
            await sites.AddAsync(site, cancellationToken);
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            // Deux creations simultanees du meme code : l'index unique tranche.
            throw CodeAlreadyUsed();
        }

        return await ToResponseAsync(site, cancellationToken);
    }

    public async Task<SiteResponse> UpdateAsync(Guid siteId, UpdateSiteDto dto, CancellationToken cancellationToken = default)
    {
        var site = await LoadAsync(siteId, cancellationToken);
        await EnsureVersionAsync(site, dto.Version, cancellationToken);
        site.EnsureWritable();
        site.Update(dto.Data);

        try
        {
            await sites.UpdateAsync(site, cancellationToken);
        }
        catch (DbUpdateConcurrencyException)
        {
            // Modifie par quelqu'un d'autre entre la lecture et l'ecriture : on renvoie l'etat courant pour proposer de recharger.
            await db.Entry(site).ReloadAsync(cancellationToken);
            throw new ConflictException(await ToResponseAsync(site, cancellationToken));
        }

        return await ToResponseAsync(site, cancellationToken);
    }

    public async Task<SiteResponse> ArchiveAsync(Guid siteId, CancellationToken cancellationToken = default)
    {
        var site = await LoadAsync(siteId, cancellationToken);
        if (!site.IsArchived)
        {
            site.Archive(currentUser.Id ?? throw new NotFoundException(), time.GetUtcNow());
            await sites.UpdateAsync(site, cancellationToken);
        }

        return await ToResponseAsync(site, cancellationToken);
    }

    public async Task<SiteResponse> RestoreAsync(Guid siteId, CancellationToken cancellationToken = default)
    {
        var site = await LoadAsync(siteId, cancellationToken);
        if (site.IsArchived)
        {
            site.Restore();
            await sites.UpdateAsync(site, cancellationToken);
        }

        return await ToResponseAsync(site, cancellationToken);
    }

    private async Task<Site> LoadAsync(Guid siteId, CancellationToken cancellationToken)
        => await sites.GetByIdAsync(siteId, cancellationToken) ?? throw new NotFoundException();

    private async Task EnsureVersionAsync(Site site, string version, CancellationToken cancellationToken)
    {
        if (!BasicEntity.TryParseVersion(version, out var parsed))
        {
            throw new Core.Exceptions.ValidationException("version", "La version est invalide.");
        }

        if (parsed != site.RowVersion)
        {
            throw new ConflictException(await ToResponseAsync(site, cancellationToken));
        }
    }

    private static DomainRuleException CodeAlreadyUsed()
        => new(ErrorCodes.CodeChantierExistant, "Ce code de chantier existe déjà.");

    private async Task<SiteResponse> ToResponseAsync(Site site, CancellationToken cancellationToken)
        => (await ToResponsesAsync([site], cancellationToken))[0];

    private async Task<List<SiteResponse>> ToResponsesAsync(IReadOnlyCollection<Site> rows, CancellationToken cancellationToken)
    {
        var includeAmount = await permissions.HasAsync(Permissions.ContractAmountView, cancellationToken);
        var names = await directory.GetNamesAsync(rows.SelectMany(SiteResponse.AuditUsers), cancellationToken);
        return rows.Select(site => SiteResponse.From(site, includeAmount, names)).ToList();
    }
}
