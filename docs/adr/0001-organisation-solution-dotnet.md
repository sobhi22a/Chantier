# ADR 0001 : Organisation de la solution .NET

**Date :** 2026-11-24 · **Statut :** Acceptée · **Auteur :** architecte-chantier

## Contexte
Il faut un backend .NET 10 en monolithe modulaire (une API, une base). Kardinal-app propose trois projets en couches
(`Core/Easy.Core`, `Core/Easy.Infrastructure`, `Easy/Easy.WebApi`) avec contrôleurs MVC, services, Ardalis.Specification et AutoMapper
(`docs/architecture/reference-kardinal.md`, §1 et §2). Contraintes propres à Chantier : règles et calculs testables sans base ni HTTP
(règle 3), audit automatique (règle 9), contrat d'API REST (skill `contrat-api`), licences saines.

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. Imiter Kardinal tel quel (3 projets, contrôleurs, AutoMapper, EF dans Core) | Zéro surprise pour l'équipe | Domaine couplé à EF ; AutoMapper vulnérable ou payant ; audit manuel | Dette dès le jour 1 |
| B. **3 projets comme Kardinal, domaine sans EF, mapping manuel, dossiers par module** | Même vocabulaire et mêmes dossiers que Kardinal ; domaine testable ; aucune bibliothèque payante | Mapping à écrire (quelques lignes par DTO) | Faible |
| C. Tranches verticales (une feature = un dossier de bout en bout, Minimal APIs) | Très lisible par fonctionnalité | Rupture totale avec Kardinal ; ADR et formation supplémentaires | Moyen |
| D. Un projet par module (Sites, Approvisionnement, …) | Frontières strictes | Surdimensionné pour une équipe réduite ; références croisées | Élevé |

## Décision
**Option B.** Trois projets de production et deux projets de tests, des dossiers par module à l'intérieur de chaque projet.

```
chantier-backend/
  Chantier.sln                    (format .sln, comme Kardinal)
  global.json                     SDK 10.0.x, rollForward latestFeature
  Directory.Build.props           net10.0, Nullable, ImplicitUsings, LangVersion par défaut (C# 14), analyseurs
  Directory.Packages.props        versions centralisées de tous les paquets
  Core/Chantier.Core/             domaine : aucune référence EF, SQL ni ASP.NET
  Core/Chantier.Infrastructure/   EF Core, dépôts, services, DI, seeders, stockage
  WebApi/Chantier.WebApi/         contrôleurs, middlewares, autorisation, OpenAPI, Program.cs
  Tests/Chantier.UnitTests/       NUnit + Moq, sans base
  Tests/Chantier.IntegrationTests/  NUnit + WebApplicationFactory + base SQL Server réelle
```

`Chantier.Core` référence uniquement Ardalis.Specification 9.x et `Microsoft.Extensions.Identity.Stores` (types `IdentityUser`/`IdentityRole`, sans EF Core).

Contenu de `Chantier.Core` (dossiers, du plus stable au plus volatil) :
- `Entities/<Module>/` : entités et `BasicEntity` (`Entities/Common/`). Modules du socle : `Common`, `Identity`, `Sites`.
- `Specifications/<Module>/` : toute la logique de requête (Ardalis.Specification 9.x), comme Kardinal.
- `<Module>/` (ex. `Sites/`) : interfaces de service (`ISiteService`) et réponses (`SiteResponse`), comme `Tiers/ITiersService.cs` de Kardinal.
- `DTOs/<Module>/` : DTO d'entrée des services. `Exceptions/`, `Paging/`, `Abstractions/` (`ICurrentUser`, `ISiteAccess`, …).

Règles :
1. **Contrôleurs MVC** (`[ApiController]`), pas de Minimal APIs : on imite Kardinal ; le filtre d'autorisation par chantier et la génération OpenAPI sont aussi simples.
2. **Mapping manuel** : méthodes statiques `XxxResponse.From(entity)` et `XxxRequest.ToDto()`. Ni AutoMapper (licence commerciale depuis la v15, version 12 de Kardinal vulnérable), ni Mapperly (inutile pour ce volume).
3. **Validation** : annotations de données sur les requêtes HTTP (`[ApiController]` renvoie 400, converti en Problem Details, ADR 0002) ; règles métier dans les entités et objets de valeur, qui lèvent `DomainRuleException` portant un `Code` stable. Pas de FluentValidation.
4. **Temps et identifiants** : `TimeProvider` injecté (jamais `DateTime.UtcNow` direct) ; `Guid.CreateVersion7()` pour les identifiants.
5. **Langue du code** : anglais (entités, routes, DTO) ; codes d'erreur métier en français majuscules (`UNITE_OBLIGATOIRE`) comme dans `metier-chantier` ; aucun texte d'interface côté serveur.
6. **Services** transitoires, dépôts `IRepositoryBase<T>` scoped (générique ouvert), une méthode `AddInfrastructure` et une méthode `AddWebApi`.
7. **Paquets** centralisés (`Directory.Packages.props`). **Interdits sans ADR** : AutoMapper, MediatR, FluentAssertions ≥ 8, MassTransit ≥ 9, SixLabors.ImageSharp, tout paquet Oracle ; `TreatWarningsAsErrors` sur `Core` et `Infrastructure`.
8. **Suppression d'un projet inutile** : pas de `Modules/` vide comme chez Kardinal (stubs ignorés).

## Conséquences
- Plus facile : tester les règles métier sans base ; lire un module en parcourant quatre dossiers parallèles.
- Plus difficile : écrire le mapping à la main (compensé par les tests) ; ne pas laisser un service devenir un fourre-tout.
- À surveiller : le jour où un module (par ex. `Procurement`) dépasse une vingtaine de fichiers, l'extraire dans un sous-dossier dédié plutôt que créer un projet.
