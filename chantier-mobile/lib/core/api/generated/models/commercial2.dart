// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'commercial2.freezed.dart';
part 'commercial2.g.dart';

@Freezed()
abstract class Commercial2 with _$Commercial2 {
  const factory Commercial2({
    required double? unitPrice,
    required double? amount,
    required double? receivedValue,
    required String? purchaseOrderNumber,
  }) = _Commercial2;

  factory Commercial2.fromJson(Map<String, Object?> json) =>
      _$Commercial2FromJson(json);
}
