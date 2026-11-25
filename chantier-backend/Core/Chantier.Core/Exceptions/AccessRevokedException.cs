namespace Chantier.Core.Exceptions;

/// <summary>Compte desactive alors qu'une session existait : 401 <c>ACCES_RETIRE</c> (le mobile efface les donnees chantier).</summary>
public sealed class AccessRevokedException : DomainException
{
    public AccessRevokedException() : base(ErrorCodes.AccesRetire, "Accès retiré, contactez votre administrateur.")
    {
    }
}
