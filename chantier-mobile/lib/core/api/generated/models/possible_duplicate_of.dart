// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'possible_duplicate_of.freezed.dart';
part 'possible_duplicate_of.g.dart';

@Freezed()
abstract class PossibleDuplicateOf with _$PossibleDuplicateOf {
  const factory PossibleDuplicateOf({
    required String id,
    required String number,
  }) = _PossibleDuplicateOf;

  factory PossibleDuplicateOf.fromJson(Map<String, Object?> json) =>
      _$PossibleDuplicateOfFromJson(json);
}
