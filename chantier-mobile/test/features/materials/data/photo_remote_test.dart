import 'dart:io';
import 'dart:typed_data';

import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/storage/token_pair.dart';
import 'package:chantier_mobile/features/materials/data/photo_remote.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/api_json.dart';
import '../../../support/fake_http_adapter.dart';
import '../../../support/memory_token_store.dart';
import '../../../support/photo_support.dart';

/// `PUT .../photos/{id}/content` : le corps est l'image brute, `Content-Type: image/jpeg`, envoyee
/// par le client HTTP de l'application (jeton, erreurs typees). Aucun appel reseau reel.
void main() {
  late FakeHttpAdapter adapter;
  late DioClient client;
  late PhotoRemoteSource remote;
  late Directory directory;
  late File file;

  setUp(() {
    adapter = FakeHttpAdapter();
    client = DioClient(
      config: const AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1'),
      tokenStore: MemoryTokenStore(
        const TokenPair(accessToken: 'ACCESS-SECRET', refreshToken: 'REFRESH'),
      ),
      events: SessionEvents(),
      languageCode: () => 'fr',
      adapter: adapter,
    );
    remote = PhotoRemoteSource(client);
    directory = Directory.systemTemp.createTempSync('chantier_remote_');
    file = File('${directory.path}/bon.jpg')
      ..writeAsBytesSync(jpegBytes(size: 4096));
  });
  tearDown(() => directory.deleteSync(recursive: true));

  test('PUT du fichier : JPEG brut, longueur, jeton, un seul envoi', () async {
    adapter.respond(
      'PUT /sites/s-1/photos/p-1/content',
      FakeResponse.ok(photoJson(id: 'p-1', siteId: 's-1')),
    );

    final response = await remote.upload(
      siteId: 's-1',
      photoId: 'p-1',
      file: file,
    );

    expect(response.id, 'p-1');
    expect(response.contentStatus.json, 'Uploaded');
    final call = adapter.callsTo('PUT /sites/s-1/photos/p-1/content').single;
    expect(call.header('Content-Type'), startsWith('image/jpeg'));
    expect(call.header('Content-Length'), '4096');
    expect(call.header('Authorization'), 'Bearer ACCESS-SECRET');
  });

  test('refus du serveur : erreur typee avec son code', () async {
    adapter.respond(
      'PUT /sites/s-1/photos/p-1/content',
      FakeResponse.problem(415, 'TYPE_FICHIER_REFUSE'),
    );
    await expectLater(
      remote.upload(siteId: 's-1', photoId: 'p-1', file: file),
      throwsA(
        isA<ApiException>()
            .having((e) => e.status, 'statut', 415)
            .having((e) => e.code, 'code', 'TYPE_FICHIER_REFUSE'),
      ),
    );
  });

  test('409 CONFLIT_VERSION : erreur de conflit (a rejouer, R2-04)', () async {
    adapter.respond(
      'PUT /sites/s-1/photos/p-1/content',
      FakeResponse.problem(409, 'CONFLIT_VERSION'),
    );
    await expectLater(
      remote.upload(siteId: 's-1', photoId: 'p-1', file: file),
      throwsA(
        isA<ConflictApiException>().having(
          (e) => e.code,
          'code',
          'CONFLIT_VERSION',
        ),
      ),
    );
  });

  test('coupure reseau : erreur de reseau', () async {
    adapter.on(
      'PUT /sites/s-1/photos/p-1/content',
      (_) => throw connectionError(),
    );
    await expectLater(
      remote.upload(siteId: 's-1', photoId: 'p-1', file: file),
      throwsA(isA<NetworkApiException>()),
    );
  });

  test('lecture sans le droit : 404 introuvable', () async {
    // Sans le droit `DeliveryPhotos.View` (ou photo d'un autre chantier) : 404 identique.
    adapter.respond(
      'GET /sites/s-1/photos/p-2/content',
      FakeResponse.problem(404, 'INTROUVABLE'),
    );
    await expectLater(
      remote.download(siteId: 's-1', photoId: 'p-2'),
      throwsA(isA<NotFoundApiException>()),
    );
  });

  group('PhotoViewer : en memoire seulement', () {
    test('cache borne, vide a la deconnexion', () async {
      final photos = FakePhotoRemote();
      for (var i = 1; i <= 4; i++) {
        photos.downloads['p-$i'] = Uint8List.fromList([i]);
      }
      final viewer = PhotoViewer(photos, capacity: 2);

      await viewer.load(siteId: 's', photoId: 'p-1');
      await viewer.load(siteId: 's', photoId: 'p-1');
      expect(photos.downloadCalls, ['p-1']);

      await viewer.load(siteId: 's', photoId: 'p-2');
      await viewer.load(siteId: 's', photoId: 'p-3');
      // p-1 est sortie du cache (capacite 2) : rechargee.
      await viewer.load(siteId: 's', photoId: 'p-1');
      expect(photos.downloadCalls, ['p-1', 'p-2', 'p-3', 'p-1']);

      viewer.clear();
      await viewer.load(siteId: 's', photoId: 'p-1');
      expect(photos.downloadCalls.length, 5);
    });

    test('une erreur n est jamais gardee', () async {
      final photos = FakePhotoRemote();
      final viewer = PhotoViewer(photos);
      await expectLater(
        viewer.load(siteId: 's', photoId: 'absente'),
        throwsA(isA<NotFoundApiException>()),
      );
      photos.downloads['absente'] = Uint8List.fromList([9]);
      expect(await viewer.load(siteId: 's', photoId: 'absente'), [9]);
    });
  });
}
