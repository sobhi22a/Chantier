# Plan : demandes de matériaux, commandes et livraisons

**Slug :** `demandes-materiaux-livraisons` · **User stories :** `docs/metier/demandes-materiaux-livraisons.md` (US-MAT-001 à 016, hypothèses H-MAT-01 à 24, questions Q-MAT-01 à 10) · **Auteur :** architecte-chantier · **Date :** 2026-11-25 · **Statut :** Proposé
**Contrat :** `docs/api/demandes-materiaux-livraisons.md` (puis `docs/api/openapi.json` généré) · **Codes d'erreur :** `docs/api/codes-erreur.md` · **Vecteurs de calcul :** `docs/api/vecteurs-materiaux.json` · **Décisions :** ADR 0011 à 0014.

## Résumé
Première fonctionnalité métier : la chaîne **besoin → validation → commande → livraison avec photo du bon → réception**, où chaque maillon est une ligne numérotée (`DEM-014`, `LIV-021`), datée, avec un responsable, une unité et un statut.
Le chef d'équipe ou de chantier signale un besoin en 4 gestes **sans réseau** ; le conducteur valide en 2 gestes ; les Achats commandent au bureau (web) ; le chef de chantier enregistre le camion et photographie le bon **sans réseau** ; le serveur calcule le statut d'après les livraisons (dans les deux sens), refuse tout mélange d'unités et garde les prix hors de portée du terrain.
Le lot s'appuie sur le socle sans le modifier en profondeur : `ISiteNumbering`, `[SiteScoped]`, `HasPermission`, Ardalis.Specification, Problem Details, `clientId`, file d'envoi, curseur de synchronisation. Il **étend** la synchronisation (opérations `update` et `transition`, entités globales) : ADR 0011 et 0012.
**Livraison en deux tranches**, chacune démontrable seule (voir « Ordonnancement ») : **A « Demander et valider »** (catalogue, demandes, validation, mobile hors ligne, conflits de modification) puis **B « Commander et recevoir »** (commandes, livraisons, photos du bon, statut calculé, suivi, archivage, démonstration).

## Périmètre par rapport aux user stories
| Story | Couverture | Tâches | Tranche |
|---|---|---|---|
| 001 Signaler un besoin | Complète (mobile hors ligne, web) | B1 B2 B4 B9, W1 W3, M1 M3 M4 | A |
| 002 Suivre mes demandes | Complète | B4, W3, M2 M4 | A |
| 003 Valider ou refuser | Complète (lot de 50 sur le web) | B4 B9, W4, M5 M9 | A |
| 004 Corriger ou annuler | Complète | B4 B9, W3, M4 M9 | A |
| 015 Catalogue et fournisseurs | Complète (web) ; copie hors ligne sur mobile | B3 B9, W2, M2 | A |
| 005 Commander | Complète sur le web ; **mobile en ligne, optionnel (M10)** | B5, W5, M10 | B |
| 006 Recevoir un camion | Complète | B6 B10, W6, M6 | B |
| 007 N° et photo du bon | Complète | B7 B10, W6, M8 | B |
| 008 Statut automatique, réception, solde | Complète | B5 B6, W5 W6, M6 M7 | B |
| 009 Chacun voit ce qui le concerne | Transversale (prix, téléphone, matrice) | B2 B3 B5, W1, tous, Q1 Q2 R1 R2 | A puis B |
| 010 Envoyer sans perte, trancher les conflits | Complète | B9 B10, M3 M9 | A (demandes), B (livraisons) |
| 011 Livraison sans demande, rattacher | Complète | B6 B10, W6, M7 | B |
| 012 Corriger ou annuler une livraison | Complète | B6 B10, W6, M7 | B |
| 013 Suivre : à valider, commander, recevoir | Web complète ; mobile : À valider, À recevoir, À réceptionner | B8, W7, M5 M6 | B |
| 014 Archiver | Complète (web, en ligne) | B4, W7 | A (API) / B (écran) |
| 016 Données de démonstration | Complète | B11 | B |
**Écarts de périmètre à signaler** : (1) l'écran mobile « Commander » (CA-MAT-005.8) est **optionnel** et en ligne seulement ; (2) le téléphone d'un fournisseur n'est lu **qu'en ligne** (jamais stocké sur le téléphone, ADR 0012) ; (3) aucun prix n'est affiché sur le mobile, pour aucun rôle (ADR 0012) ; (4) pas de suppression de photo (lot photos).

## Hypothèses retenues, à valider par l'utilisateur
Valeurs par défaut de l'expert métier retenues pour **toutes** les questions ouvertes. « Pour inverser » = coût du retour en arrière (une ligne de configuration ou de matrice, sauf mention).
| N° | Choix retenu | Pour inverser |
|---|---|---|
| **Q-MAT-01 a** | Les Achats annulent une commande sans livraison : **Commandée → Validée** (motif obligatoire), seulement si aucune livraison non annulée n'existe | Retirer `Orders.Cancel` à Achats et Admin dans `RolePermissionMatrix` ; retirer CA-MAT-005.7 |
| **Q-MAT-01 b** | Achats ou conducteur **solde** un manque définitif : **Livrée partiellement → Livrée** (motif obligatoire, drapeau `isSettled`) | Retirer `Requests.Settle` ; retirer CA-MAT-008.5 |
| **Q-MAT-01 c** | **Écart de statut** : le ChefChantier **n'annule pas** les demandes de ses chefs d'équipe (seulement les siennes) | Ajouter `Requests.CancelAny` à ChefChantier (une ligne) |
| Q-MAT-02 | Seuls ChefChantier, conducteur, Achats (et Admin) enregistrent le camion | Ajouter `Deliveries.Create` + `DeliveryPhotos.Create` à ChefEquipe (matrice ; l'écran mobile est déjà piloté par les permissions) |
| Q-MAT-03 | Le ChefChantier voit la photo du bon | Retirer `DeliveryPhotos.View` à ChefChantier (il garde `Create` ; il voit alors sa photo locale tant qu'elle n'est pas envoyée) |
| Q-MAT-04 | Tolérance de « livraison complète » : **0 %** (il faut solder un manque) | `Materials:DeliveryTolerancePercent` (valeur globale) ; par produit = une colonne nullable `Product.DeliveryTolerancePercent` et une migration (non faite : pas de code mort) |
| Q-MAT-05 | Rond à béton en **T ou kg** (pas de barres) | Ajouter l'unité `barre` et sa conversion (poids par diamètre) dans `UnitConverter` + vecteurs : règle nouvelle à valider (ADR 0014) |
| Q-MAT-06 | Montants **hors taxes** en DZD ; aucune TVA, aucun taux en dur | Ajouter une option `Materials:VatRatePercent` (vide) et un montant TTC calculé ; **taux à confirmer auprès de la DGI**, jamais codé en dur |
| Q-MAT-07 | **Un camion pour deux demandes = deux livraisons** (même n° de BL possible, avertissement de doublon non bloquant) | Livraison répartie : refonte du modèle (table de lignes) = changement lourd ; à décider avant la tranche B |
| Q-MAT-08 | « retba », « lheria », « auberge » = **autres chantiers** créés par l'Admin | Un « lieu de réception » sur la livraison (colonne et écran) |
| Q-MAT-09 | Date de besoin par défaut = **aujourd'hui + 3 jours** pour tout | `Materials:DefaultNeededByDays` ; par produit = colonne nullable `Product.DefaultLeadDays` |
| Q-MAT-10 | Traductions arabes : textes du document métier, **à faire relire** par un arabophone du terrain avant la mise en service (H-MAT-24) | Fichiers `errors.json`, `materials.json` (web) et ARB (mobile), aucun code à changer |
| H-MAT-05, 10 | `Materials:DefaultNeededByDays = 3` ; tolérance 0 % | configuration |
| H-MAT-08 | Masse du sac **par produit** (`Product.BagMassKg`, 50 ciment, 25 monocouche) | donnée du catalogue |
| H-MAT-13 | 5 photos au plus, n° de BL ≤ 30 caractères | `Materials:MaxPhotosPerDelivery` |
| H-MAT-15, 16 | Prix : `Prices.View` (Admin, Direction, Conducteur, Achats) ; téléphone fournisseur : `SupplierPhone.View` (Admin, Achats, Conducteur, ChefChantier) | matrice |
| H-MAT-18 | Listes de motifs par cas, ouvertes (« Autre » impose une remarque) | `Materials:Reasons:*` ; `GET /settings/materials` les publie, le client affiche un code inconnu tel quel |
**Hypothèses d'architecture** (nouvelles, à valider) :
| N° | Hypothèse | Pour inverser |
|---|---|---|
| H-ARCH-01 | Entité `MaterialRequest`, route `/requests`, entité de synchronisation `request` (le glossaire dit `Request`) | renommage de code avant la première migration seulement |
| H-ARCH-02 | **Aucun prix sur aucun téléphone**, pour aucun rôle ; les rôles autorisés les lisent en ligne (ADR 0012) | SQLCipher d'abord, puis ADR de remplacement |
| H-ARCH-03 | **Téléphone fournisseur jamais stocké sur le téléphone** ; lecture en ligne puis `tel:` | idem (SQLCipher) |
| H-ARCH-04 | Écran mobile « Commander » **optionnel** (M10), en ligne ; la commande se saisit surtout sur le web | promouvoir M10 en obligatoire |
| H-ARCH-05 | Conflit entre deux modifications du même champ : **première arrivée retenue**, l'autre dans « À vérifier » (écart au skill : dernière écriture gagne ; ADR 0011) | changer l'évaluateur `FieldMergeEvaluator` |
| H-ARCH-06 | Conflit tout ou rien **par opération** (pas de fusion partielle d'une même saisie) | idem |
| H-ARCH-07 | **La livraison n'a pas de prix propre** : sa valeur = quantité convertie × prix de la commande (le champ « prix de la livraison » du document métier est calculé, lecture seule) | colonne `Delivery.UnitPrice` + règle de priorité |
| H-ARCH-08 | Photos : **JPEG seulement**, 5 Mo au plus (cible 2 Mo), EXIF retiré sans réencodage, pas de miniature, un `PUT` complet idempotent, pas de suppression (ADR 0013) | lot « photos » (SkiaSharp) |
| H-ARCH-09 | Pas de **détachement** d'une livraison rattachée par erreur : l'annuler puis la ressaisir | action `detach` (petite) |
| H-ARCH-10 | Annuler une commande ne compte que les livraisons **non annulées** | règle du service de commande |
| H-ARCH-11 | Demande soldée : drapeau `isSettled`, statut `Delivered` ; si toutes ses livraisons sont ensuite annulées, retour à `Ordered` | règle de `RequestStatusCalculator` |
| H-ARCH-12 | Une demande ou une livraison d'un chantier archivé est en lecture seule (`CHANTIER_ARCHIVE`), y compris pour réceptionner ; le serveur renvoie la saisie hors ligne dans « À vérifier » | règle du socle |
| H-ARCH-13 | Liste transversale `GET /requests` (tous mes chantiers) pour les files « À valider » et « À commander » du web | supprimer l'endpoint, filtrer par chantier courant |
| H-ARCH-14 | Retard et dates du jour = **date d'Algérie** (UTC+1, pas d'heure d'été) via `TimeProvider` ; une date de livraison dans le futur est refusée **sans marge**, même si l'horloge du téléphone avance | marge paramétrable (non faite) |
| H-ARCH-15 | Réglages (`GET /settings/materials`) lus depuis `appsettings` ; un écran d'administration viendra avec le lot Administration | table de réglages |

## Modèle de données
Conventions du socle (ADR 0003) : `BasicEntity` (GUID v7, audit, `RowVersion`), `ISiteScoped`, `IHasClientId`, énumérations en chaînes, `decimal` avec précision explicite (quantités 18,3 ; montants 18,2), dates métier en `DateOnly`, index uniques **filtrés** `DeletedAt IS NULL`, index `(SiteId, RowVersion)` sur toute table synchronisée. Aucune suppression physique : archiver, annuler, désactiver.
| Entité (code) | Champs | Index et contraintes | Migration |
|---|---|---|---|
| `Product` : `BasicEntity` (**globale**) | `NameFr` (150), `NameAr?`, `NormalizedNameFr` (minuscules, sans accents ni espaces superflus), `Category`, `AllowedUnits` (codes séparés par des virgules, ≥ 1), `DefaultUnit` (∈ `AllowedUnits`), `BagMassKg?` (9,3 ; obligatoire si `sac` autorisé), `IsActive`, `DeactivatedAt?` | Unique `NormalizedNameFr` filtré ; index `RowVersion` ; index `(Category, IsActive)` | `AddMaterialRequests` (B2) |
| `Supplier` : `BasicEntity` (**globale**) | `Name` (150), `NormalizedName`, `Phone?` (30, **sensible**), `ProductIds` (liste de GUID, colonne JSON), `IsActive`, `DeactivatedAt?` | Unique `NormalizedName` filtré ; index `RowVersion` | B2 |
| `MaterialRequest` : `BasicEntity`, `ISiteScoped`, `IHasClientId` | `SiteId`, `ClientId?`, `ClientCreatedAt?`, `Number` (`DEM-nnn`), `ProductId?`, `FreeProductName?` (≤ 100), `Quantity` (18,3), `Unit`, `ZoneId?`, `NeededBy` (date), `Priority`, `Note?` (≤ 200), `Status`, `StatusReasonCode?`, `StatusReasonNote?`, `ReceivedQuantity` (18,3, unité de la demande), `IsSettled`, `PossibleDuplicateOfId?`, `ArchivedAt?`, `ArchivedBy?` ; exactement un de `ProductId` / `FreeProductName` (contrainte `CHECK`) | Unique `(SiteId, Number)` filtré ; unique `(SiteId, ClientId)` filtré `ClientId IS NOT NULL` ; `(SiteId, Status, Priority, NeededBy)` ; `(SiteId, ProductId, ZoneId, Status)` (doublons) ; `(SiteId, RowVersion)` ; FK `ProductId`, `ZoneId` | B2 |
| `MaterialEvent` : `BasicEntity` (immuable, **pas** `ISiteScoped` : lu via son sujet) | `SiteId`, `SubjectType` (`Request` \| `Delivery`), `SubjectId`, `Type`, `FromStatus?`, `ToStatus?`, `ReasonCode?`, `ReasonNote?`, `Changes?` (JSON `[{field, old, new}]`), `ActorId`, `OccurredAt` (serveur), `DeviceAt?` (« saisi le »), `Source` (`Api`\|`Sync`\|`System`) | `(SubjectType, SubjectId, OccurredAt)` ; `(SiteId)` | B2 |
| `SyncOperationLog` (technique, ni `BasicEntity` ni synchronisée) | `ClientId` (PK), `UserId`, `SiteId?`, `Entity`, `Operation`, `Outcome` (`applied`\|`conflict`\|`rejected`), `Code?`, `ResourceId?`, `CreatedAt` | PK `ClientId` ; index `CreatedAt` (purge) | B2 |
| `MaterialOrder` : `BasicEntity`, `ISiteScoped`, `IHasClientId` | `SiteId`, `RequestId`, `ClientId?`, `SupplierId`, `OrderDate`, `ExpectedDeliveryDate?`, `UnitPrice?` (18,2, **commercial**), `Amount?` (18,2, **commercial**, calculé), `PurchaseOrderNumber?` (50, **commercial**), `Note?`, `CancelledAt?`, `CancelledBy?`, `CancelReasonCode?`, `CancelReasonNote?` | Unique `(RequestId)` filtré `DeletedAt IS NULL AND CancelledAt IS NULL` (une commande active par demande) ; unique `(SiteId, ClientId)` ; `(SiteId, RowVersion)` ; FK `SupplierId` | `AddOrdersDeliveriesPhotos` (B5) |
| `Delivery` : `BasicEntity`, `ISiteScoped`, `IHasClientId` | `SiteId`, `ClientId?`, `ClientCreatedAt?`, `Number` (`LIV-nnn`), `RequestId?`, `UnattachedReason?`, `SupplierId?`, `FreeSupplierName?`, `ProductId?`, `FreeProductName?`, `Quantity` (18,3), `Unit`, `QuantityInRequestUnit?` (18,3), `DeliveryDate`, `DeliveryNoteNumber?` (30), `Conformity`, `ReserveReasonCode?`, `ReserveNote?`, `Status`, `CancelReasonCode?`, `CancelReasonNote?`, `CancelledAt?`, `CancelledBy?`, `Amount?` (18,2, **commercial**), `PossibleDuplicateOfId?` | Unique `(SiteId, Number)` filtré ; unique `(SiteId, ClientId)` ; `(SiteId, RequestId, Status)` ; `(SiteId, Status)` filtré `RequestId IS NULL` (non rattachées) ; `(SiteId, SupplierId, ProductId, DeliveryNoteNumber)` (doublon de BL) ; `(SiteId, RowVersion)` | B5 |
| `Photo` : `BasicEntity`, `ISiteScoped`, `IHasClientId` | `SiteId`, `ClientId`, `ClientCreatedAt?`, `DeliveryId` (obligatoire ici, nullable au lot photos), `TakenAt`, `ContentType`, `SizeBytes?`, `Sha256` (64), `StorageKey?`, `ContentStatus`, `UploadedAt?` | Unique `(SiteId, ClientId)` ; `(DeliveryId)` ; `(SiteId, RowVersion)` | B5 |
Compteurs `DEM` et `LIV` : **déjà créés** par le socle (`SiteCounters`, migration `BackfillSiteCounters`) : aucun nouveau compteur.
**Pas de colonne dérivée sans propriétaire** : `ReceivedQuantity`, `QuantityInRequestUnit`, `Status` (après `Ordered`) et `Amount` sont des **caches recalculés dans la transaction** par `RequestRecalculator` (seul écrivain) à partir des livraisons non annulées ; un test (`RecomputeMatchesStoredTests`) tire des séquences aléatoires d'opérations et compare le cache à un recalcul depuis zéro.
**Où chaque règle est écrite** : domaine pur dans `Chantier.Core/Materials/` (ADR 0014, testé sans base ni HTTP) ; orchestration (transaction, numéro, événements, droits de ressource) dans `Chantier.Infrastructure/Services/Materials/` ; contrôleurs minces (`WebApi/Controllers/Materials/`).

## Contrat d'API
Détail, JSON et règles : `docs/api/demandes-materiaux-livraisons.md`. Résumé (toutes les routes sous `/api/v1`, `[SiteScoped]` sur `{siteId}`) :
| Méthode | Route | Permission | Réponses (codes) |
|---|---|---|---|
| GET / POST / PUT | `/products`, `/products/{id}` | `Products.View` / `Create` / `Update` | 200, 201, 400, 404, 409, 422 `PRODUIT_EXISTANT` `MASSE_SAC_OBLIGATOIRE` `UNITE_NON_AUTORISEE` |
| POST | `/products/{id}/activate`, `/deactivate` | `Products.Update` | 200, 404 |
| GET / POST / PUT, POST | `/suppliers`, `/suppliers/{id}`, `…/activate`, `…/deactivate` | `Suppliers.*` ; `phone` avec `SupplierPhone.View` | 200, 201, 404, 409, 422 `FOURNISSEUR_EXISTANT` |
| GET | `/settings/materials` | authentifié | 200 |
| GET | `/sites/{siteId}/requests`, `/requests` (transversale) | `Requests.View` | 200, 404 |
| GET / POST / PUT | `/sites/{siteId}/requests[/{id}]` | `Requests.View` / `Create` / `Update` ou `UpdateAny` | 200, 201, 400, 403, 404, 409 `CONFLIT_VERSION`, 422 (voir ci-dessous) |
| POST | `…/requests/{id}/approve`, `/reject`, `/cancel`, `/receive`, `/settle`, `/link-product`, `/archive`, `/restore` | `Approve`, `Approve`, `Cancel`/`CancelAny`, `Receive`, `Settle`, `LinkProduct`, `Archive` | 200 (idempotent), 400 `VALIDATION`, 403, 404, 422 `TRANSITION_INTERDITE` `DEMANDE_VERROUILLEE` |
| POST | `/sites/{siteId}/requests/batch/approve` (≤ 50), `/batch/archive` (≤ 100) | `Approve` / `Archive` | 200 résultats par demande |
| POST / PUT | `…/requests/{id}/order` ; POST `…/order/cancel` | `Orders.Create` / `Update` / `Cancel` | 201, 200, 404, 409, 422 `COMMANDE_EXISTANTE` `TRANSITION_INTERDITE` `FOURNISSEUR_INACTIF` |
| GET / POST / PUT | `/sites/{siteId}/deliveries[/{id}]` | `Deliveries.View` / `Create` / `Update` | 200, 201, 400 `DATE_INVALIDE`, 404, 409, 422 `UNITES_INCOMPATIBLES` `PRODUIT_DIFFERENT` `UNITE_OBLIGATOIRE` `QUANTITE_*` |
| POST | `…/deliveries/{id}/cancel`, `/attach` | `Deliveries.Update` / `Attach` | 200, 404, 422 `DEMANDE_NON_OUVERTE` `LIVRAISON_DEJA_RATTACHEE` `PRODUIT_DIFFERENT` `UNITES_INCOMPATIBLES` |
| POST / PUT / GET | `…/deliveries/{id}/photos`, `/sites/{siteId}/photos/{id}/content` | `DeliveryPhotos.Create` / `View` | 201, 200, 404, 409 `PHOTO_DEJA_ENVOYEE`, 413 `FICHIER_TROP_GROS`, 415 `TYPE_FICHIER_REFUSE`, 422 `PHOTOS_TROP_NOMBREUSES` |
| GET | `/sites/{siteId}/follow-up` | `Requests.View` | 200 compteurs, totaux, montants (avec `Prices.View`) |
| GET / POST | `/sync/changes`, `/sync/push` (étendus) | authentifié | voir « Synchronisation » |
**Nouveaux codes d'erreur (17)** dans `docs/api/codes-erreur.md` : `DEMANDE_VERROUILLEE`, `DEMANDE_NON_OUVERTE`, `COMMANDE_EXISTANTE`, `PRODUIT_DIFFERENT`, `QUANTITE_ENTIERE_REQUISE`, `UNITE_NON_AUTORISEE`, `MASSE_SAC_OBLIGATOIRE`, `PRODUIT_EXISTANT`, `FOURNISSEUR_EXISTANT`, `PRODUIT_INACTIF`, `FOURNISSEUR_INACTIF`, `ZONE_HORS_CHANTIER`, `LIVRAISON_DEJA_RATTACHEE`, `PHOTOS_TROP_NOMBREUSES`, `PHOTO_DEJA_ENVOYEE`, `FICHIER_TROP_GROS`, `TYPE_FICHIER_REFUSE`. Codes existants désormais utilisés : `UNITE_OBLIGATOIRE`, `UNITES_INCOMPATIBLES`, `TRANSITION_INTERDITE`, `QUANTITE_INVALIDE`, `DATE_INVALIDE`, `CHANTIER_ARCHIVE`, `INTERDIT`, `INTROUVABLE`, `CONFLIT_VERSION`.
**Autorisations** : catalogue de 24 permissions et matrice par rôle dans le contrat (ADR 0012) ; le rôle décide de l'action, l'affectation du périmètre, et deux règles de ressource s'ajoutent (« la sienne seulement » pour `Requests.Update` et `Requests.Cancel`).
**Champs réservés** : objet `commercial` (prix, montant, valeur reçue, n° de bon de commande) absent sans `Prices.View` et **absent de toute synchronisation** ; `phone` du fournisseur absent sans `SupplierPhone.View` et absent de toute synchronisation.

## Synchronisation hors ligne
Protocole : ADR 0009, complété par ADR 0011 (modifications, transitions, journal d'opérations) et ADR 0012 (entités globales, champs réservés).
| Entité | Créée hors ligne ? | Modifiable hors ligne ? | Politique de conflit |
|---|---|---|---|
| `product`, `supplier` (globales) | non (web) | non | lecture seule, le serveur gagne ; pas de pierre tombale (désactivation) ; reçues par tous ; `phone` jamais envoyé |
| `request` | **oui** (`create`, `clientId`) | **oui** : `update`, `transition` (`approve`, `reject`, `cancel`, `receive`) | statuts : le serveur gagne ; champs : trois valeurs, tout ou rien, première arrivée retenue ; **validée pendant l'édition hors ligne** : `conflict` + `DEMANDE_VERROUILLEE` + état du serveur ; annulée, refusée ou commandée : `conflict` + `TRANSITION_INTERDITE` |
| commande (incorporée à `request`) | non | non | en ligne ; `PUT` strict avec `version` |
| `delivery` | **oui** | **oui** : `update`, `transition` `cancel` | création jamais refusée à cause du statut de la demande (fait de chantier : non rattachée, motif) ; livraison avant commande **retenue** ; correction : trois valeurs par champ ; demande `Received` : `conflict` + `DEMANDE_NON_OUVERTE` |
| `photo` | **oui** (métadonnées ; binaire par `PUT`, un fichier à la fois) | non | ajout seul, idempotent ; aucune ligne pour un utilisateur sans `DeliveryPhotos.View` |
**Serveur** : `SyncChange.siteId` nullable ; sources `ProductSyncSource`, `SupplierSyncSource`, `RequestSyncSource`, `DeliverySyncSource`, `PhotoSyncSource` ; handlers `request`, `delivery`, `photo` ; `SyncOperationLog` ; `SyncTouch.TouchedEntityTypes` complété (`MaterialRequest`, `MaterialOrder`, `Delivery`, `Photo` : exigé par le test d'architecture) et le SQL de « toucher » rendu **générique** (liste de tables tirée du modèle EF) pour ne pas multiplier les cas ; résultat de push `conflict` enrichi de `code` et `conflictFields`.
**Mobile** : voir M1 à M3 et M9. Rappels : écriture locale + opération d'envoi dans **une** transaction Drift ; création hors ligne = ligne locale « numéro en attente » ; statuts affichés par le téléphone = **provisoires**, marqués « à confirmer » ; le serveur remplace sans intervention ; une livraison saisie pour une demande encore en attente d'envoi la désigne par `requestClientId`.
**Cas d'école du lot** (tests de bout en bout) : trois jours sans réseau, 20 demandes et 5 livraisons (CA-MAT-010.1) ; demande modifiée (300 → 400 sacs) puis validée entre-temps (CA-MAT-010.2) ; deux dates de besoin différentes (CA-MAT-010.4) ; livraison pour une demande annulée (CA-MAT-010.6) ; livraison avant commande (CA-MAT-010.7).

## Interfaces
**Web** (menu « Approvisionnement » et « Catalogue » ; routes `/materials/*`, `/catalog/*`) :
- **Demandes** : tableau paginé (numéro, chantier, produit, quantité **avec unité**, zone, pour le, urgence et statut en icône **et** texte, retard) ; filtres chantier, vue, urgence, produit, zone, fournisseur, période ; recherche ; tri par colonne ; tiroir de **détail** (historique, commande, livraisons, reste et écart, actions selon les permissions) ; formulaire de création et de modification (avertissement de doublon, de date passée, équivalence sac ↔ T) ; annulation avec motif.
- **À valider** (conducteur) : file transversale, valider / refuser / valider avec une autre quantité, **sélection de 50 demandes au plus** : résultats listés demande par demande (CA-MAT-003.9).
- **À commander** (Achats) : file, totaux par produit et par unité (400 sacs = 20 T), formulaire de commande (fournisseur par défaut = dernier du produit, date prévue, prix HT avec l'unité à côté, montant calculé par le serveur affiché après enregistrement), modifier, annuler la commande, solder.
- **Livraisons** : liste (filtres Non rattachées, À compléter / BL manquant, Avec réserve), formulaire depuis une commande attendue ou libre, correction, annulation, rattachement, photos (JPEG, réduction canvas, 5 au plus, affichage par URL authentifiée), réceptionner depuis le détail.
- **Suivi** : cinq vues avec compteurs (À valider, À commander, Attendues, En retard, À réceptionner), montants du chantier selon le rôle, archivage et restauration (lot de 100).
- **Catalogue** : produits (unités autorisées, unité par défaut, masse du sac, confirmation avant de la changer) et fournisseurs (téléphone selon le rôle) ; désactiver au lieu de supprimer.
- Actions **absentes** (non grisées) sans la permission ; FR et AR (RTL, quantités, numéros, dates en LTR) ; erreurs traduites par `code` ; aucun texte en dur.
**Mobile** (nouvelle fonctionnalité `features/materials/`) :
- **Accueil du chantier** : tuiles *Demandes*, *À recevoir*, *À réceptionner*, *À valider* (selon les permissions), bouton « + Demande » ; chantier courant en en-tête (socle).
- **Nouvelle demande** (4 gestes) : tuiles des 6 produits les plus demandés puis recherche tolérante (accents, abréviations, une faute) répondant en moins de 2 s hors ligne ; quantité au clavier numérique avec équivalence (« 300 sacs = 15 T ») ; unité en pastilles (préremplie, jamais libre) ; zone (3 dernières zones puis sélecteur du socle) ; date en pastilles (Demain · +3 j · Semaine prochaine · Autre date) ; urgence en pastilles ; remarque ; « Envoyer » ; avertissement non bloquant de date passée et de doublon ; « Ajouter un autre matériau » ; boutons de 56 dp, texte ≥ 16 sp.
- **Demandes** (À suivre, Terminées, Refusées et annulées, Archivées ; « Mes demandes » par défaut pour ChefEquipe), recherche, détail avec historique, commande (fournisseur, date prévue, jamais de prix), livraisons liées, reste et écart, « Appeler le fournisseur » (en ligne, `SupplierPhone.View`), corriger, annuler avec motif.
- **À valider** (conducteur) : Valider (2 gestes), Refuser (motif), Valider avec une autre quantité ; marque « Validation en attente d'envoi ».
- **À recevoir** → **Recevoir** (3 gestes, 6 avec photo) : quantité préremplie = reste, unité de la commande, annonce en toutes lettres (partielle, complète, surplus), unité convertible, conformité et réserve, date par calendrier, avertissement de BL en double ; **Livraison sans demande** (« Non rattachée ») ; **Livraisons** (liste, détail, corriger, annuler, photos) ; **À réceptionner** (1 geste).
- **À vérifier** (conflits) : version de l'utilisateur et version du serveur côte à côte ; « Garder la version du serveur » ; « Créer une nouvelle demande avec mes valeurs » ou « Refaire ma modification » (préremplie) ; rien n'est supprimé sans choix ; motifs traduits par `code`.
- Hors ligne : tout ce qui précède **sauf** commander (M10, en ligne), solder, rattacher, archiver et gérer le catalogue ; bandeau « Données du JJ/MM/AAAA HH:MM » ; statuts « à confirmer » ; photos en attente dans « Envois en attente ».

## Critères d'acceptation techniques
Les CA de `docs/metier/demandes-materiaux-livraisons.md` restent la référence ; les CT ci-dessous sont les critères **vérifiables par test** (colonne de droite : CA couverts).
| # | Critère | CA couverts |
|---|---|---|
| CT-MAT-01 | Tous les vecteurs de `docs/api/vecteurs-materiaux.json` passent **en .NET, en Dart et en TypeScript** ; `AwayFromZero` partout (613,125 → 613,13) ; aucun `MidpointRounding` par défaut | 001.3, 001.6, 003.3, 005.3, 006.4, 008.1, 008.6, 008.7, 013.2, 013.3, 013.5 |
| CT-MAT-02 | Création de demande : numéro `DEM-nnn` serveur après contrôle du `clientId` ; renvoi = une demande et **un** numéro ; 60 créations parallèles sans doublon ni trou ; double appui = une seule | 001.1, 001.8, 010.9 |
| CT-MAT-03 | Validations : unité obligatoire (liste, jamais libre), quantité > 0, 3 décimales, entiers pour `sac` et `u`, date complète (`../12/2026`, `31/11/2026` refusées), date passée acceptée, zone d'un autre chantier refusée, chantier archivé refusé, produit libre 3 à 100 caractères, produit désactivé refusé | 001.5, 001.6, 001.7, 001.11, 001.14 |
| CT-MAT-04 | Doublon possible calculé à la création (même chantier, produit, zone, demande ouverte), jamais bloquant ; idem pour un n° de BL | 001.9, 006.9 |
| CT-MAT-05 | **Table de transitions** `(statut, action, rôle)` testée en entier : permis, `TRANSITION_INTERDITE` ou `INTERDIT` ; idempotence (« Déjà validée », deux annulations = un motif) ; motif obligatoire ; historique (qui, quand serveur, ancien → nouveau, motif) | 003.1 à 003.7, 004.4, 004.5, 004.7, 008.3, 008.4, 014.1 à 014.3, 014.6 |
| CT-MAT-06 | Verrouillage : produit, quantité, unité figés après validation (`DEMANDE_VERROUILLEE`), date / urgence / remarque modifiables jusqu'à `Delivered` avec `UpdateAny` ; ChefEquipe ne modifie ni n'annule la demande d'un collègue ; historique « ancienne → nouvelle valeur » | 004.1 à 004.3, 004.8 |
| CT-MAT-07 | Commande : fournisseur obligatoire, prix > 0 facultatif, dates complètes, `COMMANDE_EXISTANTE` (autre `clientId`) / 200 (même `clientId`), montant 234 000,00, modification du prix recalcule montant et valeur reçue, annulation refusée avec livraison | 005.2 à 005.7, 005.9 |
| CT-MAT-08 | Livraison : partielle, complète, surplus, tolérance 0 % puis 1 %, conversions sac ↔ kg ↔ T, `UNITES_INCOMPATIBLES` (sable m³ / T), date future refusée, date antérieure à la demande acceptée, réserve, numéro `LIV-nnn` serveur | 006.1 à 006.8 |
| CT-MAT-09 | **Recalcul dans les deux sens** (annuler LIV-008 ramène DEM-005 à `PartiallyDelivered`, 400 sacs sur 600) ; cache = recalcul depuis zéro sur séquences aléatoires ; `Received` ne se recalcule plus | 008.1, 008.2, 012.3, 012.4 |
| CT-MAT-10 | Fait de chantier : livraison jamais refusée à cause du statut (non rattachée avec motif) ; livraison avant commande **retenue** puis prise en compte à la commande (deux événements) ; rattachement : `PRODUIT_DIFFERENT`, `UNITES_INCOMPATIBLES`, `DEMANDE_NON_OUVERTE`, `LIVRAISON_DEJA_RATTACHEE` | 008.10, 010.6, 010.7, 011.1 à 011.6 |
| CT-MAT-11 | Correction et annulation de livraison : historique, numéro inchangé, hors totaux, demande `Received` refusée | 012.1 à 012.7 |
| CT-MAT-12 | **Prix absents** (objet `commercial`, événements sensibles, n° de bon de commande) des réponses REST, de la synchronisation, du push, des erreurs et des journaux pour ChefChantier, ChefEquipe (et Direction pour l'écriture) ; test qui parcourt **toutes** les routes et la synchro avec ces jetons | 005.12, 009.3, 010.13 |
| CT-MAT-13 | Téléphone fournisseur : présent pour Admin, Achats, Conducteur, ChefChantier ; absent pour ChefEquipe et Direction ; **jamais** dans la synchronisation, les journaux ni les erreurs | 009.4 |
| CT-MAT-14 | Isolation : chantier non affecté = 404 `INTROUVABLE` **identique** à un chantier inexistant sur demandes, commandes, livraisons, **photos**, listes, recherche, lot et listes transversales ; zone ou demande d'un autre chantier refusée ; test d'architecture : toute route `{siteId}` porte `[SiteScoped]`, toute route transversale est listée et filtrée par chantiers visibles | 001.14, 002.6, 002.8, 003.8, 004.9, 005.10, 006.11, 007.9, 009.2, 011.7, 012.8, 013.8, 014.7 |
| CT-MAT-15 | Matrice des permissions : pour chacun des 6 rôles, chaque action du tableau « Droits par rôle » passe ou renvoie `INTERDIT` sans rien écrire | 001.13, 003.7, 004.8, 005.9, 006.10, 008.9, 009.1, 009.6, 011.7, 012.8, 014.7, 015.8 |
| CT-MAT-16 | Catalogue : unités autorisées et unité par défaut, `MASSE_SAC_OBLIGATOIRE`, unicité insensible à la casse et aux accents, désactivation (jamais de suppression), changement de masse du sac recalcule les demandes ouvertes (quantités saisies inchangées) | 015.1 à 015.7, 015.9 |
| CT-MAT-17 | Synchronisation : `product` et `supplier` reçus par tous sans chantier ; `request`, `delivery`, `photo` selon les chantiers affectés ; pas de ligne `photo` sans `DeliveryPhotos.View` ; nouvelle affectation renvoie les lignes anciennes ; retrait coupe l'accès ; `siteId` nullable dans l'OpenAPI et les deux clients générés | 010.8, 015.10 |
| CT-MAT-18 | Push `update` et `transition` : journal d'opérations (un renvoi = même résultat, jamais de faux conflit) ; **demande validée pendant l'édition hors ligne** = `conflict` + état du serveur, rien d'appliqué ; annulée / refusée / commandée idem ; même champ modifié deux fois = première retenue ; champs différents = les deux appliqués ; ordre création → modification → annulation | 003.5, 003.6, 008.8, 010.2 à 010.5, 010.10, 012.5 |
| CT-MAT-19 | Photos : métadonnées idempotentes, `PUT` idempotent (même contenu), octets magiques JPEG, 5 photos, taille, EXIF et GPS retirés (fixture avec GPS), chemin aléatoire hors du dossier web, lecture authentifiée et autorisée, photo d'un autre chantier = 404 ; fichier jamais perdu si l'envoi échoue (mobile) | 007.1 à 007.5, 007.8 à 007.10 |
| CT-MAT-20 | Web : FR et AR (RTL), aucun texte en dur, parité des clés avec `codes-erreur.md`, actions absentes selon les permissions, lot de 50 avec résultats par demande, jamais une quantité sans unité | 001.15, 002.10, 003.9, 009.1, 013.1 à 013.4, 014.8, 015.11 |
| CT-MAT-21 | Mobile hors ligne : demande, validation, refus, livraison, correction, annulation, réception **sans réseau** ; « numéro en attente » ; statut « à confirmer » remplacé par la valeur du serveur ; liste et détail < 2 s ; recherche de 300 produits < 2 s ; 4 gestes pour le cas nominal | 001.2, 001.4, 001.12, 002.3, 006.2, 006.7, 010.1, 010.11, 010.12, 013.7 |
| CT-MAT-22 | Mobile « À vérifier » : deux versions côte à côte, deux choix, rien supprimé sans décision ; file de 200 saisies par lots dans l'ordre ; **inspection de la base Drift : aucun prix, aucun téléphone de fournisseur** | 003.5, 010.2, 010.3, 010.12, 010.13 |
| CT-MAT-23 | Suivi : cinq vues et compteurs, totaux par produit et unité sans mélange (400 sacs = 20 T, 2,5 T, 24 m³ et 10 T séparés), retard 2 j / 0 / 5 j, montants selon le rôle, 1 000 demandes < 2 s ; archivage des seules demandes closes, lot de 100 | 002.4, 013.1 à 013.6, 014.1 à 014.8 |
| CT-MAT-24 | Démonstration : 13 produits, 5 fournisseurs, 12 demandes, 10 livraisons sur `CH-ECO-UV18`, 1 demande sur `CH-LOG-OL40` ; répétable sans doublon ni trou ; cas (a) à (g) de CA-MAT-016.4 ; ciment livré 110 T = 2 200 sacs | 016.1 à 016.4 |
| CT-MAT-25 | Journaux : aucune donnée personnelle ni prix ni téléphone, parcours complet capturé (serveur, web, mobile) | 009.4 |
| CT-MAT-26 | OpenAPI régénéré et versionné ; la CI échoue si le fichier ou un client généré dérive ; schémas `*SyncData` présents ; vecteurs lus depuis un seul fichier | : |

## Découpage des tâches
Un agent par tâche ; les tâches d'un même agent sont **séquentielles**. Préfixe `MAT-` implicite dans ce plan (`B1` = `MAT-B1`). Taille : S ≤ une demi-journée d'agent, M ≈ une journée, L > une journée.
**34 tâches : 11 backend, 7 web, 10 mobile, 3 QA, 2 revue, 1 devops.**
| # | Agent | Tâche | Dépend de | Tr. | Taille | CT / critères couverts |
|---|---|---|---|---|---|---|
| B1 | backend-dotnet | Domaine pur : unités, conversions, statut calculé, agrégats, arrondi, retard, vecteurs | : | A | M | CT-01 |
| B2 | backend-dotnet | Persistance A, permissions, codes d'erreur, options, journal d'opérations | B1 | A | L | CT-14, CT-15 |
| B3 | backend-dotnet | Catalogue : produits, fournisseurs, réglages | B2 | A | M | CT-13, CT-15, CT-16 |
| B4 | backend-dotnet | Demandes : REST complet, événements, doublons, listes, lot, archivage | B3 | A | L | CT-02 à 06, 14, 15 |
| B9 | backend-dotnet | Synchronisation A : entités globales, `request`, `update` / `transition`, journal, toucher | B4 | A | L | CT-17, CT-18 |
| B5 | backend-dotnet | Commandes, entités livraison et photo, recalcul, projection commerciale | B9 | B | L | CT-07, 09, 12 |
| B6 | backend-dotnet | Livraisons : REST, rattachement, solde, recalcul par masse du sac | B5 | B | L | CT-08 à 11 |
| B7 | backend-dotnet | Photos du bon : stockage, EXIF, upload, lecture | B6 | B | M | CT-19 |
| B8 | backend-dotnet | Suivi : compteurs, totaux, retards, montants | B6 | B | M | CT-23 |
| B10 | backend-dotnet | Synchronisation B : `delivery`, `photo`, commande incorporée, handlers | B7 | B | L | CT-17, 18, 19 |
| B11 | backend-dotnet | Démonstration, contrat final, vérification des générateurs | B8, B10 | B | M | CT-24, 26 |
| W1 | frontend-react | Fondations web : client API, permissions, i18n, formateurs, miroir de calcul | B4 (OpenAPI A) | A | M | CT-01, 20 |
| W2 | frontend-react | Catalogue : produits et fournisseurs | W1, B3 | A | M | CT-16, 20 |
| W3 | frontend-react | Demandes : liste, détail, formulaire, annulation | W1, B4 | A | L | CT-03 à 06, 20 |
| W4 | frontend-react | À valider : valider, refuser, ajuster, lot de 50 | W3 | A | M | CT-05, 20 |
| W5 | frontend-react | À commander : commande, modification, annulation, solde | W4, B5, B6 | B | L | CT-07, 20 |
| W6 | frontend-react | Livraisons : liste, formulaire, correction, rattachement, photos, réception | W5, B7 | B | L | CT-08 à 11, 19, 20 |
| W7 | frontend-react | Suivi : cinq vues, totaux, montants, archivage | W6, B8 | B | M | CT-23 |
| M1 | mobile-flutter | Base locale, miroir de calcul, recherche de produits | : (contrat) | A | L | CT-01, 21, 22 |
| M2 | mobile-flutter | Synchronisation en lecture : décodeurs, dépôts, réglages | M1, B9 | A | L | CT-17, 21 |
| M3 | mobile-flutter | Envoi : opérations, résultats, surcouche provisoire, références par `clientId` | M2 | A | L | CT-18, 21 |
| M4 | mobile-flutter | Nouvelle demande, Mes demandes, détail, corriger, annuler | M3 | A | L | CT-02 à 06, 21 |
| M5 | mobile-flutter | À valider : valider, refuser, ajuster | M4 | A | M | CT-05, 21 |
| M6 | mobile-flutter | À recevoir, recevoir une livraison, À réceptionner, accueil du chantier, appel au fournisseur | M5, B10 | B | L | CT-08, 09, 13, 21 |
| M7 | mobile-flutter | Livraisons : liste, détail, non rattachées, corriger, annuler | M6 | B | M | CT-10, 11, 21 |
| M8 | mobile-flutter | Photos du bon : prise, fichier local, envoi, affichage | M7, B10 | B | L | CT-19, 21 |
| M9 | mobile-flutter | « À vérifier » : conflits côte à côte, deux choix | M5 (demandes), M8 | A→B | L | CT-18, 22 |
| M10 | mobile-flutter | Commander en ligne (**optionnel**) | M7, B5, B6 | B | M | CT-07 |
| D1 | devops-ci | Stockage des photos, limite de corps, CI, vecteurs | B7 | B | S | CT-19, 26 |
| Q1 | qa-tests | QA tranche A : backend, sync, web, mobile des demandes | B9, W4, M5 | A | L | CT-01 à 06, 14 à 18, 20 à 22 |
| Q2 | qa-tests | QA tranche B : backend, web, contrat, démonstration | B11, W7, D1 | B | L | CT-07 à 12, 19, 23 à 26 |
| Q3 | qa-tests | QA mobile tranche B, scénarios hors ligne de bout en bout | Q2, M9 | B | L | CT-18, 19, 21, 22 |
| R1 | revue-securite-perf | Revue sécurité et performance, tranche A | Q1 | A | M | CT-12 à 14, 17 |
| R2 | revue-securite-perf | Revue sécurité et performance, tranche B (prix, photos, performances) | Q3 | B | L | CT-12, 19, 21, 23, 25 |
M9 est livrée avec la tranche A pour les conflits de **demandes** (CA-MAT-010.2 à 010.5, 003.5) ; ses cas **livraison** (CA-MAT-008.8, 010.6) s'ajoutent après M8 (même tâche, deux passes).

### Avancement du backend (2026-11-25)
| Tâche | État | Remarques |
|---|---|---|
| B1 | **Fait** | `Core/Materials/` + vecteurs lus par `Tests/Chantier.UnitTests/Materials/` (lien vers `docs/api/vecteurs-materiaux.json`) |
| B2 | **Fait** | migrations `AddMaterialRequests` et `AddSyncOperationLogConflictFields` ; 28 permissions, 17 codes d'erreur ; `AddMaterialRequests` a été appliquée à la base de dev avant l'ajout de la colonne `ConflictFields` (d'où la seconde migration) |
| B3 | **Fait** | catalogue et réglages |
| B4 | **Fait** | demandes REST ; écarts : voir « Écarts et précisions décidés par le backend » du contrat |
| B9 | **Fait** | `product`, `supplier`, `request` ; `SyncTouch` généralisé (tables tirées du modèle EF) |
| B5 | **Fait** | `MaterialOrder`, `Delivery`, `Photo` ; migration `AddOrdersDeliveriesPhotos` (création de 3 tables, aucune perte) ; `RequestRecalculator`, `RequestEventWriter`, `CommercialProjection` ; la commande n'est pas `IHasClientId` (écart 11 du contrat) |
| B6 | **Fait** | livraisons REST, rattachement, solde (garde « au moins une livraison »), fait de chantier, vue `late` |
| B7 | **Fait** | `FileSystemPhotoStorage`, `JpegMetadataStripper` (sans bibliothèque), `PhotoService` ; `Storage:PhotosRoot` |
| B8 | **Fait** | `FollowUpService`, `GET /follow-up`, vue `late`, filtre `supplierId` |
| B10 | **Fait** | sources `delivery` et `photo`, handlers `delivery` (`create`, `update`, `transition`), `photo` (`create`), `order` dans `RequestSyncData` |
| B11 | **Fait** | `MaterialsDemoSeeder` (amorçage direct, auteur `SystemActor`, idempotent, jamais d'écrasement) ; générateurs vérifiés : web identique, mobile non régénéré depuis B5 à B10, défauts de forme de `Quantity` (écarts 23 et 24 du contrat) |

### Avancement du web (2026-11-25)
| Tâche | État | Remarques |
|---|---|---|
| W1 | **Fait** | client régénéré, étiquettes de cache, `can("Requests.Approve")` (liste brute des permissions), espaces i18n `materials` et `catalog` FR et AR (17 codes d'erreur), `QuantityText` / `useQuantityFormatter` / `formatPercent`, miroir `BigInt` testé par `vecteurs-materiaux.json`, menu et routes gardées |
| W2 | **Fait** | `features/catalog/` : produits et fournisseurs ; téléphone selon `SupplierPhone.View` |
| W3 | **Fait** | `features/materials/` : liste (vues, filtres, tri, pagination dans l'URL), tiroir de détail, création, modification, annulation avec motif, rattachement d'un produit, archivage et restauration (lot de 100) |
| W4 | **Fait** | « À valider » : valider, refuser, autre quantité, lot de 50 regroupé par chantier avec résultats par demande |
| W5 | **Fait** | `/materials/to-order` (file, totaux par produit et par unité du chantier), formulaire de commande (`clientId` posé à l'ouverture, prix par unité seulement avec `Prices.View`, montant lu dans la réponse), modifier, annuler la commande, solder, réceptionner depuis la fiche de la demande |
| W6 | **Fait** | `/materials/deliveries` : liste par chantier (onglets Non rattachées, À compléter, Avec réserve ; filtres dans l'URL), formulaire (depuis une demande ou libre, annonce partielle / complète / surplus, conversion sac ↔ kg ↔ T), correction, annulation, rattachement, photos du bon (JPEG réduit à 1 600 px, 5 au plus, lecture par la session) ; proposition de réceptionner quand la livraison complète la demande |
| W7 | **Fait** | `/materials/follow-up` : cinq vues et compteurs du serveur, totaux, montants si `commercial` ; archivage et restauration par les lots de 100 de W3 (liens). Revue R2-06 corrigée (annuaire des zones groupé), R2-09 côté affichage (avertissement « visible du terrain, aucun prix ») |

### Avancement du mobile (2026-11-25)
| Tâche | État | Remarques |
|---|---|---|
| M1 | **Fait** | base v2, domaine de calcul, recherche, ARB |
| M2 | **Fait** | client régénéré (deux fois : le backend a complété l'OpenAPI en cours de lot, B5 à B8, sans écran mobile) ; décodeurs `product`, `supplier`, `request` ; réglages ; `delivery` et `photo` ignorés jusqu'à M6 et M8 |
| M3 | **Fait** | opérations `request` (`create`, `update`, `transition`), résultats `applied` / `duplicate` / `conflict` / `rejected`, surcouche provisoire « à confirmer », références `requestClientId` et `zoneClientId` |
| M4 | **Fait** | Nouvelle demande (4 gestes), Demandes, détail, corriger (sauf le produit : annuler puis recréer), annuler avec motif |
| M5 | **Fait** | À valider : valider, refuser (motif), autre quantité |
| M9 (passe 1) | **Fait** | « À vérifier » pour les demandes : deux versions côte à côte, garder le serveur, refaire ma modification, créer une nouvelle demande, corriger ma saisie |
| M6 | **Fait** | À recevoir (date prévue la plus proche, recherche, filtres Aujourd'hui / Cette semaine / En retard), Recevoir (quantité = reste, unité de la commande, annonce partielle / complète / surplus, conformité et réserve, doublon de BL), À réceptionner (1 geste), « DEM-014 est livrée. Réceptionner maintenant ? », tuiles de l'accueil du chantier, « Appeler le fournisseur » (`url_launcher`, numéro lu en ligne, jamais stocké) |
| M7 | **Fait** | Livraisons (Toutes, Non rattachées, Avec réserve, BL manquant), détail, corriger, annuler avec motif, livraison sans demande. Rattacher : message « réseau nécessaire » seulement (l'action reste sur le web, pas d'écran mobile) |
| M8 | **Fait** | `image_picker` (caméra, sans permission), `path_provider` (dossier privé par propriétaire), SHA-256 dans un isolat, 5 photos, « Reprendre / Garder », envoi un fichier à la fois après le push des métadonnées, reprise après coupure, 409 `CONFLIT_VERSION` rejoué (R2-04), affichage à la demande en mémoire |
| M9 (passe 2) | **Fait** | « À vérifier » pour les livraisons (annulée entre-temps, demande réceptionnée, correction concurrente, création refusée) et les photos refusées ; « La demande n'est plus complète » pour une réception en conflit |
| R2-07 | **Fait** | liste légère (`history_json` non lu) et émissions regroupées (300 ms) ; non mesuré sur appareil (pas d'émulateur ni de licences Android) |
| Ordre du pull entre pages (écart 26) | **Fait** | clés étrangères suspendues le temps d'une page, lignes sans chantier retirées à la fin du pull ; test `test/features/sites/pull_order_test.dart` |
| D-3 (QA) | **Fait** | en-têtes (recherche + pastilles) de Demandes, À recevoir et Livraisons dans la zone défilante, `Wrap` : aucun débordement à 320 dp et police ×2 ; `test/qa/materials_small_screen_large_font_test.dart` vert (18) |
| R3-01 | **Fait** | après un `retry`, les opérations qui visent la création (même lot ou lots suivants) restent en file, ni envoyées ni rejetées ; test d'injection dans `deliveries_sync_test.dart` |
| R3-05 | **Fait** | rechargement complet sur `resetRequired` ou après `FULL_RELOAD_AFTER_DAYS` (60) jours sans synchro réussie, saisies en attente conservées |
| M10 | Hors périmètre | « Commander » mobile, optionnel |

### B1 : Domaine pur (backend-dotnet)
- Créer `Core/Chantier.Core/Materials/{MeasureUnit,Quantity,UnitConverter,QuantityRules,RequestStatusCalculator,QuantityAggregator,Money,OverdueCalculator,AlgeriaDate,MaterialsOptions,ReasonLists,NameNormalizer}.cs` selon ADR 0014. `MeasureUnit` : codes `u ml m2 m3 kg t sac l h j pj ft`, sérialisés par `[JsonStringEnumMemberName]`, drapeau « entiers seulement » pour `sac` et `u`. `RequestStatusCalculator.Compute(...)` pur (statut, `Qr`, reste, écart, écart %, drapeau soldé, tolérance). `AlgeriaDate.Today(TimeProvider)` (fuseau `Africa/Algiers`, réutiliser l'existant de `JsonDefaults` si possible). `NameNormalizer` (minuscules, sans accents ni diacritiques arabes, espaces compactés) partagé avec la recherche.
- `MaterialsOptions` lié à `appsettings` `Materials` : `DefaultNeededByDays` (3), `DeliveryTolerancePercent` (0), `MaxPhotosPerDelivery` (5), `NoteMaxLength` (200), `DeliveryNoteMaxLength` (30), `FreeNameMinLength` (3) / `MaxLength` (100), `Reasons` (six listes).
- Tests `Tests/Chantier.UnitTests/Materials/*` pilotés par `docs/api/vecteurs-materiaux.json` (inclus par lien dans le `.csproj`, **pas copié**) : toutes les sections (conversions, règles de quantité, statut, montants, valeur reçue, retard, date par défaut, agrégats) ; test de chaîne : aucun `MidpointRounding.ToEven` implicite (`Math.Round(decimal)` sans mode interdit dans `Chantier.Core.Materials`).
- Fini quand : `dotnet test` vert, couverture des 12 conversions et 11 cas de statut du fichier de vecteurs, aucune dépendance EF ni HTTP dans `Core/Materials` (test d'architecture existant).

### B2 : Persistance, permissions, erreurs (backend-dotnet)
- Entités `Core/Entities/Materials/{Product,Supplier,MaterialRequest,MaterialEvent,RequestStatus,Priority,ProductCategory,MaterialEventType}.cs`, `Core/Entities/Sync/SyncOperationLog.cs` ; configurations `Infrastructure/Persistence/Configurations/{Product,Supplier,MaterialRequest,MaterialEvent,SyncOperationLog}Configuration.cs` ; `ApplicationDbContext` (jeux d'entités, filtre `SoftDelete`) ; migration `AddMaterialRequests` (relue : aucun `DropTable`, `Down` fonctionnel).
- `Core/Identity/PermissionResources.cs`, `Permissions.cs`, `RolePermissionMatrix.cs` : les **24 permissions** du contrat ; `ErrorCodes.cs` + `WebApi/Errors/ErrorCatalog.cs` : les **17 codes** ; `SyncEntities` (`product`, `supplier`, `request`, `delivery`, `photo`) ; `SyncTouch.TouchedEntityTypes` += `MaterialRequest` ; `appsettings.json` section `Materials`.
- Tests : unicités filtrées et `CHECK` produit exclusif, audit, migration sur base vide (montée et descente), **test table de la matrice** (rôle × permission = tableau du contrat), `ErrorCatalogTests` (statut et ligne de `codes-erreur.md`), architecture (`MaterialRequest` est `ISiteScoped`, présent dans `TouchedEntityTypes`).
- Risque : `RolePermissionMatrix` change `permissionsVersion` de tous les rôles : rechargement complet des mobiles au déploiement (attendu, à annoncer).

### B3 : Catalogue et réglages (backend-dotnet)
- `Core/Materials/{IProductService,ISupplierService}.cs`, `Core/DTOs/Materials/*`, `Core/Specifications/Materials/{ProductsSearchSpecification,SuppliersSearchSpecification}.cs`, `Infrastructure/Services/Materials/{ProductService,SupplierService}.cs`, `WebApi/Controllers/Materials/{ProductsController,SuppliersController,MaterialSettingsController}.cs`, `WebApi/Models/Materials/*`.
- Règles : unités autorisées du référentiel (jamais de texte libre), unité par défaut ∈ liste, `MASSE_SAC_OBLIGATOIRE`, masse > 0, unicité normalisée (`PRODUIT_EXISTANT`, `FOURNISSEUR_EXISTANT`), désactivation sans suppression, `phone` format algérien et **omis** sans `SupplierPhone.View`, `productIds` du fournisseur existants, pagination `page/pageSize/totalCount`, recherche `q` insensible aux accents, `GET /settings/materials` (valeurs de `MaterialsOptions`). Le recalcul des demandes ouvertes lors d'un changement de masse du sac est branché en **B6** (test de bout en bout là).
- Tests : validation (matrice d'unités), unicité (casse, accents, espaces), double envoi, rôles (matrice), téléphone par rôle, **téléphone absent des journaux capturés**, 300 produits et 100 fournisseurs listés en < 2 s.

### B4 : Demandes REST (backend-dotnet)
- `Core/Materials/{IRequestService,IRequestEventWriter,IRequestRecalculator}.cs`, `Core/DTOs/Materials/Request*`, `Core/Specifications/Materials/{RequestsVisibleToUserSpecification,RequestsListSpecification,RequestByClientIdSpecification,RequestBySiteAndIdSpecification,OpenRequestsForDuplicateSpecification}.cs`, `Infrastructure/Services/Materials/{RequestService,RequestEventWriter,RequestRecalculator}.cs`, `WebApi/Controllers/Materials/{RequestsController,CrossSiteRequestsController}.cs`, `WebApi/Models/Materials/Request*`.
- `RequestService` : création en **transaction explicite** (vérifier `clientId` → `ISiteNumbering.NextAsync(siteId, "DEM")` → écrire → événement) sur le modèle de `ZoneService` (résolution de course par l'index unique) ; actions `approve`, `reject`, `cancel`, `receive`, `settle` (garde de statut seulement ici), `link-product`, `archive`, `restore`, lots `batch/approve` et `batch/archive` (**chaque demande dans sa propre transaction**, résultats par demande, 50 et 100 au plus) ; règles de ressource « la sienne » ; verrouillage des champs ; doublon possible ; `overdueDays` ; vues de liste (`view`) sauf `late` (B8) ; recherche `q` (numéro, produit, remarque) ; liste transversale limitée aux chantiers visibles (`AllSites.View` pour Admin). `RequestRecalculator` : version B4 sans commandes (statuts `Requested` à `Validated` seulement) ; complété en B5.
- Le modèle de requête porte une unité **nullable** : une quantité sans unité doit donner 422 `UNITE_OBLIGATOIRE` (et non 400 de liaison de modèle) ; idem pour une livraison. Réutiliser `ISiteAccess`, `SiteScopedAttribute`, `RepositoryCommon`, le format `PagedResult` de `SitesController`. **Étendre** `ControllerArchitectureTests` : liste blanche explicite des routes sans `{siteId}` (`/requests`, `/products`, `/suppliers`, `/settings/materials`) + test d'isolation de la liste transversale.
- Tests : CT-02 à CT-06, CT-14, CT-15 ; table de transitions complète ; 60 créations parallèles ; deux conducteurs qui valident la même demande (une validation, une réponse « déjà validée ») ; quantités d'ajustement dans l'historique ; accents et casse de `q` ; 500 demandes, 20 premières en < 2 s.

### B9 : Synchronisation A (backend-dotnet)
- `Core/Sync/SyncContracts.cs` : `SyncChangeRow.SiteId`, `SyncChange.SiteId`, `SyncDeletion.SiteId` **nullables** ; `SyncPushResult.Conflict(clientId, current, code, conflictFields)` ; `SyncPullService` : sources globales exemptées du filtre de chantier (nouveau drapeau `IsGlobal` sur `ISyncSource` ou deux interfaces) ; `Infrastructure/Sync/{ProductSyncSource,SupplierSyncSource,RequestSyncSource,SyncOperationLogService,FieldMergeEvaluator,RequestSyncPushHandler}.cs`.
- `RequestSyncSource` : lignes des chantiers visibles, `RequestSyncData` (sans `commercial`, historique sans événement sensible, `order` null jusqu'en B10) ; `SupplierSyncSource` **sans `phone`** ; `ProductSyncSource` ; pas de pierre tombale.
- `RequestSyncPushHandler` : `create` (idempotent par l'index), `update` (trois valeurs par champ via `FieldMergeEvaluator`, tout ou rien), `transition` (`approve`, `reject`, `cancel`, `receive`), `requestId` ou `requestClientId`, `zoneClientId`, journal d'opérations écrit **dans la transaction**, `conflict` avec `code` et `conflictFields`, `rejected` pour droit, validation, chantier archivé ou non affecté ; **réutilise `RequestService`** (aucune règle dupliquée).
- `SyncTouch` : `TouchedEntityTypes` complété et SQL de « toucher » **généralisé** (tables tirées du modèle EF, `READPAST`, lots de 500) avec test de non-interblocage conservé.
- `ChantierSchemaTransformer` : schémas `RequestSyncData`, `ProductResponse`, `SupplierSyncData` enregistrés comme composants. Régénérer `docs/api/openapi.json` ; mettre à jour `docs/api/demandes-materiaux-livraisons.md` si un écart est décidé.
- Tests (`Tests/.../Sync/Materials*Tests.cs`) : CT-17, CT-18 ; **cas CA-MAT-010.2** (300 → 400 sacs puis validation : `conflict`, rien appliqué), 010.3, 010.4 (deux dates), 010.5 (champs différents), 003.5 (validation après annulation), renvoi du même `clientId` (journal), ordre création → modification → annulation, chantier retiré, aucun prix ni `phone` dans les lignes reçues par ChefChantier **et** par Achats.

### B5 : Commandes, entités livraison et photo, recalcul (backend-dotnet)
- Entités `MaterialOrder`, `Delivery`, `Photo` (+ énumérations `DeliveryStatus`, `Conformity`, `UnattachedReason`, `PhotoContentStatus`), configurations, migration `AddOrdersDeliveriesPhotos`, `SyncTouch.TouchedEntityTypes` complété.
- `Core/Materials/{IOrderService,CommercialProjection}.cs`, `Infrastructure/Services/Materials/OrderService.cs`, `WebApi/Controllers/Materials/OrdersController.cs` : création idempotente par `clientId` puis recalcul (deux événements si des livraisons sont retenues), `COMMANDE_EXISTANTE`, fournisseur actif, prix > 0, `Amount` calculé, `plannedAfterNeedDays`, modification (`version`), annulation (refusée si une livraison non annulée existe), événements `Ordered`, `OrderEdited`, `OrderCommercialEdited` (sensible), `OrderCancelled`.
- `RequestRecalculator` **complet** : somme des livraisons non annulées converties, statut dans les deux sens, drapeau soldé, montants, `StatusRecomputed` ; **seul écrivain** des colonnes en cache. `CommercialProjection` : **seul endroit** qui construit l'objet `commercial` (omis sans `Prices.View`).
- Tests : CT-07, CT-09 (dont `RecomputeMatchesStoredTests`), CT-12 sur les réponses de commande ; 234 000,00 ; annuler la commande ; réponse d'un ChefChantier sans `commercial` ni n° de bon de commande ; événement sensible masqué.

### B6 : Livraisons REST (backend-dotnet)
- `Core/Materials/IDeliveryService.cs`, `Infrastructure/Services/Materials/DeliveryService.cs`, `Core/Specifications/Materials/Delivery*Specification.cs`, `WebApi/Controllers/Materials/DeliveriesController.cs` : création (numéro `LIV` dans la transaction, **jamais refusée à cause du statut**, non rattachée avec motif, rattachée et retenue avant commande, produit forcé à celui de la demande, conversion de l'unité, date pas dans le futur, doublon de BL), correction, annulation, rattachement, `settle` complété (garde « au moins une livraison »), recalcul de toutes les demandes ouvertes d'un produit quand sa **masse de sac change** (branché depuis `ProductService`), événements, filtres de liste (`unattached`, `withReserve`, `missingNote`).
- Tests : CT-08 à CT-11 ; DEM-005 → LIV-006/007/008 puis annulation de LIV-008 ; 10 T pour une commande en sacs ; sable m³ / T refusé ; livraison datée du lendemain refusée ; demande `Received` : correction refusée, création non rattachée ; attacher LIV-010 (gravier) à DEM-009 (ciment) : `PRODUIT_DIFFERENT` ; masse du sac 50 → 40 recalcule.

### B7 : Photos du bon (backend-dotnet)
- `Core/Abstractions/IPhotoStorage.cs`, `Infrastructure/Storage/FileSystemPhotoStorage.cs`, `Infrastructure/Imaging/JpegMetadataStripper.cs`, `Core/Materials/IPhotoService.cs`, `Infrastructure/Services/Materials/PhotoService.cs`, `WebApi/Controllers/Materials/PhotosController.cs` (`RequestSizeLimit` propre à la route), options `Storage:PhotosRoot`, `Storage:MaxPhotoBytes`.
- Règles : ADR 0013 (octets magiques, 5 photos, empreinte, EXIF retiré sans réencodage, chemin `<racine>/<siteId>/<AAAA>/<MM>/<guid>.jpg`, protection `..`, écriture temporaire puis déplacement, nettoyage en cas d'échec, lecture autorisée par chantier et permission, `nosniff`).
- Tests : fixture JPEG avec EXIF GPS (GPS absent du fichier servi, image décodable), faux JPEG (415), 6e photo (422), renvoi identique (200), contenu différent (409), 5,1 Mo (413), photo d'un autre chantier (404 identique), ChefEquipe (404), chemin hors racine impossible.

### B8 : Suivi (backend-dotnet)
- `Core/Materials/IFollowUpService.cs`, `Infrastructure/Services/Materials/FollowUpService.cs`, `WebApi/Controllers/Materials/FollowUpController.cs` : compteurs des cinq vues, `toOrderTotals` par `QuantityAggregator`, montants (`commercial`), vue `late` (statut ouvert avec `neededBy` dépassé ou commande attendue en retard) ; index vérifié sur les plans de requête.
- Tests : CT-23 (400 sacs = 20 T, 2,5 T, 24 m³ et 10 T séparés ; retard 2 / 0 / 5 jours ; montants absents pour ChefChantier) ; 1 000 demandes en < 2 s.

### B10 : Synchronisation B (backend-dotnet)
- `Infrastructure/Sync/{DeliverySyncSource,PhotoSyncSource,DeliverySyncPushHandler,PhotoSyncPushHandler}.cs` ; `RequestSyncData.order` rempli (sans `commercial`) ; `DeliverySyncData` sans `commercial`, sans `photos`, sans `missingNote` ; `PhotoSyncSource` filtrée par `DeliveryPhotos.View` ; handlers `delivery` (`create`, `update`, `transition` `cancel`) et `photo` (`create`) **au-dessus de `DeliveryService` et `PhotoService`** ; `requestClientId` introuvable → livraison non rattachée (`RequestMissing`).
- Tests : CT-17 à CT-19 ; CA-MAT-010.6 (livraison pour une demande annulée puis réceptionnée : enregistrée, non rattachée), 010.7 (avant commande : retenue, puis commande : `Ordered` puis `PartiallyDelivered`), 008.8 (réception d'une demande plus complète : `conflict`), correction concurrente d'une livraison, ChefEquipe sans ligne `photo`, aucun prix dans les lignes reçues.

### B11 : Démonstration et contrat final (backend-dotnet)
- `Infrastructure/SeedData/Demo/MaterialsDemoSeeder.cs` (ou extension de `DemoDataSeeder`) : exactement le jeu de `docs/metier/demandes-materiaux-livraisons.md` (« Données de test »), **idempotent**, actif seulement avec `Seed:Demo = true` en Development, créé **par les services du domaine** (numéros `DEM-001…012` et `LIV-001…010` sans trou, historique réel), prix fictifs, une photo fictive sur LIV-006.
- Régénérer `docs/api/openapi.json` ; marquer `docs/api/demandes-materiaux-livraisons.md` « remplacé par le fichier généré » ; **vérifier les générateurs** (`@rtk-query/codegen-openapi`, `swagger_parser`) sur les schémas `*SyncData`, `siteId` nullable et `Quantity` ; noter le résultat dans la tâche.
- Tests : CT-24 (comptes, cas (a) à (g), ciment 110 T = 2 200 sacs, DEM-005 `Delivered`, DEM-011 reste 0,8 T), double chargement, inactif hors Development.

### W1 : Fondations web (frontend-react)
- `npm run generate:api` (client régénéré, commité), tags `REQUESTS`, `DELIVERIES`, `PRODUCTS`, `SUPPLIERS`, `FOLLOW_UP` dans `libs/api-core/src/lib/entitiesTags.config.ts`.
- **Permissions** : `libs/state-store/.../authenticationSlice.ts` et `libs/authentication/src/utilities/resources.ts` ne connaissent que `View/Create/Update/Delete` ; ajouter la liste brute `permissions` au state et `usePermissions().can("Requests.Approve")` (le format Kardinal reste pour `Sites`, `Zones`).
- `libs/i18n` : espaces `materials` et `catalog` FR et AR (statuts, urgences, unités avec pluriels, motifs, vocabulaire du document métier, **17 nouveaux codes d'erreur**, messages d'avertissement), formateurs `formatQuantity` (« 300 sacs », « 15 T », nombre en chiffres 0-9, unité traduite, jamais sans unité), `formatMoney`, `formatOverdue`, miroir `quantityMirror.ts` (**`BigInt` en millièmes**, ADR 0014) testé par `docs/api/vecteurs-materiaux.json` (lu par `fs` dans le test).
- Menu latéral (sections « Approvisionnement » et « Catalogue »), routes `/materials/*`, `/catalog/*` dans `routesMapping.ts` / `navigationRoutes.ts`, gardes par permission.
- Tests : parité FR/AR des clés (dont les 17 codes), vecteurs, formateurs en LTR dans une page RTL, claims.

### W2 à W7 : écrans web (frontend-react)
Chaque tâche suit la structure de `features/sites/` : `components/`, `containers/`, `sections/`, `types/` (schémas Zod), tests `*.spec.tsx` avec MSW ; réutiliser `GenericConfirmDialog`, `GenericEmpty`, `GenericError`, `useApiErrorMessage`, les composants de zone (`ZoneLabel`). Dossiers : `apps/chantier-back-office/src/features/{catalog,materials}/`.
- **W2** : `catalog/` produits (liste, formulaire : unités autorisées, unité par défaut, masse du sac, confirmation avant de la changer, doublon « Existe déjà ») et fournisseurs (téléphone selon `SupplierPhone.View`, produits fournis), désactiver / activer. CA-MAT-015.
- **W3** : `materials/requests/` : liste (filtres, vues, tri, pagination, recherche, retard), tiroir de détail (historique, commande, livraisons, reste et écart), formulaire de création et de modification (produit du catalogue ou « Autre produit », unité en liste, équivalence, avertissement de doublon et de date passée, 409 → recharger), annulation avec motif ; « Rattacher un produit du catalogue » (`Requests.LinkProduct`). CA-MAT-001, 002, 004, 015.7.
- **W4** : `materials/to-approve/` : file transversale, valider / refuser / valider avec une autre quantité, sélection de 50 au plus avec résultats par demande, regroupement des appels par chantier. CA-MAT-003.
- **W5** : `materials/to-order/` : file « À commander » avec totaux par produit et par unité (`toOrderTotals`), formulaire de commande (prix HT par unité, montant renvoyé par le serveur, `COMMANDE_EXISTANTE` → « Déjà commandée »), modifier, annuler, solder (demandes `PartiallyDelivered`). Aucune écriture de montant côté client. CA-MAT-005, 008.5.
- **W6** : `materials/deliveries/` : liste (Non rattachées, À compléter, Avec réserve), formulaire (depuis une commande attendue ou libre, quantité préremplie = reste, annonce partielle / complète / surplus, conversion, calendrier sans futur), correction, annulation, rattachement, photos (sélection JPEG, réduction canvas 1 600 px qualité 0,7, vignettes par URL authentifiée, 5 au plus), « Réceptionner ». CA-MAT-006, 007, 008.3, 011, 012.
- **W7** : `materials/follow-up/` : cinq vues et compteurs, totaux, montants selon `Prices.View`, archiver / restaurer (lot de 100). CA-MAT-013, 014.
- Tests communs : rendu FR et AR (RTL), actions **absentes** selon les permissions des six rôles, aucune quantité sans unité, prix absents pour ChefChantier / ChefEquipe, états vide / chargement / erreur.

### M1 : Base locale et domaine (mobile-flutter)
- `database/tables/{products,suppliers,material_requests,deliveries,delivery_photos,pending_photo_files,app_settings}.dart`, DAO correspondants, schéma passé à la version suivante avec **test de migration** (`drift_dev schema`) ; `outbox_operations` : colonnes `conflict_json` (état du serveur) et `conflict_fields` (additives) ; purge à la déconnexion étendue (données synchronisées effacées, **file et fichiers de photos du propriétaire conservés**).
- Décimaux en texte (convertisseurs du socle) ; `material_requests` porte `order_json` et `history_json` ; **aucune colonne de prix ni de téléphone**.
- `features/materials/domain/quantity_mirror.dart` (paquet `decimal`, ADR 0014) testé par `docs/api/vecteurs-materiaux.json` ; `features/materials/domain/product_search.dart` : normalisation (accents, `Ø`, casse), recherche par préfixe de chaque mot avec **une faute tolérée** (« cim » → ciment, « ha 12 » → rond HA Ø12, « brik 12 » → brique creuse 12 trous), 300 produits en moins de 100 ms ; tuiles « 6 produits les plus demandés du chantier » calculées localement.
- Tests : DAO en mémoire (upsert par version, cascade chantier → demandes et livraisons, purge qui conserve la file), vecteurs, recherche.

### M2 : Synchronisation en lecture (mobile-flutter)
- Régénérer le client (`swagger_parser`, `siteId` nullable) ; `features/materials/data/{materials_sync_decoder,catalog_repository,materials_repository}.dart` ; `core/sync/sync_engine.dart` : étape « réglages » (`GET /settings/materials`) après le profil, décodage des entités `product`, `supplier`, `request`, `delivery`, `photo`, rechargement complet si `permissionsVersion` change.
- Flux Drift pour les listes (À suivre, Terminées, Refusées et annulées, Archivées), détail, recherche ; bandeau « Données du … » ; premier lancement : « Préparation de vos chantiers… » inclut le catalogue.
- Tests : première synchro paginée avec le catalogue, entité inconnue ignorée, version plus ancienne ignorée, ChefEquipe sans lignes `photo`, **la base ne contient aucun prix** même après synchro d'un conducteur.

### M3 : Envoi des opérations (mobile-flutter)
- `features/materials/data/materials_outbox.dart` : constructeurs d'opérations `request` (`create`, `update` avec `changes` et `base`, `transition`), `delivery`, `photo` ; **chaque saisie = écriture locale + opération dans une transaction** ; références par `requestClientId`, `deliveryClientId`, `zoneClientId` tant que le serveur n'a pas répondu ; `SyncEngine._applyResult` étendu : `applied` / `duplicate` remplacent la ligne locale par la ressource du serveur et **rattachent les lignes qui la désignaient par son `clientId`**, `conflict` et `rejected` conservent `code`, `conflict_json`, `conflict_fields`.
- **Surcouche provisoire** : `MaterialsRepository` calcule l'affichage = état du serveur + opérations en attente (statut « à confirmer », reste et reçu provisoires par le miroir de calcul) ; disparaît à la réponse du serveur.
- Tests : création hors ligne puis synchro, renvoi, deux appuis, ordre création → modification → annulation, 200 opérations par lots de 50, livraison sur une demande encore en attente (références), `conflict` conservé, rollback de la transaction locale.

### M4 : Nouvelle demande et Mes demandes (mobile-flutter)
- `features/materials/presentation/requests/{new_request_screen,requests_screen,request_detail_screen,edit_request_screen,cancel_request_sheet}.dart`, cubits, routes dans `core/router/app_router.dart`.
- 4 gestes (compter dans un test de widget), pastilles zone / date / urgence (1 geste chacune), équivalence en direct, unité préremplie ou à choisir (produit libre : « Envoyer » inactif), « Autre produit » (3 à 100 caractères), avertissement de date passée (« Envoyer quand même ») et de doublon (« Voir DEM-012 » / « C'est une autre demande »), « Ajouter un autre matériau », « numéro en attente », modification d'une demande jamais envoyée = simple modification de la saisie en attente, `DEMANDE_VERROUILLEE` → « Annuler et recréer », boutons 56 dp, texte ≥ 16 sp, FR et AR (numéros, quantités, dates en LTR).
- Tests : widgets FR et AR, comptage de gestes, hors ligne, doublon, verrouillage.

### M5 à M8 : validation, réception, livraisons, photos (mobile-flutter)
- **M5** `presentation/approvals/` : « À valider » (urgence, date de besoin), Valider (2 gestes), Refuser (motif), Valider avec une autre quantité ; « Validation en attente d'envoi » ; visible seulement avec `Requests.Approve`. CA-MAT-003, 013.7.
- **M6** `presentation/deliveries/{to_receive_screen,receive_delivery_screen,to_reception_screen}.dart`, tuiles de l'accueil du chantier (`features/sites/presentation/site_detail_screen.dart` ou nouvel écran d'accueil) : « À recevoir » (date prévue la plus proche), formulaire (reste préchargé, unité de la commande, annonce en toutes lettres, conversion, calendrier sans futur, conformité et réserve, doublon de BL), « À réceptionner » (1 geste), « DEM-014 est livrée. Réceptionner maintenant ? » ; **« Appeler le fournisseur »** sur la commande (visible avec `SupplierPhone.View`) : lit `GET /suppliers/{id}` en ligne, affiche le numéro et lance `tel:` avec `url_launcher` (`<queries>` Android), **sans jamais l'enregistrer** (ADR 0012) ; sans réseau : « Réseau nécessaire pour afficher le numéro ». CA-MAT-006, 008.3, 009.4, 013.7.
- **M7** `presentation/deliveries/{deliveries_screen,delivery_detail_screen,edit_delivery_screen}.dart` : liste et filtres (Non rattachées), livraison sans demande (fournisseur de la liste ou nom libre), correction, annulation avec motif, « BL manquant ». Rattacher : **réseau nécessaire** (message). CA-MAT-011, 012.
- **M8** `presentation/photos/{capture_bl_screen}.dart`, `data/photo_files.dart`, étape `_uploadPhotos()` du moteur : `image_picker` (caméra, `imageQuality` et `maxWidth` fixés), copie dans le stockage privé **par propriétaire** (`path_provider`), vignette avec « Reprendre » / « Garder », jusqu'à 5 photos (6e refusée), envoi **un fichier à la fois** après le push des métadonnées, suppression du fichier à la confirmation, « Photo en attente d'envoi (2) » dans « Envois en attente », affichage à la demande avec réseau (octets en mémoire, cache temporaire purgé à la déconnexion), jamais dans la base. CA-MAT-007. Dépendances : ADR 0013.
- Tests : widgets FR et AR, hors ligne, 150 photos en attente envoyées par petits lots sans figer l'interface (temps contrôlé), fichier conservé après un échec, rôle sans bouton.

### M9 : « À vérifier » (mobile-flutter)
- `features/sync_queue/presentation/{pending_operations_screen,conflict_review_screen}.dart` (le premier existe) : opérations `rejected` et `conflict` avec motif traduit par `code` ; pour un conflit : **« Votre version »** et **« Version du serveur »** côte à côte (champs, statut, quantité avec unité) ; choix « Garder la version du serveur » (abandonne l'opération), « Créer une nouvelle demande avec mes valeurs » (formulaire prérempli), « Refaire ma modification » (champ en conflit) ; confirmation avant d'abandonner ; aucune opération supprimée sans choix. Passe 1 (tranche A) : demandes. Passe 2 (tranche B, après M8) : livraisons (« La demande n'est plus complète », livraison sur demande close).
- Tests : CA-MAT-010.2 à 010.5 et 003.5 de bout en bout avec le serveur simulé, widgets FR et AR.

### M10 : Commander en ligne (mobile-flutter, optionnel)
- `presentation/orders/order_screen.dart` : formulaire en ligne seulement (« Réseau nécessaire pour commander » sans réseau, rien ne part) pour `Orders.Create` ; **aucun prix n'est écrit en base** (le montant renvoyé n'est affiché qu'à l'écran).
- Peut être **différée** sans bloquer la livraison de la tranche B (H-ARCH-04) ; si elle est différée, CA-MAT-005.8 est marqué « reporté » par la QA.

### D1 : Stockage, limites et CI (devops-ci)
- `docker-compose.dev.yml` : volume des photos et `Storage__PhotosRoot` ; `docs/exploitation/proxy-et-production.md` : limite de corps relevée **sur la seule route** `PUT /api/v1/sites/*/photos/*/content` (6 Mo), alerte disque à 80 %, sauvegarde du dossier avec la base, contrôle de cohérence ; `scripts/ci/check-banned-packages` : autoriser `image_picker`, `path_provider`, `url_launcher` (premier parti) et vérifier qu'aucun paquet interdit n'est entré ; CI : un contrôle que `docs/api/vecteurs-materiaux.json` est lu par les trois suites ; `scripts/dev.ps1` : chargement de la démonstration inchangé (comptes `*.dev`).

### Q1 à Q3 : QA (qa-tests) et R1, R2 : revues (revue-securite-perf)
- **Q1** (tranche A) : `docs/qa/demandes-materiaux-livraisons.md` : matrice CA-MAT-001 à 004, 009, 010 (demandes), 015 → test automatisé ou scénario manuel ; exécuter toutes les suites ; combler les trous (matrice de permissions, isolation, conflits) ; scénario hors ligne sur émulateur (créer 3 demandes sans réseau, valider côté web, retour réseau, conflit) ; captures RTL web et mobile ; Playwright : créer une demande puis la valider.
- **Q2** (tranche B, backend et web) : CA-MAT-005 à 008, 011 à 014, 016 ; cas négatifs du document métier ; contrat (OpenAPI, clients, vecteurs) ; Playwright : commander, recevoir avec photo, réceptionner ; performances (500 / 1 000 demandes) ; journaux sans prix ni téléphone.
- **Q3** (mobile tranche B et bout en bout) : scénario **trois jours sans réseau** (20 demandes, 5 livraisons, 150 photos par lots), conflits de livraison, rôle sans bouton, inspection de la base Drift (aucun prix, aucun téléphone), « 4 gestes » et « 3 / 6 gestes » mesurés, bandeau « Données du … ».
- **R1** (après Q1) : isolation (404 identique, liste transversale, lot), droits « la sienne », journal d'opérations, entités globales, `siteId` nullable, rafales sur le push. **R2** (après Q3) : fuite de prix (REST, synchro, événements, erreurs, OpenAPI), photos (octets magiques, EXIF, chemin, droits, taille, déni de service par envoi répété), téléphone fournisseur, plans de requête du suivi et des listes, taille d'une première synchro avec 300 produits, 2 000 demandes et 5 000 livraisons, taille de l'APK.

## Ordonnancement
```
Tranche A  B1 ─► B2 ─► B3 ─► B4 ─► B9 ──────────────► Q1 ─► R1
                              │      └─► M2 ─► M3 ─► M4 ─► M5 ─► M9 (passe 1)
            W1 (après B4) ─► W2 ∥ W3 ─► W4 ───────────────────┘
            M1 (maintenant, sans serveur) ─► M2

Tranche B  B5 ─► B6 ─► B7 ─► B8 ─► B10 ─► B11 ─► D1 ─► Q2 ─► Q3 ─► R2
           W5 ─► W6 ─► W7  (après B5/B6, B7, B8)        M6 ─► M7 ─► M8 ─► M9 (passe 2) ─► (M10 optionnel)
```
- **Chemin critique** : B1 → B2 → B3 → B4 → B9 → M2 → M3 → M4 → M5 (tranche A), puis B5 → B6 → B7 → B10 → M6 → M7 → M8 (tranche B). Le backend est séquentiel (un agent) : 11 tâches.
- **Gains de temps sans risque** : M1 ne dépend d'aucun endpoint et démarre **tout de suite**, en parallèle de B1 à B4 (dossiers distincts) ; W1 démarre dès que l'OpenAPI de B4 est commité ; W2, W3, W4 pendant B9 ; les écrans web de la tranche B pendant M6 à M8.
- **Jalons démontrables** : (1) après B4 : un chef crée une demande, le conducteur la valide dans Scalar (`chef.dev`, `conducteur.dev`, `equipe.dev`) ; (2) après B9 + M5 : demande saisie **sans réseau**, validée côté web, conflit visible dans « À vérifier » ; (3) après B6 : chaîne complète en REST (DEM-005 jusqu'à `Delivered`, annulation de LIV-008) ; (4) après B10 + M8 : camion reçu et photographié hors ligne ; (5) après B11 : démonstration « École UV18 » complète.
- **Première livraison utile (tranche A)** : le conducteur voit les besoins le matin sur son téléphone au lieu de les apprendre l'après-midi ; aucune commande ni livraison n'est encore enregistrée. Si la tranche B tarde, la tranche A seule est déjà en service.
- **Fichiers partagés modifiés par plusieurs tâches** (séquentiel par agent, aucun conflit entre agents) : `SyncContracts.cs`, `SyncTouch.cs`, `ErrorCodes.cs` / `ErrorCatalog.cs`, `RolePermissionMatrix.cs`, `ChantierSchemaTransformer.cs`, `docs/api/openapi.json` (backend) ; `routesMapping.ts`, `entitiesTags.config.ts`, `locales/*` (web) ; `app_database.dart`, `sync_engine.dart`, `app_router.dart`, ARB (mobile).

## Stratégie de test
Voir ADR 0010. **Unitaires** : domaine pur piloté par `docs/api/vecteurs-materiaux.json` (.NET, Dart, TypeScript), table de transitions, matrice de permissions, évaluateur de champs à trois valeurs, retrait EXIF. **Intégration** (SQL Server réel) : isolation, idempotence (`clientId` et journal d'opérations), 60 créations parallèles, recalcul (dont `RecomputeMatchesStoredTests` aléatoire), prix et téléphone absents de **toutes** les réponses par rôle, push de bout en bout avec conflits, photos (fichiers temporaires), migrations, journaux sans donnée personnelle. **Web** : composants FR et AR, MSW, actions absentes selon les permissions, lot de 50. **Mobile** : Cubit / Bloc, DAO en mémoire, moteur de synchro simulé, widgets FR et AR, comptage de gestes, inspection de la base. **Hors ligne** : scénario scripté sur émulateur (trois jours sans réseau). **Performance** : 500 demandes (20 premières < 2 s), 1 000 demandes (suivi < 2 s), 300 produits (recherche mobile < 2 s hors ligne), première synchro mesurée.

## Risques
| Risque | Probabilité | Impact | Parade |
|---|---|---|---|
| Fuite d'un prix ou du téléphone d'un fournisseur par un chemin oublié (historique, erreur, push, export, journal, OpenAPI) | Moyenne | Élevé (négociations d'achat, règle 8) | Un seul constructeur (`CommercialProjection`), événements sensibles filtrés **par type**, formes de synchro sans champ commercial, test qui parcourt toutes les routes avec les jetons ChefChantier et ChefEquipe, inspection de la base mobile, revue R1 et R2 |
| Cache de statut (`ReceivedQuantity`, `Status`) qui diverge des livraisons | Moyenne | Élevé (quantité fausse devant le chef) | `RequestRecalculator` seul écrivain, dans la transaction ; test aléatoire « cache = recalcul depuis zéro » ; recalcul aussi sur changement de masse du sac |
| Opérations `update` / `transition` : faux conflits ou perte silencieuse après un renvoi | Moyenne | Élevé | Journal d'opérations (ADR 0011), comparaison à trois valeurs, tests de renvoi et de croisement ; `conflict` toujours visible dans « À vérifier » |
| Complexité de l'état provisoire et du rattachement par `clientId` côté mobile | Élevée | Moyen | M3 isolée et testée avant les écrans ; une seule fonction de surcouche ; scénario trois jours sans réseau (Q3) |
| Entités globales dans un protocole pensé par chantier : régression du pull du socle | Moyenne | Élevé | B9 modifie `SyncPullService` avec les tests du socle inchangés comme garde ; `siteId` nullable régénéré dans les deux clients, vérifié en B11 |
| Écran « À vérifier » trop difficile à comprendre pour le terrain | Moyenne | Moyen | Deux choix seulement, valeurs côte à côte, essai terrain après tranche A ; texte relu en arabe |
| Photos : 150 images après trois jours hors ligne sur 3G ; disque ; JPEG illisible | Moyenne | Moyen | Un fichier à la fois, reprise par le moteur, fichiers conservés jusqu'à confirmation, 2 Mo cible, alerte disque, rejet des JPEG incohérents (fixtures) |
| Trois miroirs de calcul qui divergent | Faible | Moyen | Un fichier de vecteurs unique pour les trois suites (CI), miroirs limités à conversion, cumul et statut provisoire |
| Backend séquentiel (11 tâches) = chemin critique long | Certaine | Moyen | Tranche A livrable seule ; M1 et W1 en parallèle ; B-tâches petites et testables |
| Traductions arabes imprécises (statuts, « Bloquante », « Solder », produits) | Moyenne | Moyen | Relecture par un arabophone du terrain avant la mise en service (Q-MAT-10) |
| Date du téléphone en avance : livraison « dans le futur » refusée à l'envoi | Faible | Faible | La saisie va dans « À vérifier » avec le motif ; marge paramétrable possible (H-ARCH-14) |
| `RolePermissionMatrix` change `permissionsVersion` : rechargement complet de tous les mobiles au déploiement | Certaine | Faible | Attendu (CA-MAT-009.5) ; annoncer le déploiement ; la file d'envoi est conservée |
| Compteur de numérotation unique par chantier : contention à la création | Faible | Faible | Quelques dizaines de créations par jour ; verrou déjà éprouvé par 60 appels parallèles |

## Décisions
`docs/adr/0011-synchronisation-des-modifications-et-transitions.md` · `0012-donnees-commerciales-catalogue-global-et-synchronisation.md` · `0013-photos-des-bons-de-livraison-avant-le-lot-photos.md` · `0014-unites-conversions-et-vecteurs-de-calcul-partages.md`.
Concernés : ADR 0003 (conventions EF), 0004 (photos), 0005 (permissions, affectation), 0008 (base locale, SQLCipher), 0009 (protocole de synchronisation), 0010 (tests et CI).
Nouvelles dépendances : **aucune côté serveur, web ni TypeScript** ; Flutter : `image_picker`, `path_provider` (ADR 0013), `url_launcher` (ADR 0012), toutes de première partie (licence BSD), versions résolues par `flutter pub add` pour Flutter 3.35.7 / Dart 3.9 sans montée de version.

## Fini quand
- [ ] Les CT-MAT-01 à CT-MAT-26 sont couverts par des tests qui passent (ou un scénario manuel consigné pour le hors ligne sur émulateur)
- [ ] Les vecteurs de calcul passent dans les trois suites (.NET, Dart, TypeScript)
- [ ] Aucun prix ni téléphone de fournisseur dans les réponses, la synchronisation, les journaux ni la base du téléphone (CT-MAT-12, 13, 22, 25)
- [ ] QA et revue sans défaut Bloquant ni Majeur, pour chaque tranche
- [ ] CI verte sur les trois parties et sur le contrat ; `docs/api/openapi.json` à jour
- [ ] Traductions arabes relues (Q-MAT-10) avant la mise en service
- [ ] Hypothèses « à valider par l'utilisateur » confirmées ou inversées
- [ ] Validation métier « conforme » de `docs/metier/demandes-materiaux-livraisons.md`
