---
name: revue-materiaux-risques-et-commandes
description: Revues R2 et R2 bis demandes-materiaux-livraisons (2026-11-25) : endroits sensibles, pièges mesurés, méthode base jetable, résultats des corrections, ce qui reste ouvert (R3-01 à R3-10)
metadata:
  type: project
---

## Chemins clés (endroits sensibles du lot matériaux)
- Prix : `Core/Chantier.Core/Materials/OrderResponses.cs` (`CommercialProjection`, seul constructeur de `commercial`), `RequestSyncData.From` / `DeliverySyncData.From`, `MaterialEvent.IsSensitive`. Mobile : `database/converters/material_json_guard.dart` + `features/materials/data/materials_sync_decoder.dart`. Web : montants seulement via l'objet `commercial` ; `OrderFormModal.container.tsx` (`can("Prices.View")`).
- Photos : `Infrastructure/Services/Materials/PhotoService.cs`, `Imaging/JpegMetadataStripper.cs` (liste blanche), `Storage/{FileSystemPhotoStorage,PhotoMaintenance,PhotoStorageOptionsValidator}.cs`, `WebApi/Controllers/Materials/PhotosController.cs`. Mobile : `features/materials/data/{photo_files,photo_upload_service,photo_remote,supplier_contact}.dart`.
- Synchro : `Infrastructure/Sync/{SyncPushService,SyncWindow,SyncTouch,SyncPullService,RequestSyncPushHandler,DeliverySyncPushHandler}.cs`, mobile `core/sync/sync_engine.dart` (`_push`, `_applyResult`).
- Verrous et rejeu : `Persistence/{AppLocks,DbTransactions,SqlErrors}.cs`, `Services/Materials/MaterialLocks.cs`, `Middlewares/GlobalExceptionMiddleware.cs` (503).
- Rapport : `docs/revues/demandes-materiaux-livraisons.md` (R2-01 à R2-16, section R2 bis, R3-01 à R3-10).

## Pièges connus
- R2-01 (interblocages sur `POST …/order`), R2-02 (poids de la synchro), R2-03 à R2-05, R2-08, R2-10, R2-11 : **corrigés et vérifiés le 2026-11-25 (R2 bis)** ; mesures : 840 commandes à 8 en parallèle = 840 × 201, première synchro 29 Ko gzip pour 312 demandes ouvertes, affectation 1,15 s / 34 Ko gzip.
- Un nouveau test de concurrence se fait toujours sur une **base neuve** (le plan change quand la table grossit) ; avec `READ_COMMITTED_SNAPSHOT` plus aucun interblocage observé.
- Les rapports d'interblocage de `system_health` sont à filtrer par base (`currentdbname`) : ceux des bases `chantier_test_*` viennent des tests de backend-dotnet, pas de l'API mesurée.
- Statut push `retry` : les opérations dépendantes (par `clientId` du parent) ne sont pas écartées, ni côté serveur ni côté mobile : elles tombent en « À vérifier » (R3-01, ouvert).
- Web : `resetApiState` seulement à la déconnexion volontaire (R3-03) ; code `ERREUR_TEMPORAIRE` sans libellé web (R3-02) ; chaque essai de photo crée une nouvelle photo et consomme une place 24 h (R3-04).
- Fenêtre de synchro de 60 jours : aucune pierre tombale pour les lignes qui en sortent ; pas de rechargement complet sur le mobile après une longue absence (R3-05).
- Dans une transaction avec verrou applicatif, relire une entité déjà suivie ne la rafraîchit pas : `ChangeTracker.Clear()` avant (corrigé dans `PhotoService.UploadAsync`) ; à chercher ailleurs.
- Les trois index `RowVersion` ne servent qu'à partir de quelques dizaines de milliers de lignes (0 recherche à 2 000 lignes, 20 ms avec 102 663).
- Texte libre (`order.note`, motifs) : seul canal de prix non filtré, accepté ; avertissement dans le formulaire web (fr/ar).
- Mobile : fichiers de photos en attente non chiffrés et gardés après déconnexion (R2-16, ouvert, attend SQLCipher) ; SHA-256 écrit à la main (R3-10).

## Commandes qui marchent (base jetable, API de dev intacte)
- Créer : `MSYS_NO_PATHCONV=1 docker exec chantier-dev-db sh -c '/opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "CREATE DATABASE chantier_revue_r3"'`. `-I` obligatoire pour les UPDATE sur colonnes indexées/filtrées et les méthodes XML ; `-W` et `-y`/`-h` incompatibles ; `GROUP BY` impossible sur une méthode XML (passer par `#temp`). Supprimer : `SINGLE_USER WITH ROLLBACK IMMEDIATE` puis `DROP DATABASE`.
- Lancer : copier `WebApi/Chantier.WebApi/bin/Debug/net10.0` dans le dossier de session ; chaîne et clé JWT lues par `dotnet user-secrets list | grep … | sed` **sans les afficher** (`Server=127.0.0.1,`) ; **toujours** `nohup env VAR=… "ConnectionStrings__ChantierDb=$CS" "JwtSettings__Key=$JK" Seed__Demo=true Database__MigrateOnStartup=true RateLimiting__Global__PermitLimit=100000 Storage__MaintenanceIntervalMinutes=0 dotnet Chantier.WebApi.dll --urls http://localhost:8199`. Filtrer la sortie d'une instance de test par `sed -E 's/(Password|Pwd)=[^;"]*/\1=<masqué>/Ig'`.
- Comptes : `admin.dev`, `chef.dev`, `equipe.dev`, `conducteur.dev`, `achats.dev`, `direction.dev`, `nonaffecte.dev`, mot de passe de `appsettings.Development.json` (`Seed:DemoPassword`) ; `POST /auth/login` renvoie `user.id`. Pas de route `/users`.
- Semer : push par lots de 100 (`entity=request`, `operation=create`), `batch/approve` par 50 (conducteur), `POST …/order` à 8 en parallèle (achats + admin), livraisons REST (≈ 50 s pour 2 520), photos : métadonnées seulement. Vieillir pour tester la fenêtre : `UPDATE MaterialRequests SET Status=…, UpdatedAt=DATEADD(day,-90,…)` (avec `-I`). Gonfler une table : `INSERT … SELECT` dynamique depuis `sys.columns` (sans `RowVersion`), `Number` modifié, `ClientId` NULL (102 663 lignes en quelques secondes).
- Provoquer un échec momentané : session SQL externe `docker exec -d … "BEGIN TRAN; UPDATE SiteCounters SET LastValue=LastValue WHERE Prefix=N'DEM'; WAITFOR DELAY '00:00:50'; ROLLBACK"` puis `POST /requests` (503) et `POST /sync/push` (`retry`) après 30 s.
- Maintenance des photos : lancer une 2e instance de 40 s (port 8197) avec `Storage__MaintenanceInitialDelayMinutes=0` après avoir préparé `.staging/old.part` (`touch -d`), un fichier à nom GUID hors base (le contrôle d'orphelins ignore les noms qui ne suivent pas le format) et des photos `Pending` vieillies. Démarrage en production refusé : instance `ASPNETCORE_ENVIRONMENT=Production` (échoue aussi sur le certificat DataProtection, normal).
- Index utilisés : `sys.dm_db_index_usage_stats` (delta avant/après) et plans via `sys.dm_exec_query_plan`.
- Journal SQL par appel : `Logging__LogLevel__Microsoft.EntityFrameworkCore.Database.Command=Information`.
- Dépendances : `dotnet list Chantier.sln package --vulnerable --include-transitive` (aucune), `npm audit` sur copie de `package.json` + lock (prod 0, complet 39 : outillage), `flutter pub outdated --no-dev-dependencies` (aucun avis ; `image_picker` 1.2.4, `url_launcher` 6.3.3, `path_provider` 2.1.6 à prendre).
- Arrêt de l'API jetable : `Get-NetTCPConnection -LocalPort 8199` puis `Stop-Process` sur ce seul processus.

## Reste à revoir
- Décisions en attente chez l'architecte : fenêtre et rechargement après 60 jours (R3-05), SHA-256 maison (R3-10), photo du bon visible du ChefChantier (R2-12, décidé : oui).
- Non jugé : B11 (démonstration) en profondeur, M9 passe 2, démarrage à froid et mémoire du mobile (appareil absent).
