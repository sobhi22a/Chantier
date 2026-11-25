import { http, HttpResponse } from "msw";

import { enhancedApi } from "@chantier-frontend/api-core";
import { apiUrl, makeMe, problem, server, setupMockServer } from "@chantier-frontend/testing";

import { createChantierStore } from "./store";

setupMockServer();

describe("tranche authentication alimentée par GET /auth/me (CT-1, CT-3)", () => {
  it("range les permissions du serveur au format { ressource: { View, Create, Update, Delete } }", async () => {
    server.use(http.get(apiUrl("/auth/me"), () => HttpResponse.json(makeMe("ChefChantier"))));
    const store = createChantierStore();

    await store.dispatch(enhancedApi.endpoints.authMe.initiate());

    const state = store.getState().authentication;
    expect(state.isAuthenticated).toBe(true);
    expect(state.userId).toBe(makeMe().id);
    expect(state.isAuthLoading).toBe(false);
    expect(state.claims?.["Zones"]).toEqual({ View: true, Create: true, Update: true, Delete: false });
    expect(state.claims?.["Sites"]).toEqual({ View: true, Create: false, Update: false, Delete: false });
    expect(state.claims?.["ContractAmount"]).toBeUndefined();
  });

  it("n'accorde rien au ChefEquipe en écriture", async () => {
    server.use(http.get(apiUrl("/auth/me"), () => HttpResponse.json(makeMe("ChefEquipe"))));
    const store = createChantierStore();

    await store.dispatch(enhancedApi.endpoints.authMe.initiate());

    const claims = store.getState().authentication.claims ?? {};
    for (const resource of Object.values(claims)) {
      expect([resource.Create, resource.Update, resource.Delete]).toEqual([false, false, false]);
    }
  });

  it("retient le mot de passe provisoire (le serveur refuse tout le reste)", async () => {
    server.use(http.get(apiUrl("/auth/me"), () => HttpResponse.json(makeMe("Admin", { mustChangePassword: true }))));
    const store = createChantierStore();

    await store.dispatch(enhancedApi.endpoints.authMe.initiate());

    expect(store.getState().authentication.mustChangePassword).toBe(true);
  });

  it("considère l'utilisateur déconnecté après un 401, sans permission", async () => {
    server.use(http.get(apiUrl("/auth/me"), () => problem(401, "NON_AUTHENTIFIE")));
    const store = createChantierStore();

    await store.dispatch(enhancedApi.endpoints.authMe.initiate());

    const state = store.getState().authentication;
    expect(state).toMatchObject({ isAuthenticated: false, userId: null, claims: null, isAuthLoading: false });
  });

  it("efface la session après la déconnexion", async () => {
    server.use(
      http.get(apiUrl("/auth/me"), () => HttpResponse.json(makeMe("Admin"))),
      http.post(apiUrl("/auth/logout"), () => new HttpResponse(null, { status: 204 })),
    );
    const store = createChantierStore();
    await store.dispatch(enhancedApi.endpoints.authMe.initiate());
    expect(store.getState().authentication.isAuthenticated).toBe(true);

    await store.dispatch(enhancedApi.endpoints.authLogout.initiate({ logoutRequest: {} }));

    expect(store.getState().authentication).toMatchObject({ isAuthenticated: false, claims: null, mustChangePassword: false });
  });
});
