// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/commune_response.dart';
import '../models/wilaya_response.dart';

part 'reference_client.g.dart';

@RestApi()
abstract class ReferenceClient {
  factory ReferenceClient(Dio dio, {String? baseUrl}) = _ReferenceClient;

  /// Liste des wilayas (code, nom français, nom arabe).
  @GET('/api/v1/reference/wilayas')
  Future<List<WilayaResponse>> referenceWilayas();

  /// Communes d'une wilaya (404 si le code est inconnu).
  @GET('/api/v1/reference/wilayas/{code}/communes')
  Future<List<CommuneResponse>> referenceCommunes({
    @Path('code') required String code,
  });
}
