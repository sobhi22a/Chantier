namespace Chantier.Core.Exceptions;

/// <summary>
/// Echec d'authentification : 401. Meme reponse pour identifiant inconnu, mot de passe faux et compte desactive (CA-001.3).
/// Avec <see cref="ErrorCodes.RefreshInvalide"/> pour un jeton de rafraichissement refuse.
/// </summary>
public sealed class InvalidCredentialsException : DomainException
{
    public InvalidCredentialsException(string code = ErrorCodes.IdentifiantsInvalides)
        : base(code, code == ErrorCodes.RefreshInvalide
            ? "Session expirée. Reconnectez-vous."
            : "Identifiant ou mot de passe incorrect, ou compte inactif. Contactez votre administrateur.")
    {
    }
}
