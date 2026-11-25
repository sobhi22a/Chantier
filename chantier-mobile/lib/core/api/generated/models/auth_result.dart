// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user_response.dart';

part 'auth_result.freezed.dart';
part 'auth_result.g.dart';

/// Resultat de connexion ou de rafraichissement. Web (`isAppMobile = false`) : cookie + `user`.
/// Mobile : en plus `accessToken` (15 min), `refreshToken` (14 jours, rotatif) et `expiresIn` (secondes).
@Freezed()
abstract class AuthResult with _$AuthResult {
  const factory AuthResult({
    required AuthUserResponse user,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) = _AuthResult;

  factory AuthResult.fromJson(Map<String, Object?> json) =>
      _$AuthResultFromJson(json);
}
