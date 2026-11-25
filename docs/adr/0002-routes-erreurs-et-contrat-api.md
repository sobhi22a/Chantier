# ADR 0002 : Routes REST versionnées et erreurs Problem Details

**Date :** 2026-11-24 · **Statut :** Acceptée · **Auteur :** architecte-chantier

## Contexte
Kardinal utilise `api/[controller]/[action]` (`get-tiers`, `create`, `Delete`) sans version et renvoie un JSON d'erreur maison
(`statusCode`, `type`, `correlationId`, `stackTrace`). Le skill `contrat-api` impose `/api/v1`, des ressources au pluriel
imbriquées sous le chantier, des actions métier explicites (`POST …/approve`), des erreurs RFC 9457 avec un `code` métier,
la pagination par curseur et `version` pour la concurrence. Le skill précise : « si le projet a des conventions différentes,
elles priment » ; or **le projet Chantier n'a pas de code existant**, donc le skill s'applique.

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. Garder `api/[controller]/[action]` de Kardinal | Copie directe du front Kardinal | Contraire au contrat ; verbes dans l'URL ; pas de version ; clients générés peu lisibles | Dette contractuelle |
| B. **Contrôleurs MVC avec routes d'attributs REST `/api/v1/...` et Problem Details** | Respecte le contrat ; garde le style contrôleur de Kardinal ; OpenAPI propre | Les patrons d'URL de Kardinal ne se recopient pas | Faible |
| C. Minimal APIs groupées | Natif .NET 10 (validation intégrée) | Rupture avec Kardinal | Moyen |

## Décision
**Option B.**
- Préfixe `/api/v1`. Ressources au pluriel, imbriquées : `/api/v1/sites`, `/api/v1/sites/{siteId}/zones`, `/api/v1/sites/{siteId}/members`.
  Actions métier : `POST /api/v1/sites/{siteId}/requests/{id}/approve` (à venir). Aucun verbe dans l'URL sauf action métier.
- Attributs `[Route("api/v1/sites/{siteId:guid}/zones")]` explicites sur chaque contrôleur ; jamais `[controller]` ni `[action]`.
- **Erreurs** : `GlobalExceptionMiddleware` (nom conservé) produit `application/problem+json` : `type`, `title`, `status`, `detail`,
  `code`, `errors` (par champ, pour 400), `traceId`. Table exception → statut : `NotFoundException` 404 ; `ForbiddenException` 403 ;
  `ValidationException` 400 ; `DomainRuleException` 422 (avec `code`) ; `ConflictException` 409 ; `DbUpdateConcurrencyException` 409 ;
  `InvalidCredentialsException` 401 (`IDENTIFIANTS_INVALIDES`, identique pour identifiant inconnu, mot de passe faux et compte désactivé) ; trop d'échecs de connexion 429 (`TROP_D_ESSAIS`, en-tête `Retry-After`) ; accès retiré 401 (`ACCES_RETIRE`) ; inattendue 500 (`ERREUR_INTERNE`).
  Aucun message d'erreur ne contient de nom, d'identifiant de connexion ni de téléphone.
  Hors développement : aucun message d'exception interne, aucune trace, aucun SQL (déjà le principe de Kardinal).
- **400 par validation de modèle** : `ConfigureApiBehaviorOptions` → `ValidationProblemDetails` enrichi de `code = "VALIDATION"` et `traceId`.
- **Listes** : `pageSize` (défaut 50, max 200) + `cursor` → `{ items, nextCursor }` ; le back-office peut demander `page` + `totalCount` (`GET /sites`).
  Filtres explicites, tri `sort=-name`.
- **Concurrence** : toute ressource modifiable expose `version` (chaîne : rowversion encodé, ADR 0003) ; `PUT` envoie `version` dans le corps ;
  discordance → 409 avec `code = "CONFLIT_VERSION"` et l'état courant dans `current`.
- **Langue** : le serveur renvoie `code` et un message français par défaut ; `Accept-Language: fr|ar` est lu et journalisé mais les clients traduisent par `code`.
- **Catalogue des codes** : `docs/api/codes-erreur.md`, tenu par le backend, repris par web et mobile dans leurs fichiers de traduction.
- **Écart à signaler** : le skill `contrat-api` doit recevoir une ligne sur `siteId` facultatif pour `GET /sync/changes` (ADR 0009).

## Conséquences
- Plus facile : clients générés lisibles ; traduction des erreurs par `code` sans analyser des textes.
- Plus difficile : aucun copier-coller des contrôleurs Kardinal ; chaque exception doit avoir un `code`.
- À surveiller : ne jamais renvoyer `ex.Message` d'une exception non métier ; un test d'intégration vérifie qu'une 500 ne contient ni pile ni SQL.
