// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

/// Type d'ouvrage. Stocke et expose sous forme de chaine (jamais d'entier, contrat d'API).
@JsonEnum()
enum SiteType {
  @JsonValue('School')
  school('School'),
  @JsonValue('Housing')
  housing('Housing'),
  @JsonValue('PublicFacility')
  publicFacility('PublicFacility'),
  @JsonValue('Other')
  other('Other'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const SiteType(this.json);

  factory SiteType.fromJson(String json) =>
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
  static List<SiteType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
