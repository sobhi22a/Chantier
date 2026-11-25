import type { BaseQueryFn, FetchArgs, FetchBaseQueryMeta } from "@reduxjs/toolkit/query";
import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

import { toApiError, type ApiError } from "./apiError";
import { getApiBaseUrl } from "./apiBaseUrl";
import { BACK_OFFICE_ENTITY_TAGS } from "./entitiesTags.config";
import { apiCallEnded, apiCallStarted } from "./networkActivity.slice";

/** Langue envoyée dans `Accept-Language` (`fr` ou `ar`). Branchée par l'application sur i18next. */
let languageProvider: () => string = () => "fr";
export const setAcceptLanguageProvider = (provider: () => string): void => {
  languageProvider = provider;
};

type ApiBaseQuery = ReturnType<typeof fetchBaseQuery>;
let apiBaseQuery: ApiBaseQuery | undefined;

// Créée au premier appel : voir getApiBaseUrl. Le cookie de session accompagne chaque requête (ADR 0005).
// Aucun `Content-Type` fixé ici : fetchBaseQuery le pose pour le JSON et laisse le navigateur gérer le multipart.
const getApiBaseQuery = (): ApiBaseQuery => {
  apiBaseQuery ??= fetchBaseQuery({
    baseUrl: getApiBaseUrl(),
    credentials: "include",
    prepareHeaders: (headers) => {
      headers.set("Accept", "application/json");
      headers.set("Accept-Language", languageProvider());
      return headers;
    },
  });
  return apiBaseQuery;
};

const urlOf = (args: string | FetchArgs): string => (typeof args === "string" ? args : args.url);

// La session se règle par `GET /auth/me` : ces routes ne déclenchent jamais de nouvelle lecture (pas de boucle).
const isAuthRoute = (url: string): boolean => url.includes("/auth/");

export const baseQueryWithNetworkActivity: BaseQueryFn<string | FetchArgs, unknown, ApiError, object, FetchBaseQueryMeta> =
  async (args, api, extraOptions) => {
    api.dispatch(apiCallStarted());
    try {
      const result = await getApiBaseQuery()(args, api, extraOptions);
      if (!result.error) return result;

      const error = toApiError(result.error);
      // Session expirée ou mot de passe provisoire : on relit le profil, l'interface redirige d'elle-même.
      const sessionChanged =
        !isAuthRoute(urlOf(args)) && (error.status === 401 || error.code === "MOT_DE_PASSE_A_CHANGER");
      if (sessionChanged) {
        api.dispatch(ApplicationApiService.util.invalidateTags([{ type: BACK_OFFICE_ENTITY_TAGS.ME, id: "CURRENT" }]));
      }
      return { error, meta: result.meta };
    } finally {
      api.dispatch(apiCallEnded());
    }
  };

export const ApplicationApiService = createApi({
  reducerPath: "ApplicationApi",
  baseQuery: baseQueryWithNetworkActivity,
  tagTypes: [...Object.values(BACK_OFFICE_ENTITY_TAGS)],
  endpoints: () => ({}),
});
