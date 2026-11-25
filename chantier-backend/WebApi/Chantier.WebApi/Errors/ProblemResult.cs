using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Errors;

/// <summary>Resultat MVC qui ecrit un Problem Details via <see cref="ProblemResponses"/> (format unique).</summary>
public sealed class ProblemResult(ProblemDetails problem) : IActionResult
{
    public Task ExecuteResultAsync(ActionContext context) => ProblemResponses.WriteAsync(context.HttpContext, problem);
}
