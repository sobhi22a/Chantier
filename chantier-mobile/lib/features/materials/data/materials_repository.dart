import 'dart:convert';

import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/utils/stream_combine.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/database/tables/user_prefs.dart';
import 'package:chantier_mobile/features/materials/data/materials_sync_decoder.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_settings.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/sites/data/sync_decoder.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;

/// Resultat de l'enregistrement d'une demande saisie hors ligne.
sealed class RequestSaveResult {
  const RequestSaveResult();
}

/// Enregistree sur le telephone, en attente d'envoi.
final class RequestSaved extends RequestSaveResult {
  const RequestSaved(this.row);

  final MaterialRequestRow row;
}

/// Le meme formulaire a deja ete enregistre (double appui) : rien n'est ecrit une seconde fois.
final class RequestAlreadySaved extends RequestSaveResult {
  const RequestAlreadySaved();
}

/// Aucune valeur n'a change : aucune operation n'est ajoutee.
final class RequestUnchanged extends RequestSaveResult {
  const RequestUnchanged();
}

/// La saisie est en cours d'envoi : elle ne peut plus etre corrigee ici (reessayer apres l'envoi).
final class RequestBusy extends RequestSaveResult {
  const RequestBusy();
}

/// Resultat d'une action de statut (valider, refuser, annuler, receptionner).
enum QueueResult {
  /// L'operation est dans la file d'envoi.
  queued,

  /// La meme action attend deja son envoi (double appui) : rien n'est ajoute.
  alreadyQueued,
}

/// Demandes de materiaux, catalogue et reglages : **lecture dans la base locale**, ecriture
/// locale + operation d'envoi dans UNE transaction (ADR 0009, 0011), jamais le reseau.
///
/// Aucun prix, aucun telephone ne passe ici (ADR 0012).
class MaterialsRepository {
  MaterialsRepository({
    required AppDatabase database,
    required OutboxRepository outbox,
    DateTime Function()? now,
    this.onLocalWrite,
    this.listThrottle = Duration.zero,
  }) : _db = database,
       _outbox = outbox,
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final OutboxRepository _outbox;
  final DateTime Function() _now;

  /// Appele apres un enregistrement : declenche l'envoi 2 s plus tard (`SyncScheduler`).
  final void Function()? onLocalWrite;

  /// Fenetre de regroupement des emissions de la liste (R2-07) : nulle dans les tests, 300 ms en
  /// production.
  final Duration listThrottle;

  // --- Lecture ---------------------------------------------------------------------------------

  /// Demandes du chantier avec leurs saisies en attente (surcouche provisoire), les plus
  /// recentes en premier. L'interface en tire ses vues (`filterRequests`).
  ///
  /// Les livraisons saisies hors ligne, corrigees ou annulees comptent tout de suite dans le recu,
  /// le reste et le statut **provisoires** (« a confirmer », CA-MAT-006.7) ; le serveur recalcule
  /// et remplace toujours cette valeur.
  ///
  /// Liste **legere** (R2-07) : `history_json` n'est pas lu, et les emissions
  /// rapprochees d'une synchronisation sont regroupees ([listThrottle]).
  Stream<List<RequestView>> watchRequests(String siteId, String userId) =>
      throttleLatest(
        combineLatestAll<List<RequestView>>([
          _db.materialRequestsDao.watchBySiteLight(siteId),
          _outbox.watch(userId),
          _db.deliveriesDao.watchBySiteLight(siteId),
          _db.productsDao.watchAll(),
          watchSettings(),
        ], (values) => _overlayAll(values)),
        listThrottle,
      );

  /// Une demande avec ses saisies en attente ; `null` si elle n'existe plus sur le telephone.
  Stream<RequestView?> watchRequest(String id, String userId) =>
      combineLatestAll<RequestView?>(
        [
          _db.materialRequestsDao.watchById(id),
          _outbox.watch(userId),
          _db.deliveriesDao.watchByRequest(id),
          _db.productsDao.watchAll(),
          watchSettings(),
        ],
        (values) {
          final row = values[0] as MaterialRequestRow?;
          if (row == null) return null;
          return _overlayAll([
            [row],
            ...values.skip(1),
          ]).first;
        },
      );

  /// [values] : demandes, saisies en attente, livraisons, produits, reglages (dans cet ordre).
  static List<RequestView> _overlayAll(List<Object?> values) {
    final rows = values[0]! as List<MaterialRequestRow>;
    final operations = values[1]! as List<OutboxRow>;
    final deliveries = values[2]! as List<DeliveryRow>;
    final products = values[3]! as List<ProductRow>;
    final settings = values[4]! as MaterialSettings;

    final requestOperations = [
      for (final op in operations)
        if (op.isRequestOperation) op,
    ];
    final groups = groupByRequest(
      deliveryViews(deliveries, operations, const []),
    );
    final bagMass = {
      for (final product in products)
        if (product.bagMassKg != null) product.id: product.bagMassKg!,
    };
    return [
      for (final row in rows)
        _withDeliveries(
          overlayRequest(row, requestOperations),
          groups,
          bagMass,
          settings,
        ),
    ];
  }

  static RequestView _withDeliveries(
    RequestView view,
    Map<String, List<DeliveryView>> groups,
    Map<String, Decimal> bagMass,
    MaterialSettings settings,
  ) {
    final mine = deliveriesOfRequest(groups, view);
    if (mine.isEmpty) return view;
    return applyDeliveries(
      view,
      mine,
      bagMassKg: bagMass[view.row.productId],
      tolerancePercent: settings.toleranceOrZero,
    );
  }

  /// Ligne locale de la demande visee par une saisie de la file d'envoi (identifiant serveur ou
  /// `clientId`) ; `null` si elle a disparu du telephone.
  Future<MaterialRequestRow?> requestFor(OutboxRow operation) async {
    final ref = operation.requestRef;
    if (ref == null) return null;
    final id = ref.requestId;
    if (id != null) return _db.materialRequestsDao.getById(id);
    final siteId = operation.siteId;
    final clientId = ref.requestClientId;
    if (siteId == null || clientId == null) return null;
    return _db.materialRequestsDao.findByClientId(siteId, clientId);
  }

  Stream<List<ProductRow>> watchProducts() => _db.productsDao.watchAll();

  /// Fournisseurs actifs du catalogue (sans telephone : jamais stocke, ADR 0012).
  Stream<List<SupplierRow>> watchSuppliers() => _db.suppliersDao.watchAll();

  Future<ProductRow?> getProduct(String id) => _db.productsDao.getById(id);

  /// Les produits les plus demandes sur ce chantier (tuiles de « Nouvelle demande »), calcules
  /// localement (CA-MAT-001.12).
  Future<List<ProductRow>> topProducts(String siteId, {int limit = 6}) async {
    final ids = await _db.materialRequestsDao.topProductIds(
      siteId,
      limit: limit,
    );
    final products = <ProductRow>[];
    for (final id in ids) {
      final product = await _db.productsDao.getById(id);
      if (product != null && product.isActive) products.add(product);
    }
    return products;
  }

  /// Demande locale designee par le `clientId` de sa creation (saisie en attente ou confirmee).
  Future<MaterialRequestRow?> findRequestByClientId(
    String siteId,
    String clientId,
  ) => _db.materialRequestsDao.findByClientId(siteId, clientId);

  Future<List<MaterialRequestRow>> requestsOf(String siteId) =>
      _db.materialRequestsDao.watchBySite(siteId).first;

  /// Reglages du serveur (derniere copie), ou valeurs par defaut avant la premiere synchronisation.
  Stream<MaterialSettings> watchSettings() => _db.appSettingsDao
      .watch(MaterialSettings.storageKey)
      .map(MaterialSettings.fromStorage);

  Future<MaterialSettings> settings() async => MaterialSettings.fromStorage(
    await _db.appSettingsDao.get(MaterialSettings.storageKey),
  );

  // --- Creation et correction --------------------------------------------------------------------

  /// Enregistre une nouvelle demande : ligne locale « numero en attente » **et** operation
  /// `request/create` dans la meme transaction. [clientId] est cree a l'ouverture du formulaire :
  /// un double appui ne cree rien de plus. [replacing] : « Creer une nouvelle demande avec mes
  /// valeurs » / « Corriger », l'ancienne saisie refusee et sa ligne locale sont remplacees.
  Future<RequestSaveResult> createRequest({
    required String clientId,
    required String siteId,
    required String userId,
    required String requesterName,
    required RequestDraft draft,
    required String label,
    ProductRow? product,
    OutboxRow? replacing,
  }) async {
    final now = _now().toUtc();
    final row = MaterialRequestRow(
      id: clientId,
      siteId: siteId,
      clientId: clientId,
      productId: draft.productId,
      productName: product?.nameFr,
      productNameAr: product?.nameAr,
      freeProductName: draft.freeProductName,
      quantityValue: draft.quantity.value,
      quantityUnit: draft.quantity.unit.code,
      zoneId: draft.zoneId,
      neededBy: draft.neededBy,
      priority: draft.priority.code,
      note: _blankToNull(draft.note),
      status: RequestStatus.requested.code,
      isSettled: false,
      hasDeliveryWithoutOrder: false,
      requestedById: userId,
      requestedByName: requesterName,
      version: 0,
      clientCreatedAt: now,
      isPending: true,
      createdAt: now,
      createdByName: requesterName,
    );
    final saved = await _outbox.saveWithOperation(
      operation: OutboxOperationsCompanion.insert(
        clientId: clientId,
        ownerUserId: userId,
        entity: RequestEntity.name,
        operation: RequestEntity.create,
        siteId: Value(siteId),
        label: label,
        payloadJson: jsonEncode(RequestPayloads.create(draft, now)),
        createdAt: now,
      ),
      localWrite: () async {
        if (replacing != null) await _outbox.abandon(replacing);
        await _db.materialRequestsDao.insertPending(row);
        final zoneId = draft.zoneId;
        if (zoneId != null) {
          await _db.userPrefsDao.set(userId, UserPrefKeys.lastZoneId, zoneId);
        }
      },
    );
    if (!saved) return const RequestAlreadySaved();
    onLocalWrite?.call();
    return RequestSaved(row);
  }

  /// Corrige une demande (quantite, zone, date, urgence, remarque).
  ///
  /// * demande **jamais envoyee** : la saisie en attente est simplement modifiee (ligne locale et
  ///   operation `create`, meme transaction) ;
  /// * demande connue du serveur : une operation `request/update` est ajoutee, avec la valeur de
  ///   depart de chaque champ modifie (comparaison a trois valeurs du serveur, ADR 0011).
  Future<RequestSaveResult> editRequest({
    required RequestView view,
    required RequestDraft draft,
    required String userId,
    required String clientId,
    required String label,
    OutboxRow? replacing,
  }) async {
    if (view.isNotYetSent) return _editPending(view, draft, label);

    final edit = RequestEdit.diff(view.row, draft);
    if (edit.isEmpty) {
      if (replacing != null) await _outbox.abandon(replacing);
      return const RequestUnchanged();
    }
    final now = _now().toUtc();
    final saved = await _outbox.saveWithOperation(
      operation: OutboxOperationsCompanion.insert(
        clientId: clientId,
        ownerUserId: userId,
        entity: RequestEntity.name,
        operation: RequestEntity.update,
        siteId: Value(view.stored.siteId),
        label: label,
        payloadJson: jsonEncode(
          RequestPayloads.update(
            ref: RequestRef.of(view.stored),
            now: now,
            changes: edit.changes,
            base: edit.base,
          ),
        ),
        baseVersion: Value(
          view.stored.version > 0 ? view.stored.version : null,
        ),
        createdAt: now,
      ),
      localWrite: () async {
        if (replacing != null) await _outbox.abandon(replacing);
      },
    );
    if (!saved) return const RequestAlreadySaved();
    onLocalWrite?.call();
    return RequestSaved(view.stored);
  }

  Future<RequestSaveResult> _editPending(
    RequestView view,
    RequestDraft draft,
    String label,
  ) async {
    final row = view.stored;
    final createOperation = await _db.outboxDao.getByClientId(row.id);
    if (createOperation == null ||
        createOperation.status != OutboxStatus.pending) {
      return const RequestBusy();
    }
    final firstSavedAt =
        DateTime.tryParse('${createOperation.payload['clientCreatedAt']}') ??
        _now();
    final next = row.copyWith(
      quantityValue: draft.quantity.value,
      quantityUnit: draft.quantity.unit.code,
      zoneId: Value(draft.zoneId),
      neededBy: draft.neededBy,
      priority: draft.priority.code,
      note: Value(_blankToNull(draft.note)),
    );
    final replaced = await _db.transaction(() async {
      final done = await _db.outboxDao.replacePendingPayload(
        createOperation.id,
        payloadJson: jsonEncode(RequestPayloads.create(draft, firstSavedAt)),
        label: label,
      );
      if (done) await _db.materialRequestsDao.replacePending(next);
      return done;
    });
    if (!replaced) return const RequestBusy();
    onLocalWrite?.call();
    return RequestSaved(next);
  }

  // --- Actions de statut ---------------------------------------------------------------------------

  /// Valider (conducteur), eventuellement avec une autre [quantity] (meme unite).
  Future<QueueResult> approve({
    required RequestView view,
    required String userId,
    required String clientId,
    required String label,
    Quantity? quantity,
  }) => _transition(
    view: view,
    userId: userId,
    clientId: clientId,
    label: label,
    action: RequestEntity.approve,
    quantity: quantity,
  );

  Future<QueueResult> reject({
    required RequestView view,
    required String userId,
    required String clientId,
    required String label,
    required String reasonCode,
    String? reasonNote,
  }) => _transition(
    view: view,
    userId: userId,
    clientId: clientId,
    label: label,
    action: RequestEntity.reject,
    reasonCode: reasonCode,
    reasonNote: reasonNote,
  );

  /// « Receptionner » (ChefChantier) : une demande livree passe a receptionnee (1 geste).
  Future<QueueResult> receive({
    required RequestView view,
    required String userId,
    required String clientId,
    required String label,
  }) => _transition(
    view: view,
    userId: userId,
    clientId: clientId,
    label: label,
    action: RequestEntity.receive,
  );

  Future<QueueResult> cancel({
    required RequestView view,
    required String userId,
    required String clientId,
    required String label,
    required String reasonCode,
    String? reasonNote,
  }) => _transition(
    view: view,
    userId: userId,
    clientId: clientId,
    label: label,
    action: RequestEntity.cancel,
    reasonCode: reasonCode,
    reasonNote: reasonNote,
  );

  Future<QueueResult> _transition({
    required RequestView view,
    required String userId,
    required String clientId,
    required String label,
    required String action,
    Quantity? quantity,
    String? reasonCode,
    String? reasonNote,
  }) async {
    // Une seule action de statut en attente par demande : un double appui, ou un « valider »
    // apres un « refuser » non envoye, n'ajoute rien (le serveur tranche de toute facon).
    final queued = await _db.outboxDao.allFor(userId);
    final already = queued.any(
      (op) =>
          op.transitionAction != null &&
          op.targets(view.stored) &&
          (op.status == OutboxStatus.pending ||
              op.status == OutboxStatus.sending),
    );
    if (already) return QueueResult.alreadyQueued;

    final now = _now().toUtc();
    final saved = await _outbox.saveWithOperation(
      operation: OutboxOperationsCompanion.insert(
        clientId: clientId,
        ownerUserId: userId,
        entity: RequestEntity.name,
        operation: RequestEntity.transition,
        siteId: Value(view.stored.siteId),
        label: label,
        payloadJson: jsonEncode(
          RequestPayloads.transition(
            ref: RequestRef.of(view.stored),
            now: now,
            action: action,
            quantity: quantity,
            reasonCode: reasonCode,
            reasonNote: reasonNote,
          ),
        ),
        baseVersion: Value(
          view.stored.version > 0 ? view.stored.version : null,
        ),
        createdAt: now,
      ),
      // Le statut affiche est provisoire (surcouche) : la ligne locale reste celle du serveur.
      localWrite: () async {},
    );
    if (!saved) return QueueResult.alreadyQueued;
    onLocalWrite?.call();
    return QueueResult.queued;
  }

  // --- Synchronisation --------------------------------------------------------------------------------

  /// Reglages recus de `GET /settings/materials` : derniere copie gardee pour le hors ligne.
  Future<void> saveSettings(MaterialSettings settings) =>
      _db.appSettingsDao.set(MaterialSettings.storageKey, settings.toStorage());

  /// Resultat `applied` ou `duplicate` d'une operation `request` : la ressource du serveur
  /// remplace la ligne locale (meme `clientId`), sans doublon. Leve `SyncDecodeException` si la
  /// ressource est illisible.
  Future<void> applyPushedRequest(Object? resource) async {
    await _db.materialRequestsDao.upsertIfNewer(
      decodeRequestResource(resource),
    );
  }

  /// Etat du serveur renvoye avec un `conflict` : la ligne locale le suit (le serveur gagne).
  /// Une reponse illisible est ignoree ici : l'ecran « A verifier » garde ce qu'il peut afficher.
  Future<void> applyServerState(Object? current) async {
    if (current == null) return;
    try {
      await _db.materialRequestsDao.upsertIfNewer(
        decodeRequestResource(current),
      );
    } on SyncDecodeException {
      return;
    }
  }

  /// Resultat `applied` ou `duplicate` d'une operation `delivery` : la ressource du serveur
  /// remplace la ligne locale (meme `clientId`), les photos qui la designaient sont rattachees a
  /// son identifiant. Leve `SyncDecodeException` si la ressource est illisible.
  Future<void> applyPushedDelivery(Object? resource) async {
    await _db.deliveriesDao.upsertIfNewer(decodeDeliveryResource(resource));
  }

  /// Etat du serveur renvoye avec un `conflict` de livraison : la ligne locale le suit (le serveur
  /// gagne). Une reponse illisible est ignoree ici.
  Future<void> applyServerDelivery(Object? current) async {
    if (current == null) return;
    try {
      await _db.deliveriesDao.upsertIfNewer(decodeDeliveryResource(current));
    } on SyncDecodeException {
      return;
    }
  }

  /// Resultat `applied` ou `duplicate` d'une operation `photo` / `create` : les metadonnees du
  /// serveur remplacent la ligne locale. Le fichier part ensuite (`PhotoUploadService`).
  Future<void> applyPushedPhoto(Object? resource) async {
    await _db.deliveryPhotosDao.upsertIfNewer(decodePhotoResource(resource));
  }

  static String? _blankToNull(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
