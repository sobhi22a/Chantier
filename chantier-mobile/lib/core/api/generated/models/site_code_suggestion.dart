// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'site_code_suggestion.freezed.dart';
part 'site_code_suggestion.g.dart';

@Freezed()
abstract class SiteCodeSuggestion with _$SiteCodeSuggestion {
  const factory SiteCodeSuggestion({required String code}) =
      _SiteCodeSuggestion;

  factory SiteCodeSuggestion.fromJson(Map<String, Object?> json) =>
      _$SiteCodeSuggestionFromJson(json);
}
