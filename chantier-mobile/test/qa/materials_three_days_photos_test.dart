// Q3 (CA-MAT-007.10, CA-MAT-010.1, CA-MAT-010.12) : trois jours sans reseau, 30 livraisons avec 5 photos chacune (150 photos).
// Au retour du reseau, tout part par lots, un fichier a la fois ; une coupure au milieu, puis une application tuee et relancee, ne perdent
// aucun fichier et n'en envoient aucun deux fois. Serveur simule : aucun appel reseau reel.
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/data/deliveries_repository.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_json.dart';
import '../support/fake_sync_remote.dart';
import '../support/fixtures.dart';
import '../support/photo_support.dart';
import '../support/test_database.dart';

class _MockMonitor extends Mock implements ConnectivityMonitor {}

const _siteId = '0192a000-0000-7000-8000-0000000000a1';
const _productId = '0192a000-0000-7000-8000-0000000000d1';
const _supplierId = '0192a000-0000-7000-8000-0000000000e1';
const _requestId = '0192a000-0000-7000-8000-0000000000f1';
const _user = 'user-a';
const _deliveries = 30;
const _photosPerDelivery = 5;

void main() {
  late AppDatabase db;
  late FakeSyncRemote remote;
  late PhotoTestBed bed;
  late FakePhotoRemote photoRemote;
  late DeliveriesRepository deliveries;
  late SyncEngine Function() newEngine;

  setUp(() async {
    db = createTestDatabase();
    remote = FakeSyncRemote();
    bed = PhotoTestBed();
    photoRemote = FakePhotoRemote(remote.deliveries);
    final monitor = _MockMonitor();
    when(() => monitor.hasNetworkInterface()).thenAnswer((_) async => true);
    final outbox = OutboxRepository(db);
    final materials = MaterialsRepository(
      database: db,
      outbox: outbox,
      now: () => DateTime.utc(2026, 11, 25, 9),
    );
    deliveries = DeliveriesRepository(
      database: db,
      outbox: outbox,
      now: () => DateTime.utc(2026, 11, 25, 9),
    );
    // Une « application tuee puis relancee » = un nouveau moteur et un nouveau service d'envoi sur la meme base et les memes fichiers.
    newEngine = () => SyncEngine(
      database: db,
      remote: remote,
      sites: SitesRepository(db),
      materials: materials,
      photoUploads: bed.uploads(db, photoRemote),
      currentUserId: () => _user,
      connectivity: monitor,
      backoff: Backoff(),
      now: () => DateTime.utc(2026, 11, 28, 10),
      pushBatchSize: 50,
    );
    await db.sitesDao.upsertIfNewer(siteRow(id: _siteId));
    await db.productsDao.upsertIfNewer(productRow(id: _productId));
    await db.suppliersDao.upsertIfNewer(supplierRow(id: _supplierId));
    remote.materials.requests[_requestId] = requestJson(
      id: _requestId,
      siteId: _siteId,
      status: 'Ordered',
      quantity: 600,
      version: '51000',
    );
    await db.materialRequestsDao.upsertIfNewer(
      requestRow(
        id: _requestId,
        siteId: _siteId,
        productId: _productId,
        quantity: '600',
        status: 'Ordered',
        requestedById: _user,
      ),
    );
  });

  tearDown(() async {
    await db.close();
    bed.dispose();
  });

  Future<void> recordThreeDays() async {
    final request = (await db.materialRequestsDao.getById(_requestId))!;
    final supplier = await db.suppliersDao.getById(_supplierId);
    for (var d = 0; d < _deliveries; d++) {
      final photos = [
        for (var p = 0; p < _photosPerDelivery; p++)
          await bed.capture(
            owner: _user,
            clientId: 'ph-$d-$p',
            seed: d * 10 + p + 1,
          ),
      ];
      final result = await deliveries.record(
        clientId: 'liv-$d',
        siteId: _siteId,
        userId: _user,
        recorderName: 'Mourad B.',
        draft: DeliveryDraft(
          request: const RequestRef.server(_requestId),
          supplierId: _supplierId,
          quantity: Quantity(Decimal.parse('1'), MeasureUnit.tonne),
          deliveryDate: DateTime.utc(2026, 11, 25),
          deliveryNoteNumber: 'BL-$d',
        ),
        label: 'LIV Ciment',
        photoLabel: 'Photo du bon',
        maxPhotos: 5,
        request: request,
        supplier: supplier,
        photos: photos,
      );
      expect(result, isA<DeliverySaved>(), reason: 'livraison $d');
    }
  }

  test(
    '150 photos en attente : tout part, un fichier a la fois, dans l ordre de prise, aucun fichier ne reste',
    () async {
      await recordThreeDays();
      expect(
        await db.deliveriesDao.countBySite(_siteId),
        _deliveries,
        reason: 'saisies gardees sur le telephone',
      );

      int storedFiles() => bed.root
          .listSync(recursive: true)
          .where((entity) => entity.path.contains('ph-'))
          .length;
      expect(
        storedFiles(),
        _deliveries * _photosPerDelivery,
        reason: 'precondition : les 150 fichiers sont sur le telephone',
      );

      await newEngine().run();

      expect(photoRemote.stored.length, _deliveries * _photosPerDelivery);
      expect(
        photoRemote.uploadCalls.toSet().length,
        _deliveries * _photosPerDelivery,
        reason: 'chaque photo une seule fois',
      );
      expect(photoRemote.uploadCalls.length, _deliveries * _photosPerDelivery);
      // Ordre de prise : les metadonnees partent dans l'ordre de saisie, les fichiers dans le meme ordre.
      final clientOfPhoto = {
        for (final entry in remote.deliveries.photos.entries)
          entry.key: entry.value['clientId'] as String,
      };
      final sent = [
        for (final id in photoRemote.uploadCalls) clientOfPhoto[id],
      ];
      final expected = [
        for (var d = 0; d < _deliveries; d++)
          for (var p = 0; p < _photosPerDelivery; p++) 'ph-$d-$p',
      ];
      expect(sent, expected);
      expect(remote.deliveries.photoCount, _deliveries * _photosPerDelivery);
      expect(
        await db.outboxDao.allFor(_user),
        isEmpty,
        reason: 'plus rien a envoyer',
      );
      expect(
        storedFiles(),
        0,
        reason: 'fichiers supprimes apres confirmation du serveur',
      );
    },
  );

  test(
    'coupure du reseau au milieu des 150 photos, puis application relancee : tout arrive, aucune photo en double, aucun fichier perdu',
    () async {
      await recordThreeDays();
      // 70 fichiers partent, le 71e se perd en route (reseau coupe), puis le reseau revient.
      photoRemote.script
        ..addAll(List<ApiException?>.filled(70, null))
        ..add(const NetworkApiException());

      await newEngine().run();

      expect(
        photoRemote.stored.length,
        70,
        reason: 'seuls 70 fichiers confirmes',
      );
      final pendingAfterCut = await db.deliveryPhotosDao.readyFilesFor(
        _user,
        limit: 500,
      );
      expect(
        pendingAfterCut.length,
        _deliveries * _photosPerDelivery - 70,
        reason: 'les 80 autres fichiers sont toujours la, jamais perdus',
      );

      // Application tuee puis relancee : nouveau moteur, meme base, memes fichiers.
      await newEngine().run();

      expect(photoRemote.stored.length, _deliveries * _photosPerDelivery);
      expect(remote.deliveries.photoCount, _deliveries * _photosPerDelivery);
      final calls = <String, int>{};
      for (final id in photoRemote.uploadCalls) {
        calls[id] = (calls[id] ?? 0) + 1;
      }
      expect(
        calls.values.where((count) => count > 1).length,
        lessThanOrEqualTo(1),
        reason:
            'au plus le fichier en cours au moment de la coupure est renvoye',
      );
      expect(
        (await db.deliveryPhotosDao.readyFilesFor(_user, limit: 500)),
        isEmpty,
      );
      expect(await db.outboxDao.allFor(_user), isEmpty);
    },
  );
}
