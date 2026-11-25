// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem_details.freezed.dart';
part 'problem_details.g.dart';

/// Erreur au format RFC 9457 (`application/problem+json`). Les clients traduisent `code` ; `title` et `detail` ne sont qu'un repli en français.
@Freezed()
abstract class ProblemDetails with _$ProblemDetails {
  const factory ProblemDetails({
    /// URI stable du type d'erreur, dérivée de `code`.
    required String type,
    required String title,

    /// Code HTTP.
    required int status,

    /// Code métier stable (`VALIDATION`, `INTROUVABLE`, `ZONE_EXISTANTE`...). Ensemble ouvert : un client ignore un code qu'il ne connaît pas et affiche `title`.
    required String code,

    /// Identifiant à communiquer au support.
    required String traceId,
    String? detail,
    String? instance,

    /// Détail par champ (400 `VALIDATION`) : nom du champ en camelCase, puis les messages.
    Map<String, List<String>>? errors,

    /// 409 `CONFLIT_VERSION` : état actuel de la ressource (même JSON que sa réponse REST).
    dynamic current,
  }) = _ProblemDetails;

  factory ProblemDetails.fromJson(Map<String, Object?> json) =>
      _$ProblemDetailsFromJson(json);
}
