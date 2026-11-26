// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_photo_request.dart';
import '../models/photo_response.dart';

part 'photos_client.g.dart';

@RestApi()
abstract class PhotosClient {
  factory PhotosClient(Dio dio, {String? baseUrl}) = _PhotosClient;

  /// Créer les métadonnées d'une photo du bon (5 au plus par livraison : 422 `PHOTOS_TROP_NOMBREUSES`). Un même `clientId` renvoyé donne 200 et les mêmes métadonnées.
  @POST('/api/v1/sites/{siteId}/deliveries/{deliveryId}/photos')
  Future<PhotoResponse> photosCreate({
    @Path('siteId') required String siteId,
    @Path('deliveryId') required String deliveryId,
    @Body() required CreatePhotoRequest body,
  });

  /// Lire le fichier (`image/jpeg`, `nosniff`, `Cache-Control: private, no-cache` avec un `ETag` : revalidation à chaque lecture, `304` si inchangée). Une photo d'un autre chantier, non envoyée, ou sans le droit `DeliveryPhotos.View` est.
  /// introuvable (404 identique) : le droit se vérifie dans le service pour ne pas distinguer « interdit » de « inexistant ».
  @GET('/api/v1/sites/{siteId}/photos/{photoId}/content')
  @DioResponseType(ResponseType.stream)
  Stream<String> photosDownload({
    @Path('siteId') required String siteId,
    @Path('photoId') required String photoId,
  });

  /// Envoyer le fichier : le corps est l'image JPEG elle-même (`Content-Type: image/jpeg`, 5 Mo au plus, cible 2 Mo). Vérifié par ses octets magiques ; l'empreinte.
  /// SHA-256 doit être celle déclarée ; les métadonnées EXIF (GPS, appareil) sont retirées sans réencodage. Même contenu renvoyé : 200 sans effet ; autre contenu sur une photo.
  /// déjà envoyée : 409 `PHOTO_DEJA_ENVOYEE` ; 413 `FICHIER_TROP_GROS` ; 415 `TYPE_FICHIER_REFUSE`.
  @PUT('/api/v1/sites/{siteId}/photos/{photoId}/content')
  Future<PhotoResponse> photosUpload({
    @Path('siteId') required String siteId,
    @Path('photoId') required String photoId,
    @Body() required File body,
  });
}
