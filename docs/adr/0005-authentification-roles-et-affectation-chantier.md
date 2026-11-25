# ADR 0005 : Authentification, rôles et affectation au chantier

**Date :** 2026-11-24 · **Statut :** Acceptée (alignée sur `docs/metier/socle.md`, hypothèses H-01 à H-05, H-17) · **Auteur :** architecte-chantier

## Contexte
Deux clients : le back-office web (bureau, réseau stable) et le mobile (terrain, hors ligne, jours sans réseau possibles).
Kardinal a déjà un modèle éprouvé : Identity, cookie `HttpOnly` pour la SPA, JWT bearer pour le mobile, refresh persistant rotatif avec détection de réutilisation,
permissions `Permission.<Ressource>.<Action>` portées par les rôles (`docs/architecture/reference-kardinal.md`, §1).
Règles Chantier : six rôles fixes (un seul par utilisateur, H-01), « un utilisateur ne voit que les chantiers auxquels il est affecté » (OWASP API1), données personnelles protégées, auteur jamais fourni par le client,
un compte désactivé ne doit plus rien pouvoir enregistrer (CA-002.5).

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. **Modèle Kardinal** (Identity + cookie web + JWT mobile + refresh rotatif persistant) + affectation par ressource | Éprouvé, même code, aucune bibliothèque nouvelle | Il faut ajouter l'affectation (absente de Kardinal) et régler les durées pour le hors ligne | Faible |
| B. Fournisseur externe (Keycloak, Entra ID, Auth0) | SSO, MFA prêts | Service à exploiter, dépendance réseau et coûts, surdimensionné | Élevé |
| C. JWT partout, y compris web (jeton en mémoire) | Un seul mécanisme | Jeton volable par XSS s'il est stocké ; rafraîchissement silencieux à reconstruire | Moyen |

## Décision
**Option A**, avec les réglages suivants.

**Identité.** `AppUser : IdentityUser<Guid>` : `FullName` (nom complet unique, pas de prénom/nom séparés), `Language` (`fr` | `ar`, défaut `fr`), `PhoneNumber` (Identity), `MustChangePassword`, `IsActive`, `DeactivatedAt?`.
`AppRole : IdentityRole<Guid>`. **Un seul rôle** par utilisateur (règle appliquée par le service d'utilisateurs ; l'API expose `role` et non `roles`). Identifiant sans e-mail (comme Kardinal). Mot de passe : 8 caractères minimum dont un chiffre.
Un compte n'est jamais supprimé : désactivation (H-13).

**Tentatives de connexion.** Écart avec Kardinal (verrouillage Identity, qui ne protège que les comptes existants et révèle leur existence) : un `LoginAttemptTracker` (mémoire, instance unique) compte les échecs **par identifiant normalisé, existant ou non** :
5 échecs en 15 min → 429 `TROP_D_ESSAIS` avec `Retry-After`, même avec le bon mot de passe. Un identifiant faux, un mot de passe faux et un compte désactivé donnent **la même réponse** 401 `IDENTIFIANTS_INVALIDES` (CA-001.3). Le verrouillage Identity est désactivé. Le compteur est perdu au redémarrage (accepté ; à externaliser si l'API passe à plusieurs instances).

**Compte désactivé.** Un `JwtBearerEvents.OnTokenValidated` et l'événement de validation du cookie vérifient `IsActive` (cache mémoire ≤ 60 s) : un jeton encore valide d'un compte désactivé reçoit 401 `ACCES_RETIRE`. Le refresh d'un compte désactivé répond aussi `ACCES_RETIRE` et révoque ses refresh. Le mobile efface alors les données chantier (CA-002.5).

**Web.** Cookie `.Chantier.Identity.Application`, `HttpOnly`, `SameSite=Lax`, `Secure` toujours hors développement, expiration glissante de 8 h ; 401/403 au lieu de redirections.
Protection CSRF : `SameSite=Lax` + CORS à liste blanche + corps JSON (requête non « simple ») ; pas de jeton anti-falsification tant qu'aucun endpoint n'accepte un formulaire. Clés de protection des données persistées dans `Storage:DataProtectionKeys` (sinon les sessions meurent à chaque redémarrage).

**Mobile.** Connexion avec `isAppMobile: true` → `accessToken` JWT **15 min** (HS256, clé ≥ 32 octets, refusée sinon au démarrage) et `refreshToken` **14 jours, rotatif, persisté** (empreinte SHA-256, détection de réutilisation qui révoque la chaîne) ; durée paramétrable `Jwt:RefreshTokenDurationInDays`.
Règle métier H-05 : une session reste utilisable hors ligne **14 jours** ; la durée du refresh est alignée dessus et la rotation la prolonge à chaque contact avec le serveur. Le **travail local n'exige aucun jeton** ; seule la synchronisation en a besoin.
Au-delà de 14 jours sans contact, reconnexion avec réseau, **sans perdre les saisies en attente** (conservées pour le même compte, CA-002.2).
Stockage : `flutter_secure_storage` (Keystore Android). Un échec de refresh **ne supprime pas** la file d'envoi ; il ne supprime les données chantier que sur `ACCES_RETIRE`.

**Endpoints du socle** : `POST /api/v1/auth/login`, `refresh`, `logout`, `change-password`, `GET /api/v1/auth/me`, `PUT /api/v1/auth/me/language` (détails : `docs/api/socle.md`).
La gestion des comptes (création, désactivation, réinitialisation, changement de rôle) et le journal des connexions sont dans le **lot « Administration »** qui suit immédiatement le socle (voir plan).

**Rôles et permissions.** Les six rôles sont fixes et amorcés par le code : `Admin`, `Direction`, `ConducteurTravaux`, `Achats`, `ChefChantier`, `ChefEquipe`.
Mécanisme Kardinal conservé : `[HasPermission("Zones","Create")]` → politique `Permission.Zones.Create` → claim de rôle. Catalogue et matrice par défaut dans le code
(`PermissionResources`, `RolePermissionMatrix`), appliqués par un seeder idempotent qui **ajoute** les claims manquantes sans retirer les ajouts manuels.
Écarts avec Kardinal : pas de tables `Claims` / `References` (le catalogue est une constante) ; pas d'écran d'édition de la matrice au socle.
Les permissions ne sont **pas** dans le jeton : le serveur les résout par rôle avec un cache mémoire de 5 minutes (au lieu de 3 requêtes par appel chez Kardinal) ; `GET /auth/me` les liste et renvoie `permissionsVersion` (empreinte).
Action `Delete` = **archiver** (aucune suppression physique).

Matrice du socle (reprend « Droits par rôle » de `docs/metier/socle.md`) :

| Ressource.Action | Admin | Direction | ConducteurTravaux | Achats | ChefChantier | ChefEquipe |
|---|---|---|---|---|---|---|
| `AllSites.View` (voir **tous** les chantiers sans affectation) | oui | non | non | non | non | non |
| `Sites.View`, `Zones.View`, `SiteMembers.View` | oui | oui | oui | oui | oui | oui |
| `ContractAmount.View` (montant du marché) | oui | oui | oui | non | non | non |
| `Sites.Create`, `Sites.Update`, `Sites.Delete` (archiver / restaurer) | oui | non | non | non | non | non |
| `Zones.Create`, `Zones.Update` | oui | non | oui | non | oui | non |
| `Zones.Delete` (archiver / restaurer) | oui | non | oui | non | non | non |
| `SiteMembers.Update` (affecter / retirer) | oui | non | non | non | non | non |
| `Users.View`, `Users.Create`, `Users.Update` (lot Administration) | oui | non | non | non | non | non |
`Sites.Update` est refusé au ConducteurTravaux (CA-008.7 : seul l'Admin modifie un chantier). `Direction` n'a aucun droit d'écriture (CA-003.4).

**Affectation au chantier (règle de ressource).**
- Entité `SiteMember (SiteId, UserId)` ; un utilisateur voit un chantier s'il y est affecté **ou** s'il a `AllSites.View` (Admin seul, H-02 ; Direction non, question Q-02 ouverte : l'activer = ajouter la claim au rôle, sans code).
- Toute route portant `{siteId}` passe par le filtre d'action `[SiteScoped]` → `ISiteAccess.EnsureAsync(siteId)` : **404 `INTROUVABLE`** si non affecté, **réponse strictement identique** à celle d'un chantier inexistant (CA-006.2). La ressource enfant est ensuite lue **par `(siteId, id)`**, jamais par `id` seul.
  Pas de cache sur l'affectation : le retrait coupe l'accès immédiatement (CA-005.4).
- Les listes utilisent des spécifications filtrées (`SitesVisibleToUserSpecification`) ; la synchronisation applique la même règle et émet une pierre tombale quand une affectation est retirée (ADR 0009).
- Le rôle global décide de **l'action** ; l'affectation décide du **périmètre**. Les deux sont vérifiés à chaque requête.

**Champs réservés à certains rôles.** Le montant du marché est **omis des réponses et des données de synchro** sans `ContractAmount.View` (jamais stocké sur le téléphone, CA-003.5/CA-012.7). Le téléphone d'un compte n'est renvoyé qu'à son titulaire (`GET /auth/me`) ; l'Admin le verra dans le lot Administration (H-17).

**Limitation de débit.** Politique `auth` (login, refresh) : 10 requêtes / 5 min par couple (IP, identifiant haché), au lieu de 5 / 5 min par IP chez Kardinal (adresses d'opérateurs mobiles partagées par de nombreux téléphones, donc blocage d'une équipe entière).
Limiteur global : 300 requêtes / min, partitionné par utilisateur authentifié, par IP sinon.

**Amorçage.** Aucun mot de passe dans le dépôt de production (écart avec Kardinal `IdentityConstants.cs:9`). Le premier Admin est créé au démarrage depuis `Bootstrap:AdminUserName` et `Bootstrap:AdminPassword` (`user-secrets` ou variables d'environnement) **seulement s'il n'existe aucun Admin** ; le compte est marqué « doit changer son mot de passe ».
Comptes de démonstration (`*.dev`, voir `docs/metier/socle.md`) : seulement si `Seed:Demo = true` **et** environnement Development, mot de passe lu dans `Seed:DemoPassword` (valeur de développement uniquement, jamais utilisée hors Development).

**Données personnelles.** Le journal ne contient que des identifiants GUID anonymes (jamais nom, identifiant de connexion, téléphone ni mot de passe, CA-017.1) ; un test capture les journaux d'un parcours complet et cherche ces valeurs.

## Conséquences
- Plus facile : réutilisation directe du savoir-faire Kardinal ; affectation vérifiée à un seul endroit ; message de connexion unique qui n'aide pas à deviner les identifiants.
- Plus difficile : toute nouvelle route portant un `siteId` doit porter `[SiteScoped]` ; un test d'architecture (réflexion) échoue si ce n'est pas le cas ; toute réponse contenant un champ réservé doit passer par le contrôle de permission.
- À surveiller : le blocage par identifiant permet un déni de service ciblé sur un compte (accepté, 15 min) ; compteur en mémoire à externaliser en cas de montée en charge horizontale ; les 14 jours de refresh doivent être revus après la revue sécurité et le test terrain (question Q-07).
