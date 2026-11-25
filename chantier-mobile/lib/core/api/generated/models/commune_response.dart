// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'commune_response.freezed.dart';
part 'commune_response.g.dart';

@Freezed()
abstract class CommuneResponse with _$CommuneResponse {
  const factory CommuneResponse({
    required String nameFr,
    required String nameAr,
  }) = _CommuneResponse;

  factory CommuneResponse.fromJson(Map<String, Object?> json) =>
      _$CommuneResponseFromJson(json);
}
