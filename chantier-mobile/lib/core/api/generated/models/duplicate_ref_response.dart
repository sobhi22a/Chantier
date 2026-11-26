// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'duplicate_ref_response.freezed.dart';
part 'duplicate_ref_response.g.dart';

/// Demande semblable deja ouverte (avertissement, jamais un blocage).
@Freezed()
abstract class DuplicateRefResponse with _$DuplicateRefResponse {
  const factory DuplicateRefResponse({
    required String id,
    required String number,
  }) = _DuplicateRefResponse;

  factory DuplicateRefResponse.fromJson(Map<String, Object?> json) =>
      _$DuplicateRefResponseFromJson(json);
}
