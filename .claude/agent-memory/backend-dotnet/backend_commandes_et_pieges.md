---
name: backend-commandes-et-pieges
description: Commandes exactes (build, tests, migrations, API locale, OpenAPI, générateurs), conventions et pièges vérifiés du backend Chantier (.NET 10, EF Core, SQL Server) après B1 à B8
metadata:
  type: project
---

## Conventions
- Solution `chantier-backend/Chantier.sln` : `Core/Chantier.Core` (sans EF ni ASP.NET), `Core/Chantier.Infrastructure`, `WebApi/Chantier.WebApi`, `Tests/Chantier.UnitTests`, `Tests/Chantier.IntegrationTests`. Namespaces file-scoped, `TreatWarningsAsErrors`, paquets centralisés (`Directory.Packages.props`).
- Un cas métier attendu = exception typée de `Core/Exceptions` (code stable de `ErrorCodes`) ; `GlobalExceptionMiddleware.Map` fait exception -> statut + `code`. Toute réponse d'erreur passe par `ProblemResponses` (type, title, status, detail, code, traceId). Nouveau code = `ErrorCodes` + `ErrorCatalog` + `docs/api/codes-erreur.md` (test `ErrorCatalogTests`).
- Lecture par `Specification` Ardalis ; mapping manuel `XxxResponse.From(...)` ; DTO d'entrée sans champ protégé (test d'architecture `ControllerArchitectureTests`, types `*Request` seulement).
- `[SiteScoped]` est un filtre de RESSOURCE (avant la liaison du corps) : un corps invalide ne révèle pas l'existence d'un chantier non affecté. Obligatoire sur toute route `{siteId:guid}`.
- Audit uniquement par `AuditingInterceptor` (setters privés, `MarkCreated/Updated/Deleted`). `DbSet.Remove` devient une suppression logique. Écritures hors requête (seeders) = auteur `SystemActor`.
- Idempotence : vérifier le `clientId` AVANT et APRÈS la vérification de position (course entre renvois parallèles), cf. `ZoneService.ResolveRaceAsync`.
- Synchronisation : une `ISyncSource` par entité lue, un `ISyncPushHandler` par entité écrite ; toute entité `ISiteScoped` s'ajoute à `SyncTouch.TouchedEntityTypes` (test d'architecture). Numérotation : `ISiteNumbering.NextAsync` dans la transaction de l'entité, idempotence (`clientId`) vérifiée d'abord.

## Chemins clés
- Contrat : `docs/api/openapi.json` (GÉNÉRÉ, fait foi), `docs/api/socle.md` (lecture guidée), `docs/api/codes-erreur.md`. ADR : `docs/adr/0001` à `0010` (0006 et 0009 ont une section « B6 » / « B5 » du backend).
- OpenAPI : `WebApi/Chantier.WebApi/OpenApi/` (`ChantierOpenApi`, transformateurs document / opération / schéma, `OpenApiGeneration`). Sync : `Core/Chantier.Core/Sync`, `Core/Chantier.Infrastructure/Sync`. Démo : `Core/Chantier.Infrastructure/SeedData/Demo`.
- Données de référence : `Core/Chantier.Infrastructure/SeedData/Reference/*.json` (communes = extrait Blida seulement).
- Migrations : `Core/Chantier.Infrastructure/Persistence/Migrations` (exclues des règles de style via `chantier-backend/.editorconfig`) : `InitialCreate`, `AddSiteCounters`.

## Commandes qui marchent
- Build et tests : `cd chantier-backend; dotnet build; dotnet test`. Sans variable, les tests d'intégration lancent un conteneur Testcontainers (Docker, ~50 s, image `mssql/server:2022-latest`).
- Réutiliser le conteneur de dev sans l'afficher : `set -a; . /d/projects/Chantier/.env; set +a; export CHANTIER_TEST_SQL="Server=localhost,14335;User Id=sa;Password=${MSSQL_SA_PASSWORD};TrustServerCertificate=True;Encrypt=False"` (le fixture crée puis supprime des bases `chantier_test_*`). Dernier état : 153 tests unitaires + 379 d'intégration verts ; les tests de numérotation et de concurrence ont passé 8 boucles de suite.
- OpenAPI : `dotnet build` écrit `docs/api/openapi.json` (test `OpenApiContractTests` = fichier commité identique au code ; sans base ni secret grâce à `OpenApiGeneration.Settings()`). Désactiver : `-p:OpenApiGenerateDocuments=false`.
- Migration : `dotnet ef migrations add <Nom> --project Core/Chantier.Infrastructure --startup-project WebApi/Chantier.WebApi -o Persistence/Migrations` (exporter `ConnectionStrings__ChantierDb` factice ; pas de connexion nécessaire) ; `dotnet ef migrations script <de> <vers> --idempotent` pour relire le SQL.
- Secrets de dev : `dotnet user-secrets set` dans `WebApi/Chantier.WebApi` (id `chantier-webapi`) : `ConnectionStrings:ChantierDb`, `JwtSettings:Key`. Ils ne sont chargés qu'en Development.
- API locale avec démo : `ASPNETCORE_ENVIRONMENT=Development Seed__Demo=true dotnet run --no-build --no-launch-profile --urls http://localhost:8195` (mot de passe démo = `Seed:DemoPassword` de `appsettings.Development.json`). Sans Development l'API refuse de démarrer (clé JWT et chaîne absentes).
- Format : `dotnet format Chantier.sln` puis `--verify-no-changes`.
- Build bloqué (MSB3021, DLL verrouillées) : un `Chantier.WebApi.exe` de dev (port 8195) tourne encore ; l'arrêter avant `dotnet build`/`dotnet ef`.
- Vérifier une migration sur vraie base : base temporaire dans `chantier-dev-db`, `dotnet ef database update <migration précédente>`, insérer des lignes par `sqlcmd -I` (QUOTED_IDENTIFIER requis), puis `database update`.
- Générateurs (vérifiés B6, dossiers temporaires) : web `npm i @rtk-query/codegen-openapi esbuild-runner` puis `npx rtk-query-codegen-openapi openapi-config.ts` ; mobile `swagger_parser 1.46.0` (PAS 2.x : Dart ≥ 3.13) avec `use_freezed3: true`, `retrofit 4.4.2` + `retrofit_generator 9.1.9`.
- Diagnostic d'interblocage SQL : `docker exec chantier-dev-db /opt/mssql-tools18/bin/sqlcmd ...` (préfixer `MSYS_NO_PATHCONV=1` sous Git Bash), `DBCC TRACEON(1222,-1)`, puis `sp_readerrorlog`.

## Pièges connus
- Horloge de test : la validation JWT utilise l'horloge RÉELLE. Ne jamais `FakeTimeProvider.SetUtcNow` à une date fixe (jetons expirés) ; seulement `Advance`, après les connexions.
- Une requête sur la table pendant qu'une transaction ouverte verrouille une ligne se bloque : dans les tests de curseur, filtrer par fenêtre de version, pas par Id.
- `[AllowAnonymous]` au niveau classe écrase les `[Authorize]` des actions (erreur ASP0026) : le placer sur les actions.
- Écrire des fichiers avec Python sous Windows donne du CRLF : utiliser `newline=''`. Dans les heredocs Bash, les `\r` `\n` des chaînes C# sont mangés : construire les littéraux avec `chr(92)` ou écrire le fichier avec l'outil Write ; les grosses heredocs avec apostrophes échouent parfois : passer par Write.
- `MsSqlBuilder()` sans image est obsolète : passer l'image. Analyseur NUnit1032 : la fabrique créée en `OneTimeSetUp` doit être libérée en `OneTimeTearDown`.
- Les messages d'exception inattendus (500) sont journalisés avec leur pile : aucune donnée personnelle ne doit jamais être mise dans un message d'exception.
- **Interblocages SQL (mesurés)** : une transaction d'affectation qui verrouille `Sites` APRÈS des lignes enfants, ou avec `UPDLOCK` sur la ligne, ou avec un `UPDATE` par chantier qui parcourt les zones, s'interbloque avec le contrôle d'affectation (`Sites` puis `SiteMembers`) et la clé étrangère d'une création de zone. Solution en place : verrou applicatif + chantier d'abord + zones relevées en `READPAST` puis touchées une à une par clé primaire. Un test de concurrence ne révèle le défaut que si les requêtes se chevauchent vraiment (le test seul, à froid, passe) : lancer la classe entière en boucle.
- `ExecuteUpdateAsync(SetProperty(x => x.UpdatedAt, x => x.UpdatedAt))` fait bien avancer le `rowversion` sans toucher à l'audit.
- Génération OpenAPI au build : l'hôte démarre vraiment (validation des options) ; `OpenApiGeneration` fournit une clé JWT aléatoire et un dossier temporaire. Les commentaires XML multi-lignes sortent en CRLF sous Windows : normalisés par le transformateur de document. Un type avec convertisseur JSON personnalisé (`DateOnly` strict) perd son `type` dans le schéma.
- `GenerateDocumentationFile` : `CS1573` (paramètres documentés en partie) désactivé dans Core ; ne pas utiliser `<see cref>` ni `<b>` dans les commentaires qui atteignent l'OpenAPI.

- **Numérotation** : les 5 compteurs naissent avec le chantier (`Site.Create` -> `Site.Counters`, `ClientNoAction` pour que `Remove` d'un chantier suivi ne casse pas) + migration `BackfillSiteCounters`. Repli (chantier sans compteur) : `sp_getapplock` transactionnel puis `INSERT … WHERE NOT EXISTS` DANS la transaction de l'appelant. Ne PAS revenir à une seconde connexion (la clé étrangère attend l'`UPDATE Sites` de l'appelant : D-6, 30 s) ni à `HOLDLOCK` (interblocage avec les annulations : D-1). Pour tester le repli, supprimer les lignes `SiteCounters` du chantier (`SiteNumberingFallbackTests`).
- **Limiteur de débit** : placé AVANT `UseAuthorization` (sinon les 401/403 ne le traversent jamais : D-7), précédé de `RateLimitIdentityMiddleware` qui évalue la politique par défaut (cookie + jeton porteur) pour que la partition voie l'utilisateur (le schéma par défaut d'Identity est le cookie). Anonyme ou jeton invalide = seau par IP ; le résultat d'authentification est mémorisé par requête (pas de double validation). `AddWebApi(configuration)` reçoit la configuration : le certificat des clés de protection des données est lu à l'enregistrement, donc les réglages en mémoire de `WebApplicationFactory` ne l'atteignent pas (tests : variables d'environnement). `IConfiguration` n'est pas retrouvable dans `IServiceCollection` (fabrique, pas instance).
- **Session web (R1-02)** : cookie avec `session_stamp` (= `SecurityStamp` de l'utilisateur) et `login_at` ; vérifiés dans `ActiveUserValidator.ValidateCookieAsync` via `UserStatusProvider` ; la déconnexion web appelle `EndWebSessionsAsync` (change le stamp). Tests de temps : fabrique dédiée (`Advance` casse les jetons des autres tests).
- `TestServer` n'applique pas `MaxRequestBodySize` de Kestrel : le 413 à 64 Ko se vérifie sur un vrai serveur (`dotnet run`, curl).
- Le test de concurrence n'échoue que si les requêtes se chevauchent vraiment : lancer la classe entière en boucle. Les retraits d'affectation prennent le même verrou de chantier que les affectations.

## Décisions (lien ADR)
- Convertisseur `RowVersion` gros-boutiste et `MIN_ACTIVE_ROWVERSION()` vérifiés sur vraie base : ADR 0003 inchangé, pas de repli.
- Limitation `auth` faite dans l'action (IP + identifiant haché) car l'identifiant est dans le corps : ADR 0005.
- Cursor des zones = décalage opaque (base64url `o:N`), pas de keyset : à revoir si les listes dépassent quelques milliers de lignes.
- OpenAPI 3.1 conservé (le repli 3.0 de l'ADR 0006 n'a pas été nécessaire) : web et mobile lisent le document tel quel.
- Production : proxy inverse, certificat des clés et limites dans `docs/exploitation/production-backend.md` (`ForwardedHeaders`, `DataProtection`, `Auth:CookieAbsoluteHours`, `Auth:RefreshGraceSeconds`).
- Mot de passe de démonstration : valeur de développement dans `appsettings.Development.json` (plan B7), `Seed:Demo` désactivé par défaut même en Development.
