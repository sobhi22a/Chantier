---
name: qa-commandes-et-pieges
description: Commandes de test des trois parties, zones fragiles et pièges de test vérifiés lors de la QA du socle (Q1, 2026-11-24)
metadata:
  type: project
---

## Commandes qui marchent
- Backend : `cd chantier-backend; set -a; . ../.env; set +a; export CHANTIER_TEST_SQL="Server=localhost,14335;User Id=sa;Password=${MSSQL_SA_PASSWORD};TrustServerCertificate=True;Encrypt=False"; dotnet test Chantier.sln -p:OpenApiGenerateDocuments=false` (~2 min, conteneur `chantier-dev-db` ; le build arrête sinon si l'API tourne depuis `bin/Debug`). Tests QA : `Tests/Chantier.IntegrationTests/Qa/`.
- Web : `cd chantier-frontend; npx nx run-many -t lint test build typecheck --skip-nx-cache` (~30 s). Un fichier : `cd apps/chantier-back-office; npx vitest run src/qa`.
- Mobile : `cd chantier-mobile; flutter analyze; flutter test` (~20 s). Captures PNG : `QA_CAPTURES=D:/chemin flutter test test/qa/captures_test.dart`.
- Playwright réel : lancer l'API (`ASPNETCORE_ENVIRONMENT=Development Seed__Demo=true`, base temporaire via `ConnectionStrings__ChantierDb`, clé JWT aléatoire) + `npx nx serve chantier-back-office`, puis `QA_DEMO_PASSWORD=<Seed:DemoPassword lu par script> npx playwright test --project=chromium` dans `apps/chantier-back-office-e2e`. Arrêter les processus (ports 8195, 3600) et supprimer la base ensuite.
- Interblocage SQL : `DBCC TRACEON(1222,-1)` puis `sp_readerrorlog 0,1,'deadlock-list'` via `docker exec -e SQLCMDPASSWORD=... chantier-dev-db /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa` (`MSYS_NO_PATHCONV=1`).

## Pièges connus
- Flutter : sans la police réelle, `flutter_test` mesure en « Ahem » (1 em par caractère) et invente des débordements : charger Cairo avec `FontLoader('Cairo')..addFont(rootBundle.load('assets/fonts/Cairo-Variable.ttf'))` dans `setUpAll`. Police agrandie : `tester.platformDispatcher.textScaleFactorTestValue`.
- Flutter : une ligne de pull illisible annule toute la page (rien d'écrit) ; écrire une zone locale exige que son chantier soit déjà synchronisé (clé étrangère).
- Playwright : `getByLabel('Mot de passe')` trouve aussi le bouton « Afficher le mot de passe » → `{ exact: true }`. Le traceId change à chaque réponse : le retirer avant de comparer deux messages d'erreur.
- Limite de débit `auth` : 10 connexions / 5 min par (adresse, identifiant), réussites comprises. Une seule connexion API par exécution de test ; un redémarrage de l'API remet le compteur à zéro.
- Une `ApiSession` de test n'envoie que des corps sérialisés : `SendRawAsync` pour du JSON brut (1e40, surrogate isolé).
- Python sous Git Bash : les chemins `/d/...` ne marchent pas, utiliser `D:\...` (r-string). Heredocs avec apostrophes : préférer l'outil Write.
- Le mot de passe de démonstration est dans `appsettings.Development.json` (`Seed:DemoPassword`) et peut fuiter dans `test-output/` de Playwright : supprimer ce dossier.

## Zones fragiles
- Numérotation : compteurs créés avec le chantier + migration de rattrapage + repli `sp_getapplock` (D-1 et D-6 clos). Tout changement de verrouillage se rejoue en `NumberingStabilityTests` (15 tours x 6 passages) : l'erreur d'origine était intermittente. Le chantier « ancien » (sans compteurs) se simule en supprimant les lignes de `SiteCounters`.
- Limiteur : placé avant l'autorisation, seau par utilisateur (jeton ou cookie valide), par adresse sinon (D-7 clos). Tout déplacement de middleware se re-teste avec 400 appels anonymes puis un utilisateur valide de la même adresse.
- Mesures réelles utiles : 300 requêtes/min par utilisateur ; 35 s d'attente pour sortir de la grâce du refresh (30 s) ; 8 Mo sur `/auth/login` = 413.

## Défauts récurrents
- Valeurs par défaut des formulaires de l'US non implémentées (CA-008.6 wilaya du dernier chantier).
- Tests périmés après un changement de squelette (smoke Playwright de W1) : vérifier à chaque lot que les scénarios e2e existent et sont lancés par la CI (rien ne les lance à ce jour).
