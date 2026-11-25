# ADR 0006 : Génération des clients web et mobile depuis l'OpenAPI

**Date :** 2026-11-24 · **Statut :** Acceptée (avec deux vérifications techniques à faire en premier) · **Auteur :** architecte-chantier

## Contexte
Dans Kardinal, les endpoints et types TypeScript sont écrits à la main (`features/*/services/*.tsx`, `types/*.type.ts`) ; des erreurs s'y glissent
(DELETE mal formé, `reference-kardinal.md` W-3, W-4) et rien ne détecte une dérive avec le backend. Le skill `contrat-api` demande un fichier OpenAPI
**généré et versionné**, avec des types clients jamais modifiés à la main. Le mobile n'a, lui, aucune couche d'API typée.

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. Écriture manuelle (Kardinal) | Aucun outil | Dérive garantie ; aucune détection | Dette |
| B. **Génération depuis `docs/api/openapi.json`** : web `@rtk-query/codegen-openapi`, mobile `swagger_parser` | S'insère dans RTK Query comme Kardinal (`injectEndpoints`) ; modèles Dart `freezed` ; diff visible en revue | Deux outils à maintenir ; OpenAPI 3.1 à valider avec chacun | Moyen |
| C. `openapi-generator` (Java) pour les deux | Un seul outil, très complet | JRE obligatoire, sorties volumineuses et peu idiomatiques | Moyen |
| D. `openapi-typescript` + `openapi-fetch` pour le web | Très léger | Sort de RTK Query (cache, étiquettes) : rupture avec Kardinal | Moyen |

## Décision
**Option B.**

**Backend (source du contrat).** `Microsoft.AspNetCore.OpenApi` (OpenAPI 3.1, natif .NET 10) + `Microsoft.Extensions.ApiDescription.Server` écrivent `docs/api/openapi.json` à chaque build du projet `Chantier.WebApi`
(`OpenApiGenerateDocuments`, `OpenApiDocumentsDirectory = ../../../docs/api`). Pendant cette génération, le démarrage **ne doit ni migrer ni amorcer** la base
(test `Assembly.GetEntryAssembly()?.GetName().Name == "GetDocument.Insider"`). Transformateurs : schémas de sécurité (cookie, bearer), réponses Problem Details par défaut,
`operationId` stables et explicites (`Sites_List`, `Sites_Get`…), car les générateurs en déduisent les noms de hooks. Scalar reste actif en développement (comme Kardinal).

**Web.** `@rtk-query/codegen-openapi` : fichier `chantier-frontend/libs/api-core/openapi-config.ts` (`schemaFile` = `../../../docs/api/openapi.json`, `apiFile` = `ApplicationApiService`,
`outputFile` = `src/generated/chantierApi.ts`, `hooks: true`). Le fichier généré est **commité**, jamais édité ; les étiquettes de cache sont ajoutées dans `src/lib/enhancedApi.ts`
par `enhanceEndpoints` (même logique `queryCacheTagsProvider` que Kardinal). Script `npm run generate:api`.

**Mobile.** `swagger_parser` : `chantier-mobile/swagger_parser.yaml` (entrée `../docs/api/openapi.json`, sortie `lib/core/api/generated/`, client Dio, modèles `freezed` + `json_serializable`).
Le client généré reçoit l'instance Dio du `DioClient` (intercepteurs d'authentification inchangés). Fichiers générés commités. Pour la synchronisation, `changes[].data` est un objet libre
désérialisé par le modèle généré de l'entité (`SiteResponse`, `ZoneResponse`).

**Contrôle en CI** : le job backend régénère le fichier et échoue si `git diff --exit-code docs/api/openapi.json` n'est pas vide ; les jobs web et mobile régénèrent leurs clients et échouent de même.

**Vérifications à faire avant d'écrire du code applicatif (tâches B6, W3, M6) :**
1. Le fichier OpenAPI 3.1 produit par .NET 10 est lu sans erreur par `@rtk-query/codegen-openapi` (non vérifié : la page de documentation ne précise pas les versions prises en charge) et par `swagger_parser` (3.1 annoncé pris en charge, version 2.3.0 lue sur pub.dev).
   Repli web : second document nommé `v1-compat` en OpenAPI 3.0 (`OpenApiVersion = OpenApi3_0`) servant uniquement aux générateurs.
2. Si `swagger_parser` ne convient pas : modèles Dart `freezed` écrits à la main, **plus** un test de contrat qui lit `docs/api/openapi.json` et vérifie les champs ; décision à consigner dans l'ADR.

## Conséquences
- Plus facile : plus de types d'API écrits à la main ; une modification d'endpoint se voit dans un diff et casse la CI si les clients ne sont pas régénérés.
- Plus difficile : les noms d'`operationId` deviennent un contrat (les renommer renomme les hooks) ; le fichier commité doit être régénéré avant chaque PR.
- À surveiller : taille des fichiers générés ; les changements cassants sont interdits dans `/api/v1` (skill `contrat-api`).

## Vérification des générateurs (B6, backend-dotnet, 2026-11-24)
Les deux vérifications demandées sont faites sur le fichier réel `docs/api/openapi.json` (OpenAPI **3.1.1**, 26 opérations, 32 schémas), dans des dossiers temporaires, sans modifier le web ni le mobile.

| Générateur | Résultat | À savoir pour W3 / M4 |
|---|---|---|
| Web : `@rtk-query/codegen-openapi` 2.2.0 (`oazapfts` 6.3) | **Lit le 3.1 sans erreur** ; 26 hooks (`useSitesListQuery`, `useZonesCreateMutation`, `useSyncChangesQuery`…) ; le fichier généré passe `tsc --strict` | Lancer avec `esbuild-runner` (ou `ts-node`) pour lire `openapi-config.ts` ; un `apiFile` exportant `createApi` est requis. Les noms des hooks viennent des `operationId` (`Sites_List` → `useSitesListQuery`). Réponses 204 typées `unknown` |
| Mobile : `swagger_parser` | **Lit le 3.1 sans erreur** : 6 clients, 26 requêtes, 32 modèles `freezed` ; les modèles et clients **compilent et passent `dart analyze`** (seuls 8 avertissements de style dans le code généré) | **Version 1.46.0 obligatoirement** : la 2.x exige Dart ≥ 3.13 (le projet est sur Dart 3.9.2). Régler `use_freezed3: true` (sinon `freezed` 3.0 refuse les classes générées). Clients : `retrofit: 4.4.2` + `retrofit_generator: 9.1.9` compilent avec les versions figées du mobile (`analyzer 7.7.1`, `freezed 3.0.0`, `json_serializable 6.9.5`, `build_runner 2.5.4`) ; avec `retrofit_generator 9.7.0` (et `retrofit` 4.9.2 ou 4.10.0), la génération échoue (`Parser.DartMappable` non géré). Les énumérations reçoivent une valeur `$unknown` : un nouveau type de local côté serveur ne casse pas un ancien mobile |

**Décision : OpenAPI 3.1 conservé, le repli 3.0 n'est pas nécessaire** (ni le second document `v1-compat`). Repli mobile (modèles écrits à la main) non nécessaire non plus.

Le document est rendu exact et lisible par les générateurs par des transformateurs (`WebApi/OpenApi/`) : `operationId` `Contrôleur_Action`, schémas de sécurité (jeton porteur et cookie), erreurs en `ProblemDetails` partout (`code`, `traceId`, `errors`, `current`), nombres sans variante « chaîne » (ASP.NET déclarait `integer` ou `string`), énumérations en chaînes sans `null`, `required` exact (`contractAmount`, jetons de `AuthResult` facultatifs), dates métier typées, ordre des routes et des schémas trié, fins de ligne normalisées (le fichier est identique sous Windows et sous Linux).
Limites connues : `data` (pull) et `resource` / `current` (push) sont des objets libres (un seul schéma ne peut pas dépendre de `entity`) : `SiteResponse`, `ZoneResponse` et `SyncMemberData` sont tous décrits dans les composants ; les réponses 204 n'ont pas de type ; `decimal` est exprimé en `number` (`double`) : l'affichage seulement, le serveur fait foi pour les calculs.
Un test (`OpenApiContractTests`) échoue si le fichier commité n'est pas celui que le code génère ; la CI régénère (`dotnet build`) et vérifie `git diff --exit-code docs/api/openapi.json`.
