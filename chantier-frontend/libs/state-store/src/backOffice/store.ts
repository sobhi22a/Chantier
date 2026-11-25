import { configureStore } from "@reduxjs/toolkit";
import { setupListeners } from "@reduxjs/toolkit/query";

import { ApplicationApiService, networkActivityReducer } from "@chantier-frontend/api-core";

import { authSliceReducer } from "./slices/authenticationSlice";

/**
 * Magasin Redux minimal (ADR 0007) : session (`authentication`), activité réseau et cache RTK Query.
 * Les données du serveur restent dans le cache RTK Query, jamais copiées dans une tranche.
 * La langue vit dans i18next (`@chantier-frontend/i18n`), source unique : pas de tranche `ui` pour l'instant.
 */
export const createChantierStore = () =>
  configureStore({
    reducer: {
      authentication: authSliceReducer,
      networkActivity: networkActivityReducer,
      [ApplicationApiService.reducerPath]: ApplicationApiService.reducer,
    },
    middleware: (getDefaultMiddleware) => getDefaultMiddleware().concat(ApplicationApiService.middleware),
  });

export type ChantierStore = ReturnType<typeof createChantierStore>;
export type ChantierRootState = ReturnType<ChantierStore["getState"]>;
export type ChantierAppDispatch = ChantierStore["dispatch"];

export const chantierStore: ChantierStore = createChantierStore();

// Rechargement des requêtes au retour du réseau ou du focus (refetchOnFocus / refetchOnReconnect).
setupListeners(chantierStore.dispatch);
