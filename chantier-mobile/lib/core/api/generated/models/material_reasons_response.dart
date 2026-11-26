// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'material_reasons_response.freezed.dart';
part 'material_reasons_response.g.dart';

/// Listes de motifs par cas (listes ouvertes : un client affiche tel quel un code qu'il ne connaît pas).
@Freezed()
abstract class MaterialReasonsResponse with _$MaterialReasonsResponse {
  const factory MaterialReasonsResponse({
    required List<String> rejection,
    required List<String> requestCancellation,
    required List<String> orderCancellation,
    required List<String> settle,
    required List<String> deliveryCancellation,
    required List<String> reserve,
  }) = _MaterialReasonsResponse;

  factory MaterialReasonsResponse.fromJson(Map<String, Object?> json) =>
      _$MaterialReasonsResponseFromJson(json);
}
