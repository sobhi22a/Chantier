// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'site_type.dart';

part 'update_site_request.freezed.dart';
part 'update_site_request.g.dart';

/// Modification : pas de `code` (immuable). `version` est la valeur lue, pour détecter une modification concurrente.
@Freezed()
abstract class UpdateSiteRequest with _$UpdateSiteRequest {
  const factory UpdateSiteRequest({
    /// Version lue avec le chantier ; une version périmée donne 409 `CONFLIT_VERSION`.
    required String version,

    /// Nom du chantier (français).
    required String name,

    /// Type d'ouvrage.
    required SiteType? type,

    /// Wilaya (liste de référence).
    required String wilaya,

    /// Commune (liste de la wilaya ; une saisie libre est acceptée).
    required String commune,

    /// Maître d'ouvrage.
    required String owner,

    /// Nom en arabe (facultatif) : affiché à la place du nom français s'il est présent.
    String? nameAr,

    /// Latitude en degrés décimaux (va avec la longitude).
    double? latitude,

    /// Longitude en degrés décimaux (va avec la latitude).
    double? longitude,

    /// Numéro du marché.
    String? contractNumber,

    /// Montant du marché en DZD, 2 décimales.
    double? contractAmount,

    /// Délai en jours calendaires (entier supérieur à 0).
    int? delayDays,

    /// Date complète de l'ordre de service de démarrage ; une date incomplète (`../03/2026`) donne `DATE_INVALIDE`.
    DateTime? odsDate,
  }) = _UpdateSiteRequest;

  factory UpdateSiteRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateSiteRequestFromJson(json);
}
