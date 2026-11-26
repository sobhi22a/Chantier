// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'photo_response_content_status.dart';

part 'photo_response.freezed.dart';
part 'photo_response.g.dart';

/// Photo d'un bon : metadonnees seulement (le fichier se lit par `GET .../photos/{id}/content`) ; ni chemin de stockage ni empreinte.
@Freezed()
abstract class PhotoResponse with _$PhotoResponse {
  const factory PhotoResponse({
    required String id,
    required String siteId,
    required String deliveryId,
    required String? clientId,
    required DateTime takenAt,
    required String contentType,
    required int sizeBytes,

    /// Etat du fichier d'une photo : les metadonnees existent (`Pending`), puis le binaire est envoye (`Uploaded`).
    required PhotoResponseContentStatus contentStatus,
    required DateTime? uploadedAt,
    required String version,
    required DateTime createdAt,
  }) = _PhotoResponse;

  factory PhotoResponse.fromJson(Map<String, Object?> json) =>
      _$PhotoResponseFromJson(json);
}
