using System.Reflection;
using Chantier.WebApi.Authorization;
using Chantier.WebApi.Controllers.Auth;
using Chantier.WebApi.Filters;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Routing;

namespace Chantier.UnitTests.Architecture;

/// <summary>Tests d'architecture par reflexion sur les controleurs (ADR 0005 et 0010) : aucune route ne peut oublier son controle.</summary>
[TestFixture]
public class ControllerArchitectureTests
{
    private static readonly Assembly WebApi = typeof(AuthController).Assembly;

    private sealed record ActionInfo(Type Controller, MethodInfo Method, string Template)
    {
        public string Name => $"{Controller.Name}.{Method.Name}";
    }

    private static IEnumerable<Type> Controllers()
        => WebApi.GetTypes().Where(type => !type.IsAbstract && typeof(ControllerBase).IsAssignableFrom(type));

    private static IEnumerable<ActionInfo> Actions()
    {
        foreach (var controller in Controllers())
        {
            var prefix = controller.GetCustomAttribute<RouteAttribute>()?.Template ?? string.Empty;
            foreach (var method in controller.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly))
            {
                var verb = method.GetCustomAttributes<HttpMethodAttribute>().FirstOrDefault();
                if (verb is not null)
                {
                    yield return new ActionInfo(controller, method, $"{prefix}/{verb.Template}");
                }
            }
        }
    }

    [Test]
    public void There_are_controllers_and_actions_to_check()
    {
        Assert.Multiple(() =>
        {
            Assert.That(Controllers().Count(), Is.GreaterThanOrEqualTo(5));
            Assert.That(Actions().Count(), Is.GreaterThanOrEqualTo(24));
        });
    }

    [Test]
    public void Every_route_with_a_site_id_is_site_scoped()
    {
        var offenders = Actions()
            .Where(action => action.Template.Contains("{siteId", StringComparison.Ordinal))
            .Where(action => !HasAttribute<SiteScopedAttribute>(action))
            .Select(action => action.Name)
            .ToList();

        Assert.That(offenders, Is.Empty, "Toute route portant {siteId} doit porter [SiteScoped] (OWASP API1).");
    }

    [Test]
    public void Site_scoped_is_only_used_on_routes_that_carry_a_site_id()
    {
        var offenders = Actions()
            .Where(action => HasAttribute<SiteScopedAttribute>(action))
            .Where(action => !action.Template.Contains("{siteId", StringComparison.Ordinal))
            .Select(action => action.Name)
            .ToList();

        Assert.That(offenders, Is.Empty);
    }

    [Test]
    public void The_site_id_route_parameter_is_always_a_guid()
    {
        var offenders = Actions()
            .Where(action => action.Template.Contains("{siteId", StringComparison.Ordinal) && !action.Template.Contains("{siteId:guid}", StringComparison.Ordinal))
            .Select(action => action.Name);

        Assert.That(offenders, Is.Empty);
    }

    [Test]
    public void Every_action_states_who_may_call_it()
    {
        // Les routes qui n'exigent que d'etre connecte (profil, referentiel, synchronisation) sont listees explicitement ; toute autre route
        // doit porter [HasPermission] : on ne compte jamais sur la seule politique de repli pour une action metier.
        // La synchronisation controle ensuite le role et l'affectation entite par entite (handlers et sources).
        var authenticatedOnly = new[] { "AuthController", "ReferenceController", "SyncController" };

        var offenders = Actions()
            .Where(action => !authenticatedOnly.Contains(action.Controller.Name))
            .Where(action => !HasAttribute<HasPermissionAttribute>(action) && !HasAttribute<AllowAnonymousAttribute>(action))
            .Select(action => action.Name)
            .ToList();

        Assert.That(offenders, Is.Empty, "Ajouter [HasPermission(...)] : le rôle décide de l'action.");
    }

    [Test]
    public void Only_the_login_and_refresh_routes_are_anonymous()
    {
        var anonymous = Actions().Where(action => HasAttribute<AllowAnonymousAttribute>(action)).Select(action => action.Name).ToList();

        Assert.That(anonymous, Is.EquivalentTo(new[] { "AuthController.Login", "AuthController.Refresh" }));
    }

    [Test]
    public void Routes_are_versioned_and_never_use_controller_or_action_tokens()
    {
        var offenders = Actions()
            .Where(action => !action.Template.StartsWith("api/v1/", StringComparison.Ordinal)
                || action.Template.Contains("[controller]", StringComparison.Ordinal)
                || action.Template.Contains("[action]", StringComparison.Ordinal))
            .Select(action => $"{action.Name} : {action.Template}");

        Assert.That(offenders, Is.Empty);
    }

    [Test]
    public void Request_models_expose_no_protected_field()
    {
        // Protection contre l'affectation de masse : aucun champ d'audit, de statut, de numero ni d'identifiant dans les requetes.
        var forbidden = new[]
        {
            "Id", "CreatedAt", "CreatedBy", "UpdatedAt", "UpdatedBy", "DeletedAt", "DeletedBy", "ArchivedAt", "ArchivedBy",
            "RowVersion", "Status", "Number", "SiteId", "Role", "IsActive", "CreatedByName", "UpdatedByName",
        };

        var requests = WebApi.GetTypes().Where(type => type.Namespace?.StartsWith("Chantier.WebApi.Models", StringComparison.Ordinal) == true && type.Name.EndsWith("Request", StringComparison.Ordinal));
        var offenders = requests
            .SelectMany(type => type.GetProperties().Where(property => forbidden.Contains(property.Name)).Select(property => $"{type.Name}.{property.Name}"))
            .ToList();

        Assert.That(offenders, Is.Empty);
    }

    private static bool HasAttribute<T>(ActionInfo action) where T : Attribute
        => action.Method.GetCustomAttribute<T>() is not null || action.Controller.GetCustomAttribute<T>() is not null;
}
