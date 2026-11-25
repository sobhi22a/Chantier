// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'room_type.dart';

part 'create_zone_request.freezed.dart';
part 'create_zone_request.g.dart';

/// Création, y compris hors ligne : `clientId` rend l'envoi idempotent.
@Freezed()
abstract class CreateZoneRequest with _$CreateZoneRequest {
  const factory CreateZoneRequest({
    /// Bloc du chantier (obligatoire).
    required String block,

    /// Identifiant généré par le téléphone : un renvoi avec le même `clientId` donne 200 et la même zone.
    String? clientId,

    /// Heure du téléphone à la saisie (« saisi le ») : information seulement, jamais utilisée pour trier ou décider.
    DateTime? clientCreatedAt,

    /// Cote en mètres, 2 décimales, de -20,00 à +60,00 (paramétrable).
    double? elevation,

    /// Type de local (classe, couloir, cantine...).
    RoomType? roomType,

    /// Numéro du local (1 à 999) ; exige un type de local.
    int? roomNumber,

    /// Libellé libre, seulement si `roomType = Other`.
    String? roomLabel,
  }) = _CreateZoneRequest;

  factory CreateZoneRequest.fromJson(Map<String, Object?> json) =>
      _$CreateZoneRequestFromJson(json);
}
