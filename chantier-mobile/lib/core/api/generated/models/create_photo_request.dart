// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_photo_request.freezed.dart';
part 'create_photo_request.g.dart';

/// Métadonnées d'une photo de bon de livraison (créables hors ligne) ; le fichier JPEG est envoyé ensuite par `PUT .../content`.
@Freezed()
abstract class CreatePhotoRequest with _$CreatePhotoRequest {
  const factory CreatePhotoRequest({
    /// Identifiant généré par le téléphone : un renvoi donne 200 et les mêmes métadonnées.
    String? clientId,
    DateTime? clientCreatedAt,

    /// Heure de la prise de vue (téléphone) : information seulement.
    DateTime? takenAt,

    /// Toujours `image/jpeg` (415 `TYPE_FICHIER_REFUSE` sinon).
    String? contentType,

    /// Taille du fichier envoyé, en octets (413 `FICHIER_TROP_GROS` au-delà de `maxPhotoBytes`).
    int? sizeBytes,

    /// Empreinte SHA-256 du fichier envoyé (64 caractères hexadécimaux) : rend l'envoi du fichier idempotent et vérifie son intégrité.
    String? sha256,
  }) = _CreatePhotoRequest;

  factory CreatePhotoRequest.fromJson(Map<String, Object?> json) =>
      _$CreatePhotoRequestFromJson(json);
}
