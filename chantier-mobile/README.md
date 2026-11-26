# chantier-mobile

Application terrain **hors ligne d'abord** (Flutter, Android seul au socle). Decisions : `docs/adr/0008-mobile-etat-navigation-base-locale-i18n.md`
(etat, base locale, jetons, i18n) et `docs/adr/0009-synchronisation-hors-ligne.md` (protocole). Plan : `docs/plans/socle.md` (taches M1 a M8).

Flutter **3.35.7 / Dart 3.9.2** (ne pas monter sans ADR). Identifiant d'application provisoire `dz.chantier.terrain`, Android 6 minimum (`minSdk 23`, Keystore).

## Commandes

```powershell
cd chantier-mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift (*.g.dart) ; fichiers generes commites
flutter gen-l10n                                            # lib/l10n/generated (lance aussi par flutter pub get / run)
dart run swagger_parser                                     # client d'API depuis ../docs/api/openapi.json (lib/core/api/generated/)
dart format lib                                             # a lancer apres swagger_parser + build_runner (le diff CI l'exige)
flutter analyze                                             # zero avertissement attendu
flutter test                                                # aucun appel reseau reel (faux serveur HTTP)
```

Lancer sur l'emulateur (API de developpement sur le port 8195 de la machine) :

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8195/api/v1   # valeur par defaut
```

Telephone reel : `adb reverse tcp:8195 tcp:8195` puis `--dart-define=API_BASE_URL=http://localhost:8195/api/v1`.
En production, `API_BASE_URL` doit etre en `https://` (verifie au demarrage). Le HTTP en clair n'est autorise que par la configuration reseau du profil **debug**
(`android/app/src/debug/res/xml/network_security_config.xml`).

Build de production (apres acceptation des licences : `flutter doctor --android-licenses`) :
`flutter build apk --release --obfuscate --split-debug-info=build/debug-info --dart-define=API_BASE_URL=https://...`

## Livraison (a verrouiller AVANT toute diffusion de l'APK)

Hors socle, mais bloquant pour une diffusion (revue `docs/revues/socle.md`, R1-04, R1-19, R1-21) :

- **Signature (R1-19)** : le build `release` est signe avec la **cle de debug** (`android/app/build.gradle.kts`),
  pour le seul confort de `flutter run --release`. Un APK ainsi signe **ne doit pas etre diffuse**. A faire :
  creer un keystore de livraison **hors du depot** (`*.jks`, `*.keystore` et `android/key.properties` sont deja ignores),
  declarer un `signingConfig` `release` lu depuis `key.properties` (ou les secrets de la CI), puis verifier la signature
  (`apksigner verify`). Aucune cle n'est generee dans le depot ; la decision de stockage de la cle releve de l'utilisateur.
- **Obfuscation** : `--obfuscate --split-debug-info=<dossier>` est obligatoire dans la commande de build (ci-dessus) ; conserver
  les symboles hors depot (`**/debug-info/` est ignore). Verifier aussi `minifyEnabled` / `shrinkResources` et privilegier un
  bundle ou `--split-per-abi` (taille).
- **Sauvegarde Android (R1-04)** : `allowBackup="false"` et regles d'exclusion (`res/xml/data_extraction_rules.xml`,
  `backup_rules.xml`) : la base locale n'est jamais envoyee vers un compte Google. Controle statique : `test/android/manifest_test.dart`.
- **Chiffrement de la base** : SQLCipher est **exige avant** de synchroniser des telephones ou des evaluations d'ouvriers
  (ADR 0008). Au socle, la base ne contient que des chantiers, des zones, des noms d'affectes et, selon le role, le montant du marche.
- **Dependances a suivre (R1-21a)** : `sqlite3_flutter_libs 0.5.42` est remplace (`0.6.0+eol`) et `flutter_secure_storage` a une
  version majeure plus recente : a traiter dans l'ADR de mise a niveau qui introduira le chiffrement (aucune montee ici : Flutter 3.35.7 fige).

## Structure

```
lib/
  main.dart  app.dart
  core/{config,di,logging,network,router,storage,sync,theme,l10n,widgets}
  database/{app_database.dart, tables/, daos/, converters/}
  features/<fonctionnalite>/{domain,data,presentation}
  l10n/{app_fr.arb, app_ar.arb}        # gabarit francais ; arabe = RTL automatique
drift_schemas/                         # schema Drift exporte, une version par fichier
test/                                  # miroir de lib/ + support/ (faux serveur, fixtures)
```

## Client d'API et synchronisation

- `lib/core/api/generated/` : **genere** depuis `docs/api/openapi.json` (swagger_parser 1.46.0 + retrofit 4.4.2, ADR 0006) ; jamais modifie a la main.
  Enchainement : `dart run swagger_parser` -> `dart run build_runner build --delete-conflicting-outputs` -> `dart format lib`.
- `SyncChange.data` est un objet libre : decode **selon `entity`** (`site`, `zone`, `member`, `product`, `supplier`, `request`, `delivery`, `photo`) par
  `features/sites/data/sync_decoder.dart`. Les lignes `product`, `supplier`, `request`, `delivery` et `photo`
  sont lues a la main (`features/materials/data/materials_sync_decoder.dart`) : l'historique d'une demande a des statuts absents, que les modeles generes refusent.
- **Ordre du pull** : le serveur range une page parents d'abord, mais **entre deux pages aucun ordre n'est garanti** (ecart 26 du contrat). Le telephone suspend donc
  les cles etrangeres le temps d'une page (`SitesRepository.applyPullPage`), applique tout le pull, puis retire les lignes dont le chantier n'est jamais arrive
  (`AppDatabase.deleteOrphans`, a la derniere page). Les saisies en attente ne sont jamais touchees.
- Moteur : `core/sync/sync_engine.dart` (push par lots de 50, pull a curseur serveur, puis **fichiers des photos de bons**) ; declencheurs : `sync_scheduler.dart`.
  Un resultat `retry` (`ERREUR_TEMPORAIRE`) laisse l'operation en file : elle n'est pas renvoyee dans la meme execution, reprise avec delai exponentiel.
  Ses **dependants** (operations qui la visent par `requestClientId`, `deliveryClientId` ou `zoneClientId`, transitivement) restent en file eux aussi : ni envoyes, ni rejetes (R3-01).
- **Rechargement complet** (R3-05) : le serveur ne renvoie plus les demandes closes depuis plus de 60 jours et n'envoie aucune pierre tombale. Le pull repart de zero
  (`AppDatabase.startWindowReload` : demandes, livraisons et photos **confirmees** effacees, saisies en attente, file d'envoi et fichiers de photos conserves) quand la reponse
  porte `resetRequired` (ignore jusqu'a la fin du rechargement, drapeau `full_reload`) ou quand la derniere synchronisation reussie date de plus de
  `--dart-define=FULL_RELOAD_AFTER_DAYS` jours (60 par defaut, `0` = jamais).

## Livraisons et photos de bons (M6 a M8, ADR 0012 et 0013)

- Ecrans (`features/materials/presentation/deliveries/`) : **A recevoir**, **Recevoir** (3 gestes, 6 avec la photo du bon), **A receptionner** (1 geste),
  **Livraisons** (dont « Non rattachees »), detail et correction ; accueil du chantier : tuiles selon les permissions (absentes, jamais grisees).
- **Photos** : `image_picker` (appareil photo seulement, 1 920 px, JPEG qualite 80, **aucune permission** : la prise passe par l'application photo du telephone),
  fichier range dans `<dossier prive>/<ownerUserId>/pending_photos/` (`path_provider` : dossier de l'application, exclu de la sauvegarde Android), empreinte SHA-256
  calculee dans un isolat (`core/utils/sha256.dart`, vecteurs NIST testes), 5 photos au plus par livraison. Envoi (`PhotoUploadService`) : **un fichier a la fois,
  apres le push des metadonnees**, `PUT` direct `Content-Type: image/jpeg`, fichier supprime **apres** la confirmation du serveur, reprise apres coupure (renvoi complet
  idempotent), `409 CONFLIT_VERSION` = rejouer (R2-04). Refus definitif (413, 415, 422, empreinte) : le fichier est garde et signale dans « Envois en attente ».
- **Appeler le fournisseur** (`url_launcher`, composeur `tel:` sans `CALL_PHONE`) : le numero est lu **en ligne** (`GET /suppliers/{id}`), affiche dans une boite de dialogue,
  jamais stocke (ni base, ni cache, ni journal).
- **Historique** (R2-02) : la synchronisation envoie `history[]` vide ; le detail d'une demande ou d'une livraison le lit **a la demande, en ligne** (`GET /sites/{id}/requests|deliveries/{id}`, `HistorySection`), assaini (aucun prix) et jamais ecrit en base ; hors ligne : « Historique indisponible hors ligne » (ou la copie lue plus tot pendant la session, en memoire).
- **Listes** (R2-07) : lecture legere (`watchBySiteLight` sans `history_json`) et emissions regroupees (`throttleLatest`, 300 ms) ; l'historique n'est lu qu'au detail.
- Permissions Android : seulement `INTERNET` (`test/android/manifest_test.dart`) ; `<queries>` pour le composeur.

- Essai reel : lancer l'API (`Seed__Demo=true`, port 8195, voir `docs/exploitation`) et ouvrir l'application sur l'emulateur ;
  comptes `*.dev`, mot de passe = `Seed:DemoPassword` de `appsettings.Development.json`.

## Regles a connaitre

- **Aucun texte en dur** : toute chaine passe par les ARB (`fr` et `ar`, memes cles ; test de parite). Les erreurs serveur sont traduites **par `code`** (`core/l10n/error_messages.dart`).
- **Codes, dates, cotes, montants** : `LtrText` en interface arabe ; chiffres 0-9 (`core/l10n/formatters.dart`).
- **Demandes de materiaux** (`features/materials/`, ADR 0011 a 0014) : **aucun prix, montant, n° de bon de commande ni telephone de fournisseur** dans la base du telephone, pour aucun role
  (garde `database/converters/material_json_guard.dart`, test `test/database/materials_privacy_test.dart`). Le calcul d'affichage (`QuantityMirror`) est teste par
  `docs/api/vecteurs-materiaux.json`, partage avec le serveur et le web : une regle de calcul change d'abord ce fichier. Le serveur fait foi, le telephone n'affiche
  qu'un etat provisoire « a confirmer ».
- **Jamais de `double`** pour une quantite, une cote ou un montant : texte decimal (`DecimalTextConverter`), aucune arithmetique cote mobile.
- **Jetons** : `flutter_secure_storage` uniquement. Un echec de rafraichissement ne supprime que les jetons, jamais la base locale ni la file d'envoi.
- **Journaux** : `package:logging`, jamais `print`, aucune donnee personnelle ni jeton.
- **Changer une table** : incrementer `AppDatabase.currentSchemaVersion`, ecrire la migration, puis
  `dart run drift_dev schema dump lib/database/app_database.dart drift_schemas/` et
  `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/` ; `test/database/migration_test.dart` echoue sinon.
- **Tests Drift** : SQLite natif en memoire. Windows 10/11 : `winsqlite3.dll` du systeme (rien a installer). Linux/CI : `libsqlite3-dev`.
  Surcharge facultative : variable `SQLITE3_DLL`.
- **Police Cairo** (SIL OFL) embarquee dans `assets/fonts/` : aucun telechargement a l'execution.
