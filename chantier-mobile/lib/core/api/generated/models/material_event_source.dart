// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

/// Origine d'un evenement : API directe, push de synchronisation, ou systeme (recalcul).
@JsonEnum()
enum MaterialEventSource {
  @JsonValue('Api')
  api('Api'),

  /// The name has been replaced because it contains a keyword. Original name: `Sync`.
  @JsonValue('Sync')
  valueSync('Sync'),
  @JsonValue('System')
  system('System'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const MaterialEventSource(this.json);

  factory MaterialEventSource.fromJson(String json) =>
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
  static List<MaterialEventSource> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
