// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user_response.freezed.dart';
part 'auth_user_response.g.dart';

/// Utilisateur renvoye apres connexion. Jamais de telephone ici : il n'est visible que par son titulaire via `GET /auth/me` (H-17).
@Freezed()
abstract class AuthUserResponse with _$AuthUserResponse {
  const factory AuthUserResponse({
    required String id,
    required String userName,
    required String fullName,
    required String role,
    required String language,
    required bool mustChangePassword,
  }) = _AuthUserResponse;

  factory AuthUserResponse.fromJson(Map<String, Object?> json) =>
      _$AuthUserResponseFromJson(json);
}
