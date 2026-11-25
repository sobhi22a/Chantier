// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'sync_push_operation.dart';

part 'sync_push_request.freezed.dart';
part 'sync_push_request.g.dart';

/// Lot d'opérations envoyé par le téléphone (100 au maximum, 1 Mo au maximum).
@Freezed()
abstract class SyncPushRequest with _$SyncPushRequest {
  const factory SyncPushRequest({
    /// Opérations dans l'ordre de saisie ; les résultats reviennent dans le même ordre.
    required List<SyncPushOperation> operations,
  }) = _SyncPushRequest;

  factory SyncPushRequest.fromJson(Map<String, Object?> json) =>
      _$SyncPushRequestFromJson(json);
}
