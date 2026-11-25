// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'me_response.freezed.dart';
part 'me_response.g.dart';

/// Profil du titulaire : le seul endroit ou son telephone est renvoye (H-17, CT-14).
@Freezed()
abstract class MeResponse with _$MeResponse {
  const factory MeResponse({
    required String id,
    required String userName,
    required String fullName,
    required String? phoneNumber,
    required String role,
    required String language,
    required List<String> permissions,
    required String permissionsVersion,
    required bool mustChangePassword,
  }) = _MeResponse;

  factory MeResponse.fromJson(Map<String, Object?> json) =>
      _$MeResponseFromJson(json);
}
