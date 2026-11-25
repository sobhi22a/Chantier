namespace Chantier.Core.Exceptions;

/// <summary>
/// Base des erreurs attendues du domaine. Porte un <see cref="Code"/> stable (contrat d'API).
/// Le message est un texte francais par defaut : il ne contient jamais de nom, d'identifiant de connexion ni de telephone.
/// </summary>
public abstract class DomainException : Exception
{
    protected DomainException(string code, string message) : base(message)
    {
        Code = code;
    }

    public string Code { get; }
}
