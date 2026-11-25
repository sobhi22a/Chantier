# ADR 0008 : Mobile : état, navigation, base locale, jetons, i18n

**Date :** 2026-11-24 · **Statut :** Acceptée · **Auteur :** architecte-chantier

## Contexte
Le mobile est l'outil du chef de chantier et des chefs d'équipe : téléphone d'entrée de gamme (Android très probable), réseau faible ou absent, plein soleil, gants,
saisie en moins de 30 secondes. Kardinal fournit : BLoC/Cubit, GetIt, Dio, GoRouter. Mais (`docs/architecture/reference-kardinal.md`, §0 et §6) :
Drift et Freezed sont déclarés **sans être utilisés** ; la base locale réelle est du sqflite manuel avec une cible web ; les jetons sont dans `SharedPreferences` ;
l'i18n est un `Map` Dart en/fr sans arabe ; l'URL de l'API dépend de `kReleaseMode`.

## Options étudiées
| Sujet | Option retenue | Alternatives écartées |
|---|---|---|
| État | **flutter_bloc 9** (Bloc pour l'authentification et la synchro, Cubit sinon) + `equatable` | Riverpod (déclaré chez Kardinal, deux systèmes d'état), Provider |
| Injection | **GetIt** (comme Kardinal) | injectable (génération de code en plus) |
| Navigation | **go_router** (comme Kardinal), `refreshListenable` sur l'état d'authentification | Navigator 2 à la main |
| Base locale | **Drift** (+ `drift_flutter`, `sqlite3_flutter_libs`) : tables typées, flux réactifs, migrations versionnées, base en mémoire pour les tests | sqflite manuel (Kardinal : verbeux, non typé) ; Isar et Hive (maintenance incertaine) ; ObjectBox, Realm (licences et dépendances natives) |
| Modèles | **freezed 3 + json_serializable** (modèles générés par `swagger_parser`, ADR 0006) | classes écrites à la main |
| Jetons | **flutter_secure_storage** (Keystore Android) | SharedPreferences (Kardinal : en clair) |
| i18n | **`flutter_localizations` + `intl` + ARB** (`gen-l10n`), `fr` et `ar` | `Map` Dart (Kardinal), easy_localization (bibliothèque en plus) |
| HTTP | **Dio** (comme Kardinal) | http |
| Réseau | `connectivity_plus` uniquement comme **déclencheur** de synchro ; la vérité est le résultat des requêtes | se fier à l'état « connecté » seul |
| Décimaux | paquet `decimal` pour **afficher et valider** ; stockage en texte | `double` (Kardinal) |

## Décision
Imiter Kardinal pour l'état, l'injection, la navigation et Dio ; corriger la base locale, les jetons, l'i18n et la configuration.

**Projet.** `chantier-mobile/`, nom de paquet `chantier_mobile`, **Android uniquement** au socle (`flutter create --platforms android --org dz.chantier`) ; iOS plus tard sur décision. Pas de cible web ni desktop.
Identifiant d'application provisoire `dz.chantier.terrain` (hypothèse à confirmer avant toute publication).

**Structure** (inspirée de `lib/features/<feature>/{domain,data,presentation}` de Kardinal, noms en `snake_case`) :
```
lib/
  main.dart  app.dart
  core/{config,di,network,router,storage,sync,theme,l10n,widgets}
  database/{app_database.dart, tables/, daos/, converters/}
  features/{auth,sites,settings}/{domain,data,presentation}
  l10n/{app_fr.arb, app_ar.arb}
```
Pas de cas d'usage (`usecases/`) tant qu'il n'y a pas de logique à y mettre : sauf `auth`, un Cubit parle au dépôt de la fonctionnalité.

**Principe hors ligne.** L'interface lit **uniquement** la base locale (flux Drift). Le réseau n'alimente que la base, via le moteur de synchronisation (ADR 0009). Aucune action de saisie n'attend le réseau.
**Téléphone partagé (CA-002.4).** À la déconnexion, toutes les données synchronisées (chantiers, zones, affectations, préférences) sont **purgées**. Seules les lignes de `outbox_operations` restent, étiquetées `owner_user_id` ; le moteur n'envoie et l'interface ne montre
que les lignes de l'utilisateur connecté. Un autre compte ne voit donc rien de A ; A retrouve ses saisies en attente à sa reconnexion (la déconnexion avec envois en attente demande confirmation, CA-002.3).
Sur `ACCES_RETIRE` (compte désactivé), les données chantier sont aussi purgées. Si `permissionsVersion` (renvoyée par `GET /auth/me`) change, le curseur est remis à zéro (rechargement complet, file conservée).
**Préférences par utilisateur** (Drift, table `user_prefs`, purgée à la déconnexion) : chantier courant (CA-010), dernière zone utilisée (CA-009.1), langue. Dernier identifiant saisi : stocké dans `shared_preferences` (non sensible) pour le préremplir (CA-001.2).
Session hors ligne : valide si le dernier contact réussi avec le serveur date de moins de 14 jours (`sync_state.last_server_contact_at`, H-05, paramétrable).
Le chiffrement de la base (SQLCipher) est **exigé avant** de synchroniser toute donnée personnelle (intervenants, téléphones) ; le socle ne contient aucune donnée de ce type.

**Types.** Dates métier en texte `yyyy-MM-dd` ; horodatages en entier UTC ; **décimaux en texte** (convertisseur Drift) ; aucune arithmétique sur quantités ou montants côté mobile (règle 3).

**Configuration.** `--dart-define=API_BASE_URL=https://…/api/v1` (défaut de développement `http://10.0.2.2:8195/api/v1` pour l'émulateur) ; aucune bascule sur `kReleaseMode`. HTTP en clair autorisé uniquement par la configuration réseau du profil debug.

**Dio.** `DioClient` de Kardinal conservé dans l'esprit : intercepteur d'autorisation, **un seul rejeu** après refresh sur 401, Dio « nu » pour le refresh ; changements : jetons dans le stockage sécurisé, **un refresh échoué n'efface ni base ni file d'envoi**,
en-tête `Accept-Language`, conversion de tout `application/problem+json` en `ApiException(code, status, traceId)`, délais courts (connexion 10 s, réception 30 s).

**i18n.** ARB `app_fr.arb` (gabarit) et `app_ar.arb` ; `Locale` mémorisée ; RTL automatique par `Directionality` ; **chiffres latins** (locale de formatage `ar_DZ`, à vérifier par un test de widget) ; police **Cairo embarquée** dans les assets (pas de téléchargement à l'exécution).
Les erreurs serveur sont traduites par `code` (`errors.<CODE>`). Test : clés FR et AR identiques.

**Ergonomie terrain (contraintes de thème, H-16, CA-014.8).** Contraste ≥ 4,5:1 (visé 7:1 pour les textes principaux), cibles tactiles ≥ 48 dp et **56 dp pour les boutons principaux**, texte courant ≥ 16 sp, valeurs clés (code chantier, cote) ≥ 20 sp,
respect de l'échelle de texte du système, boutons principaux en bas de l'écran (accès au pouce), pas d'information portée par la seule couleur (icône + texte pour l'état de synchro).
**Sens de lecture** : en arabe, les codes (`CH-ECO-UV18`, `DEM-001`), dates, montants et cotes restent **de gauche à droite** : widget `LtrText` (`Directionality(ltr)`) obligatoire pour ces valeurs ; tests de widget en arabe.
Écrans réutilisables du socle : `ZonePicker` (bloc, puis cote, puis local ; dernière zone préchoisie ; recherche libre au-delà de 8 valeurs) et `SyncStatusBar` (en haut de **tous** les écrans).

**Qualité.** `flutter_lints` + `always_use_package_imports` ; `avoid_print` actif (Kardinal compte 4 `print`) ; journalisation via `package:logging` **sans donnée personnelle** ; tests : `flutter_test`, `bloc_test`, `mocktail`, base Drift en mémoire.

## Conséquences
- Plus facile : écrans toujours rapides (lecture locale) ; migrations de schéma testables ; traduction complète dès le premier écran.
- Plus difficile : génération de code (`build_runner`) à chaque modification de table ou de modèle ; deux représentations d'une entité (réponse API, ligne Drift) à convertir.
- À surveiller : taille de l'APK (Drift + SQLite + Cairo) ; compatibilité des paquets avec Flutter 3.35 / Dart 3.9 (on ne monte pas Flutter sans ADR) ; temps de génération sur poste modeste.
