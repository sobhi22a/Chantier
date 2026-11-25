import { createSlice, type PayloadAction } from "@reduxjs/toolkit";

import { enhancedApi } from "@chantier-frontend/api-core";

/** Permissions par ressource, au format Kardinal : `{ Sites: { View, Create, Update, Delete } }`. */
export interface UserClaims {
  [resource: string]: {
    View: boolean;
    Create: boolean;
    Update: boolean;
    Delete: boolean;
  };
}

export interface UserAuthState {
  isAuthLoading: boolean;
  isClaimsLoading: boolean;
  userId: string | null;
  isAuthenticated: boolean;
  /** Mot de passe provisoire : le serveur refuse tout sauf le changement de mot de passe (CA-001.7). */
  mustChangePassword: boolean;
  claims: UserClaims | null;
}

export const initialAuthState: UserAuthState = {
  isAuthLoading: true,
  isClaimsLoading: true,
  userId: null,
  isAuthenticated: false,
  mustChangePassword: false,
  claims: null,
};

const CLAIM_ACTIONS = ["View", "Create", "Update", "Delete"] as const;
type ClaimAction = (typeof CLAIM_ACTIONS)[number];

/**
 * Construit les permissions au format Kardinal à partir de la liste du serveur (`GET /auth/me`) :
 * `["Sites.View", "Zones.Create"]` devient `{ Sites: { View: true, Create: false, … }, Zones: { … } }`.
 * Une action inconnue du client est ignorée ; le serveur reste juge de chaque requête.
 */
export const claimsFromPermissions = (permissions: readonly string[]): UserClaims => {
  const claims: UserClaims = {};
  for (const permission of permissions) {
    const [resource, action] = permission.split(".");
    if (!resource || !action || !(CLAIM_ACTIONS as readonly string[]).includes(action)) continue;
    claims[resource] ??= { View: false, Create: false, Update: false, Delete: false };
    claims[resource][action as ClaimAction] = true;
  }
  return claims;
};

const authSlice = createSlice({
  name: "authentication",
  initialState: initialAuthState,
  reducers: {
    setUserAuthenticationInfo: (state, action: PayloadAction<{ userId: string }>) => {
      state.isAuthenticated = true;
      state.userId = action.payload.userId;
    },
    deleteUserAuthenticationInfo: (state) => {
      state.isAuthenticated = false;
      state.userId = null;
      state.mustChangePassword = false;
    },
    setUserClaims: (state, action: PayloadAction<{ claims: UserClaims }>) => {
      state.claims = action.payload.claims;
    },
    deleteUserClaims: (state) => {
      state.claims = null;
    },
    setAuthLoadingState: (state, action: PayloadAction<{ isLoading: boolean }>) => {
      state.isAuthLoading = action.payload.isLoading;
    },
    setClaimsLoadingState: (state, action: PayloadAction<{ isLoading: boolean }>) => {
      state.isClaimsLoading = action.payload.isLoading;
    },
  },
  // Le profil du serveur (`GET /auth/me`) alimente la tranche : ni effet, ni copie manuelle.
  extraReducers: (builder) => {
    builder
      .addMatcher(enhancedApi.endpoints.authMe.matchFulfilled, (state, action) => {
        state.isAuthenticated = true;
        state.userId = action.payload.id;
        state.mustChangePassword = action.payload.mustChangePassword;
        state.claims = claimsFromPermissions(action.payload.permissions);
        state.isAuthLoading = false;
        state.isClaimsLoading = false;
      })
      .addMatcher(enhancedApi.endpoints.authMe.matchRejected, (state) => {
        // Pas de session valide (401) ou profil illisible : l'utilisateur n'est pas considéré connecté.
        state.isAuthenticated = false;
        state.userId = null;
        state.mustChangePassword = false;
        state.claims = null;
        state.isAuthLoading = false;
        state.isClaimsLoading = false;
      })
      .addMatcher(enhancedApi.endpoints.authLogout.matchFulfilled, (state) => {
        state.isAuthenticated = false;
        state.userId = null;
        state.mustChangePassword = false;
        state.claims = null;
      });
  },
});

export const {
  setUserAuthenticationInfo,
  deleteUserAuthenticationInfo,
  setUserClaims,
  deleteUserClaims,
  setAuthLoadingState,
  setClaimsLoadingState,
} = authSlice.actions;
export const authSliceReducer = authSlice.reducer;

export const selectUserAuthState = (state: { authentication: UserAuthState }): UserAuthState => state.authentication;
