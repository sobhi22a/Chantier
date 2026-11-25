namespace Chantier.Core.Exceptions;

/// <summary>
/// Conflit de version ou de concurrence : 409. <see cref="Current"/> est l'etat courant de la ressource
/// (renvoye dans le champ <c>current</c> pour que le client propose de recharger).
/// </summary>
public sealed class ConflictException : DomainException
{
    public ConflictException(object? current = null, string code = ErrorCodes.ConflitVersion)
        : base(code, "La ressource a été modifiée entre-temps.")
    {
        Current = current;
    }

    public object? Current { get; }
}
