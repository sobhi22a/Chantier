// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'changes2.freezed.dart';
part 'changes2.g.dart';

@Freezed()
abstract class Changes2 with _$Changes2 {
  const factory Changes2({
    required String field,
    required String? old,

    /// The name has been replaced because it contains a keyword. Original name: `new`.
    /// The name has been replaced because it contains a keyword. Original name: `new`.
    /// The name has been replaced because it contains a keyword. Original name: `new`.
    @JsonKey(name: 'new') required String? newValue,
  }) = _Changes2;

  factory Changes2.fromJson(Map<String, Object?> json) =>
      _$Changes2FromJson(json);
}
