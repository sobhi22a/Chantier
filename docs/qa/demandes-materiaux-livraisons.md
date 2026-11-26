# Rapport QA : demandes de matériaux, commandes et livraisons (Q1 à Q3)

**Dates :** 2026-11-25 (passe 1), 2026-11-26 (passe 2) · **Verdict final : Conforme** (passe 1 : À corriger, 1 Majeur et 2 Mineurs, tous corrigés en passe 2) · **Auteur :** qa-tests

Branche `fonctionnalite/demandes-materiaux-livraisons`, code non commité (tranches A et B, correctifs R2 et boucle 1/2 compris). Aucun code de production modifié par la QA.

## Seconde passe (2026-11-26) : verdict final **Conforme**
**Aucun défaut ouvert de sévérité Bloquant, Majeur ni Mineur.** D-1, D-2 et D-3 sont corrigés et vérifiés avant/après ; les correctifs R3-01, R3-02, R3-03, R3-04, R3-05 et S-1 aussi ; R2-02 n'a pas bougé. Aucun test n'a été désactivé ni assoupli : les tests rouges de la passe 1 sont devenus verts tels quels (le fichier mobile `materials_small_screen_large_font_test.dart` est inchangé depuis la passe 1).

### Exécution (passe 2)
| Partie | Commande | Résultat réel |
|---|---|---|
| Backend, suite complète | `dotnet test Chantier.sln` (SQL Server du conteneur, `127.0.0.1`) | **458 unitaires + 826 intégration, 0 échec** (passe 1 : 1 rouge). Les 3 tests QA ajoutés ensuite ont été exécutés avec toute la classe QA : **65 sur 65 verts** |
| Backend, concurrence répétée | 39 tests (commandes, livraisons, photos, validations, numérotation, interblocage, repli sans snapshot, push concurrent) × **5 passages** | **5 sur 5 verts**, 0 erreur 500 |
| Web | `npx nx run-many -t lint test build typecheck --skip-nx-cache` | tout OK : **528 tests verts, 0 rouge** (passe 1 : 522 + 1 rouge) ; lint du projet e2e OK |
| Mobile | `flutter analyze` ; `flutter test` | aucun problème ; **1 128 verts, 8 ignorés (captures), 0 rouge** (passe 1 : 8 rouges) |
| Playwright | build `VITE_BACKEND_API_BASE_URL=http://localhost:8195`, Chromium, API de démonstration (base temporaire ; API redémarrée entre deux exécutions à cause de la limite de connexion) | **21 sur 21, 3 exécutions** (les 20 d'avant plus le nouveau parcours de reprise de photo) |
| API réelle, non-régression | les 31 contrôles de la passe 1, base neuve | **31 sur 31** |
| API réelle, nouveaux essais | D-1, R3-05, R3-01 (détail plus bas) | **12 sur 12** (un premier échec de R3-05 venait de mon script, voir « Incidents d'essai ») |

Total passe 2 : 1 287 tests backend, 528 web, 1 136 mobile (dont 8 ignorés) : **2 943 verts, 0 rouge**, plus 21 parcours e2e. **4 tests ajoutés** (3 backend, 1 Playwright), soit 116 au total pour la QA.

### Vérification avant/après des défauts
| # | Avant (passe 1) | Après (passe 2) | Statut |
|---|---|---|---|
| **D-2** (Majeur) `ERREUR_TEMPORAIRE` sans traduction web | `nx run i18n:test` rouge ; message générique | clé présente en français (« Le serveur est momentanément occupé : rien n'a été enregistré. Réessayez dans un instant. ») et en arabe ; `i18n:test` vert ; **navigateur réel** : un 503 simulé sur l'envoi d'une photo affiche ce message (Playwright `photoRetry.spec.ts`) | **Corrigé** |
| **D-1** (Mineur) 500 sur montant démesuré | livraison de 1 milliard de tonnes (commande en kg au prix maximal) : **500 `ERREUR_INTERNE`** (`ArgumentException`) | **API réelle : 422 `QUANTITE_INVALIDE`** (« La quantité reçue, convertie dans l'unité de la demande, dépasse la limite »), demande intacte (`Ordered`, 0 livraison), livraison normale ensuite = 201 ; commande au prix maximal toujours acceptée (9 999 999 990 000 000,00) ; test QA d'origine vert ; **nouveaux tests** : valeur reçue exactement à la capacité de la colonne acceptée (201), 2 kg de plus refusés en 422 sans rien écrire ; en synchronisation : `rejected QUANTITE_INVALIDE` et le reste du lot passe | **Corrigé** |
| **D-3** (Mineur) en-têtes mobiles qui débordent | 8 tests rouges à 320 × 568 dp (101 à 247 px de débordement) | **18 sur 18 verts** (FR et AR, polices ×1,3 et ×2, 320 × 568 et 360 × 640, boutons de 56 dp, formulaire de réception) ; mesure sur écran réel non faite | **Corrigé** |

### Vérification des autres correctifs de la boucle 1/2
| # | Essai | Résultat |
|---|---|---|
| **R3-01** serveur : un `retry` entraîne ses dépendants | **API réelle**, vrai verrou SQL de 75 s tenu sur le compteur `DEM` : lot [création de demande, sa correction par `requestClientId`, livraison qui la désigne, photo de cette livraison, livraison sans lien] | `retry ERREUR_TEMPORAIRE` × 4 en 30 s, **jamais traités** ; l'opération sans lien : `applied` ; rien d'écrit (34 → 34 demandes) ; verrou levé, renvoi de la chaîne dans le même ordre : **4 × `applied`**, une seule demande créée (DEM-043), correction appliquée ; second renvoi : **4 × `duplicate`** |
| R3-01 client | `deliveries_sync_test` (« retry d'une création : ses dépendants restent en file ») | vert ; non rejoué sur appareil |
| **R3-05** serveur : `resetRequired` | **API réelle** : demande vue ouverte (curseur C), annulée puis vieillie de 90 jours en base, pull depuis C | `resetRequired: true`, la ligne n'est pas envoyée ; téléphone à jour : jamais de signal ; pull complet (`since` vide) : pas de signal et pas de ligne hors fenêtre ; pull suivant : pas de signal. **Test QA** `A_pull_never_carries_the_reset_flag…` vert |
| R3-05 client | `deliveries_sync_test` « signal resetRequired : données confirmées effacées, rechargées, saisies gardées » (3 cas dont un pull en plusieurs pages) | vert ; non rejoué sur appareil |
| **R3-04** reprise d'une photo en attente (web) | **navigateur réel** : premier `PUT` du fichier en 503, bouton « Réessayer l'envoi » | une seule photo côté serveur (même `id`, `Pending` puis `Uploaded`), 2 `PUT`, une seule place du quota de 5 consommée |
| **R3-03** cache vidé à l'expiration de session | `session.spec.tsx` (session expirée ; autre compte dans le même onglet) | vert ; **non rejoué en navigateur réel** |
| **S-1** avertissement `READ_COMMITTED_SNAPSHOT` | **API réelle** : base avec l'option à 0, puis démarrage | avertissement journalisé, démarrage non bloqué ; option active : 0 avertissement. Remarque de libellé : le message dit « appliquer les migrations » alors que, dans ce cas, la migration est déjà appliquée (base recréée hors EF) : formulation à nuancer |
| R2-02 inchangé | `MaterialsQaVolumeTests` (5 000 demandes) | première synchro **311 lignes, 285 Ko bruts, 32 Ko gzip** ; affectation 514 ms ; relecture du chef 307 lignes : identique à la passe 1 |
| R2-01 inchangé | concurrence × 5 ; essai réel | 24 × 201 sur l'API réelle ; sans snapshot : 28 × 201, 20 × 503, **0 × 500**, toutes les commandes annoncées existent |

### Incidents d'essai (aucun défaut du produit)
- **Conteneur de base supprimé en cours de route.** Pendant les passages de concurrence, `chantier-dev-db` a disparu (supprimé, pas simplement arrêté ; cause non établie, ce n'est pas un `-Down` de ma part). Les passages 2 à 5 de cette série ont échoué à la connexion SQL, sans rapport avec les tests. La base a été recréée par `scripts\dev.ps1` (le volume de données était intact) et la série complète rejouée : 5 sur 5 verts. Deux bases de test orphelines ont été supprimées. **À savoir pour l'orchestrateur : quelque chose a supprimé ce conteneur.**
- Mon préparatif SQL de R3-05 échouait en silence (`sqlcmd` exige `-I` pour écrire dans une table à index filtré) : la ligne n'était jamais vieillie, donc faux négatif de mon essai ; corrigé, l'essai passe.

### Reste ouvert (aucun défaut)
- **devops-ci** : contrôle de `is_read_committed_snapshot_on` dans `/health/ready`, purge par lots, `PhotosRoot` hors production (R3-08, R3-09) ; R3-06, R3-07, R3-10 (suggestions de la revue) : ni traités ni testés ici.
- `quantity.value` envoyé en chaîne (`"300"`) accepté en 201 (S-2) : inchangé, non requalifié. Les fichiers vides de la racine (S-3) ont été supprimés.
- **Non vérifiable sans appareil** : inchangé (voir « Risques résiduels »). R3-01 et R3-05 côté mobile reposent sur des tests avec serveur simulé.
- Traductions arabes non relues (Q-MAT-10) ; hypothèses Q-MAT-01 à 09 non validées par l'utilisateur.

# Première passe (2026-11-25) : état initial, conservé pour l'historique


**En clair.** Les 16 histoires sont couvertes par des tests qui passent, et les essais réels sur l'API confirment les règles qui comptent sur le chantier : aucun prix ni téléphone fournisseur pour le terrain, chantier non affecté en 404 identique à un chantier inconnu, doublon de `clientId` sans second numéro, demande validée pendant l'édition hors ligne rendue en conflit sans rien écraser. Les deux Majeurs de la revue R2 sont corrigés et vérifiés avant/après. Trois défauts restent : un message d'erreur manquant sur le web (CI rouge, Majeur), un 500 sur un montant démesuré (Mineur) et un en-tête de liste qui déborde sur les plus petits téléphones (Mineur). Le verdict passe à **Conforme** quand ils sont corrigés.

## Exécution (passe 1)
| Partie | Commande | Résultat réel |
|---|---|---|
| Backend, ligne de base (avant mes ajouts) | `dotnet test Chantier.sln` (SQL Server du conteneur `chantier-dev-db`, `127.0.0.1`) | 458 unitaires + 761 intégration : **tout vert** (10 min 48) |
| Backend, final | idem, avec mes tests | 458 unitaires verts ; intégration, suite complète : **822 tests dont 821 verts et 1 rouge voulu (D-1)** ; le 823e (nombre de requêtes SQL, R2-14) a été ajouté ensuite et exécuté avec les 61 autres tests QA : 61 verts, 1 rouge (D-1) |
| Backend, concurrence répétée | 34 tests (commandes, livraisons, photos, validations, numérotation, interblocage, repli sans snapshot) × **5 passages** | **5 sur 5 verts**, aucune erreur 500 (voir « Test instable » plus bas) |
| Backend, forme | `dotnet format Chantier.sln --verify-no-changes --include <mes fichiers>` | OK |
| Web | `npx nx run-many -t lint test build typecheck --skip-nx-cache` (sans `npm ci`) | lint, build, typecheck **OK** ; **522 tests verts, 1 rouge (D-2)** sur 523 |
| Mobile | `flutter analyze` ; `dart format --set-exit-if-changed` ; `flutter test` | aucun problème ; OK ; **1 097 verts, 8 ignorés (captures), 8 rouges (D-3)** |
| Playwright | build `VITE_BACKEND_API_BASE_URL=http://localhost:8195`, `npx playwright test --project=chromium` contre l'API de démonstration (base temporaire) | **20 sur 20**, répété **4 fois** (14 s chacune), stable |
| API réelle | script d'essais (31 contrôles, comptes `*.dev`), base temporaire, **deux fois** (la seconde sur base neuve : démonstration répétable) | **31 sur 31** les deux fois |
| Journal de l'API pendant les essais | recherche de prix, téléphones, noms et identifiants de connexion, mot de passe | 0 occurrence (journal court : 44 lignes ; la preuve large reste `NoPersonalDataInLogsTests` et les 157 Mo de la revue R2) |

Total : 2 917 tests, **2 899 verts, 10 rouges (3 défauts : 1 + 1 + 8), 8 ignorés** (captures). **112 tests ajoutés par cette QA** (voir plus bas).

Nettoyage : API et base temporaires supprimées, `test-output/` de Playwright supprimé, une base de test orpheline de ma première exécution supprimée, **API de dev relancée** par `scripts\dev.ps1 -Api` (`/health/ready` = 200). La base de dev n'a pas été modifiée par mes essais.

## Vérification des Majeurs de la revue R2
| # | Avant (mesure de la revue) | Après (mesuré ici) | Statut |
|---|---|---|---|
| **R2-01** interblocage des commandes simultanées | 840 `POST /order` à 8 en parallèle : **518 × 500** (62 %), tout un lot de synchronisation perdu sur une `SqlException` | `OrderConcurrencyTests` (8 acheteurs × 6 tours, base neuve) vert **5 passages sur 5** ; **API réelle : 24 commandes par 8 en parallèle = 24 × 201** ; `READ_COMMITTED_SNAPSHOT` actif sur la base de dev et sur la base temporaire (`is_read_committed_snapshot_on = 1`) ; `DeadlockRetryTests` (5) verts | **Corrigé** |
| R2-01, repli | — | Base remise **sans** snapshot (cas d'une base restaurée sans la migration) : 48 commandes à 8 en parallèle = **29 à 30 × 201, 18 à 19 × 503 `ERREUR_TEMPORAIRE`, 0 × 500**, et chaque commande annoncée existe (30 commandées pour 30 × 201) : aucune perte, mais **40 % de refus à rejouer** (S-1) | Corrigé, risque d'exploitation noté |
| **R2-02** volume de synchronisation | première synchro d'un chantier de 2 175 demandes : 6 953 lignes, **10 386 Ko bruts, 1 102 Ko gzip**, 35 pages ; affectation d'une personne : **3 024 ms** et 6 936 lignes retéléchargées par chaque autre téléphone | chantier de **5 000 demandes dont 300 ouvertes** : **311 lignes, 285 Ko bruts, 32 Ko gzip**, 73 à 120 ms (cible < 300 Ko gzip : **tenue avec une marge de 9 fois**) ; démonstration réelle : 101 lignes, 87 Ko / 9 Ko, **0 ligne avec historique** ; affectation sur ce chantier : **543 à 991 ms**, le chef relit **307 lignes** et non 5 000 ; `SyncWindowTests` (3) verts | **Corrigé** |

Correctifs R2 vérifiés par tests verts de la suite complète : R2-03 (retrait des métadonnées JPEG par liste blanche, fixture hostile), R2-04 (6 `PUT` identiques simultanés = 6 × 200, vert aux 5 passages), R2-05 (alerte « BL manquant » et place libérée), R2-08 (`PullIndexTests`), R2-10 (`PhotoMaintenanceTests`, chemin absolu en production), R2-11 (`ETag`, 304 pour qui peut lire, 404 pour le chef d'équipe), R2-09 (texte d'aide « visible du terrain » présent dans le formulaire de commande, FR et AR). **R2-14 : test ajouté** (voir plus bas ; 8 requêtes SQL pour 5 comme pour 50 lignes). R2-06 (zones groupées) et R2-07 (liste mobile légère : `list_performance_test`, l'historique n'est pas lu en liste) : tests verts, **gain non mesuré sur appareil**.

## Essais réels sur l'API de démonstration
Base temporaire, mot de passe lu dans `appsettings.Development.json` (jamais affiché).
| Essai | Résultat |
|---|---|
| `chef.dev` voit **12 demandes** de `CH-ECO-UV18` (6 à suivre, 4 réceptionnées, 2 closes) et 10 livraisons | OK |
| `chef.dev` : **aucun prix** sur 30 routes (listes, 12 détails, 10 livraisons, suivi, transversale) ni dans la synchronisation (101 lignes) | OK : 0 occurrence de `commercial`, `unitPrice`, `amount`, `receivedValue`, `purchaseOrderNumber` |
| `chef.dev` voit le téléphone fournisseur (`SupplierPhone.View`) | OK, présent |
| `achats.dev` voit le prix de DEM-009 | OK : 234 000,00 DZD |
| `equipe.dev` : suivi sans montants ; **commander = 403, valider = 403** ; détail commandé sans prix ni téléphone ; photo du bon = 404 ; **aucune ligne `photo`** ni prix dans la synchronisation | OK |
| `nonaffecte.dev` : 0 chantier ; liste, livraison, suivi = **404 identique à un chantier inconnu** (corps comparé sans `traceId`) ; liste transversale vide | OK |
| `chef.dev` ouvre `CH-LOG-OL40` : 404 ; `DEM-001` existe sur les deux chantiers | OK |
| Même `clientId` envoyé 3 fois (la 3e avec une autre quantité) | OK : 201, 200, 200, **même demande, même numéro**, quantité du premier envoi, numéro suivant contigu |
| **Demande validée pendant l'édition hors ligne** (300 → 400 sacs) | OK : `conflict` + `DEMANDE_VERROUILLEE`, état serveur renvoyé (`Validated`, 300), **rien d'appliqué** ; renvoi du lot : même conflit ; aucun prix dans la réponse |
| Validation après annulation (CA-MAT-003.5) | OK : `conflict` `TRANSITION_INTERDITE`, le serveur garde `Cancelled` |
| `chef.dev` valide : 403 `INTERDIT` | OK |
| CA-MAT-016.4 (a) à (g) : ciment livré = 110 T = 2 200 sacs ; DEM-005 Livrée (600 sacs) ; DEM-011 Livrée partiellement, reste 0,8 T | OK |

Constat à ne pas prendre pour un défaut : `equipe.dev` obtient **200** sur `GET /follow-up` (compteurs seulement, sans montant). CA-MAT-013.8 dit « ChefEquipe n'a que Mes demandes » : le web masque bien le menu (Playwright), le serveur laisse lire des compteurs de demandes que ce rôle voit déjà une à une (CA-MAT-002.7). Aucune fuite.

## Couverture des critères d'acceptation
Légende : **B** backend (`Tests/Chantier.IntegrationTests/…` ou `UnitTests`), **W** web (vitest), **M** mobile (flutter_test), **P** Playwright, **R** essai réel. « QA » = test ajouté par cette QA.
| Critère | Tests | Résultat |
|---|---|---|
| **001.1** nominal | B `RequestCreationTests.A_team_leader_signals_a_need…` ; W `requestForm.spec` ; M `request_form_screen_test` cas nominal ; P `requests.spec` chef.dev 300 sacs ; R DEM créé en 201 | OK |
| 001.2 rapidité (4 gestes) | M « cas nominal en 4 gestes » (gestes comptés dans le test) | OK ; **30 s non mesurable sans appareil** |
| 001.3 équivalence | W `quantityMirror.spec` (37, vecteurs), `requestForm.spec` ; M `quantity_mirror`, `shared_vectors` ; B `MaterialVectorTests` ; P « 15 T » | OK |
| 001.4 hors ligne | M `offline_to_sync_test`, `materials_sync_test`, `requests_screens_test` (« Numéro en attente », « En attente d'envoi ») | OK (simulateur, pas d'appareil) |
| 001.5 unité | B `…refused_with_UNITE_OBLIGATOIRE`, `A_missing_quantity_is_a_400…` ; M « Autre produit : unité à choisir » ; W | OK |
| 001.6 quantité | B `An_invalid_quantity…`, `Up_to_three_decimals…` + **QA** `An_absurd_quantity…` (0, −5, −0,001, 0,0004, 2,5004, > 1 milliard, 1e15, 1e40, décimale pour sac, `null`, `true`, `[1]`) ; M ; W | OK |
| 001.7 date | B `An_incomplete_or_impossible_date…` + **QA** (13 formes, dont `../08/2026`, `31/11/2026`, `2026-02-30`, `0000-00-00`, sur demande, commande **et** livraison) ; M date passée | OK |
| 001.8 double appui, renvoi | B `A_double_tap_sent_ten_times…`, `Resending_the_same_client_id…` + **QA** autres valeurs ; M « double appui » ; R | OK |
| 001.9 doublon possible | B `A_second_open_request_for_the_same_product_and_zone…`, `A_closed_request_is_not_a_duplicate` ; M | OK |
| 001.10, 001.11 | M « ajouter un autre matériau » ; B/W/M produit libre 3 à 100 caractères + **QA** texte arabe de 100 lettres | OK |
| 001.12 grande liste de produits | M `product_search_test` (300 produits < 100 ms, « cim » retrouve le ciment) ; B `CatalogTests` (300 produits) | OK ; **temps sur appareil non mesuré** |
| 001.13 mauvais rôle | B `Create_is_allowed_for_admin_conducteur_chef_chantier_and_chef_equipe_only`, matrice ; P `requests.spec` equipe | OK |
| 001.14 mauvais chantier | B `A_site_where_the_user_is_not_assigned_is_a_404…`, `An_archived_site_is_read_only…` + **QA** balayage de toutes les routes `{siteId}` du contrat avec 3 rôles | OK |
| 001.15 arabe, soleil | W, P (RTL, numéros en LTR) ; M widgets FR/AR, boutons 56 dp, 16 sp ; **QA** petit écran | **Partiel : D-3** |
| 002.1 à 002.6 | B `RequestListTests` (15) ; M `requests_screens_test` ; W `requestsScreens.spec` ; **QA** recherche (jokers `%`, `_`, `[`, injection, arabe) | OK |
| 002.7, 002.8 | B `Every_route_of_a_site_that_is_not_assigned_is_the_same_404` + **QA** ; R 404 identique | OK |
| 002.9 grande liste | B 500 demandes + **QA 5 000 demandes** : liste 34 à 81 ms, dernière page 35 à 74 ms, recherche arabe 55 à 100 ms, retard, transversale, suivi, livraisons < 130 ms (seuil 2 s) | OK |
| 002.10 jamais sans unité | W `quantity.spec` ; M ; **QA** détail avec quantité de 1 milliard | OK |
| 003.1 à 003.4 | B `RequestTransitionTests` (21) ; W `toApprove.spec` ; M `approvals` (2 gestes, « Validation en attente d'envoi ») ; P valide en un clic | OK |
| 003.5 conflit à l'envoi | B `A_validation_after_the_cancellation_is_a_conflict…` ; M ; **R** | OK |
| 003.6 double action | B `Approving_twice…`, `Two_conductors_approving_in_parallel…` (5 passages) + **QA** valider ∥ annuler (8 tours : toujours Annulée, historique cohérent) | OK |
| 003.7, 003.8 | B + **QA** `A_team_leader_cannot_validate_reject_order_settle_archive_or_receive` (8 actions, 403, rien écrit) ; R chef 403 `INTERDIT` | OK |
| 003.9 lot de 50 | B `A_batch_is_limited_to_fifty…` ; W lot de 50 par demande | OK |
| 004.1 à 004.4 | B `RequestUpdateTests` (16) ; W ; M ; **QA** modifier la quantité ∥ valider (8 tours : jamais une quantité modifiée après validation) | OK |
| 004.5 à 004.9 | B `An_ordered_request_cannot_be_cancelled_by_the_requester`, `Cancelling_twice…`, rôles ; M ; W | OK |
| **005.1 à 005.7** | B `OrderTests` (21) ; W `toOrder.spec` ; P commande 234 000,00 ; R 234 000 | OK |
| 005.3 arrondi | B `The_amount_rounds_away_from_zero`, vecteurs (613,125 → 613,13) | OK |
| 005.5 doublon | B + **QA** (même `clientId`, autre prix : le premier prix reste) ; R **24 commandes ∥ = 24 × 201** | OK |
| **005.8** commander sur mobile sans réseau | **Reporté** : M10 hors périmètre (plan) | Reporté |
| 005.9 à 005.12 | B `Only_purchasing_and_admin…`, `Prices_never_reach_the_field_roles_on_any_route` + **QA** balayage prix ; R | OK |
| 006.1 à 006.3 | M `delivery_form_screen_test` (« 3 gestes », annonce partielle/complète/surplus +16,67 %) ; B `DeliveryTests` (32) ; W `deliveries.spec` | OK |
| 006.4 unités | B `A_partial_delivery_in_tonnes…`, `Sand_ordered_in_cubic_metres_cannot_be_received_in_tonnes` ; M ; W | OK |
| 006.5 quantité, date | B `The_delivery_fields_are_validated` + **QA** dates ; M « hier » ; **QA** horloge du téléphone en avance : livraison de demain `rejected DATE_INVALIDE`, livraison d'il y a 5 jours appliquée | OK |
| 006.6 à 006.12 | B (réserve, `Simultaneous_sends…`, doublon de BL, rôles, autre chantier, archivé) ; M ; W | OK |
| 006.13 | M « Plus tard » / « DEM-014 est livrée. Réceptionner maintenant ? » | OK |
| 007.1, 007.2 | M `delivery_form_screen_test` (Reprendre/Garder), `deliveries_sync_test` ; **QA M** 150 photos | OK ; **appareil photo réel non testable** |
| 007.3 à 007.5 | B `A_sixth_photo_is_refused`, `Six_simultaneous_uploads…`, `A_file_that_is_not_a_jpeg…`, `A_file_over_the_limit…` (413), retrait EXIF en liste blanche | OK |
| 007.6, 007.7 | B `The_missing_note_alert_clears_only_when_the_file_is_received` ; M filtre « BL manquant », majuscules | OK |
| 007.8, 007.9 | B `Photos_are_read_only_by_the_roles…`, 304 ; P photo lue avec la session ; R chef d'équipe 404 | OK |
| **007.10** 150 photos | **QA M** `materials_three_days_photos_test` : 30 livraisons × 5 photos, tout part **une fois, dans l'ordre de prise**, 0 fichier restant ; coupure au 71e fichier puis application relancée : 80 fichiers conservés, tout arrive, aucun doublon | OK ; **fluidité de l'écran non mesurable sans appareil** |
| 008.1, 008.2 | B vecteurs, `Three_deliveries_complete_the_request_and_cancelling_the_last_goes_back_one_step`, `The_cache_always_matches_a_recompute_from_scratch_after_random_operations` | OK |
| 008.3, 008.4 | B `Receiving_a_delivered_request…` ; M « Réceptionner en 1 geste », conducteur sans bouton ; W | OK |
| 008.5 à 008.7 | B `Settling_a_partially_delivered_request…`, surplus ; vecteurs (tolérance 1 %) ; W solder | OK |
| 008.8 | B `DeliverySyncTests` ; M « La demande n'est plus complète » | OK |
| 008.9, 008.10 | B `A_received_request_refuses_correction_and_cancellation_of_its_deliveries`, `A_delivery_is_never_refused_because_of_the_status_of_the_request` | OK |
| 009.1, 009.6 | B `MaterialPermissionMatrixTests` ; **QA W** `materialsContract.spec` (30) : la matrice du web = le tableau du contrat, 28 permissions ; P equipe sans boutons | OK |
| 009.2 | **QA** balayage : pour chaque route `{siteId}`, chantier non affecté ≡ chantier inconnu (3 rôles) ; routes anonymes = 401 | OK |
| 009.3 prix | B + **QA** : 5 rôles × toutes les routes de lecture du contrat + synchronisation complète : 0 prix pour le terrain, **0 prix dans toute synchronisation** ; M `materials_privacy_test`, `material_json_guard_test` ; R 30 routes | OK |
| 009.4 téléphone | B + **QA** même balayage ; M ; R | OK |
| 009.5 droit retiré | B `A_role_without_the_right_to_create_is_rejected_and_the_rest_of_the_batch_goes_through`, `A_transition_without_the_right…` | OK |
| 009.7 traçabilité | B `Approving_moves_to_validated_and_keeps_the_history` (heure du serveur, « saisi le ») + **QA** horloge 2099 / 1999 : numéros dans l'ordre d'arrivée, dates du serveur | OK |
| 010.1, 010.12 | **QA B** 20 demandes + 5 livraisons « de trois jours » poussées puis **renvoyées en entier** : 25 `applied` puis 25 `duplicate`, DEM-001 à DEM-020 sans trou ; M `trois jours sans réseau`, `200 saisies par lots de 50` | OK |
| 010.2 à 010.5 | B `MaterialsSyncTests` (39) ; M ; **R** conflit réel | OK |
| 010.6, 010.7 | B `DeliverySyncTests` (15) ; M | OK |
| 010.8 à 010.11, 010.13, 010.14 | B (journal, ordre, renvoi) ; M (« à confirmer », aucun prix en base) ; **QA** horloge fausse | OK |
| 011.1 à 011.8 | B `An_unattached_delivery_is_attached…`, `Attaching_checks_the_product…` ; M non rattachées ; W ; R LIV-010 | OK |
| 012.1 à 012.8 | B `Correcting_a_delivery_recomputes…`, `Cancelling_needs_a_reason…`, `A_received_request_refuses…` ; M ; W ; **QA** six corrections sur la même version = 1 × 200 + 5 × 409 (livraison et commande) | OK |
| 013.1 à 013.6, 013.8 | B `FollowUpTests` (7) ; W `followUp.spec` ; P suivi ; R compteurs ; **QA** suivi d'un chantier de 5 000 demandes en 77 à 120 ms | OK |
| 013.7 | M `to_receive`, `to_reception`, bandeau | OK |
| 014.1 à 014.8 | B `Archiving_hides_a_closed_request…`, lot de 100 ; W ; **QA** un numéro annulé puis archivé n'est jamais réattribué (demande et livraison) | OK |
| 015.1 à 015.10 | B `CatalogTests` (29) ; W `catalogScreens.spec` ; P `achats.dev` crée un produit ; M `catalog_daos_test` | OK |
| 015.11 | W `translations.spec` (parité FR/AR des clés) | **KO : D-2** (un code d'erreur sans traduction) |
| 016.1 à 016.4 | B `MaterialsDemoDataTests` (15) ; **R** deux chargements (base neuve), cas (a) à (g) | OK |

## Règles métier obligatoires
| Règle | Test | Résultat |
|---|---|---|
| Arrondi `AwayFromZero` (1,005 → 1,01 ; 613,125 → 613,13), montants, ciment 20 sacs = 1 T, avancement | `MaterialVectorTests` et vecteurs lus par les **trois** suites (.NET, Dart, TypeScript) ; B `The_amount_rounds_away_from_zero` ; **QA** 1 milliard de kg × 9 999 999,99 = 9 999 999 990 000 000,00 exact | OK |
| Unité obligatoire ; refus d'agréger des unités | B `UNITE_OBLIGATOIRE`, `UNITES_INCOMPATIBLES` (sable m³ / T) ; W/M | OK |
| Dates incomplètes (`../08/2026`) | B + **QA** 13 formes sur 3 routes | OK |
| Transitions autorisées et interdites, motif obligatoire | B `The_transition_table_permits_exactly_the_documented_pairs`, `A_reason_from_the_list_is_required…` | OK |
| Numérotation unique par chantier, deux créations simultanées | B `Sixty_parallel_creations_give_sixty_distinct_numbers_without_gap`, `Simultaneous_deliveries…` (5 passages) ; R | OK |
| Idempotence du `clientId` | B, M, **R** (201, 200, 200) | OK |
| Droits : ChefEquipe ne valide pas ; chantier non affecté = 404 ; téléphones masqués | B + **QA** + R | OK |
| Concurrence : deux modifications sur la même version = un 200, un 409 | B `Two_parallel_edits_with_the_same_version…` + **QA** livraison et commande (6 écritures ∥) | OK |

## Cas limites explorés
| Cas | Résultat |
|---|---|
| Hors ligne : mode avion pendant l'envoi d'une photo ; application tuée pendant la synchronisation ; reprise après trois jours | **QA M** coupure au 71e fichier puis relance : 0 fichier perdu, 0 doublon ; M `application tuee pendant l'envoi : reprise sans doublon` ; **QA B** lot de trois jours renvoyé en entier = 25 `duplicate` |
| Double appui sur « Envoyer » | B (10 envois ∥ = 1 demande, 0 numéro brûlé), M |
| Horloge du téléphone fausse | **QA** `clientCreatedAt` en 2099 et en 1999 : le serveur fait foi ; livraison datée de demain rejetée `DATE_INVALIDE` avec son code, jamais perdue en silence |
| Liste de 5 000 lignes | **QA** 5 000 demandes + 3 000 livraisons : toutes les listes < 130 ms ; première synchro 32 Ko gzip |
| Texte arabe long, caractères spéciaux | **QA** note de 200 caractères arabes avec `« » Ø <b> & ' " % _ [ ] \ ؟ ٣٠٠` relue à l'identique ; 100 emojis acceptés ; 201 caractères refusés ; recherche par `%`, `_`, `[`, `'`, `; DROP TABLE` sans effet |
| Valeurs nulles, corps malformés | **QA** 10 corps (`null`, `{}`, `[]`, `"texte"`, `{`, vide, GUID invalide…) × 8 routes : toujours 4xx `application/problem+json`, jamais de pile |
| Quantité 0 ou négative, très grand montant | **QA** voir 001.6 ; **D-1** pour le dépassement de colonne |
| Interface : arabe (RTL), petit écran, police agrandie | W/P/M RTL OK ; **QA M petit écran : D-3** |

## Défauts (passe 1) : tous corrigés en passe 2
| # | Sévérité | Où (fichier:ligne) | Scénario de reproduction | Attendu / obtenu | Agent à qui corriger |
|---|---|---|---|---|---|
| **D-2** | **Majeur** | `chantier-frontend/libs/i18n/src/locales/{fr,ar}/errors.json` (clé `ERREUR_TEMPORAIRE` absente) ; test `libs/i18n/src/translations.spec.ts:70-82` | `cd chantier-frontend; npx nx run i18n:test` : « traduit tous les codes d'erreur du catalogue docs/api/codes-erreur.md » → `expected [ 'ERREUR_TEMPORAIRE' ] to deeply equal []`. Le code a été ajouté par la correction R2-01 (503 + `Retry-After`, `docs/api/codes-erreur.md:39`) | **Attendu** : le web traduit tous les codes du catalogue (CT-MAT-20, CA-MAT-015.11), comme le mobile (`errorErreurTemporaire`, FR et AR). **Obtenu** : CI rouge ; un utilisateur du back-office dont la commande tombe sur un 503 voit le message générique, sans « rien n'a été enregistré, réessayez » | frontend-react |
| **D-1** | Mineur | `Core/Chantier.Core/Materials/QuantityRules.cs:8-12` (`MaxValue`) et `Core/Chantier.Core/Materials/Money.cs` ; colonne `Delivery.Amount` (18,2) | Test `MaterialsQaTests.The_largest_quantity_at_the_largest_price_gives_the_exact_amount_and_an_overflow_is_never_a_server_error` (rouge). À la main : demande de 1 000 000 000 kg, validée ; commande à 9 999 999,99 DZD/kg (montant exact 9 999 999 990 000 000,00 : accepté) ; `POST …/deliveries` de **1 000 000 000 t** pour cette demande | **Attendu** : refus clair (422, par exemple `QUANTITE_INVALIDE`), rien d'écrit. **Obtenu** : **500 `ERREUR_INTERNE`** (`DbUpdateException` / `ArgumentException` : la valeur reçue convertie en kg (10¹² kg) × prix dépasse la précision 18,2). La borne `MaxValue` contrôle la quantité saisie, pas son produit par le prix après conversion. Extrême (un million de tonnes à un prix maximal) mais la règle « jamais d'erreur serveur sur un très grand montant » n'est pas tenue | backend-dotnet |
| **D-3** | Mineur | `chantier-mobile/lib/features/materials/presentation/requests/requests_screen.dart:82`, `deliveries/to_receive_screen.dart:75`, `deliveries/deliveries_screen.dart:49` (`Column` d'en-tête fixe : recherche + 5 pastilles qui passent à la ligne, hors de la zone défilante) | `cd chantier-mobile; flutter test test/qa/materials_small_screen_large_font_test.dart` (8 rouges, FR et AR) | **Attendu** : aucun débordement sur un petit téléphone avec police agrandie, liste atteignable. **Obtenu** à **320 × 568 dp** : « Demandes » : débordement de **101 px à police ×1,3** (FR) et 17 px (AR), 247 px (FR) et 203 px (AR) à ×2 ; « À recevoir » : 146 px (FR), 45 px (AR) ; « Livraisons » : 146 px (FR et AR) : la liste est rognée. **À 360 × 640 dp et police ×1,3 : aucun débordement** (test de calibrage vert) : seuls les plus petits téléphones et les très grandes polices sont touchés. Même famille que le défaut D-2 du rapport du socle | mobile-flutter |

### Suggestions (aucune action bloquante)
- **S-1 (devops-ci, backend).** Sans `READ_COMMITTED_SNAPSHOT` (base restaurée sans la migration), 8 acheteurs simultanés reçoivent **40 % de 503** à rejouer (jamais de 500, aucune perte). La parade est la migration : à rappeler dans `docs/exploitation/` (la base doit être appliquée sans autre connexion) et à contrôler au démarrage (alerte si l'option est à 0).
- **S-2 (backend).** `quantity.value` envoyé comme **chaîne** (`"300"`) est accepté en 201 : tolérance du désérialiseur, sans conséquence métier. À décider : refuser (contrat strict) ou documenter.
- **S-3 (orchestrateur).** Deux fichiers vides à la racine du dépôt, `DeliverySyncTests.cs` et `MaterialsSyncTests.cs` (0 octet, créés le 25/11 à 16:25, non commités) : traces d'un déplacement raté, à supprimer. Je n'y ai pas touché.
- **S-4 (revue).** `GET /follow-up` répond 200 à un chef d'équipe (compteurs seulement). Voir plus haut : pas de fuite, à noter dans le contrat.

## Test instable détecté puis corrigé (le mien)
`Six_corrections_of_a_delivery_or_an_order_on_the_same_version…` a échoué 2 fois sur 5 aux premiers passages (deux 200 au lieu d'un). Ce n'était pas un défaut du produit : la livraison partait à 5 t et l'une des six corrections demandait justement 5 t ; si elle passait la première, c'est un « aucun changement » légitime (200 sans écriture), puis une autre réussissait sur la même version. Départ à 7,5 t : plus aucune valeur commune, **5 passages sur 5 verts**. Le message d'assertion donne désormais la liste des codes reçus.

## Tests ajoutés (112 en passe 1, **+4 en passe 2**)
Passe 2 :
- `chantier-backend/Tests/Chantier.IntegrationTests/Qa/MaterialsQaTests.cs` (+3) : `The_received_value_stops_exactly_at_the_column_limit_with_a_422…` (D-1, cumul reçu à la capacité exacte de la colonne puis 2 kg de trop), `An_oversized_delivery_sent_from_the_phone_is_rejected_with_its_code…` (D-1 en synchronisation), `A_pull_never_carries_the_reset_flag_for_an_up_to_date_phone_nor_for_a_first_pull` (R3-05).
- `chantier-frontend/apps/chantier-back-office-e2e/src/photoRetry.spec.ts` (+1) : navigateur réel, 503 `ERREUR_TEMPORAIRE` sur le fichier d'une photo, message traduit, « Réessayer l'envoi » rejoue la même photo (D-2, R3-02, R3-04).
- Essais réels (scripts jetables, hors dépôt) : D-1, R3-05, R3-01 avec un verrou SQL réel, S-1.

Passe 1 :
- `chantier-backend/Tests/Chantier.IntegrationTests/Qa/MaterialsQaTests.cs` (57 cas) : quantités extrêmes (15 formes), dates (13 formes × 3 routes), corps nuls ou malformés (10 × 8 routes), texte arabe et caractères spéciaux, recherche par jokers, idempotence avec d'autres valeurs (demande, commande, livraison), concurrence (valider ∥ annuler, modifier la quantité ∥ valider, six corrections sur la même version), numéros jamais réattribués, horloge du téléphone en 2099 et 1999, trois jours hors ligne (20 demandes + 5 livraisons, lot renvoyé en entier), balayages dérivés du contrat OpenAPI (404 identique sur toutes les routes `{siteId}` avec 3 rôles ; 401 anonyme sur toutes les routes ; prix et téléphone absents de toutes les lectures et de la synchronisation pour 5 rôles), chef d'équipe sans aucun droit d'écriture, **nombre de requêtes SQL constant (R2-14)**, montant démesuré (rouge : D-1).
- `chantier-backend/Tests/Chantier.IntegrationTests/Qa/MaterialsQaVolumeTests.cs` (5) : 5 000 demandes et 3 000 livraisons (listes, recherche arabe, suivi < 2 s ; première synchro < 300 Ko gzip ; affectation), et **repli sans `READ_COMMITTED_SNAPSHOT`** (`The_migration_turns_read_committed_snapshot_on…`, `Without_the_snapshot_option_the_retry_alone_keeps…`).
- `chantier-frontend/apps/chantier-back-office/src/qa/materialsContract.spec.ts` (30) : la matrice de permissions du web est lue dans le contrat et comparée permission par permission.
- `chantier-mobile/test/qa/materials_small_screen_large_font_test.dart` (18, dont 8 rouges D-3) : 320 × 568 dp police ×2, FR et AR, textes de 100 lettres arabes, quantité de 999 999 999,999, boutons de 56 dp, calibrage 360 × 640 à ×1,3.
- `chantier-mobile/test/qa/materials_three_days_photos_test.dart` (2) : 150 photos par lots, coupure en plein envoi, application relancée.

## Risques résiduels : non vérifiable sans appareil ni environnement réel
- **Appareil Android** (ni émulateur ni licences) : scénario hors ligne réel (mode avion pendant une vraie prise de photo), appareil photo, `tel:` du fournisseur, rapidité « moins de 30 s » et « 4 gestes » (comptés en test de widget seulement), fluidité d'une liste de 5 000 lignes et de 150 photos en attente, mémoire, taille de l'APK, manifeste Android fusionné, lisibilité au soleil et avec des gants.
- **Réseau réel** : durée de la première synchro en 3G (calcul indicatif : 32 Ko gzip, quelques secondes), proxy et en-têtes de production, `Storage:PhotosRoot` absolu en production (démarrage refusé sinon : testé, pas essayé sur le serveur).
- **Traductions arabes** : présentes et parité des clés vérifiée, mais **non relues par un arabophone du terrain** (Q-MAT-10, H-MAT-24) : à faire avant la mise en service.
- **CA-MAT-005.8** (commander sur mobile) reporté avec M10 ; Q-MAT-01 à 09 retenues par défaut, **non validées** par l'utilisateur.
- Playwright : Chromium seul (WebKit et Firefox non lancés). La limite de connexion (10 par 5 min et par compte) fait échouer une 2e exécution rapprochée : redémarrer l'API de test entre deux passes.
- Journal de l'API pendant les essais trop court (44 lignes) pour prouver seul l'absence de données sensibles ; la preuve large est celle de la revue R2 et de `NoPersonalDataInLogsTests`.
- Captures RTL web et mobile du lot non régénérées (`docs/qa/captures` : celles du socle).
