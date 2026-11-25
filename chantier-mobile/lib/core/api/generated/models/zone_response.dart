// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'room_type.dart';

part 'zone_response.freezed.dart';
part 'zone_response.g.dart';

/// Zone d'un chantier : bloc, cote (en mètres) et local. Identique à la ligne `zone` de la synchronisation.
@Freezed()
abstract class ZoneResponse with _$ZoneResponse {
  const factory ZoneResponse({
    required String id,
    required String siteId,

    /// Identifiant généré par le téléphone qui a créé la zone (création hors ligne), sinon `null`.
    required String? clientId,

    /// « Saisi le » du téléphone : information seulement, jamais utilisée pour trier ou décider.
    required DateTime? clientCreatedAt,

    /// Bloc, par exemple `Bloc 01`.
    required String block,

    /// Cote en mètres, 2 décimales (affichage signé côté client : −1,90 ; ±0,00 ; +3,40).
    required double? elevation,

    /// Type de local.
    required RoomType? roomType,

    /// Numéro du local (classe 02).
    required int? roomNumber,

    /// Libellé libre, seulement si le type est `Other`.
    required String? roomLabel,

    /// Date d'archivage ; une zone archivée n'est plus proposée à la saisie.
    required DateTime? archivedAt,

    /// Nom de la personne qui a archivé.
    required String? archivedByName,

    /// Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification.
    required String version,

    /// Création (heure du serveur, UTC).
    required DateTime createdAt,

    /// Nom du créateur.
    required String? createdByName,

    /// Dernière modification (heure du serveur, UTC).
    required DateTime? updatedAt,

    /// Nom de la dernière personne ayant modifié.
    required String? updatedByName,
  }) = _ZoneResponse;

  factory ZoneResponse.fromJson(Map<String, Object?> json) =>
      _$ZoneResponseFromJson(json);
}
