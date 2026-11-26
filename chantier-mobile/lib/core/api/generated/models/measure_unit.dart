// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

/// Unites du referentiel (skill `metier-chantier`), identifiees par leur <b>code stable</b> dans le JSON, la base et les vecteurs de calcul :.
/// `u ml m2 m3 kg t sac l h j pj ft`. Une quantite n'existe jamais sans unite (regle 1).
@JsonEnum()
enum MeasureUnit {
  @JsonValue('u')
  u('u'),
  @JsonValue('ml')
  ml('ml'),
  @JsonValue('m2')
  m2('m2'),
  @JsonValue('m3')
  m3('m3'),
  @JsonValue('kg')
  kg('kg'),
  @JsonValue('t')
  t('t'),
  @JsonValue('sac')
  sac('sac'),
  @JsonValue('l')
  l('l'),
  @JsonValue('h')
  h('h'),
  @JsonValue('j')
  j('j'),
  @JsonValue('pj')
  pj('pj'),
  @JsonValue('ft')
  ft('ft'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const MeasureUnit(this.json);

  factory MeasureUnit.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError(
        'Cannot convert enum value with null JSON representation to String. '
        'This usually happens for \$unknown or @JsonValue(null) entries.',
      );
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<MeasureUnit> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
