// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_site_request.dart';
import '../models/paged_result_of_site_response.dart';
import '../models/site_code_suggestion.dart';
import '../models/site_response.dart';
import '../models/site_type.dart';
import '../models/update_site_request.dart';

part 'sites_client.g.dart';

@RestApi()
abstract class SitesClient {
  factory SitesClient(Dio dio, {String? baseUrl}) = _SitesClient;

  /// Mes chantiers (l'Admin voit tous les chantiers).
  ///
  /// Les chantiers archivés ne sont listés qu'avec `includeArchived=true`. `sort` : `name`, `-name`, `code`, `-code`, `createdAt`, `-createdAt`.
  ///
  /// [q] - Recherche dans le code et les noms.
  ///
  /// [type] - Type d'ouvrage.
  ///
  /// [wilaya] - Nom de la wilaya.
  ///
  /// [includeArchived] - Inclure les chantiers archivés.
  ///
  /// [sort] - Tri : `name` (défaut), `-name`, `code`, `-code`, `createdAt`, `-createdAt`.
  ///
  /// [page] - Numéro de page, à partir de 1.
  ///
  /// [pageSize] - Taille de page (1 à 200).
  @GET('/api/v1/sites')
  Future<PagedResultOfSiteResponse> sitesList({
    @Query('includeArchived') bool? includeArchived = false,
    @Query('page') int? page = 1,
    @Query('pageSize') int? pageSize = 50,
    @Query('q') String? q,
    @Query('type') SiteType? type,
    @Query('wilaya') String? wilaya,
    @Query('sort') String? sort,
  });

  /// Créer un chantier (Admin).
  @POST('/api/v1/sites')
  Future<SiteResponse> sitesCreate({@Body() required CreateSiteRequest body});

  /// Proposer un code de chantier libre (modifiable avant la création).
  ///
  /// [type] - Type d'ouvrage.
  ///
  /// [name] - Nom du chantier, dont on tire le code.
  @GET('/api/v1/sites/code-suggestion')
  Future<SiteCodeSuggestion> sitesSuggestCode({
    @Query('type') SiteType? type,
    @Query('name') String? name,
  });

  /// Fiche d'un chantier.
  @GET('/api/v1/sites/{siteId}')
  Future<SiteResponse> sitesGet({@Path('siteId') required String siteId});

  /// Modifier un chantier (Admin). Le code est immuable ; `version` détecte une modification concurrente.
  @PUT('/api/v1/sites/{siteId}')
  Future<SiteResponse> sitesUpdate({
    @Path('siteId') required String siteId,
    @Body() required UpdateSiteRequest body,
  });

  /// Archiver un chantier : lecture seule, restaurable, jamais supprimé.
  @POST('/api/v1/sites/{siteId}/archive')
  Future<SiteResponse> sitesArchive({@Path('siteId') required String siteId});

  /// Restaurer un chantier archivé.
  @POST('/api/v1/sites/{siteId}/restore')
  Future<SiteResponse> sitesRestore({@Path('siteId') required String siteId});
}
