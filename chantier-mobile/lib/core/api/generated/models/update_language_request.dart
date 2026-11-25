// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_language_request.freezed.dart';
part 'update_language_request.g.dart';

/// Langue de l'interface.
@Freezed()
abstract class UpdateLanguageRequest with _$UpdateLanguageRequest {
  const factory UpdateLanguageRequest({
    /// `fr` ou `ar`.
    required String language,
  }) = _UpdateLanguageRequest;

  factory UpdateLanguageRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateLanguageRequestFromJson(json);
}
