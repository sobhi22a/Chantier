using Chantier.Core.Exceptions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.IntegrationTests.Support;

/// <summary>Points d'entree reserves aux tests (jamais dans l'API) : declenchent des erreurs volontaires.</summary>
[ApiController]
[Route("test-support")]
public class TestSupportController : ControllerBase
{
    public const string SecretMessage = "SELECT password FROM Users at Chantier.Infrastructure.Secret";

    [AllowAnonymous]
    [HttpGet("boom")]
    public IActionResult Boom() => throw new InvalidOperationException(SecretMessage);

    [AllowAnonymous]
    [HttpGet("not-found")]
    public IActionResult NotFoundCase() => throw new NotFoundException();

    /// <summary>Route authentifiee quelconque (politique de repli) : sert a verifier le changement de mot de passe obligatoire.</summary>
    [HttpGet("authenticated")]
    public IActionResult Authenticated() => Ok();

    [HttpGet("needs-zones-create")]
    [Chantier.WebApi.Authorization.HasPermission("Zones", "Create")]
    public IActionResult NeedsZonesCreate() => Ok();

    [HttpGet("needs-sites-create")]
    [Chantier.WebApi.Authorization.HasPermission("Sites", "Create")]
    public IActionResult NeedsSitesCreate() => Ok();

    [AllowAnonymous]
    [HttpPost("echo")]
    public IActionResult Echo([FromBody] EchoRequest request) => Ok(new { request.Name });

    public sealed class EchoRequest
    {
        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Le champ est obligatoire.")]
        public string? Name { get; set; }

        public DateOnly? Date { get; set; }
    }
}
