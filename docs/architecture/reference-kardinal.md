# Référence d'architecture : Kardinal-app

**Auteur :** architecte-chantier · **Date :** 2026-11-24 · **Statut :** Validé pour le socle

Kardinal-app (e-commerce pharmaceutique) sert de **référence de conventions** pour Chantier. Règle : imiter ses bibliothèques
et ses structures de dossiers, sauf quand une règle non négociable de `CLAUDE.md` l'interdit (hors ligne, FR/AR RTL, `decimal`
serveur, traçabilité automatique, numérotation serveur, contrat d'API). Kardinal n'est **jamais modifié** : lecture seule.

## 0. Sources lues

| Version | Chemin | Remarque |
|---|---|---|
| Référence officielle (demandée) | `D:\projects\Project_init\Kardinal-app` | Backend complet, web complet, **mobile réduit** (auth + clients, sans base locale) |
| Version complète du mobile (consultée pour la base locale) | `D:\projects\Kardinal-app\Mobile-app` | Contient la base locale et la synchronisation hors ligne |

Écart important : les `CLAUDE.md` de Kardinal annoncent **Drift et Freezed**, mais le code ne les utilise nulle part
(aucun `import 'package:drift'`, aucun fichier `*.g.dart` ni `*.freezed.dart`). La base locale réelle est du **sqflite écrit à la
main** (`D:\projects\Kardinal-app\Mobile-app\lib\database\ecommerce_database.dart`) avec `idb_shim` pour le web. Drift et Freezed sont déclarés
dans `pubspec.yaml` (lignes 59, 73) sans être utilisés. Chantier adopte donc Drift et Freezed « pour de vrai » (ADR 0008) :
il n'y a pas de code Kardinal à imiter pour ces deux points, seulement l'intention.

Chemins ci-dessous : `KB` = `D:\projects\Project_init\Kardinal-app\kardinal-backend`, `KF` = `...\kardinal-frontend`,
`KM` = `...\Mobile-app` (version Project_init), `KMF` = `D:\projects\Kardinal-app\Mobile-app` (version complète).

## 1. Backend : à reprendre tel quel

| Pattern | Ce que fait Kardinal | Fichier de référence | Équivalent Chantier |
|---|---|---|---|
| Trois projets en couches | `Core/Easy.Core` (domaine, DTO, interfaces, spécifications), `Core/Easy.Infrastructure` (EF Core, services, DI, seeder), `Easy/Easy.WebApi` (contrôleurs, middlewares, autorisation) | `KB\Easy.sln`, `KB\Core\*`, `KB\Easy\Easy.WebApi.csproj` | `chantier-backend/Core/Chantier.Core`, `Core/Chantier.Infrastructure`, `WebApi/Chantier.WebApi` |
| Contrôleurs MVC + services + DTO | Contrôleur fin, service injecté (`ITiersService`), DTO de service dans `Core/DTOs`, requêtes HTTP dans `Easy/Models` | `KB\Easy\Controllers\Authentification\TiersController.cs`, `KB\Core\Easy.Infrastructure\Services\TiersService.cs` | Idem, mapping écrit à la main (voir §1 « à ne pas reproduire ») |
| Ardalis.Specification partout | `IRepositoryBase<T>` injecté ; `RepositoryCommon<T> : RepositoryBase<T>` (une ligne) enregistré en générique ouvert ; toute la logique de requête dans une `Specification<T>` ; lecture paginée = `CountAsync(spec)` + `ListAsync(spec)` | `KB\Core\Easy.Infrastructure\Repositories\RepositoryCommon.cs`, `KB\Core\Easy.Core\Specifications\Tiers\TiersSearchSpecification.cs`, `KB\Core\Easy.Infrastructure\DependencyInjection.cs:43` | Identique (Ardalis.Specification 9.x) |
| `BasicEntity` | Classe de base : `Id` (Guid), dates et auteurs de création/modification, `IsDeleted` | `KB\Core\Easy.Core\Entities\BasicEntity.cs` | `BasicEntity` conservée, champs adaptés (`CreatedAt/By`, `UpdatedAt/By`, `DeletedAt`, `RowVersion`) |
| Entité à constructeur privé et fabrique statique | `Tiers.Create(dto)`, `Update(dto)`, `Delete(userId)`, setters privés, constructeur protégé pour EF | `KB\Core\Easy.Core\Entities\Tiers.cs` | Identique : les règles vivent dans l'entité |
| Configuration Fluent API par entité | `IEntityTypeConfiguration<T>`, `ApplyConfiguration` dans `OnModelCreating`, index explicites | `KB\Core\Easy.Core\Entities\Configurations\TiersConfiguration.cs`, `KB\Core\Easy.Infrastructure\ApplicationDbContext.cs` | Identique, mais les configurations vont dans `Infrastructure` (voir §2) |
| `ApplicationDbContext : IdentityDbContext<Users, Roles, Guid>` | Identity avec clés Guid, tables renommées | `KB\Core\Easy.Infrastructure\ApplicationDbContext.cs` | `IdentityDbContext<AppUser, AppRole, Guid>` |
| Services transitoires, dépôts scoped | `AddTransient<IXxxService, XxxService>()`, `AddScoped(typeof(IRepositoryBase<>), typeof(RepositoryCommon<>))` | `KB\Core\Easy.Infrastructure\DependencyInjection.cs` | Identique, une méthode `AddInfrastructure` |
| `GlobalExceptionMiddleware` | Capture toute exception, associe type d'exception et code HTTP, masque les détails de base de données hors développement, `correlationId` = `TraceIdentifier` | `KB\Easy\Middlewares\GlobalErrors\GlobalExceptionMiddleware.cs` | Même nom et même rôle, sortie **Problem Details** (ADR 0002) |
| Exceptions métier typées | `BusinessLogicException`, `NotFoundException`, `ValidationException`, `ForbiddenException`, `InvalidCredentialsException`… lancées par les services | `KB\Core\Easy.Core\Exceptions\*.cs` | Même jeu, avec une propriété `Code` stable |
| Permissions par claims | `[HasPermission("Tiers","Create")]` → politique `Permission.Tiers.Create` créée à la demande par `PermissionPolicyProvider` ; `PermissionAuthorizationHandler` lit les claims de rôle ; catalogue `IdentityConstants.References` ; seeder idempotent | `KB\Easy\Authorization\*.cs`, `KB\Core\Easy.Infrastructure\SeedData\Identity\IdentityConstants.cs` | Repris tels quels (ADR 0005) |
| Authentification double | Cookie Identity pour la SPA, JWT bearer pour le mobile, politique de repli « authentifié » sur toute l'API, `OnRedirectToLogin` → 401 | `KB\Easy\Program.cs:46-99` | Repris (ADR 0005) |
| Jeton de rafraîchissement persistant | Entité `RefreshToken` (empreinte SHA-256), rotation à chaque usage, détection de réutilisation qui révoque la chaîne, verrouillage 5 échecs / 15 min | `KB\Core\Easy.Core\Entities\RefreshToken.cs`, `KB\Core\Easy.Infrastructure\Services\AuthService.cs:230-263`, `DependencyInjection.cs:58-60` | Repris, durées adaptées au hors ligne |
| Sécurité de configuration | Clé JWT refusée si vide ou < 32 octets, secrets en `user-secrets` / variables d'environnement, `AddServerHeader = false`, `SecurityHeadersMiddleware`, HSTS hors développement | `KB\Easy\Program.cs:19-35`, `KB\SECURITY.md`, `KB\Easy\Middlewares\SecurityHeadersMiddleware.cs` | Repris |
| OpenAPI + Scalar en développement | `AddOpenApi()`, `MapScalarApiReference()` en Development uniquement | `KB\Easy\Program.cs:140,156-160` | Repris + génération du fichier versionné (ADR 0006) |
| Limitation de débit | Politique `auth` fixe par IP + limiteur global lenient | `KB\Easy\Program.cs:117-129` | Repris, partition modifiée (voir §2) |
| CORS par liste de configuration | Origines lues dans `Cors:Origins`, verbes et en-têtes explicites, `AllowCredentials` | `KB\Easy\Program.cs:104-112` | Repris |
| Tests unitaires NUnit + Moq | Contrôleurs instanciés directement, `BaseControllerTest` | `KB\Easy.ApiTests\BaseControllerTest.cs` | Repris pour les tests unitaires ; **ajout** de tests d'intégration (ADR 0010) |

## 2. Backend : défauts à NE PAS reproduire

| # | Défaut observé | Preuve | Traitement dans Chantier |
|---|---|---|---|
| B-1 | Audit **non rempli automatiquement** : chaque entité met à la main `Created`, `Modified`… ; un oubli = pas de trace. Contredit la règle 9 | `KB\Core\Easy.Core\Entities\Tiers.cs:90-91,154-155`, `KB\CLAUDE.md` (« audit fields are not auto-populated ») | `SaveChangesInterceptor` unique (ADR 0003) |
| B-2 | L'**auteur vient du client** : `DeleteUser([FromQuery] Guid tierId, [FromQuery] Guid userId)` ; contraire à « le client ne fixe jamais l'auteur » | `KB\Easy\Controllers\Authentification\TiersController.cs:58` | Auteur lu uniquement dans le jeton (`ICurrentUser`) |
| B-3 | Suppression logique (`IsDeleted`) sans filtre global sur les entités métier (seul `Users` en a un) | `KB\Core\Easy.Infrastructure\ApplicationDbContext.cs:41-42`, `KB\CLAUDE.md` | Filtre de requête **nommé** EF Core 10 sur toutes les entités, désactivable pour la synchro (ADR 0003) |
| B-4 | Routes `api/[controller]/[action]` avec verbes dans l'URL (`get-tiers`, `create`, `Delete`) et sans version ; contraire au skill `contrat-api` | `KB\Easy\Controllers\Authentification\TiersController.cs:12,23,37,51,64,78` | Routes REST versionnées `/api/v1/sites/{siteId}/…` (ADR 0002) |
| B-5 | Erreurs en JSON maison (`statusCode`, `type`, `correlationId`, `stackTrace`) au lieu de RFC 9457 ; pas de `code` métier | `KB\Easy\Middlewares\GlobalErrors\ErrorResponse.cs`, `GlobalExceptionMiddleware.cs:52-62` | Problem Details avec `code`, `errors`, `traceId` (ADR 0002) |
| B-6 | Classes d'exception **en double** : définies dans `Core/Exceptions` et recopiées dans le fichier du middleware (`BusinessLogicException`, `ValidationException`, `NotFoundException`, `ForbiddenException`) | `KB\Easy\Middlewares\GlobalErrors\GlobalExceptionMiddleware.cs:184-215` | Un seul jeu, dans `Core/Exceptions` |
| B-7 | Dépendance **Oracle** inutile (WebApi, Core, Infrastructure) et gestion `OracleException` dans le middleware | `KB\Core\Easy.Core\Easy.Core.csproj:23`, `GlobalExceptionMiddleware.cs:84,157` | Aucune dépendance Oracle |
| B-8 | `Easy.Core` (le domaine) référence **EF Core, SQL Server, Oracle, JwtBearer** ; les configurations EF y vivent ; le domaine n'est pas testable sans EF | `KB\Core\Easy.Core\Easy.Core.csproj:10-24`, `KB\Core\Easy.Core\Entities\Configurations\*.cs` | `Chantier.Core` ne référence que Ardalis.Specification et des abstractions ; configurations EF dans `Infrastructure` |
| B-9 | **AutoMapper 12.0.1** : version ancienne et vulnérable (déni de service corrigé en 14), les versions récentes sont sous licence commerciale | `KB\Core\Easy.Core\Easy.Core.csproj:11`, `KB\Easy\AutoMapper\AutoMapperProfile.cs` | Mapping écrit à la main (ADR 0001) |
| B-10 | Mot de passe administrateur par défaut **en clair dans le code** | `KB\Core\Easy.Infrastructure\SeedData\Identity\IdentityConstants.cs:9` | Mot de passe d'amorçage lu en configuration, jamais dans le dépôt (ADR 0005) |
| B-11 | Lecture d'une ressource absente renvoie un objet vide (200) et une mise à jour absente renvoie `false` au lieu d'un 404 | `KB\Core\Easy.Infrastructure\Services\TiersService.cs:31-32,69` | `NotFoundException` partout |
| B-12 | Limite `auth` à **5 requêtes / 5 min / IP** : sur les réseaux mobiles algériens (adresses partagées), toute une équipe de chantier peut être bloquée | `KB\Easy\Program.cs:121-123` | Partition IP + nom d'utilisateur, plafond relevé (ADR 0005) |
| B-13 | Aucune validation d'entrée déclarative, entités qui lèvent `ArgumentException` génériques | `KB\Core\Easy.Core\Entities\Tiers.cs:96-100` | Validation des requêtes (annotations) + exceptions de domaine à `Code` |
| B-14 | Aucune **affectation par ressource** (un utilisateur authentifié avec la permission voit tous les tiers) ; indispensable ici (règle « Un utilisateur ne voit que ses chantiers ») | `KB\Easy\Controllers\Authentification\TiersController.cs` | Filtre `SiteScoped` + spécifications filtrées (ADR 0005) |
| B-15 | Aucune pipeline CI pour le backend ; tests sans base réelle ; le projet de tests embarque MSTest + xunit + NUnit + MediatR inutilisés | `KB\CLAUDE.md` (racine : « Backend: no in-repo pipeline »), `KB\Easy.ApiTests\Easy.Identity.UnitTests.csproj:15-26` | CI trois parties + tests d'intégration sur SQL Server réel (ADR 0010) |
| B-16 | Même liste de paquets recopiée dans quatre `csproj`, sans gestion centralisée | `KB\*\*.csproj` | `Directory.Packages.props` (versions centralisées) et `Directory.Build.props` |
| B-17 | Migration : le modèle ne contient plus d'anciennes tables ; un `migrations add` génère des `DropTable` à supprimer à la main | `KB\CLAUDE.md` (avertissement « Migration warning ») | Migration `InitialCreate` propre dès le départ ; relecture obligatoire de chaque migration |

## 3. Web : à reprendre tel quel

| Pattern | Ce que fait Kardinal | Fichier de référence | Équivalent Chantier |
|---|---|---|---|
| Monorepo **Nx** à npm workspaces | `apps/kardinal-back-office`, `libs/{api-core,authentication,state-store,user-interface}`, alias dans `tsconfig.base.json`, plugins Vite/ESLint/Vitest | `KF\nx.json`, `KF\tsconfig.base.json`, `KF\package.json` | `chantier-frontend/` : `apps/chantier-back-office`, mêmes 4 libs + `libs/i18n`, alias `@chantier-frontend/*` |
| Service d'API de base | `ApplicationApiService = createApi({ baseQuery: fetchBaseQuery({ credentials: "include" }), tagTypes })` + compteur d'activité réseau | `KF\libs\api-core\src\lib\ApplicationApi.service.ts`, `networkActivity.slice.ts` | Repris ; `baseQuery` enrichi (Problem Details, `Accept-Language`) |
| RTK Query par fonctionnalité via `injectEndpoints` + étiquettes de cache par entité | `KardinalApiService.injectEndpoints`, `providesTags` / `invalidatesTags` | `KF\apps\kardinal-back-office\src\features\clients\services\tiersApi.service.tsx`, `KF\libs\api-core\src\lib\queryCacheTagsProvider.ts` | Repris ; les endpoints sont **générés** depuis l'OpenAPI (ADR 0006) |
| Store Redux minimal | Tranches `authentication`, `roles`, `networkActivity` + reducer RTK Query ; hooks typés | `KF\libs\state-store\src\backOffice\store.ts`, `hooks.ts` | Repris : `authentication`, `networkActivity`, `ui` (langue) |
| Structure d'une fonctionnalité | `components/` (présentation), `containers/` (données), `sections/` (page), `services/` (RTK), `types/` (interfaces + Zod) | `KF\apps\kardinal-back-office\src\features\clients\*` | Identique |
| Garde de routes par permission | `AuthProvider` → `RoleClaimsProvider` → `PermissionsGuard resourceKey=…`, `DefaultRedirect` | `KF\apps\kardinal-back-office\src\app\providers\router\routers.tsx`, `KF\libs\authentication\src\components\*` | Repris, permissions lues dans `GET /auth/me` |
| UI Mantine 8 + thème + `DirectionProvider` | Thème teal, police Cairo (supporte l'arabe), tableau, notifications | `KF\apps\kardinal-back-office\src\app\providers\mantine\theme.ts`, `main.tsx:26-34` | Repris, thème Chantier à fort contraste |
| Formulaires **react-hook-form** + Zod 4 | Schémas Zod puis `z.infer` ; formulaires en `useForm` | `KF\apps\kardinal-back-office\src\features\clients\types\tiersApi.zod.ts`, `sections\tiersCreator\TierCreator.component.tsx` | Repris, + `@hookform/resolvers/zod` |
| Routeur | `createBrowserRouter` de `react-router-dom` 7 | `KF\apps\kardinal-back-office\src\app\providers\router\routers.tsx` | Repris |
| Conventions de nommage | `IEntityRequest/Response`, `*.style.scss`, enums dans `types/*.enum.ts`, pagination `{items,pageNumber,…}` | `KF\CLAUDE.md` | Repris, pagination alignée sur le contrat (curseur ou `totalCount`) |

## 4. Web : défauts à NE PAS reproduire

| # | Défaut observé | Preuve | Traitement |
|---|---|---|---|
| W-1 | **Aucune internationalisation** : textes français en dur ; `DirectionProvider` présent mais jamais piloté | `KF\libs\authentication\src\components\AuthProvider.component.tsx:39`, `KF\apps\kardinal-back-office\src\main.tsx:26` | Lib `i18n` FR + AR, bascule RTL (ADR 0007) |
| W-2 | `react-hook-form` déclaré en **devDependencies** alors qu'il est utilisé à l'exécution | `KF\package.json:62` | En `dependencies` |
| W-3 | Appels DELETE incorrects : `query: { body }` au lieu de `params`/`body` | `KF\apps\kardinal-back-office\src\features\clients\services\tiersApi.service.tsx:35` | Endpoints générés, plus d'écriture manuelle |
| W-4 | Types d'API écrits à la main (dérive possible avec le backend) | `KF\apps\kardinal-back-office\src\features\clients\types\tiersApi.type.ts` | Types générés (ADR 0006) |
| W-5 | Quasiment **aucun test** unitaire (un `example.spec.ts` e2e seulement) | `KF\apps\kardinal-back-office-e2e\src\example.spec.ts` | Vitest + Testing Library + MSW (ADR 0010) |
| W-6 | Installation par `npm ci --legacy-peer-deps` (conflits de pairs avec React 19) | `KF\..\CLAUDE.md` (racine) | Viser zéro `--legacy-peer-deps` ; sinon documenter chaque conflit |
| W-7 | Une seule version de React épinglée (`19.0.0`) | `KF\package.json:17-18` | Rester en 19.x, plage de correctifs (`~19.x`) |
| W-8 | Libellés d'erreur non traduits ; pas de gestion centralisée des erreurs réseau | `KF\libs\api-core\src\lib\ApplicationApi.service.ts:31-33` (commentaire « global error handling could be placed here ») | `code` Problem Details → clé de traduction |
| W-9 | Bouton de rafraîchissement manuel de liste (`isModified`, états dupliqués) au lieu de laisser RTK Query gérer le cache | `KF\apps\kardinal-back-office\src\features\clients\container\Tiers.container.tsx:47,77-90` | Laisser le cache RTK Query faire foi |

## 5. Mobile : à reprendre tel quel

| Pattern | Ce que fait Kardinal | Fichier de référence | Équivalent Chantier |
|---|---|---|---|
| Fonctionnalités autonomes | `lib/features/<feature>/{domain,data,presentation}` | `KM\lib\features\auth\*` | Identique, noms `snake_case` en minuscules (voir M-5) |
| BLoC pour les flux complexes, Cubit pour le simple | `AuthBloc` (événements/états), `TiersBloc extends Cubit` | `KM\lib\features\auth\presentation\bloc\auth_bloc.dart`, `...\Clients\presentation\bloc\tiers_bloc.dart` | Identique (`flutter_bloc`) |
| Injection avec GetIt | `sl = GetIt.instance`, `initializeDependencies()`, `registerLazySingleton`, `registerFactory` pour les blocs | `KM\lib\core\di\injection.dart` | Identique |
| Client HTTP Dio unique | `DioClient` enveloppant Dio, intercepteur d'autorisation, **un seul rejeu après refresh sur 401** (marqueur `__retried`), Dio « nu » pour le refresh | `KM\lib\core\network\dio_client.dart:36-60,92-118` | Repris (intercepteur), stockage et effacement corrigés (M-2) |
| GoRouter piloté par l'état d'authentification | `refreshListenable: GoRouterRefreshStream(authBloc.stream)` + `redirect` | `KM\lib\core\router\app_router.dart`, `go_router_refresh_stream.dart` | Identique |
| Synchronisation mono-exécution | `Future<void>? _syncInProgress` : les appels concurrents partagent la même exécution | `KMF\lib\features\visitGros\commands\presentation\bloc\sync-functions.dart:13-20` | Principe repris dans le moteur de synchro |
| Reprise après échec partiel | Un échec sur un élément n'interrompt pas les suivants | `KMF\...\sync-functions.dart:116-120` | Repris (réponse par opération) |
| Génération de code | `build_runner` pour Freezed / Drift / JSON | `KM\CLAUDE.md` (commandes) | Repris (Drift, Freezed, json_serializable) |
| CI mobile externe | `codemagic.yaml` (iOS) | `KM\codemagic.yaml` | Non repris : build Android dans la CI principale (ADR 0010) |

## 6. Mobile : défauts à NE PAS reproduire

| # | Défaut observé | Preuve | Traitement |
|---|---|---|---|
| M-1 | **i18n codée en dur** : un `Map` Dart `en` / `fr`, **pas d'arabe**, pas de RTL | `KM\lib\localization\AppLocalizations.dart:7,122` | ARB `fr` + `ar` générés par `gen-l10n`, RTL natif (ADR 0008) |
| M-2 | Jetons d'accès et de rafraîchissement stockés dans **SharedPreferences** (en clair) ; en cas d'échec de refresh, tout l'utilisateur en cache est effacé | `KM\lib\core\network\dio_client.dart:67-81,103` | `flutter_secure_storage` ; un échec de refresh **ne supprime ni base locale ni file d'envoi** |
| M-3 | URL de l'API choisie par `kReleaseMode` : impossible de pointer un autre environnement sans recompiler le code | `KM\lib\core\network\app_config.dart:12` | `--dart-define=API_BASE_URL` (ADR 0008) |
| M-4 | Aucune persistance structurée ni file d'envoi : indicateurs `syncRow 'Y'/'N'` par ligne, réconciliation par appel « verify-sync », **pas de `clientId`**, **numéro généré par le client** (`documentno: generateRandomNumber()`), contraire aux règles 5 et 6 | `KMF\lib\features\visitGros\commands\presentation\bloc\sync-functions.dart:130`, `KMF\lib\database\ecommerce_database.dart` | Drift + file d'envoi (outbox) + curseur serveur (ADR 0008, 0009) |
| M-5 | Casse de dossiers incohérente (`visitGros`, `Clients`), noms de fichiers en `PascalCase` (`TierRequest.dart`), tirets (`sync-functions.dart`) ; contraire aux règles Dart | `KM\lib\features\Clients\domain\models\TierRequest.dart` | `snake_case` partout |
| M-6 | Repositories SQL manuels dupliqués pour web et mobile (`kIsWeb`) ; cible web inutile | `KMF\lib\repositories\commands\command_repository.dart` | Android d'abord, pas de web, accès via DAO Drift |
| M-7 | Deux bibliothèques d'état (Riverpod déclaré en plus de BLoC) | `KM\pubspec.yaml:37` | BLoC / Cubit seulement |
| M-8 | Montants et quantités en `double` avec calcul côté client | `KMF\lib\database\models\command_model.dart` | Aucune arithmétique client ; valeurs conservées en texte décimal (ADR 0008) |
| M-9 | `print(...)` et `catch (e)` sans journalisation structurée ; erreurs affichées en brut (`error: e.toString()`) | `KM\lib\features\Clients\presentation\bloc\tiers_bloc.dart:16-17` | Erreurs typées (`code` Problem Details) traduites dans l'interface |
| M-10 | Un seul test (`widget_test.dart`) | `KM\test\widget_test.dart` | `bloc_test`, `mocktail`, base Drift en mémoire (ADR 0010) |

## 7. Synthèse : ce qui change et pourquoi

| Domaine | Décision | Cause (règle non négociable ou défaut) |
|---|---|---|
| Mapping | Manuel, pas d'AutoMapper | Licence commerciale + faille (B-9) |
| Audit et suppression logique | Automatiques (intercepteur, filtre nommé) | Règle 9, B-1, B-3 |
| Routes et erreurs | REST `/api/v1`, Problem Details | Skill `contrat-api` (B-4, B-5) |
| Domaine | `Chantier.Core` sans EF | Règle 3 (calculs testables sans base), B-8 |
| Affectation au chantier | Filtre de ressource | Règle « chantiers affectés », B-14 |
| Mobile | Drift + outbox + curseur | Règle 6 (hors ligne, `clientId`), M-4 |
| i18n | FR + AR partout | Règle 7, W-1, M-1 |
| Jetons mobiles | Stockage sécurisé, pas d'effacement de la base | Terrain hors ligne, M-2 |
