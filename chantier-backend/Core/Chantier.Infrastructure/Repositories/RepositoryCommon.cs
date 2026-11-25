using Ardalis.Specification.EntityFrameworkCore;
using Chantier.Infrastructure.Persistence;

namespace Chantier.Infrastructure.Repositories;

/// <summary>
/// Implementation EF Core de <c>IRepositoryBase&lt;T&gt;</c> (Ardalis.Specification), liee a <see cref="ApplicationDbContext"/>.
/// Toute la logique de requete vit dans des <c>Specification&lt;T&gt;</c> (<c>Chantier.Core.Specifications</c>),
/// jamais en <c>IQueryable</c> brut dans les services.
/// </summary>
public class RepositoryCommon<T>(ApplicationDbContext context) : RepositoryBase<T>(context) where T : class;
