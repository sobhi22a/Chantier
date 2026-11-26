// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attach_body.freezed.dart';
part 'attach_body.g.dart';

/// Rattachement d'une livraison à une demande du même chantier et du même produit.
@Freezed()
abstract class AttachBody with _$AttachBody {
  const factory AttachBody({required String requestId}) = _AttachBody;

  factory AttachBody.fromJson(Map<String, Object?> json) =>
      _$AttachBodyFromJson(json);
}
