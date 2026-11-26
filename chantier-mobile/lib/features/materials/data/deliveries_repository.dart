import 'dart:convert';

import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/utils/stream_combine.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart'
    show QueueResult;
import 'package:chantier_mobile/features/materials/data/photo_files.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:drift/drift.dart' show Value;

/// Resultat de l'enregistrement d'une livraison saisie hors ligne.
sealed class DeliverySaveResult {
  const DeliverySaveResult();
}

/// Enregistree sur le telephone, en attente d'envoi.
final class DeliverySaved extends DeliverySaveResult {
  const DeliverySaved(this.row);

  final DeliveryRow row;
}

/// Le meme formulaire a deja ete enregistre (double appui) : rien n'est ecrit une seconde fois.
final class DeliveryAlreadySaved extends DeliverySaveResult {
  const DeliveryAlreadySaved();
}

/// Aucune valeur n'a change : aucune operation n'est ajoutee.
final class DeliveryUnchanged extends DeliverySaveResult {
  const DeliveryUnchanged();
}

/// La saisie est en cours d'envoi : elle ne peut plus etre corrigee ici (reessayer apres l'envoi).
final class DeliveryBusy extends DeliverySaveResult {
  const DeliveryBusy();
}

/// Plus de photos que la limite du serveur (5 par livraison) : aucune n'est enregistree.
final class DeliveryTooManyPhotos extends DeliverySaveResult {
  const DeliveryTooManyPhotos();
}

/// Livraisons et photos de bons : **lecture dans la base locale**, ecriture locale + operations
/// d'envoi dans UNE transaction (ADR 0009, 0011, 0013), jamais le reseau.
///
/// Aucun prix, aucun montant, aucun telephone ne passe ici (ADR 0012) : la valeur d'une livraison
/// est calculee par le serveur et reservee a `Prices.View`.
class DeliveriesRepository {
  DeliveriesRepository({
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

  /// Fenetre de regroupement des emissions de la liste (R2-07).
  final Duration listThrottle;

  // --- Lecture ---------------------------------------------------------------------------------

  /// Livraisons du chantier avec leurs saisies en attente (surcouche provisoire) et leur nombre de
  /// photos, les plus recentes d'abord.
  Stream<List<DeliveryView>> watchDeliveries(String siteId, String userId) =>
      throttleLatest(
        combineLatestAll<List<DeliveryView>>(
          [
            _db.deliveriesDao.watchBySiteLight(siteId),
            _outbox.watch(userId),
            _db.deliveryPhotosDao.watchBySite(siteId),
          ],
          (values) => deliveryViews(
            values[0]! as List<DeliveryRow>,
            values[1]! as List<OutboxRow>,
            values[2]! as List<DeliveryPhotoRow>,
          ),
        ),
        listThrottle,
      );

  /// Une livraison avec ses saisies en attente ; `null` si elle n'existe plus sur le telephone.
  Stream<DeliveryView?> watchDelivery(String id, String userId) =>
      combineLatestAll<DeliveryView?>(
        [
          _db.deliveriesDao.watchById(id),
          _outbox.watch(userId),
          _db.deliveryPhotosDao.watchByDelivery(id),
        ],
        (values) {
          final row = values[0] as DeliveryRow?;
          if (row == null) return null;
          final operations = values[1]! as List<OutboxRow>;
          final photos = values[2]! as List<DeliveryPhotoRow>;
          return overlayDelivery(row, operations).withPhotoCount(photos.length);
        },
      );

  /// Photos d'une livraison (envoyees ou en attente), dans l'ordre de prise.
  Stream<List<DeliveryPhotoRow>> watchPhotos(String deliveryId) =>
      _db.deliveryPhotosDao.watchByDelivery(deliveryId);

  /// Fichiers de photos en attente d'envoi du proprietaire (« Photo en attente d'envoi (2) »).
  Stream<List<PendingPhotoFileRow>> watchPendingFiles(String ownerUserId) =>
      _db.deliveryPhotosDao.watchFiles(ownerUserId);

  /// « Abandonner » une photo refusee ou perdue (apres confirmation de l'utilisateur) : sa ligne
  /// locale, son fichier a envoyer et le fichier du disque. Rien n'est supprime sans cette decision.
  Future<void> abandonPhotoFile({
    required String ownerUserId,
    required PendingPhotoFileRow file,
    required Future<void> Function(String relativePath) deleteFile,
  }) async {
    await _db.transaction(() async {
      final local = await _db.deliveryPhotosDao.findByClientId(
        file.siteId,
        file.clientId,
      );
      if (local != null) await _db.deliveryPhotosDao.deletePhoto(local.id);
      await _db.deliveryPhotosDao.deleteFile(file.clientId);
    });
    await deleteFile(file.relativePath);
  }

  Future<List<DeliveryRow>> deliveriesOf(String siteId) =>
      _db.deliveriesDao.watchBySite(siteId).first;

  Future<DeliveryRow?> findDelivery(String id) => _db.deliveriesDao.getById(id);

  /// Ligne locale de la livraison visee par une saisie de la file d'envoi (identifiant serveur ou
  /// `clientId`) ; `null` si elle a disparu du telephone.
  Future<DeliveryRow?> deliveryFor(OutboxRow operation) async {
    final ref = operation.deliveryRef;
    if (ref == null) return null;
    final id = ref.deliveryId;
    if (id != null) return _db.deliveriesDao.getById(id);
    final siteId = operation.siteId;
    final clientId = ref.deliveryClientId;
    if (siteId == null || clientId == null) return null;
    return _db.deliveriesDao.findByClientId(siteId, clientId);
  }

  /// Nombre de photos deja prises pour une livraison (envoyees ou en attente).
  Future<int> photoCount(String deliveryId) =>
      _db.deliveryPhotosDao.countByDelivery(deliveryId);

  // --- Creation --------------------------------------------------------------------------------

  /// Enregistre une livraison : ligne locale « numero en attente », operation `delivery` /
  /// `create` et, pour chaque photo, ses metadonnees (`photo` / `create`), sa ligne locale et son
  /// fichier a envoyer, **dans la meme transaction**. [clientId] est cree a l'ouverture du
  /// formulaire : un double appui ne cree rien de plus.
  ///
  /// [request] : la demande de la livraison (produit force), [product] : produit d'une livraison
  /// sans demande, [supplier] : fournisseur du catalogue. [quantityInRequest] : equivalent dans
  /// l'unite de la demande (affichage « 10 T = 200 sacs »), calcule par le miroir.
  Future<DeliverySaveResult> record({
    required String clientId,
    required String siteId,
    required String userId,
    required String recorderName,
    required DeliveryDraft draft,
    required String label,
    required String photoLabel,
    required int maxPhotos,
    MaterialRequestRow? request,
    ProductRow? product,
    SupplierRow? supplier,
    Quantity? quantityInRequest,
    List<CapturedPhoto> photos = const [],
    OutboxRow? replacing,
  }) async {
    if (photos.length > maxPhotos) return const DeliveryTooManyPhotos();
    final now = _now().toUtc();
    final row = DeliveryRow(
      id: clientId,
      siteId: siteId,
      clientId: clientId,
      requestId: request == null ? null : (request.clientId ?? request.id),
      unattachedReason: draft.request == null ? 'NoRequestChosen' : null,
      supplierId: draft.supplierId,
      supplierName: supplier?.name,
      freeSupplierName: draft.freeSupplierName,
      productId: request?.productId ?? draft.productId,
      productName: request?.productName ?? product?.nameFr,
      productNameAr: request?.productNameAr ?? product?.nameAr,
      freeProductName: request?.freeProductName ?? draft.freeProductName,
      quantityValue: draft.quantity.value,
      quantityUnit: draft.quantity.unit.code,
      quantityInRequestValue: quantityInRequest?.value,
      quantityInRequestUnit: quantityInRequest?.unit.code,
      deliveryDate: draft.deliveryDate,
      deliveryNoteNumber: normalizeNoteNumber(draft.deliveryNoteNumber),
      conformity: draft.conformity.code,
      reserveReasonCode: draft.conformity == Conformity.withReserve
          ? draft.reserveReasonCode
          : null,
      reserveNote: draft.conformity == Conformity.withReserve
          ? _blankToNull(draft.reserveNote)
          : null,
      status: DeliveryStatus.recorded.code,
      version: 0,
      clientCreatedAt: now,
      isPending: true,
      createdAt: now,
      createdByName: recorderName,
    );

    final operations = <OutboxOperationsCompanion>[
      OutboxOperationsCompanion.insert(
        clientId: clientId,
        ownerUserId: userId,
        entity: DeliveryEntity.name,
        operation: DeliveryEntity.create,
        siteId: Value(siteId),
        label: label,
        payloadJson: jsonEncode(DeliveryPayloads.create(draft, now)),
        createdAt: now,
      ),
      for (final photo in photos)
        _photoOperation(
          photo: photo,
          ref: DeliveryRef.client(clientId),
          siteId: siteId,
          userId: userId,
          label: photoLabel,
          now: now,
        ),
    ];

    final saved = await _outbox.saveWithOperations(
      operations: operations,
      localWrite: () async {
        if (replacing != null) await _outbox.abandon(replacing);
        await _db.deliveriesDao.insertPending(row);
        for (final photo in photos) {
          await _writePhoto(
            photo: photo,
            deliveryId: clientId,
            siteId: siteId,
            userId: userId,
            now: now,
          );
        }
      },
    );
    if (!saved) return const DeliveryAlreadySaved();
    onLocalWrite?.call();
    return DeliverySaved(row);
  }

  /// Ajoute des photos du bon a une livraison **deja enregistree** (« on peut completer plus
  /// tard », CA-MAT-007.7) : au plus [maxPhotos] au total, une operation `photo` / `create` par
  /// photo.
  Future<DeliverySaveResult> addPhotos({
    required DeliveryView view,
    required String userId,
    required List<CapturedPhoto> photos,
    required String photoLabel,
    required int maxPhotos,
  }) async {
    if (photos.isEmpty) return const DeliveryUnchanged();
    final existing = await photoCount(view.stored.id);
    if (existing + photos.length > maxPhotos) {
      return const DeliveryTooManyPhotos();
    }
    final now = _now().toUtc();
    final ref = DeliveryRef.of(view.stored);
    final saved = await _outbox.saveWithOperations(
      operations: [
        for (final photo in photos)
          _photoOperation(
            photo: photo,
            ref: ref,
            siteId: view.stored.siteId,
            userId: userId,
            label: photoLabel,
            now: now,
          ),
      ],
      localWrite: () async {
        for (final photo in photos) {
          await _writePhoto(
            photo: photo,
            deliveryId: view.stored.id,
            siteId: view.stored.siteId,
            userId: userId,
            now: now,
          );
        }
      },
    );
    if (!saved) return const DeliveryAlreadySaved();
    onLocalWrite?.call();
    return DeliverySaved(view.stored);
  }

  OutboxOperationsCompanion _photoOperation({
    required CapturedPhoto photo,
    required DeliveryRef ref,
    required String siteId,
    required String userId,
    required String label,
    required DateTime now,
  }) => OutboxOperationsCompanion.insert(
    clientId: photo.clientId,
    ownerUserId: userId,
    entity: PhotoEntity.name,
    operation: PhotoEntity.create,
    siteId: Value(siteId),
    label: label,
    payloadJson: jsonEncode(
      DeliveryPayloads.photo(
        delivery: ref,
        now: now,
        takenAt: photo.takenAt,
        sizeBytes: photo.sizeBytes,
        sha256: photo.sha256,
      ),
    ),
    createdAt: now,
  );

  /// Metadonnees locales de la photo et son fichier a envoyer.
  Future<void> _writePhoto({
    required CapturedPhoto photo,
    required String deliveryId,
    required String siteId,
    required String userId,
    required DateTime now,
  }) async {
    await _db.deliveryPhotosDao.insertPending(
      DeliveryPhotoRow(
        id: photo.clientId,
        siteId: siteId,
        deliveryId: deliveryId,
        clientId: photo.clientId,
        takenAt: photo.takenAt,
        contentType: PhotoEntity.jpeg,
        sizeBytes: photo.sizeBytes,
        contentStatus: PhotoContentStatus.pending,
        version: 0,
        isPending: true,
      ),
    );
    await _db.deliveryPhotosDao.enqueueFile(
      PendingPhotoFilesCompanion.insert(
        clientId: photo.clientId,
        ownerUserId: userId,
        siteId: siteId,
        deliveryId: deliveryId,
        relativePath: photo.relativePath,
        sha256: photo.sha256,
        sizeBytes: photo.sizeBytes,
        takenAt: photo.takenAt,
        createdAt: now,
      ),
    );
  }

  // --- Correction et annulation ----------------------------------------------------------------

  /// Corrige une livraison (quantite, unite, date, n° de BL, conformite).
  ///
  /// * livraison **jamais envoyee** : la saisie en attente est simplement modifiee (ligne locale
  ///   et operation `create`, meme transaction) ;
  /// * livraison connue du serveur : une operation `delivery` / `update` est ajoutee, avec la
  ///   valeur de depart de chaque champ modifie (comparaison a trois valeurs, ADR 0011).
  Future<DeliverySaveResult> edit({
    required DeliveryView view,
    required DeliveryEditDraft draft,
    required String userId,
    required String clientId,
    required String label,
    Quantity? quantityInRequest,
    OutboxRow? replacing,
  }) async {
    if (view.isNotYetSent) {
      return _editPending(view, draft, label, quantityInRequest);
    }
    final edit = DeliveryEdit.diff(view.row, draft);
    if (edit.isEmpty) {
      if (replacing != null) await _outbox.abandon(replacing);
      return const DeliveryUnchanged();
    }
    final now = _now().toUtc();
    final saved = await _outbox.saveWithOperation(
      operation: OutboxOperationsCompanion.insert(
        clientId: clientId,
        ownerUserId: userId,
        entity: DeliveryEntity.name,
        operation: DeliveryEntity.update,
        siteId: Value(view.stored.siteId),
        label: label,
        payloadJson: jsonEncode(
          DeliveryPayloads.update(
            ref: DeliveryRef.of(view.stored),
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
    if (!saved) return const DeliveryAlreadySaved();
    onLocalWrite?.call();
    return DeliverySaved(view.stored);
  }

  Future<DeliverySaveResult> _editPending(
    DeliveryView view,
    DeliveryEditDraft draft,
    String label,
    Quantity? quantityInRequest,
  ) async {
    final row = view.stored;
    final createOperation = await _db.outboxDao.getByClientId(row.id);
    if (createOperation == null ||
        createOperation.status != OutboxStatus.pending) {
      return const DeliveryBusy();
    }
    final first = draftFromDeliveryPayload(createOperation.payload);
    if (first == null) return const DeliveryBusy();
    final firstSavedAt =
        DateTime.tryParse('${createOperation.payload['clientCreatedAt']}') ??
        _now();
    final updated = DeliveryDraft(
      request: first.request,
      supplierId: first.supplierId,
      freeSupplierName: first.freeSupplierName,
      productId: first.productId,
      freeProductName: first.freeProductName,
      quantity: draft.quantity,
      deliveryDate: draft.deliveryDate,
      deliveryNoteNumber: draft.deliveryNoteNumber,
      conformity: draft.conformity,
      reserveReasonCode: draft.reserveReasonCode,
      reserveNote: draft.reserveNote,
    );
    final next = row.copyWith(
      quantityValue: draft.quantity.value,
      quantityUnit: draft.quantity.unit.code,
      quantityInRequestValue: Value(quantityInRequest?.value),
      quantityInRequestUnit: Value(quantityInRequest?.unit.code),
      deliveryDate: draft.deliveryDate,
      deliveryNoteNumber: Value(normalizeNoteNumber(draft.deliveryNoteNumber)),
      conformity: draft.conformity.code,
      reserveReasonCode: Value(
        draft.conformity == Conformity.withReserve
            ? draft.reserveReasonCode
            : null,
      ),
      reserveNote: Value(
        draft.conformity == Conformity.withReserve
            ? _blankToNull(draft.reserveNote)
            : null,
      ),
    );
    final replaced = await _db.transaction(() async {
      final done = await _db.outboxDao.replacePendingPayload(
        createOperation.id,
        payloadJson: jsonEncode(DeliveryPayloads.create(updated, firstSavedAt)),
        label: label,
      );
      if (done) await _db.deliveriesDao.replacePending(next);
      return done;
    });
    if (!replaced) return const DeliveryBusy();
    onLocalWrite?.call();
    return DeliverySaved(next);
  }

  /// Annule une livraison (motif obligatoire) : elle reste visible, barree, hors de tout total ;
  /// le statut de sa demande est recalcule par le serveur (et provisoirement ici).
  Future<QueueResult> cancel({
    required DeliveryView view,
    required String userId,
    required String clientId,
    required String label,
    required String reasonCode,
    String? reasonNote,
  }) async {
    // Une seule annulation en attente par livraison : un double appui n'ajoute rien.
    final queued = await _db.outboxDao.allFor(userId);
    final already = queued.any(
      (op) =>
          op.deliveryAction == DeliveryEntity.cancel &&
          op.targetsDelivery(view.stored) &&
          (op.status == OutboxStatus.pending ||
              op.status == OutboxStatus.sending),
    );
    if (already) return QueueResult.alreadyQueued;

    final now = _now().toUtc();
    final saved = await _outbox.saveWithOperation(
      operation: OutboxOperationsCompanion.insert(
        clientId: clientId,
        ownerUserId: userId,
        entity: DeliveryEntity.name,
        operation: DeliveryEntity.transition,
        siteId: Value(view.stored.siteId),
        label: label,
        payloadJson: jsonEncode(
          DeliveryPayloads.cancel(
            ref: DeliveryRef.of(view.stored),
            now: now,
            reasonCode: reasonCode,
            reasonNote: reasonNote,
          ),
        ),
        baseVersion: Value(
          view.stored.version > 0 ? view.stored.version : null,
        ),
        createdAt: now,
      ),
      localWrite: () async {},
    );
    if (!saved) return QueueResult.alreadyQueued;
    onLocalWrite?.call();
    return QueueResult.queued;
  }

  static String? _blankToNull(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
