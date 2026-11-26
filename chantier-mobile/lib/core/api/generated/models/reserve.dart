// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reserve.freezed.dart';
part 'reserve.g.dart';

@Freezed()
abstract class Reserve with _$Reserve {
  const factory Reserve({required String code, required String? note}) =
      _Reserve;

  factory Reserve.fromJson(Map<String, Object?> json) =>
      _$ReserveFromJson(json);
}
