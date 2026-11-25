namespace Chantier.Core.Exceptions;

/// <summary>Donnees d'entree invalides : 400, avec le detail par champ (noms de champ en camelCase).</summary>
public sealed class ValidationException : DomainException
{
    public ValidationException(IReadOnlyDictionary<string, string[]> errors, string code = ErrorCodes.Validation)
        : base(code, "Une ou plusieurs valeurs sont invalides.")
    {
        Errors = errors;
    }

    public ValidationException(string field, string message, string code = ErrorCodes.Validation)
        : this(new Dictionary<string, string[]> { [field] = [message] }, code)
    {
    }

    public IReadOnlyDictionary<string, string[]> Errors { get; }
}
