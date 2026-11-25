using Ardalis.Specification;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Exceptions;
using Chantier.Core.Sites;
using Chantier.Core.Specifications.Sites;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Services.Sites;

/// <summary>
/// Affectations. Immediates et tracees (qui, quand) ; un retrait est une suppression logique. Jamais de telephone ni
/// d'identifiant de connexion dans les reponses (H-17). Affecter « touche » le chantier et ses lignes synchronisees dans la
/// meme transaction (ADR 0009) : le nouvel affecte recoit aussi les lignes anciennes au prochain pull.
/// </summary>
public sealed class SiteMemberService(
    IRepositoryBase<SiteMember> members,
    ApplicationDbContext db,
    IUserDirectory directory,
    ISyncTouch syncTouch) : ISiteMemberService
{
    public async Task<IReadOnlyList<SiteMemberResponse>> ListAsync(Guid siteId, CancellationToken cancellationToken = default)
    {
        var rows = await members.ListAsync(new SiteMembersBySiteSpecification(siteId), cancellationToken);
        var people = await directory.GetNamesAndRolesAsync(rows.Select(member => member.UserId), cancellationToken);

        return rows
            .Where(member => people.ContainsKey(member.UserId))
            .Select(member => new SiteMemberResponse(member.UserId, people[member.UserId].FullName, people[member.UserId].Role, member.CreatedAt))
            .ToList();
    }

    public async Task<AssignmentResult> AssignAsync(Guid siteId, Guid userId, CancellationToken cancellationToken = default)
    {
        var isActive = await directory.IsActiveAsync(userId, cancellationToken) ?? throw new NotFoundException();
        if (!isActive)
        {
            throw new DomainRuleException(ErrorCodes.CompteDesactive, "Ce compte est désactivé : il ne peut pas être affecté.");
        }

        // Affectation et « toucher » dans une seule transaction : le pull ne voit jamais l'un sans l'autre.
        // Le chantier est verrouille en premier (ordre commun a toutes les lectures et ecritures) : les appuis simultanes se mettent en file,
        // le premier cree, les suivants trouvent l'affectation (CA-005.3).
        await using var transaction = await db.Database.BeginTransactionAsync(cancellationToken);
        await syncTouch.LockSiteAsync(siteId, cancellationToken);

        var existing = await members.FirstOrDefaultAsync(new SiteMemberByUserSpecification(siteId, userId), cancellationToken);
        if (existing is not null)
        {
            return new AssignmentResult(await ToResponseAsync(existing, cancellationToken), Created: false);
        }

        var member = SiteMember.Create(siteId, userId);
        try
        {
            await members.AddAsync(member, cancellationToken);
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            // Filet de securite : l'index unique reste l'arbitre final.
            db.Entry(member).State = EntityState.Detached;
            var winner = await members.FirstOrDefaultAsync(new SiteMemberByUserSpecification(siteId, userId), cancellationToken)
                ?? throw new NotFoundException();
            return new AssignmentResult(await ToResponseAsync(winner, cancellationToken), Created: false);
        }

        await syncTouch.TouchLinesAsync(siteId, cancellationToken);
        await transaction.CommitAsync(cancellationToken);

        return new AssignmentResult(await ToResponseAsync(member, cancellationToken), Created: true);
    }

    public async Task RemoveAsync(Guid siteId, Guid userId, CancellationToken cancellationToken = default)
    {
        // Meme verrou que l'affectation : retraits et affectations d'un meme chantier se mettent en file (sinon interblocage avec le « toucher »).
        await using var transaction = await db.Database.BeginTransactionAsync(cancellationToken);
        await syncTouch.LockSiteAsync(siteId, cancellationToken);

        var existing = await members.FirstOrDefaultAsync(new SiteMemberByUserSpecification(siteId, userId), cancellationToken);
        if (existing is not null)
        {
            // Converti en suppression logique par l'intercepteur d'audit : qui et quand sont conserves.
            await members.DeleteAsync(existing, cancellationToken);
        }

        await transaction.CommitAsync(cancellationToken);
    }

    private async Task<SiteMemberResponse> ToResponseAsync(SiteMember member, CancellationToken cancellationToken)
    {
        var people = await directory.GetNamesAndRolesAsync([member.UserId], cancellationToken);
        var (fullName, role) = people.TryGetValue(member.UserId, out var person) ? person : (string.Empty, string.Empty);
        return new SiteMemberResponse(member.UserId, fullName, role, member.CreatedAt);
    }
}
