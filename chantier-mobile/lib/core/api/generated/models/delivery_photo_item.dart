// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'photo_content_status.dart';

part 'delivery_photo_item.freezed.dart';
part 'delivery_photo_item.g.dart';

/// Photo du bon dans une livraison : ni chemin de stockage, ni empreinte.
@Freezed()
abstract class DeliveryPhotoItem with _$DeliveryPhotoItem {
  const factory DeliveryPhotoItem({
    required String id,
    required PhotoContentStatus contentStatus,
    required int sizeBytes,
    required DateTime takenAt,
  }) = _DeliveryPhotoItem;

  factory DeliveryPhotoItem.fromJson(Map<String, Object?> json) =>
      _$DeliveryPhotoItemFromJson(json);
}
