// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reserve_response.freezed.dart';
part 'reserve_response.g.dart';

/// Reserve a la reception : un motif de la liste (`QuantityMissing`, `DamagedProduct`...) et une remarque.
@Freezed()
abstract class ReserveResponse with _$ReserveResponse {
  const factory ReserveResponse({required String code, required String? note}) =
      _ReserveResponse;

  factory ReserveResponse.fromJson(Map<String, Object?> json) =>
      _$ReserveResponseFromJson(json);
}
