## Conventions
- Code Dart en `snake_case`, imports `package:chantier_mobile/...` (lint `always_use_package_imports`), commentaires sans accents, textes UI uniquement via ARB (`lib/l10n/app_fr.arb` gabarit + `app_ar.arb`).
- Erreurs serveur traduites par `code` (`core/l10n/error_messages.dart`) ; le test compare au catalogue `docs/api/codes-erreur.md` : tout nouveau code = ARB fr+ar + `switch`.
- Decimaux en texte (`DecimalTextConverter`), dates metier `yyyy-MM-dd`, versions serveur en `int` comparees numeriquement.
- `LtrText` pour codes, dates, cotes, montants ; dans une phrase arabe : `Formatters.isolateLtr` (LRI/PDI). Boutons principaux 56 dp, texte >= 16 sp, valeurs cles 20 sp.
- Aucune ecriture locale sans operation d'envoi : `OutboxRepository.saveWithOperation` (une transaction). `clientId` cree a l'ouverture du formulaire.
- Tri des noms : `core/utils/collation.dart` (SQLite ne plie pas les accents).

## Chemins clés
- `chantier-mobile/` (Android seul, `dz.chantier.terrain`, minSdk 23) ; README du dossier = commandes et regles.
- Reseau : `core/network/*`, client genere `core/api/generated/` (jamais a la main) + `core/api/api_clients.dart`. Sync : `core/sync/{sync_engine,sync_scheduler,sync_status_cubit,current_site,outbox_repository}.dart`, decodeur `features/sites/data/sync_decoder.dart`.
- Auth : `features/auth/*` (`AuthBloc`, `AuthRepositoryImpl`), routes `core/router/app_router.dart` (`redirectFor` pur, teste).
- Tests : `test/support/{fake_http_adapter,fake_sync_remote,fake_auth_repository,api_json,pump_app,test_database,fixtures}.dart`.

## Commandes qui marchent
- `flutter pub get` ; `dart run swagger_parser` puis `dart run build_runner build --delete-conflicting-outputs` puis `dart format lib` (ordre obligatoire : swagger_parser n'ecrit pas du code formate) ; `flutter analyze` ; `flutter test` (625 tests + 8 captures ignorees, ~30 s) ; `dart format --output=none --set-exit-if-changed lib test`.
- Apres changement de table : incrementer `AppDatabase.currentSchemaVersion`, `dart run drift_dev schema dump lib/database/app_database.dart drift_schemas/` puis `schema generate drift_schemas/ test/generated_migrations/`.
- Tests Drift sous Windows : `winsqlite3.dll` systeme (rien a installer) ; Linux : libsqlite3-dev.
- Essai reel : `ASPNETCORE_ENVIRONMENT=Development Seed__Demo=true dotnet run --no-build --no-launch-profile --urls http://localhost:8195` dans `chantier-backend/WebApi/Chantier.WebApi` ; mot de passe demo = `Seed:DemoPassword` (lu par script, jamais affiche). Arreter ensuite le processus du port 8195.

## Pièges connus
- Champ reserve (montant du marche) : `upsertIfNewer` ignore les versions egales ; un changement de `permissionsVersion` passe par `AppDatabase.startFullReload(clearRestrictedFields: true)` (efface le montant tout de suite + drapeau `full_reload` qui ecrase pendant le rechargement). Ne jamais appeler `resetCursor` seul pour un changement de permissions.
- Android : `allowBackup="false"` + `res/xml/{data_extraction_rules,backup_rules}.xml` ; garde-fou `test/android/manifest_test.dart`. Release signe avec la cle de debug : documente (README « Livraison »), ne pas diffuser.
- Noms de personnes dans une phrase : `Formatters.isolateName` (latin isole, arabe laisse). Texte de ligne qui peut passer a la ligne a 320 dp / police x2 : `Expanded` dans le `Row`.
- Fiche chantier : `ListView.builder` sur une liste aplatie de closures (R1-15).
- Apostrophes dans un titre de test genere par script Python : les retirer (sinon Dart ne parse plus).
- Flutter 3.35.7 : `bloc_test` borne `analyzer` < 8 : drift/drift_dev 2.28, freezed 3.0, json_serializable 6.9, json_annotation 4.9, `drift_flutter` < 0.2.7, swagger_parser 1.46.0 (`use_freezed3: true`), retrofit 4.4.2 + retrofit_generator 9.1.9.
- Les clients generes ont des chemins complets `/api/v1/...` : leur `baseUrl` = `AppConfig.serverRootUrl` (sans `/api/v1`). `dio` nu (`bareDio`) pour login/refresh.
- `app_database.dart` doit importer convertisseurs et `decimal` (utilises par le `.g.dart`). `insertOnConflictUpdate(row)` ignore les `null` : utiliser `row.toCompanion(false)`.
- Bidi : ecrire `⁦`/`⁩` en echappements (lint `text_direction_code_point_in_literal`) ; `findTextContaining` (pump_app) ignore les isolats.
- Tests de widgets avec un Bloc : le creer DANS le test (pas dans `setUp`), sinon `pump` n'avance pas ses evenements. `ListView` ne construit que le visible : agrandir `tester.view.physicalSize`.
- `SegmentedButton` ignore `minimumSize` (hauteur = police + padding vertical).
- Le moteur n'a pas de `GET /health` : `GET /auth/me` sert d'appel leger et recharge permissions + `permissionsVersion`.
- Heredocs bash avec apostrophes : preferer l'outil Write. Licences Android non acceptees : `flutter build bundle --debug` seulement.

## Décisions (lien ADR)
- ADR 0006/0008/0009. Refresh echoue : seuls les jetons sont effaces (`SessionEvent` authRequired / accessRevoked / passwordChangeRequired) ; la file d'envoi n'est jamais videe, sauf abandon explicite.
- Reste hors socle : photos, WorkManager, SQLCipher (avant donnees personnelles), `integration_test` sur emulateur.
