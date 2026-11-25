# ADR 0010 : Outils de test et plateforme de CI

**Date :** 2026-11-24 · **Statut :** Acceptée · **Auteur :** architecte-chantier

## Contexte
Kardinal : tests backend NUnit + Moq limités aux contrôleurs (aucune base réelle, projet de tests encombré de MSTest, xunit et MediatR inutilisés), **aucun test web**, **un test mobile**, pas de CI backend ;
CI web sur Azure Pipelines + Nx Cloud, CI mobile sur Codemagic (iOS) (`reference-kardinal.md`, B-15, W-5, M-10). Chantier a des risques que seuls des tests réels attrapent :
isolation entre chantiers, idempotence, curseur de synchronisation, migrations, RTL. Le dépôt n'a pas encore de serveur distant connu.

## Options étudiées
| Sujet | Option retenue | Alternatives écartées |
|---|---|---|
| Tests unitaires .NET | **NUnit 4 (version stable) + Moq 4.20.72** (comme Kardinal, sans le bruit) | xUnit (rupture), FluentAssertions ≥ 8 (licence commerciale), NSubstitute |
| Tests d'intégration .NET | **`WebApplicationFactory` + `Testcontainers.MsSql`** : vraie base SQL Server, migrations appliquées | EF InMemory ou SQLite (ne reproduisent ni `rowversion` ni les index filtrés : faux positifs) ; base partagée de développement |
| Web | **Vitest 3 + Testing Library + MSW 2** ; **Playwright** pour un parcours de bout en bout | Jest, Cypress |
| Mobile | **`flutter_test` + `bloc_test` + `mocktail`** ; base Drift **en mémoire** ; `integration_test` pour un scénario hors ligne sur émulateur (lot ultérieur) | Golden tests partout (fragiles) |
| Plateforme de CI | **Azure Pipelines** (`azure-pipelines.yml`, comme Kardinal) ; commandes simples portables | GitHub Actions (équivalent, à choisir si le dépôt distant s'y trouve), Codemagic (iOS, inutile au socle), Nx Cloud (service externe) |

## Décision
**Tests.**
- Règles et calculs : tests unitaires sans base (`Chantier.UnitTests`), cas chiffrés repris tels quels de `metier-chantier/calculs.md` quand ils existent.
- Isolation, permissions, synchronisation, migrations, erreurs : tests d'intégration (`Chantier.IntegrationTests`). Une base par exécution (conteneur) ; chaque test crée ses propres données (GUID aléatoires), pas de dépendance d'ordre.
- Tests d'architecture écrits par réflexion (aucune bibliothèque) : `Chantier.Core` ne référence ni EF ni ASP.NET ; toute action avec `{siteId}` porte `[SiteScoped]` ; aucune action sans `[Authorize]`/`[HasPermission]` hors liste blanche.
- Web : clés de traduction FR/AR identiques (test), composants testés en FR et en AR (`dir="rtl"`), MSW pour simuler l'API ; un scénario Playwright « connexion puis Mes chantiers ».
- Mobile : tests de Cubit/Bloc, de DAO (Drift en mémoire), du moteur de synchro avec une API simulée (hors ligne, 401, 429, doublons) ; widgets de « Mes chantiers » en FR et en AR.
- Couverture : mesurée (`coverlet`, `vitest --coverage`, `flutter test --coverage`), **sans seuil bloquant** au socle ; cible 80 % sur les règles de domaine dès la première fonctionnalité.

**CI** (`azure-pipelines.yml` à la racine, déclenché sur `master` et les demandes de fusion) : trois jobs parallèles + un contrôle.
1. `backend` : .NET 10, `dotnet restore`, `dotnet build -warnaserror`, `dotnet test` (unitaires + intégration, Docker disponible sur l'agent Ubuntu), `dotnet format --verify-no-changes`,
   `dotnet list package --vulnerable --include-transitive` (échec si gravité haute ou critique), **contrôle du contrat** : régénérer `docs/api/openapi.json` puis `git diff --exit-code`.
2. `web` : Node 22, `npm ci`, `npx nx run-many -t lint test build typecheck`, régénération du client d'API puis `git diff --exit-code`.
3. `mobile` : Flutter **3.35.7 épinglé**, `flutter pub get`, `dart run build_runner build`, `git diff --exit-code` sur les fichiers générés, `flutter analyze` (zéro avertissement), `flutter test`, `flutter build apk --debug`.
4. Étape transversale : script « paquets interdits » (échec si `AutoMapper`, `MediatR`, `FluentAssertions`, `MassTransit`, `SixLabors` ou `Oracle` apparaît dans `Directory.Packages.props`, `package.json` ou `pubspec.yaml` sans ADR).
- Secrets de CI : clé JWT de test générée à chaque exécution (`JwtSettings__Key`) ; aucun secret réel ; pas de Nx Cloud.
- Le build APK de **version signée** et le déploiement sont hors socle (lot « exploitation », décision utilisateur sur l'hébergement).
- Hypothèse : si le dépôt distant est sur GitHub, les trois jobs se portent tels quels en GitHub Actions (mêmes commandes) ; décision à prendre à la création du dépôt distant.

## Conséquences
- Plus facile : les régressions de sécurité (fuite entre chantiers) et de synchronisation sont attrapées avant la revue ; le contrat OpenAPI ne dérive plus en silence.
- Plus difficile : la CI exige Docker pour le backend ; durée attendue de l'ordre de 8 à 12 minutes (à mesurer).
- À surveiller : durée des tests d'intégration (garder une seule base par exécution) ; stabilité de l'installation de Flutter sur l'agent (version épinglée et mise en cache).
