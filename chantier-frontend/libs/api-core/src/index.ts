export {
  ApplicationApiService,
  baseQueryWithNetworkActivity,
  setAcceptLanguageProvider,
} from "./lib/ApplicationApi.service";
export { getApiBaseUrl } from "./lib/apiBaseUrl";
export { isApiError, toApiError, NETWORK_ERROR_CODE, UNKNOWN_ERROR_CODE } from "./lib/apiError";
export type { ApiError } from "./lib/apiError";
export { useApiErrorMessage } from "./lib/useApiErrorMessage";
export type { ApiErrorMessage } from "./lib/useApiErrorMessage";
export { BACK_OFFICE_ENTITY_TAGS } from "./lib/entitiesTags.config";
export type { BackOfficeEntityTag } from "./lib/entitiesTags.config";
export { queryCacheTagsProvider } from "./lib/queryCacheTagsProvider";
export type { EntityTag } from "./lib/queryCacheTagsProvider";
export {
  apiCallEnded,
  apiCallStarted,
  networkActivityReducer,
  selectIsNetworkLoading,
} from "./lib/networkActivity.slice";
export type { NetworkActivityState } from "./lib/networkActivity.slice";

// Client généré depuis docs/api/openapi.json (npm run generate:api) + étiquettes de cache.
export { enhancedApi } from "./lib/enhancedApi";
export { usePhotoContentQuery } from "./lib/photoContent";
export { useZoneDirectoryQuery } from "./lib/zoneDirectory";
export type { PhotoContentArg } from "./lib/photoContent";
export * from "./generated/chantierApi";
