// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'site_type.dart';

part 'site_response.freezed.dart';
part 'site_response.g.dart';

/// Chantier tel que renvoyé par l'API et par la synchronisation (même JSON). Le montant du marché (`contractAmount`) est.
/// <b>absent</b> de la réponse (et non masqué) sans la permission `ContractAmount.View` (CT-20, CA-003.5).
@Freezed()
abstract class SiteResponse with _$SiteResponse {
  const factory SiteResponse({
    required String id,

    /// Code unique et immuable, par exemple `CH-ECO-UV18`.
    required String code,
    required String name,

    /// Nom en arabe, s'il existe.
    required String? nameAr,
    required SiteType type,
    required String wilaya,
    required String commune,
    required double? latitude,
    required double? longitude,
    required String owner,
    required String? contractNumber,

    /// Délai contractuel en jours calendaires.
    required int? delayDays,

    /// Date de l'ordre de service de démarrage.
    required DateTime? odsDate,

    /// Fin contractuelle = date de l'ODS + délai, calculée par le serveur ; `null` si l'un des deux manque (« À définir »).
    required DateTime? contractualEndDate,

    /// Date d'archivage ; un chantier archivé est en lecture seule.
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

    /// Montant du marché en DZD (2 décimales) ; absent sans la permission `ContractAmount.View`.
    double? contractAmount,
  }) = _SiteResponse;

  factory SiteResponse.fromJson(Map<String, Object?> json) =>
      _$SiteResponseFromJson(json);
}
