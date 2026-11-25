namespace Chantier.Core.Exceptions;

/// <summary>Role sans la permission requise sur une ressource visible : 403.</summary>
public sealed class ForbiddenException : DomainException
{
    public ForbiddenException() : base(ErrorCodes.Interdit, "Action non autorisée pour votre rôle.")
    {
    }
}
