// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'changes.freezed.dart';
part 'changes.g.dart';

@Freezed()
abstract class Changes with _$Changes {
  const factory Changes({
    required String field,
    required String? old,

    /// The name has been replaced because it contains a keyword. Original name: `new`.
    /// The name has been replaced because it contains a keyword. Original name: `new`.
    /// The name has been replaced because it contains a keyword. Original name: `new`.
    @JsonKey(name: 'new') required String? newValue,
  }) = _Changes;

  factory Changes.fromJson(Map<String, Object?> json) =>
      _$ChangesFromJson(json);
}
