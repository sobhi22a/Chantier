import 'dart:io';
import 'dart:typed_data';

import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/utils/sha256.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/data/photo_capture.dart';
import 'package:chantier_mobile/features/materials/data/photo_files.dart';
import 'package:chantier_mobile/features/materials/data/photo_remote.dart';
import 'package:chantier_mobile/features/materials/data/photo_upload_service.dart';

import 'fake_deliveries_server.dart';

/// Octets d'un JPEG factice (en-tete `FF D8 FF`, fin `FF D9`) ; [seed] differencie deux images.
Uint8List jpegBytes({int size = 2048, int seed = 1}) {
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = (i * 31 + seed) & 0xFF;
  }
  bytes[0] = 0xFF;
  bytes[1] = 0xD8;
  bytes[2] = 0xFF;
  bytes[size - 2] = 0xFF;
  bytes[size - 1] = 0xD9;
  return bytes;
}

/// Dossier prive temporaire d'un test (aucun appel a `path_provider`) ; a supprimer a la fin.
class PhotoTestBed {
  PhotoTestBed()
    : root = Directory.systemTemp.createTempSync('chantier_photos_') {
    files = PhotoFiles(rootProvider: () async => root);
  }

  final Directory root;
  late final PhotoFiles files;
  int _counter = 0;

  /// Fichier JPEG factice, comme celui que rend l'appareil photo (dossier temporaire du plugin).
  File cameraFile({int size = 2048, int? seed}) {
    final file = File(
      '${root.path}${Platform.pathSeparator}camera_${_counter++}.jpg',
    );
    file.writeAsBytesSync(jpegBytes(size: size, seed: seed ?? _counter + 1));
    return file;
  }

  /// Photo rangee dans le dossier prive de [owner], comme apres « Garder ».
  Future<CapturedPhoto> capture({
    required String owner,
    required String clientId,
    int size = 2048,
    int? seed,
    DateTime? takenAt,
  }) => files.importCaptured(
    source: cameraFile(size: size, seed: seed),
    ownerUserId: owner,
    clientId: clientId,
    takenAt: takenAt ?? DateTime.utc(2026, 11, 25, 8, 10),
    maxBytes: 5242880,
  );

  PhotoUploadService uploads(
    AppDatabase db,
    PhotoRemote remote, {
    DateTime Function()? now,
  }) => PhotoUploadService(
    database: db,
    remote: remote,
    files: files,
    now: now,
    batchSize: 3,
  );

  void dispose() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  }
}

/// Appareil photo simule : rend les fichiers prepares, dans l'ordre (`null` = l'utilisateur annule).
class FakePhotoCapture implements PhotoCapture {
  FakePhotoCapture(this.bed);

  final PhotoTestBed bed;
  final List<File?> script = [];
  int calls = 0;

  /// Prepare [count] photos : chacune a sa propre image.
  void queue(int count, {int size = 2048}) {
    for (var i = 0; i < count; i++) {
      script.add(bed.cameraFile(size: size));
    }
  }

  @override
  Future<File?> takePhoto() async {
    calls++;
    return script.isEmpty ? null : script.removeAt(0);
  }
}

/// Faux serveur des fichiers de photos (aucun appel reseau reel) : verifie les octets magiques et
/// l'empreinte declaree a la creation des metadonnees, comme le serveur (ADR 0013). Un meme contenu
/// renvoye donne 200 sans effet ; un autre contenu sur une photo deja envoyee, 409.
class FakePhotoRemote implements PhotoRemote {
  FakePhotoRemote([this.server]);

  /// Faux serveur de synchronisation : source des metadonnees (empreinte declaree, chantier,
  /// livraison). Sans lui, tout fichier JPEG est accepte.
  final FakeDeliveriesServer? server;

  /// Empreinte declaree par photo (`photoId` -> sha256) ; renseignee par le faux serveur de
  /// synchronisation a la creation des metadonnees.
  final Map<String, String> declared = {};

  /// Fichiers recus (`photoId` -> octets).
  final Map<String, Uint8List> stored = {};

  /// Appels de `upload`, dans l'ordre (`photoId`).
  final List<String> uploadCalls = [];

  /// Erreurs a lever, dans l'ordre, avant de reussir (`null` = reussir).
  final List<ApiException?> script = [];

  /// Coupure apres ecriture : le serveur a le fichier, la reponse se perd.
  bool loseNextResponse = false;

  /// Version attribuee aux photos envoyees.
  int nextVersion = 70000;

  /// Octets servis par `download`.
  final Map<String, Uint8List> downloads = {};
  final List<String> downloadCalls = [];

  @override
  Future<PhotoResponse> upload({
    required String siteId,
    required String photoId,
    required File file,
  }) async {
    uploadCalls.add(photoId);
    if (script.isNotEmpty) {
      final error = script.removeAt(0);
      if (error != null) throw error;
    }
    final bytes = file.readAsBytesSync();
    if (bytes.length < 3 || bytes[0] != 0xFF || bytes[1] != 0xD8) {
      throw const UnknownApiException(status: 415, code: 'TYPE_FICHIER_REFUSE');
    }
    final metadata = server?.photos[photoId];
    if (server != null && metadata == null) {
      throw const NotFoundApiException(status: 404);
    }
    final declaredSha = server?.declaredSha[photoId] ?? declared[photoId];
    if (declaredSha != null && declaredSha != Sha256.hex(bytes)) {
      throw const BusinessRuleApiException(
        status: 422,
        code: 'TYPE_FICHIER_REFUSE',
      );
    }
    final known = stored[photoId];
    if (known != null && Sha256.hex(known) != Sha256.hex(bytes)) {
      throw const ConflictApiException(status: 409, code: 'PHOTO_DEJA_ENVOYEE');
    }
    stored[photoId] = bytes;
    if (metadata != null) server!.markUploaded(photoId, bytes.length);
    if (loseNextResponse) {
      loseNextResponse = false;
      throw const NetworkApiException();
    }
    if (metadata != null) return PhotoResponse.fromJson(metadata);
    return PhotoResponse.fromJson({
      'id': photoId,
      'siteId': siteId,
      'deliveryId': 'liv-srv',
      'clientId': null,
      'takenAt': '2026-11-25T08:10:00Z',
      'contentType': 'image/jpeg',
      'sizeBytes': bytes.length,
      'contentStatus': 'Uploaded',
      'uploadedAt': '2026-11-25T09:00:00Z',
      'version': '${nextVersion++}',
      'createdAt': '2026-11-25T08:11:00Z',
    });
  }

  @override
  Future<Uint8List> download({
    required String siteId,
    required String photoId,
  }) async {
    downloadCalls.add(photoId);
    final bytes = downloads[photoId];
    if (bytes == null) throw const NotFoundApiException(status: 404);
    return bytes;
  }
}
