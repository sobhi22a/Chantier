// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'material_reasons_response.dart';

part 'material_settings_response.freezed.dart';
part 'material_settings_response.g.dart';

/// Réglages lus par le mobile à chaque synchronisation (hors ligne : dernière copie).
@Freezed()
abstract class MaterialSettingsResponse with _$MaterialSettingsResponse {
  const factory MaterialSettingsResponse({
    /// Date de besoin proposée = aujourd'hui + ce nombre de jours.
    required int defaultNeededByDays,

    /// Tolérance de « livraison complète » en pourcentage de la quantité commandée.
    required double deliveryTolerancePercent,

    /// Nombre maximal de photos de bon de livraison par livraison.
    required int maxPhotosPerDelivery,

    /// Taille maximale d'une photo, en octets.
    required int maxPhotoBytes,

    /// Longueur maximale d'une remarque.
    required int noteMaxLength,
    required MaterialReasonsResponse reasons,
  }) = _MaterialSettingsResponse;

  factory MaterialSettingsResponse.fromJson(Map<String, Object?> json) =>
      _$MaterialSettingsResponseFromJson(json);
}
