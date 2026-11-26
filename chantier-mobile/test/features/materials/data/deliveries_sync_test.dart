import 'dart:convert';
import 'package:chantier_mobile/core/api/generated/export.dart'
    show SyncPullResponse, SyncPushOperation, SyncPushResponse, SyncPushResult;
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/materials/data/deliveries_repository.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/data/photo_files.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/api_json.dart';
import '../../../support/fake_sync_remote.dart';
import '../../../support/fixtures.dart';
import '../../../support/photo_support.dart';
import '../../../support/test_database.dart';

class _MockMonitor extends Mock implements ConnectivityMonitor {}

const _siteId = '0192a000-0000-7000-8000-0000000000a1';
const _productId = '0192a000-0000-7000-8000-0000000000d1';
const _supplierId = '0192a000-0000-7000-8000-0000000000e1';
const _requestId = '0192a000-0000-7000-8000-0000000000f1';
const _user = 'user-a';

class _Harness {
  _Harness() {
    db = createTestDatabase();
    remote = FakeSyncRemote();
    bed = PhotoTestBed();
    photoRemote = FakePhotoRemote(remote.deliveries);
    monitor = _MockMonitor();
    when(() => monitor.hasNetworkInterface()).thenAnswer((_) async => true);
    outbox = OutboxRepository(db);
    materials = MaterialsRepository(
      database: db,
      outbox: outbox,
      now: () => DateTime.utc(2026, 11, 25, 9),
    );
    deliveries = DeliveriesRepository(
      database: db,
      outbox: outbox,
      now: () => DateTime.utc(2026, 11, 25, 9),
    );
    engine = SyncEngine(
      database: db,
      remote: remote,
      sites: SitesRepository(db),
      materials: materials,
      photoUploads: bed.uploads(db, photoRemote),
      currentUserId: () => _user,
      connectivity: monitor,
      backoff: Backoff(),
      now: () => DateTime.utc(2026, 11, 25, 10),
      pushBatchSize: 50,
    );
  }

  late final AppDatabase db;
  late final FakeSyncRemote remote;
  late final PhotoTestBed bed;
  late final FakePhotoRemote photoRemote;
  late final _MockMonitor monitor;
  late final OutboxRepository outbox;
  late final MaterialsRepository materials;
  late final DeliveriesRepository deliveries;
  late final SyncEngine engine;

  /// Chantier, catalogue et une demande de 600 sacs **commandee** (cote serveur et sur le telephone).
  Future<void> prepare({String status = 'Ordered'}) async {
    await db.sitesDao.upsertIfNewer(siteRow(id: _siteId));
    await db.productsDao.upsertIfNewer(productRow(id: _productId));
    await db.suppliersDao.upsertIfNewer(supplierRow(id: _supplierId));
    remote.materials.requests[_requestId] = requestJson(
      id: _requestId,
      siteId: _siteId,
      status: status,
      quantity: 600,
      version: '51000',
    );
    await db.materialRequestsDao.upsertIfNewer(
      requestRow(
        id: _requestId,
        siteId: _siteId,
        productId: _productId,
        quantity: '600',
        status: status,
        requestedById: _user,
      ),
    );
  }

  Future<MaterialRequestRow> request() async =>
      (await db.materialRequestsDao.getById(_requestId))!;

  DeliveryDraft draft({
    String quantity = '10',
    MeasureUnit unit = MeasureUnit.tonne,
    String? note = 'bl-4471',
    bool unattached = false,
  }) => DeliveryDraft(
    request: unattached ? null : const RequestRef.server(_requestId),
    supplierId: _supplierId,
    productId: unattached ? _productId : null,
    quantity: Quantity(Decimal.parse(quantity), unit),
    deliveryDate: DateTime.utc(2026, 11, 25),
    deliveryNoteNumber: note,
  );

  Future<DeliverySaveResult> record(
    String clientId, {
    DeliveryDraft? input,
    List<CapturedPhoto> photos = const [],
  }) async => deliveries.record(
    clientId: clientId,
    siteId: _siteId,
    userId: _user,
    recorderName: 'Mourad B.',
    draft: input ?? draft(),
    label: 'LIV Ciment',
    photoLabel: 'Photo du bon',
    maxPhotos: 5,
    request: await request(),
    supplier: await db.suppliersDao.getById(_supplierId),
    photos: photos,
  );

  Future<CapturedPhoto> photo(String clientId, {int? seed}) =>
      bed.capture(owner: _user, clientId: clientId, seed: seed);

  Future<DeliveryRow> delivery(String clientId) async =>
      (await db.deliveriesDao.findByClientId(_siteId, clientId))!;

  Future<void> dispose() async {
    await engine.dispose();
    await db.close();
    bed.dispose();
  }
}

void main() {
  late _Harness h;

  setUp(() async {
    h = _Harness();
    await h.prepare();
  });
  tearDown(() => h.dispose());

  group('livraison hors ligne puis synchronisation (CA-MAT-006.7, 010.1)', () {
    test(
      'ligne locale + operations dans une transaction ; numero en attente',
      () async {
        final photo = await h.photo('ph-1');
        final result = await h.record('liv-1', photos: [photo]);
        expect(result, isA<DeliverySaved>());

        final row = await h.delivery('liv-1');
        expect(row.isPending, isTrue);
        expect(row.number, isNull);
        expect(row.version, 0);
        expect(row.requestId, _requestId);
        expect(row.deliveryNoteNumber, 'BL-4471');
        final ops = await h.db.outboxDao.allFor(_user);
        expect(
          [for (final op in ops) '${op.entity}/${op.operation}'],
          ['delivery/create', 'photo/create'],
        );
        expect(await h.db.deliveryPhotosDao.countByDelivery('liv-1'), 1);
        expect(await h.db.deliveryPhotosDao.getFile('ph-1'), isNotNull);
      },
    );

    test('double appui : une seule livraison, une seule operation', () async {
      await h.record('liv-1');
      final second = await h.record('liv-1');
      expect(second, isA<DeliveryAlreadySaved>());
      expect(await h.db.deliveriesDao.countBySite(_siteId), 1);
      expect((await h.db.outboxDao.allFor(_user)).length, 1);
    });

    test(
      'aucune operation ne porte de numero, de statut, de motif ni de montant',
      () async {
        await h.record('liv-1');
        final payload = (await h.db.outboxDao.getByClientId('liv-1'))!.payload;
        for (final forbidden in [
          'number',
          'status',
          'unattachedReason',
          'amount',
          'commercial',
          'unitPrice',
          'phone',
        ]) {
          expect(payload.containsKey(forbidden), isFalse, reason: forbidden);
        }
        expect(payload['deliveryNoteNumber'], 'BL-4471');
        expect(payload['quantity'], {'value': 10, 'unit': 't'});
        expect(payload['requestId'], _requestId);
      },
    );

    test(
      'statut provisoire de la demande : 10 T = 200 sacs, a confirmer',
      () async {
        await h.record('liv-1');
        final views = await h.materials
            .watchRequests(_siteId, _user)
            .firstWhere((_) => true);
        final view = views.single;
        expect(view.isStatusProvisional, isTrue);
        expect(view.row.status, 'PartiallyDelivered');
        expect(view.row.receivedValue, Decimal.parse('200'));
        expect(view.row.remainingValue, Decimal.parse('400'));
        // La ligne stockee reste celle du serveur.
        expect((await h.request()).status, 'Ordered');
      },
    );

    test(
      'retour du reseau : livraison creee une seule fois, numero LIV, photo envoyee',
      () async {
        final photo = await h.photo('ph-1');
        await h.record('liv-1', photos: [photo]);

        expect(await h.engine.run(), SyncOutcome.completed);

        expect(h.remote.deliveries.createdCount, 1);
        final row = await h.delivery('liv-1');
        expect(row.isPending, isFalse);
        expect(row.number, 'LIV-001');
        expect(row.requestId, _requestId);
        expect(row.quantityInRequest!.value, Decimal.parse('200'));
        expect(row.quantityInRequest!.unit, MeasureUnit.bag);
        expect(await h.db.outboxDao.allFor(_user), isEmpty);

        // La photo : metadonnees confirmees, fichier envoye puis supprime du telephone.
        final serverPhoto = h.remote.deliveries.photos.values.single;
        expect(serverPhoto['deliveryId'], row.id);
        expect(h.photoRemote.uploadCalls, [serverPhoto['id']]);
        expect(await h.db.deliveryPhotosDao.getFile('ph-1'), isNull);
        expect(
          (await h.bed.files.fileFor(_user, photo.relativePath)).existsSync(),
          isFalse,
        );
        final local = (await h.db.deliveryPhotosDao.findByClientId(
          _siteId,
          'ph-1',
        ))!;
        expect(local.id, serverPhoto['id']);
        expect(local.isPending, isFalse);
        expect(local.contentStatus, 'Uploaded');
        expect(local.deliveryId, row.id);
      },
    );

    test('la livraison sur une demande en attente designe son clientId', () async {
      // Demande saisie hors ligne : la livraison la designe par `requestClientId`.
      await h.materials.createRequest(
        clientId: 'req-offline',
        siteId: _siteId,
        userId: _user,
        requesterName: 'Mourad B.',
        draft: RequestDraft(
          productId: _productId,
          quantity: Quantity(Decimal.parse('300'), MeasureUnit.bag),
          neededBy: DateTime.utc(2026, 11, 28),
        ),
        label: 'Demande',
      );
      // Le serveur la valide (hors ligne la livraison est retenue avant la commande).
      await h.deliveries.record(
        clientId: 'liv-1',
        siteId: _siteId,
        userId: _user,
        recorderName: 'Mourad B.',
        draft: DeliveryDraft(
          request: const RequestRef.client('req-offline'),
          supplierId: _supplierId,
          quantity: Quantity(Decimal.parse('100'), MeasureUnit.bag),
          deliveryDate: DateTime.utc(2026, 11, 25),
        ),
        label: 'LIV',
        photoLabel: 'Photo',
        maxPhotos: 5,
        request: await h.db.materialRequestsDao.getById('req-offline'),
      );
      final op = (await h.db.outboxDao.getByClientId('liv-1'))!;
      expect(op.payload['requestClientId'], 'req-offline');
      expect(op.payload.containsKey('requestId'), isFalse);

      await h.engine.run();
      // Demande `Requested` : la livraison est enregistree, non rattachee (fait de chantier).
      final row = await h.delivery('liv-1');
      expect(row.number, 'LIV-001');
      expect(row.requestId, isNull);
      expect(row.unattachedReason, 'RequestNotOpen');
      expect(h.remote.deliveries.createdCount, 1);
    });
  });

  group('reprise sans doublon (application tuee, coupure)', () {
    test(
      'reponse du push perdue : au renvoi, une seule livraison et une seule photo',
      () async {
        final photo = await h.photo('ph-1');
        await h.record('liv-1', photos: [photo]);

        h.remote.loseNextPushResponse = true;
        expect(await h.engine.run(), SyncOutcome.offline);
        // Le serveur a tout traite, le telephone ne le sait pas.
        expect(h.remote.deliveries.createdCount, 1);
        expect((await h.delivery('liv-1')).isPending, isTrue);
        expect(h.photoRemote.uploadCalls, isEmpty);

        expect(await h.engine.run(), SyncOutcome.completed);
        expect(h.remote.deliveries.createdCount, 1);
        expect(h.remote.deliveries.photoCount, 1);
        expect(h.remote.deliveries.numbers, ['LIV-001']);
        expect(h.photoRemote.uploadCalls.length, 1);
        expect((await h.delivery('liv-1')).isPending, isFalse);
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
      },
    );

    test(
      'application tuee pendant l envoi (operation sending) : reprise sans doublon',
      () async {
        await h.record('liv-1');
        final op = (await h.db.outboxDao.getByClientId('liv-1'))!;
        await h.db.outboxDao.markSending([op.id]);

        await h.engine.run();
        await h.engine.run();

        expect(h.remote.deliveries.createdCount, 1);
        expect(await h.db.deliveriesDao.countBySite(_siteId), 1);
      },
    );

    test(
      'coupure pendant l envoi du fichier : le fichier reste, repart une fois',
      () async {
        final photo = await h.photo('ph-1');
        await h.record('liv-1', photos: [photo]);
        h.photoRemote.script.add(const NetworkApiException());

        expect(await h.engine.run(), SyncOutcome.offline);
        // Donnees synchronisees, fichier toujours la, tentative comptee.
        expect(h.remote.deliveries.createdCount, 1);
        final pending = (await h.db.deliveryPhotosDao.getFile('ph-1'))!;
        expect(pending.attempts, 1);
        expect(
          (await h.bed.files.fileFor(_user, pending.relativePath)).existsSync(),
          isTrue,
        );

        expect(await h.engine.run(), SyncOutcome.completed);
        expect(
          h.remote.deliveries.photos.values.single['contentStatus'],
          'Uploaded',
        );
        expect(h.photoRemote.stored.length, 1);
        expect(await h.db.deliveryPhotosDao.getFile('ph-1'), isNull);
      },
    );

    test(
      'reponse du PUT perdue : renvoi du meme contenu sans doublon (idempotence)',
      () async {
        final photo = await h.photo('ph-1');
        await h.record('liv-1', photos: [photo]);
        h.photoRemote.loseNextResponse = true;

        expect(await h.engine.run(), SyncOutcome.offline);
        expect(h.photoRemote.stored.length, 1);
        expect(await h.db.deliveryPhotosDao.getFile('ph-1'), isNotNull);

        expect(await h.engine.run(), SyncOutcome.completed);
        // Deux envois du meme fichier, un seul fichier sur le serveur.
        expect(h.photoRemote.uploadCalls.length, 2);
        expect(h.photoRemote.stored.length, 1);
        expect(await h.db.deliveryPhotosDao.getFile('ph-1'), isNull);
      },
    );
  });

  group('echec momentane du serveur (R2-01)', () {
    test(
      'resultat « retry » ERREUR_TEMPORAIRE : l operation reste a envoyer, rien n est perdu',
      () async {
        await h.record('liv-1');
        var first = true;
        h.remote.pushHandler = (operations) {
          if (first) {
            first = false;
            return SyncPushResponse(
              results: [
                for (final op in operations)
                  SyncPushResult(
                    clientId: op.clientId,
                    status: 'retry',
                    code: 'ERREUR_TEMPORAIRE',
                  ),
              ],
            );
          }
          return SyncPushResponse(
            results: [for (final op in operations) h.remote.handle(op)],
          );
        };

        // Une seule requete : « retry » ne provoque aucune boucle de renvoi dans la meme execution.
        expect(await h.engine.run(), SyncOutcome.failed);
        expect(h.remote.pushBatches.length, 1);
        final waiting = (await h.db.outboxDao.getByClientId('liv-1'))!;
        expect(waiting.status, OutboxStatus.pending);
        expect(waiting.lastErrorCode, 'ERREUR_TEMPORAIRE');
        expect(waiting.attempts, 1);
        expect((await h.delivery('liv-1')).isPending, isTrue);

        expect(await h.engine.run(), SyncOutcome.completed);
        expect(h.remote.deliveries.createdCount, 1);
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
      },
    );
  });

  group('retry d une creation : ses dependants restent en file (R3-01)', () {
    /// Demande creee hors ligne, corrigee, livraison saisie pour elle, avec une photo.
    Future<void> offlineChain() async {
      await h.materials.createRequest(
        clientId: 'req-off',
        siteId: _siteId,
        userId: _user,
        requesterName: 'Mourad B.',
        draft: RequestDraft(
          productId: _productId,
          quantity: Quantity(Decimal.parse('300'), MeasureUnit.bag),
          neededBy: DateTime.utc(2026, 11, 28),
        ),
        label: 'Demande',
      );
      final stored = (await h.db.materialRequestsDao.getById('req-off'))!;
      await h.materials.editRequest(
        view: RequestView.plain(stored),
        draft: RequestDraft(
          productId: _productId,
          quantity: Quantity(Decimal.parse('400'), MeasureUnit.bag),
          neededBy: DateTime.utc(2026, 11, 28),
        ),
        userId: _user,
        clientId: 'edit-off',
        label: 'Demande 400',
      );
      final photo = await h.photo('ph-off');
      await h.record(
        'liv-off',
        input: DeliveryDraft(
          request: const RequestRef.client('req-off'),
          supplierId: _supplierId,
          quantity: Quantity(Decimal.parse('100'), MeasureUnit.bag),
          deliveryDate: DateTime.utc(2026, 11, 25),
        ),
        photos: [photo],
      );
    }

    /// Serveur dont la creation de la demande echoue momentanement ; les dependants, eux, sont
    /// refuses « introuvable » (le parent n'existe pas encore) : ce serait leur perte definitive.
    SyncPushResponse Function(List<SyncPushOperation>) flaky() =>
        (operations) => SyncPushResponse(
          results: [
            for (final op in operations)
              if (op.clientId == 'req-off')
                SyncPushResult(
                  clientId: op.clientId,
                  status: 'retry',
                  code: 'ERREUR_TEMPORAIRE',
                )
              else
                SyncPushResult(
                  clientId: op.clientId,
                  status: 'rejected',
                  code: 'INTROUVABLE',
                ),
          ],
        );

    test(
      'meme lot : creation en retry, livraison et photo restent a envoyer',
      () async {
        await offlineChain();
        h.remote.pushHandler = flaky();

        expect(await h.engine.run(), SyncOutcome.failed);

        // Une seule requete : rien n'est renvoye dans la meme execution.
        expect(h.remote.pushBatches.length, 1);
        for (final id in ['req-off', 'liv-off', 'ph-off']) {
          final op = (await h.db.outboxDao.getByClientId(id))!;
          expect(op.status, OutboxStatus.pending, reason: id);
        }
        // Rien a verifier : aucun faux « refuse ».
        expect(
          (await h.db.outboxDao.allFor(
            _user,
          )).where((op) => op.status != OutboxStatus.pending),
          isEmpty,
        );
        // Les saisies locales sont intactes.
        expect(await h.db.materialRequestsDao.getById('req-off'), isNotNull);
        expect((await h.delivery('liv-off')).isPending, isTrue);
        expect(await h.db.deliveryPhotosDao.getFile('ph-off'), isNotNull);
      },
    );

    test(
      'au rejeu : tout est applique, une seule fois, dans l ordre',
      () async {
        await offlineChain();
        h.remote.pushHandler = flaky();
        await h.engine.run();

        h.remote.pushHandler = null;
        expect(await h.engine.run(), SyncOutcome.completed);

        expect(
          h.remote.materials.createdCount,
          2,
        ); // req-009 de l'amorce + req-off
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
        final delivery = await h.delivery('liv-off');
        expect(delivery.isPending, isFalse);
        expect(h.remote.deliveries.createdCount, 1);
        expect(h.remote.deliveries.photoCount, 1);
        expect(h.photoRemote.stored.length, 1);
      },
    );

    test(
      'lots suivants : les dependants ne partent pas dans la meme execution',
      () async {
        await offlineChain();
        // Lots d'une operation : la creation (retry) part seule, les dependants ne partent pas.
        final small = SyncEngine(
          database: h.db,
          remote: h.remote,
          sites: SitesRepository(h.db),
          materials: h.materials,
          currentUserId: () => _user,
          connectivity: h.monitor,
          backoff: Backoff(),
          pushBatchSize: 1,
        );
        addTearDown(small.dispose);
        h.remote.pushHandler = flaky();

        await small.run();

        expect(h.remote.pushBatches.length, 1);
        expect(h.remote.pushBatches.single.single.clientId, 'req-off');
        expect(
          (await h.db.outboxDao.getByClientId('liv-off'))!.status,
          OutboxStatus.pending,
        );
      },
    );

    test('une operation independante du meme lot part normalement', () async {
      await offlineChain();
      await h.record(
        'liv-libre',
      ); // demande du serveur, sans lien avec la chaine
      h.remote.pushHandler = (operations) => SyncPushResponse(
        results: [
          for (final op in operations)
            if (op.clientId == 'req-off')
              SyncPushResult(
                clientId: op.clientId,
                status: 'retry',
                code: 'ERREUR_TEMPORAIRE',
              )
            else if (op.entity == 'delivery' && op.clientId == 'liv-libre')
              h.remote.handle(op)
            else
              SyncPushResult(
                clientId: op.clientId,
                status: 'rejected',
                code: 'INTROUVABLE',
              ),
        ],
      );

      await h.engine.run();

      expect(await h.db.outboxDao.getByClientId('liv-libre'), isNull);
      expect((await h.delivery('liv-libre')).isPending, isFalse);
      expect(
        (await h.db.outboxDao.getByClientId('liv-off'))!.status,
        OutboxStatus.pending,
      );
    });
  });

  group('fenetre de synchronisation depassee : rechargement complet (R3-05)', () {
    SyncEngine engineAt(DateTime now, {int days = 60}) => SyncEngine(
      database: h.db,
      remote: h.remote,
      sites: SitesRepository(h.db),
      materials: h.materials,
      photoUploads: h.bed.uploads(h.db, h.photoRemote),
      currentUserId: () => _user,
      connectivity: h.monitor,
      backoff: Backoff(),
      now: () => now,
      fullReloadAfterDays: days,
    );

    /// Une demande close encore « Validee » sur le telephone, une livraison confirmee, une
    /// livraison et une photo saisies hors ligne.
    Future<void> staleState() async {
      await h.db.materialRequestsDao.upsertIfNewer(
        requestRow(
          id: 'req-stale',
          siteId: _siteId,
          number: 'DEM-050',
          status: 'Validated',
          version: 100,
        ),
      );
      await h.db.deliveriesDao.upsertIfNewer(
        deliveryRow(
          id: 'liv-stale',
          siteId: _siteId,
          requestId: 'req-stale',
          version: 101,
        ),
      );
      await h.db.deliveryPhotosDao.upsertIfNewer(
        photoRow(
          id: 'ph-stale',
          siteId: _siteId,
          deliveryId: 'liv-stale',
          version: 102,
        ),
      );
      final photo = await h.photo('ph-off');
      await h.record('liv-off', photos: [photo]);
      await h.db.syncStateDao.set('cursor', '999');
    }

    test(
      'signal resetRequired : donnees confirmees effacees, rechargees, saisies gardees',
      () async {
        await staleState();
        h.remote.pullScript.addAll([
          SyncPullResponse.fromJson(
            syncPullJson(resetRequired: true, cursor: '999'),
          ),
          // Pull complet depuis zero : le serveur ne renvoie plus la demande close.
          SyncPullResponse.fromJson(
            syncPullJson(
              changes: [
                syncChangeJson(
                  'request',
                  requestJson(
                    id: 'req-live',
                    siteId: _siteId,
                    number: 'DEM-060',
                    status: 'Ordered',
                  ),
                  version: '300',
                ),
              ],
              cursor: '300',
            ),
          ),
        ]);

        expect(await h.engine.run(), SyncOutcome.completed);

        // Depart a zero apres le signal, une seule fois.
        expect(h.remote.pullSinces, ['999', null]);
        expect(await h.db.materialRequestsDao.getById('req-stale'), isNull);
        expect(await h.db.deliveriesDao.getById('liv-stale'), isNull);
        expect(await h.db.deliveryPhotosDao.getById('ph-stale'), isNull);
        expect(await h.db.materialRequestsDao.getById('req-live'), isNotNull);
        // Les saisies en attente passent par le push avant le pull : confirmees, jamais perdues.
        expect(h.remote.deliveries.createdCount, 1);
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
        expect(await h.db.syncStateDao.get('full_reload'), isNull);
        expect(await h.db.syncStateDao.get('cursor'), '300');
      },
    );

    test(
      'les saisies en attente ne sont pas touchees quand le push echoue',
      () async {
        await staleState();
        h.remote.pushHandler = (operations) => SyncPushResponse(
          results: [
            for (final op in operations)
              SyncPushResult(
                clientId: op.clientId,
                status: 'retry',
                code: 'ERREUR_TEMPORAIRE',
              ),
          ],
        );
        h.remote.pullScript.addAll([
          SyncPullResponse.fromJson(
            syncPullJson(resetRequired: true, cursor: '999'),
          ),
          SyncPullResponse.fromJson(syncPullJson(cursor: '300')),
        ]);

        await h.engine.run();

        // Livraison locale, file d'envoi et fichier de photo : intacts.
        expect((await h.delivery('liv-off')).isPending, isTrue);
        expect(await h.db.outboxDao.getByClientId('liv-off'), isNotNull);
        expect(await h.db.outboxDao.getByClientId('ph-off'), isNotNull);
        expect(await h.db.deliveryPhotosDao.getFile('ph-off'), isNotNull);
        // Les lignes confirmees perimees, elles, sont parties.
        expect(await h.db.materialRequestsDao.getById('req-stale'), isNull);
      },
    );

    test(
      'le signal est ignore pendant le rechargement (pas de boucle)',
      () async {
        await staleState();
        h.remote.pullScript.addAll([
          SyncPullResponse.fromJson(
            syncPullJson(resetRequired: true, cursor: '999'),
          ),
          SyncPullResponse.fromJson(
            syncPullJson(resetRequired: true, hasMore: true, cursor: '100'),
          ),
          SyncPullResponse.fromJson(syncPullJson(cursor: '200')),
        ]);

        expect(await h.engine.run(), SyncOutcome.completed);
        expect(h.remote.pullSinces, ['999', null, '100']);
      },
    );

    test('sans signal : rien n est efface', () async {
      await staleState();
      expect(await h.engine.run(), SyncOutcome.completed);
      expect(await h.db.materialRequestsDao.getById('req-stale'), isNotNull);
      expect(h.remote.pullSinces, ['999']);
    });

    test(
      'derniere synchronisation de plus de 60 jours : rechargement complet sans signal',
      () async {
        await staleState();
        await h.db.syncStateDao.set(
          'last_success_at',
          DateTime.utc(2026, 9, 1).toIso8601String(),
        );
        final late = engineAt(DateTime.utc(2026, 11, 25, 10));
        addTearDown(late.dispose);

        expect(await late.run(), SyncOutcome.completed);

        expect(h.remote.pullSinces, [null]);
        expect(await h.db.materialRequestsDao.getById('req-stale'), isNull);
        expect(h.remote.deliveries.createdCount, 1);
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
      },
    );

    test(
      'moins de 60 jours : aucun rechargement ; seuil parametrable ; 0 = jamais',
      () async {
        await staleState();
        await h.db.syncStateDao.set(
          'last_success_at',
          DateTime.utc(2026, 10, 20).toIso8601String(),
        );
        final recent = engineAt(DateTime.utc(2026, 11, 25, 10));
        addTearDown(recent.dispose);
        await recent.run();
        expect(await h.db.materialRequestsDao.getById('req-stale'), isNotNull);

        // Seuil ramene a 30 jours : 36 jours sans synchronisation = rechargement.
        await h.db.syncStateDao.set(
          'last_success_at',
          DateTime.utc(2026, 10, 20).toIso8601String(),
        );
        final strict = engineAt(DateTime.utc(2026, 11, 25, 10), days: 30);
        addTearDown(strict.dispose);
        await strict.run();
        expect(await h.db.materialRequestsDao.getById('req-stale'), isNull);

        await h.db.materialRequestsDao.upsertIfNewer(
          requestRow(
            id: 'req-stale',
            siteId: _siteId,
            status: 'Validated',
            version: 100,
          ),
        );
        await h.db.syncStateDao.set(
          'last_success_at',
          DateTime.utc(2025, 1, 1).toIso8601String(),
        );
        final never = engineAt(DateTime.utc(2026, 11, 25, 10), days: 0);
        addTearDown(never.dispose);
        await never.run();
        expect(await h.db.materialRequestsDao.getById('req-stale'), isNotNull);
      },
    );

    test(
      'premiere synchronisation : pas de rechargement (rien de perime)',
      () async {
        await staleState();
        final first = engineAt(DateTime.utc(2030, 1, 1));
        addTearDown(first.dispose);
        await first.run();
        expect(await h.db.materialRequestsDao.getById('req-stale'), isNotNull);
      },
    );
  });

  group('photos : un fichier a la fois, SHA-256, rejets', () {
    test(
      'les metadonnees portent la taille et l empreinte SHA-256 du fichier',
      () async {
        final photo = await h.photo('ph-1');
        await h.record('liv-1', photos: [photo]);
        final payload = (await h.db.outboxDao.getByClientId('ph-1'))!.payload;
        expect(payload['sha256'], hasLength(64));
        expect(payload['sha256'], photo.sha256);
        expect(payload['sizeBytes'], photo.sizeBytes);
        expect(payload['contentType'], 'image/jpeg');
        expect(payload['deliveryClientId'], 'liv-1');
        expect(payload['takenAt'], isNotNull);
      },
    );

    test('5 photos : envoyees une par une, dans l ordre de prise', () async {
      final photos = [
        for (var i = 1; i <= 5; i++) await h.photo('ph-$i', seed: i * 7),
      ];
      await h.record('liv-1', photos: photos);

      await h.engine.run();

      final byClient = {
        for (final entry in h.remote.deliveries.photos.entries)
          entry.value['clientId']: entry.key,
      };
      expect(h.photoRemote.uploadCalls, [
        for (var i = 1; i <= 5; i++) byClient['ph-$i'],
      ]);
      expect(h.photoRemote.stored.length, 5);
      expect(
        await h.db.deliveryPhotosDao.countByDelivery(
          (await h.delivery('liv-1')).id,
        ),
        5,
      );
    });

    test(
      'une 6e photo est refusee a l enregistrement, rien n est ecrit',
      () async {
        final photos = [
          for (var i = 1; i <= 6; i++) await h.photo('ph-$i', seed: i),
        ];
        final result = await h.record('liv-1', photos: photos);
        expect(result, isA<DeliveryTooManyPhotos>());
        expect(await h.db.deliveriesDao.countBySite(_siteId), 0);
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
      },
    );

    test(
      'le serveur refuse la photo en trop (PHOTOS_TROP_NOMBREUSES) : les autres partent',
      () async {
        h.remote.deliveries.maxPhotos = 2;
        await h.record(
          'liv-1',
          photos: [
            for (var i = 1; i <= 3; i++) await h.photo('ph-$i', seed: i * 3),
          ],
        );

        await h.engine.run();

        expect(h.remote.deliveries.photoCount, 2);
        expect(h.photoRemote.uploadCalls.length, 2);
        // La 3e : operation refusee a verifier, fichier conserve (jamais perdu en silence).
        final refused = (await h.db.outboxDao.getByClientId('ph-3'))!;
        expect(refused.status, OutboxStatus.rejected);
        expect(refused.lastErrorCode, 'PHOTOS_TROP_NOMBREUSES');
        expect(await h.db.deliveryPhotosDao.getFile('ph-3'), isNotNull);
      },
    );

    test(
      '409 CONFLIT_VERSION (R2-04) : a relire puis reessayer, sans perte',
      () async {
        final photo = await h.photo('ph-1');
        await h.record('liv-1', photos: [photo]);
        h.photoRemote.script.addAll([
          const ConflictApiException(status: 409, code: 'CONFLIT_VERSION'),
          const ConflictApiException(status: 409, code: 'CONFLIT_VERSION'),
        ]);

        expect(await h.engine.run(), SyncOutcome.completed);
        expect(h.photoRemote.uploadCalls.length, 3);
        expect(await h.db.deliveryPhotosDao.getFile('ph-1'), isNull);
        expect(h.photoRemote.stored.length, 1);
      },
    );

    test(
      '409 CONFLIT_VERSION persistant : le fichier reste, reprise plus tard',
      () async {
        final photo = await h.photo('ph-1');
        await h.record('liv-1', photos: [photo]);
        h.photoRemote.script.addAll([
          for (var i = 0; i < 3; i++)
            const ConflictApiException(status: 409, code: 'CONFLIT_VERSION'),
        ]);

        expect(await h.engine.run(), SyncOutcome.failed);
        final pending = (await h.db.deliveryPhotosDao.getFile('ph-1'))!;
        // Jamais « definitif » : pas dans les echecs a verifier, retente a la synchro suivante.
        expect(pending.lastErrorCode, 'CONFLIT_VERSION');
        expect(await h.engine.run(), SyncOutcome.completed);
        expect(await h.db.deliveryPhotosDao.getFile('ph-1'), isNull);
      },
    );

    test(
      'fichier refuse (415) : conserve, signale, n empeche pas les autres',
      () async {
        final first = await h.photo('ph-1', seed: 5);
        final second = await h.photo('ph-2', seed: 9);
        await h.record('liv-1', photos: [first, second]);
        h.photoRemote.script.add(
          const UnknownApiException(status: 415, code: 'TYPE_FICHIER_REFUSE'),
        );

        expect(await h.engine.run(), SyncOutcome.completed);

        final refused = (await h.db.deliveryPhotosDao.getFile('ph-1'))!;
        expect(refused.lastErrorCode, 'TYPE_FICHIER_REFUSE');
        expect(await h.db.deliveryPhotosDao.getFile('ph-2'), isNull);
        // Pas renvoye en boucle a chaque synchronisation.
        final calls = h.photoRemote.uploadCalls.length;
        await h.engine.run();
        expect(h.photoRemote.uploadCalls.length, calls);
      },
    );

    test(
      'fichier altere apres la prise : empreinte differente, jamais envoye',
      () async {
        final photo = await h.photo('ph-1');
        await h.record('liv-1', photos: [photo]);
        photo.file.writeAsBytesSync(jpegBytes(seed: 99));

        await h.engine.run();

        expect(h.photoRemote.uploadCalls, isEmpty);
        final pending = (await h.db.deliveryPhotosDao.getFile('ph-1'))!;
        expect(pending.lastErrorCode, 'TYPE_FICHIER_REFUSE');
      },
    );

    test(
      'fichier disparu du telephone : signale, les autres partent',
      () async {
        final first = await h.photo('ph-1', seed: 5);
        final second = await h.photo('ph-2', seed: 9);
        await h.record('liv-1', photos: [first, second]);
        first.file.deleteSync();

        await h.engine.run();

        expect(
          (await h.db.deliveryPhotosDao.getFile('ph-1'))!.lastErrorCode,
          'INTROUVABLE',
        );
        expect(await h.db.deliveryPhotosDao.getFile('ph-2'), isNull);
      },
    );

    test('les fichiers d un autre compte ne partent jamais', () async {
      final other = await h.bed.capture(owner: 'user-b', clientId: 'ph-b');
      await h.db.deliveryPhotosDao.enqueueFile(
        pendingPhotoFile(
          clientId: 'ph-b',
          owner: 'user-b',
          siteId: _siteId,
          deliveryId: 'liv-x',
        ),
      );
      expect(other.file.existsSync(), isTrue);

      await h.engine.run();

      expect(h.photoRemote.uploadCalls, isEmpty);
      expect(await h.db.deliveryPhotosDao.getFile('ph-b'), isNotNull);
    });

    test(
      'fichiers orphelins (formulaire abandonne) nettoyes apres le delai de grace',
      () async {
        final kept = await h.photo('ph-keep');
        await h.record('liv-1', photos: [kept]);
        final orphan = await h.photo('ph-orphan', seed: 77);
        expect(orphan.file.existsSync(), isTrue);

        // Hier : rien n'est supprime ; le jour d'apres le delai : l'orphelin disparait.
        final clean = h.bed.uploads(
          h.db,
          h.photoRemote,
          now: () => DateTime.now().add(const Duration(days: 2)),
        );
        await clean.uploadPending('user-zzz');
        expect(
          orphan.file.existsSync(),
          isTrue,
        ); // autre dossier de proprietaire
        await clean.uploadPending(_user);
        expect(orphan.file.existsSync(), isFalse);
      },
    );
  });

  group('correction et annulation hors ligne (CA-MAT-012)', () {
    Future<DeliveryView> confirmed() async {
      await h.record('liv-1');
      await h.engine.run();
      final row = await h.delivery('liv-1');
      return DeliveryView.plain(row);
    }

    test(
      'corriger une livraison envoyee : operation update avec valeurs de depart',
      () async {
        final view = await confirmed();
        final result = await h.deliveries.edit(
          view: view,
          draft: DeliveryEditDraft(
            quantity: Quantity(Decimal.parse('8'), MeasureUnit.tonne),
            deliveryDate: view.row.deliveryDate,
            deliveryNoteNumber: view.row.deliveryNoteNumber,
          ),
          userId: _user,
          clientId: 'edit-1',
          label: 'LIV-001',
        );
        expect(result, isA<DeliverySaved>());
        final op = (await h.db.outboxDao.getByClientId('edit-1'))!;
        expect(op.payload['changes'], {
          'quantity': {'value': 8, 'unit': 't'},
        });
        expect(op.payload['base'], {
          'quantity': {'value': 10, 'unit': 't'},
        });
        expect(op.payload['deliveryId'], view.row.id);

        await h.engine.run();
        expect(h.remote.deliveries.deliveries[view.row.id]!['quantity'], {
          'value': 8,
          'unit': 't',
        });
        expect(
          (await h.request()).status,
          anyOf('Ordered', 'PartiallyDelivered'),
        );
      },
    );

    test('aucune modification : aucune operation', () async {
      final view = await confirmed();
      final result = await h.deliveries.edit(
        view: view,
        draft: DeliveryEditDraft(
          quantity: view.row.quantity!,
          deliveryDate: view.row.deliveryDate,
          deliveryNoteNumber: view.row.deliveryNoteNumber,
        ),
        userId: _user,
        clientId: 'edit-1',
        label: 'LIV-001',
      );
      expect(result, isA<DeliveryUnchanged>());
      expect(await h.db.outboxDao.allFor(_user), isEmpty);
    });

    test(
      'corriger une livraison jamais envoyee : la saisie en attente est modifiee',
      () async {
        await h.record('liv-1');
        final view = DeliveryView.plain(await h.delivery('liv-1'));
        await h.deliveries.edit(
          view: view,
          draft: DeliveryEditDraft(
            quantity: Quantity(Decimal.parse('12'), MeasureUnit.tonne),
            deliveryDate: view.row.deliveryDate,
            deliveryNoteNumber: 'BL-9',
          ),
          userId: _user,
          clientId: 'edit-1',
          label: 'LIV',
        );
        // Toujours une seule operation : le create corrige.
        final ops = await h.db.outboxDao.allFor(_user);
        expect(ops.length, 1);
        expect(ops.single.payload['quantity'], {'value': 12, 'unit': 't'});
        expect(ops.single.payload['deliveryNoteNumber'], 'BL-9');
        expect((await h.delivery('liv-1')).quantityValue, Decimal.parse('12'));
        await h.engine.run();
        expect(h.remote.deliveries.createdCount, 1);
      },
    );

    test(
      'annuler : motif obligatoire, statut provisoire « annulee », 2 appuis = 1 operation',
      () async {
        final view = await confirmed();
        final first = await h.deliveries.cancel(
          view: view,
          userId: _user,
          clientId: 'cancel-1',
          label: 'LIV-001',
          reasonCode: 'DoubleEntry',
        );
        final second = await h.deliveries.cancel(
          view: view,
          userId: _user,
          clientId: 'cancel-2',
          label: 'LIV-001',
          reasonCode: 'DoubleEntry',
        );
        expect(first, QueueResult.queued);
        expect(second, QueueResult.alreadyQueued);

        final shown = overlayDelivery(
          view.row,
          await h.db.outboxDao.allFor(_user),
        );
        expect(shown.row.isCancelled, isTrue);
        expect(shown.isProvisional, isTrue);

        await h.engine.run();
        expect((await h.delivery('liv-1')).status, 'Cancelled');
        expect((await h.delivery('liv-1')).cancelReasonCode, 'DoubleEntry');
      },
    );

    test(
      'livraison annulee ailleurs : ma correction va dans « A verifier », le serveur gagne',
      () async {
        final view = await confirmed();
        await h.deliveries.edit(
          view: view,
          draft: DeliveryEditDraft(
            quantity: Quantity(Decimal.parse('8'), MeasureUnit.tonne),
            deliveryDate: view.row.deliveryDate,
            deliveryNoteNumber: view.row.deliveryNoteNumber,
          ),
          userId: _user,
          clientId: 'edit-1',
          label: 'LIV-001',
        );
        h.remote.deliveries.cancelElsewhere(view.row.id);

        await h.engine.run();

        final op = (await h.db.outboxDao.getByClientId('edit-1'))!;
        expect(op.status, OutboxStatus.conflict);
        expect(op.lastErrorCode, 'TRANSITION_INTERDITE');
        // Le serveur gagne : la ligne locale suit, rien n'est applique, rien n'est supprime.
        final row = await h.delivery('liv-1');
        expect(row.status, 'Cancelled');
        expect(row.quantityValue, Decimal.parse('10'));
        expect(op.conflictJson, isNotNull);
        expect(jsonDecode(op.conflictJson!)['status'], 'Cancelled');
      },
    );

    test(
      'meme champ corrige des deux cotes : premiere arrivee retenue, conflit conserve',
      () async {
        final view = await confirmed();
        await h.deliveries.edit(
          view: view,
          draft: DeliveryEditDraft(
            quantity: Quantity(Decimal.parse('8'), MeasureUnit.tonne),
            deliveryDate: view.row.deliveryDate,
            deliveryNoteNumber: view.row.deliveryNoteNumber,
          ),
          userId: _user,
          clientId: 'edit-1',
          label: 'LIV-001',
        );
        h.remote.deliveries.changeElsewhere(view.row.id, {
          'quantity': {'value': 9, 'unit': 't'},
        });

        await h.engine.run();

        final op = (await h.db.outboxDao.getByClientId('edit-1'))!;
        expect(op.status, OutboxStatus.conflict);
        expect(op.lastErrorCode, 'CONFLIT_VERSION');
        expect(jsonDecode(op.conflictFields!), ['quantity']);
        expect((await h.delivery('liv-1')).quantityValue, Decimal.parse('9'));
      },
    );

    test(
      'demande receptionnee entre-temps : correction refusee (DEMANDE_NON_OUVERTE), conservee',
      () async {
        final view = await confirmed();
        await h.deliveries.edit(
          view: view,
          draft: DeliveryEditDraft(
            quantity: Quantity(Decimal.parse('8'), MeasureUnit.tonne),
            deliveryDate: view.row.deliveryDate,
            deliveryNoteNumber: view.row.deliveryNoteNumber,
          ),
          userId: _user,
          clientId: 'edit-1',
          label: 'LIV-001',
        );
        h.remote.materials.setStatus(_requestId, 'Received');

        await h.engine.run();

        final op = (await h.db.outboxDao.getByClientId('edit-1'))!;
        expect(op.status, OutboxStatus.conflict);
        expect(op.lastErrorCode, 'DEMANDE_NON_OUVERTE');
      },
    );

    test(
      'livraison saisie pour une demande annulee : enregistree, non rattachee avec motif',
      () async {
        h.remote.materials.setStatus(_requestId, 'Cancelled');
        await h.record('liv-1');

        await h.engine.run();

        final row = await h.delivery('liv-1');
        expect(row.number, 'LIV-001');
        expect(row.requestId, isNull);
        expect(row.unattachedReason, 'RequestNotOpen');
        expect(row.isUnattached, isTrue);
      },
    );

    test(
      'livraison avant commande : demande validee, livraison retenue',
      () async {
        final late = _Harness();
        addTearDown(late.dispose);
        await late.prepare(status: 'Validated');
        await late.record('liv-1');
        await late.engine.run();
        final row = await late.delivery('liv-1');
        expect(row.requestId, _requestId);
        expect(row.unattachedReason, isNull);
        expect(row.quantityInRequest!.value, Decimal.parse('200'));
        // Le statut du serveur reste « Validee » : la livraison est seulement retenue.
        expect(
          late.remote.materials.requests[_requestId]!['status'],
          'Validated',
        );
      },
    );

    test(
      'unites incompatibles (sable en T pour une commande en m3) : rejetee avec son code',
      () async {
        final sand = _Harness();
        addTearDown(sand.dispose);
        await sand.prepare();
        sand.remote.materials.requests[_requestId] = requestJson(
          id: _requestId,
          siteId: _siteId,
          status: 'Ordered',
          quantity: 24,
          unit: 'm3',
          version: '51001',
        );
        await sand.record('liv-1');
        await sand.engine.run();
        final op = (await sand.db.outboxDao.getByClientId('liv-1'))!;
        expect(op.status, OutboxStatus.rejected);
        expect(op.lastErrorCode, 'UNITES_INCOMPATIBLES');
      },
    );
  });

  group('lecture : pull des livraisons et des photos (M6, M8)', () {
    test('livraison et photo decodees ; demande rattachee', () async {
      h.remote.pullScript.add(
        SyncPullResponse.fromJson(
          syncPullJson(
            changes: [
              syncChangeJson(
                'delivery',
                deliveryJson(siteId: _siteId, requestId: _requestId),
                version: '49800',
              ),
              syncChangeJson(
                'photo',
                photoJson(siteId: _siteId),
                version: '49900',
              ),
            ],
          ),
        ),
      );
      await h.engine.run();

      final row = (await h.db.deliveriesDao.getById(
        '0192a000-0000-7000-8000-000000000601',
      ))!;
      expect(row.number, 'LIV-006');
      expect(row.quantity, Quantity(Decimal.parse('10'), MeasureUnit.tonne));
      expect(
        row.quantityInRequest,
        Quantity(Decimal.parse('200'), MeasureUnit.bag),
      );
      expect(row.deliveryDate, DateTime.utc(2026, 11, 4));
      expect(row.deliveryNoteNumber, 'BL-4471');
      final photo = (await h.db.deliveryPhotosDao.getById(
        '0192a000-0000-7000-8000-000000000701',
      ))!;
      expect(photo.contentStatus, 'Uploaded');
      expect(photo.isPending, isFalse);
    });

    test(
      'aucun montant en base meme si le serveur en envoie (ADR 0012)',
      () async {
        final data = deliveryJson(siteId: _siteId)
          ..['commercial'] = {'amount': 156000.0}
          ..['photos'] = [
            {'id': 'x', 'contentStatus': 'Uploaded'},
          ]
          ..['missingNote'] = false
          ..['history'] = [
            {
              'id': 'e1',
              'type': 'OrderCommercialEdited',
              'occurredAt': '2026-11-04T09:00:00Z',
              'changes': [
                {'field': 'unitPrice', 'old': '780.00', 'new': '800.00'},
              ],
            },
            {
              'id': 'e2',
              'type': 'DeliveryEdited',
              'occurredAt': '2026-11-04T09:05:00Z',
              'changes': [
                {'field': 'amount', 'old': '1', 'new': '156000.00'},
                {'field': 'quantity', 'old': '8 t', 'new': '10 t'},
              ],
            },
          ];
        h.remote.pullScript.add(
          SyncPullResponse.fromJson(
            syncPullJson(
              changes: [syncChangeJson('delivery', data, version: '49800')],
            ),
          ),
        );
        await h.engine.run();

        final rows = await h.db.customSelect('SELECT * FROM deliveries').get();
        final dump = jsonEncode([
          for (final row in rows) row.data.map((k, v) => MapEntry(k, '$v')),
        ]);
        expect(dump, isNot(contains('156000')));
        expect(dump, isNot(contains('780')));
        expect(dump, isNot(contains('OrderCommercialEdited')));
        expect(dump, isNot(contains('commercial')));
        expect(dump, contains('DeliveryEdited'));
      },
    );

    test(
      'etat du serveur d un conflit : liste blanche, jamais de montant',
      () async {
        await h.record('liv-1');
        await h.engine.run();
        final view = DeliveryView.plain(await h.delivery('liv-1'));
        await h.deliveries.edit(
          view: view,
          draft: DeliveryEditDraft(
            quantity: Quantity(Decimal.parse('8'), MeasureUnit.tonne),
            deliveryDate: view.row.deliveryDate,
            deliveryNoteNumber: view.row.deliveryNoteNumber,
          ),
          userId: _user,
          clientId: 'edit-1',
          label: 'LIV-001',
        );
        h.remote.deliveries.cancelElsewhere(view.row.id);
        h.remote.deliveries.deliveries[view.row.id]!
          ..['commercial'] = {'amount': 156000.0}
          ..['photos'] = [
            {'id': 'p'},
          ];

        await h.engine.run();

        final op = (await h.db.outboxDao.getByClientId('edit-1'))!;
        expect(op.conflictJson, isNotNull);
        expect(op.conflictJson, isNot(contains('156000')));
        expect(op.conflictJson, isNot(contains('commercial')));
        expect(op.conflictJson, isNot(contains('photos')));
      },
    );

    test(
      'un role sans DeliveryPhotos.View ne recoit aucune ligne photo : rien en base',
      () async {
        h.remote.pullScript.add(
          SyncPullResponse.fromJson(
            syncPullJson(
              changes: [
                syncChangeJson(
                  'delivery',
                  deliveryJson(siteId: _siteId),
                  version: '49800',
                ),
              ],
            ),
          ),
        );
        await h.engine.run();
        expect(
          await h.db.deliveryPhotosDao.countByDelivery(
            '0192a000-0000-7000-8000-000000000601',
          ),
          0,
        );
      },
    );
  });
}
