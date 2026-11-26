import { ApplicationApiService as api } from "../lib/ApplicationApi.service";
const injectedRtkApi = api.injectEndpoints({
  endpoints: (build) => ({
    authChangePassword: build.mutation<
      AuthChangePasswordApiResponse,
      AuthChangePasswordApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/auth/change-password`,
        method: "POST",
        body: queryArg.changePasswordRequest,
      }),
    }),
    authLogin: build.mutation<AuthLoginApiResponse, AuthLoginApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/auth/login`,
        method: "POST",
        body: queryArg.loginRequest,
      }),
    }),
    authLogout: build.mutation<AuthLogoutApiResponse, AuthLogoutApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/auth/logout`,
        method: "POST",
        body: queryArg.logoutRequest,
      }),
    }),
    authMe: build.query<AuthMeApiResponse, AuthMeApiArg>({
      query: () => ({ url: `/api/v1/auth/me` }),
    }),
    authUpdateLanguage: build.mutation<
      AuthUpdateLanguageApiResponse,
      AuthUpdateLanguageApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/auth/me/language`,
        method: "PUT",
        body: queryArg.updateLanguageRequest,
      }),
    }),
    authRefresh: build.mutation<AuthRefreshApiResponse, AuthRefreshApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/auth/refresh`,
        method: "POST",
        body: queryArg.refreshRequest,
      }),
    }),
    productsList: build.query<ProductsListApiResponse, ProductsListApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/products`,
        params: {
          q: queryArg.q,
          category: queryArg.category,
          isActive: queryArg.isActive,
          sort: queryArg.sort,
          page: queryArg.page,
          pageSize: queryArg.pageSize,
        },
      }),
    }),
    productsCreate: build.mutation<
      ProductsCreateApiResponse,
      ProductsCreateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/products`,
        method: "POST",
        body: queryArg.createProductRequest,
      }),
    }),
    productsGet: build.query<ProductsGetApiResponse, ProductsGetApiArg>({
      query: (queryArg) => ({ url: `/api/v1/products/${queryArg.productId}` }),
    }),
    productsUpdate: build.mutation<
      ProductsUpdateApiResponse,
      ProductsUpdateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/products/${queryArg.productId}`,
        method: "PUT",
        body: queryArg.updateProductRequest,
      }),
    }),
    productsActivate: build.mutation<
      ProductsActivateApiResponse,
      ProductsActivateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/products/${queryArg.productId}/activate`,
        method: "POST",
      }),
    }),
    productsDeactivate: build.mutation<
      ProductsDeactivateApiResponse,
      ProductsDeactivateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/products/${queryArg.productId}/deactivate`,
        method: "POST",
      }),
    }),
    referenceWilayas: build.query<
      ReferenceWilayasApiResponse,
      ReferenceWilayasApiArg
    >({
      query: () => ({ url: `/api/v1/reference/wilayas` }),
    }),
    referenceCommunes: build.query<
      ReferenceCommunesApiResponse,
      ReferenceCommunesApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/reference/wilayas/${queryArg.code}/communes`,
      }),
    }),
    crossSiteRequestsList: build.query<
      CrossSiteRequestsListApiResponse,
      CrossSiteRequestsListApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/requests`,
        params: {
          siteId: queryArg.siteId,
          view: queryArg.view,
          mine: queryArg.mine,
          status: queryArg.status,
          priority: queryArg.priority,
          zoneId: queryArg.zoneId,
          productId: queryArg.productId,
          supplierId: queryArg.supplierId,
          from: queryArg["from"],
          to: queryArg.to,
          q: queryArg.q,
          sort: queryArg.sort,
          page: queryArg.page,
          pageSize: queryArg.pageSize,
        },
      }),
    }),
    materialSettingsGet: build.query<
      MaterialSettingsGetApiResponse,
      MaterialSettingsGetApiArg
    >({
      query: () => ({ url: `/api/v1/settings/materials` }),
    }),
    sitesList: build.query<SitesListApiResponse, SitesListApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites`,
        params: {
          q: queryArg.q,
          type: queryArg["type"],
          wilaya: queryArg.wilaya,
          includeArchived: queryArg.includeArchived,
          sort: queryArg.sort,
          page: queryArg.page,
          pageSize: queryArg.pageSize,
        },
      }),
    }),
    sitesCreate: build.mutation<SitesCreateApiResponse, SitesCreateApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites`,
        method: "POST",
        body: queryArg.createSiteRequest,
      }),
    }),
    sitesSuggestCode: build.query<
      SitesSuggestCodeApiResponse,
      SitesSuggestCodeApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/code-suggestion`,
        params: {
          type: queryArg["type"],
          name: queryArg.name,
        },
      }),
    }),
    sitesGet: build.query<SitesGetApiResponse, SitesGetApiArg>({
      query: (queryArg) => ({ url: `/api/v1/sites/${queryArg.siteId}` }),
    }),
    sitesUpdate: build.mutation<SitesUpdateApiResponse, SitesUpdateApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}`,
        method: "PUT",
        body: queryArg.updateSiteRequest,
      }),
    }),
    sitesArchive: build.mutation<SitesArchiveApiResponse, SitesArchiveApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/archive`,
        method: "POST",
      }),
    }),
    deliveriesList: build.query<
      DeliveriesListApiResponse,
      DeliveriesListApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/deliveries`,
        params: {
          requestId: queryArg.requestId,
          unattached: queryArg.unattached,
          withReserve: queryArg.withReserve,
          missingNote: queryArg.missingNote,
          status: queryArg.status,
          supplierId: queryArg.supplierId,
          productId: queryArg.productId,
          q: queryArg.q,
          from: queryArg["from"],
          to: queryArg.to,
          sort: queryArg.sort,
          page: queryArg.page,
          pageSize: queryArg.pageSize,
        },
      }),
    }),
    deliveriesCreate: build.mutation<
      DeliveriesCreateApiResponse,
      DeliveriesCreateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/deliveries`,
        method: "POST",
        body: queryArg.createDeliveryRequest,
      }),
    }),
    deliveriesGet: build.query<DeliveriesGetApiResponse, DeliveriesGetApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/deliveries/${queryArg.deliveryId}`,
      }),
    }),
    deliveriesUpdate: build.mutation<
      DeliveriesUpdateApiResponse,
      DeliveriesUpdateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/deliveries/${queryArg.deliveryId}`,
        method: "PUT",
        body: queryArg.updateDeliveryRequest,
      }),
    }),
    deliveriesAttach: build.mutation<
      DeliveriesAttachApiResponse,
      DeliveriesAttachApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/deliveries/${queryArg.deliveryId}/attach`,
        method: "POST",
        body: queryArg.attachBody,
      }),
    }),
    deliveriesCancel: build.mutation<
      DeliveriesCancelApiResponse,
      DeliveriesCancelApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/deliveries/${queryArg.deliveryId}/cancel`,
        method: "POST",
        body: queryArg.reasonBody,
      }),
    }),
    photosCreate: build.mutation<PhotosCreateApiResponse, PhotosCreateApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/deliveries/${queryArg.deliveryId}/photos`,
        method: "POST",
        body: queryArg.createPhotoRequest,
      }),
    }),
    followUpGet: build.query<FollowUpGetApiResponse, FollowUpGetApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/follow-up`,
      }),
    }),
    siteMembersList: build.query<
      SiteMembersListApiResponse,
      SiteMembersListApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/members`,
      }),
    }),
    siteMembersRemove: build.mutation<
      SiteMembersRemoveApiResponse,
      SiteMembersRemoveApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/members/${queryArg.userId}`,
        method: "DELETE",
      }),
    }),
    siteMembersAssign: build.mutation<
      SiteMembersAssignApiResponse,
      SiteMembersAssignApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/members/${queryArg.userId}`,
        method: "PUT",
      }),
    }),
    photosDownload: build.query<
      PhotosDownloadApiResponse,
      PhotosDownloadApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/photos/${queryArg.photoId}/content`,
      }),
    }),
    photosUpload: build.mutation<PhotosUploadApiResponse, PhotosUploadApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/photos/${queryArg.photoId}/content`,
        method: "PUT",
        body: queryArg.body,
      }),
    }),
    requestsList: build.query<RequestsListApiResponse, RequestsListApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests`,
        params: {
          view: queryArg.view,
          mine: queryArg.mine,
          status: queryArg.status,
          priority: queryArg.priority,
          zoneId: queryArg.zoneId,
          productId: queryArg.productId,
          supplierId: queryArg.supplierId,
          from: queryArg["from"],
          to: queryArg.to,
          q: queryArg.q,
          sort: queryArg.sort,
          page: queryArg.page,
          pageSize: queryArg.pageSize,
        },
      }),
    }),
    requestsCreate: build.mutation<
      RequestsCreateApiResponse,
      RequestsCreateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests`,
        method: "POST",
        body: queryArg.createRequestRequest,
      }),
    }),
    requestsApproveBatch: build.mutation<
      RequestsApproveBatchApiResponse,
      RequestsApproveBatchApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/batch/approve`,
        method: "POST",
        body: queryArg.requestIdsBody,
      }),
    }),
    requestsArchiveBatch: build.mutation<
      RequestsArchiveBatchApiResponse,
      RequestsArchiveBatchApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/batch/archive`,
        method: "POST",
        body: queryArg.requestIdsBody,
      }),
    }),
    requestsGet: build.query<RequestsGetApiResponse, RequestsGetApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}`,
      }),
    }),
    requestsUpdate: build.mutation<
      RequestsUpdateApiResponse,
      RequestsUpdateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}`,
        method: "PUT",
        body: queryArg.updateRequestRequest,
      }),
    }),
    requestsApprove: build.mutation<
      RequestsApproveApiResponse,
      RequestsApproveApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/approve`,
        method: "POST",
        body: queryArg.approveBody,
      }),
    }),
    requestsArchive: build.mutation<
      RequestsArchiveApiResponse,
      RequestsArchiveApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/archive`,
        method: "POST",
      }),
    }),
    requestsCancel: build.mutation<
      RequestsCancelApiResponse,
      RequestsCancelApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/cancel`,
        method: "POST",
        body: queryArg.reasonBody,
      }),
    }),
    requestsLinkProduct: build.mutation<
      RequestsLinkProductApiResponse,
      RequestsLinkProductApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/link-product`,
        method: "POST",
        body: queryArg.linkProductBody,
      }),
    }),
    ordersCreate: build.mutation<OrdersCreateApiResponse, OrdersCreateApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/order`,
        method: "POST",
        body: queryArg.createOrderRequest,
      }),
    }),
    ordersUpdate: build.mutation<OrdersUpdateApiResponse, OrdersUpdateApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/order`,
        method: "PUT",
        body: queryArg.updateOrderRequest,
      }),
    }),
    ordersCancel: build.mutation<OrdersCancelApiResponse, OrdersCancelApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/order/cancel`,
        method: "POST",
        body: queryArg.reasonBody,
      }),
    }),
    requestsReceive: build.mutation<
      RequestsReceiveApiResponse,
      RequestsReceiveApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/receive`,
        method: "POST",
        body: queryArg.receiveBody,
      }),
    }),
    requestsReject: build.mutation<
      RequestsRejectApiResponse,
      RequestsRejectApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/reject`,
        method: "POST",
        body: queryArg.reasonBody,
      }),
    }),
    requestsRestore: build.mutation<
      RequestsRestoreApiResponse,
      RequestsRestoreApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/restore`,
        method: "POST",
      }),
    }),
    requestsSettle: build.mutation<
      RequestsSettleApiResponse,
      RequestsSettleApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/requests/${queryArg.requestId}/settle`,
        method: "POST",
        body: queryArg.reasonBody,
      }),
    }),
    sitesRestore: build.mutation<SitesRestoreApiResponse, SitesRestoreApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/restore`,
        method: "POST",
      }),
    }),
    zonesList: build.query<ZonesListApiResponse, ZonesListApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/zones`,
        params: {
          block: queryArg.block,
          q: queryArg.q,
          includeArchived: queryArg.includeArchived,
          pageSize: queryArg.pageSize,
          cursor: queryArg.cursor,
        },
      }),
    }),
    zonesCreate: build.mutation<ZonesCreateApiResponse, ZonesCreateApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/zones`,
        method: "POST",
        body: queryArg.createZoneRequest,
      }),
    }),
    zonesGet: build.query<ZonesGetApiResponse, ZonesGetApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/zones/${queryArg.zoneId}`,
      }),
    }),
    zonesUpdate: build.mutation<ZonesUpdateApiResponse, ZonesUpdateApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/zones/${queryArg.zoneId}`,
        method: "PUT",
        body: queryArg.updateZoneRequest,
      }),
    }),
    zonesArchive: build.mutation<ZonesArchiveApiResponse, ZonesArchiveApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/zones/${queryArg.zoneId}/archive`,
        method: "POST",
      }),
    }),
    zonesRestore: build.mutation<ZonesRestoreApiResponse, ZonesRestoreApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sites/${queryArg.siteId}/zones/${queryArg.zoneId}/restore`,
        method: "POST",
      }),
    }),
    suppliersList: build.query<SuppliersListApiResponse, SuppliersListApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/suppliers`,
        params: {
          q: queryArg.q,
          isActive: queryArg.isActive,
          sort: queryArg.sort,
          page: queryArg.page,
          pageSize: queryArg.pageSize,
        },
      }),
    }),
    suppliersCreate: build.mutation<
      SuppliersCreateApiResponse,
      SuppliersCreateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/suppliers`,
        method: "POST",
        body: queryArg.createSupplierRequest,
      }),
    }),
    suppliersGet: build.query<SuppliersGetApiResponse, SuppliersGetApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/suppliers/${queryArg.supplierId}`,
      }),
    }),
    suppliersUpdate: build.mutation<
      SuppliersUpdateApiResponse,
      SuppliersUpdateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/suppliers/${queryArg.supplierId}`,
        method: "PUT",
        body: queryArg.updateSupplierRequest,
      }),
    }),
    suppliersActivate: build.mutation<
      SuppliersActivateApiResponse,
      SuppliersActivateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/suppliers/${queryArg.supplierId}/activate`,
        method: "POST",
      }),
    }),
    suppliersDeactivate: build.mutation<
      SuppliersDeactivateApiResponse,
      SuppliersDeactivateApiArg
    >({
      query: (queryArg) => ({
        url: `/api/v1/suppliers/${queryArg.supplierId}/deactivate`,
        method: "POST",
      }),
    }),
    syncChanges: build.query<SyncChangesApiResponse, SyncChangesApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sync/changes`,
        params: {
          since: queryArg.since,
          siteId: queryArg.siteId,
          limit: queryArg.limit,
        },
      }),
    }),
    syncPush: build.mutation<SyncPushApiResponse, SyncPushApiArg>({
      query: (queryArg) => ({
        url: `/api/v1/sync/push`,
        method: "POST",
        body: queryArg.syncPushRequest,
      }),
    }),
  }),
  overrideExisting: false,
});
export { injectedRtkApi as chantierApi };
export type AuthChangePasswordApiResponse = unknown;
export type AuthChangePasswordApiArg = {
  changePasswordRequest: ChangePasswordRequest;
};
export type AuthLoginApiResponse = /** status 200 OK */ AuthResult;
export type AuthLoginApiArg = {
  loginRequest: LoginRequest;
};
export type AuthLogoutApiResponse = unknown;
export type AuthLogoutApiArg = {
  logoutRequest: LogoutRequest;
};
export type AuthMeApiResponse = /** status 200 OK */ MeResponse;
export type AuthMeApiArg = void;
export type AuthUpdateLanguageApiResponse = unknown;
export type AuthUpdateLanguageApiArg = {
  updateLanguageRequest: UpdateLanguageRequest;
};
export type AuthRefreshApiResponse = /** status 200 OK */ AuthResult;
export type AuthRefreshApiArg = {
  refreshRequest: RefreshRequest;
};
export type ProductsListApiResponse =
  /** status 200 OK */ PagedResultOfProductResponse;
export type ProductsListApiArg = {
  /** Recherche dans le nom (français ou arabe). */
  q?: string;
  /** Limiter à une catégorie. */
  category?: ProductCategory;
  /** Limiter aux produits actifs (`true`) ou désactivés (`false`). */
  isActive?: boolean;
  /** `name` (défaut), `-name`, `category`, `-category`, `createdAt`, `-createdAt`. */
  sort?: string;
  /** Numéro de page, à partir de 1. */
  page?: number;
  /** Taille de page (1 à 200). */
  pageSize?: number;
};
export type ProductsCreateApiResponse =
  /** status 201 Created */ ProductResponse;
export type ProductsCreateApiArg = {
  createProductRequest: CreateProductRequest;
};
export type ProductsGetApiResponse = /** status 200 OK */ ProductResponse;
export type ProductsGetApiArg = {
  productId: string;
};
export type ProductsUpdateApiResponse = /** status 200 OK */ ProductResponse;
export type ProductsUpdateApiArg = {
  productId: string;
  updateProductRequest: UpdateProductRequest;
};
export type ProductsActivateApiResponse = /** status 200 OK */ ProductResponse;
export type ProductsActivateApiArg = {
  productId: string;
};
export type ProductsDeactivateApiResponse =
  /** status 200 OK */ ProductResponse;
export type ProductsDeactivateApiArg = {
  productId: string;
};
export type ReferenceWilayasApiResponse = /** status 200 OK */ WilayaResponse[];
export type ReferenceWilayasApiArg = void;
export type ReferenceCommunesApiResponse =
  /** status 200 OK */ CommuneResponse[];
export type ReferenceCommunesApiArg = {
  code: string;
};
export type CrossSiteRequestsListApiResponse =
  /** status 200 OK */ PagedResultOfMaterialRequestResponse;
export type CrossSiteRequestsListApiArg = {
  /** Limiter à un chantier (404 s'il n'est pas affecté). */
  siteId?: string;
  /** `toFollow` (défaut), `toApprove`, `toOrder`, `expected`, `late` (date de besoin ou livraison prévue dépassée), `toReceive`, `received`, `closed` ou `archived`. */
  view?: string;
  /** Seulement mes demandes. */
  mine?: boolean;
  /** Limiter à un statut. */
  status?: RequestStatus;
  /** Limiter à une urgence. */
  priority?: Priority;
  /** Limiter à une zone. */
  zoneId?: string;
  /** Limiter à un produit du catalogue. */
  productId?: string;
  /** Limiter aux demandes dont la commande active est chez ce fournisseur. */
  supplierId?: string;
  /** Date de besoin à partir de (incluse). */
  from?: null | string;
  /** Date de besoin jusqu'à (incluse). */
  to?: null | string;
  /** Recherche dans le numéro, le produit et la remarque. */
  q?: string;
  /** `neededBy`, `-neededBy`, `number`, `-number`, `createdAt`, `-createdAt`, `priority`. */
  sort?: string;
  /** Numéro de page, à partir de 1. */
  page?: number;
  /** Taille de page (1 à 200). */
  pageSize?: number;
};
export type MaterialSettingsGetApiResponse =
  /** status 200 OK */ MaterialSettingsResponse;
export type MaterialSettingsGetApiArg = void;
export type SitesListApiResponse =
  /** status 200 OK */ PagedResultOfSiteResponse;
export type SitesListApiArg = {
  /** Recherche dans le code et les noms. */
  q?: string;
  /** Type d'ouvrage. */
  type?: SiteType;
  /** Nom de la wilaya. */
  wilaya?: string;
  /** Inclure les chantiers archivés. */
  includeArchived?: boolean;
  /** Tri : `name` (défaut), `-name`, `code`, `-code`, `createdAt`, `-createdAt`. */
  sort?: string;
  /** Numéro de page, à partir de 1. */
  page?: number;
  /** Taille de page (1 à 200). */
  pageSize?: number;
};
export type SitesCreateApiResponse = /** status 201 Created */ SiteResponse;
export type SitesCreateApiArg = {
  createSiteRequest: CreateSiteRequest;
};
export type SitesSuggestCodeApiResponse =
  /** status 200 OK */ SiteCodeSuggestion;
export type SitesSuggestCodeApiArg = {
  /** Type d'ouvrage. */
  type?: SiteType;
  /** Nom du chantier, dont on tire le code. */
  name?: string;
};
export type SitesGetApiResponse = /** status 200 OK */ SiteResponse;
export type SitesGetApiArg = {
  siteId: string;
};
export type SitesUpdateApiResponse = /** status 200 OK */ SiteResponse;
export type SitesUpdateApiArg = {
  siteId: string;
  updateSiteRequest: UpdateSiteRequest;
};
export type SitesArchiveApiResponse = /** status 200 OK */ SiteResponse;
export type SitesArchiveApiArg = {
  siteId: string;
};
export type DeliveriesListApiResponse =
  /** status 200 OK */ PagedResultOfDeliveryResponse;
export type DeliveriesListApiArg = {
  siteId: string;
  /** Livraisons d'une demande. */
  requestId?: string;
  /** `true` : seulement les livraisons non rattachées (à traiter). */
  unattached?: boolean;
  /** `true` : seulement les livraisons reçues avec réserve. */
  withReserve?: boolean;
  /** `true` : seulement les livraisons sans n° de BL ni photo (« à compléter »). */
  missingNote?: boolean;
  /** `Recorded` ou `Cancelled`. */
  status?: DeliveryStatus;
  /** Limiter à un fournisseur du catalogue. */
  supplierId?: string;
  /** Limiter à un produit du catalogue. */
  productId?: string;
  /** Recherche dans le numéro (`LIV-006`), le n° de BL, le produit et le fournisseur. */
  q?: string;
  /** Date de livraison à partir de (incluse). */
  from?: null | string;
  /** Date de livraison jusqu'à (incluse). */
  to?: null | string;
  /** `deliveryDate`, `-deliveryDate`, `number`, `-number` ; par défaut les plus récentes d'abord. */
  sort?: string;
  /** Numéro de page, à partir de 1. */
  page?: number;
  /** Taille de page (1 à 200). */
  pageSize?: number;
};
export type DeliveriesCreateApiResponse =
  | /** status 200 OK */ DeliveryDetailResponse
  | /** status 201 Created */ DeliveryDetailResponse;
export type DeliveriesCreateApiArg = {
  siteId: string;
  createDeliveryRequest: CreateDeliveryRequest;
};
export type DeliveriesGetApiResponse =
  /** status 200 OK */ DeliveryDetailResponse;
export type DeliveriesGetApiArg = {
  siteId: string;
  deliveryId: string;
};
export type DeliveriesUpdateApiResponse =
  /** status 200 OK */ DeliveryDetailResponse;
export type DeliveriesUpdateApiArg = {
  siteId: string;
  deliveryId: string;
  updateDeliveryRequest: UpdateDeliveryRequest;
};
export type DeliveriesAttachApiResponse =
  /** status 200 OK */ DeliveryDetailResponse;
export type DeliveriesAttachApiArg = {
  siteId: string;
  deliveryId: string;
  attachBody: AttachBody;
};
export type DeliveriesCancelApiResponse =
  /** status 200 OK */ DeliveryDetailResponse;
export type DeliveriesCancelApiArg = {
  siteId: string;
  deliveryId: string;
  reasonBody: ReasonBody;
};
export type PhotosCreateApiResponse =
  /** status 200 OK */ PhotoResponse | /** status 201 Created */ PhotoResponse;
export type PhotosCreateApiArg = {
  siteId: string;
  deliveryId: string;
  createPhotoRequest: CreatePhotoRequest;
};
export type FollowUpGetApiResponse = /** status 200 OK */ FollowUpResponse;
export type FollowUpGetApiArg = {
  siteId: string;
};
export type SiteMembersListApiResponse =
  /** status 200 OK */ ItemsResponseOfSiteMemberResponse;
export type SiteMembersListApiArg = {
  siteId: string;
};
export type SiteMembersRemoveApiResponse = unknown;
export type SiteMembersRemoveApiArg = {
  siteId: string;
  userId: string;
};
export type SiteMembersAssignApiResponse =
  | /** status 200 OK */ SiteMemberResponse
  | /** status 201 Created */ SiteMemberResponse;
export type SiteMembersAssignApiArg = {
  siteId: string;
  userId: string;
};
export type PhotosDownloadApiResponse =
  /** status 200 Le fichier JPEG (métadonnées EXIF retirées). */ Blob;
export type PhotosDownloadApiArg = {
  siteId: string;
  photoId: string;
};
export type PhotosUploadApiResponse = /** status 200 OK */ PhotoResponse;
export type PhotosUploadApiArg = {
  siteId: string;
  photoId: string;
  /** Le fichier JPEG lui-même (5 Mo au plus) ; `Content-Type: image/jpeg`. */
  body: Blob;
};
export type RequestsListApiResponse =
  /** status 200 OK */ PagedResultOfMaterialRequestResponse;
export type RequestsListApiArg = {
  siteId: string;
  /** `toFollow` (défaut), `toApprove`, `toOrder`, `expected`, `late` (date de besoin ou livraison prévue dépassée), `toReceive`, `received`, `closed` ou `archived`. Les demandes archivées ne figurent que dans `archived`. */
  view?: string;
  /** Seulement mes demandes. */
  mine?: boolean;
  /** Limiter à un statut. */
  status?: RequestStatus;
  /** Limiter à une urgence. */
  priority?: Priority;
  /** Limiter à une zone. */
  zoneId?: string;
  /** Limiter à un produit du catalogue. */
  productId?: string;
  /** Limiter aux demandes dont la commande active est chez ce fournisseur. */
  supplierId?: string;
  /** Date de besoin à partir de (incluse). */
  from?: null | string;
  /** Date de besoin jusqu'à (incluse). */
  to?: null | string;
  /** Recherche dans le numéro (`DEM-014`), le produit et la remarque. */
  q?: string;
  /** `neededBy`, `-neededBy`, `number`, `-number`, `createdAt`, `-createdAt`, `priority` ; par défaut les plus urgentes d'abord (vue à suivre) ou par date de besoin. */
  sort?: string;
  /** Numéro de page, à partir de 1. */
  page?: number;
  /** Taille de page (1 à 200). */
  pageSize?: number;
};
export type RequestsCreateApiResponse =
  | /** status 200 OK */ MaterialRequestDetailResponse
  | /** status 201 Created */ MaterialRequestDetailResponse;
export type RequestsCreateApiArg = {
  siteId: string;
  createRequestRequest: CreateRequestRequest;
};
export type RequestsApproveBatchApiResponse =
  /** status 200 OK */ BatchResponse;
export type RequestsApproveBatchApiArg = {
  siteId: string;
  requestIdsBody: RequestIdsBody;
};
export type RequestsArchiveBatchApiResponse =
  /** status 200 OK */ BatchResponse;
export type RequestsArchiveBatchApiArg = {
  siteId: string;
  requestIdsBody: RequestIdsBody;
};
export type RequestsGetApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type RequestsGetApiArg = {
  siteId: string;
  requestId: string;
};
export type RequestsUpdateApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type RequestsUpdateApiArg = {
  siteId: string;
  requestId: string;
  updateRequestRequest: UpdateRequestRequest;
};
export type RequestsApproveApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type RequestsApproveApiArg = {
  siteId: string;
  requestId: string;
  approveBody: ApproveBody;
};
export type RequestsArchiveApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type RequestsArchiveApiArg = {
  siteId: string;
  requestId: string;
};
export type RequestsCancelApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type RequestsCancelApiArg = {
  siteId: string;
  requestId: string;
  reasonBody: ReasonBody;
};
export type RequestsLinkProductApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type RequestsLinkProductApiArg = {
  siteId: string;
  requestId: string;
  linkProductBody: LinkProductBody;
};
export type OrdersCreateApiResponse =
  | /** status 200 OK */ MaterialRequestDetailResponse
  | /** status 201 Created */ MaterialRequestDetailResponse;
export type OrdersCreateApiArg = {
  siteId: string;
  requestId: string;
  createOrderRequest: CreateOrderRequest;
};
export type OrdersUpdateApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type OrdersUpdateApiArg = {
  siteId: string;
  requestId: string;
  updateOrderRequest: UpdateOrderRequest;
};
export type OrdersCancelApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type OrdersCancelApiArg = {
  siteId: string;
  requestId: string;
  reasonBody: ReasonBody;
};
export type RequestsReceiveApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type RequestsReceiveApiArg = {
  siteId: string;
  requestId: string;
  receiveBody: ReceiveBody;
};
export type RequestsRejectApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type RequestsRejectApiArg = {
  siteId: string;
  requestId: string;
  reasonBody: ReasonBody;
};
export type RequestsRestoreApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type RequestsRestoreApiArg = {
  siteId: string;
  requestId: string;
};
export type RequestsSettleApiResponse =
  /** status 200 OK */ MaterialRequestDetailResponse;
export type RequestsSettleApiArg = {
  siteId: string;
  requestId: string;
  reasonBody: ReasonBody;
};
export type SitesRestoreApiResponse = /** status 200 OK */ SiteResponse;
export type SitesRestoreApiArg = {
  siteId: string;
};
export type ZonesListApiResponse =
  /** status 200 OK */ CursorPageOfZoneResponse;
export type ZonesListApiArg = {
  siteId: string;
  /** Limiter à un bloc. */
  block?: string;
  /** Recherche dans le bloc et le libellé. */
  q?: string;
  /** Inclure les zones archivées. */
  includeArchived?: boolean;
  /** Taille de page (1 à 200). */
  pageSize?: number;
  /** `nextCursor` de la page précédente (opaque). */
  cursor?: string;
};
export type ZonesCreateApiResponse =
  /** status 200 OK */ ZoneResponse | /** status 201 Created */ ZoneResponse;
export type ZonesCreateApiArg = {
  siteId: string;
  createZoneRequest: CreateZoneRequest;
};
export type ZonesGetApiResponse = /** status 200 OK */ ZoneResponse;
export type ZonesGetApiArg = {
  siteId: string;
  zoneId: string;
};
export type ZonesUpdateApiResponse = /** status 200 OK */ ZoneResponse;
export type ZonesUpdateApiArg = {
  siteId: string;
  zoneId: string;
  updateZoneRequest: UpdateZoneRequest;
};
export type ZonesArchiveApiResponse = /** status 200 OK */ ZoneResponse;
export type ZonesArchiveApiArg = {
  siteId: string;
  zoneId: string;
};
export type ZonesRestoreApiResponse = /** status 200 OK */ ZoneResponse;
export type ZonesRestoreApiArg = {
  siteId: string;
  zoneId: string;
};
export type SuppliersListApiResponse =
  /** status 200 OK */ PagedResultOfSupplierResponse;
export type SuppliersListApiArg = {
  /** Recherche dans le nom. */
  q?: string;
  /** Limiter aux fournisseurs actifs (`true`) ou désactivés (`false`). */
  isActive?: boolean;
  /** `name` (défaut), `-name`, `createdAt`, `-createdAt`. */
  sort?: string;
  /** Numéro de page, à partir de 1. */
  page?: number;
  /** Taille de page (1 à 200). */
  pageSize?: number;
};
export type SuppliersCreateApiResponse =
  /** status 201 Created */ SupplierResponse;
export type SuppliersCreateApiArg = {
  createSupplierRequest: CreateSupplierRequest;
};
export type SuppliersGetApiResponse = /** status 200 OK */ SupplierResponse;
export type SuppliersGetApiArg = {
  supplierId: string;
};
export type SuppliersUpdateApiResponse = /** status 200 OK */ SupplierResponse;
export type SuppliersUpdateApiArg = {
  supplierId: string;
  updateSupplierRequest: UpdateSupplierRequest;
};
export type SuppliersActivateApiResponse =
  /** status 200 OK */ SupplierResponse;
export type SuppliersActivateApiArg = {
  supplierId: string;
};
export type SuppliersDeactivateApiResponse =
  /** status 200 OK */ SupplierResponse;
export type SuppliersDeactivateApiArg = {
  supplierId: string;
};
export type SyncChangesApiResponse = /** status 200 OK */ SyncPullResponse;
export type SyncChangesApiArg = {
  /** Curseur reçu du serveur ; absent ou `0` = première synchronisation. */
  since?: string;
  /** Limiter à un chantier (404 s'il n'est pas affecté) ; absent = tous les chantiers visibles. */
  siteId?: string;
  /** Nombre de lignes par page (1 à 500, 200 par défaut). */
  limit?: number;
};
export type SyncPushApiResponse = /** status 200 OK */ SyncPushResponse;
export type SyncPushApiArg = {
  syncPushRequest: SyncPushRequest;
};
export type ProblemDetails = {
  /** URI stable du type d'erreur, dérivée de `code`. */
  type: string;
  title: string;
  /** Code HTTP. */
  status: number;
  detail?: string;
  instance?: null | string;
  /** Code métier stable (`VALIDATION`, `INTROUVABLE`, `ZONE_EXISTANTE`...). Ensemble ouvert : un client ignore un code qu'il ne connaît pas et affiche `title`. */
  code: string;
  /** Identifiant à communiquer au support. */
  traceId: string;
  /** Détail par champ (400 `VALIDATION`) : nom du champ en camelCase, puis les messages. */
  errors?: {
    [key: string]: string[];
  };
  /** 409 `CONFLIT_VERSION` : état actuel de la ressource (même JSON que sa réponse REST). */
  current?: object;
};
export type ChangePasswordRequest = {
  /** Mot de passe actuel (ou provisoire). */
  currentPassword: string;
  /** Nouveau mot de passe ; sinon 422 `MOT_DE_PASSE_FAIBLE`. */
  newPassword: string;
};
export type AuthUserResponse = {
  id: string;
  userName: string;
  fullName: string;
  role: string;
  language: string;
  mustChangePassword: boolean;
};
export type AuthResult = {
  user: AuthUserResponse;
  accessToken?: null | string;
  refreshToken?: null | string;
  expiresIn?: null | number;
};
export type LoginRequest = {
  /** Identifiant de connexion. */
  userName: string;
  /** Mot de passe. */
  password: string;
  /** `true` : jetons (mobile) ; `false` : cookie de session (web). */
  isAppMobile?: boolean;
};
export type LogoutRequest = {
  /** Jeton de rafraîchissement à révoquer (mobile). */
  refreshToken?: null | string;
};
export type MeResponse = {
  id: string;
  userName: string;
  fullName: string;
  phoneNumber: null | string;
  role: string;
  language: string;
  permissions: string[];
  permissionsVersion: string;
  mustChangePassword: boolean;
};
export type UpdateLanguageRequest = {
  /** `fr` ou `ar`. */
  language: string;
};
export type RefreshRequest = {
  /** Jeton de rafraîchissement reçu à la connexion ou au dernier renouvellement (il n'est valable qu'une fois). */
  refreshToken: string;
};
export type ProductResponse = {
  id: string;
  /** Nom en français. */
  nameFr: string;
  /** Nom en arabe, s'il existe (sinon le nom français est affiché). */
  nameAr: null | string;
  category:
    | "Binders"
    | "Steel"
    | "Masonry"
    | "Aggregates"
    | "Admixtures"
    | "FinishingWorks"
    | "Other";
  /** Unités autorisées (codes du référentiel : `sac`, `t`, `kg`...), jamais du texte libre. */
  allowedUnits: (
    | "u"
    | "ml"
    | "m2"
    | "m3"
    | "kg"
    | "t"
    | "sac"
    | "l"
    | "h"
    | "j"
    | "pj"
    | "ft"
  )[];
  /** Unites du referentiel (skill `metier-chantier`), identifiees par leur <b>code stable</b> dans le JSON, la base et les vecteurs de calcul :
    `u ml m2 m3 kg t sac l h j pj ft`. Une quantite n'existe jamais sans unite (regle 1). */
  defaultUnit:
    | "u"
    | "ml"
    | "m2"
    | "m3"
    | "kg"
    | "t"
    | "sac"
    | "l"
    | "h"
    | "j"
    | "pj"
    | "ft";
  /** Masse d'un sac en kg (50 pour le ciment) ; obligatoire si l'unité `sac` est autorisée. Sert aux conversions sac, kg, T. */
  bagMassKg: null | number;
  /** Un produit désactivé reste affiché dans l'historique mais ne peut plus être demandé ni livré. */
  isActive: boolean;
  deactivatedAt: null | string;
  /** Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification. */
  version: string;
  createdAt: string;
  createdByName: null | string;
  updatedAt: null | string;
  updatedByName: null | string;
};
export type PagedResultOfProductResponse = {
  items: ProductResponse[];
  page: number;
  pageSize: number;
  totalCount: number;
};
export type ProductCategory =
  | "Binders"
  | "Steel"
  | "Masonry"
  | "Aggregates"
  | "Admixtures"
  | "FinishingWorks"
  | "Other";
export type MeasureUnit =
  "u" | "ml" | "m2" | "m3" | "kg" | "t" | "sac" | "l" | "h" | "j" | "pj" | "ft";
export type CreateProductRequest = {
  /** Nom en français (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus). */
  nameFr: string;
  /** Nom en arabe (facultatif : le nom français est affiché à défaut). */
  nameAr?: null | string;
  category: null | ProductCategory;
  /** Unités autorisées (au moins une), parmi le référentiel : jamais de texte libre. */
  allowedUnits: MeasureUnit[];
  defaultUnit: null | MeasureUnit;
  /** Masse d'un sac en kg ; obligatoire si l'unité `sac` est autorisée (422 `MASSE_SAC_OBLIGATOIRE`). */
  bagMassKg?: null | number;
};
export type UpdateProductRequest = {
  /** Version lue avec le produit ; une version périmée donne 409 `CONFLIT_VERSION`. */
  version: string;
  /** Nom en français (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus). */
  nameFr: string;
  /** Nom en arabe (facultatif : le nom français est affiché à défaut). */
  nameAr?: null | string;
  category: null | ProductCategory;
  /** Unités autorisées (au moins une), parmi le référentiel : jamais de texte libre. */
  allowedUnits: MeasureUnit[];
  defaultUnit: null | MeasureUnit;
  /** Masse d'un sac en kg ; obligatoire si l'unité `sac` est autorisée (422 `MASSE_SAC_OBLIGATOIRE`). */
  bagMassKg?: null | number;
};
export type WilayaResponse = {
  code: string;
  nameFr: string;
  nameAr: string;
};
export type CommuneResponse = {
  nameFr: string;
  nameAr: string;
};
export type ProductRefResponse = {
  productId: null | string;
  name: null | string;
  nameAr: null | string;
  freeName: null | string;
};
export type Quantity = {
  /** Valeur, 3 decimales au plus. */
  value: number;
  /** Code de l'unite : `u ml m2 m3 kg t sac l h j pj ft`. */
  unit: MeasureUnit;
};
export type Priority = "Normal" | "Urgent" | "Blocking";
export type RequestStatus =
  | "Requested"
  | "Validated"
  | "Rejected"
  | "Ordered"
  | "PartiallyDelivered"
  | "Delivered"
  | "Received"
  | "Cancelled";
export type StatusReasonResponse = {
  code: string;
  note: null | string;
};
export type VarianceResponse = {
  value: number;
  unit: MeasureUnit;
  percent: number;
};
export type DuplicateRefResponse = {
  id: string;
  number: string;
};
export type OrderCommercialResponse = {
  unitPrice: null | number;
  amount: null | number;
  receivedValue: null | number;
  purchaseOrderNumber: null | string;
};
export type OrderResponse = {
  id: string;
  supplierId: string;
  supplierName: null | string;
  orderDate: string;
  expectedDeliveryDate: null | string;
  /** Jours entre la date de besoin et la livraison prevue quand elle la depasse (avertissement, jamais un blocage) ; 0 sinon. */
  plannedAfterNeedDays: number;
  note: null | string;
  /** Jeton de concurrence de la commande (entier decimal en chaine). */
  version: string;
  commercial?: null | OrderCommercialResponse;
};
export type MaterialRequestResponse = {
  id: string;
  siteId: string;
  /** Code du chantier (liste transversale et REST) ; absent de la synchronisation. */
  siteCode?: null | string;
  /** Identifiant genere par le telephone qui a cree la demande (creation hors ligne), sinon `null`. */
  clientId?: null | string;
  clientCreatedAt?: null | string;
  /** Numero `DEM-nnn`, donne par le serveur. */
  number: string;
  product: ProductRefResponse;
  /** Quantite demandee et son unite. */
  quantity: Quantity;
  zoneId?: null | string;
  /** Date de besoin (« pour le »), date complete sans fuseau. */
  neededBy: string;
  priority: Priority;
  note?: null | string;
  status: RequestStatus;
  statusReason?: null | StatusReasonResponse;
  receivedQuantity?: null | Quantity;
  remainingQuantity?: null | Quantity;
  variance?: null | VarianceResponse;
  /** Manque definitif accepte (« solde »). */
  isSettled: boolean;
  /** Jours de retard par rapport a la date de besoin (date d'Algerie), pour une demande ouverte ; 0 sinon. */
  overdueDays: number;
  possibleDuplicateOf?: null | DuplicateRefResponse;
  order?: null | OrderResponse;
  /** Demande validee qui a deja une livraison rattachee non annulee (badge « Livraison recue sans commande enregistree »). */
  hasDeliveryWithoutOrder?: boolean;
  requestedById: string;
  requestedByName?: null | string;
  archivedAt?: null | string;
  archivedByName?: null | string;
  /** Jeton de concurrence (entier decimal en chaine), a renvoyer a la modification. */
  version: string;
  createdAt: string;
  createdByName?: null | string;
  updatedAt?: null | string;
  updatedByName?: null | string;
};
export type PagedResultOfMaterialRequestResponse = {
  items: MaterialRequestResponse[];
  page: number;
  pageSize: number;
  totalCount: number;
};
export type MaterialReasonsResponse = {
  rejection: string[];
  requestCancellation: string[];
  orderCancellation: string[];
  settle: string[];
  deliveryCancellation: string[];
  reserve: string[];
};
export type MaterialSettingsResponse = {
  /** Date de besoin proposée = aujourd'hui + ce nombre de jours. */
  defaultNeededByDays: number;
  /** Tolérance de « livraison complète » en pourcentage de la quantité commandée. */
  deliveryTolerancePercent: number;
  /** Nombre maximal de photos de bon de livraison par livraison. */
  maxPhotosPerDelivery: number;
  /** Taille maximale d'une photo, en octets. */
  maxPhotoBytes: number;
  /** Longueur maximale d'une remarque. */
  noteMaxLength: number;
  reasons: MaterialReasonsResponse;
};
export type SiteType = "School" | "Housing" | "PublicFacility" | "Other";
export type SiteResponse = {
  id: string;
  /** Code unique et immuable, par exemple `CH-ECO-UV18`. */
  code: string;
  name: string;
  /** Nom en arabe, s'il existe. */
  nameAr: null | string;
  type: SiteType;
  wilaya: string;
  commune: string;
  latitude: null | number;
  longitude: null | number;
  owner: string;
  contractNumber: null | string;
  /** Montant du marché en DZD (2 décimales) ; absent sans la permission `ContractAmount.View`. */
  contractAmount?: null | number;
  /** Délai contractuel en jours calendaires. */
  delayDays: null | number;
  /** Date de l'ordre de service de démarrage. */
  odsDate: null | string;
  /** Fin contractuelle = date de l'ODS + délai, calculée par le serveur ; `null` si l'un des deux manque (« À définir »). */
  contractualEndDate: null | string;
  /** Date d'archivage ; un chantier archivé est en lecture seule. */
  archivedAt: null | string;
  /** Nom de la personne qui a archivé. */
  archivedByName: null | string;
  /** Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification. */
  version: string;
  /** Création (heure du serveur, UTC). */
  createdAt: string;
  /** Nom du créateur. */
  createdByName: null | string;
  /** Dernière modification (heure du serveur, UTC). */
  updatedAt: null | string;
  /** Nom de la dernière personne ayant modifié. */
  updatedByName: null | string;
};
export type PagedResultOfSiteResponse = {
  items: SiteResponse[];
  page: number;
  pageSize: number;
  totalCount: number;
};
export type CreateSiteRequest = {
  /** Code unique et immuable, proposé par `GET /sites/code-suggestion`. */
  code: string;
  /** Nom du chantier (français). */
  name: string;
  /** Nom en arabe (facultatif) : affiché à la place du nom français s'il est présent. */
  nameAr?: null | string;
  type: null | SiteType;
  /** Wilaya (liste de référence). */
  wilaya: string;
  /** Commune (liste de la wilaya ; une saisie libre est acceptée). */
  commune: string;
  /** Latitude en degrés décimaux (va avec la longitude). */
  latitude?: null | number;
  /** Longitude en degrés décimaux (va avec la latitude). */
  longitude?: null | number;
  /** Maître d'ouvrage. */
  owner: string;
  /** Numéro du marché. */
  contractNumber?: null | string;
  /** Montant du marché en DZD, 2 décimales. */
  contractAmount?: null | number;
  /** Délai en jours calendaires (entier supérieur à 0). */
  delayDays?: null | number;
  /** Date complète de l'ordre de service de démarrage ; une date incomplète (`../03/2026`) donne `DATE_INVALIDE`. */
  odsDate?: null | string;
};
export type SiteCodeSuggestion = {
  code: string;
};
export type UpdateSiteRequest = {
  /** Version lue avec le chantier ; une version périmée donne 409 `CONFLIT_VERSION`. */
  version: string;
  /** Nom du chantier (français). */
  name: string;
  /** Nom en arabe (facultatif) : affiché à la place du nom français s'il est présent. */
  nameAr?: null | string;
  type: null | SiteType;
  /** Wilaya (liste de référence). */
  wilaya: string;
  /** Commune (liste de la wilaya ; une saisie libre est acceptée). */
  commune: string;
  /** Latitude en degrés décimaux (va avec la longitude). */
  latitude?: null | number;
  /** Longitude en degrés décimaux (va avec la latitude). */
  longitude?: null | number;
  /** Maître d'ouvrage. */
  owner: string;
  /** Numéro du marché. */
  contractNumber?: null | string;
  /** Montant du marché en DZD, 2 décimales. */
  contractAmount?: null | number;
  /** Délai en jours calendaires (entier supérieur à 0). */
  delayDays?: null | number;
  /** Date complète de l'ordre de service de démarrage ; une date incomplète (`../03/2026`) donne `DATE_INVALIDE`. */
  odsDate?: null | string;
};
export type UnattachedReason =
  "NoRequestChosen" | "RequestNotOpen" | "RequestMissing";
export type Conformity = "Conform" | "WithReserve";
export type ReserveResponse = {
  code: string;
  note: null | string;
};
export type DeliveryStatus = "Recorded" | "Cancelled";
export type PhotoContentStatus = "Pending" | "Uploaded";
export type DeliveryPhotoItem = {
  id: string;
  contentStatus: PhotoContentStatus;
  sizeBytes: number;
  takenAt: string;
};
export type DeliveryCommercialResponse = {
  amount: number;
};
export type DeliveryResponse = {
  id: string;
  siteId: string;
  clientId?: null | string;
  clientCreatedAt?: null | string;
  /** Numero `LIV-nnn`, donne par le serveur ; jamais reutilise, meme apres une annulation. */
  number: string;
  /** Demande liee ; `null` = non rattachee (voir `unattachedReason`). */
  requestId?: null | string;
  requestNumber?: null | string;
  unattachedReason?: null | UnattachedReason;
  supplierId?: null | string;
  supplierName?: null | string;
  freeSupplierName?: null | string;
  product: ProductRefResponse;
  /** Quantite recue, dans l'unite saisie. */
  quantity: Quantity;
  quantityInRequestUnit?: null | Quantity;
  deliveryDate: string;
  deliveryNoteNumber?: null | string;
  /** Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`). */
  missingNote?: null | boolean;
  conformity: Conformity;
  reserve?: null | ReserveResponse;
  status: DeliveryStatus;
  cancelReason?: null | StatusReasonResponse;
  possibleDuplicateOf?: null | DuplicateRefResponse;
  /** Nombre de photos du bon. */
  photoCount: number;
  /** Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation. */
  photos?: null | DeliveryPhotoItem[];
  commercial?: null | DeliveryCommercialResponse;
  /** Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction. */
  version: string;
  createdAt: string;
  createdByName?: null | string;
  updatedAt?: null | string;
  updatedByName?: null | string;
};
export type PagedResultOfDeliveryResponse = {
  items: DeliveryResponse[];
  page: number;
  pageSize: number;
  totalCount: number;
};
export type MaterialEventType =
  | "Created"
  | "Edited"
  | "Approved"
  | "QuantityAdjusted"
  | "Rejected"
  | "Cancelled"
  | "Ordered"
  | "OrderEdited"
  | "OrderCommercialEdited"
  | "OrderCancelled"
  | "DeliveryRegistered"
  | "DeliveryEdited"
  | "DeliveryCancelled"
  | "DeliveryAttached"
  | "StatusRecomputed"
  | "Settled"
  | "Received"
  | "Archived"
  | "Restored"
  | "ProductLinked"
  | "PhotoAdded";
export type FieldChange = {
  field: string;
  old: null | string;
  new: null | string;
};
export type MaterialEventSource = "Api" | "Sync" | "System";
export type RequestHistoryItem = {
  id: string;
  type: MaterialEventType;
  fromStatus: null | RequestStatus;
  toStatus: null | RequestStatus;
  reasonCode: null | string;
  reasonNote: null | string;
  changes: null | FieldChange[];
  actorName: null | string;
  occurredAt: string;
  /** « Saisi le » du telephone pour une saisie hors ligne : information seulement. */
  deviceAt: null | string;
  source: MaterialEventSource;
};
export type DeliveryDetailResponse = {
  history?: RequestHistoryItem[];
  id?: string;
  siteId?: string;
  clientId?: null | string;
  clientCreatedAt?: null | string;
  /** Numero `LIV-nnn`, donne par le serveur ; jamais reutilise, meme apres une annulation. */
  number?: string;
  /** Demande liee ; `null` = non rattachee (voir `unattachedReason`). */
  requestId?: null | string;
  requestNumber?: null | string;
  unattachedReason?: null | UnattachedReason;
  supplierId?: null | string;
  supplierName?: null | string;
  freeSupplierName?: null | string;
  product?: ProductRefResponse;
  /** Quantite recue, dans l'unite saisie. */
  quantity?: Quantity;
  quantityInRequestUnit?: null | Quantity;
  deliveryDate?: string;
  deliveryNoteNumber?: null | string;
  /** Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`). */
  missingNote?: null | boolean;
  conformity?: Conformity;
  reserve?: null | ReserveResponse;
  status?: DeliveryStatus;
  cancelReason?: null | StatusReasonResponse;
  possibleDuplicateOf?: null | DuplicateRefResponse;
  /** Nombre de photos du bon. */
  photoCount?: number;
  /** Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation. */
  photos?: null | DeliveryPhotoItem[];
  commercial?: null | DeliveryCommercialResponse;
  /** Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction. */
  version?: string;
  createdAt?: string;
  createdByName?: null | string;
  updatedAt?: null | string;
  updatedByName?: null | string;
};
export type QuantityBody = {
  /** Valeur strictement positive, 3 décimales au plus ; entier pour `sac` et `u` (422 `QUANTITE_INVALIDE`, `QUANTITE_ENTIERE_REQUISE`). */
  value?: null | number;
  unit?: null | MeasureUnit;
};
export type CreateDeliveryRequest = {
  /** Identifiant généré par le téléphone : un renvoi donne 200 et la même livraison, sans nouveau numéro. */
  clientId?: null | string;
  /** Heure du téléphone (« saisi le ») : information seulement. */
  clientCreatedAt?: null | string;
  /** Demande livrée ; absente = livraison non rattachée. Une demande d'un autre chantier : 404. */
  requestId?: null | string;
  /** Fournisseur du catalogue (par défaut celui de la commande) ; exactement un de `supplierId` et `freeSupplierName`. */
  supplierId?: null | string;
  /** « Autre fournisseur » : nom libre de 3 à 100 caractères. */
  freeSupplierName?: null | string;
  /** Produit du catalogue ; sans demande seulement (avec une demande, c'est celui de la demande : un autre produit donne 422 `PRODUIT_DIFFERENT`). */
  productId?: null | string;
  freeProductName?: null | string;
  quantity: null | QuantityBody;
  /** Date de livraison complète, pas dans le futur (heure d'Algérie). */
  deliveryDate?: null | string;
  /** N° du bon de livraison (30 caractères au plus), mis en majuscules. */
  deliveryNoteNumber?: null | string;
  conformity?: null | Conformity;
  /** Motif de réserve, de la liste de `GET /settings/materials` ; `Other` impose une remarque. */
  reserveReasonCode?: null | string;
  reserveNote?: null | string;
};
export type UpdateDeliveryRequest = {
  /** Version lue avec la livraison. */
  version: string;
  quantity?: null | QuantityBody;
  deliveryDate?: null | string;
  /** N° de BL ; une valeur déjà posée se remplace, elle ne s'efface pas. */
  deliveryNoteNumber?: null | string;
  conformity?: null | Conformity;
  reserveReasonCode?: null | string;
  reserveNote?: null | string;
};
export type AttachBody = {
  requestId: string;
};
export type ReasonBody = {
  reasonCode?: null | string;
  /** Remarque (200 caractères au plus), obligatoire pour `Other`. */
  reasonNote?: null | string;
};
export type PhotoResponse = {
  id: string;
  siteId: string;
  deliveryId: string;
  clientId: null | string;
  takenAt: string;
  contentType: string;
  sizeBytes: number;
  /** Etat du fichier d'une photo : les metadonnees existent (`Pending`), puis le binaire est envoye (`Uploaded`). */
  contentStatus: "Pending" | "Uploaded";
  uploadedAt: null | string;
  version: string;
  createdAt: string;
};
export type CreatePhotoRequest = {
  /** Identifiant généré par le téléphone : un renvoi donne 200 et les mêmes métadonnées. */
  clientId?: null | string;
  clientCreatedAt?: null | string;
  /** Heure de la prise de vue (téléphone) : information seulement. */
  takenAt?: null | string;
  /** Toujours `image/jpeg` (415 `TYPE_FICHIER_REFUSE` sinon). */
  contentType?: null | string;
  /** Taille du fichier envoyé, en octets (413 `FICHIER_TROP_GROS` au-delà de `maxPhotoBytes`). */
  sizeBytes?: null | number;
  /** Empreinte SHA-256 du fichier envoyé (64 caractères hexadécimaux) : rend l'envoi du fichier idempotent et vérifie son intégrité. */
  sha256?: null | string;
};
export type FollowUpCounters = {
  /** A valider : demandees. */
  toApprove: number;
  /** A commander : validees. */
  toOrder: number;
  /** Attendues : commandees et livrees partiellement. */
  expected: number;
  /** En retard : date de besoin depassee, ou commande attendue dont la date prevue est depassee. */
  late: number;
  /** A receptionner : livrees. */
  toReceive: number;
};
export type ToOrderTotalLine = {
  /** Produit du catalogue ; `null` pour un nom libre. */
  productId: null | string;
  name: string;
  total: Quantity;
  massEquivalent?: null | Quantity;
  /** Nombre de demandes comptees dans cette ligne. */
  requestCount: number;
};
export type FollowUpCommercialResponse = {
  orderedAmount: number;
  receivedValue: number;
};
export type FollowUpResponse = {
  counters: FollowUpCounters;
  toOrderTotals: ToOrderTotalLine[];
  commercial?: null | FollowUpCommercialResponse;
};
export type SiteMemberResponse = {
  userId: string;
  fullName: string;
  role: string;
  /** Date d'affectation (heure du serveur, UTC). */
  assignedAt: string;
};
export type ItemsResponseOfSiteMemberResponse = {
  items: SiteMemberResponse[];
};
export type RequestDeliveryItem = {
  id: string;
  number: string;
  deliveryDate: string;
  quantity: Quantity;
  quantityInRequestUnit?: null | Quantity;
  status: DeliveryStatus;
  deliveryNoteNumber: null | string;
  conformity: Conformity;
  photoCount: number;
};
export type MaterialRequestDetailResponse = {
  history?: RequestHistoryItem[];
  /** Livraisons de la demande, annulees comprises ; absentes de la synchronisation (l'entite `delivery` les porte). */
  deliveries?: null | RequestDeliveryItem[];
  id?: string;
  siteId?: string;
  /** Code du chantier (liste transversale et REST) ; absent de la synchronisation. */
  siteCode?: null | string;
  /** Identifiant genere par le telephone qui a cree la demande (creation hors ligne), sinon `null`. */
  clientId?: null | string;
  clientCreatedAt?: null | string;
  /** Numero `DEM-nnn`, donne par le serveur. */
  number?: string;
  product?: ProductRefResponse;
  /** Quantite demandee et son unite. */
  quantity?: Quantity;
  zoneId?: null | string;
  /** Date de besoin (« pour le »), date complete sans fuseau. */
  neededBy?: string;
  priority?: Priority;
  note?: null | string;
  status?: RequestStatus;
  statusReason?: null | StatusReasonResponse;
  receivedQuantity?: null | Quantity;
  remainingQuantity?: null | Quantity;
  variance?: null | VarianceResponse;
  /** Manque definitif accepte (« solde »). */
  isSettled?: boolean;
  /** Jours de retard par rapport a la date de besoin (date d'Algerie), pour une demande ouverte ; 0 sinon. */
  overdueDays?: number;
  possibleDuplicateOf?: null | DuplicateRefResponse;
  order?: null | OrderResponse;
  /** Demande validee qui a deja une livraison rattachee non annulee (badge « Livraison recue sans commande enregistree »). */
  hasDeliveryWithoutOrder?: boolean;
  requestedById?: string;
  requestedByName?: null | string;
  archivedAt?: null | string;
  archivedByName?: null | string;
  /** Jeton de concurrence (entier decimal en chaine), a renvoyer a la modification. */
  version?: string;
  createdAt?: string;
  createdByName?: null | string;
  updatedAt?: null | string;
  updatedByName?: null | string;
};
export type CreateRequestRequest = {
  /** Identifiant généré par le téléphone : un renvoi avec le même `clientId` donne 200 et la même demande, sans nouveau numéro. */
  clientId?: null | string;
  /** Heure du téléphone à la saisie (« saisi le ») : information seulement, jamais utilisée pour trier ou décider. */
  clientCreatedAt?: null | string;
  /** Produit du catalogue (actif). Exactement un de `productId` et `freeProductName`. */
  productId?: null | string;
  /** « Autre produit » : nom libre de 3 à 100 caractères. */
  freeProductName?: null | string;
  quantity: null | QuantityBody;
  /** Zone du chantier (facultative) ; 422 `ZONE_HORS_CHANTIER` si elle appartient à un autre chantier. */
  zoneId?: null | string;
  /** Date de besoin complète (« pour le ») ; une date passée est acceptée (avertissement côté client). */
  neededBy?: null | string;
  priority?: null | Priority;
  /** Usage ou remarque (200 caractères au plus). */
  note?: null | string;
};
export type BatchItemResult = {
  requestId: string;
  outcome: string;
  code?: null | string;
};
export type BatchResponse = {
  results: BatchItemResult[];
};
export type RequestIdsBody = {
  requestIds: string[];
};
export type UpdateRequestRequest = {
  /** Version lue avec la demande. */
  version: string;
  /** Produit du catalogue ; écarte le nom libre. Verrouillé après la validation (422 `DEMANDE_VERROUILLEE`). */
  productId?: null | string;
  /** Nom libre ; écarte le produit du catalogue. Verrouillé après la validation. */
  freeProductName?: null | string;
  quantity?: null | QuantityBody;
  /** Zone. Verrouillée après la validation. */
  zoneId?: null | string;
  /** Date de besoin : modifiable jusqu'à la livraison (droit `Requests.UpdateAny` après la validation). */
  neededBy?: null | string;
  priority?: null | Priority;
  /** Remarque ; une chaîne vide l'efface. */
  note?: null | string;
};
export type ApproveBody = {
  quantity?: null | QuantityBody;
};
export type LinkProductBody = {
  productId: string;
};
export type CreateOrderRequest = {
  /** Identifiant généré par le client : un renvoi donne 200 et la même commande, sans nouvel effet. */
  clientId?: null | string;
  /** Fournisseur du catalogue, actif (422 `FOURNISSEUR_INACTIF` sinon). */
  supplierId: string;
  /** Date de commande complète, pas dans le futur (heure d'Algérie). */
  orderDate?: null | string;
  /** Livraison prévue, complète et pas avant la date de commande. Au-delà de la date de besoin : avertissement (`plannedAfterNeedDays`), jamais un blocage. */
  expectedDeliveryDate?: null | string;
  /** Prix unitaire hors taxes par unité de commande, en DZD, supérieur à 0, 2 décimales au plus. Facultatif (« à renseigner »). */
  unitPrice?: null | number;
  /** N° du bon de commande (50 caractères au plus). */
  purchaseOrderNumber?: null | string;
  /** Remarque (200 caractères au plus). */
  note?: null | string;
};
export type UpdateOrderRequest = {
  /** Version de la commande, lue dans `order.version`. */
  version: string;
  supplierId?: null | string;
  expectedDeliveryDate?: null | string;
  /** Nouveau prix : recalcule le montant de la commande et de chaque livraison (événement sensible `OrderCommercialEdited`). */
  unitPrice?: null | number;
  purchaseOrderNumber?: null | string;
  note?: null | string;
};
export type ReceiveBody = {
  /** Remarque facultative (200 caractères au plus). */
  note?: null | string;
};
export type RoomType =
  | "Classroom"
  | "Corridor"
  | "Canteen"
  | "Refectory"
  | "Kitchen"
  | "Office"
  | "Sanitary"
  | "TechnicalRoom"
  | "Facade"
  | "Other";
export type ZoneResponse = {
  id: string;
  siteId: string;
  /** Identifiant généré par le téléphone qui a créé la zone (création hors ligne), sinon `null`. */
  clientId: null | string;
  /** « Saisi le » du téléphone : information seulement, jamais utilisée pour trier ou décider. */
  clientCreatedAt: null | string;
  /** Bloc, par exemple `Bloc 01`. */
  block: string;
  /** Cote en mètres, 2 décimales (affichage signé côté client : −1,90 ; ±0,00 ; +3,40). */
  elevation: null | number;
  roomType: null | RoomType;
  /** Numéro du local (classe 02). */
  roomNumber: null | number;
  /** Libellé libre, seulement si le type est `Other`. */
  roomLabel: null | string;
  /** Date d'archivage ; une zone archivée n'est plus proposée à la saisie. */
  archivedAt: null | string;
  /** Nom de la personne qui a archivé. */
  archivedByName: null | string;
  /** Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification. */
  version: string;
  /** Création (heure du serveur, UTC). */
  createdAt: string;
  /** Nom du créateur. */
  createdByName: null | string;
  /** Dernière modification (heure du serveur, UTC). */
  updatedAt: null | string;
  /** Nom de la dernière personne ayant modifié. */
  updatedByName: null | string;
};
export type CursorPageOfZoneResponse = {
  items: ZoneResponse[];
  nextCursor: null | string;
};
export type CreateZoneRequest = {
  /** Identifiant généré par le téléphone : un renvoi avec le même `clientId` donne 200 et la même zone. */
  clientId?: null | string;
  /** Heure du téléphone à la saisie (« saisi le ») : information seulement, jamais utilisée pour trier ou décider. */
  clientCreatedAt?: null | string;
  /** Bloc du chantier (obligatoire). */
  block: string;
  /** Cote en mètres, 2 décimales, de -20,00 à +60,00 (paramétrable). */
  elevation?: null | number;
  roomType?: null | RoomType;
  /** Numéro du local (1 à 999) ; exige un type de local. */
  roomNumber?: null | number;
  /** Libellé libre, seulement si `roomType = Other`. */
  roomLabel?: null | string;
};
export type UpdateZoneRequest = {
  /** Version lue avec la zone ; une version périmée donne 409 `CONFLIT_VERSION`. */
  version: string;
  /** Bloc du chantier (obligatoire). */
  block: string;
  /** Cote en mètres, 2 décimales, de -20,00 à +60,00 (paramétrable). */
  elevation?: null | number;
  roomType?: null | RoomType;
  /** Numéro du local (1 à 999) ; exige un type de local. */
  roomNumber?: null | number;
  /** Libellé libre, seulement si `roomType = Other`. */
  roomLabel?: null | string;
};
export type SupplierResponse = {
  id: string;
  name: string;
  /** Téléphone au format algérien (`0550 00 00 21`) ; donnée sensible. */
  phone?: null | string;
  /** Produits fournis (liste indicative). */
  productIds: string[];
  isActive: boolean;
  deactivatedAt: null | string;
  version: string;
  createdAt: string;
  createdByName: null | string;
  updatedAt: null | string;
  updatedByName: null | string;
};
export type PagedResultOfSupplierResponse = {
  items: SupplierResponse[];
  page: number;
  pageSize: number;
  totalCount: number;
};
export type CreateSupplierRequest = {
  /** Nom du fournisseur (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus). */
  name: string;
  /** Téléphone au format algérien (05, 06 ou 07 suivi de 8 chiffres, espaces facultatifs). */
  phone?: null | string;
  /** Produits fournis (identifiants du catalogue), liste indicative. */
  productIds?: null | string[];
};
export type UpdateSupplierRequest = {
  /** Version lue avec le fournisseur ; une version périmée donne 409 `CONFLIT_VERSION`. */
  version: string;
  /** Nom du fournisseur (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus). */
  name: string;
  /** Téléphone au format algérien (05, 06 ou 07 suivi de 8 chiffres, espaces facultatifs). */
  phone?: null | string;
  /** Produits fournis (identifiants du catalogue), liste indicative. */
  productIds?: null | string[];
};
export type SyncChange = {
  /** `site`, `zone` ou `member` ; un client ignore une entité qu'il ne connaît pas. */
  entity: string;
  /** Identifiant de la ligne. */
  id: string;
  /** Chantier de la ligne (pour un chantier : son propre identifiant) ; `null` pour une entité globale (`product`, `supplier`). */
  siteId: null | string;
  /** Version serveur (entier décimal en chaîne) : n'appliquer la ligne que si elle est plus grande que celle déjà connue. */
  version: string;
  /** Ressource de la ligne, selon `entity` : `SiteResponse` (site), `ZoneResponse` (zone), `SyncMemberData` (member), `ProductResponse` (product), `SupplierSyncData` (supplier, sans téléphone), `RequestSyncData` (request, sans champ commercial), `DeliverySyncData` (delivery, sans montant ni photos) ou `PhotoResponse` (photo, métadonnées seulement). */
  data: object;
};
export type SyncDeletion = {
  /** `site`, `zone` ou `member`. */
  entity: string;
  /** Identifiant de la ligne supprimée. */
  id: string;
  /** Chantier de la ligne ; `null` pour une entité globale. */
  siteId: null | string;
  /** Version serveur de la suppression. */
  version: string;
};
export type SyncPullResponse = {
  /** Lignes créées ou modifiées, par version croissante. */
  changes: SyncChange[];
  /** Pierres tombales. */
  deleted: SyncDeletion[];
  /** Curseur à renvoyer au prochain appel (donné par le serveur, jamais l'horloge du téléphone). */
  cursor: string;
  /** Vrai s'il reste des changements : rappeler tout de suite avec ce curseur. */
  hasMore: boolean;
};
export type SyncPushResult = {
  /** Identifiant de l'opération côté téléphone. */
  clientId: string;
  /** `applied`, `duplicate`, `conflict`, `rejected` ou `retry`. */
  status: string;
  /** Ressource créée ou déjà existante (`applied`, `duplicate`). */
  resource?: null | object;
  /** État du serveur (`conflict`). */
  current?: null | object;
  /** Code d'erreur du catalogue (`rejected`) : `INTROUVABLE`, `INTERDIT`, `CHANTIER_ARCHIVE`, `VALIDATION`, `ZONE_EXISTANTE`, `ENTITE_NON_SYNCHRONISABLE`. */
  code?: null | string;
  /** Vrai si une ressource identique, créée par un autre téléphone, a été retenue : y rattacher les saisies, sans erreur affichée. */
  merged?: null | boolean;
  /** Détail par champ (`rejected` avec `VALIDATION`). */
  errors?:
    | {
        [key: string]: string[];
      }
    | {
        [key: string]: string[];
      };
  /** Champs en désaccord (`conflict` avec `CONFLIT_VERSION`) : la valeur saisie et celle du serveur diffèrent de la valeur de départ. */
  conflictFields?: null | string[];
};
export type SyncPushResponse = {
  results: SyncPushResult[];
};
export type SyncPushOperation = {
  /** Identifiant généré par le téléphone : rend l'envoi idempotent (un renvoi donne `duplicate`). */
  clientId: string;
  /** Entité visée (`zone` au socle) ; une autre entité reçoit `rejected` `ENTITE_NON_SYNCHRONISABLE`. */
  entity: string;
  /** `create`, `update` ou `transition` (au socle : `create` d'une zone). */
  operation: string;
  /** Chantier visé. */
  siteId?: null | string;
  /** Contenu de l'opération : les champs de la ressource (pour une zone : `block`, `elevation`, `roomType`, `roomNumber`, `roomLabel`, `clientCreatedAt`). */
  payload?: null | object;
  /** Version serveur lue par le téléphone (modifications) ; inutilisée pour une création. */
  baseVersion?: null | string;
};
export type SyncPushRequest = {
  /** Opérations dans l'ordre de saisie ; les résultats reviennent dans le même ordre. */
  operations: SyncPushOperation[];
};
export const {
  useAuthChangePasswordMutation,
  useAuthLoginMutation,
  useAuthLogoutMutation,
  useAuthMeQuery,
  useLazyAuthMeQuery,
  useAuthUpdateLanguageMutation,
  useAuthRefreshMutation,
  useProductsListQuery,
  useLazyProductsListQuery,
  useProductsCreateMutation,
  useProductsGetQuery,
  useLazyProductsGetQuery,
  useProductsUpdateMutation,
  useProductsActivateMutation,
  useProductsDeactivateMutation,
  useReferenceWilayasQuery,
  useLazyReferenceWilayasQuery,
  useReferenceCommunesQuery,
  useLazyReferenceCommunesQuery,
  useCrossSiteRequestsListQuery,
  useLazyCrossSiteRequestsListQuery,
  useMaterialSettingsGetQuery,
  useLazyMaterialSettingsGetQuery,
  useSitesListQuery,
  useLazySitesListQuery,
  useSitesCreateMutation,
  useSitesSuggestCodeQuery,
  useLazySitesSuggestCodeQuery,
  useSitesGetQuery,
  useLazySitesGetQuery,
  useSitesUpdateMutation,
  useSitesArchiveMutation,
  useDeliveriesListQuery,
  useLazyDeliveriesListQuery,
  useDeliveriesCreateMutation,
  useDeliveriesGetQuery,
  useLazyDeliveriesGetQuery,
  useDeliveriesUpdateMutation,
  useDeliveriesAttachMutation,
  useDeliveriesCancelMutation,
  usePhotosCreateMutation,
  useFollowUpGetQuery,
  useLazyFollowUpGetQuery,
  useSiteMembersListQuery,
  useLazySiteMembersListQuery,
  useSiteMembersRemoveMutation,
  useSiteMembersAssignMutation,
  usePhotosDownloadQuery,
  useLazyPhotosDownloadQuery,
  usePhotosUploadMutation,
  useRequestsListQuery,
  useLazyRequestsListQuery,
  useRequestsCreateMutation,
  useRequestsApproveBatchMutation,
  useRequestsArchiveBatchMutation,
  useRequestsGetQuery,
  useLazyRequestsGetQuery,
  useRequestsUpdateMutation,
  useRequestsApproveMutation,
  useRequestsArchiveMutation,
  useRequestsCancelMutation,
  useRequestsLinkProductMutation,
  useOrdersCreateMutation,
  useOrdersUpdateMutation,
  useOrdersCancelMutation,
  useRequestsReceiveMutation,
  useRequestsRejectMutation,
  useRequestsRestoreMutation,
  useRequestsSettleMutation,
  useSitesRestoreMutation,
  useZonesListQuery,
  useLazyZonesListQuery,
  useZonesCreateMutation,
  useZonesGetQuery,
  useLazyZonesGetQuery,
  useZonesUpdateMutation,
  useZonesArchiveMutation,
  useZonesRestoreMutation,
  useSuppliersListQuery,
  useLazySuppliersListQuery,
  useSuppliersCreateMutation,
  useSuppliersGetQuery,
  useLazySuppliersGetQuery,
  useSuppliersUpdateMutation,
  useSuppliersActivateMutation,
  useSuppliersDeactivateMutation,
  useSyncChangesQuery,
  useLazySyncChangesQuery,
  useSyncPushMutation,
} = injectedRtkApi;
