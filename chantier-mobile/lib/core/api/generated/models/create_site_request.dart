// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'site_type.dart';

part 'create_site_request.freezed.dart';
part 'create_site_request.g.dart';

@Freezed()
abstract class CreateSiteRequest with _$CreateSiteRequest {
  const factory CreateSiteRequest({
    /// Code unique et immuable, proposé par `GET /sites/code-suggestion`.
    required String code,

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
  }) = _CreateSiteRequest;

  factory CreateSiteRequest.fromJson(Map<String, Object?> json) =>
      _$CreateSiteRequestFromJson(json);
}
