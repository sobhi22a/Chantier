namespace Chantier.Core.Exceptions;

/// <summary>Regle metier violee : 422 avec un <c>code</c> stable.</summary>
public sealed class DomainRuleException : DomainException
{
    public DomainRuleException(string code, string message) : base(code, message)
    {
    }
}
