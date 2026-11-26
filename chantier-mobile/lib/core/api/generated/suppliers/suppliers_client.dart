// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_supplier_request.dart';
import '../models/paged_result_of_supplier_response.dart';
import '../models/supplier_response.dart';
import '../models/update_supplier_request.dart';

part 'suppliers_client.g.dart';

@RestApi()
abstract class SuppliersClient {
  factory SuppliersClient(Dio dio, {String? baseUrl}) = _SuppliersClient;

  /// Fournisseurs, avec recherche insensible aux accents et pagination avec total.
  ///
  /// [q] - Recherche dans le nom.
  ///
  /// [isActive] - Limiter aux fournisseurs actifs (`true`) ou désactivés (`false`).
  ///
  /// [sort] - `name` (défaut), `-name`, `createdAt`, `-createdAt`.
  ///
  /// [page] - Numéro de page, à partir de 1.
  ///
  /// [pageSize] - Taille de page (1 à 200).
  @GET('/api/v1/suppliers')
  Future<PagedResultOfSupplierResponse> suppliersList({
    @Query('page') int? page = 1,
    @Query('pageSize') int? pageSize = 50,
    @Query('q') String? q,
    @Query('isActive') bool? isActive,
    @Query('sort') String? sort,
  });

  /// Créer un fournisseur (Achats, Admin). 422 `FOURNISSEUR_EXISTANT`.
  @POST('/api/v1/suppliers')
  Future<SupplierResponse> suppliersCreate({
    @Body() required CreateSupplierRequest body,
  });

  /// Un fournisseur (c'est ici qu'un téléphone est lu, en ligne seulement).
  @GET('/api/v1/suppliers/{supplierId}')
  Future<SupplierResponse> suppliersGet({
    @Path('supplierId') required String supplierId,
  });

  /// Modifier un fournisseur (Achats, Admin). `version` détecte une modification concurrente (409 `CONFLIT_VERSION`).
  @PUT('/api/v1/suppliers/{supplierId}')
  Future<SupplierResponse> suppliersUpdate({
    @Path('supplierId') required String supplierId,
    @Body() required UpdateSupplierRequest body,
  });

  /// Réactiver un fournisseur désactivé. Idempotent.
  @POST('/api/v1/suppliers/{supplierId}/activate')
  Future<SupplierResponse> suppliersActivate({
    @Path('supplierId') required String supplierId,
  });

  /// Désactiver un fournisseur : il reste dans l'historique mais ne peut plus recevoir de commande. Idempotent.
  @POST('/api/v1/suppliers/{supplierId}/deactivate')
  Future<SupplierResponse> suppliersDeactivate({
    @Path('supplierId') required String supplierId,
  });
}
