// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/follow_up_response.dart';

part 'follow_up_client.g.dart';

@RestApi()
abstract class FollowUpClient {
  factory FollowUpClient(Dio dio, {String? baseUrl}) = _FollowUpClient;

  /// Compteurs (à valider, à commander, attendues, en retard, à réceptionner), totaux « à commander » (400 sacs = 20 T ; 24 m³ et 10 T de sable restent deux lignes) et, avec.
  /// le droit `Prices.View` seulement, les montants du chantier en DZD hors taxes (`commercial`). Les listes détaillées sont celles des demandes (`view`).
  @GET('/api/v1/sites/{siteId}/follow-up')
  Future<FollowUpResponse> followUpGet({
    @Path('siteId') required String siteId,
  });
}
