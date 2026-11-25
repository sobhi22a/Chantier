# Plan : socle technique et parcours « Mes chantiers »

**Slug :** `socle` · **User stories :** `docs/metier/socle.md` (US-SOCLE-001 à 018, hypothèses H-01 à H-20) · **Auteur :** architecte-chantier · **Statut :** Proposé

## Résumé
Créer les trois applications (`chantier-backend/`, `chantier-frontend/`, `chantier-mobile/`) en imitant Kardinal-app (`docs/architecture/reference-kardinal.md`) et livrer un parcours témoin qui marche de bout en bout :
un utilisateur se connecte sur le web ou sur le mobile, voit **« Mes chantiers »** (uniquement ceux auxquels il est affecté), ouvre la **fiche d'un chantier** avec ses **zones** (bloc, cote, local).
Sur mobile, la liste, la fiche et les zones se lisent **hors ligne** (base locale Drift alimentée par un pull à curseur serveur) et **une zone peut être créée hors ligne** : c'est le premier chemin d'écriture, qui éprouve de bout en bout la file d'envoi, l'idempotence par `clientId` et la fusion de doublons.
Le tout en français et en arabe (RTL), avec une CI qui vérifie les trois parties et le contrat OpenAPI, et la fondation de numérotation par chantier côté serveur.

Décisions : ADR `docs/adr/0001` à `0010`. Contrat : `docs/api/socle.md` puis `docs/api/openapi.json` (généré). Codes d'erreur : `docs/api/codes-erreur.md`.

## Périmètre par rapport aux user stories (`docs/metier/socle.md`)
| Story | Couverture dans ce plan | Tâches |
|---|---|---|
| 001 Se connecter · 002 Hors ligne et déconnexion · 003 Droits par rôle | Complète (hors réinitialisation par l'Admin) | B3, B4, W4, M6 |
| 004 Gérer les comptes | **Lot Administration** (hors socle) : seul l'amorçage de l'Admin et les comptes de démonstration existent | : |
| 005 Affecter | API complète (`/members`, immédiate, tracée) ; **écrans web dans le lot Administration** | B4, B5 |
| 006 Mes chantiers · 007 Fiche · 008 Créer/modifier/archiver un chantier | Complète (web pour 008) | B4, W5, M7 |
| 009 Sélecteur de zone · 010 Chantier courant · 011 Ajouter une zone | Complète pour **ajouter** une zone (web, mobile hors ligne). **Renommer et archiver hors ligne** : lot suivant ; archiver/renommer **sur le web** : inclus | B4, B5, W5, M7, M8 |
| 012 Ce qui marche sans réseau · 013 Indicateur de synchro · 014 FR/AR | Complète | M5, M7, M8, W2 |
| 015 Numérotation par chantier | Fondation serveur + tests (aucun écran) | B8 |
| 016 Qui a fait quoi | 016.1 et 016.2 (créé/modifié par et le, heure du serveur, « saisi le ») ; **016.3 historique détaillé et 016.5 journal des connexions : lot Administration** | B2, B4, W5, M7 |
| 017 Aucune donnée personnelle dans les journaux · 018 Données de démonstration | Complète | B1, B3, B7, R1, D2 |
Écart à signaler : les stories **004, 005 (écrans), 016.3 et 016.5** sont marquées « Indispensable » par l'expert métier mais ne sont pas nécessaires au parcours témoin ; elles forment le **lot Administration**, à lancer immédiatement après le socle et **avant** tout usage réel.

## Modèle de données
| Entité | Champs (nom de code) | Index et contraintes | Migration |
|---|---|---|---|
| `AppUser` (Identity) | `Id`, `UserName`, `FullName`, `Language` (`fr`/`ar`), `PhoneNumber` (sensible), `MustChangePassword`, `IsActive`, `DeactivatedAt?` | `UserName` unique | `InitialCreate` |
| `AppRole` (Identity) | `Id`, `Name` ∈ Admin, Direction, ConducteurTravaux, Achats, ChefChantier, ChefEquipe (un seul par utilisateur) | `Name` unique | `InitialCreate` |
| `RefreshToken` | `Id`, `UserId`, `TokenHash` (SHA-256), `CreatedAt`, `CreatedByIp?`, `ExpiresAt`, `RevokedAt?`, `RevokedByIp?`, `ReplacedByTokenHash?` | `TokenHash` unique ; index `UserId` | `InitialCreate` |
| `Wilaya`, `Commune` (référentiel) | `Wilaya(Code, NameFr, NameAr)`, `Commune(Id, WilayaCode, NameFr, NameAr)` | PK `Code` ; unique `(WilayaCode, NameFr)` | `InitialCreate` |
| `Site` : `BasicEntity` | `Code` (immuable), `Name`, `NameAr?`, `Type`, `Wilaya`, `Commune`, `Latitude?`, `Longitude?`, `Owner`, `ContractNumber?`, `ContractAmount?` (decimal 18,2), `DelayDays?`, `OdsDate?` (`DateOnly`), `ArchivedAt?`, `ArchivedBy?` ; calculé : `ContractualEndDate` | Unique `Code` filtré `DeletedAt IS NULL` ; index `RowVersion` | `InitialCreate` |
| `Zone` : `BasicEntity`, `ISiteScoped`, `IHasClientId` | `SiteId`, `ClientId?`, `ClientCreatedAt?`, `Block`, `Elevation?` (decimal 5,2, −20,00 à +60,00), `RoomType?`, `RoomNumber?`, `RoomLabel?`, `ArchivedAt?`, `ArchivedBy?` | Unique `(SiteId, Block, Elevation, RoomType, RoomNumber, RoomLabel)` filtré non supprimé ; unique `(SiteId, ClientId)` filtré `ClientId IS NOT NULL` ; index `(SiteId, RowVersion)` | `InitialCreate` |
| `SiteMember` : `BasicEntity`, `ISiteScoped` | `SiteId`, `UserId` | Unique `(SiteId, UserId)` filtré non supprimé ; index `UserId` ; index `(SiteId, RowVersion)` | `InitialCreate` |
| `SiteCounter` | `SiteId`, `Prefix` (`DEM`, `LIV`, `T`, `PB`, `SIT`), `LastValue` | PK `(SiteId, Prefix)` | `AddSiteCounters` (B8) |
Pas de table `Claims`/`References` (catalogue en code, ADR 0005). Conventions communes (audit, suppression logique et archivage, `RowVersion`, énumérations en chaînes) : ADR 0003.

## Contrat d'API (résumé ; détail et JSON dans `docs/api/socle.md`)
| Méthode | Route | Rôles / permission | Réponses (codes) |
|---|---|---|---|
| POST | `/api/v1/auth/login` | anonyme | 200, 400, 401 `IDENTIFIANTS_INVALIDES`, 429 `TROP_D_ESSAIS` |
| POST | `/api/v1/auth/refresh` | anonyme | 200, 401 `REFRESH_INVALIDE` / `ACCES_RETIRE`, 429 |
| POST | `/api/v1/auth/logout`, `/auth/change-password` | authentifié | 204, 401, 422 `MOT_DE_PASSE_FAIBLE` |
| GET / PUT | `/api/v1/auth/me`, `/auth/me/language` | authentifié | 200 / 204 |
| GET | `/api/v1/reference/wilayas`, `/reference/wilayas/{code}/communes` | authentifié | 200, 404 |
| GET | `/api/v1/sites`, `/sites/code-suggestion`, `/sites/{siteId}` | `Sites.View` (+ affectation) / `Sites.Create` | 200, 404 |
| POST / PUT | `/api/v1/sites`, `/sites/{siteId}` | `Sites.Create` / `Sites.Update` | 201 / 200, 400, 404, 409, 422 `CODE_CHANTIER_EXISTANT` |
| POST | `/api/v1/sites/{siteId}/archive`, `/restore` | `Sites.Delete` | 200, 404 |
| GET / POST | `/api/v1/sites/{siteId}/zones` | `Zones.View` / `Zones.Create` | 200 / 201 ou 200 (idempotent), 400, 404, 422 `ZONE_EXISTANTE`, `CHANTIER_ARCHIVE` |
| GET / PUT | `/api/v1/sites/{siteId}/zones/{zoneId}` | `Zones.View` / `Zones.Update` | 200, 404, 409 |
| POST | `/api/v1/sites/{siteId}/zones/{zoneId}/archive`, `/restore` | `Zones.Delete` | 200, 404, 422 |
| GET / PUT / DELETE | `/api/v1/sites/{siteId}/members[/{userId}]` | `SiteMembers.View` / `SiteMembers.Update` | 200, 201, 204, 404, 422 `COMPTE_DESACTIVE` |
| GET | `/api/v1/sync/changes` | authentifié | 200, 400 `CURSEUR_INVALIDE`, 404 |
| POST | `/api/v1/sync/push` | authentifié | 200, 400, 413 `LOT_TROP_GRAND` |
| GET | `/health/live`, `/health/ready` | anonyme | 200, 503 |
Codes d'erreur : `docs/api/codes-erreur.md`.

## Synchronisation hors ligne
| Entité | Créée hors ligne ? | Modifiable hors ligne ? | Politique de conflit |
|---|---|---|---|
| `Site` | Non (back-office) | Non | Lecture seule sur mobile ; le serveur gagne ; champ `contractAmount` absent sans permission |
| `Zone` | **Oui** (création, `clientId`) | Non au socle (renommer/archiver : web) | Ajout seul, création idempotente ; zone identique déjà créée par un autre : **fusion** (`duplicate` + `merged`), les saisies pointent vers la zone retenue |
| `SiteMember` | Non | Non | Lecture seule (noms et rôles, jamais de téléphone) ; une suppression produit `deleted` `member`, et `deleted` `site` pour l'utilisateur retiré |
Détail du protocole : ADR 0009.

## Interfaces
- **Web** : connexion ; changement obligatoire du mot de passe provisoire ; en-tête avec sélecteur FR/AR ; menu latéral (section « Chantiers ») ; **Mes chantiers** (tableau : code, nom dans la langue, commune/wilaya, fin contractuelle ; recherche `q`, filtre type, case « Afficher les archivés », pagination, états vide/chargement/erreur) ;
  **fiche chantier** (informations, montant selon le rôle, fin contractuelle calculée ou « À définir », zones groupées par bloc avec cote signée, personnes affectées, créé/modifié par et le) ; formulaires **chantier** (code proposé, calendrier pour l'ODS, wilaya puis commune) et **zone** ; archiver/restaurer avec confirmation ; erreurs traduites par `code`.
- **Mobile** : connexion (dernier identifiant prérempli, 3 gestes, bouton inactif pendant l'envoi) ; **Mes chantiers** (cartes lisibles en plein soleil, lecture seule depuis Drift, recherche au-delà de 5, mention « Données du … ») ; **fiche chantier** ; chantier courant visible en en-tête ;
  **sélecteur de zone** (bloc, cote, local) et **Ajouter une zone** (5 gestes, moins de 30 s, hors ligne) ; **barre d'état de synchro** sur tous les écrans et écran **Envois en attente** (liste, « Synchroniser maintenant », Corriger / Abandonner) ; réglages (langue en 2 gestes, déconnexion avec avertissement, version) ;
  écrans « Préparation de vos chantiers… » et « Première connexion : réseau nécessaire » ; bandeau « Données du … » après 24 h.

## Critères d'acceptation techniques
Les critères CA-xxx.y de `docs/metier/socle.md` restent la référence métier ; les CT ci-dessous sont les critères **vérifiables par test** du plan (la colonne de droite renvoie aux CA couverts).
| # | Critère | CA couverts |
|---|---|---|
| CT-1 | Connexion web (cookie) et mobile (jetons) ; identifiant faux, mot de passe faux et compte désactivé : **même** 401 `IDENTIFIANTS_INVALIDES` ; 5 échecs en 15 min sur un identifiant (existant ou non) : 429 `TROP_D_ESSAIS` ; double appui = une seule demande | 001.1, 001.3, 001.4, 001.6 |
| CT-2 | Refresh rotatif (14 j) : l'ancien jeton est refusé (`REFRESH_INVALIDE`) ; la réutilisation révoque la chaîne ; le changement de mot de passe révoque les refresh ; premier mot de passe provisoire : changement obligatoire | 001.7, 002.2 |
| CT-3 | Isolation : un utilisateur non affecté obtient **404 `INTROUVABLE` identique** à celui d'un chantier inexistant sur `/sites/{id}` et tous ses sous-chemins, ne le voit ni dans la liste, ni dans `q`, ni dans la synchro ; Admin voit tout, Direction seulement ses affectations | 003, 006.1, 006.2, 006.9, 007.7, 012.6 |
| CT-4 | Affectation retirée : accès coupé immédiatement ; chantier, zones et affectations disparaissent du mobile au pull suivant ; affectation ajoutée : arrivent même si anciens | 005.4, 005.5 |
| CT-5 | Toute erreur est Problem Details avec `code` et `traceId` ; aucune pile, SQL ni message interne ; aucun nom, identifiant ou téléphone dans un message | 017.2 |
| CT-6 | `createdBy/At`, `updatedBy/At` posés automatiquement depuis le jeton, jamais depuis le client ; heure du serveur ; « saisi le » du téléphone conservé à part ; archivage tracé (qui, quand) ; rien n'est supprimé physiquement | 016.1, 016.2, 016.4 |
| CT-7 | `PUT` avec `version` périmée : 409 `CONFLIT_VERSION` avec `current` ; l'interface propose de recharger | 008.9 |
| CT-8 | Pull : curseur serveur, `hasMore`, **aucun changement perdu** avec une transaction ouverte, pierres tombales ; application idempotente côté client ; reprise après coupure | 012.2, 012.4 |
| CT-9 | Push : 200 avec un résultat par opération dans l'ordre ; entité sans handler : `rejected` `ENTITE_NON_SYNCHRONISABLE` ; même `clientId` renvoyé : `duplicate` sans effet ; lot > 100 : 413 | 011.7, 013.6 |
| CT-10 | OpenAPI 3.1 généré et versionné ; la CI échoue si le fichier ou un client généré dérive | : |
| CT-11 | Web : FR et AR (RTL, chiffres 0-9, codes/dates/cotes en LTR), aucun texte en dur, erreurs traduites par `code`, actions absentes (non grisées) selon les permissions | 003.1, 014 |
| CT-12 | Mobile : « Mes chantiers », fiche et zones lisibles **hors ligne** (< 2 s) après une première synchro ; premier lancement hors ligne : message clair ; jetons en stockage sécurisé ; un refresh échoué ne supprime ni base ni file | 002.1, 006.5, 007.5, 012.1, 001.5 |
| CT-13 | CI verte (backend, web, mobile) + contrôle du contrat + contrôle des paquets interdits | : |
| CT-14 | Aucun nom, identifiant, téléphone, mot de passe ni jeton dans les journaux du serveur, du web et du mobile (parcours complet, journaux capturés) ; aucun téléphone dans les réponses sauf `me` (titulaire) | 017.1, 017.4 |
| CT-15 | Démarrage refusé sans clé JWT ≥ 32 octets ; aucun secret dans le dépôt ; en-têtes de sécurité ; CORS limité à la liste de configuration | : |
| CT-16 | Démarrage local documenté et scripté (base, API avec données de démonstration, web, mobile) | 018 |
| CT-17 | Zone : unicité `(bloc, cote, type de local, numéro, libellé)` ; `roomLabel` seulement si type `Other` ; cote hors −20,00..+60,00 refusée ; affichage signé (`−1,90`, `±0,00`, `+3,40`), trié du plus bas au plus haut | 009.2, 011.3, 011.4 |
| CT-18 | Fin contractuelle calculée par le serveur : 2026-03-02 + 540 j = 2027-08-24 ; 2026-06-15 + 420 j = 2027-08-09 ; 2026-01-15 + 30 j = 2026-02-14 ; 2027-03-01 + 366 j = 2028-03-01 ; données manquantes : `null` (« À définir ») ; date incomplète (`../03/2026`) : `DATE_INVALIDE` ; délai ≤ 0 : `QUANTITE_INVALIDE` | 007.2, 007.3, 008.4, 008.5 |
| CT-19 | Compte désactivé : plus de connexion, refresh refusé (`ACCES_RETIRE`), **jeton encore valide refusé** (≤ 60 s) ; le mobile purge les données chantier | 002.5, 004.5, 017.6 |
| CT-20 | Montant du marché **absent** des réponses et des données de synchro pour ChefChantier, ChefEquipe, Achats ; changement de `permissionsVersion` : rechargement complet sur mobile | 003.5, 007.4, 012.7 |
| CT-21 | Création de zone hors ligne : écriture locale + opération d'envoi dans **une** transaction ; renvoi = une seule zone ; deux téléphones créant la même zone : une seule zone, la seconde fusionnée sans erreur affichée ; chantier non affecté ou archivé : `rejected` visible dans « À vérifier » | 011.5, 011.6, 011.7, 011.9, 002.6, 013.7 |
| CT-22 | Numérotation : `DEM-001` par chantier, indépendante entre chantiers, **60 appels parallèles** sans doublon ni trou ; renvoi du même `clientId` ne consomme pas de numéro ; ≥ 3 chiffres, `DEM-1000` sans troncature | 015 |
| CT-23 | Téléphone partagé : à la déconnexion, aucune donnée de A visible pour B ; saisies en attente de A conservées pour A seul ; déconnexion avec envois en attente : confirmation en deux temps | 002.3, 002.4 |
| CT-24 | Indicateur de synchro : 5 états (icône **et** texte), compteurs exacts, bandeau après 24 h, double appui = une seule synchro, 200 envois en attente envoyés par lots dans l'ordre de création | 013, 012.5 |

## Découpage des tâches
Un agent par tâche. Les tâches d'un même agent sont **séquentielles**. Ordre recommandé : voir « Ordonnancement » plus bas.

| # | Agent | Tâche | Dépend de | Critères couverts |
|---|---|---|---|---|
| D0 | devops-ci | Dépôt et environnement local | : | CT-16 |
| B1 | backend-dotnet | Squelette de la solution, erreurs, sécurité de base | D0 | CT-5, CT-15 |
| B2 | backend-dotnet | Persistance, conventions EF, entités, première migration, seeders | B1 | CT-6 |
| B3 | backend-dotnet | Authentification, rôles, permissions, compte désactivé | B2 | CT-1, CT-2, CT-14, CT-19 |
| B4 | backend-dotnet | Chantiers, zones, affectations, référentiel géographique, archivage, filtre `SiteScoped` | B3 | CT-3, CT-6, CT-7, CT-17, CT-18, CT-20 |
| B5 | backend-dotnet | Synchronisation : pull, push (handler `zone`), « toucher » à l'affectation | B4 | CT-4, CT-8, CT-9, CT-20, CT-21 |
| B6 | backend-dotnet | OpenAPI généré et versionné, catalogue d'erreurs, vérification des générateurs | B5 | CT-10 |
| B7 | backend-dotnet | Données de démonstration « École UV18 » (développement seulement) | B4 | CT-3, CT-16 |
| B8 | backend-dotnet | Fondation de numérotation par chantier | B4 | CT-22 |
| W1 | frontend-react | Espace de travail Nx, bibliothèques, thème, fournisseurs | D0 | CT-13 |
| W2 | frontend-react | Bibliothèque i18n FR/AR, RTL, formateurs | W1 | CT-11, CT-17 |
| W3 | frontend-react | Client d'API généré, gestion d'erreurs Problem Details, MSW | W1, B6 | CT-5, CT-10, CT-11 |
| W4 | frontend-react | Connexion, session, permissions, mise en page | W2, W3 (B3 pour l'essai réel) | CT-1, CT-2, CT-11 |
| W5 | frontend-react | « Mes chantiers », fiche, formulaires chantier et zone, archivage | W4, B4 | CT-3, CT-7, CT-11, CT-17, CT-18, CT-20 |
| M1 | mobile-flutter | Projet Flutter Android, thème terrain, l10n, configuration | D0 | CT-12 |
| M2 | mobile-flutter | Réseau (Dio, refresh), stockage sécurisé, erreurs typées | M1 | CT-2, CT-12 |
| M3 | mobile-flutter | Base locale Drift, DAO, convertisseurs | M1 | CT-12, CT-23 |
| M4 | mobile-flutter | Client et modèles générés depuis l'OpenAPI | M2, B6 | CT-10 |
| M5 | mobile-flutter | Moteur de synchronisation, file d'envoi, état de synchro | M3, M4 | CT-4, CT-8, CT-9, CT-21, CT-24 |
| M6 | mobile-flutter | Authentification mobile, session hors ligne, téléphone partagé | M2, M3 | CT-1, CT-19, CT-23 |
| M7 | mobile-flutter | « Mes chantiers », fiche, chantier courant, barre de synchro, réglages | M5, M6 | CT-3, CT-12, CT-17, CT-20, CT-24 |
| M8 | mobile-flutter | Sélecteur de zone, ajout de zone hors ligne, « Envois en attente » | M7 | CT-17, CT-21, CT-24 |
| D1 | devops-ci | Pipeline CI et contrôles | B1, W1, M1 (contrat : B6) | CT-10, CT-13 |
| D2 | devops-ci | Démarrage local de bout en bout | B7, W5, M8 | CT-16 |
| Q1 | qa-tests | Plan de test, trous de couverture, scénarios hors ligne et RTL | D1, D2 | tous |
| R1 | revue-securite-perf | Revue sécurité et performance | B6, W5, M8 | CT-14, CT-15, CT-19, CT-20 |

### D0 : Dépôt et environnement local (devops-ci)
- Fichiers : `docker-compose.dev.yml` (SQL Server 2022, volume nommé, port 14335 → 1433, `MSSQL_PID=Developer`, mot de passe lu dans `.env`), `.env.example` (sans secret réel), `.editorconfig`, complément de `.gitignore` (`*.user`, `chantier-frontend/build/`, `**/Storage/`), `scripts/dev.ps1` (démarre la base ; le reste s'ajoute en D2).
- Rien d'autre à la racine. Branche `socle` créée par l'orchestrateur avant D0.
- Vérifier : `docker compose -f docker-compose.dev.yml up -d` puis connexion `sqlcmd`.

### B1 : Squelette backend (backend-dotnet)
- Créer `chantier-backend/` selon ADR 0001 : `Chantier.sln` (`dotnet new sln --format sln`), `global.json`, `Directory.Build.props`, `Directory.Packages.props`, trois projets et deux projets de tests, références, paquets **de la liste ci-dessous seulement**.
  Paquets : `Chantier.Core` ne référence que Ardalis.Specification 9.x et `Microsoft.Extensions.Identity.Stores` (pour `AppUser`/`AppRole`, sans EF) ; ensuite Ardalis.Specification.EntityFrameworkCore 9.x, Microsoft.EntityFrameworkCore(.SqlServer/.Design) 10.x, Microsoft.AspNetCore.Identity.EntityFrameworkCore 10.x, Microsoft.AspNetCore.Authentication.JwtBearer 10.x, Microsoft.AspNetCore.OpenApi 10.x, Microsoft.Extensions.ApiDescription.Server 10.x, Scalar.AspNetCore ;
  tests : NUnit 4 stable, NUnit3TestAdapter, NUnit.Analyzers, Moq 4.20.72, Microsoft.NET.Test.Sdk, coverlet.collector, Microsoft.AspNetCore.Mvc.Testing, Testcontainers.MsSql.
- `WebApi/Chantier.WebApi/` : `Program.cs` (pipeline calqué sur `KB\Easy\Program.cs` : configuration, clé JWT ≥ 32 octets sinon exception, `AddServerHeader=false`, CORS `Cors:Origins`, limiteur de débit, `UseGlobalExceptionHandling`, `UseSecurityHeaders`, Scalar en Development), `Middlewares/GlobalExceptionMiddleware.cs` (sortie Problem Details, table de l'ADR 0002), `Middlewares/SecurityHeadersMiddleware.cs`, `Extensions/ClaimsPrincipalExtensions.cs`, `appsettings.json` (secrets vides), `appsettings.Development.json` (port 8195), `Properties/launchSettings.json`, `GET /health/live` et `/health/ready`.
- `Core/Chantier.Core/Exceptions/` : `DomainException` (avec `Code`), `DomainRuleException`, `NotFoundException`, `ForbiddenException`, `ValidationException`, `ConflictException`, `InvalidCredentialsException`, `TooManyAttemptsException`, `AccessRevokedException` (un seul jeu).
- Journalisation : aucune donnée personnelle (identifiants GUID anonymes seulement).
- Tests : middleware (chaque exception → statut + `code`), 500 sans fuite (pile, SQL), démarrage refusé sans clé JWT, `GET /health/live` 200, test d'architecture « Core sans EF ».
- Vérifier : `dotnet build -warnaserror`, `dotnet test` verts.

### B2 : Persistance (backend-dotnet)
- `Core/Entities/Common/{BasicEntity,IHasClientId,ISiteScoped}.cs`, `Core/Abstractions/{ICurrentUser,SystemActor}.cs`, `Core/Entities/{Identity,Sites,Reference}/` (`AppUser`, `AppRole`, `RefreshToken`, `Site`, `Zone`, `SiteMember`, `Wilaya`, `Commune`), `Core/Paging/`.
- `Infrastructure/Persistence/` : `ApplicationDbContext` (Identity, conventions : filtre nommé `SoftDelete`, énumérations en chaînes, précision decimal), `AuditingInterceptor`, `RowVersionConverter` (gros-boutiste), `Configurations/*`, `DesignTimeDbContextFactory`, `Repositories/RepositoryCommon.cs`, `DependencyInjection.cs`, seeders `IdentityDbInitializer` (rôles, claims de `RolePermissionMatrix`, amorçage Admin depuis `Bootstrap:*`) et `ReferenceDataSeeder` (lit `SeedData/Reference/wilayas.json` et `communes.json` ; **les listes sont des données, pas du code** ; liste officielle à confirmer, H-14), migration `InitialCreate`.
- `WebApi/Services/HttpContextCurrentUser.cs`.
- **Vérification à faire en premier (risque majeur)** : test d'intégration prouvant (1) l'ordre des comparaisons `RowVersion` avec le convertisseur gros-boutiste, (2) l'effet de `MIN_ACTIVE_ROWVERSION()` avec une transaction ouverte. Repli documenté dans l'ADR 0003 ; si le repli est retenu, mettre l'ADR à jour.
- Tests : audit automatique (création, modification, archivage), filtre `SoftDelete`, migration appliquée sur base vide, unicités filtrées (zone avec valeurs absentes), relecture manuelle de la migration (aucun `DropTable`).

### B3 : Authentification (backend-dotnet)
- Fichiers : `Core/Identity/{IAuthService,ILoginAttemptTracker}`, `Infrastructure/Services/AuthService.cs` (calque `KB\...\AuthService.cs` : login, rotation, détection de réutilisation), `Infrastructure/Services/LoginAttemptTracker.cs` (mémoire, 5 échecs / 15 min par identifiant normalisé, existant ou non),
  `Specifications/Identity/{RefreshTokenByHashSpecification,ActiveRefreshTokensByUserSpecification}`, `WebApi/Controllers/Auth/AuthController.cs`,
  `WebApi/Authorization/{HasPermissionAttribute,PermissionAuthorizationHandler,PermissionPolicyProvider,PermissionRequirement,ActiveUserValidator}.cs`, `Core/Identity/{PermissionResources,RolePermissionMatrix}.cs`, `Program.cs` (cookie + JWT + politique de repli + limiteur `auth` partitionné), clés de protection des données persistées.
- Endpoints : `/api/v1/auth/{login,refresh,logout,change-password,me,me/language}`. `me` renvoie `permissions[]`, `permissionsVersion`, et le téléphone **du titulaire seulement**.
- `ActiveUserValidator` : `JwtBearerEvents.OnTokenValidated` et validation du cookie vérifient `IsActive` (cache ≤ 60 s) → 401 `ACCES_RETIRE`.
- Tests : CT-1, CT-2 (rotation, réutilisation, révocation au changement de mot de passe), compte désactivé avec jeton encore valide, 429 `TROP_D_ESSAIS` (identifiant inexistant compris), cookie `HttpOnly`/`SameSite`, **journaux capturés sans donnée personnelle** (CT-14), `me` liste les permissions du rôle.

### B4 : Chantiers, zones, affectations (backend-dotnet)
- Fichiers : `Core/Sites/{ISiteService,IZoneService,ISiteMemberService,ISiteAccess,IReferenceService,SiteResponse,ZoneResponse,...}`, `Core/DTOs/Sites/*`, `Core/Specifications/Sites/{SitesVisibleToUserSpecification,SiteSearchSpecification,ZonesBySiteSpecification,SiteMemberByUserSpecification,...}`,
  `Infrastructure/Services/Sites/{SiteService,ZoneService,SiteMemberService,SiteAccess,ReferenceService,SiteCodeSuggester}.cs`, `WebApi/Filters/SiteScopedAttribute.cs`, `WebApi/Controllers/Sites/{SitesController,ZonesController,SiteMembersController}.cs`, `WebApi/Controllers/Reference/ReferenceController.cs`, `WebApi/Models/Sites/*` (requêtes, annotations, `ToDto()`).
- Endpoints : tableau « Contrat d'API ». Règles : `[SiteScoped]` sur toute route `{siteId}` ; 404 identique si non affecté ; enfants lus par `(siteId, id)` ; `PUT` avec `version` (le `code` n'est pas modifiable) ; `ContractualEndDate` calculée dans l'entité ;
  `contractAmount` omis sans `ContractAmount.View` ; archivage et restauration tracés, chantier archivé = lecture seule (`CHANTIER_ARCHIVE`) ; unicités → `CODE_CHANTIER_EXISTANT` / `ZONE_EXISTANTE` ; zone : `roomLabel` seulement si `Other`, bornes de la cote paramétrables (`Zones:ElevationMin/Max`) ; `clientId` idempotent sur zone ; affectation d'un compte désactivé refusée.
- Tests : unitaires (fin contractuelle avec les **quatre cas** de CT-18, validations de zone), intégration (CT-3 avec deux utilisateurs et deux chantiers, **même réponse** pour inexistant et non affecté, CT-6, CT-7, CT-17, CT-20), test d'architecture `[SiteScoped]` présent sur toute action portant `{siteId}`.

### B5 : Synchronisation (backend-dotnet)
- Fichiers : `Core/Sync/{ISyncSource,ISyncPushHandler,ISyncClock,ISyncTouch,SyncChangeRow,SyncPullResponse,SyncPushRequest,SyncPushResult}.cs`, `Infrastructure/Sync/{SqlServerSyncClock,SyncPullService,SyncPushService,SiteSyncSource,ZoneSyncSource,MemberSyncSource,ZoneSyncPushHandler}.cs`, `WebApi/Controllers/Sync/SyncController.cs`.
- `SiteMemberService.AssignAsync` « touche » le chantier, ses zones et ses affectations (`ISyncTouch`) dans la même transaction. Les sources reçoivent les permissions de l'utilisateur (montant du marché).
- `ZoneSyncPushHandler` : droits (`Zones.Create`, affectation), chantier non archivé, idempotence `(siteId, clientId)`, fusion avec une zone identique (`duplicate` + `merged`), `clientCreatedAt` conservé, validations identiques au `POST`.
- Tests d'intégration : curseur et `hasMore` ; **transaction ouverte** (une ligne de version basse validée après une ligne de version haute n'est jamais perdue) ; pierre tombale ; retrait d'affectation → `deleted: site` et `member` ; ajout d'affectation d'un chantier ancien → reçu ; `CURSEUR_INVALIDE` ;
  push : lot vide, entité inconnue → `rejected`, zone créée puis renvoyée (`duplicate`), deux utilisateurs créant la même zone (`merged`), chantier non affecté (`INTROUVABLE` identique), chantier archivé, limite 100 opérations, 413 ; montant absent de `data` sans permission.

### B6 : OpenAPI et contrat (backend-dotnet)
- `WebApi/OpenApi/*` (transformateurs : schémas de sécurité, Problem Details par défaut, `operationId` explicites), propriétés `OpenApiGenerateDocuments` / `OpenApiDocumentsDirectory` (`../../../docs/api`), démarrage sans migration ni amorçage pendant la génération.
- Produire `docs/api/openapi.json` (commité), compléter `docs/api/codes-erreur.md`, marquer `docs/api/socle.md` comme « remplacé par le fichier généré ».
- **Vérifier les deux générateurs** (ADR 0006) : exécuter `@rtk-query/codegen-openapi` et `swagger_parser` dans un répertoire temporaire ; consigner le résultat ; appliquer le repli de l'ADR 0006 si besoin.
- Test de contrat : un test d'intégration compare le document généré au fichier commité.

### B7 : Démonstration (backend-dotnet)
- `Infrastructure/SeedData/Demo/DemoDataSeeder.cs`, actif **seulement** si `Seed:Demo = true` et environnement Development, **idempotent** (CA-018.2). Contenu : exactement `docs/metier/socle.md` §« Données de démonstration » :
  2 chantiers (`CH-ECO-UV18` : 26 zones ; `CH-LOG-OL40` : 3 zones), 7 comptes `admin.dev`, `direction.dev`, `conducteur.dev`, `achats.dev`, `chef.dev`, `equipe.dev`, `nonaffecte.dev` (noms et téléphones fictifs `0550 00 00 11` à `17`), affectations du tableau ; mot de passe lu dans `Seed:DemoPassword`
  (valeur de développement dans `appsettings.Development.json`, jamais utilisée hors Development).
- Test : compte exact (2 chantiers, 7 comptes, 26 + 3 zones), double exécution sans doublon, inactif hors Development ; les cas (a) à (f) de CA-018.4 en tests d'intégration.

### B8 : Numérotation par chantier (backend-dotnet)
- `Core/Entities/Sites/SiteCounter.cs`, `Core/Sites/ISiteNumbering.cs`, `Infrastructure/Services/Sites/SiteNumbering.cs` : incrément atomique (`UPDATE … SET LastValue = LastValue + 1 OUTPUT inserted.LastValue`, ligne créée à la première utilisation) **dans la transaction de l'entité**, formatage `PREFIX-NNN` (≥ 3 chiffres, `DEM-1000` sans troncature), migration `AddSiteCounters`. Aucune entité consommatrice au socle : le service est prêt pour les demandes (lot suivant).
- Tests d'intégration : `DEM-001` pour deux chantiers différents, **60 appels parallèles** sans doublon ni trou, annulation de transaction sans consommer de numéro, immuabilité.

### W1 : Espace de travail Nx (frontend-react)
- Créer `chantier-frontend/` selon ADR 0007 : `package.json`, `nx.json`, `tsconfig.base.json`, `eslint.config.mjs` (+ `react/jsx-no-literals`), `vitest.workspace.ts`, `apps/chantier-back-office` (Vite, port 3600, alias vers les sources des libs comme `KF\apps\kardinal-back-office\vite.config.mts`), `apps/chantier-back-office-e2e`, `libs/{api-core,authentication,state-store,user-interface,i18n}`.
- `main.tsx` (Provider Redux, `DirectionProvider`, `MantineProvider`, `Notifications`, `GlobalLoader`, `GenericErrorBoundary`, `RouterProvider`), thème Mantine (contraste élevé, police Cairo locale), `.env.development` (`VITE_BACKEND_API_BASE_URL=http://localhost:8195`).
- Vérifier : `npm ci` (sans `--legacy-peer-deps` si possible), `npx nx run-many -t lint test build typecheck` verts sur le squelette.

### W2 : i18n et RTL (frontend-react)
- `libs/i18n/src/{i18n.ts,locales/{fr,ar}/{common,auth,sites,errors}.json,useDirection.ts,formatters.ts,LanguageSwitcher.tsx,Ltr.tsx}`. Vocabulaire arabe : tableau « Vocabulaire FR / AR » de `docs/metier/socle.md` (à faire relire, H-19).
- Formateurs : date `24/11/2026`, nombre avec chiffres 0-9, montant `185 000 000,00 DZD`, cote signée (`−1,90`, `±0,00`, `+3,40`), libellé de zone `Bloc 01 · +3,40 m · Classe 02` (types de local traduits), fuseau `Africa/Algiers`.
- Tests : parité des clés FR/AR (tous les codes d'erreur de `codes-erreur.md` y compris les codes métier à venir), `dir` et `lang` posés sur `<html>`, formateurs avec les cas chiffrés, `<Ltr>` en arabe.

### W3 : Client d'API (frontend-react)
- `libs/api-core/openapi-config.ts`, `src/generated/chantierApi.ts` (généré, commité), `src/lib/enhancedApi.ts` (étiquettes `SITES`, `ZONES`, `MEMBERS`, `ME`, `REFERENCE`), `baseQuery` : `credentials: "include"`, `Accept-Language`, normalisation `ApiError`, hook `useApiErrorMessage`, test MSW d'une erreur 422 `ZONE_EXISTANTE` (message FR et AR).
- Script `npm run generate:api` ; CI : voir D1.

### W4 : Connexion et mise en page (frontend-react)
- `libs/authentication` : `SignInPage` (choix de langue avant connexion, mot de passe masquable, bouton inactif pendant l'envoi, message unique d'échec), `AuthProvider` (appelle `GET /auth/me`, applique `language`), `PermissionsGuard`, `ChangePasswordPage` (redirection si `mustChangePassword`), `SignOut` ;
  `libs/state-store` : tranche `authentication` au format Kardinal (`{ [ressource]: { View, Create, Update, Delete } }`) construite depuis `permissions[]`.
- `apps/chantier-back-office/src/app/{providers/router,layouts}` : routes `/sign-in`, `/`, `/sites`, `/sites/:siteId`, `/unauthorized` ; menu latéral avec la section « Chantiers » (une seule entrée au socle) ; en-tête avec `LanguageSwitcher` et menu utilisateur.
- Tests : garde de route (permission absente → `/unauthorized`), redirection non connecté, bascule de langue mémorisée (`PUT /auth/me/language`).

### W5 : Mes chantiers et fiche (frontend-react)
- `apps/chantier-back-office/src/features/sites/{components,containers,sections,services,types}` : `SitesBrowser` (liste paginée, `q`, filtre type, archivés), `SiteDetail` (infos, montant selon le rôle, fin contractuelle ou « À définir », zones par bloc, affectations en lecture seule, créé/modifié par), `SiteForm` (react-hook-form + Zod ; code proposé par `code-suggestion` ; calendrier pour l'ODS ; wilaya puis commune avec saisie libre en repli ; délai en jours),
  `ZoneForm` (bloc, cote, type de local, numéro, libellé libre si « Autre »), archiver/restaurer avec confirmation, états vide/chargement/erreur, `409 CONFLIT_VERSION` (« Modifié entre-temps par … », proposer de recharger).
- Actions **absentes** (non grisées) sans la permission correspondante. Les écrans d'affectation et de comptes sont dans le lot Administration.
- Tests : rendu FR et AR de la liste et de la fiche, formulaires (validation Zod + erreurs serveur), conflit 409, cote signée, montant absent pour un rôle sans droit.

### M1 : Projet Flutter (mobile-flutter)
- `flutter create --platforms android --org dz.chantier --project-name chantier_mobile chantier-mobile`, `pubspec.yaml` (dépendances de l'ADR 0008, versions compatibles Flutter 3.35.7 / Dart 3.9 résolues par `flutter pub add`), `analysis_options.yaml`, `lib/{main.dart,app.dart,core/{config,di,router,theme,l10n,widgets}}`, `l10n.yaml`, `lib/l10n/app_{fr,ar}.arb`, police Cairo en assets, `AppConfig` (`--dart-define`), thème terrain (contraste, cibles 48/56 dp, texte ≥ 16 sp), widget `LtrText`, configuration réseau Android (HTTP en clair en debug seulement).
- Vérifier : `flutter pub get`, `dart run build_runner build`, `flutter analyze`, `flutter test` verts ; `flutter build apk --debug` (nécessite les licences Android acceptées : action utilisateur).

### M2 : Réseau et stockage sécurisé (mobile-flutter)
- `core/network/{dio_client.dart,api_exception.dart,auth_interceptor.dart}`, `core/storage/secure_token_store.dart`, `core/network/connectivity_monitor.dart`.
- Comportement : Bearer, un rejeu après refresh, Dio nu pour le refresh, **un échec de refresh ne supprime que les jetons** (état `authRequired`) ; `ACCES_RETIRE` déclenche la purge des données chantier ; `Accept-Language` ; Problem Details → `ApiException(code, status, traceId)`.
- Tests : 401 → refresh → rejeu ; refresh refusé → jetons effacés, base et file intactes ; `ACCES_RETIRE` ; 429 ; Problem Details ; absence de jetons dans les journaux.

### M3 : Base locale (mobile-flutter)
- `database/{app_database.dart,tables/{sites,zones,site_members,outbox_operations,sync_state,user_prefs}.dart,daos/*,converters/{decimal_text,date_only_text}.dart}`, schéma versionné et exporté (`drift_dev schema`), test de migration.
- Le montant du marché n'a **pas de colonne** si la permission manque : la colonne est nullable et reste vide.
- Tests : DAO en mémoire (upsert idempotent par version, suppression en cascade site → zones et affectations, flux réactifs, purge à la déconnexion qui conserve la file), convertisseurs (`-1.90`, `0.00`, `185000000.00` sans perte).

### M4 : Client généré (mobile-flutter)
- `swagger_parser.yaml`, `lib/core/api/generated/*` (commités), script documenté. Si l'ADR 0006 impose le repli : modèles écrits à la main + test de contrat sur `docs/api/openapi.json`.
- Tests : désérialisation de `SiteResponse`, `ZoneResponse` et de la réponse de synchro avec les exemples de `docs/api/socle.md`.

### M5 : Moteur de synchronisation (mobile-flutter)
- `core/sync/{sync_engine.dart,sync_status.dart,sync_status_cubit.dart,outbox_repository.dart,backoff.dart}`, `features/sites/data/{sites_remote_source.dart,sites_repository.dart}`.
- Comportement : ADR 0009 (exécution unique, push par lots de 50 dans l'ordre de création, pull jusqu'à `hasMore=false`, application transactionnelle d'une page, `deleted` en cascade, `CURSEUR_INVALIDE` ou changement de `permissionsVersion` → reprise à zéro **sans toucher à la file**, `owner_user_id`, `merged` → rattachement des saisies à la zone retenue, toutes les 5 min au premier plan).
- Tests (API simulée) : première synchro paginée et reprise après coupure ; hors ligne ; 401 ; 429 avec attente ; `applied`/`duplicate`/`merged`/`conflict`/`rejected` ; appels concurrents partagés ; retrait d'affectation ; écriture locale et opération d'envoi dans la même transaction (test de rollback) ; 200 envois en attente par lots ; seules les lignes du compte connecté sont envoyées.

### M6 : Authentification mobile (mobile-flutter)
- `features/auth/{domain,data,presentation}` (calque `KM\lib\features\auth`) : `AuthBloc` (vérifier session, connexion, déconnexion), écran de connexion FR/AR (langue choisissable avant connexion, dernier identifiant prérempli, message unique d'échec, bouton inactif pendant l'envoi, « Première connexion : réseau nécessaire » avec « Réessayer »), redirection GoRouter via `GoRouterRefreshStream`,
  session utilisable hors ligne si le dernier contact serveur a moins de 14 jours, changement obligatoire du mot de passe provisoire, **déconnexion** : écran « N saisies ne sont pas encore envoyées » (Envoyer d'abord / Rester connecté en premier, « Se déconnecter quand même » en dernier avec seconde confirmation), purge des données synchronisées, file conservée pour son propriétaire ; `ACCES_RETIRE` : message « Accès retiré, contactez votre administrateur ».
- Tests : `bloc_test` (connexion ok/ko, trop d'essais, hors ligne avec session valide ou trop ancienne, compte retiré), widgets FR et AR, téléphone partagé A puis B (CT-23).

### M7 : Mes chantiers, fiche, chantier courant, synchro (mobile-flutter)
- `features/sites/presentation/{sites_cubit.dart,sites_screen.dart,site_detail_screen.dart}`, `core/widgets/sync_status_bar.dart` (cinq états, icône **et** texte, tous les écrans), `core/widgets/stale_data_banner.dart`, `features/settings/*` (langue en 2 gestes, version, déconnexion), `core/sync/current_site.dart` (chantier courant par utilisateur, CA-010).
- Lecture **uniquement** depuis Drift ; tirer pour synchroniser ; recherche au-delà de 5 chantiers ; archivés masqués avec filtre ; liste vide (« Aucun chantier ne vous est affecté… » + Actualiser) ; chantier courant retiré → message et nouveau choix ; premier lancement hors ligne ; « Préparation de vos chantiers… » ; noms dans la langue (`nameAr`) ; montant seulement si présent ; zones groupées par bloc, cote signée ; fiche complète hors ligne (coordonnées écrites à la place de la carte).
- Tests : widgets en FR et AR (RTL, codes/dates/cotes en LTR, chiffres 0-9), liste vide, hors ligne, chantier retiré après synchro, montant absent, indicateur exact (CT-24).

### M8 : Zones hors ligne et « Envois en attente » (mobile-flutter)
- `features/zones/{domain,data,presentation}` : `ZonePicker` (réutilisable : bloc, puis cote, puis local ; dernière zone préchoisie ; pastilles puis recherche au-delà de 8 valeurs), `AddZoneScreen` (« + Zone » ; bloc et cote préchoisis ; type de local en liste ; numéro avec « + / − » ; « Autre cote » avec clavier numérique ; unité en mètres non modifiable ; doublon : ouvrir la zone existante ; **5 gestes depuis Mes chantiers, moins de 30 s**), visible seulement pour ChefChantier et ConducteurTravaux.
- `features/sync_queue/presentation/pending_operations_screen.dart` : liste (type, libellé, saisi le, état), « Synchroniser maintenant », **Corriger** / **Abandonner** (confirmation) pour les opérations à vérifier, motif traduit par `code`.
- Tests : création hors ligne puis synchro (CT-21), renvoi, fusion `merged`, chantier retiré (CA-002.6 → « À vérifier »), double appui, cote hors plage, widgets FR et AR.

### D1 : CI (devops-ci)
- `azure-pipelines.yml` (3 jobs + étape « paquets interdits » + contrôle du contrat) selon ADR 0010 ; `scripts/ci/check-banned-packages.ps1` ou `.sh` ; mise en cache NuGet, npm, pub, Flutter. Dépend de B1, W1 et M1 pour exister ; l'étape « contrat » s'active après B6.
- Mesurer et consigner la durée réelle de chaque job.
- **Réalisé (2026-11-24, devops-ci) :** `azure-pipelines.yml`, `scripts/ci/{check-banned-packages.ps1,check-generated-drift.sh,banned-packages.allow}`, `docs/exploitation/ci.md`. Étape contrat en `--optional` jusqu'à B6 ; durées d'agent à consigner après la première exécution sur Azure (aucun serveur distant à ce jour).

### D2 : Démarrage local (devops-ci)
- `scripts/dev.ps1` complet (base, API avec `Seed:Demo=true`, web, mobile avec `--dart-define=API_BASE_URL`), `docs/exploitation/demarrage-local.md` (prérequis dont `flutter doctor --android-licenses`, ports 8195/3600, comptes de démonstration `*.dev` et origine du mot de passe de développement, `adb reverse` pour un vrai téléphone, dépannage).
- **Réalisé (2026-11-24, devops-ci) :** `scripts/dev.ps1` (`-Api`, `-Web`, `-All`, `-Mobile [-Phone]`, `-Status`, `-Down`, `-Reset`), `docs/exploitation/demarrage-local.md`. API et web testés (comptes `*.dev` : 2, 1 et 0 chantiers) ; mobile non testé faute d'émulateur ni d'`adb`.

### Q1 : QA (qa-tests)
- `docs/qa/socle.md` : matrice CT-1 à CT-24 et CA de `docs/metier/socle.md` → test automatisé ou scénario manuel ; exécuter toutes les suites ; ajouter les tests manquants ; scénario hors ligne sur émulateur (connexion, synchro, mode avion, ouverture liste et fiche, ajout d'une zone, retour réseau, retrait d'affectation) ;
  contrôle visuel RTL (captures FR/AR du web et du mobile) ; Playwright : connexion puis Mes chantiers ; recherche des téléphones fictifs, noms et jetons dans tous les journaux (CA-017.1).

### R1 : Revue sécurité et performance (revue-securite-perf)
- `docs/revues/<date>-socle.md` : authentification et cookies, désactivation de compte, blocage par identifiant, CORS, limitation de débit sur réseau partagé, refresh 14 jours, `SiteScoped` exhaustif et réponse 404 identique, champs réservés (montant), journaux sans donnée personnelle, secrets ;
  performance : plans de requête du pull (index `RowVersion`), taille d'une première synchro, taille de l'APK, démarrage à froid sur appareil modeste.

## Ordonnancement
```
D0 ──► B1 ─► B2 ─► B3 ─► B4 ─► B5 ─► B6        B7 et B8 après B4
 │                                  │
 ├──► W1 ─► W2 ─────────────────────┼──► W3 ─► W4 ─► W5
 └──► M1 ─► M2 ∥ M3 ───────────────┴──► M4 ─► M5 ─► M7 ─► M8 ◄─ M6 (avant M7)
D1 dès B1+W1+M1 (contrat après B6) ; D2 après B7+W5+M8 ; puis Q1 ∥ R1 ; corrections ; validation métier.
```
- Le skill `/socle` lance le backend puis les clients. **Gain de temps sans risque** : W1, W2, M1, M2, M3 ne dépendent d'aucun endpoint ; ils peuvent tourner pendant B1 à B6 (dossiers distincts, aucune écriture commune).
- Premier jalon démontrable : après B4 + B7, un conducteur appelle `/sites` dans Scalar avec `conducteur.dev` et voit 2 chantiers, `chef.dev` en voit 1 et `nonaffecte.dev` aucun.

## Stratégie de test
Voir ADR 0010. Unitaires : règles de domaine (fin contractuelle, zones, jetons). Intégration (SQL Server réel) : isolation, audit, concurrence, curseur de synchro avec transaction ouverte, numérotation parallèle, migrations, erreurs sans fuite, journaux sans donnée personnelle.
Web : composants FR/AR, MSW, parité i18n, Playwright. Mobile : Cubit/Bloc, DAO en mémoire, moteur de synchro simulé, widgets FR/AR. Hors ligne : scénario manuel scripté sur émulateur.

## Hypothèses d'architecture (les hypothèses métier H-01 à H-20 sont dans `docs/metier/socle.md`)
1. **SQL Server 2022** (ADR 0003) ; hébergement de production non fixé ; photos sur disque (ADR 0004).
2. Admin seul voit tous les chantiers (`AllSites.View`, H-02) ; matrice de permissions de l'ADR 0005 issue de « Droits par rôle » ; Q-02 et Q-05 changent une claim, pas du code.
3. Identifiant d'application mobile `dz.chantier.terrain` ; Android seul au socle ; ports 8195 (API) et 3600 (web).
4. Refresh de 14 jours (H-05), accès de 15 min, cookie web de 8 h glissants ; blocage 5 échecs / 15 min en mémoire (instance unique).
5. CI Azure Pipelines par imitation de Kardinal ; plateforme réelle à confirmer à la création du dépôt distant.
6. Synchro automatique toutes les 5 minutes au premier plan (CA-013.4, paramétrable).
7. Listes de wilayas et communes : **données** chargées depuis des fichiers modifiables, liste officielle à confirmer (Q-11) ; saisie libre de la commune en repli.
8. `clientId` facultatif pour les zones créées au back-office ; absent pour les chantiers.
9. Écran de renommage/archivage de zone **hors ligne** et édition d'un chantier au mobile : hors socle.

## Risques
| Risque | Probabilité | Impact | Parade |
|---|---|---|---|
| Convertisseur `RowVersion` gros-boutiste ou comparaisons EF incorrects : curseur faux | Moyenne | Élevé (pertes de données de synchro) | Test d'intégration dès B2 avec transaction ouverte ; repli `FromSql` (ADR 0003) |
| OpenAPI 3.1 mal lu par `@rtk-query/codegen-openapi` ou `swagger_parser` | Moyenne | Moyen | Vérification en B6 ; document 3.0 de repli ; modèles Dart manuels + test de contrat (ADR 0006) |
| Paquets Flutter incompatibles avec Flutter 3.35.7 / Dart 3.9 | Moyenne | Moyen | Résoudre les versions à la création (M1) ; ne pas monter Flutter sans ADR |
| Tests Drift en mémoire exigent SQLite natif sur le poste Windows | Moyenne | Faible | Documenter dans D2 ; exécution fiable sur l'agent Linux de CI |
| Toolchain Android non prête (licences) | Certaine | Moyen | Action utilisateur avant M1 ; sinon `flutter test` seulement |
| Conteneur SQL Server trop gourmand sur le poste | Faible | Moyen | `MSSQLLocalDB` en repli ; 2 Go de mémoire suffisent au socle |
| Limitation de débit bloquant plusieurs utilisateurs derrière une même adresse | Moyenne | Moyen | Partition IP + identifiant (ADR 0005) ; revue R1 |
| Traductions arabes imprécises | Moyenne | Moyen | Relecture par un arabophone du terrain (Q-12) avant livraison |
| Fusion de zones identiques créées par deux téléphones : cas limites (zone archivée entre-temps, saisies déjà rattachées) | Moyenne | Moyen | Règles dans B5 + tests ; en cas de doute, `rejected` visible plutôt que fusion silencieuse |
| Périmètre : stories « Indispensable » 004, 005 (écrans), 016.3, 016.5 hors socle | Certaine | Moyen | Lot Administration immédiatement après, avant tout usage réel ; à confirmer par l'utilisateur |
| Données personnelles sur le téléphone dès les intervenants (lots suivants) | Moyenne | Élevé | Chiffrement SQLCipher exigé avant la synchro de toute donnée personnelle (ADR 0008) ; au socle : noms des affectés seulement, jamais de téléphone |

## Décisions
`docs/adr/0001-organisation-solution-dotnet.md` · `0002-routes-erreurs-et-contrat-api.md` · `0003-base-de-donnees-et-conventions-ef-core.md` · `0004-stockage-des-photos.md` ·
`0005-authentification-roles-et-affectation-chantier.md` · `0006-generation-des-clients-depuis-openapi.md` · `0007-web-routeur-etat-formulaires-ui-i18n.md` ·
`0008-mobile-etat-navigation-base-locale-i18n.md` · `0009-synchronisation-hors-ligne.md` · `0010-tests-et-ci.md`. Référence : `docs/architecture/reference-kardinal.md`.

## Lots suivants (priorisés par valeur terrain × risque × dépendances)
1. **Administration** : comptes (création, désactivation, réinitialisation, changement de rôle), écrans d'affectation web, historique détaillé et journal des connexions (US-004, 005, 016.3, 016.5), liste de référence des wilayas/communes éditable. Prérequis de tout usage réel.
2. **Demandes de matériaux et livraisons** (`DEM-`, `LIV-`) : première fonctionnalité métier, réutilise `ISiteNumbering`, le handler de push et la file d'envoi ; plus forte valeur pour le chef de chantier.
3. **Journal du jour, pointage, problèmes et photos** (envoi des binaires, SkiaSharp, chiffrement de la base locale avant les intervenants).
4. **Tâches, avancement et coulages** (avancement pondéré, volumes et ciment théorique).
5. **Situations des sous-traitants et métrés** (expressions, montants, arrondi « loin de zéro »).

## Fini quand
- [ ] Tous les critères CT-1 à CT-24 sont couverts par des tests qui passent (ou un scénario manuel consigné pour le hors ligne sur émulateur)
- [ ] QA et revue sans défaut Bloquant ni Majeur
- [ ] CI verte sur les trois parties et sur le contrat
- [ ] `docs/exploitation/demarrage-local.md` testé sur un poste propre
- [ ] Validation métier « conforme » de `docs/metier/socle.md` pour le périmètre ci-dessus
