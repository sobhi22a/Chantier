# Rapport QA : socle (connexion, rôles, chantiers, zones, hors ligne)

**Date :** 2026-11-24 (passe 1), 2026-11-25 (passes 2 et 3) · **Verdict final (passe 3) :** Conforme ; passe 2 : Conforme sous réserve de D-6 et D-7 (clos en passe 3) ; passe 1 : À corriger (1 Majeur) · **Auteur :** qa-tests

Verdict final : **Conforme**. Après la troisième passe : 1 451 tests passent (546 backend, 280 web, 625 mobile) plus 8 parcours Playwright ; les 24 critères techniques ont des tests ; aucun défaut ouvert. D-1 (Majeur, passe 1), D-6 et D-7 (Mineurs, passe 2) sont clos et vérifiés sur l'API réelle. Les sections « Troisième passe » puis « Seconde passe » détaillent les corrections ; « Passe 1 » est l'état initial conservé pour l'historique.


## Troisième passe (boucle 2/2, 2026-11-25) : clôture de D-6 et D-7

**Verdict final : Conforme.** Aucun défaut ouvert de sévérité Bloquant, Majeur ni Mineur dans le périmètre de cette QA. **D-6 et D-7 sont clos.** Les trois tests rouges de la passe 2 sont verts ; aucun test n'a été désactivé ni assoupli.

### Exécution
| Partie | Commande | Résultat réel |
|---|---|---|
| Backend, numérotation et limiteur | `NumberingStabilityTests`, `SiteNumberingTests`, `RateLimitRegressionTests`, 6 passages consécutifs | 28 réussis à chaque passage, **0 erreur SQL**, tour de 30 appels le plus long 88 ms ; premier numéro avec verrou sur le chantier : 0 à 2 ms dans les 4 variantes |
| Backend, chantier ancien sans compteurs (repli `sp_getapplock`) | **nouveau** `A_legacy_site_without_counter_rows_takes_the_fallback_path_without_deadlock_even_with_a_locked_site_row` ×4 | 4 sur 4 verts : 15 tours de 30 appels (un sur trois annulé) sans interblocage, 216 ms au maximum ; premier numéro avec la ligne du chantier déjà écrite par l'appelant : 10 à 13 ms (avant D-6 : 30 s puis `SqlException`) |
| Backend, série complète | `dotnet test Chantier.sln` | 153 unitaires verts ; intégration **393 sur 393 verts** (0 échec) |
| Backend, forme | `dotnet format Chantier.sln --verify-no-changes` | OK |
| Web | `npx nx run-many -t lint test build typecheck --skip-nx-cache` | 8 projets OK, 280 tests, aucun avertissement |
| Web, e2e | Playwright Chromium contre l'API de démonstration | 8 réussis |
| Mobile | `flutter analyze` ; `dart format` ; `flutter test` | aucun problème ; OK ; 625 réussis, 8 ignorés (captures), 0 échec |
| Total | | **1 451 tests passent** (546 backend, 280 web, 625 mobile, hors 8 e2e) |

### Vérification sur l'API réelle (base temporaire, comptes de démonstration)
| Contrôle | Avant | Après |
|---|---|---|
| D-7 : 400 requêtes anonymes sur `GET /sites` | 400 × 401, aucun 429 | **296 × 401 puis 104 × 429** |
| D-7 : 400 requêtes avec un jeton invalide | 400 × 401, aucun 429 | **400 × 429** (seau d'adresse) |
| R1-01 non régressé : `chef.dev` et `equipe.dev` juste après l'épuisement du seau anonyme de l'adresse | — | 200 pour les deux ; `chef.dev` seul : 295 acceptées puis 35 refus sur 330 ; `equipe.dev` toujours 200 |
| D-6 : chantiers de démonstration et chantier créé par l'API | pas de ligne de compteur (créée au premier numéro) | `CH-ECO-UV18`, `CH-LOG-OL40` (rattrapés par la migration `BackfillSiteCounters`) et un chantier créé par `POST /sites` : **5 compteurs chacun** (`DEM`, `LIV`, `PB`, `SIT`, `T` à 0) |

### Statut
| # | Statut |
|---|---|
| D-6 numérotation : premier numéro bloqué 30 s si l'appelant a écrit la ligne du chantier | **Clos** : compteurs créés avec le chantier, rattrapage des chantiers existants, repli sûr par verrou applicatif (testé sous concurrence et annulations) |
| D-7 limiteur : 401 et 403 non comptés | **Clos** : limiteur placé avant l'autorisation, seau par utilisateur pour un jeton ou un cookie valide, seau par adresse pour les autres |
| D-1 à D-5, S-1, R1-01 à R1-08, R1-14, R1-15 | Clos (passe 2), non régressés |

### Reste ouvert (hors lot, sans défaut bloquant)
- S-2 (limite hors ligne mesurée par l'horloge du téléphone), S-3 (langue choisie avant la connexion écrasée par celle du compte : décision métier), S-4 (limite de connexion) ; D-4 : décision CI de devops-ci ; mineurs de la revue R1-09 à R1-13 et R1-16 à R1-21, non traités dans ce lot.
- Jamais exécutable ici : scénario hors ligne sur émulateur, mesures de durée et lisibilité au soleil sur appareil, manifeste Android fusionné d'un APK, proxy réel en production, pipeline Azure.

## Seconde passe (2026-11-25) : vérification des corrections

**Verdict : plus aucun défaut Bloquant ni Majeur.** D-1 à D-5, S-1 et les Majeurs R1-01 à R1-04 sont corrigés et vérifiés (avant : reproduction de la passe 1 ou mesure de la revue ; après : relancé). La passe a trouvé **deux défauts Mineurs nouveaux**, dont un introduit par une correction. Le critère du plan (« QA sans Bloquant ni Majeur ») est satisfait ; les trois tests rouges ci-dessous restent actifs, ne pas les désactiver.

### Exécution
| Partie | Commande | Résultat réel |
|---|---|---|
| Backend | `dotnet test Chantier.sln` (SQL Server du conteneur) | 153 unitaires verts ; intégration 385 : **382 réussis, 3 échecs voulus** (D-6, D-7 ×2). Une série sans mes 3 nouveaux tests : 379 sur 379 |
| Backend, numérotation | `Rollbacks_mixed_with_commits_in_parallel_leave_no_gap` en série complète, puis isolé 12 fois ; `NumberingStabilityTests` (15 tours de 30 appels, compteur neuf) 8 fois | Série complète verte ; 12 sur 12 ; **0 erreur SQL**, tour le plus long 472 ms (avant : 100 à 113 interblocages, jusqu'à 15 s) ; compteur existant : 79 ms au maximum |
| Backend, forme | `dotnet format --verify-no-changes` | OK |
| Web | `npx nx run-many -t lint test build typecheck --skip-nx-cache` (sans `npm ci`) | 8 projets OK, **280 tests réussis** (267 avant), aucun avertissement |
| Web, e2e | Playwright Chromium contre l'API de démonstration (base temporaire, supprimée ensuite) | **8 réussis** (7 + nouveau scénario CA-008.6) |
| Mobile | `flutter analyze` ; `dart format --set-exit-if-changed lib test` ; `flutter test` | aucun problème ; OK ; **625 réussis, 8 ignorés (captures), 0 échec** (les 3 tests rouges D-2 et D-3 sont devenus verts) |
| Mesures réelles sur l'API de démonstration (script Node, base temporaire) | tableau suivant | R1-01, R1-02, R1-05, R1-07, R1-08, R1-14 corrigés |
| Journaux de l'API pendant ces essais (84 lignes) | recherche des noms, téléphones, identifiants `*.dev`, jetons, mot de passe | 0 occurrence |

### Statut de chaque défaut
| # | Avant | Après (vérification) | Statut |
|---|---|---|---|
| D-1 interblocage de la numérotation | 100 à 113 erreurs SQL 1205 sur 15 tours, jusqu'à 15 s ; test existant rouge en série complète | 0 erreur sur 8 passages de 15 tours, 472 ms au maximum ; test existant 12/12 et vert en série complète. Revue du correctif : la ligne du compteur est créée sur une **autre connexion** (`SiteNumbering.EnsureCounterAsync`), d'où D-6 | **Corrigé** (D-6 en conséquence) |
| D-2 « Envois en attente » à 320 dp, police ×2 | débordement de 50 px (fr), 22 px (ar) | `small_screen_large_font_test` : 12 sur 12 verts (6 écrans, FR et AR) | **Corrigé** |
| D-3 noms latins en arabe | « .Mourad B », « .Farid L » | `rtl_names_test` vert ; capture `mobile-fiche-chantier-ar.png` régénérée : « Mourad B. », « Toufik G. », « Farid L. » | **Corrigé** |
| D-4 Playwright périmé, absent de la CI | smoke en échec, aucun parcours réel | 8 scénarios verts ; la décision sur l'étape CI reste à devops-ci (`azure-pipelines.yml` non relu : un autre agent y écrit) | **Corrigé côté tests** ; CI : question ouverte |
| D-5 CA-008.6 | champs vides | `siteFormDefaults.spec` (6 cas) vert ; **réel** : `admin.dev` ouvre « Nouveau chantier » : wilaya « Blida » et maître d'ouvrage préremplis | **Corrigé** |
| S-1 fiche web à 5 000 zones | 105 246 nœuds DOM, 8,7 s | **286 nœuds, 1,5 s** (blocs repliés, affichage progressif) ; `zonesLarge.spec` : repli, « afficher plus », tri, arabe | **Corrigé** |
| R1-01 limiteur global partagé par adresse | `chef.dev` à 300 requêtes : `equipe.dev` et `/health/live` reçoivent 429 | `chef.dev` : 300 acceptées puis 30 refus sur 330 ; **`equipe.dev` : 200, `/health/live` : 200** ; `UseForwardedHeaders` testé (proxy déclaré, démarrage refusé sans proxy de confiance, en-tête ignoré hors proxy) | **Corrigé** (D-7 en conséquence) |
| R1-02 cookie rejoué après déconnexion | `GET /auth/me` : 200 | connexion web : `me` 200, `logout` 204, **rejeu du cookie : 401** ; `WebSessionTests` (changement de mot de passe, plafond absolu, déconnexion web sans effet sur le mobile) verts | **Corrigé** |
| R1-03 montant mobile conservé après retrait de permission | montant resté en base à version égale | `permission_change_test` : effacement immédiat même hors ligne, rechargement complet avec écrasement des versions égales, drapeau persistant jusqu'à la dernière page, permission conservée : le montant revient, file d'envoi intacte. Relu : `clearRestrictedFields`, `fullReload` | **Corrigé** |
| R1-04 sauvegarde Android | manifeste sans `allowBackup` | `allowBackup="false"`, `dataExtractionRules` et `fullBackupContent` excluent base, préférences, fichiers ; `test/android/manifest_test.dart` vert. APK non construit (licences) : manifeste fusionné non vérifié | **Corrigé** (lecture et test de manifeste) |
| R1-05 refresh perdu = chaîne révoquée | 401 au rejeu, jeton neuf révoqué | rejeu immédiat : **200**, successeur utilisable : 200 ; après la fenêtre de grâce (35 s) : rejeu **401 `REFRESH_INVALIDE`**, successeurs révoqués (détection de vol conservée) | **Corrigé** |
| R1-06 clés de protection en clair | avertissement au démarrage | `DataProtectionTests` : hors développement, démarrage refusé sans certificat ; avec certificat, clés écrites chiffrées et cookies valides ; mauvais mot de passe refusé sans l'écho. En développement, l'avertissement reste (voulu) | **Corrigé** |
| R1-07 `{"operations":[null]}` | 500 et pile | **400 `VALIDATION`**, aucune `NullReferenceException` au journal | **Corrigé** |
| R1-08 corps de 8 Mo | accepté, lu en entier | **413 en 3 ms** (limite de 64 Ko, push à 1 Mo) | **Corrigé** |
| R1-14 pas de compression | `Content-Encoding` absent | pull : `gzip` ; `HardeningTests` (gzip, brotli, sans en-tête : brut, erreurs valides) | **Corrigé** |
| R1-15 fiche mobile non paresseuse | `ListView` de tous les enfants | `ListView.builder` ; `site_detail_screen_test` « 300 zones : seules les lignes visibles sont construites » vert | **Corrigé** |

### Défauts nouveaux de la seconde passe
| # | Sévérité | Où | Reproduction | Attendu / obtenu | Agent |
|---|---|---|---|---|---|
| D-6 | Mineur (latent, aucun consommateur aujourd'hui) | `chantier-backend/Core/Chantier.Infrastructure/Services/Sites/SiteNumbering.cs`, `EnsureCounterAsync` (nouvelle connexion pour créer la ligne du compteur) | `dotnet test Tests/Chantier.IntegrationTests --filter "FullyQualifiedName~A_first_number_can_be_taken"` : le test `…while_the_caller_has_updated_the_site_row` est rouge | Si la transaction de l'appelant a **écrit** la ligne du chantier (`UPDATE Sites …`, par exemple un « toucher » de synchronisation) avant de demander son premier numéro, la clé étrangère de l'autre connexion attend la fin de cette transaction : l'appel reste bloqué **30 s** puis lève `SqlException` (délai). Lecture simple, lecture `UPDLOCK` et insertion d'une zone du même chantier : OK (5 à 123 ms). Piste : créer les cinq compteurs à la création du chantier (et par migration pour les chantiers existants), ce qui supprime aussi la voie « à froid ». | backend-dotnet |
| D-7 | Mineur | `chantier-backend/WebApi/Chantier.WebApi/Extensions/WebApplicationExtensions.cs` lignes 45 à 50 : `UseRateLimiter()` placé **après** `UseAuthorization()` (correctif de R1-01) | `dotnet test … --filter "FullyQualifiedName~RateLimitRegressionTests"` : 2 tests rouges. Réel : 400 requêtes sans jeton, puis 400 avec un jeton invalide, sur `GET /api/v1/sites` : **800 réponses 401, aucun 429** | Les requêtes refusées par l'authentification ou l'autorisation (401, 403) n'atteignent plus le limiteur : un anonyme peut marteler les routes protégées sans limite (avant le correctif, le seau par adresse IP les comptait). Impact modéré : réponses peu coûteuses, aucun secret exposé ; reste le coût du contrôle de signature du jeton. Piste : garder un limiteur par adresse **avant** l'authentification (plafond large) en plus du seau par utilisateur après. | backend-dotnet |

### Tests ajoutés pendant la seconde passe
- `chantier-backend/Tests/Chantier.IntegrationTests/Qa/NumberingStabilityTests.cs` : 4 cas « premier numéro avec verrou de l'appelant sur le chantier » (D-6).
- `chantier-backend/Tests/Chantier.IntegrationTests/Qa/RateLimitRegressionTests.cs` : 2 cas, rouges (D-7).
- `chantier-frontend/apps/chantier-back-office-e2e/src/sites.spec.ts` : scénario CA-008.6 réel.
- Tests de la passe 1 conservés ; `bigList.spec.tsx` valide désormais S-1 (286 nœuds).
- Tests des développeurs relus et cohérents avec les défauts : `Security/*`, `permission_change_test`, `zonesLarge.spec`, `siteFormDefaults.spec`, `manifest_test`.

### Risques résiduels de la seconde passe
- Non vérifiables sans appareil ni AVD : le manifeste Android **fusionné** d'un APK (R1-04), la fluidité de la fiche paresseuse sur un téléphone modeste, le scénario hors ligne sur émulateur.
- `UseForwardedHeaders` : testé en intégration avec des adresses simulées ; le proxy réel (NAT, reverse proxy de production) n'a pas été essayé.
- Mineurs de la revue non corrigés par ce lot et donc non revérifiés : R1-09 à R1-13, R1-16 à R1-21 ; S-2, S-3, S-4 de la passe 1 restent ouverts.

---

# Passe 1 (2026-11-24) : état initial

## Exécution
| Partie | Commande | Résultat réel |
|---|---|---|
| Backend, unitaires | `dotnet test Chantier.sln` (SQL Server du conteneur `chantier-dev-db`, base temporaire par exécution) | 153 réussis, 0 échec |
| Backend, intégration, avant mes ajouts | idem | 311 réussis, 0 échec (le test de numérotation a passé) |
| Backend, intégration, après mes ajouts | idem | 344 tests : 342 réussis, **2 échecs** (D-1) : `Rollbacks_mixed_with_commits_in_parallel_leave_no_gap` (existant, interblocage SQL 1205) et `Rollbacks_mixed_with_commits_stay_gapless_and_fast_over_repeated_rounds_cold_counter` (mon test de reproduction) |
| Backend, forme | `dotnet format Chantier.sln --verify-no-changes` | OK (après correction de mes fichiers) |
| Web | `npx nx run-many -t lint test build typecheck --skip-nx-cache` | 8 projets OK, **267 tests réussis** (265 avant mes ajouts), aucun avertissement ESLint ; build Vite OK |
| Web, client d'API | `npm run generate:api` puis empreinte du fichier généré | identique (`a71a6992…`) : pas de dérive |
| Web, bout en bout | Playwright Chromium contre l'API de développement avec `Seed:Demo` (base temporaire `chantier_qa_e2e`, supprimée ensuite) | 7 réussis (le smoke test d'origine échouait : D-4) |
| Mobile | `flutter analyze` | aucun problème |
| Mobile | `flutter test` | 578 existants verts ; avec mes ajouts : **595 réussis, 8 ignorés** (captures, sans `QA_CAPTURES`), **3 échecs voulus** qui prouvent D-2 et D-3 |
| Mobile, client d'API | `dart run swagger_parser` + `build_runner` + `dart format lib` puis empreinte de `lib/core/api/generated` | identique : pas de dérive |
| Mobile, forme | `dart format --set-exit-if-changed lib test` | OK |
| CI | `scripts/ci/check-banned-packages.ps1` | « Aucun paquet interdit (19 manifestes) » |

Non exécuté : `flutter build apk` et scénario sur émulateur (aucun AVD sur le poste, licences Android non acceptées : action utilisateur) ; pipeline Azure (aucun serveur distant) ; WebKit et Firefox pour Playwright (Chromium seul lancé).

## Défauts
| # | Sévérité | Où | Reproduction | Attendu / obtenu | Agent |
|---|---|---|---|---|---|
| D-1 | **Majeur** | `chantier-backend/Core/Chantier.Infrastructure/Services/Sites/SiteNumbering.cs` lignes 28 à 34 (`INSERT … WHERE NOT EXISTS (SELECT … WITH (UPDLOCK, HOLDLOCK))` dans la transaction de l'appelant) | `dotnet test Tests/Chantier.IntegrationTests --filter "FullyQualifiedName~Rollbacks_mixed_with_commits_stay_gapless_and_fast_over_repeated_rounds"` (15 tours de 30 appels parallèles, un sur trois annulé, compteur du chantier **inexistant** au départ). Trois exécutions : 100, 110 et 113 erreurs SQL 1205 (interblocage), tours de 4 à 15 s. Le test existant `Rollbacks_mixed_with_commits_in_parallel_leave_no_gap` a passé 12 fois sur 12 isolé (0,6 s) mais **a échoué dans la série complète** avec la même erreur 1205. Graphe d'interblocage (trace 1222) : tous les participants sont dans l'`INSERT … NOT EXISTS`, en verrous de plage `RangeS-U` contre un `RangeX-X`. | Attendu : numéros sans trou et sans erreur (CA-015.3, CT-22). Obtenu : interblocages et attentes jusqu'au délai de 15 s. Avec le compteur **déjà créé** (variante `_warm_counter`) : 0 erreur, 144 ms au maximum ; 60 appels sans annulation : 0 erreur. Le défaut est donc la **création de la ligne** du compteur sous verrou de plage quand une transaction qui l'a insérée s'annule (le test est intermittent car il dépend de l'état de l'index : lignes fantômes des annulations précédentes). Sans consommateur aujourd'hui, mais la première demande d'un chantier (lot suivant) sera exactement ce cas ; l'erreur 1205 n'est pas rejouée par le service. **Piste validée par prototype** (test jetable, supprimé) : créer la ligne **hors** de la transaction de l'entité (instruction seule, auto-validée), puis incrémenter dans la transaction : 15 tours, 0 erreur, 245 ms au maximum. Autre piste : créer les cinq compteurs à la création du chantier. | backend-dotnet |
| D-2 | Mineur | `chantier-mobile/lib/features/sync_queue/presentation/pending_operations_screen.dart` lignes 200 à 209 (`Row` icône + statut sans `Flexible`) | `flutter test test/qa/small_screen_large_font_test.dart` : écran « Envois en attente », téléphone 320 dp, police système ×2, saisie « En attente d'envoi » | Attendu : texte qui passe à la ligne. Obtenu : « RenderFlex overflowed by 50 pixels » en français (22 px en arabe) ; sans souci à ×1,3 et à 360 dp avec ×1,3. Les autres écrans (connexion, Mes chantiers, fiche, ajout de zone, barre de synchro) tiennent à 320 dp et ×2. | mobile-flutter |
| D-3 | Mineur | Fiche chantier mobile (membres, « Créé par »), `chantier-mobile/lib/features/sites/presentation/site_detail_screen.dart` | `flutter test test/qa/rtl_names_test.dart` ; capture `docs/qa/captures/mobile-fiche-chantier-ar.png` | Attendu : « Mourad B. » isolé de gauche à droite (comme sur le web). Obtenu : en arabe, le point final passe à gauche (« .Mourad B », « .Farid L ») car le nom n'est pas entouré de `Formatters.isolateLtr`. Cosmétique, mais ce sont les noms que les gens lisent. | mobile-flutter |
| D-4 | Mineur | `chantier-frontend/apps/chantier-back-office-e2e/src/smoke.spec.ts` (corrigé par la QA) ; `azure-pipelines.yml` | `npx playwright test --project=chromium` avant correction : le test attendait le titre « Back-office Chantier » à `/`, remplacé par la connexion depuis W4 | Attendu : le parcours Playwright de l'ADR 0010 existe et la CI le lance. Obtenu : test périmé et en échec, aucun scénario « connexion puis Mes chantiers », et **aucune étape Playwright dans le pipeline**. J'ai corrigé le smoke test et ajouté `sites.spec.ts` (6 scénarios). Reste à faire par devops-ci : décider d'une étape CI (API avec `Seed:Demo`, build web, `QA_DEMO_PASSWORD` en variable secrète) ou de le garder en vérification locale. | devops-ci |
| D-5 | Mineur | Formulaire chantier web, `chantier-frontend/apps/chantier-back-office/src/features/sites/types/siteForm.zod.ts` ligne 44 (`wilaya: ""`) | Ouvrir « Créer un chantier » après en avoir créé un en Blida | CA-008.6 : « par défaut, la wilaya du dernier chantier créé » (et maître d'ouvrage « dernier utilisé » dans le tableau des champs). Obtenu : champs vides à chaque création. | frontend-react |

### Suggestions et questions
| # | Sujet | Constat | Pour qui |
|---|---|---|---|
| S-1 | Fiche web avec 5 000 zones | Rendu complet : 105 246 nœuds DOM, 8,7 s dans jsdom (le serveur répond bien : 25 pages en 1,1 s, pull de 5 002 lignes en 0,9 s). Utilisable mais lourd sur un poste modeste. Repli des blocs ou virtualisation. Test : `apps/chantier-back-office/src/qa/bigList.spec.tsx` (journalise la taille). | frontend-react / architecte |
| S-2 | Horloge du téléphone fausse | La limite de 14 jours hors ligne est mesurée avec l'horloge du téléphone (`auth_repository_impl.dart` lignes 66 à 70) : une horloge reculée prolonge la session hors ligne sans limite, une horloge avancée la coupe trop tôt. Le serveur n'est jamais consulté hors ligne. Côté serveur, une heure de saisie fausse (1970, 9999, fuseau étrange) est bien conservée à part et n'altère ni l'audit ni le pull (testé). | architecte (Q-07 : code de verrouillage du téléphone) |
| S-3 | Langue choisie avant la connexion | Sur web **et** mobile, la langue choisie sur l'écran de connexion est remplacée par la langue du compte dès l'ouverture de session (voulu, commenté dans `app.dart`). CA-001.8 dit « le choix s'applique immédiatement », ce qui reste vrai sur l'écran de connexion. À trancher. | expert-metier-chantier |
| S-4 | Limite de débit sur `login` | Dix connexions par cinq minutes pour un couple adresse + identifiant, **réussites comprises** : mes scripts ont reçu 429 « Trop de requêtes ». Comportement conforme à l'ADR 0005 ; à garder en tête pour un téléphone partagé ou une démonstration, et pour les scripts de test (une seule connexion API par exécution). | revue-securite-perf |

## Couverture des critères techniques (CT-1 à CT-24)
Abréviations : **BE** = `chantier-backend/Tests/Chantier.IntegrationTests` (ou `UnitTests`), **WEB** = specs Vitest, **E2E** = Playwright, **MOB** = `chantier-mobile/test`.

| CT | Test(s) | Résultat |
|---|---|---|
| CT-1 | BE `LoginTests` (cookie HttpOnly/SameSite, jetons mobile, même 401 pour identifiant faux / mot de passe faux / compte désactivé, 5 échecs puis 429 même avec le bon mot de passe et sur identifiant inexistant, levée du blocage, casse, limite par adresse + identifiant) ; WEB `auth.spec` (double appui : une seule demande, 429) ; MOB `login_screen_test`, `auth_bloc_test` | OK |
| CT-2 | BE `RefreshAndPasswordTests` (rotation, réutilisation révoque la chaîne, deux refresh parallèles : un seul réussit, 14 jours, changement de mot de passe révoque, mot de passe provisoire bloque tout sauf le changement) ; MOB `token_refresher_test`, `auth_repository_test` (session de plus de 14 jours) | OK |
| CT-3 | BE `SiteIsolationTests` (liste par rôle, `q`, tous les sous-chemins, 404 **identique** inexistant / non affecté, corps invalide sans fuite, Admin voit tout, Direction non), `SyncPullTests`, `DemoDataTests.CA_018_4`, **nouveau** `QaEdgeCaseTests` (push sur chantier d'un autre : `INTROUVABLE` identique, pull vide) ; WEB `sitesScreens.spec` ; E2E `sites.spec` (chef : 1 chantier ; conducteur : 2 ; lien direct OL40 identique à un identifiant inexistant au traceId près) | OK |
| CT-4 | BE `SiteIsolationTests` (retrait coupe l'accès, ajout donne l'accès), `SyncPullTests` (retrait : `deleted` site et membre, ajout d'un chantier ancien reçu), `SyncConcurrencyTests` ; MOB `sync_engine_test` | OK |
| CT-5 | BE `SkeletonTests`, `GlobalExceptionMiddlewareTests`, `ErrorCatalogTests`, `ModelStateProblemFactoryTests` ; WEB `api.msw.spec` ; MOB `api_exception_test`, `error_messages_test` | OK |
| CT-6 | BE `AuditAndFilterTests`, `SitesCrudTests` (audit depuis le jeton, archivage tracé, pas de route de suppression), `ZonesTests` (« saisi le » à part, champs d'audit forgés ignorés), **nouveau** horloge fausse (5 valeurs) | OK |
| CT-7 | BE `SitesCrudTests` (409 avec `current`, concurrence), `ZonesTests`, **nouveau** 6 `PUT` de zone sur la même version : 1 réussit, 5 reçoivent 409 ; WEB `sitesForms.spec` (rechargement proposé) | OK |
| CT-8 | BE `SyncOpenTransactionTests` (ligne de version basse validée en retard jamais perdue), `SyncPullTests`, `RowVersionTests` ; MOB `sync_engine_test` (pages, reprise, `CURSEUR_INVALIDE`, ligne illisible : rien d'écrit) ; **nouveau** 5 000 zones : 5 002 lignes, sans doublon, 0,9 s | OK |
| CT-9 | BE `SyncPushTests` (résultats dans l'ordre, `duplicate`, entité inconnue, lot de 100 accepté et 101 : 413), **nouveau** 8 envois parallèles du même `clientId` : 1 `applied`, 7 `duplicate`, 1 zone | OK |
| CT-10 | BE `OpenApiContractTests` ; client web et client mobile régénérés : identiques ; étape contrat du pipeline sans `--optional` | OK (pipeline non exécuté) |
| CT-11 | WEB `i18n/translations.spec`, `formatters.spec`, `auth.spec`, `sitesScreens.spec`, `sitesForms.spec` (FR et AR, RTL, `<Ltr>`, actions absentes selon les droits) ; E2E arabe (`dir=rtl`, captures) | OK |
| CT-12 | MOB `sites_screen_test`, `site_detail_screen_test`, `app_test`, `login_screen_test` (première connexion hors ligne), `session_failure_keeps_local_data_test` (refresh refusé : base et file intactes), `secure_token_store_test` | OK ; « moins de 2 s » non mesuré sur appareil |
| CT-13 | `check-banned-packages.ps1` exécuté ; les trois jobs et le contrat n'ont pu être exécutés qu'**en local** (équivalents lancés ci-dessus) | Partiel : pipeline Azure jamais exécuté |
| CT-14 | BE `NoPersonalDataInLogsTests`, `DemoDataTests`, `OpenApiContractTests.No_phone_number…` ; **nouveau** WEB `qa/journey.spec` (console et stockage du navigateur relus), **nouveau** MOB `qa/no_personal_data_in_logs_test` (connexion refusée, connexion, synchro avec noms, ligne illisible, déconnexion, second compte, session expirée) ; **réel** : journaux de l'API pendant les 7 parcours Playwright, 166 lignes : 0 nom, téléphone, identifiant, mot de passe ou jeton | OK |
| CT-15 | BE `SkeletonTests` (clé absente ou courte, CORS joker, en-têtes, `Server` absent, secret absent des fichiers versionnés) ; vérifié en réel : CORS limité à `http://localhost:3600`, origine étrangère sans en-tête `Access-Control-Allow-Origin` | OK |
| CT-16 | Démarrage scripté : API réelle lancée avec `Seed__Demo=true` sur base vide, web en développement, comptes `*.dev` : tout a démarré | OK ; `docs/exploitation/demarrage-local.md` non testé sur poste propre |
| CT-17 | BE `ZonesTests`, `UniquenessTests`, `ZoneTests` (unit.), **nouveau** casse et espaces (« BLOC 01 », « Bloc 01 ») = même position (422) ; WEB `zoneForm.zod.spec`, `zoneGrouping.spec` ; MOB `zone_logic_test`, `zone_picker_test`, `add_zone_screen_test` | OK |
| CT-18 | BE `SitesCrudTests` (quatre cas de référence, données manquantes `null`, `../03/2026` : `DATE_INVALIDE`, délai ≤ 0 : `QUANTITE_INVALIDE`), `SiteTests` ; **nouveau** délai maximal avec ODS 2100-12-31 : fin 2200-12-07, délais énormes (`int.MaxValue`) refusés en 400 ; E2E fin contractuelle 24/08/2027 | OK |
| CT-19 | BE `DeactivatedAccountTests` (jeton encore valide refusé, cookie refusé, refresh `ACCES_RETIRE`) ; MOB `session_failure…`, `auth_bloc_test` (accès retiré) | OK |
| CT-20 | BE `ContractAmountTests`, `SyncPullTests` (montant absent de `data`) ; WEB `sitesScreens.spec`, `sitesForms.spec` ; MOB `site_detail_screen_test` ; E2E : montant visible pour `conducteur.dev`, **absent** pour `equipe.dev` | OK |
| CT-21 | MOB `integration/offline_to_sync_test`, `zones_repository_test`, `outbox_dao_test`, `sync_engine_test` (écriture locale et envoi dans une transaction, `merged`, `rejected`) ; BE `SyncPushTests` (fusion, archivé, non affecté), **nouveau** 8 envois parallèles de la même position par deux comptes : 1 zone | OK |
| CT-22 | BE `SiteNumberingTests` (001, indépendance entre chantiers, 60 appels parallèles, annulation, `DEM-1000`) | **KO intermittent** : D-1 |
| CT-23 | MOB `auth_repository_test` (téléphone partagé A puis B), `app_database_test` (`purgeSyncedData`), `outbox_dao_test`, `logout_screen_test` | OK |
| CT-24 | MOB `sync_status_bar_test` (5 états, icône et texte), `sync_status_cubit_test`, `sync_engine_test` (200 envois en 4 lots de 50, dans l'ordre), `sync_scheduler_test` (5 min), `pending_operations_screen_test` | OK, sauf D-2 |

## Couverture des critères d'acceptation (CA, `docs/metier/socle.md`)
« Manuel » : à faire sur appareil ; « Hors socle » : écran du lot Administration (plan, écart signalé par l'architecte).

| Histoire | CA couverts par test | Trous |
|---|---|---|
| 001 Se connecter | .1 BE `LoginTests`, E2E ; .2 MOB `login_screen_test` (3 gestes) ; .3 `LoginTests`, WEB `auth.spec` ; .4 `LoginTests` (429, levée) ; .5 MOB `login_screen_test`, `auth_repository_test` ; .6 WEB `auth.spec`, MOB `login_screen_test` ; .7 BE, WEB `auth.spec` ; .8 WEB `auth.spec`, E2E smoke ; .9 WEB, MOB (56 dp) ; .10 WEB `auth.spec` | .1 « moins de 10 s » non mesuré ; .4 « noté dans le journal des connexions » = hors socle (016.5) |
| 002 Hors ligne et déconnexion | .1 MOB `auth_repository_test`, `app_test` ; .2 MOB `auth_repository_test`, `session_failure…` ; .3 MOB `logout_screen_test` ; .4 MOB `auth_repository_test`, `app_database_test` ; .5 BE `DeactivatedAccountTests`, MOB `auth_bloc_test` ; .6 MOB `sync_engine_test`, `pending_operations_screen_test` | .1 « moins de 3 s » non mesuré |
| 003 Droits | .1 WEB `auth.spec`, `sitesScreens.spec` ; .2 BE `SyncPushTests`, `ZonesTests`, **nouveau** `QaEdgeCaseTests` (ChefEquipe, Achats, Direction : 403 et rien d'écrit) ; .3 BE `SyncPushTests` (INTERDIT) ; .4 WEB `sitesScreens.spec` ; .5 BE `ContractAmountTests`, MOB `sites_dao_test` ; .6 BE `ContractAmountTests` (cache) | .6 historique de l'ancien rôle : hors socle (016.3) |
| 004 Comptes | — | **Hors socle** (lot Administration). Seuls couverts : désactivation (`DeactivatedAccountTests`) et amorçage Admin (`SeedAndMigrationTests`) |
| 005 Affecter | .3, .4, .5, .6, .7, .9 BE `MembersAndReferenceTests`, `SiteIsolationTests`, `SyncPullTests` ; .5 MOB `sync_engine_test` | .1, .2, .8 : écrans web hors socle (l'API existe) |
| 006 Mes chantiers | .1 à .3, .9 BE `SiteIsolationTests`, E2E ; .4, .5, .6, .8 MOB `sites_screen_test`, `sites_cubit_test` (50 chantiers), WEB (pagination, archivés) ; .7 MOB `sites_screen_test` | .5 « moins de 2 s » non mesuré |
| 007 Fiche | .1 à .8 WEB `sitesScreens.spec`, MOB `site_detail_screen_test`, BE `SitesCrudTests`, E2E (24/08/2027, montant selon le rôle) | .5 sans carte : coordonnées écrites testées, carte absente du socle |
| 008 Chantier | .1 à .5, .7 à .9 BE `SitesCrudTests`, WEB `sitesForms.spec`, `siteForm.zod.spec` ; .10 N/A | **.6 : défaut D-5** (liste wilaya puis commune testée, valeur par défaut non implémentée) |
| 009 Sélecteur de zone | .1 à .6 MOB `zone_picker_test` (3 gestes, 300 zones, « cl 02 »), `zones_dao_test`, BE `ZonesTests` | .7 « Non précisée » : sans objet au socle |
| 010 Chantier courant | .1 à .5 MOB `current_site_test`, **nouveau** `qa/current_site_header_test` (en-tête : code et nom, arabe, 2 gestes, un seul chantier) | .1 « visible en haut de **chaque** écran » : la coquille `AuthenticatedShell` n'a toujours pas de test d'ensemble (l'en-tête et la barre sont testés séparément) ; **.6 non testé** (formulaires déjà ouverts : aucun formulaire de saisie au socle) |
| 011 Zone | .1 à .11 MOB `add_zone_screen_test`, `zones_repository_test`, BE `ZonesTests`, `SyncPushTests`, WEB `sitesForms.spec` | .1 « moins de 30 s » : le nombre de gestes est testé, pas le temps (Manuel) |
| 012 Hors ligne | .1, .3, .4 MOB `integration/offline_to_sync_test`, `sync_engine_test` ; .2 `sites_screen_test` (préparation) ; .5 `sync_status_bar_test` ; .6 BE `SyncPullTests`, MOB `sync_engine_test` ; .7 MOB `sites_dao_test` ; .8 revue d'écrans | Scénario émulateur (Manuel) non exécuté |
| 013 Indicateur | .1 à .10 MOB `sync_status_bar_test`, `sync_status_cubit_test`, `pending_operations_screen_test`, `sync_engine_test`, `integration/offline_to_sync_test` | D-2 (police ×2) |
| 014 FR et AR | .1 MOB `app_test` ; .2 BE ; .3, .4 WEB et MOB (RTL, LTR des codes) ; .5 `translations.spec`, `arb_parity_test`, `error_messages_test` ; .6, .7 WEB `formatters.spec`, MOB `formatters_test` ; .8 MOB `app_theme_test` (contraste) ; .9 WEB et MOB (catalogue d'erreurs) | .8 lisibilité au soleil : Manuel ; **D-3** (noms latins en arabe) ; captures FR/AR faites (`docs/qa/captures/`) |
| 015 Numérotation | .1, .4, .5, .6, .7 BE `SiteNumberingTests` ; .3 | **.3 KO : D-1** ; .2 affichage « DEM · numéro en attente » : aucune entité numérotée au socle (N/A) |
| 016 Qui a fait quoi | .1, .2, .4, .6, .7 BE `AuditAndFilterTests`, `SitesCrudTests`, `ZonesTests`, WEB et MOB (« Créé par ») | .3, .5 : hors socle ; .2 « les deux visibles dans l'historique » : l'historique est hors socle |
| 017 Aucune donnée personnelle | .1 BE, WEB, MOB (nouveaux) et journaux réels de l'API ; .2 BE `SkeletonTests`, `ErrorCatalogTests` ; .4 BE `LoginTests`, `OpenApiContractTests` ; .5 relecture des jeux de test ; .6 BE `DeactivatedAccountTests` | .3 rapports de plantage et statistiques : aucun outil de ce type au socle (N/A) |
| 018 Démonstration | .1 à .4 BE `DemoDataTests` (7 comptes, 26 + 3 zones, deux chargements, inactif hors Development, cas a à f) ; E2E (a, b, c, d, e, f sur l'API réelle) | — |

## Règles métier obligatoires
| Règle | Test | Résultat |
|---|---|---|
| Unité obligatoire, refus d'agréger m² et ml, quantités, métré, ciment, avancement | Aucune quantité ni calcul au socle (histoire 015.9 et « Règles de calcul ») : la cote est toujours en mètres, non modifiable (MOB `add_zone_screen_test`) | N/A |
| Arrondi `AwayFromZero` | BE `ContractAmountTests.The_amount_is_stored_with_two_decimals_rounded_away_from_zero`, `ZoneTests` (cote), **nouveau** plus grand montant accepté (999 999 999 999 999,99) conservé sans perte ; 1e16, 1e40, décimal maximal .NET, négatif : 400 | OK |
| Dates incomplètes refusées | BE `SitesCrudTests.Incomplete_ods_date_is_400_DATE_INVALIDE` (`../03/2026` …), WEB `sitesForms.spec` | OK |
| Transitions de statut, motif obligatoire | Aucune transition au socle (archivage seulement, sans motif : H-13) | N/A |
| Numérotation unique par chantier, deux créations simultanées | BE `SiteNumberingTests` | OK sauf compteur neuf avec annulations : **D-1** |
| Idempotence du `clientId` | BE `ZonesTests`, `SyncPushTests`, **nouveau** 8 envois parallèles ; MOB `integration/offline_to_sync_test` | OK |
| ChefEquipe ne valide pas / ne crée pas ; chantier non affecté : 404 ; téléphones masqués | BE `SyncPushTests`, `SiteIsolationTests`, `MembersAndReferenceTests` (jamais de téléphone ni d'identifiant), `OpenApiContractTests`, **nouveau** rôles en lecture seule | OK (il n'y a pas de demande à valider au socle) |
| Concurrence : deux modifications sur la même version : 1 succès, 1 conflit 409 | BE `SitesCrudTests`, **nouveau** `QaEdgeCaseTests` (zone, 6 parallèles : 1 et 5) | OK |

## Cas limites explorés
| Cas | Résultat |
|---|---|
| Mode avion pendant l'envoi, application tuée pendant la synchronisation, reprise après des jours sans réseau, double appui | Couverts et verts côté mobile (`offline_to_sync_test`, `sync_engine_test`, `sync_status_cubit_test`). Les photos n'existent pas au socle. Scénario réel sur émulateur : non exécuté. |
| Horloge du téléphone fausse | Serveur : OK (1970, 9999, 0001, 2099, décalage horaire : conservée à part, audit au temps du serveur). Mobile : S-2 |
| Liste de 5 000 lignes | Serveur OK (liste 1,1 s, pull 0,9 s). Web : S-1 |
| Texte arabe long (200 lettres sur chantier, 50 sur bloc, 100 sur libellé), caractères spéciaux (HTML, apostrophes, `DROP TABLE`, emoji, `%`, `_`), NUL, substitut isolé, valeurs nulles | OK : conservés tels quels, 400 au-delà de la limite (REST **et** envoi hors ligne), jamais de 500 |
| Quantité 0 ou négative, très grand montant | Délai 0 ou négatif : 422 `QUANTITE_INVALIDE` ; montants absurdes : 400 ; délai énorme avec ODS 2100 : 400 (pas de dépassement de date) |
| Interface : arabe RTL, petit écran, police agrandie | Arabe : OK sauf D-3. Petit écran 320 dp et police ×2 : OK sauf D-2. Captures dans `docs/qa/captures/` (`web-*` et `mobile-*`, FR et AR) |

## Tests ajoutés
- `chantier-backend/Tests/Chantier.IntegrationTests/Qa/QaEdgeCaseTests.cs` : 30 cas limites (montants, délais, arabe, caractères spéciaux, horloge fausse, 5 000 zones, concurrence de zone et d'envoi, rôles en lecture seule, isolation de l'envoi hors ligne).
- `…/Qa/NumberingStabilityTests.cs` : reproduction et diagnostic de D-1 (compteur neuf et compteur existant, 15 tours ; 60 appels). **Le test « compteur neuf » est rouge tant que D-1 n'est pas corrigé ; ne pas le désactiver.**
- `…/Support/SitesTestKit.cs` : `ApiSession.SendRawAsync` (corps JSON brut).
- `chantier-mobile/test/qa/small_screen_large_font_test.dart` (320 dp, police ×2, FR et AR, police Cairo chargée : sans elle `flutter_test` mesure en « Ahem » et invente des débordements) ; **rouge** pour « Envois en attente » (D-2).
- `…/qa/rtl_names_test.dart` : noms isolés en arabe ; **rouge** (D-3).
- `…/qa/no_personal_data_in_logs_test.dart`, `…/qa/current_site_header_test.dart` (6 cas), `…/qa/captures_test.dart` (écrit les PNG si `QA_CAPTURES` est défini).
- `chantier-frontend/apps/chantier-back-office/src/qa/journey.spec.tsx` (console et stockage sans donnée personnelle), `…/qa/bigList.spec.tsx` (5 000 zones).
- `chantier-frontend/apps/chantier-back-office-e2e/src/smoke.spec.ts` (corrigé) et `sites.spec.ts` (6 scénarios réels). Lancement : `QA_DEMO_PASSWORD` (valeur de `Seed:DemoPassword`, jamais écrite dans le dépôt) ; `QA_CAPTURES` facultatif ; une seule connexion API par exécution à cause de la limite de débit (S-4).

## Risques résiduels
- Scénario hors ligne sur émulateur (connexion, synchro, mode avion, liste et fiche, ajout de zone, retour du réseau, retrait d'affectation), mesures de durée (< 2 s, < 3 s, < 10 s, < 30 s) et lisibilité au soleil : **non réalisés** faute d'appareil ou d'AVD. Scénario à exécuter : voir `docs/exploitation/demarrage-local.md` (adb reverse), puis les 7 étapes ci-dessus.
- Pipeline Azure jamais exécuté ; durées réelles inconnues.
- WebKit et Firefox non lancés ; arabe relu par un arabophone (Q-12) non fait.
- Base mobile non chiffrée (ADR 0008 : SQLCipher avant toute donnée personnelle) : acceptable au socle (noms seuls, jamais de téléphone), à ne pas oublier au lot suivant.
- D-1 n'a pas encore de consommateur ; il se manifestera à la première création de demande sur un chantier neuf.
- Stories 004, 005 (écrans), 016.3 et 016.5 : hors socle, donc non vérifiables.

## Suite
Corriger D-1 (backend-dotnet) puis relancer : `dotnet test Tests/Chantier.IntegrationTests --filter "FullyQualifiedName~Numbering"` (les deux tests rouges doivent passer, 20 exécutions de suite sans échec). Puis D-2, D-3 (mobile-flutter) et D-5 (frontend-react). Le plan exige « QA sans défaut Bloquant ni Majeur » : le critère n'est pas atteint tant que D-1 est ouvert.
