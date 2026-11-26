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

| Code | HTTP | Cas | Socle (« oui ») ou lot |
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
| `ERREUR_TEMPORAIRE` | 503 | Échec momentané de la base (interblocage resté sans solution après les rejeux du serveur, délai SQL dépassé) : **rien n'a été enregistré**, la même requête peut être renvoyée telle quelle (idempotente par `clientId`) ; `Retry-After: 1`. En synchronisation : résultat d'opération `retry` avec ce `code`. Ajouté par la correction R2-01 (additif) | oui |
| `UNITE_OBLIGATOIRE` | 422 | Quantité sans unité (demande, livraison). Utilisé par le lot demandes de matériaux | demandes |
| `UNITES_INCOMPATIBLES` | 422 | Unité de livraison non convertible vers l'unité de la commande (m³ ↔ T, L ↔ kg, `sac` sans masse de sac) ; unité d'un produit libre rattaché non autorisée par le produit du catalogue. Utilisé par le lot demandes de matériaux | demandes |
| `TRANSITION_INTERDITE` | 422 | Changement de statut ou action impossible dans l'état actuel (valider une demande refusée, réceptionner une demande non livrée, archiver une demande ouverte, annuler une commande qui a une livraison, solder sans livraison, modifier une demande livrée ou close). Utilisé par le lot demandes de matériaux | demandes |
| `EXPRESSION_INVALIDE` | 422 | Expression de métré invalide (skill `metier-chantier`) | non : lot situations et métrés ; messages FR/AR quand même fournis (CA-014.9) |
| `DEMANDE_VERROUILLEE` | 422 | Produit, quantité ou unité d'une demande déjà validée : plus modifiables (annuler et recréer). « Demande validée : la quantité et le produit ne se modifient plus. Annulez-la et créez-en une nouvelle. » | demandes |
| `DEMANDE_NON_OUVERTE` | 422 | Rattacher, corriger ou annuler une livraison sur une demande Refusée, Annulée ou Réceptionnée, ou rattacher à une demande non encore validée (hors création d'une livraison, qui n'est jamais refusée : elle est enregistrée « non rattachée ») | demandes |
| `COMMANDE_EXISTANTE` | 422 | Demande déjà commandée avec un autre `clientId` (même `clientId` : renvoi idempotent, 200) | demandes |
| `PRODUIT_DIFFERENT` | 422 | Le produit de la livraison n'est pas celui de la demande | demandes |
| `QUANTITE_ENTIERE_REQUISE` | 422 | Unité `sac` ou `u` avec une décimale (« Nombre entier requis ») | demandes |
| `UNITE_NON_AUTORISEE` | 422 | Unité absente de la liste des unités autorisées du produit du catalogue | demandes |
| `MASSE_SAC_OBLIGATOIRE` | 422 | Produit dont l'unité `sac` est autorisée mais sans masse de sac | demandes |
| `PRODUIT_EXISTANT` | 422 | Nom de produit déjà présent (la casse, les accents et les espaces ne comptent pas) | demandes |
| `FOURNISSEUR_EXISTANT` | 422 | Nom de fournisseur déjà présent | demandes |
| `PRODUIT_INACTIF` | 422 | Nouvelle demande ou livraison sur un produit désactivé | demandes |
| `FOURNISSEUR_INACTIF` | 422 | Nouvelle commande ou livraison avec un fournisseur désactivé | demandes |
| `ZONE_HORS_CHANTIER` | 422 | La zone n'appartient pas à ce chantier (ou n'existe pas) : « Cette zone n'appartient pas à ce chantier » | demandes |
| `LIVRAISON_DEJA_RATTACHEE` | 422 | Rattacher une livraison déjà rattachée à une autre demande (une livraison sert une seule demande) | demandes |
| `PHOTOS_TROP_NOMBREUSES` | 422 | Plus de 5 photos pour une livraison (`Materials:MaxPhotosPerDelivery`) | demandes |
| `PHOTO_DEJA_ENVOYEE` | 409 | Contenu différent envoyé pour une photo dont le binaire est déjà reçu (même contenu : 200 sans effet) | demandes |
| `FICHIER_TROP_GROS` | 413 | Image de plus de `Storage:MaxPhotoBytes` (5 Mo par défaut) | demandes |
| `TYPE_FICHIER_REFUSE` | 415 | Fichier qui n'est pas un JPEG valide (octets magiques ou structure) | demandes |

**Remarques sur le lot demandes de matériaux** (`docs/api/demandes-materiaux-livraisons.md`) :
- Un motif manquant (refus, annulation, solde, réserve) ou « Autre » sans remarque est une erreur de validation : 400 `VALIDATION` avec `errors.reasonCode` / `errors.reasonNote`. Aucun code dédié.
- Une date de livraison ou de commande dans le futur : 400 `DATE_INVALIDE` avec le message du champ dans `errors` (« La date de livraison ne peut pas être dans le futur ») ; les clients affichent ce message de champ quand il existe, sinon le texte traduit du code.
- Dans une réponse de **push**, `DEMANDE_VERROUILLEE`, `DEMANDE_NON_OUVERTE`, `TRANSITION_INTERDITE` et `CONFLIT_VERSION` accompagnent un résultat `conflict` (l'état du serveur a changé, ADR 0011) ; les autres codes accompagnent un résultat `rejected`.
- Chaque nouveau code a ses textes FR et AR côté web (`libs/i18n/.../errors.json`) et mobile (ARB `errors_*`) ; textes FR et AR de départ : `docs/metier/demandes-materiaux-livraisons.md`, section « Messages » (à faire relire, H-MAT-24).
