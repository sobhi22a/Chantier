// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'content_status.dart';

part 'photos.freezed.dart';
part 'photos.g.dart';

@Freezed()
abstract class Photos with _$Photos {
  const factory Photos({
    required String id,

    /// Etat du fichier d'une photo : les metadonnees existent (`Pending`), puis le binaire est envoye (`Uploaded`).
    required ContentStatus contentStatus,
    required int sizeBytes,
    required DateTime takenAt,
  }) = _Photos;

  factory Photos.fromJson(Map<String, Object?> json) => _$PhotosFromJson(json);
}
