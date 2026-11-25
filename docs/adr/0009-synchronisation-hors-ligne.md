# ADR 0009 : Protocole de synchronisation hors ligne (curseur, tombstones, file d'envoi)

**Date :** 2026-11-24 · **Statut :** Acceptée · **Auteur :** architecte-chantier

## Contexte
Règle 6 : toute création mobile porte un `clientId` et le serveur est idempotent. Le skill `contrat-api` fixe le principe (pull par curseur serveur, push par lot avec réponse par opération,
suppression logique, politique de conflit par entité) mais pas les détails. Kardinal n'a rien de comparable : indicateurs `syncRow 'Y'/'N'` par ligne, réconciliation par appel « verify-sync »,
numéro de document généré par le téléphone (`reference-kardinal.md`, M-4). Le socle ne synchronise en lecture que `Site` et `Zone`, mais le protocole doit être juste dès le départ.

Problème de fond du curseur : si le serveur donne « tout ce qui a une version > X » et que deux transactions se terminent dans le désordre, une ligne de version plus basse peut apparaître **après** que le client a avancé son curseur ;
elle serait perdue pour toujours. SQL Server fournit `MIN_ACTIVE_ROWVERSION()` (plus petite version d'une transaction encore ouverte).

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. Curseur = horloge (`updatedAt` du serveur ou du téléphone) | Simple | Dérives d'horloge, égalités, pertes en cas de transactions longues | Pertes silencieuses |
| B. Séquence applicative `SyncVersion` assignée par intercepteur | Portable | Même problème d'ordre de validation ; nécessite une fenêtre de recouvrement | Moyen |
| C. **`rowversion` + borne `MIN_ACTIVE_ROWVERSION()`** | Monotone, sans trou, fourni par le moteur, déjà jeton de concurrence | Spécifique à SQL Server (confiné à `SqlServerSyncClock`) | Faible |
| D. Moteur tiers (Realm Sync, Firebase, PowerSync…) | Tout fait | Dépendance externe, coûts, perte de contrôle des règles métier | Élevé |

## Décision
**Option C.** Protocole du skill `contrat-api`, complété ainsi.

### Pull : `GET /api/v1/sync/changes?since=<curseur>&siteId=<facultatif>&limit=<facultatif>`
- `siteId` **facultatif** (écart avec le skill, qui le rend obligatoire) : absent = tous les chantiers visibles de l'utilisateur. Raison : la liste « Mes chantiers » doit être obtenue **avant** de connaître un `siteId`. Le mobile utilise **un seul curseur global**.
- `since` absent ou `0` = première synchronisation. `limit` : 200 par défaut, 500 maximum. Curseur = chaîne opaque (valeur décimale d'une version) ; format invalide → 400 `CURSEUR_INVALIDE` → le client repart de zéro **sans toucher à sa file d'envoi**.
- Réponse : `{ "changes": [{ "entity", "id", "siteId", "version", "data" }], "deleted": [{ "entity", "id", "siteId", "version" }], "cursor", "hasMore" }`.
  `entity` ∈ `site`, `zone`, `member` (socle) ; `data` = **même JSON que la réponse REST** de l'entité (`SiteResponse`, `ZoneResponse`, ligne d'affectation avec nom et rôle, jamais de téléphone).
  Chaque `ISyncSource` reçoit les **permissions de l'utilisateur** : le montant du marché est absent de `data` sans `ContractAmount.View` (CA-003.5). Si les permissions changent (`permissionsVersion` de `GET /auth/me`), le mobile remet son curseur à zéro.
- Algorithme serveur (`SyncPullService`) : `upper = SyncClock.SafeUpperBound()` (= `MIN_ACTIVE_ROWVERSION()`), puis, pour chaque source de synchro (`ISyncSource`, une par entité), les lignes `since < RowVersion < upper`
  des chantiers visibles, ordre croissant, `limit + 1` lignes ; fusion triée, on garde `limit`. `hasMore` si des lignes restent. Le curseur renvoyé est la version de la dernière ligne, ou, **sans reste** (`hasMore = false`), `upper - 1` :
  aucune transaction ouverte ne peut plus produire de version inférieure, l'avance est sûre.
- **Pierres tombales** : les lignes `DeletedAt != null` (filtre `SoftDelete` désactivé par son nom) vont dans `deleted`. Une `SiteMember` supprimée logiquement pour cet utilisateur, sans autre droit sur le chantier, produit `deleted: [{ entity: "site", id }]` ;
  le client supprime alors le chantier **et ses enfants** localement (suppression en cascade côté client).
- **Affectation ajoutée** : les lignes du chantier ont des versions anciennes et ne seraient jamais envoyées. Le service d'affectation « touche » donc, dans la même transaction, le chantier et toutes ses lignes synchronisées (`UPDATE … SET UpdatedAt = UpdatedAt` fait avancer le `rowversion`). Opération rare, effet inoffensif pour les autres clients (mise à jour idempotente).
- Idempotence côté client : une ligne n'est appliquée que si `version` reçue > `version` locale (comparaison numérique).
- Conservation des pierres tombales : 90 jours au minimum ; au-delà, le serveur répondra `410 RESYNC_REQUIRED` (purge non implémentée au socle).

### Push : `POST /api/v1/sync/push`
- Corps : `{ "operations": [{ "clientId", "entity", "operation": "create|update|transition", "siteId", "payload", "baseVersion" }] }` (`siteId` ajouté, champ additif). Maximum 100 opérations et 1 Mo par lot.
- Réponse **toujours 200** si le lot est bien formé et authentifié : `{ "results": [{ "clientId", "status": "applied|duplicate|conflict|rejected", "resource", "current", "code" }] }`, dans l'ordre d'envoi. Chaque opération a sa propre transaction.
- Un `ISyncPushHandler` par entité (`Entity = "zone"` …) applique l'opération : vérification du droit sur `siteId` (404/`INTROUVABLE` si non affecté, même réponse que pour un chantier inexistant) et de la permission (`INTERDIT`), chantier non archivé, idempotence par `(siteId, clientId)` (`duplicate` + ressource existante), numéro attribué par le serveur, politique de conflit.
  **Au socle, un seul handler : `zone` / `create`** (ajout seul : jamais de conflit). Si une zone **identique** (même bloc, cote, local) existe déjà, créée par un autre, le handler renvoie `duplicate` avec `merged: true` et la zone retenue : le client y rattache ses saisies, sans erreur affichée (CA-011.6).
  Toute autre entité reçoit `rejected` / `ENTITE_NON_SYNCHRONISABLE`. Le premier handler écrivant prouve de bout en bout la file d'envoi, l'idempotence du lot et la limite de taille.
- Références entre entités créées hors ligne : le `payload` désigne la cible par `<entité>ClientId` (ex. `issueClientId`) ; le serveur la résout dans le même lot par `(siteId, clientId)`. Le client n'a donc jamais besoin de connaître un identifiant serveur avant l'envoi.

### Politique de conflit (rappel du skill, à décliner par entité dans chaque plan)
Ajouts seuls : création idempotente, jamais de conflit. Statuts soumis à validation : le serveur gagne. Texte libre : dernier écrit gagne champ par champ, conflit signalé. `baseVersion` ≠ version serveur → `conflict` + `current`.

### File d'envoi mobile (outbox) et moteur
- Table Drift `outbox_operations` : `id` (auto), `client_id` (unique), `owner_user_id`, `entity`, `operation`, `site_id`, `label` (libellé lisible : « Zone Bloc 01 · +3,40 m · Classe 07 »), `payload_json`, `base_version?`, `status` (`pending`, `sending`, `conflict`, `rejected`), `attempts`, `last_error_code?`, `created_at` (heure de saisie du téléphone, affichée comme « saisi le », jamais utilisée pour décider).
  Le moteur n'envoie que les lignes de l'utilisateur connecté. L'écran « Envois en attente » liste les lignes, avec les actions **Corriger** et **Abandonner** (confirmation) pour `rejected` et `conflict` (CA-013.7) ; rien n'est supprimé sans décision de l'utilisateur.
- **Une écriture locale et son opération d'envoi sont créées dans la même transaction Drift** : jamais l'une sans l'autre.
- `SyncEngine.run()` en **exécution unique** (les appels concurrents partagent la même exécution, idée reprise de Kardinal `sync-functions.dart:13-20`) : 1. push des opérations `pending` par lots de ≤ 50, dans l'ordre de création ;
  2. application des résultats (`applied` / `duplicate` : suppression de l'opération et mise à jour de la ressource locale ; `conflict` et `rejected` : conservées avec leur `code`, **jamais rejouées automatiquement**) ; 3. pull jusqu'à `hasMore = false`.
- Erreurs : réseau, 5xx, 429 → l'opération reste `pending`, reprise avec attente exponentielle (5 s à 5 min, avec gigue) ; 401 → un refresh, sinon état `authRequired` (aucune donnée perdue).
- Déclencheurs : démarrage et retour au premier plan, retour de connectivité, 2 s après un enregistrement local, bouton « Synchroniser maintenant » (un double appui lance une seule exécution), toutes les **5 minutes** au premier plan (paramétrable). Travail en arrière-plan (WorkManager) : lot ultérieur.
- État exposé à l'interface, qui correspond aux cinq états de `docs/metier/socle.md` (US-013) : **À jour** (+ heure), **Hors ligne**, **En attente** (N à envoyer), **En cours**, **Problème** (N à vérifier = rejetées + conflits) ; plus `authRequired` (reconnexion) et un bandeau « Données du JJ/MM/AAAA HH:MM » au-delà de 24 h sans synchro (H-12).
  Table `sync_state(key, value)` : `cursor`, `owner_user_id`, `last_success_at`, `last_server_contact_at`, `permissions_version`, `initial_sync_done`. La première synchro affiche « Préparation de vos chantiers… » avec le nombre d'éléments reçus et reprend où elle s'était arrêtée (le curseur n'avance qu'après application d'une page).
- L'horloge du téléphone n'intervient **jamais** dans l'ordre ou la décision ; `createdAtDevice` est une information, pas une clé.

## Conséquences
- Plus facile : aucune perte de changement ; création idempotente ; état de synchro explicable à l'utilisateur ; nouvelle entité synchronisable = une `ISyncSource` + (au besoin) un `ISyncPushHandler`.
- Plus difficile : chaque entité doit choisir sa politique de conflit ; toute entité d'un chantier doit être inscrite dans le « toucher à l'affectation ».
- À surveiller : grosses premières synchronisations sur 3G (pagination à 200 lignes, reprise après coupure) ; la bascule vers un autre moteur de base ne conserve le protocole qu'en réécrivant `SqlServerSyncClock` ; mesurer la taille d'un pull initial sur le jeu « École UV18 » dès la fin du socle.

## Précisions d'implémentation (B5, backend-dotnet, 2026-11-24)
- **Une ligne de réponse par ligne de base** : la version sert de curseur ; une source ne produit jamais deux lignes pour la même ligne (les pierres tombales `site` d'un retrait viennent de la source `member`, et seulement si l'utilisateur n'est pas réaffecté entre-temps).
- **« Toucher » (affectation)** : `ISyncTouch.LockSiteAsync` puis `TouchLinesAsync`, dans la transaction de l'affectation. Les verrous sont pris dans **l'ordre du chantier d'abord** (verrou applicatif `sp_getapplock` pour mettre en file les affectations d'un même chantier, puis la ligne du chantier), car c'est l'ordre de toutes les lectures (contrôle d'affectation : chantier puis affectations) et le contrôle de clé étrangère d'une création de zone lit le chantier **après** avoir verrouillé sa propre ligne. Mesuré sur vraie base : toute autre combinaison (enfants d'abord, `UPDLOCK` sur la ligne du chantier, `UPDATE` par chantier qui parcourt les zones) produit des interblocages. Les zones en cours d'écriture par une autre transaction sont ignorées (`READPAST`) puis les autres touchées une à une par clé primaire : leur version sera de toute façon postérieure au curseur de tout lecteur.
- **Toute nouvelle entité d'un chantier** s'ajoute à `SyncTouch.TouchedEntityTypes` (un test d'architecture l'exige pour toute entité `ISiteScoped`) et reçoit sa `ISyncSource`.
- **`merged`** : l'identité d'une zone est sa position active (bloc, cote, local) ; une zone **archivée** n'est pas une zone identique (la création d'une nouvelle est acceptée, comme sur le web).
- **Corps du `payload`** : seuls les champs de la ressource sont lus ; un champ protégé envoyé (`archivedAt`, `createdBy`, `siteId`...) est ignoré.
