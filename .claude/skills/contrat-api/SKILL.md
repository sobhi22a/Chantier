---
name: contrat-api
description: Conventions du contrat d'API entre le backend .NET 10, le web React et le mobile Flutter. Couvre les routes, identifiants, dates, montants, erreurs Problem Details, pagination, concurrence, idempotence, protocole de synchronisation hors ligne, photos, authentification et OpenAPI. À consulter avant de concevoir, implémenter ou consommer un endpoint.
user-invocable: false
---

# Contrat d'API : conventions communes

Le contrat (OpenAPI) est la **source de vérité** partagée. Si le projet a déjà des conventions différentes,
elles priment : les signaler dans l'état des lieux plutôt que de les changer.

## Cycle de vie du contrat
1. L'architecte décrit les endpoints et DTO dans le plan (`docs/plans/<fonctionnalite>.md`).
2. Le backend les implémente ; le document OpenAPI **généré** fait foi et est enregistré dans le dépôt
   (par ex. `docs/api/openapi.json`) pour que les écarts se voient dans les diffs.
3. Web et mobile régénèrent ou alignent leurs types sur ce fichier. Un type généré ne se modifie jamais à la main.
4. Changements cassants interdits dans une version publiée : ajouter (nouveaux champs optionnels, nouveaux endpoints),
   ne jamais renommer ni supprimer sans nouvelle version (`/api/v2`) et ADR.

## Routes
- Préfixe versionné : `/api/v1`. Ressources au pluriel, imbriquées sous le chantier :
  `/api/v1/sites/{siteId}/requests`, `/api/v1/sites/{siteId}/deliveries/{deliveryId}`.
- Langue des routes et des DTO : celle du code existant (à défaut, anglais, voir le glossaire métier).
- Actions métier explicites plutôt que PATCH générique sur le statut :
  `POST /requests/{id}/approve`, `/reject` (motif), `/cancel` (motif), `/receive`.
- Le serveur vérifie toujours que l'utilisateur est affecté au `siteId` de la route **et** que la ressource
  appartient bien à ce chantier (sinon 404).

## Types de données
| Donnée | Format JSON | Règle |
|---|---|---|
| Identifiant technique | GUID (chaîne) | Serveur : `Guid.CreateVersion7()` (ordonné dans le temps) |
| `clientId` | GUID (chaîne) | Généré par le client à la création, unique par (chantier, type d'entité) |
| Numéro métier | chaîne `DEM-001` | Généré par le serveur, jamais par le client |
| Date métier | `"2026-11-24"` | `DateOnly`, sans fuseau |
| Horodatage | `"2026-11-24T10:15:00Z"` | UTC ; affichage dans le fuseau Africa/Algiers |
| Quantité | `{ "value": 167.5, "unit": "m2" }` | Unité obligatoire, 3 décimales max |
| Montant | nombre, 2 décimales | DZD implicite ; calculé par le serveur |
| Expression de métré | chaîne | Conservée telle que saisie ; le serveur renvoie aussi la quantité calculée |
| Énumérations | chaînes stables (`"Validated"`) | Jamais d'entiers ; libellés traduits côté client |

## Erreurs : Problem Details (RFC 9457)
- Toute erreur renvoie `application/problem+json` avec `type`, `title`, `status`, `detail`, et :
  - `code` : code métier stable (`UNITE_OBLIGATOIRE`, `DATE_INVALIDE`, `TRANSITION_INTERDITE`…) que les clients traduisent ;
  - `errors` : détail par champ pour les erreurs de validation (400) ;
  - `traceId` pour le support.
- Statuts : 400 validation · 401 non authentifié · 403 rôle insuffisant sur un chantier visible · 404 introuvable
  ou chantier non affecté · 409 conflit de version ou transition concurrente · 412 précondition (If-Match) ·
  413 fichier trop gros · 415 type de fichier refusé · 422 règle métier violée (avec `code`) · 429 trop de requêtes.
- Jamais de trace de pile, de SQL ou de donnée personnelle dans une réponse.

## Listes
- Pagination obligatoire : `?pageSize=50` (max 200) et curseur `?cursor=…` ; réponse `{ "items": [...], "nextCursor": "…" }`.
  La pagination par numéro de page n'est admise que pour le back-office avec un total (`totalCount`).
- Filtres explicites : `status`, `type`, `priority`, `zoneId`, `from`, `to`, `q` (recherche). Tri : `sort=-date`.

## Concurrence
- Chaque ressource modifiable expose `version` (jeton de concurrence : rowversion SQL Server, xmin PostgreSQL…).
- Les modifications envoient la version lue (champ `version` ou en-tête `If-Match`) ; si elle a changé : 409 avec l'état actuel.

## Idempotence des créations
- `POST` de création : le corps contient `clientId`. Index unique (chantier, `clientId`).
- Premier envoi → 201 + ressource. Renvoi du même `clientId` → 200 + **la même** ressource, sans doublon ni effet de bord.

## Synchronisation hors ligne (mobile)
- **Pull** : `GET /api/v1/sync/changes?siteId=…&since=<curseur>` → `{ "changes": [...], "deleted": [...], "cursor": "…", "hasMore": bool }`.
  Le curseur est fourni par le serveur (séquence ou rowversion), **jamais l'horloge du téléphone**.
- **Push** : `POST /api/v1/sync/push` avec un lot d'opérations
  `{ "clientId", "entity", "operation": "create|update|transition", "payload", "baseVersion" }`.
  Réponse **par opération** : `applied` (avec la ressource), `duplicate` (déjà appliquée), `conflict` (avec l'état serveur),
  `rejected` (avec `code`). Un lot peut réussir partiellement ; le client ne rejoue que ce qui doit l'être.
- Politique de conflit, à préciser par entité dans le plan :
  - ajouts seuls (journal, photo, pointage, problème créé) : pas de conflit, création idempotente ;
  - statuts soumis à validation (demande validée, situation payée) : **le serveur gagne**, le client affiche le nouvel état ;
  - texte libre modifié des deux côtés : la dernière écriture gagne champ par champ, et le conflit est signalé à l'utilisateur.
- Suppressions : logiques (`deletedAt`), transmises dans `deleted` (pierres tombales) au pull.

## Photos et fichiers
1. Créer les métadonnées (`clientId`, chantier, zone, lien, date de prise, GPS) → `id`.
2. Envoyer le binaire : `PUT /api/v1/photos/{id}/content` (multipart ou flux), reprise possible en cas de coupure.
- Serveur : taille max (par ex. 10 Mo), type vérifié par les octets magiques (JPEG, PNG, HEIC), nom de stockage aléatoire,
  stockage hors du dossier web, miniature générée ; GPS et date extraits en métadonnées puis EXIF retiré des images servies.
- Lecture par URL temporaire ou endpoint authentifié ; jamais de dossier public listable.

## Authentification et autorisations
- Jeton d'accès court (environ 15 min) + jeton de rafraîchissement avec rotation (mobile : stockage sécurisé ;
  web : de préférence cookie `HttpOnly` `Secure` `SameSite`, sinon jeton en mémoire). Suivre l'existant s'il y en a un.
- Politiques par rôle **et** contrôle par ressource (affectation au chantier) dans chaque handler : protection contre l'accès
  aux objets d'un autre chantier (OWASP API1:2023).
- Le client ne peut jamais fixer lui-même : statut, numéro, montant, auteur, dates d'audit (protection contre l'affectation de masse).
- Langue : en-tête `Accept-Language: fr | ar` ; le serveur renvoie `code` + un message français par défaut.

## OpenAPI (.NET 10)
- `Microsoft.AspNetCore.OpenApi` génère de l'OpenAPI 3.1 ; garder l'interface de documentation déjà en place.
- Chaque endpoint : `summary`, `description`, exemples, tous les codes de réponse (dont Problem Details), schémas nommés.
