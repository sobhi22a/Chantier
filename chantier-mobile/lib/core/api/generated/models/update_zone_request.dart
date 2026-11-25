// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'room_type.dart';

part 'update_zone_request.freezed.dart';
part 'update_zone_request.g.dart';

@Freezed()
abstract class UpdateZoneRequest with _$UpdateZoneRequest {
  const factory UpdateZoneRequest({
    /// Version lue avec la zone ; une version périmée donne 409 `CONFLIT_VERSION`.
    required String version,

    /// Bloc du chantier (obligatoire).
    required String block,

    /// Cote en mètres, 2 décimales, de -20,00 à +60,00 (paramétrable).
    double? elevation,

    /// Type de local (classe, couloir, cantine...).
    RoomType? roomType,

    /// Numéro du local (1 à 999) ; exige un type de local.
    int? roomNumber,

    /// Libellé libre, seulement si `roomType = Other`.
    String? roomLabel,
  }) = _UpdateZoneRequest;

  factory UpdateZoneRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateZoneRequestFromJson(json);
}
