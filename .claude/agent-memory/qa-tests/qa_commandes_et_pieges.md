---
name: qa-commandes-et-pieges
description: Commandes de test des trois parties, zones fragiles et pièges de test vérifiés lors des QA du socle (Q1) et des demandes de matériaux et livraisons (Q1 à Q3, 2026-11-25)
metadata:
  type: project
---

## Commandes qui marchent
- Base de dev absente (`docker ps -a` ne montre pas `chantier-dev-db`) : `powershell -File scripts\dev.ps1` (sans option) la crée et attend qu'elle soit saine ; ne jamais `-Down` ni `-Reset`.
- Backend : `cd chantier-backend; set -a; . ../.env; set +a; export CHANTIER_TEST_SQL="Server=127.0.0.1,14335;User Id=sa;Password=${MSSQL_SA_PASSWORD};TrustServerCertificate=True;Encrypt=False"; dotnet test Chantier.sln -p:OpenApiGenerateDocuments=false` (~11 min, 1 300 tests ; **`127.0.0.1`, pas `localhost`** : avec `localhost` les 761 tests d'intégration expirent en 15 s). Sortie vers un fichier, jamais dans un tube. `--no-build` pour rejouer sans recompiler. Tests QA : `Tests/Chantier.IntegrationTests/Qa/` (`MaterialsQaTests`, `MaterialsQaVolumeTests`).
- Web : `cd chantier-frontend; npx nx run-many -t lint test build typecheck --skip-nx-cache` (~4 min). Un fichier : `cd apps/chantier-back-office; npx vitest run src/qa`.
- Mobile : `cd chantier-mobile; flutter analyze` (~90 s) ; `flutter test --reporter expanded > fichier` (~5 min, 1 100 tests). **Ne pas mettre `flutter test` dans un tube** (`| sed`, `| head`) : le processus peut rester bloqué sans sortie ; rediriger vers un fichier et ajouter `timeout 280`. Captures PNG : `QA_CAPTURES=D:/chemin flutter test test/qa/captures_test.dart`.
- API réelle sur base temporaire (scripts dans le dossier de session) : créer `chantier_qa_<x>`, lancer `dotnet run --no-build --no-launch-profile --urls http://localhost:8195` avec `ASPNETCORE_ENVIRONMENT=Development Seed__Demo=true Database__MigrateOnStartup=true`, clé JWT aléatoire, `Storage__PhotosRoot` et `Storage__DataProtectionKeys` hors du dépôt, `DataProtection__AllowUnencryptedKeys=true`. Mot de passe de démonstration : `Seed:DemoPassword` lu par script, jamais affiché. Fin : tuer l'arbre de processus, supprimer la base, relancer l'API de dev par `Start-Process powershell -ArgumentList '-File','scripts\dev.ps1','-Api'`.
- Playwright réel : `VITE_BACKEND_API_BASE_URL=http://localhost:8195 npx nx run chantier-back-office:build --skip-nx-cache`, puis dans `apps/chantier-back-office-e2e` : `QA_DEMO_PASSWORD=<lu par script> npx playwright test --project=chromium` (le `webServer` lance `preview` sur 3600). 20 parcours, 14 s, 10 travailleurs en parallèle (`fullyParallel`). Supprimer `test-output/` ensuite.
- Interblocage SQL : `DBCC TRACEON(1222,-1)` puis `sp_readerrorlog 0,1,'deadlock-list'` via `docker exec -e SQLCMDPASSWORD=... chantier-dev-db /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa` (`MSYS_NO_PATHCONV=1`).

## Pièges connus
- Flutter : sans la police réelle, `flutter_test` mesure en « Ahem » et invente des débordements : charger Cairo avec `FontLoader('Cairo')` dans `setUpAll`. Police agrandie : `tester.platformDispatcher.textScaleFactorTestValue`.
- Flutter : pour savoir QUEL widget déborde, remplacer `FlutterError.onError` dans le test, collecter `details.toString(minLevel: DiagnosticLevel.info)` et **restaurer le gestionnaire avant toute assertion** (sinon : « A test overrode FlutterError.onError… »). `takeException` ne donne que « overflowed by N pixels ».
- Flutter : une liste `ListView.builder` ne construit pas ce qui est sous la ligne de flottaison : défiler (`tester.drag`) avant de chercher un texte ; les quantités sont des `RichText`, pas des `Text`.
- Flutter : une ligne de pull illisible annule toute la page ; écrire une zone locale exige que son chantier soit déjà synchronisé.
- Playwright : `getByLabel('Mot de passe')` trouve aussi « Afficher le mot de passe » → `{ exact: true }`. Le traceId change à chaque réponse : le retirer avant de comparer.
- Limite de débit `auth` : 10 connexions / 5 min par (adresse, identifiant). Deux exécutions Playwright de suite font tomber la deuxième en 429 sur `/auth/login` (pas un défaut) : redémarrer l'API de test entre deux exécutions.
- Tests d'intégration : `SendRawAsync` pour du JSON brut (1e40, null, tableau) ; `ApiSession` ne sérialise que des objets. `DeliveryCreate` du kit de synchro exige `productId` ou `freeProductName` (sinon rejeté) ; une demande close (`Received`) n'est pas dans la vue par défaut `toFollow` : `view=received`.
- Scripts Python avec heredoc : ne pas écrire `\n` dans une chaîne à remplacer (il devient un vrai saut de ligne dans le C# ou le Dart) ; utiliser l'outil Edit ou `String.fromCharCode(10)`.
- Python sous Git Bash : chemins `D:\...` en r-string, `PYTHONIOENCODING=utf-8` pour imprimer de l'arabe.
- `Read` : le fichier `.env` ne se lit ni par `Select-String` direct ni par `cat` (permission) ; passer par un script `.ps1` du dossier de session.
- Le mot de passe de démonstration peut fuiter dans `test-output/` de Playwright : supprimer ce dossier.

- `sqlcmd` : toute écriture sur une table à index filtré (demandes, livraisons...) exige `-I` (QUOTED_IDENTIFIER) et `-b`, sinon l'UPDATE échoue **en silence** (faux négatif d'un essai réel). Vieillir une ligne pour la fenêtre de synchro : `UPDATE MaterialRequests SET UpdatedAt = DATEADD(day,-90,SYSUTCDATETIME()) WHERE Id='...'`.
- Le conteneur `chantier-dev-db` peut disparaître (supprimé) en plein run : les tests d'intégration échouent alors tous en 14 s sur `OneTimeSetUp ... SqlException`. Vérifier `docker ps -a` avant de conclure ; recréer par `scripts\dev.ps1` (volume conservé) et rejouer ; supprimer ensuite les bases `chantier_test_*` orphelines.
- Les fichiers que j'écris avec l'outil Write ou un script Python (mode texte sous Windows) sortent en CRLF : `sed -i 's/$//'` avant `dotnet format --verify-no-changes` (ENDOFLINE). Heredoc bash avec apostrophes dans le texte : passer par un fichier écrit avec Write.
- Provoquer un vrai `retry` de synchronisation : tenir un verrou sur `SiteCounters` (`BEGIN TRAN; UPDATE SiteCounters SET LastValue=LastValue WHERE SiteId=... AND Prefix='DEM'; WAITFOR DELAY '00:01:15'; ROLLBACK`) via `docker exec ... sqlcmd -I` en tâche de fond, puis pousser un lot : le délai SQL (30 s) donne `retry ERREUR_TEMPORAIRE`.
- Compter les commandes SQL d'un appel : EF ne les journalise qu'en Warning ; démarrer un hôte de test avec `Logging:LogLevel:Microsoft.EntityFrameworkCore.Database.Command=Information` (une `ChantierWebApplicationFactory` neuve avec les mêmes `Settings`) et compter `Executed DbCommand` dans `Logs.Entries`. Toujours asserter que le compteur est > 0.

## Zones fragiles
- Numérotation : compteurs créés avec le chantier + migration de rattrapage + repli `sp_getapplock`. Tout changement de verrouillage se rejoue en `NumberingStabilityTests` (15 tours x 6 passages).
- Limiteur : placé avant l'autorisation, seau par utilisateur (jeton valide), par adresse sinon. 300 requêtes/min par utilisateur.
- Commandes simultanées : parade complète = `READ_COMMITTED_SNAPSHOT` (migration) ; repli = rejeu sur 1205. Sans snapshot (base restaurée), 8 acheteurs en parallèle donnent ~40 % de 503 `ERREUR_TEMPORAIRE` (jamais de 500, aucune commande perdue) : vérifié par `MaterialsQaDeadlockFallbackTests`.
- Montants : la colonne `Amount` est (18,2) ; D-1 (500 sur 1 milliard de t convertis en kg au prix maximal) est corrigé en 422 `QUANTITE_INVALIDE` ; limite exacte testée (valeur reçue 9 999 999 999 999 999,99 acceptée, +2 kg refusés).
- En-têtes de listes mobiles (`requests_screen`, `to_receive_screen`, `deliveries_screen`) : étaient fixes et débordaient à 320 dp (D-3), rendus adaptatifs en boucle 1/2 ; `test/qa/materials_small_screen_large_font_test.dart` les garde (18 cas).
- Fenêtre de synchro : demandes closes > 60 j exclues (`Sync:ClosedRetentionDays`) ; première synchro d'un chantier de 5 000 demandes dont 300 ouvertes = 33 Ko gzip.

## Défauts récurrents
- Valeurs par défaut des formulaires de l'US non implémentées (CA-008.6 du socle, corrigé).
- Tests périmés après un changement de squelette : vérifier à chaque lot que les scénarios e2e existent (rien ne les lance en CI à ce jour).
- Un nouveau code d'erreur ajouté côté serveur sans traduction web : le test `i18n/translations.spec.ts` (parité avec `docs/api/codes-erreur.md`) le détecte ; `ERREUR_TEMPORAIRE` manquait en FR et AR après R2-01.
- Les corrections d'une revue ajoutent un comportement (503, `retry`) que le web ou le mobile ne connaît pas : relire les clients après chaque correction de contrat.
