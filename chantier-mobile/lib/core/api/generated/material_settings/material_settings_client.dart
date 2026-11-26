// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/material_settings_response.dart';

part 'material_settings_client.g.dart';

@RestApi()
abstract class MaterialSettingsClient {
  factory MaterialSettingsClient(Dio dio, {String? baseUrl}) =
      _MaterialSettingsClient;

  /// Réglages et listes de motifs. Réservé aux utilisateurs connectés ; aucune donnée personnelle ni prix.
  @GET('/api/v1/settings/materials')
  Future<MaterialSettingsResponse> materialSettingsGet();
}
