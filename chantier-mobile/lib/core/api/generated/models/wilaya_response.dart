// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'wilaya_response.freezed.dart';
part 'wilaya_response.g.dart';

@Freezed()
abstract class WilayaResponse with _$WilayaResponse {
  const factory WilayaResponse({
    required String code,
    required String nameFr,
    required String nameAr,
  }) = _WilayaResponse;

  factory WilayaResponse.fromJson(Map<String, Object?> json) =>
      _$WilayaResponseFromJson(json);
}
