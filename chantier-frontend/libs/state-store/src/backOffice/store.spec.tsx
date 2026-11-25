import { act, renderHook } from "@testing-library/react";
import type { ReactNode } from "react";
import { Provider } from "react-redux";

import { apiCallStarted } from "@chantier-frontend/api-core";

import { useAppChantierSelector } from "./hooks";
import {
  authSliceReducer,
  claimsFromPermissions,
  deleteUserAuthenticationInfo,
  initialAuthState,
  setUserAuthenticationInfo,
  setUserClaims,
} from "./slices/authenticationSlice";
import { createChantierStore } from "./store";

describe("tranche authentication", () => {
  it("démarre non authentifiée, en cours de chargement", () => {
    expect(initialAuthState).toEqual({
      isAuthLoading: true,
      isClaimsLoading: true,
      userId: null,
      isAuthenticated: false,
      mustChangePassword: false,
      claims: null,
    });
  });

  it("enregistre l'identité puis l'efface à la déconnexion", () => {
    const signedIn = authSliceReducer(initialAuthState, setUserAuthenticationInfo({ userId: "0192-test" }));
    expect(signedIn.isAuthenticated).toBe(true);
    expect(signedIn.userId).toBe("0192-test");

    const signedOut = authSliceReducer(signedIn, deleteUserAuthenticationInfo());
    expect(signedOut.isAuthenticated).toBe(false);
    expect(signedOut.userId).toBeNull();
  });

  it("garde les permissions au format { ressource: { View, Create, Update, Delete } }", () => {
    const claims = { Sites: { View: true, Create: false, Update: false, Delete: false } };
    expect(authSliceReducer(initialAuthState, setUserClaims({ claims })).claims).toEqual(claims);
  });
});

describe("magasin Chantier", () => {
  it("contient la session, l'activité réseau et le cache RTK Query", () => {
    expect(Object.keys(createChantierStore().getState()).sort()).toEqual([
      "ApplicationApi",
      "authentication",
      "networkActivity",
    ]);
  });

  it("donne des hooks typés liés au magasin", () => {
    const store = createChantierStore();
    const wrapper = ({ children }: { children: ReactNode }) => <Provider store={store}>{children}</Provider>;
    const selectActiveRequests = (state: ReturnType<typeof store.getState>) => state.networkActivity.activeRequests;

    const before = renderHook(() => useAppChantierSelector(selectActiveRequests), { wrapper });
    expect(before.result.current).toBe(0);

    act(() => {
      store.dispatch(apiCallStarted());
    });
    expect(before.result.current).toBe(1);
  });
});

describe("claimsFromPermissions", () => {
  it("range la liste du serveur au format { ressource: { View, Create, Update, Delete } }", () => {
    expect(claimsFromPermissions(["Sites.View", "Zones.View", "Zones.Create", "ContractAmount.View"])).toEqual({
      Sites: { View: true, Create: false, Update: false, Delete: false },
      Zones: { View: true, Create: true, Update: false, Delete: false },
      ContractAmount: { View: true, Create: false, Update: false, Delete: false },
    });
  });

  it("ignore les permissions mal formées ou d'action inconnue", () => {
    expect(claimsFromPermissions(["Sites", "Sites.Explode", ".View", "Sites."])).toEqual({});
  });

  it("renvoie un objet vide sans permission", () => {
    expect(claimsFromPermissions([])).toEqual({});
  });
});
