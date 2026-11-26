# Contrat d'API : demandes de matériaux, commandes et livraisons (v1)

**Auteur :** architecte-chantier · **Date :** 2026-11-25 · **Statut :** **Implémenté (backend B1 à B11, 2026-11-25)** : le fichier généré [`openapi.json`](openapi.json) **remplace** ce document comme source de vérité des routes et des schémas ; ce document reste sa lecture guidée (règles, exemples), comme `socle.md`. Écarts 1 à 19 **acceptés** (décision de l'orchestrateur, 2026-11-25) ; écarts 20 à 24 ci-dessous : à valider par l'architecte.
**Sources :** `docs/metier/demandes-materiaux-livraisons.md`, `docs/plans/demandes-materiaux-livraisons.md`, ADR 0002, 0004, 0009, 0011, 0012, 0013, 0014, skill `contrat-api`. Codes d'erreur : [`codes-erreur.md`](codes-erreur.md). Vecteurs de calcul : [`vecteurs-materiaux.json`](vecteurs-materiaux.json).
Conventions du socle inchangées (préfixe `/api/v1`, `camelCase`, énumérations en chaînes, dates `2026-11-25`, horodatages UTC, `version` = chaîne, Problem Details, `[SiteScoped]` sur toute route `{siteId}` avec 404 `INTROUVABLE` identique, `clientId` idempotent : 201 puis 200, `operationId` = `Contrôleur_Action`).
**Nommage** : entité `MaterialRequest`, route `/requests`, entité de synchronisation `request` (le mot « Request » seul se confond avec une requête HTTP). Les enchaînements métier sont des **actions explicites** (`approve`, `reject`…), jamais un `PATCH` de statut.

## Types communs
| Type | JSON | Règles |
|---|---|---|
| `Quantity` | `{ "value": 300, "unit": "sac" }` | `unit` ∈ `u ml m2 m3 kg t sac l h j pj ft` ; `value` > 0, 3 décimales au plus ; **entier** pour `sac` et `u` (`QUANTITE_ENTIERE_REQUISE`) ; unité toujours présente (`UNITE_OBLIGATOIRE`) |
| `Priority` | `Normal` · `Urgent` · `Blocking` | défaut `Normal` |
| `RequestStatus` | `Requested` · `Validated` · `Rejected` · `Ordered` · `PartiallyDelivered` · `Delivered` · `Received` · `Cancelled` | calculé et changé **par le serveur seulement** |
| `DeliveryStatus` | `Recorded` · `Cancelled` | |
| `Conformity` | `Conform` · `WithReserve` | `WithReserve` exige `reserveReasonCode` |
| `UnattachedReason` | `NoRequestChosen` · `RequestNotOpen` · `RequestMissing` | présent seulement si la livraison n'a pas de demande |
| `ProductCategory` | `Binders` · `Steel` · `Masonry` · `Aggregates` · `Admixtures` · `FinishingWorks` · `Other` | |
| Motifs (`reasonCode`) | chaînes ouvertes, listes par cas dans `GET /settings/materials` | Refus : `AlreadyOrdered StockSufficient QuantityToReview OverBudget Other` · Annulation de demande : `EntryError NoLongerNeeded Duplicate Other` · Annulation de commande : `SupplierUnavailable PriceRefused Other` · Solde : `SupplierWillNotDeliver QuantitySufficient Other` · Annulation de livraison : `DoubleEntry QuantityError RefusedAtReception Other` · Réserve : `QuantityMissing DamagedProduct WrongProduct Other`. `Other` impose `reasonNote` (≤ 200). Motif absent ou hors liste : 400 `VALIDATION` (`errors.reasonCode`) |
| Montant | nombre, 2 décimales | DZD hors taxes, calculé par le serveur, `AwayFromZero` ; **uniquement** dans l'objet `commercial` |

## Permissions (catalogue ajouté à `PermissionResources` / `Permissions` / `RolePermissionMatrix`)
Le rôle décide de l'**action**, l'affectation du **périmètre** (ADR 0005). O = accordée ; la ligne « règle » donne le contrôle de ressource que le service ajoute.
| Permission | Admin | Direction | Conducteur | Achats | ChefChantier | ChefEquipe | Règle de ressource |
|---|---|---|---|---|---|---|---|
| `Products.View`, `Suppliers.View` | O | O | O | O | O | O | |
| `Products.Create`, `Products.Update`, `Suppliers.Create`, `Suppliers.Update` | O | | | O | | | désactiver = `Update` |
| `SupplierPhone.View` | O | | O | O | O | | téléphone absent de la réponse sinon |
| `Prices.View` | O | O | O | O | | | objet `commercial` absent sinon |
| `Requests.View`, `Deliveries.View` | O | O | O | O | O | O | |
| `Requests.Create` | O | | O | | O | O | chantier affecté, non archivé |
| `Requests.Update` | O | | O | | O | O | **la sienne seulement** (`createdBy` = moi), statut `Requested` |
| `Requests.UpdateAny` | O | | O | | O | | toutes les demandes du chantier ; seule à permettre la modification de date, urgence, remarque après validation |
| `Requests.Approve` | O | | O | | | | valider, refuser, ajuster la quantité |
| `Requests.Cancel` | O | | O | | O | O | **la sienne seulement** |
| `Requests.CancelAny` | O | | O | | | | toutes (Q-MAT-01 c : ChefChantier **non**) |
| `Requests.Receive` | O | | | | O | | |
| `Requests.Settle` | O | | O | O | | | Q-MAT-01 b |
| `Requests.Archive` | O | | O | | | | |
| `Requests.LinkProduct` | O | | | O | | | |
| `Orders.Create`, `Orders.Update`, `Orders.Cancel` | O | | | O | | | `Orders.Cancel` = Q-MAT-01 a |
| `Deliveries.Create`, `Deliveries.Update`, `Deliveries.Attach` | O | | O | O | O | | Q-MAT-02 B = ajouter ChefEquipe à `Deliveries.Create` |
| `DeliveryPhotos.Create` | O | | O | O | O | | |
| `DeliveryPhotos.View` | O | O | O | O | O | | Q-MAT-03 B = retirer ChefChantier |
Admin voit tous les chantiers (`AllSites.View`) ; les autres rôles seulement les chantiers affectés. Direction n'écrit nulle part.

## Réponses
```json
// MaterialRequestResponse (liste, détail, REST) ; clés absentes = non écrites
{ "id": "0192…", "siteId": "0192…", "siteCode": "CH-ECO-UV18", "clientId": "7c1e…", "clientCreatedAt": "2026-11-25T06:58:00Z",
  "number": "DEM-009",
  "product": { "productId": "0192…", "name": "Ciment CPJ 42,5", "nameAr": null, "freeName": null },
  "quantity": { "value": 300, "unit": "sac" }, "zoneId": "0192…", "neededBy": "2026-11-26", "priority": "Blocking",
  "note": "Dalle +10,20", "status": "Ordered", "statusReason": null,
  "receivedQuantity": { "value": 0, "unit": "sac" }, "remainingQuantity": { "value": 300, "unit": "sac" },
  "variance": { "value": -300, "unit": "sac", "percent": -100.00 }, "isSettled": false, "overdueDays": 0,
  "possibleDuplicateOf": null, "hasDeliveryWithoutOrder": false,
  "order": { "id": "0192…", "supplierId": "0192…", "supplierName": "Cimenterie Sigma (fictive)", "orderDate": "2026-11-25", "expectedDeliveryDate": "2026-11-26",
             "plannedAfterNeedDays": 0, "note": null, "version": "51002",
             "commercial": { "unitPrice": 780.00, "amount": 234000.00, "receivedValue": 0.00, "purchaseOrderNumber": "BC-2026-044" } },
  "requestedById": "0192…", "requestedByName": "Mourad B.", "archivedAt": null, "archivedByName": null,
  "version": "51010", "createdAt": "2026-11-25T07:00:00Z", "createdByName": "Mourad B.", "updatedAt": "2026-11-25T09:12:00Z", "updatedByName": "Karim A." }
```
- `status` seul décide ; `statusReason` = `{ "code": "StockSufficient", "note": null }` pour `Rejected` et `Cancelled`. `receivedQuantity`, `remainingQuantity` (jamais négatif), `variance` (négatif = manque, positif = surplus ; `percent` à 2 décimales) sont **dans l'unité de la demande** et calculés par le serveur (vecteurs). Absents tant que la demande n'est pas `Ordered` ou au-delà, sauf `receivedQuantity` d'une demande `Validated` qui a des livraisons retenues.
- `overdueDays` = jours calendaires, heure d'Algérie, `max(0, aujourd'hui − neededBy)`, seulement pour `Requested`, `Validated`, `Ordered`, `PartiallyDelivered` ; sinon 0.
- `possibleDuplicateOf` = `{ "id", "number" }` d'une demande ouverte (`Requested` ou `Validated`) du même chantier, même produit, même zone (ou aucune), calculé à la création ; jamais bloquant. `hasDeliveryWithoutOrder` = demande `Validated` qui a une livraison rattachée non annulée (badge « Livraison reçue sans commande enregistrée »).
- `order` : `null` sans commande active ; `commercial` **absent** sans `Prices.View`. Une commande annulée n'apparaît pas ici (elle reste dans l'historique).
- `MaterialRequestDetailResponse` = `MaterialRequestResponse` + `history[]` + `deliveries[]` :
```json
{ "history": [ { "id": "0192…", "type": "Approved", "fromStatus": "Requested", "toStatus": "Validated", "reasonCode": null, "reasonNote": null,
                 "changes": [ { "field": "quantity", "old": "300 sac", "new": "200 sac" } ],
                 "actorName": "Karim A.", "occurredAt": "2026-11-25T09:00:00Z", "deviceAt": null, "source": "Api" } ],
  "deliveries": [ { "id": "0192…", "number": "LIV-006", "deliveryDate": "2026-11-04", "quantity": { "value": 10, "unit": "t" },
                    "quantityInRequestUnit": { "value": 200, "unit": "sac" }, "status": "Recorded", "deliveryNoteNumber": "BL-4471",
                    "conformity": "Conform", "photoCount": 1 } ] }
```
  Types d'événements : `Created Edited Approved QuantityAdjusted Rejected Cancelled Ordered OrderEdited OrderCommercialEdited OrderCancelled DeliveryRegistered DeliveryEdited DeliveryCancelled DeliveryAttached StatusRecomputed Settled Received Archived Restored ProductLinked PhotoAdded`. `OrderCommercialEdited` n'est rendu qu'avec `Prices.View` ; aucun autre événement ne contient un prix. `source` ∈ `Api`, `Sync`, `System` ; `deviceAt` = « saisi le » d'une saisie hors ligne.
```json
// DeliveryResponse
{ "id": "0192…", "siteId": "0192…", "clientId": "…", "clientCreatedAt": "…", "number": "LIV-006", "requestId": "0192…", "requestNumber": "DEM-005", "unattachedReason": null,
  "supplierId": "0192…", "supplierName": "Cimenterie Sigma (fictive)", "freeSupplierName": null,
  "product": { "productId": "0192…", "name": "Ciment CPJ 42,5", "nameAr": null, "freeName": null },
  "quantity": { "value": 10, "unit": "t" }, "quantityInRequestUnit": { "value": 200, "unit": "sac" }, "deliveryDate": "2026-11-04",
  "deliveryNoteNumber": "BL-4471", "missingNote": false, "conformity": "Conform", "reserve": null, "status": "Recorded", "cancelReason": null,
  "possibleDuplicateOf": null, "photos": [ { "id": "0192…", "contentStatus": "Uploaded", "sizeBytes": 1480000, "takenAt": "2026-11-04T08:10:00Z" } ],
  "commercial": { "amount": 156000.00 },
  "version": "49800", "createdAt": "…", "createdByName": "Mourad B.", "updatedAt": null, "updatedByName": null }
```
  `missingNote` = ni n° de BL ni photo (badge « BL manquant »). `reserve` = `{ "code": "DamagedProduct", "note": null }`. `quantityInRequestUnit` seulement si rattachée. `commercial.amount` = `round2(quantityInRequestUnit × prix de la commande)`, absent sans `Prices.View` ou sans prix. **`DeliveryDetailResponse`** ajoute `history[]` (mêmes événements). La livraison n'a pas de prix propre (hypothèse H-ARCH-07 du plan).
```json
// ProductResponse                                       // SupplierResponse
{ "id": "0192…", "nameFr": "Ciment CPJ 42,5",           { "id": "0192…", "name": "Cimenterie Sigma (fictive)",
  "nameAr": "إسمنت CPJ 42,5", "category": "Binders",        "phone": "0550 00 00 21", "productIds": ["0192…"], "isActive": true,
  "allowedUnits": ["sac","t","kg"], "defaultUnit": "sac",   "version": "47001", … }
  "bagMassKg": 50, "isActive": true, "version": "47000", … }
```
`phone` n'est écrit qu'avec `SupplierPhone.View` ; il n'existe **jamais** dans les données de synchronisation ni dans un journal.

## Catalogue : produits et fournisseurs (globaux, web)
| Méthode | Route | Permission | Requête | Réponses |
|---|---|---|---|---|
| GET | `/products` | `Products.View` | `?q=&category=&isActive=&page=1&pageSize=50&sort=name` | 200 `{ items, page, pageSize, totalCount }` |
| GET | `/products/{productId}` | `Products.View` | | 200 · 404 |
| POST | `/products` | `Products.Create` | `{ nameFr, nameAr?, category, allowedUnits[], defaultUnit, bagMassKg? }` | 201 · 400 · 422 `PRODUIT_EXISTANT`, `MASSE_SAC_OBLIGATOIRE`, `UNITE_NON_AUTORISEE` (unité par défaut hors liste) |
| PUT | `/products/{productId}` | `Products.Update` | mêmes champs + `version` | 200 · 404 · 409 · 422 (idem). Changer `bagMassKg` **recalcule** `quantityInRequestUnit`, `receivedQuantity` et le statut des demandes ouvertes du produit, dans la transaction, avec un événement `StatusRecomputed` |
| POST | `/products/{productId}/deactivate`, `/activate` | `Products.Update` | | 200 · 404 (idempotent) |
| GET | `/suppliers`, `/suppliers/{supplierId}` | `Suppliers.View` | `?q=&isActive=&page=&pageSize=` | 200 · 404 |
| POST | `/suppliers` | `Suppliers.Create` | `{ name, phone?, productIds[]? }` | 201 · 422 `FOURNISSEUR_EXISTANT` |
| PUT | `/suppliers/{supplierId}` | `Suppliers.Update` | idem + `version` | 200 · 409 · 422 |
| POST | `/suppliers/{supplierId}/deactivate`, `/activate` | `Suppliers.Update` | | 200 · 404 |
| GET | `/settings/materials` | authentifié | | 200 `MaterialSettingsResponse` |
`phone` : format algérien (`0[5-7]x xx xx xx`, espaces facultatifs), 400 `VALIDATION` sinon. Nom unique sans tenir compte de la casse, des accents et des espaces superflus. Un produit ou un fournisseur n'est jamais supprimé : il est désactivé et reste affiché dans l'historique ; `PRODUIT_INACTIF` / `FOURNISSEUR_INACTIF` pour toute **nouvelle** saisie.
```json
// MaterialSettingsResponse : valeurs lues par le mobile à chaque synchronisation (hors ligne : dernière copie)
{ "defaultNeededByDays": 3, "deliveryTolerancePercent": 0, "maxPhotosPerDelivery": 5, "maxPhotoBytes": 5242880, "noteMaxLength": 200,
  "reasons": { "rejection": ["AlreadyOrdered","StockSufficient","QuantityToReview","OverBudget","Other"], "requestCancellation": [...], "orderCancellation": [...], "settle": [...], "deliveryCancellation": [...], "reserve": [...] } }
```

## Demandes
| Méthode | Route | Permission | Requête | Réponses |
|---|---|---|---|---|
| GET | `/sites/{siteId}/requests` | `Requests.View` | `?view=&mine=&status=&priority=&zoneId=&productId=&supplierId=&from=&to=&q=&sort=&page=1&pageSize=50` | 200 `{ items, page, pageSize, totalCount }` · 404 |
| GET | `/requests` | `Requests.View` | mêmes filtres + `siteId?` | 200 (mêmes éléments avec `siteCode`) ; chantiers affectés seulement (Admin : tous) ; `siteId` non affecté : 404 |
| GET | `/sites/{siteId}/requests/{requestId}` | `Requests.View` | | 200 `…DetailResponse` · 404 |
| POST | `/sites/{siteId}/requests` | `Requests.Create` | `CreateRequestRequest` | 201 · 200 (même `clientId`) · 400 · 404 · 422 |
| PUT | `/sites/{siteId}/requests/{requestId}` | `Requests.Update` / `UpdateAny` | `UpdateRequestRequest` + `version` | 200 · 403 · 404 · 409 `CONFLIT_VERSION` · 422 |
| POST | `…/requests/{requestId}/approve` | `Requests.Approve` | `{ quantity? }` | 200 (idempotent si déjà `Validated`) · 422 |
| POST | `…/reject` | `Requests.Approve` | `{ reasonCode, reasonNote? }` | 200 (idempotent) · 400 · 422 |
| POST | `…/cancel` | `Requests.Cancel` / `CancelAny` | `{ reasonCode, reasonNote? }` | 200 (idempotent) · 400 · 403 · 422 |
| POST | `…/receive` | `Requests.Receive` | `{ note? }` | 200 (idempotent) · 422 |
| POST | `…/settle` | `Requests.Settle` | `{ reasonCode, reasonNote? }` | 200 · 400 · 422 |
| POST | `…/link-product` | `Requests.LinkProduct` | `{ productId }` | 200 · 422 `UNITE_NON_AUTORISEE` |
| POST | `…/archive`, `…/restore` | `Requests.Archive` | | 200 (idempotent) · 422 `TRANSITION_INTERDITE` |
| POST | `/sites/{siteId}/requests/batch/approve` | `Requests.Approve` | `{ requestIds[] }` (≤ 50) | 200 `{ results: [ { requestId, outcome: "applied"\|"duplicate"\|"rejected", code? } ] }` |
| POST | `/sites/{siteId}/requests/batch/archive` | `Requests.Archive` | `{ requestIds[] }` (≤ 100) | 200 (même forme) |
| GET | `/sites/{siteId}/follow-up` | `Requests.View` | | 200 `FollowUpResponse` |
```json
// CreateRequestRequest (le client ne fixe jamais statut, numéro, auteur, dates d'audit, doublon)
{ "clientId": "7c1e…", "clientCreatedAt": "2026-11-25T06:58:00Z", "productId": "0192…", "freeProductName": null,
  "quantity": { "value": 300, "unit": "sac" }, "zoneId": "0192…", "neededBy": "2026-11-28", "priority": "Normal", "note": null }
// UpdateRequestRequest : tous les champs facultatifs sauf version ; seuls ceux présents changent
{ "version": "51010", "productId": null, "freeProductName": null, "quantity": { "value": 400, "unit": "sac" }, "zoneId": "…", "neededBy": "2026-12-01", "priority": "Urgent", "note": "…" }
// FollowUpResponse
{ "counters": { "toApprove": 2, "toOrder": 1, "expected": 3, "late": 1, "toReceive": 1 },
  "toOrderTotals": [ { "productId": "0192…", "name": "Ciment CPJ 42,5", "total": { "value": 400, "unit": "sac" }, "massEquivalent": { "value": 20, "unit": "t" }, "requestCount": 3 } ],
  "commercial": { "orderedAmount": 2206000.00, "receivedValue": 1950000.00 } }
```
**Vues** (`view`, définies par le serveur, archivées exclues sauf `archived`) : `toFollow` (défaut : `Requested Validated Ordered PartiallyDelivered Delivered`, tri `Blocking`, `Urgent`, `Normal` puis `neededBy`) · `toApprove` (`Requested`) · `toOrder` (`Validated`) · `expected` (`Ordered`, `PartiallyDelivered`, par date prévue) · `late` (statut ouvert non livré avec `neededBy` < aujourd'hui, ou commande attendue avec date prévue < aujourd'hui) · `toReceive` (`Delivered`) · `received` · `closed` (`Rejected`, `Cancelled`) · `archived`. `mine=true` = `createdBy` = moi (défaut des ChefEquipe, côté client). `q` : numéro (`DEM-014`), nom de produit, nom libre, remarque ; insensible à la casse et aux accents.
`FollowUpResponse.toOrderTotals` : somme par produit **dans l'unité par défaut du produit**, seulement entre unités convertibles ; unités non convertibles = lignes séparées ; `massEquivalent` quand la somme est en `sac`. `commercial` absent sans `Prices.View`.

**Règles de saisie et de transition** (tableau de test : `(statut, action, rôle)` → résultat) :
| Action | Depuis | Vers | Règles et erreurs |
|---|---|---|---|
| Créer | | `Requested` | produit du catalogue **actif** (`PRODUIT_INACTIF`) ou `freeProductName` de 3 à 100 caractères, **exactement un des deux** ; unité obligatoire, parmi les unités autorisées du produit (`UNITE_NON_AUTORISEE`) ; zone du chantier (`ZONE_HORS_CHANTIER`) ; `neededBy` date complète (`DATE_INVALIDE`), passée = accepté ; chantier non archivé (`CHANTIER_ARCHIVE`) ; numéro `DEM-nnn` attribué **après** le contrôle du `clientId`, dans la transaction |
| Modifier | `Requested` | idem | tous les champs ; auteur ou `UpdateAny` ; historique « ancienne → nouvelle » |
| Modifier | `Validated`, `Ordered`, `PartiallyDelivered` | idem | `neededBy`, `priority`, `note` seulement, avec `UpdateAny` ; produit, quantité, unité, zone : 422 `DEMANDE_VERROUILLEE` |
| Modifier | `Delivered`, `Received`, `Rejected`, `Cancelled` | | 422 `TRANSITION_INTERDITE` |
| Valider | `Requested` | `Validated` | quantité facultative (même unité, > 0) : ancienne et nouvelle quantités dans l'événement `QuantityAdjusted` ; déjà `Validated` avec la même quantité : 200 idempotent ; avec une autre quantité : 422 `DEMANDE_VERROUILLEE` ; autre statut : 422 `TRANSITION_INTERDITE` |
| Refuser | `Requested` | `Rejected` | motif obligatoire ; déjà `Rejected` : 200 |
| Annuler | `Requested`, `Validated` | `Cancelled` | motif obligatoire ; auteur ou `CancelAny` ; `Ordered` et au-delà : 422 `TRANSITION_INTERDITE` (« Contactez les Achats ») ; déjà `Cancelled` : 200, premier motif conservé |
| Réceptionner | `Delivered` | `Received` | `Received` déjà : 200 ; autre statut : `TRANSITION_INTERDITE` |
| Solder | `PartiallyDelivered` | `Delivered` | motif obligatoire ; `isSettled = true` ; sans aucune livraison active : `TRANSITION_INTERDITE` |
| Archiver | `Rejected`, `Cancelled`, `Received` | (archivée) | `archivedAt/By` ; demande ouverte : `TRANSITION_INTERDITE` ; restaurer reprend le statut |
| Rattacher un produit libre | toute demande ouverte | | `freeProductName` conservé, `productId` posé ; quantité et unité conservées et vérifiées |
Chaque transition écrit un événement (qui, quand serveur, ancien → nouveau statut, motif) dans la même transaction. **Statut calculé** : voir « Livraisons et recalcul ».

## Commandes (une par demande, sans numéro propre)
| Méthode | Route | Permission | Requête | Réponses |
|---|---|---|---|---|
| POST | `/sites/{siteId}/requests/{requestId}/order` | `Orders.Create` | `{ clientId, supplierId, orderDate, expectedDeliveryDate?, unitPrice?, purchaseOrderNumber?, note? }` | 201 · 200 (même `clientId`) · 400 · 404 · 422 `COMMANDE_EXISTANTE`, `TRANSITION_INTERDITE` (demande non `Validated`), `FOURNISSEUR_INACTIF` |
| PUT | `…/order` | `Orders.Update` | `supplierId?, expectedDeliveryDate?, unitPrice?, purchaseOrderNumber?, note?` + `version` | 200 · 409 · 422 `TRANSITION_INTERDITE` (demande `Delivered` ou au-delà) |
| POST | `…/order/cancel` | `Orders.Cancel` | `{ reasonCode, reasonNote? }` | 200 `MaterialRequestResponse` (demande de nouveau `Validated`) · 422 `TRANSITION_INTERDITE` si une livraison non annulée existe |
Réponse de création et de modification : `MaterialRequestResponse` (la commande est `order`). Quantité et unité : celles de la demande, **non modifiables**. `unitPrice` > 0 sinon 400 ; `orderDate` complète et pas dans le futur ; `expectedDeliveryDate` pas avant `orderDate` (`DATE_INVALIDE`) ; `plannedAfterNeedDays` = jours entre `neededBy` et la date prévue quand elle le dépasse (sert à l'avertissement, jamais bloquant). `commercial.amount = round2(quantité × unitPrice)`.
Créer la commande fait passer la demande à `Ordered` **puis** recalcule le statut d'après les livraisons déjà retenues (deux événements si besoin). Changer `unitPrice` recalcule `amount` et `commercial.amount` de chaque livraison (événement `OrderCommercialEdited`, sensible). Annuler : la commande reste dans l'historique ; une nouvelle commande est possible ensuite.

## Livraisons et recalcul
| Méthode | Route | Permission | Requête | Réponses |
|---|---|---|---|---|
| GET | `/sites/{siteId}/deliveries` | `Deliveries.View` | `?requestId=&unattached=true&withReserve=true&missingNote=true&status=&supplierId=&productId=&q=&from=&to=&page=&pageSize=` | 200 `{ items, … totalCount }` |
| GET | `/sites/{siteId}/deliveries/{deliveryId}` | `Deliveries.View` | | 200 `DeliveryDetailResponse` · 404 |
| POST | `/sites/{siteId}/deliveries` | `Deliveries.Create` | `CreateDeliveryRequest` | 201 · 200 (même `clientId`) · 400 · 404 · 422 |
| PUT | `/sites/{siteId}/deliveries/{deliveryId}` | `Deliveries.Update` | `quantity?, deliveryDate?, deliveryNoteNumber?, conformity?, reserveReasonCode?, reserveNote?` + `version` | 200 · 409 · 422 |
| POST | `…/deliveries/{deliveryId}/cancel` | `Deliveries.Update` | `{ reasonCode, reasonNote? }` | 200 (idempotent) · 400 · 422 |
| POST | `…/deliveries/{deliveryId}/attach` | `Deliveries.Attach` | `{ requestId }` | 200 · 404 · 422 `PRODUIT_DIFFERENT`, `UNITES_INCOMPATIBLES`, `DEMANDE_NON_OUVERTE`, `LIVRAISON_DEJA_RATTACHEE` |
```json
// CreateDeliveryRequest
{ "clientId": "…", "clientCreatedAt": "…", "requestId": "0192…", "supplierId": "0192…", "freeSupplierName": null, "productId": null, "freeProductName": null,
  "quantity": { "value": 10, "unit": "t" }, "deliveryDate": "2026-11-25", "deliveryNoteNumber": "bl-4471", "conformity": "Conform", "reserveReasonCode": null, "reserveNote": null }
```
- **Une livraison est un fait de chantier** : sa création **n'est jamais refusée** à cause du statut de la demande. `requestId` absent = `NoRequestChosen` ; demande `Rejected`, `Cancelled`, `Received`, `Requested` = enregistrée **non rattachée** (`unattachedReason: RequestNotOpen`). `Validated` = rattachée et **retenue** (la demande reste `Validated`). `Ordered`, `PartiallyDelivered`, `Delivered` = rattachée. Une demande d'un autre chantier : 404 `INTROUVABLE`.
- Produit : celui de la demande (l'envoi d'un autre produit : 422 `PRODUIT_DIFFERENT`) ; sans demande : `productId` ou `freeProductName`. Fournisseur : `supplierId` actif ou `freeSupplierName` (3 à 100). **Unité** : celle de la demande ou convertible (sac, kg, t avec la masse du sac) ; sinon 422 `UNITES_INCOMPATIBLES` (« Saisissez en m³, l'unité de la commande »). `deliveryDate` pas dans le futur (date d'Algérie) : 400 `DATE_INVALIDE` ; antérieure à la demande : accepté. `deliveryNoteNumber` : ≤ 30, majuscules, espaces retirés. `WithReserve` exige `reserveReasonCode`. Numéro `LIV-nnn` (mêmes règles que `DEM`).
- **Doublon de BL** : même chantier, fournisseur, produit et n° de BL qu'une livraison non annulée : `possibleDuplicateOf`, jamais un refus.
- **Recalcul** (seule la fonction du domaine `RequestStatusCalculator`, jamais le client) : à chaque création, correction, annulation, rattachement et changement de masse de sac, pour une demande `Ordered`, `PartiallyDelivered` ou `Delivered`, **dans les deux sens** : `Qr` = somme des livraisons non annulées converties (3 décimales, `AwayFromZero`) ; `Qr = 0` → `Ordered` ; `0 < Qr` et pas complète → `PartiallyDelivered` ; complète (`Qr ≥ Qc`, ou manque ≤ `Materials:DeliveryTolerancePercent` %, ou demande soldée) → `Delivered`. Événement `StatusRecomputed` (« Recalcul suite à l'annulation de LIV-006 »). Une demande `Received` n'est plus recalculée : livraison ou correction = 422 `DEMANDE_NON_OUVERTE` (correction et annulation) ; création = livraison non rattachée.
  Une demande soldée dont toutes les livraisons sont annulées revient à `Ordered` et perd `isSettled`.
- **Corriger** : quantité, unité, date, BL, conformité (mêmes validations) tant que la demande n'est pas `Received` (ou si la livraison n'a pas de demande) ; une livraison annulée n'est pas modifiable (`TRANSITION_INTERDITE`) ; le numéro ne change jamais. **Annuler** : motif obligatoire ; la livraison reste visible, n'entre plus dans aucun total. **Rattacher** : livraison non rattachée → demande `Validated`, `Ordered` ou `PartiallyDelivered` du même chantier, même produit ; recalcule. Pas de détachement : annuler puis ressaisir.

## Photos du bon de livraison (ADR 0013)
| Méthode | Route | Permission | Requête | Réponses |
|---|---|---|---|---|
| POST | `/sites/{siteId}/deliveries/{deliveryId}/photos` | `DeliveryPhotos.Create` | `{ clientId, takenAt, contentType: "image/jpeg", sizeBytes, sha256 }` | 201 · 200 (même `clientId`) · 404 · 422 `PHOTOS_TROP_NOMBREUSES` |
| PUT | `/sites/{siteId}/photos/{photoId}/content` | `DeliveryPhotos.Create` | corps = octets JPEG (`Content-Type: image/jpeg`, ≤ `Storage:MaxPhotoBytes`) | 200 `PhotoResponse` (même contenu renvoyé : 200 sans effet) · 404 · 409 `PHOTO_DEJA_ENVOYEE` · 413 `FICHIER_TROP_GROS` · 415 `TYPE_FICHIER_REFUSE` · 422 (empreinte différente de celle déclarée) |
| GET | `/sites/{siteId}/photos/{photoId}/content` | `DeliveryPhotos.View` | | 200 `image/jpeg` (`nosniff`, `Cache-Control: private, no-cache`, `ETag`) · 304 (`If-None-Match` : après contrôle du droit) · 404 (y compris photo d'un autre chantier ou sans la permission, indiscernable) |
`PhotoResponse` : `{ id, siteId, deliveryId, clientId, takenAt, contentType, sizeBytes, contentStatus: "Pending"|"Uploaded", version, … }` ; ni chemin de stockage, ni empreinte détaillée dans les réponses. Métadonnées créables hors ligne (opération `photo` / `create`), binaire toujours par `PUT` direct. Le serveur retire les métadonnées du JPEG avant écriture, **par liste blanche** (R2-03) : seuls JFIF, Adobe, tables, cadre et balayages sont gardés ; `APP1` (Exif, XMP), `APP2`, `APP3` à `APP13`, `COM` sont supprimés partout (y compris entre deux balayages), et **tout ce qui suit le premier `FF D9` est supprimé**. `PhotoCount` (livraison) et « BL manquant » ne comptent que les photos **dont le fichier est reçu** (`Uploaded`) ; une photo `Pending` occupe l'une des 5 places pendant 24 h (`Materials:PendingPhotoHoldHours`) puis la libère, et la ligne est supprimée après 7 jours (`Materials:PendingPhotoExpiryDays`). Les photos `Uploaded` gardent leur place. L'événement `PhotoAdded` est écrit à la réception du fichier.

## Synchronisation hors ligne (ADR 0009, 0011, 0012)
**Pull** : `GET /sync/changes` existant ; `SyncChange.siteId` et `SyncDeletion.siteId` deviennent **nullables** (`null` = entité globale). Nouvelles entités :
| `entity` | Portée | `data` | Pierres tombales |
|---|---|---|---|
| `product` | globale (tous) | `ProductResponse` | aucune (désactivation) |
| `supplier` | globale (tous) | `SupplierResponse` **sans `phone`** | aucune |
| `request` | chantier | `RequestSyncData` = `MaterialRequestResponse` **sans `commercial` ni `siteCode`**, avec `order` sans `commercial` et **`history[]` toujours vide** (R2-02 : l'historique se lit à la demande par `GET /requests/{id}`) ; fenêtre de 60 jours pour les demandes closes | aucune (archivage visible dans `archivedAt`) |
| `delivery` | chantier | `DeliverySyncData` = `DeliveryResponse` **sans `commercial`, sans `photos` ni `missingNote`** (déduits de l'entité `photo`, dont la ligne change seule), **`history[]` toujours vide** (R2-02 : `GET /deliveries/{id}`) ; hors fenêtre : livraisons annulées depuis plus de 60 jours et livraisons d'une demande hors fenêtre | aucune |
| `photo` | chantier | `PhotoResponse` ; **aucune ligne pour un utilisateur sans `DeliveryPhotos.View`** | aucune |
**Fenêtre de synchronisation** (R2-02, `Sync:ClosedRetentionDays`, 60 par défaut, `0` = pas de fenêtre) : une demande `Received`, `Cancelled` ou `Rejected` (archivée ou non) modifiée depuis plus de 60 jours n'est plus envoyée, ni ses livraisons, ni leurs photos ; une demande ouverte est toujours envoyée, quel que soit son âge. Aucune pierre tombale : ce que le téléphone a déjà reçu reste chez lui.
Les `*SyncData` sont des schémas nommés de l'OpenAPI (comme `SyncMemberData`) même s'ils ne sont renvoyés que dans `SyncChange.data`. `GET /settings/materials` et `GET /auth/me` complètent la synchronisation (réglages, permissions).
Une nouvelle **affectation** touche aussi les demandes, commandes, livraisons et photos du chantier (`SyncTouch.TouchedEntityTypes`), **dans la fenêtre seulement** (R2-02) : les lignes hors fenêtre gardent leur version.

**Push** : `POST /sync/push`, lot ≤ 100 opérations, **une opération = une transaction**, `siteId` obligatoire par opération. Entités et opérations acceptées :
| `entity` / `operation` | `payload` | Résultats |
|---|---|---|
| `request` / `create` | comme `CreateRequestRequest` sans `clientId` ; `zoneId` **ou** `zoneClientId` | `applied` (`resource` = `RequestSyncData`) · `duplicate` · `rejected` (`INTERDIT`, `INTROUVABLE`, `CHANTIER_ARCHIVE`, `VALIDATION`, `ZONE_HORS_CHANTIER`, `UNITE_OBLIGATOIRE`, `QUANTITE_*`, `DATE_INVALIDE`, `PRODUIT_INACTIF`, `UNITE_NON_AUTORISEE`) |
| `request` / `update` | `{ requestId \| requestClientId, clientCreatedAt, changes: { quantity?, productId?, freeProductName?, zoneId?, neededBy?, priority?, note? }, base: { mêmes clés } }` | `applied` · `duplicate` · `conflict` (`DEMANDE_VERROUILLEE` si le statut a dépassé `Requested` pour produit, quantité, unité ou zone ; `TRANSITION_INTERDITE` si la demande est `Delivered`, `Received`, `Rejected`, `Cancelled` ; `CONFLIT_VERSION` + `conflictFields` si un champ a changé ailleurs) · `rejected` |
| `request` / `transition` | `{ requestId \| requestClientId, clientCreatedAt, action: "approve"\|"reject"\|"cancel"\|"receive", quantity?, reasonCode?, reasonNote?, note? }` | `applied` · `duplicate` (état déjà atteint : « Déjà validée ») · `conflict` (`TRANSITION_INTERDITE`, `current`) · `rejected` |
| `delivery` / `create` | comme `CreateDeliveryRequest` sans `clientId` ; `requestId` **ou** `requestClientId` ; `supplierId` ou nom libre | `applied` (`resource` = `DeliverySyncData`, `unattachedReason` posé si besoin) · `duplicate` · `rejected` (`UNITES_INCOMPATIBLES`, `PRODUIT_DIFFERENT`, `DATE_INVALIDE`, `INTERDIT`, `INTROUVABLE`, `CHANTIER_ARCHIVE`, `FOURNISSEUR_INACTIF`…) |
| `delivery` / `update` | `{ deliveryId \| deliveryClientId, clientCreatedAt, changes, base }` (champs du `PUT`) | `applied` · `conflict` (`DEMANDE_NON_OUVERTE` si la demande est `Received`, `TRANSITION_INTERDITE` si annulée, `CONFLIT_VERSION`) · `rejected` |
| `delivery` / `transition` | `{ deliveryId \| deliveryClientId, clientCreatedAt, action: "cancel", reasonCode, reasonNote? }` | `applied` · `duplicate` · `conflict` (`DEMANDE_NON_OUVERTE`) · `rejected` |
| `photo` / `create` | `{ deliveryId \| deliveryClientId, clientCreatedAt, takenAt, contentType, sizeBytes, sha256 }` | `applied` · `duplicate` · `rejected` (`PHOTOS_TROP_NOMBREUSES`, `INTROUVABLE`) |
Résultat d'opération **`retry`** (R2-01, additif) : échec momentané du serveur (`code` `ERREUR_TEMPORAIRE`), rien n'est écrit ; l'opération se renvoie telle quelle (même `clientId`) à la prochaine synchronisation. Un client qui ne connaît pas ce statut la traite comme une opération sans réponse. Une autre erreur de base devient `rejected` `ERREUR_INTERNE` : le lot n'est plus perdu.
Toute autre combinaison : `rejected` `ENTITE_NON_SYNCHRONISABLE`. **Hors synchronisation** (réseau exigé, REST seulement) : commandes, solde, archivage, rattachement, produit libre → catalogue, catalogue lui-même.
```json
// Une validation arrive après l'annulation par le demandeur : le serveur gagne
{ "results": [ { "clientId": "b1…", "status": "conflict", "code": "TRANSITION_INTERDITE",
                 "current": { /* RequestSyncData : status "Cancelled", statusReason {code "EntryError"} */ } } ] }
// Modification de la date de besoin hors ligne pendant qu'un autre l'a déjà changée
{ "results": [ { "clientId": "c2…", "status": "conflict", "code": "CONFLIT_VERSION", "conflictFields": ["neededBy"], "current": { /* RequestSyncData */ } } ] }
// Livraison hors ligne pour une demande devenue Cancelled : enregistrée, non rattachée
{ "results": [ { "clientId": "d3…", "status": "applied", "resource": { /* DeliverySyncData : requestId null, unattachedReason "RequestNotOpen", number "LIV-023" */ } } ] }
```
**Politique de conflit par entité** (ADR 0011) :
| Entité | Créée hors ligne | Modifiable hors ligne | Politique |
|---|---|---|---|
| `request` | oui | oui : modifier, valider, refuser, annuler, réceptionner | statuts : **le serveur gagne** ; champs `neededBy`, `priority`, `note` (et, tant que `Requested`, produit, quantité, unité, zone) : comparaison à trois valeurs par champ, tout ou rien par opération, **première arrivée retenue**, l'autre dans « À vérifier » ; renvoi : même résultat (journal d'opérations) |
| `delivery` | oui | oui : corriger, annuler | création jamais refusée à cause du statut de la demande (fait de chantier) ; corrections : trois valeurs par champ ; demande `Received` : `conflict` |
| `photo` | oui (métadonnées) | non | ajout seul, idempotent ; binaire par `PUT` |
| commande | non | non | en ligne seulement ; REST `PUT` avec `version` |
| `product`, `supplier` | non | non | lecture seule ; le serveur gagne |

## Écarts avec le skill `contrat-api` (à valider)
1. **Dernière écriture gagne** remplacé par « première arrivée retenue, l'autre à vérifier » pour les champs en désaccord (demande de l'expert métier, ADR 0011).
2. `SyncChange.siteId` nullable ; entités globales `product` et `supplier` (ADR 0012).
3. Résultat de push `conflict` enrichi de `code` et `conflictFields` (additif).
4. Réponses de push en forme de synchronisation (sans `commercial`).
5. Photos : un seul `PUT` complet (pas de reprise par plage), JPEG seulement, pas de miniature (ADR 0013).
6. Liste transversale `GET /requests` en plus des routes imbriquées (file « À valider » du conducteur sur tous ses chantiers).

## Écarts et précisions décidés par le backend (tâches B1 à B4 et B9, 2026-11-25)
**Acceptés** (orchestrateur, 2026-11-25). Le fichier généré [`openapi.json`](openapi.json) fait foi pour les routes livrées (catalogue, réglages, demandes, synchronisation des demandes).
1. **Livré** : produits, fournisseurs, `GET /settings/materials`, demandes, **commandes** (`POST/PUT /requests/{id}/order`, `POST .../order/cancel`), **livraisons** (liste, détail, création, correction, `cancel`, `attach`), **photos du bon** (métadonnées, `PUT`/`GET .../photos/{id}/content`), **suivi** (`GET /follow-up`, vue `late`, filtre `supplierId`), synchronisation `product`, `supplier`, `request`, `delivery` (`create`, `update`, `transition` `cancel`), `photo` (`create`). Démonstration et vérification des générateurs : fait en B11 (écarts 20 à 24).
2. **Permissions** : le catalogue du contrat compte **28** permissions (le plan en annonce 24) ; la matrice codée est exactement ce tableau (test `MaterialPermissionMatrixTests`).
3. **`QuantityAdjusted`** : une validation avec une autre quantité écrit **deux** événements, `QuantityAdjusted` (avec `changes` ancienne → nouvelle) puis `Approved` (statuts), dans cet ordre.
4. **Historique** : l'auteur et l'heure d'un événement sont ceux de l'audit (`createdBy`, `createdAt` du serveur), pas des colonnes en double ; l'ordre des événements d'une même écriture est garanti par des identifiants monotones (`MonotonicGuid`).
5. **Contrainte produit** : la base garantit « au moins un de `productId` et `freeProductName` » (et non « exactement un »), car `link-product` conserve le nom libre une fois le produit du catalogue posé ; « exactement un » reste exigé à la **saisie**.
6. **Zone d'une demande** : `PUT` ne sait pas **retirer** une zone (une clé absente ou nulle ne change rien) ; la synchronisation le sait (`changes.zoneId: null`). Question ouverte pour l'architecte.
7. **Recherche `q`** : numéro, produit du catalogue (insensible à la casse et aux accents) ; pour le **nom libre** et la **remarque**, insensible à la casse seulement (la collation de la base est sensible aux accents).
8. **Journal d'opérations** : `SyncOperationLog` garde aussi `conflictFields` (liste des champs en désaccord) pour qu'un renvoi rende le même conflit ; jamais de contenu.
9. **Réponses de synchronisation** : `RequestSyncData` hérite de la forme de la demande ; `siteCode` y est toujours **absent** et l'historique n'y contient jamais d'événement sensible.
10. **En ligne seulement (REST)** : solde, rattachement d'un produit, archivage et restauration (jamais de `transition` de synchronisation). `settle` n'a que la garde de statut tant que les livraisons n'existent pas (B6 ajoute « au moins une livraison non annulée »).

## Écarts et précisions décidés par le backend (tâches B5 à B8 et B10, 2026-11-25)
**Acceptés** (orchestrateur, 2026-11-25). Le fichier généré [`openapi.json`](openapi.json) fait foi ; ses changements depuis B4 sont **additifs** (nouvelles routes et schémas, champs facultatifs `order`, `hasDeliveryWithoutOrder`, `deliveries[]` des réponses de demande).
11. **Commande** : `clientId` facultatif mais, s'il est présent, idempotent (200 et même commande) ; la commande n'est pas `IHasClientId` (pas de `clientCreatedAt`, jamais créée hors ligne). `PUT /order` : une valeur déjà posée (prix, n° de bon de commande, remarque, date prévue) **se remplace mais ne s'efface pas** (clé absente ou nulle = inchangée). Le changement de prix recalcule `amount` et le montant de chaque livraison (cache `Delivery.Amount`, seul écrivain : `RequestRecalculator`) ; l'événement `OrderCommercialEdited` porte l'ancien et le nouveau prix (« 780.00 » → « 800.00 »), il n'est rendu qu'avec `Prices.View`.
12. **Annulation d'une demande validée avec une livraison retenue** : 422 `TRANSITION_INTERDITE` (« annulez d'abord la livraison »), car une livraison est un fait de chantier. **Solder** exige au moins une livraison non annulée (même code sinon).
13. **Historique d'une livraison** : `StatusRecomputed` porte `reasonCode` = déclencheur (`OrderPlaced`, `DeliveryRegistered`, `DeliveryEdited`, `DeliveryCancelled`, `DeliveryAttached`, `BagMassChanged`) et `reasonNote` = n° de la livraison (« Recalcul suite à l'annulation de LIV-006 » se compose côté client). Un événement de livraison ajoute aussi un événement `Delivery*` sur la demande liée (visible dans l'historique de la demande).
14. **Photos** : `POST .../photos` accepte `contentType` `image/jpeg` seulement (415 sinon) et `sizeBytes` ≤ `Storage:MaxPhotoBytes` (413 sinon) ; l'empreinte du fichier reçu doit égaler `sha256` déclaré (422 `TYPE_FICHIER_REFUSE` sinon, comme un JPEG incohérent). `GET .../content` sans `DeliveryPhotos.View` répond **404** (indiscernable d'une photo inexistante) : le droit est contrôlé dans le service, pas par `[HasPermission]` (test d'architecture : exception déclarée). Réponse `Cache-Control: private, max-age=3600` (le middleware d'en-têtes ne force plus `no-store` quand la route en a posé un). `sizeBytes` d'une photo envoyée devient la taille du fichier stocké (EXIF retiré).
15. **Aucun prix hors `commercial`** : réponses de livraison (`commercial.amount`), de demande (`order.commercial`), de suivi (`commercial.orderedAmount`, `receivedValue`), historique (événement sensible) : un seul constructeur, `CommercialProjection`. Test qui parcourt les routes avec les jetons ChefChantier et ChefEquipe.
16. **Synchronisation** : `RequestSyncData.order` est rempli (sans `commercial`) ; `deliveries[]` n'y figure jamais (entité `delivery`). `DeliverySyncData` n'a ni `commercial`, ni `photos`, ni `missingNote`. `delivery` / `update` : mêmes champs que le `PUT` (`quantity`, `deliveryDate`, `deliveryNoteNumber`, `conformity`, `reserveReasonCode`, `reserveNote`) ; une valeur déjà posée se remplace, elle ne s'efface pas ; conflit = `CONFLIT_VERSION` + `conflictFields`, ou `TRANSITION_INTERDITE` (livraison annulée) / `DEMANDE_NON_OUVERTE` (demande réceptionnée) avec l'état du serveur. `delivery` / `create` : une demande désignée par `requestClientId` inconnu donne `unattachedReason: RequestMissing` ; `requestId` inconnu : `rejected` `INTROUVABLE`.
17. **Vue `late`** : demande `Requested`, `Validated`, `Ordered` ou `PartiallyDelivered`, non archivée, dont `neededBy` est dépassée **ou** dont la commande active a une livraison prévue dépassée (heure d'Algérie). `overdueDays` ne compte que le retard sur `neededBy`.
18. **Suivi** : `toOrderTotals` regroupe par produit du catalogue (une ligne par famille d'unités convertibles, unité par défaut en tête) puis par nom libre normalisé ; `requestCount` compte les demandes de la ligne. `commercial.orderedAmount` = commandes non annulées ; `receivedValue` = montants arrondis des livraisons non annulées rattachées.
19. **Limites connues** : pas de détachement ni de suppression de photo (ADR 0013) ; `PUT /order` et `PUT /deliveries/{id}` ne savent pas effacer une valeur (voir 6 pour la zone d'une demande, même limite).

## Écarts et précisions décidés par le backend (tâche B11, 2026-11-25)
Décision de l'orchestrateur appliquée : amorçage **direct** des entités (auteur `SystemActor`), pas de contexte d'acteur simulé. À valider par l'architecte pour les points 20 à 24.
20. **Démonstration** (`MaterialsDemoSeeder`, après `DemoDataSeeder`) : actif seulement avec `Seed:Demo = true` **et** Development. Écrit 13 produits, 5 fournisseurs (téléphones fictifs `0550 00 00 21` à `25`), 12 demandes et 10 livraisons sur `CH-ECO-UV18`, 1 demande sur `CH-LOG-OL40`, 7 commandes, 1 photo fictive (LIV-006). Les **règles** restent celles du domaine (numéros par `ISiteNumbering`, transitions des entités, historique par `IRequestEventWriter`, statuts, reçus et montants par le seul `RequestRecalculator`) : seule la porte d'entrée (droits, contexte HTTP) est contournée. Événements d'historique de source `System`, auteur `SystemActor`.
21. **Idempotence sans écrasement** : un produit ou fournisseur de même nom normalisé est réutilisé tel quel (même désactivé ou modifié) ; les demandes, commandes et livraisons d'un chantier ne sont écrites **que si ce chantier n'en a aucune** (corbeille comprise), en une seule transaction (tout ou rien, numéros `DEM-001…` sans trou). Un chantier déjà renseigné est laissé tel quel et signalé dans le journal ; pour recharger le jeu : base neuve (`scripts/dev.ps1 -Reset`). Une règle du domaine qui ne s'applique plus (produit désactivé…) ignore le jeu de ce chantier avec un avertissement, sans bloquer le démarrage.
22. **Écart au tableau métier** : LIV-006 porte le n° de bon fictif `BL-SIG-0561` ; les n° de BL et de bon de commande de la démonstration sont fictifs. DEM-011 est volontairement en retard (besoin le 19/11/2026) pour montrer la vue `late`.
23. **Générateurs** (vérifiés le 2026-11-25 sur le `openapi.json` généré) : `@rtk-query/codegen-openapi` reproduit **à l'identique** `chantierApi.ts` du dépôt de travail ; `siteId` nullable est rendu `null | string` (web) et `required String? siteId` (mobile). `swagger_parser` 1.46.0 génère sans erreur (15 clients, 67 requêtes, 136 classes) et **diffère** de `lib/core/api/generated` du dépôt de travail : ce dernier n'a pas été régénéré depuis B5 à B10 (clients `deliveries`, `follow_up`, `photos`… absents, `Quantity` et `*SyncData` à mettre à jour) ; rien n'a été modifié ni commité (arborescence restaurée à l'identique).
24. **Défauts de forme du contrat sur `Quantity`** (vus par les deux générateurs, aucun changement fait) : (a) `value` et `unit` ne sont pas `required` dans le schéma `Quantity` (clients : `value?`, `unit?`) alors que le métier les impose ; (b) dans `RequestSyncData` et `DeliverySyncData` (héritage par copie), `quantity` est **recopié en ligne** au lieu de référencer `#/components/schemas/Quantity` : `swagger_parser` produit les classes jumelles `Quantity`, `Quantity2`, `Quantity3` ; (c) `Quantity?` (`receivedQuantity`, `remainingQuantity`, `quantityInRequestUnit`) est rendue `value: number | string` avec un motif : `dynamic value` côté Dart ; (d) les schémas `RequestSyncData`, `DeliverySyncData`, `SupplierSyncData` ne sont référencés par aucune route (`SyncChange.data` est un `object`) : le web ne les génère pas, le mobile les génère. **Correction proposée (additive, transformateur de schéma backend)** : marquer `value` et `unit` requis, référencer le composant `Quantity` partout, et ne pas élargir les `Quantity?` en nombre ou chaîne. Elle change `openapi.json` : web et mobile devront régénérer (à décider par l'architecte avant Q2).

## Corrections du contrat décidées par l'orchestrateur (2026-11-25)
Écarts 20 à 24 **acceptés** ; pas de `-Reset` de la base de dev.  
25. **Écart 24 corrigé** (additif) : `Quantity.required = [value, unit]` ; `quantity`, `receivedQuantity`, `remainingQuantity` (`RequestSyncData`), `quantity`, `quantityInRequestUnit` (`DeliverySyncData`) et les lignes de `RequestSyncData.deliveries[]` référencent `#/components/schemas/Quantity` (les facultatives : `oneOf [null, Quantity]`, comme dans les réponses REST) ; plus de copie en ligne (`Quantity2`, `Quantity3`), plus de `value` « nombre ou chaîne » ni de motif. `value` reste un nombre JSON (décimal exact côté serveur, aucune conversion). Test `A_quantity_always_has_its_value_and_its_unit_and_is_never_copied_inline`. Reste du point 24 (d) : `RequestSyncData`, `DeliverySyncData` et `SupplierSyncData` ne sont référencés par aucune route (`SyncChange.data` est libre) : le web ne les génère pas ; **à décider par l'architecte** (aucun schéma inventé).
26. **Pull : ordre parents avant enfants** : la synchronisation ordonne par version seulement ; un chantier retouché après ses zones/demandes arrive donc sur une page suivante. Correction sûre côté serveur : dans une page, `changes` est rangé par rang (`site`, `product`, `supplier` ; `zone`, `member` ; `request` ; `delivery` ; `photo`) puis par version (le curseur ne change pas). **Entre deux pages, aucun ordre n'est garanti** (garantir un parent par page imposerait de renvoyer des lignes déjà ou pas encore dues, donc de changer la pagination) : le mobile applique tout le pull avant de contrôler ses clés étrangères, ou met de côté la ligne dont le parent manque et la rejoue en fin de pull. Documenté dans `socle.md` (section Pull).
27. **Autres formes recopiées en ligne** (non corrigées, hors décision) : dans `RequestSyncData` et `DeliverySyncData`, les enums (`status`, `priority`, `conformity`, `unattachedReason`) et objets (`product`, `order`, `history[]`, `variance`, `reserve`, `cancelReason`, `statusReason`, `possibleDuplicateOf`, `photos[]`) sont aussi recopiés en ligne au lieu de référencer `RequestStatus`, `Priority`, `ProductRefResponse`, `RequestHistoryItem`, `VarianceResponse`, etc. (même cause que 24 b). Même correction possible, mais elle renomme des classes générées côté mobile : à décider avant de la faire.

## Corrections de la revue R2 (2026-11-25, `docs/revues/demandes-materiaux-livraisons.md`)
Tous les changements sont **additifs ou de comportement**, aucun champ renommé ni supprimé. Chaque ligne : avant → après.
28. **R2-01, interblocages.** Avant : deux commandes simultanées sur des demandes différentes pouvaient s'interbloquer (SQL 1205) → 500 `ERREUR_INTERNE` ; une `SqlException` dans un lot de push faisait perdre toute la réponse. Après : la base passe en `READ_COMMITTED_SNAPSHOT` (migration `EnableReadCommittedSnapshot`, **demande une base sans autre connexion au moment de l'application**), toute transaction victime d'un interblocage est rejouée jusqu'à 4 fois, un échec momentané qui subsiste donne **503 `ERREUR_TEMPORAIRE`** (`Retry-After: 1`, rien n'est écrit) et, en push, un résultat d'opération **`retry`** (nouveau statut de `SyncPushResult.status`, `code` `ERREUR_TEMPORAIRE`) ; les autres erreurs de base donnent `rejected` `ERREUR_INTERNE` pour cette opération seulement. Le lot garde un résultat par opération.
29. **R2-02, synchronisation.** Avant : `history[]` complet dans chaque ligne `request` et `delivery` (34 % du volume), toute l'histoire du chantier, et une affectation retouchait toutes les lignes. Après : `history` est **toujours `[]`** dans les lignes de synchronisation et les résultats de push (`resource`, `current`) ; il se lit par `GET /requests/{id}` et `GET /deliveries/{id}` (en ligne). Fenêtre `Sync:ClosedRetentionDays` = 60 (voir plus haut) ; l'affectation ne touche que la fenêtre. La clé `history` reste présente (tableau vide) : un décodeur existant ne casse pas. **Mobile** : l'écran de détail n'a plus d'historique hors ligne (à afficher en ligne).
30. **R2-04.** Avant : 6 `PUT .../content` identiques en parallèle → 1 × 200 et 5 × 409 `CONFLIT_VERSION`. Après : 6 × 200 (relecture après le verrou, rejeu sur conflit de version). Le mobile peut garder « 200 ou `PHOTO_DEJA_ENVOYEE` ».
31. **R2-03.** Avant : seuls `APP1` et `APP13` d'avant le premier balayage étaient retirés. Après : liste blanche et coupure à la fin d'image (voir « Photos »). Un fichier à images secondaires (MPF Pixel et Samsung) est stocké **réduit à son image principale** ; `sizeBytes` de la réponse est la taille stockée.
32. **R2-05.** `photoCount` et `missingNote` ne comptent plus les photos `Pending` (Avant : une métadonnée sans fichier effaçait « BL manquant »). Quota : 5 = photos reçues + envois `Pending` de moins de 24 h. Migration de données `RecountDeliveryPhotos` : recalcule `Deliveries.PhotoCount` (aucune perte). **Mobile** : ne pas déduire « BL présent » d'une ligne `photo` `Pending`.
33. **R2-08.** Index `IX_MaterialRequests_RowVersion`, `IX_Deliveries_RowVersion`, `IX_Photos_RowVersion` (migration `AddPullRowVersionIndexes`) : le pull d'un Admin ne balaie plus la table.
34. **R2-11.** `GET .../photos/{id}/content` : `Cache-Control: private, max-age=3600` → `private, no-cache` + `ETag` ; `304` ajouté à la documentation de la route.
35. **R2-09 (risque accepté, documenté).** `order.note`, motifs libres « Autre » : le texte libre ne peut pas être filtré sans rendre le champ inutilisable (faux positifs sur « 20 sacs », « 10 h », « 8 % de remise » indiscernable de « 8 % d'humidité »). La description du champ `note` de `OrderResponse` dit qu'il est visible des rôles terrain ; consigne d'aide à afficher dans le formulaire de commande (web) et dans le manuel Achats.
36. **R2-10.** Maintenance périodique `PhotoMaintenance` (première passe 5 min après le démarrage, puis toutes les 60 min ; `Storage:MaintenanceIntervalMinutes = 0` la désactive) : supprime les `.staging/*.part` de plus de 60 min, supprime (logiquement) les photos `Pending` de plus de 7 jours, **signale sans rien supprimer** les photos reçues sans fichier et les fichiers sans ligne, purge `SyncOperationLogs` à 90 jours (`Sync:OperationLogRetentionDays`). En production, `Storage:PhotosRoot` doit être un chemin **absolu hors du dossier de l'application** : le démarrage est refusé sinon.

## Corrections de la boucle 1/2 (QA et revue R2 bis, 2026-11-26)
Additif ou de comportement ; avant → après.
37. **D-1 (QA).** Avant : 1 milliard de tonnes converties en kg × le prix maximal dépassait `decimal(18,2)` et donnait **500** `ERREUR_INTERNE` à l'écriture de la livraison. Après : **422 `QUANTITE_INVALIDE`** (message : quantité reçue convertie hors limite). Limites : quantité convertie ≤ 999 999 999 999 999,999 et montant ≤ 9 999 999 999 999 999,99 (colonnes). Même contrôle dans le recalcul (cumul reçu, valeur reçue). En synchronisation : `rejected` `QUANTITE_INVALIDE`.
38. **R3-01.** Avant : après un résultat `retry` sur une création, les opérations suivantes du même lot qui la visaient étaient quand même traitées (INTROUVABLE, ou ordre rompu). Après : toute opération qui partage une ressource avec une opération `retry` (son `clientId`, ou `requestId`, `requestClientId`, `deliveryId`, `deliveryClientId`, `zoneId`, `zoneClientId` du `payload`) reçoit **`retry` `ERREUR_TEMPORAIRE` sans être traitée**, dans l'ordre, transitivement (création de demande, sa modification, la livraison qui la référence, la photo de cette livraison). Les opérations sans lien sont traitées normalement. Le client renvoie les opérations `retry` **dans le même ordre**.
39. **R3-05.** Nouveau champ **`resetRequired`** (booléen, absent quand faux) dans la réponse du pull. Vrai quand, depuis le curseur reçu (`since` non vide), des demandes ou livraisons visibles ont changé **et sont aujourd'hui hors de la fenêtre de 60 jours** : le téléphone peut garder une demande qu'il croit ouverte alors qu'elle est close depuis longtemps, sans jamais recevoir de pierre tombale. Conduite du client : vider ses données de synchronisation (**pas la file d'envoi**), recommencer avec `since` vide, et **ignorer `resetRequired` jusqu'à la fin de ce pull complet** (un pull depuis zéro le voit forcément). La page reçue reste valide : un client qui ignore le signal continue de se synchroniser. Exact et sans état : un téléphone à jour ne reçoit jamais le signal ; `since` vide non plus.
40. **S-1.** Au démarrage, un avertissement journalisé (`READ_COMMITTED_SNAPSHOT est inactif sur la base…`) si le versionnement n'est pas actif ; aucun refus de démarrer.
