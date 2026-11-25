// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'site_member_response.freezed.dart';
part 'site_member_response.g.dart';

/// Personne affectée au chantier : nom et rôle, jamais de téléphone ni d'identifiant de connexion (H-17).
@Freezed()
abstract class SiteMemberResponse with _$SiteMemberResponse {
  const factory SiteMemberResponse({
    required String userId,
    required String fullName,
    required String role,

    /// Date d'affectation (heure du serveur, UTC).
    required DateTime assignedAt,
  }) = _SiteMemberResponse;

  factory SiteMemberResponse.fromJson(Map<String, Object?> json) =>
      _$SiteMemberResponseFromJson(json);
}
