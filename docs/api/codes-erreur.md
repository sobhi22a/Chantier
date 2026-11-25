# Catalogue des codes d'erreur

**Tenu par :** backend-dotnet (créé par architecte-chantier, 2026-11-24). Tout nouveau `code` s'ajoute ici **et** dans `ErrorCodes` + `ErrorCatalog` (serveur) **et** dans les fichiers de traduction web (`libs/i18n/.../errors.json`, FR + AR) et mobile (ARB `errors_*`).
Un code existant ne change jamais de sens ni de nom (contrat versionné). **Contrôlé par test** (`ErrorCatalogTests`) : chaque code de `ErrorCodes` a une entrée du catalogue serveur et une ligne ci-dessous avec le même statut HTTP, et inversement.
Le schéma `ProblemDetails` du fichier généré (`docs/api/openapi.json`) décrit cette réponse ; `code` y est une **chaîne ouverte** (un client ignore un code inconnu et affiche `title`). Chaque route documente aussi `429` (`TROP_DE_REQUETES`) et `500` (`ERREUR_INTERNE`), et `401` et `403` si elle est protégée.

Format de réponse (RFC 9457) :
```json
{ "type": "https://chantier.local/errors/zone-existante", "title": "Zone déjà existante", "status": 422,
  "detail": "Une zone identique existe déjà sur ce chantier.", "code": "ZONE_EXISTANTE", "traceId": "00-4bf9…" }
```
Pour `VALIDATION` : champ `errors` = `{ "block": ["Le bloc est obligatoire."] }`. Pour `CONFLIT_VERSION` : champ `current` = état courant de la ressource.
Aucun message d'erreur ne contient de nom, d'identifiant de connexion ni de téléphone (CA-017.2).

| Code | HTTP | Cas | Socle |
|---|---|---|---|
| `VALIDATION` | 400 | Corps ou paramètres invalides (détail par champ) | oui |
| `DATE_INVALIDE` | 400 | Date incomplète ou impossible (ex. `../08/2026`) | oui (date d'ODS) |
| `QUANTITE_INVALIDE` | 422 | Quantité ≤ 0 (au socle : délai en jours ≤ 0) | oui |
| `CURSEUR_INVALIDE` | 400 | Curseur de synchronisation illisible | oui |
| `NON_AUTHENTIFIE` | 401 | Jeton ou cookie absent, invalide ou expiré | oui |
| `IDENTIFIANTS_INVALIDES` | 401 | Identifiant ou mot de passe faux, **ou compte désactivé** (message identique) | oui |
| `REFRESH_INVALIDE` | 401 | Jeton de rafraîchissement expiré, révoqué ou réutilisé | oui |
| `ACCES_RETIRE` | 401 | Compte désactivé alors qu'une session existait : le mobile efface les données chantier | oui |
| `INTERDIT` | 403 | Rôle sans la permission sur une ressource visible | oui |
| `INTROUVABLE` | 404 | Ressource absente **ou chantier non affecté** (réponse identique) | oui |
| `CONFLIT_VERSION` | 409 | `version` envoyée différente de la version courante | oui |
| `LOT_TROP_GRAND` | 413 | Lot de synchronisation trop volumineux : plus de 100 opérations, ou corps de plus de 1 Mo. Rien n'est écrit | oui |
| `CODE_CHANTIER_EXISTANT` | 422 | Code de chantier déjà utilisé | oui |
| `ZONE_EXISTANTE` | 422 | Même (bloc, cote, local) déjà présent sur le chantier | oui |
| `CHANTIER_ARCHIVE` | 422 | Saisie sur un chantier archivé | oui |
| `COMPTE_DESACTIVE` | 422 | Affectation d'un compte désactivé | oui |
| `MOT_DE_PASSE_FAIBLE` | 422 | Mot de passe non conforme à la politique | oui |
| `ENTITE_NON_SYNCHRONISABLE` | (résultat de push) | Entité sans handler de synchronisation, ou opération autre que `create` sur une zone : le résultat de l'opération est `rejected` avec ce `code` (la réponse du lot reste 200) | oui |
| `TROP_D_ESSAIS` | 429 | 5 échecs de connexion sur un même identifiant en 15 min (existant ou non), `Retry-After` | oui |
| `MOT_DE_PASSE_A_CHANGER` | 403 | Mot de passe provisoire : tout est refusé, sauf `GET /auth/me`, `PUT /auth/me/language`, `POST /auth/change-password` et `POST /auth/logout`, tant que l'utilisateur n'a pas choisi le sien (CA-001.7). Ajouté par B3 (additif) | oui |
| `TROP_DE_REQUETES` | 429 | Limite de débit dépassée : générale (300 / min par utilisateur ou IP) ou politique « auth » (10 / 5 min par couple adresse + identifiant sur `login` et `refresh`), avec `Retry-After`. Distinct de `TROP_D_ESSAIS`, qui ne concerne que les 5 échecs de connexion d'un identifiant | oui |
| `ERREUR_INTERNE` | 500 | Erreur inattendue (aucun détail technique renvoyé) | oui |
| `UNITE_OBLIGATOIRE`, `UNITES_INCOMPATIBLES`, `EXPRESSION_INVALIDE`, `TRANSITION_INTERDITE` | 422 | Règles métier (skill `metier-chantier`) | non : fonctionnalités à venir ; messages FR/AR quand même fournis (CA-014.9) |
