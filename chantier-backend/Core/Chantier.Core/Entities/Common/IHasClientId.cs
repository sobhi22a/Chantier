namespace Chantier.Core.Entities.Common;

/// <summary>
/// Entite creable hors ligne : le telephone fournit un <see cref="ClientId"/> (GUID) et le serveur est idempotent
/// (index unique (chantier, <c>ClientId</c>)). <see cref="ClientCreatedAt"/> est le « saisi le » du telephone :
/// une information conservee a part, jamais utilisee pour trier ni decider (CT-6).
/// </summary>
public interface IHasClientId
{
    Guid? ClientId { get; }

    DateTimeOffset? ClientCreatedAt { get; }
}
