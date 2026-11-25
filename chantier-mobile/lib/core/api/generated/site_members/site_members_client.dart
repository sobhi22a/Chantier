// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/items_response_of_site_member_response.dart';
import '../models/site_member_response.dart';

part 'site_members_client.g.dart';

@RestApi()
abstract class SiteMembersClient {
  factory SiteMembersClient(Dio dio, {String? baseUrl}) = _SiteMembersClient;

  /// Personnes affectées au chantier (nom et rôle).
  @GET('/api/v1/sites/{siteId}/members')
  Future<ItemsResponseOfSiteMemberResponse> siteMembersList({
    @Path('siteId') required String siteId,
  });

  /// Retirer une personne : l'accès est coupé tout de suite. Idempotent.
  @DELETE('/api/v1/sites/{siteId}/members/{userId}')
  Future<void> siteMembersRemove({
    @Path('siteId') required String siteId,
    @Path('userId') required String userId,
  });

  /// Affecter une personne : immédiat. 201 si créée, 200 si elle était déjà affectée.
  @PUT('/api/v1/sites/{siteId}/members/{userId}')
  Future<SiteMemberResponse> siteMembersAssign({
    @Path('siteId') required String siteId,
    @Path('userId') required String userId,
  });
}
