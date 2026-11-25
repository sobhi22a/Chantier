// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_member_data.freezed.dart';
part 'sync_member_data.g.dart';

/// Ligne `member` de la synchronisation : une affectation (nom et rôle, jamais de téléphone, H-17).
@Freezed()
abstract class SyncMemberData with _$SyncMemberData {
  const factory SyncMemberData({
    /// Identifiant de l'affectation (celui des pierres tombales `member`).
    required String id,
    required String siteId,
    required String userId,
    required String fullName,
    required String role,
    required DateTime assignedAt,
  }) = _SyncMemberData;

  factory SyncMemberData.fromJson(Map<String, Object?> json) =>
      _$SyncMemberDataFromJson(json);
}
