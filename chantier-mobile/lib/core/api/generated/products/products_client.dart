// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_product_request.dart';
import '../models/paged_result_of_product_response.dart';
import '../models/product_category.dart';
import '../models/product_response.dart';
import '../models/update_product_request.dart';

part 'products_client.g.dart';

@RestApi()
abstract class ProductsClient {
  factory ProductsClient(Dio dio, {String? baseUrl}) = _ProductsClient;

  /// Produits du catalogue, avec recherche insensible aux accents et pagination avec total.
  ///
  /// [q] - Recherche dans le nom (français ou arabe).
  ///
  /// [category] - Limiter à une catégorie.
  ///
  /// [isActive] - Limiter aux produits actifs (`true`) ou désactivés (`false`).
  ///
  /// [sort] - `name` (défaut), `-name`, `category`, `-category`, `createdAt`, `-createdAt`.
  ///
  /// [page] - Numéro de page, à partir de 1.
  ///
  /// [pageSize] - Taille de page (1 à 200).
  @GET('/api/v1/products')
  Future<PagedResultOfProductResponse> productsList({
    @Query('page') int? page = 1,
    @Query('pageSize') int? pageSize = 50,
    @Query('q') String? q,
    @Query('category') ProductCategory? category,
    @Query('isActive') bool? isActive,
    @Query('sort') String? sort,
  });

  /// Créer un produit (Achats, Admin). 422 `PRODUIT_EXISTANT`, `MASSE_SAC_OBLIGATOIRE`, `UNITE_NON_AUTORISEE`.
  @POST('/api/v1/products')
  Future<ProductResponse> productsCreate({
    @Body() required CreateProductRequest body,
  });

  /// Un produit du catalogue.
  @GET('/api/v1/products/{productId}')
  Future<ProductResponse> productsGet({
    @Path('productId') required String productId,
  });

  /// Modifier un produit (Achats, Admin). `version` détecte une modification concurrente (409 `CONFLIT_VERSION`).
  @PUT('/api/v1/products/{productId}')
  Future<ProductResponse> productsUpdate({
    @Path('productId') required String productId,
    @Body() required UpdateProductRequest body,
  });

  /// Réactiver un produit désactivé. Idempotent.
  @POST('/api/v1/products/{productId}/activate')
  Future<ProductResponse> productsActivate({
    @Path('productId') required String productId,
  });

  /// Désactiver un produit : il reste dans l'historique mais ne peut plus être demandé ni livré. Idempotent.
  @POST('/api/v1/products/{productId}/deactivate')
  Future<ProductResponse> productsDeactivate({
    @Path('productId') required String productId,
  });
}
