using Chantier.Core.Exceptions;
using Chantier.WebApi.Json;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Errors;

/// <summary>
/// Reponse 400 de la validation de modele (<c>[ApiController]</c>) : Problem Details avec <c>code = VALIDATION</c>
/// (ou <c>DATE_INVALIDE</c> pour une date incomplete) et <c>errors</c> par champ en camelCase.
/// Jamais d'echo de la valeur saisie ni d'un message d'exception interne.
/// </summary>
public static class ModelStateProblemFactory
{
    public const string GenericMessage = "Valeur invalide.";
    public const string InvalidDateMessage = "La date est incomplète ou impossible.";

    public static IActionResult Create(ActionContext context)
    {
        var errors = new Dictionary<string, List<string>>();
        var hasInvalidDate = false;

        foreach (var (key, entry) in context.ModelState)
        {
            foreach (var error in entry.Errors)
            {
                string message;
                if (IsInvalidDate(error))
                {
                    hasInvalidDate = true;
                    message = InvalidDateMessage;
                }
                else if (error.Exception is not null || key.StartsWith('$') || string.IsNullOrWhiteSpace(error.ErrorMessage))
                {
                    // Erreurs de lecture du JSON (cle « $.champ ») ou d'exception : le message du parseur
                    // contient des details techniques (position, caracteres) qu'on ne renvoie jamais.
                    message = GenericMessage;
                }
                else
                {
                    message = error.ErrorMessage;
                }

                var field = NormalizeKey(key);
                if (!errors.TryGetValue(field, out var list))
                {
                    errors[field] = list = [];
                }

                if (!list.Contains(message))
                {
                    list.Add(message);
                }
            }
        }

        var code = hasInvalidDate ? ErrorCodes.DateInvalide : ErrorCodes.Validation;
        var problem = ProblemResponses.Create(
            context.HttpContext,
            code,
            StatusCodes.Status400BadRequest,
            errors: errors.ToDictionary(pair => pair.Key, pair => pair.Value.ToArray()));
        return new ProblemResult(problem);
    }

    private static bool IsInvalidDate(Microsoft.AspNetCore.Mvc.ModelBinding.ModelError error)
    {
        for (var exception = error.Exception; exception is not null; exception = exception.InnerException)
        {
            if (exception is InvalidDateJsonException)
            {
                return true;
            }
        }

        // Selon la version d'ASP.NET Core, seul le message de l'exception JSON est conserve : on reconnait le marqueur.
        return string.Equals(error.ErrorMessage, ErrorCodes.DateInvalide, StringComparison.Ordinal)
            || (error.ErrorMessage?.StartsWith(ErrorCodes.DateInvalide, StringComparison.Ordinal) ?? false);
    }

    /// <summary>« $.OdsDate », « OdsDate » ou « request.OdsDate » deviennent « odsDate ».</summary>
    public static string NormalizeKey(string key)
    {
        var segments = key.Split('.', StringSplitOptions.RemoveEmptyEntries)
            .Where(segment => segment != "$")
            .Select(segment => segment.Length == 0 ? segment : char.ToLowerInvariant(segment[0]) + segment[1..])
            .ToArray();

        return segments.Length == 0 ? "body" : string.Join('.', segments);
    }
}
