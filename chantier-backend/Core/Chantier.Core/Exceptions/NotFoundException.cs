namespace Chantier.Core.Exceptions;

/// <summary>
/// Ressource absente <b>ou chantier non affecte</b> : meme exception, meme message, meme code (CA-006.2).
/// Aucun parametre volontairement : rien ne doit permettre de distinguer les deux cas.
/// </summary>
public sealed class NotFoundException : DomainException
{
    public const string DefaultMessage = "La ressource demandée est introuvable.";

    public NotFoundException() : base(ErrorCodes.Introuvable, DefaultMessage)
    {
    }
}
