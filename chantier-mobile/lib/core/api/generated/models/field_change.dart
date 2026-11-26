// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'field_change.freezed.dart';
part 'field_change.g.dart';

/// Un champ modifie, tel qu'il apparait dans l'historique : « quantity : 300 sac -&gt; 200 sac ». Jamais un prix (ADR 0012).
@Freezed()
abstract class FieldChange with _$FieldChange {
  const factory FieldChange({
    required String field,
    required String? old,

    /// The name has been replaced because it contains a keyword. Original name: `new`.
    /// The name has been replaced because it contains a keyword. Original name: `new`.
    /// The name has been replaced because it contains a keyword. Original name: `new`.
    @JsonKey(name: 'new') required String? newValue,
  }) = _FieldChange;

  factory FieldChange.fromJson(Map<String, Object?> json) =>
      _$FieldChangeFromJson(json);
}
