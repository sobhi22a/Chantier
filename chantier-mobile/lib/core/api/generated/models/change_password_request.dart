// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_password_request.freezed.dart';
part 'change_password_request.g.dart';

/// Changement de mot de passe (8 caractères au moins, dont un chiffre).
@Freezed()
abstract class ChangePasswordRequest with _$ChangePasswordRequest {
  const factory ChangePasswordRequest({
    /// Mot de passe actuel (ou provisoire).
    required String currentPassword,

    /// Nouveau mot de passe ; sinon 422 `MOT_DE_PASSE_FAIBLE`.
    required String newPassword,
  }) = _ChangePasswordRequest;

  factory ChangePasswordRequest.fromJson(Map<String, Object?> json) =>
      _$ChangePasswordRequestFromJson(json);
}
