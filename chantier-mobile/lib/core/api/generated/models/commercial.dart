// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'commercial.freezed.dart';
part 'commercial.g.dart';

@Freezed()
abstract class Commercial with _$Commercial {
  const factory Commercial({required double amount}) = _Commercial;

  factory Commercial.fromJson(Map<String, Object?> json) =>
      _$CommercialFromJson(json);
}
