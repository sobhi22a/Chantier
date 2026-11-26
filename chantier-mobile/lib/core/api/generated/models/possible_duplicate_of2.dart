// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'possible_duplicate_of2.freezed.dart';
part 'possible_duplicate_of2.g.dart';

@Freezed()
abstract class PossibleDuplicateOf2 with _$PossibleDuplicateOf2 {
  const factory PossibleDuplicateOf2({
    required String id,
    required String number,
  }) = _PossibleDuplicateOf2;

  factory PossibleDuplicateOf2.fromJson(Map<String, Object?> json) =>
      _$PossibleDuplicateOf2FromJson(json);
}
