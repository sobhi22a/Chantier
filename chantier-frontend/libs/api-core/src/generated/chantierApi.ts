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
export type ReferenceWilayasApiResponse = /** status 200 OK */ WilayaResponse[];
export type ReferenceWilayasApiArg = void;
export type ReferenceCommunesApiResponse =
  /** status 200 OK */ CommuneResponse[];
export type ReferenceCommunesApiArg = {
  code: string;
};
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
export type WilayaResponse = {
  code: string;
  nameFr: string;
  nameAr: string;
};
export type CommuneResponse = {
  nameFr: string;
  nameAr: string;
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
export type SyncChange = {
  /** `site`, `zone` ou `member` ; un client ignore une entité qu'il ne connaît pas. */
  entity: string;
  /** Identifiant de la ligne. */
  id: string;
  /** Chantier de la ligne (pour un chantier : son propre identifiant). */
  siteId: string;
  /** Version serveur (entier décimal en chaîne) : n'appliquer la ligne que si elle est plus grande que celle déjà connue. */
  version: string;
  /** Ressource telle que renvoyée par l'API REST : `SiteResponse` (site), `ZoneResponse` (zone) ou `SyncMemberData` (member). */
  data: object;
};
export type SyncDeletion = {
  /** `site`, `zone` ou `member`. */
  entity: string;
  /** Identifiant de la ligne supprimée. */
  id: string;
  /** Chantier de la ligne. */
  siteId: string;
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
  /** `applied`, `duplicate`, `conflict` ou `rejected`. */
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
  useReferenceWilayasQuery,
  useLazyReferenceWilayasQuery,
  useReferenceCommunesQuery,
  useLazyReferenceCommunesQuery,
  useSitesListQuery,
  useLazySitesListQuery,
  useSitesCreateMutation,
  useSitesSuggestCodeQuery,
  useLazySitesSuggestCodeQuery,
  useSitesGetQuery,
  useLazySitesGetQuery,
  useSitesUpdateMutation,
  useSitesArchiveMutation,
  useSiteMembersListQuery,
  useLazySiteMembersListQuery,
  useSiteMembersRemoveMutation,
  useSiteMembersAssignMutation,
  useSitesRestoreMutation,
  useZonesListQuery,
  useLazyZonesListQuery,
  useZonesCreateMutation,
  useZonesGetQuery,
  useLazyZonesGetQuery,
  useZonesUpdateMutation,
  useZonesArchiveMutation,
  useZonesRestoreMutation,
  useSyncChangesQuery,
  useLazySyncChangesQuery,
  useSyncPushMutation,
} = injectedRtkApi;
