using Chantier.Core.Exceptions;

namespace Chantier.Core.Validation;

/// <summary>Accumule les erreurs par champ (noms en camelCase) puis leve une seule <see cref="ValidationException"/>.</summary>
public sealed class ErrorCollector
{
    private readonly Dictionary<string, List<string>> _errors = new(StringComparer.Ordinal);
    private string _code = ErrorCodes.Validation;

    public bool HasErrors => _errors.Count > 0;

    public void Add(string field, string message)
    {
        if (!_errors.TryGetValue(field, out var list))
        {
            _errors[field] = list = [];
        }

        list.Add(message);
    }

    /// <summary>Erreur de date : le code de la reponse devient <c>DATE_INVALIDE</c>.</summary>
    public void AddInvalidDate(string field, string message)
    {
        _code = ErrorCodes.DateInvalide;
        Add(field, message);
    }

    public void ThrowIfAny()
    {
        if (_errors.Count > 0)
        {
            throw new ValidationException(
                _errors.ToDictionary(pair => pair.Key, pair => pair.Value.ToArray(), StringComparer.Ordinal),
                _code);
        }
    }
}
