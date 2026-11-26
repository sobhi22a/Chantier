# Contrat d'API : socle (v1)

**Auteur :** architecte-chantier · **Date :** 2026-11-24 · **Statut :** **Remplacé par le fichier généré [`docs/api/openapi.json`](openapi.json)**, qui fait foi (B6). Ce document reste une **lecture guidée** (règles, exemples) ; en cas de différence, le fichier généré l'emporte.
**Sources :** skill `contrat-api`, ADR 0002, 0005, 0006, 0009, user stories `docs/metier/socle.md`.
**Mise à jour backend (B5, B6, 2026-11-24)** : ajouts **additifs** acceptés par l'orchestrateur : `archivedByName` (chantier et zone), `clientCreatedAt` (zone), `403 MOT_DE_PASSE_A_CHANGER`, `429 TROP_DE_REQUETES`, `siteId` facultatif de `GET /sync/changes`, `siteId` par opération de `POST /sync/push`, `archive` / `restore` (pas de `DELETE`), paramètre `limit` du pull. Détail dans les sections concernées.

**Régénérer le fichier** : `dotnet build` (le projet `Chantier.WebApi` écrit `docs/api/openapi.json`) ; un test échoue si le fichier commité n'est pas celui du code. Noms d'opérations (`operationId`, = noms des hooks et méthodes générés) : `Contrôleur_Action`, par exemple `Auth_Login`, `Sites_List`, `Zones_Create`, `Sync_Changes`, `Sync_Push` : les renommer est un changement de contrat.

Conventions : préfixe `/api/v1`, corps de requête limité à 64 Ko (1 Mo pour le push), réponses JSON compressées (`Accept-Encoding: br, gzip`), JSON en `camelCase`, énumérations en chaînes, horodatages UTC (`2026-11-24T10:15:00Z`), dates métier `2026-11-24`.
Toutes les routes exigent une authentification (cookie ou bearer) sauf mention contraire. Toute erreur est `application/problem+json` (`docs/api/codes-erreur.md`).
**Aucune suppression physique** : « supprimer » = archiver (chantier, zone) ou retirer (affectation), toujours tracé (H-13).

## Authentification

| Méthode | Route | Accès | Requête | Réponses |
|---|---|---|---|---|
| POST | `/auth/login` | anonyme, limité | `{ userName, password, isAppMobile }` | 200 · 400 `VALIDATION` · 401 `IDENTIFIANTS_INVALIDES` (identifiant ou mot de passe faux **ou compte désactivé**, message unique) · 429 `TROP_D_ESSAIS` (+ `Retry-After`) |
| POST | `/auth/refresh` | anonyme, limité | `{ refreshToken }` | 200 · 401 `REFRESH_INVALIDE` · 401 `ACCES_RETIRE` (compte désactivé) · 429 |
| POST | `/auth/logout` | authentifié | `{ refreshToken? }` | 204 |
| GET | `/auth/me` | authentifié | | 200 · 401 |
| PUT | `/auth/me/language` | authentifié | `{ language: "fr" \| "ar" }` | 204 |
| POST | `/auth/change-password` | authentifié | `{ currentPassword, newPassword }` | 204 · 401 · 422 `MOT_DE_PASSE_FAIBLE` |

`isAppMobile = false` : cookie de session + `{ user }`. `isAppMobile = true` : en plus `accessToken` (15 min), `refreshToken` (14 jours, rotatif), `expiresIn` (secondes).
**`POST /auth/refresh`** (mobile) : corps `{ "refreshToken": "q3…" }` ; réponse 200 = **la même forme que la connexion mobile** (schéma `AuthResult`) : `{ "user": {…}, "accessToken": "eyJ…", "refreshToken": "<nouveau>", "expiresIn": 900 }`. Le jeton de rafraîchissement est **rotatif** : le nouveau remplace l'ancien, qui n'est plus accepté (`REFRESH_INVALIDE`) ; **conserver le nouveau avant toute autre chose**. Réutiliser un ancien jeton révoque toute la chaîne. Compte désactivé : 401 `ACCES_RETIRE`. Un client qui n'a besoin que des jetons lit `accessToken`, `refreshToken`, `expiresIn` et peut ignorer `user`.
**Session web** : cookie `HttpOnly`, expiration glissante de 8 h avec **plafond absolu de 12 h** depuis la connexion ; `POST /auth/logout` et le changement de mot de passe **invalident les cookies déjà émis** (le cookie rejoué reçoit 401 `NON_AUTHENTIFIE`) ; après `change-password`, la session qui l'a demandé reçoit un cookie neuf. Les jetons mobiles ne sont pas touchés par la déconnexion web, ni l'inverse. **Renouvellement perdu** (mobile) : le renvoi de l'ancien jeton de rafraîchissement dans les 30 s qui suivent son remplacement, tant que son successeur n'a pas servi, reçoit un nouveau jeton sans brûler la chaîne.
**Mot de passe provisoire** : tant que `mustChangePassword` vaut vrai, toute route répond 403 `MOT_DE_PASSE_A_CHANGER`, sauf `GET /auth/me`, `PUT /auth/me/language`, `POST /auth/change-password` et `POST /auth/logout`. **Débit** : au-delà de la limite, 429 `TROP_DE_REQUETES` (`Retry-After` en secondes) ; la limite s'applique **avant** l'autorisation : un seau par utilisateur connecté, un seau par adresse IP pour les appels sans identité valide (sans jeton, jeton invalide ou expiré), donc les 401 répétés d'une même adresse finissent en 429 sans pénaliser les utilisateurs connectés derrière elle ; sur la connexion, 5 échecs en 15 minutes sur un identifiant : 429 `TROP_D_ESSAIS`.
Un compte désactivé ne peut ni se connecter, ni rafraîchir, ni appeler l'API avec un jeton encore valide (vérifié à chaque requête, cache ≤ 60 s).
```json
// 200 /auth/login (mobile)
{ "user": { "id": "0192…", "userName": "chef.dev", "fullName": "Mourad B.", "role": "ChefChantier",
            "language": "fr", "mustChangePassword": false },
  "accessToken": "eyJ…", "refreshToken": "q3…", "expiresIn": 900 }
// 200 /auth/me  (le téléphone n'est renvoyé qu'au titulaire du compte, H-17)
{ "id": "0192…", "userName": "chef.dev", "fullName": "Mourad B.", "phoneNumber": "0550 00 00 15", "role": "ChefChantier",
  "language": "fr", "permissions": ["Sites.View","Zones.View","Zones.Create","Zones.Update","SiteMembers.View"],
  "permissionsVersion": "a41f09c2", "mustChangePassword": false }
```
`permissionsVersion` = empreinte des permissions : si elle change, le mobile repart de zéro pour la synchro (sa file d'envoi est conservée), car les champs visibles ont pu changer (ex. montant du marché).

## Référentiel géographique (H-14)

| Méthode | Route | Permission | Réponses |
|---|---|---|---|
| GET | `/reference/wilayas` | authentifié | 200 `[ { code, nameFr, nameAr } ]` |
| GET | `/reference/wilayas/{code}/communes` | authentifié | 200 `[ { nameFr, nameAr } ]` · 404 |
Données lues en base, alimentées par un fichier de données modifiable (pas de liste dans le code). Liste officielle à confirmer (Q-11) : le formulaire accepte une commune hors liste (saisie libre).

## Chantiers (`Site`)

| Méthode | Route | Permission | Requête | Réponses |
|---|---|---|---|---|
| GET | `/sites` | `Sites.View` | `?q=&type=&wilaya=&includeArchived=false&sort=name&page=1&pageSize=50` | 200 `{ items, page, pageSize, totalCount }` |
| GET | `/sites/code-suggestion` | `Sites.Create` | `?type=School&name=École UV18` | 200 `{ code }` (ex. `CH-ECO-UV18`, suffixe `-2` si pris) |
| GET | `/sites/{siteId}` | `Sites.View` + affectation | | 200 · 404 |
| POST | `/sites` | `Sites.Create` | `CreateSiteRequest` | 201 (+ `Location`) · 400 · 403 · 422 `CODE_CHANTIER_EXISTANT` |
| PUT | `/sites/{siteId}` | `Sites.Update` + affectation | `UpdateSiteRequest` (avec `version`, **sans** `code` : immuable) | 200 · 400 · 404 · 409 `CONFLIT_VERSION` |
| POST | `/sites/{siteId}/archive` | `Sites.Delete` | | 200 `SiteResponse` · 404 |
| POST | `/sites/{siteId}/restore` | `Sites.Delete` | | 200 `SiteResponse` · 404 |

`GET /sites` ne renvoie que les chantiers affectés (Admin : tous, permission `AllSites.View`) ; les archivés seulement avec `includeArchived=true` ; un chantier non affecté n'apparaît jamais (même dans `q`).
```json
// SiteResponse
{ "id": "0192…", "code": "CH-ECO-UV18", "name": "École UV18", "nameAr": null, "type": "School",
  "wilaya": "Blida", "commune": "Boufarik", "latitude": 36.575000, "longitude": 2.912000,
  "owner": "Direction des équipements publics (fictive)", "contractNumber": "M-2026-UV18-001",
  "contractAmount": 185000000.00, "delayDays": 540, "odsDate": "2026-03-02", "contractualEndDate": "2027-08-24",
  "archivedAt": null, "archivedByName": null, "version": "48213", "createdAt": "2026-11-24T08:00:00Z", "createdByName": "Farid L.",
  "updatedAt": null, "updatedByName": null }
```
- `archivedByName` : nom de la personne qui a archivé (ajout additif). `contractAmount` est **absent** (clé non écrite) sans `ContractAmount.View` : il n'est donc pas obligatoire dans le schéma.
- `type` ∈ `School`, `Housing`, `PublicFacility`, `Other`. `code` : `^[A-Z0-9][A-Z0-9-]{2,29}$`, unique, immuable. `name` obligatoire (≤ 200), `nameAr` facultatif (affiché si présent, sinon `name`).
- `contractAmount` : DZD, 2 décimales, ≥ 0 ; **omis de la réponse** (et des données de synchro) sans la permission `ContractAmount.View` (Admin, Direction, ConducteurTravaux) : ce n'est pas seulement masqué à l'écran (CA-003.5, CA-012.7).
- `delayDays` : entier > 0, sinon 422 `QUANTITE_INVALIDE` ; `odsDate` : date complète, sinon 400 `DATE_INVALIDE` ; `contractualEndDate` = `odsDate` + `delayDays` jours, **calculée par le serveur**, `null` si l'un des deux manque (« À définir »).
- Exemples vérifiés : 2026-03-02 + 540 j = 2027-08-24 ; 2026-06-15 + 420 j = 2027-08-09 ; 2026-01-15 + 30 j = 2026-02-14 ; 2027-03-01 + 366 j = 2028-03-01 (2028 bissextile).
- Un chantier archivé reste lisible et ne reçoit plus de saisie (`CHANTIER_ARCHIVE`, 422).

## Zones (`Zone`)

| Méthode | Route | Permission | Requête | Réponses |
|---|---|---|---|---|
| GET | `/sites/{siteId}/zones` | `Zones.View` | `?block=&q=&includeArchived=false&pageSize=100&cursor=` | 200 `{ items, nextCursor }` · 404 |
| GET | `/sites/{siteId}/zones/{zoneId}` | `Zones.View` | | 200 · 404 |
| POST | `/sites/{siteId}/zones` | `Zones.Create` | `{ clientId?, clientCreatedAt?, block, elevation?, roomType?, roomNumber?, roomLabel? }` | 201 · 200 (même `clientId` renvoyé : même ressource) · 400 · 404 · 422 `ZONE_EXISTANTE` / `CHANTIER_ARCHIVE` |
| PUT | `/sites/{siteId}/zones/{zoneId}` | `Zones.Update` | mêmes champs + `version` | 200 · 404 · 409 `CONFLIT_VERSION` · 422 |
| POST | `/sites/{siteId}/zones/{zoneId}/archive` | `Zones.Delete` | | 200 `ZoneResponse` · 404 |
| POST | `/sites/{siteId}/zones/{zoneId}/restore` | `Zones.Delete` | | 200 · 404 · 422 `ZONE_EXISTANTE` |

```json
// ZoneResponse
{ "id": "0192…", "siteId": "0192…", "clientId": null, "clientCreatedAt": null, "block": "Bloc 01", "elevation": 3.40,
  "roomType": "Classroom", "roomNumber": 2, "roomLabel": null, "archivedAt": null, "archivedByName": null, "version": "48230",
  "createdAt": "2026-11-24T08:05:00Z", "createdByName": "Farid L.", "updatedAt": null, "updatedByName": null }
```
- `block` obligatoire (≤ 50). `elevation` en mètres, `decimal` 2 décimales, de −20,00 à +60,00 (borne paramétrable, H-15), sinon 400 `VALIDATION`.
- `roomType` ∈ `Classroom`, `Corridor`, `Canteen`, `Refectory`, `Kitchen`, `Office`, `Sanitary`, `TechnicalRoom`, `Facade`, `Other` ; `roomNumber` entier ≥ 1 ; `roomLabel` (≤ 100) **seulement** si `roomType = Other`.
- Unicité par chantier de `(block, elevation, roomType, roomNumber, roomLabel)` (valeurs absentes comprises) : `ZONE_EXISTANTE` (422) en création et restauration. Affichage client : `Bloc 01 · +3,40 m · Classe 02` ; une zone sans local est un bloc ou une cote seule.
- `clientCreatedAt` : heure du téléphone à la saisie, **information** conservée à part (« saisi le »), jamais utilisée pour trier ou décider.

## Affectations (`SiteMember`)

| Méthode | Route | Permission | Réponses |
|---|---|---|---|
| GET | `/sites/{siteId}/members` | `SiteMembers.View` | 200 `{ items: [{ userId, fullName, role, assignedAt }] }` · 404 |
| PUT | `/sites/{siteId}/members/{userId}` | `SiteMembers.Update` | 201 (créée) · 200 (« Déjà affecté ») · 404 · 422 `COMPTE_DESACTIVE` |
| DELETE | `/sites/{siteId}/members/{userId}` | `SiteMembers.Update` | 204 (idempotent) · 404 |
Ni téléphone ni identifiant de connexion dans cette réponse. L'accès est coupé **immédiatement** au retrait (vérification à chaque requête). Affecter touche le chantier et ses lignes synchronisées (ADR 0009). Retrait = suppression logique tracée (qui, quand).

## Synchronisation

| Méthode | Route | Requête | Réponses |
|---|---|---|---|
| GET | `/sync/changes` | `?since=<curseur>&siteId=<facultatif>&limit=200` | 200 · 400 `CURSEUR_INVALIDE` ou `VALIDATION` (`limit` hors 1..500) · 404 (`siteId` non affecté) |
| POST | `/sync/push` | `{ operations: [...] }` (≤ 100 opérations, ≤ 1 Mo ; une opération `null` : 400 `VALIDATION`) | 200 · 400 · 413 `LOT_TROP_GRAND` |

Entités synchronisées au socle (lecture) : `site`, `zone`, `member` (`data` = `SiteResponse`, `ZoneResponse`, `SyncMemberData` = `{ id, siteId, userId, fullName, role, assignedAt }`, jamais de téléphone). Entité écrivable : `zone` (`create`).
**Pull** : `since` absent ou `0` = première synchronisation ; sinon le curseur reçu du serveur (chaîne opaque, **jamais l'horloge du téléphone**). `limit` : 200 par défaut, 500 au maximum. Répéter l'appel avec le `cursor` reçu tant que `hasMore` vaut vrai ; une ligne n'est appliquée que si sa `version` est plus grande que celle déjà connue. Aucun changement n'est perdu même si une transaction du serveur est encore ouverte (curseur borné par `MIN_ACTIVE_ROWVERSION()`, ADR 0003). Même `since`, même page : la reprise après coupure est sans risque. **Ordre** : les pages suivent l'ordre des versions (le curseur est la version de la dernière ligne) ; à l'intérieur d'une page, `changes` est rangé **parents avant enfants** (`site`, `product`, `supplier`, puis `zone` et `member`, `request`, `delivery`, `photo`), puis par version. **Aucun ordre parent-enfant n'est garanti d'une page à l'autre** : un parent modifié après ses enfants (chantier ou zone retouchés, demande recalculée après une livraison) arrive sur une page ultérieure. Le client applique donc toute la synchronisation (toutes les pages) avant de contrôler ses clés étrangères, ou met de côté la ligne dont le parent manque encore et la rejoue à la fin du pull.
**Pierres tombales** (`deleted`) : une ligne supprimée (zone) ; une affectation retirée (`member`) ; et, quand l'utilisateur lui-même est retiré d'un chantier, `deleted` `site` (le client supprime le chantier **et ses enfants**) ; si l'utilisateur est réaffecté avant son prochain pull, aucune pierre tombale `site` n'est envoyée et le chantier lui est renvoyé. Une **nouvelle affectation** renvoie le chantier, ses zones et ses affectations même anciens (le serveur « touche » ces lignes dans la transaction de l'affectation).
**Montant** : `contractAmount` est absent de `data` (`site`) sans la permission `ContractAmount.View` ; si `permissionsVersion` change, repartir de zéro.
```json
// GET /sync/changes?since=0
{ "changes": [ { "entity": "site", "id": "0192…", "siteId": "0192…", "version": "48213", "data": { /* SiteResponse */ } },
               { "entity": "zone", "id": "0192…", "siteId": "0192…", "version": "48230", "data": { /* ZoneResponse */ } } ],
  "deleted": [ { "entity": "member", "id": "0192…", "siteId": "0192…", "version": "48301" } ],
  "cursor": "48301", "hasMore": false }
// POST /sync/push : création d'une zone hors ligne
{ "operations": [ { "clientId": "7c1e…", "entity": "zone", "operation": "create", "siteId": "0192…", "baseVersion": null,
                    "payload": { "clientCreatedAt": "2026-11-24T06:58:00Z", "block": "Bloc 01", "elevation": 3.40, "roomType": "Classroom", "roomNumber": 7 } } ] }
// 200
{ "results": [ { "clientId": "7c1e…", "status": "applied", "resource": { /* ZoneResponse */ } } ] }
```
Résultats du `create zone` : `applied` (nouvelle zone) · `duplicate` (même `clientId` déjà reçu : même ressource, aucun effet) · `duplicate` avec `"merged": true` (une zone **identique** existe déjà, créée par un autre : la zone retenue est renvoyée, le client y rattache ses saisies, CA-011.6) ·
`rejected` avec `code` : `INTROUVABLE` (chantier non affecté ou inexistant : réponse identique), `INTERDIT` (rôle sans `Zones.Create`), `CHANTIER_ARCHIVE`, `VALIDATION` (+ `errors` par champ ; `payload` si le contenu est illisible, sans écho de la valeur), `ZONE_EXISTANTE` (cas rare : zone identique archivée entre-temps). Toute autre entité, ou une opération autre que `create` sur une zone : `rejected` `ENTITE_NON_SYNCHRONISABLE`. `clientId` absent, `operation` inconnue : `rejected` `VALIDATION`.
Le `payload` d'une zone : `{ clientCreatedAt?, block, elevation?, roomType?, roomNumber?, roomLabel? }` (mêmes validations que `POST /sites/{siteId}/zones`) ; tout autre champ (`archivedAt`, `createdBy`, `siteId`...) est **ignoré**. Chaque opération a sa propre transaction : un lot peut réussir partiellement, les résultats reviennent dans l'ordre d'envoi, **toujours en 200** si le lot est bien formé ; plus de 100 opérations : 413 `LOT_TROP_GRAND` (rien n'est écrit).

## Santé
`GET /health/live` (anonyme) → 200 `{ "status": "Healthy" }` sans détail. `GET /health/ready` (anonyme) → 200 ou 503, sans détail, vérifie l'accès à la base.

## Écarts avec le skill `contrat-api` (à valider)
1. `GET /sync/changes` : `siteId` facultatif (ADR 0009).
2. `POST /sync/push` : champ additif `siteId` par opération ; résultat additif `merged`.
3. Pas de `DELETE` : actions `archive` / `restore` (aucune suppression physique, H-13).
4. `clientId` facultatif pour les zones créées au back-office ; chantiers sans `clientId` (création au back-office, unicité du `code`).
5. `POST` de création de zone répond 200 (et non 201) pour un `clientId` déjà reçu, conformément au skill.
