namespace Chantier.Core.Exceptions;

/// <summary>Mot de passe provisoire : tout est refuse (403) tant que l'utilisateur n'en a pas choisi un nouveau (CA-001.7).</summary>
public sealed class PasswordChangeRequiredException : DomainException
{
    public PasswordChangeRequiredException()
        : base(ErrorCodes.MotDePasseAChanger, "Vous devez choisir un nouveau mot de passe avant de continuer.")
    {
    }
}
