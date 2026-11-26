import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:dio/dio.dart';

/// Ce dont l'envoi et l'affichage des photos de bons ont besoin du serveur. L'implementation de
/// production appelle l'API ; les tests utilisent un faux serveur (aucun appel reseau reel).
///
/// Chaque methode leve une `ApiException` typee en cas d'echec.
abstract interface class PhotoRemote {
  /// `PUT /sites/{siteId}/photos/{photoId}/content` : le fichier JPEG complet (reprise = renvoi
  /// complet, idempotent par empreinte, ADR 0013).
  Future<PhotoResponse> upload({
    required String siteId,
    required String photoId,
    required File file,
  });

  /// `GET /sites/{siteId}/photos/{photoId}/content` : les octets du JPEG (404 sans le droit
  /// `DeliveryPhotos.View`, indiscernable d'une photo inexistante).
  Future<Uint8List> download({required String siteId, required String photoId});
}

/// Acces reseau aux photos par le client HTTP de l'application (jeton, rejeu apres 401, erreurs
/// typees).
///
/// Le `PUT` n'utilise **pas** la methode du client genere : le corps est l'image brute avec
/// `Content-Type: image/jpeg`, alors que le client HTTP envoie du JSON par defaut ; le fichier
/// est lu en flux (jamais charge entierement en memoire).
class PhotoRemoteSource implements PhotoRemote {
  PhotoRemoteSource(this._client);

  final DioClient _client;

  static const Duration uploadTimeout = Duration(minutes: 2);

  @override
  Future<PhotoResponse> upload({
    required String siteId,
    required String photoId,
    required File file,
  }) async {
    final length = await file.length();
    final response = await _client.put<Map<String, dynamic>>(
      '/sites/$siteId/photos/$photoId/content',
      data: file.openRead(),
      options: Options(
        contentType: 'image/jpeg',
        headers: {Headers.contentLengthHeader: length},
        sendTimeout: uploadTimeout,
        receiveTimeout: uploadTimeout,
      ),
    );
    return DioClient.guard(() async => PhotoResponse.fromJson(response.data!));
  }

  @override
  Future<Uint8List> download({
    required String siteId,
    required String photoId,
  }) async {
    final response = await _client.get<List<int>>(
      '/sites/$siteId/photos/$photoId/content',
      options: Options(responseType: ResponseType.bytes),
    );
    return DioClient.guard(
      () async => Uint8List.fromList(response.data ?? const []),
    );
  }
}

/// Affichage d'une photo deja envoyee : chargee **a la demande, avec reseau**, gardee **en memoire
/// seulement** (quelques images, jamais en base ni sur disque) et videe a la deconnexion
/// (CA-MAT-007.8, ADR 0013).
class PhotoViewer {
  PhotoViewer(this._remote, {this.capacity = 6});

  final PhotoRemote _remote;
  final int capacity;
  final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap();

  Future<Uint8List> load({
    required String siteId,
    required String photoId,
  }) async {
    final cached = _cache.remove(photoId);
    if (cached != null) {
      _cache[photoId] = cached;
      return cached;
    }
    final bytes = await _remote.download(siteId: siteId, photoId: photoId);
    _cache[photoId] = bytes;
    while (_cache.length > capacity) {
      _cache.remove(_cache.keys.first);
    }
    return bytes;
  }

  /// Vide le cache (deconnexion, changement de compte).
  void clear() => _cache.clear();
}
