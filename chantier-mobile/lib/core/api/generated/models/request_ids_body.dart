// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_ids_body.freezed.dart';
part 'request_ids_body.g.dart';

/// Lot de demandes : 50 au plus pour valider, 100 au plus pour archiver.
@Freezed()
abstract class RequestIdsBody with _$RequestIdsBody {
  const factory RequestIdsBody({required List<String> requestIds}) =
      _RequestIdsBody;

  factory RequestIdsBody.fromJson(Map<String, Object?> json) =>
      _$RequestIdsBodyFromJson(json);
}
