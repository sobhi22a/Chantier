import { configureStore } from "@reduxjs/toolkit";
import { renderHook } from "@testing-library/react";
import { http, HttpResponse } from "msw";
import { setupServer } from "msw/node";
import type { ReactNode } from "react";
import { I18nextProvider } from "react-i18next";

import { createI18n, type Language } from "@chantier-frontend/i18n";

import { enhancedApi } from "./enhancedApi";
import { ApplicationApiService, setAcceptLanguageProvider } from "./ApplicationApi.service";
import { isApiError, type ApiError } from "./apiError";
import { networkActivityReducer } from "./networkActivity.slice";
import { useApiErrorMessage } from "./useApiErrorMessage";

const BASE = "http://api.test/api/v1";
const SITE_ID = "00000000-0000-7000-8000-0000000000a1";

const problem = (status: number, code: string, extra: Record<string, unknown> = {}) =>
  HttpResponse.json(
    { type: "https://chantier.local/errors/x", title: "Erreur", status, code, traceId: "00-trace-123", ...extra },
    { status, headers: { "Content-Type": "application/problem+json" } },
  );

const server = setupServer();

const createStore = () =>
  configureStore({
    reducer: {
      networkActivity: networkActivityReducer,
      [ApplicationApiService.reducerPath]: ApplicationApiService.reducer,
    },
    middleware: (getDefault) => getDefault().concat(ApplicationApiService.middleware),
  });

const newZone = { block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 2 } as const;

describe("client d'API généré : erreurs Problem Details", () => {
  beforeAll(() => server.listen({ onUnhandledRequest: "error" }));
  afterEach(() => {
    server.resetHandlers();
    setAcceptLanguageProvider(() => "fr");
  });
  afterAll(() => server.close());

  const createZone = async (store = createStore()) => {
    const result = await store.dispatch(
      enhancedApi.endpoints.zonesCreate.initiate({ siteId: SITE_ID, createZoneRequest: newZone }),
    );
    return "error" in result ? result.error : undefined;
  };

  it("normalise une erreur 422 ZONE_EXISTANTE en ApiError (statut, code, traceId)", async () => {
    server.use(http.post(`${BASE}/sites/${SITE_ID}/zones`, () => problem(422, "ZONE_EXISTANTE")));

    const error = await createZone();

    expect(isApiError(error)).toBe(true);
    expect(error).toMatchObject({ status: 422, code: "ZONE_EXISTANTE", traceId: "00-trace-123" });
  });

  it.each([
    ["fr", "Cette zone existe déjà."],
    ["ar", "هذه المنطقة موجودة من قبل."],
  ] as const)("traduit ZONE_EXISTANTE en %s depuis le code (CT-5, CT-11)", async (language: Language, expected: string) => {
    server.use(http.post(`${BASE}/sites/${SITE_ID}/zones`, () => problem(422, "ZONE_EXISTANTE", { detail: "texte du serveur" })));
    const error = await createZone();
    const i18n = createI18n(language, { persist: false, syncDocument: false });
    const wrapper = ({ children }: { children: ReactNode }) => <I18nextProvider i18n={i18n}>{children}</I18nextProvider>;

    const { result } = renderHook(() => useApiErrorMessage(), { wrapper });

    expect(result.current.getMessage(error)).toBe(expected);
    expect(result.current.getMessage(error)).not.toContain("texte du serveur");
  });

  it("affiche un message générique et la référence pour un code inconnu du client", async () => {
    server.use(http.post(`${BASE}/sites/${SITE_ID}/zones`, () => problem(422, "CODE_FUTUR_INCONNU")));
    const error = await createZone();
    const i18n = createI18n("fr", { persist: false, syncDocument: false });
    const wrapper = ({ children }: { children: ReactNode }) => <I18nextProvider i18n={i18n}>{children}</I18nextProvider>;

    const { result } = renderHook(() => useApiErrorMessage(), { wrapper });

    expect(result.current.getMessage(error)).toBe("Une erreur inattendue est survenue.");
    expect(result.current.getReference(error)).toBe("Référence pour le support : 00-trace-123");
  });

  it("distingue le réseau coupé d'une erreur du serveur", async () => {
    server.use(http.post(`${BASE}/sites/${SITE_ID}/zones`, () => HttpResponse.error()));
    expect(await createZone()).toMatchObject({ status: "NETWORK", code: "NETWORK" });
  });

  it("déduit un code du statut quand la réponse n'est pas un Problem Details", async () => {
    server.use(http.post(`${BASE}/sites/${SITE_ID}/zones`, () => new HttpResponse(null, { status: 404 })));
    expect(await createZone()).toMatchObject({ status: 404, code: "INTROUVABLE" });

    server.use(http.post(`${BASE}/sites/${SITE_ID}/zones`, () => new HttpResponse("<html>boom</html>", { status: 502 })));
    const error = (await createZone()) as ApiError;
    expect(error).toMatchObject({ status: 502, code: "ERREUR_INTERNE" });
    expect(JSON.stringify(error)).not.toContain("boom");
  });

  it("garde le détail par champ d'un 400 VALIDATION", async () => {
    server.use(
      http.post(`${BASE}/sites/${SITE_ID}/zones`, () =>
        problem(400, "VALIDATION", { errors: { block: ["Le bloc est obligatoire."] } }),
      ),
    );
    expect(await createZone()).toMatchObject({ code: "VALIDATION", errors: { block: ["Le bloc est obligatoire."] } });
  });

  it("garde l'état courant d'un 409 CONFLIT_VERSION", async () => {
    server.use(
      http.put(`${BASE}/sites/${SITE_ID}`, () => problem(409, "CONFLIT_VERSION", { current: { updatedByName: "Farid L." } })),
    );
    const store = createStore();
    const result = await store.dispatch(
      enhancedApi.endpoints.sitesUpdate.initiate({
        siteId: SITE_ID,
        updateSiteRequest: { version: "1", name: "x", type: "School", wilaya: "Blida", commune: "Boufarik", owner: "o" },
      }),
    );
    expect("error" in result && result.error).toMatchObject({ status: 409, code: "CONFLIT_VERSION", current: { updatedByName: "Farid L." } });
  });

  it("envoie Accept-Language et le cookie de session", async () => {
    let acceptLanguage: string | null = null;
    let credentials: RequestCredentials | undefined;
    server.use(
      http.get(`${BASE}/auth/me`, ({ request }) => {
        acceptLanguage = request.headers.get("accept-language");
        credentials = request.credentials;
        return problem(401, "NON_AUTHENTIFIE");
      }),
    );
    setAcceptLanguageProvider(() => "ar");

    await createStore().dispatch(enhancedApi.endpoints.authMe.initiate());

    expect(acceptLanguage).toBe("ar");
    expect(credentials).toBe("include");
  });

  it("relit le profil quand une requête reçoit 401 (session expirée), sans boucle sur /auth/me", async () => {
    let meCalls = 0;
    server.use(
      http.get(`${BASE}/auth/me`, () => {
        meCalls += 1;
        return HttpResponse.json({ id: "x", userName: "u", fullName: "n", phoneNumber: null, role: "ChefChantier", language: "fr", permissions: [], permissionsVersion: "v", mustChangePassword: false });
      }),
      http.get(`${BASE}/sites`, () => problem(401, "NON_AUTHENTIFIE")),
    );
    const store = createStore();
    const subscription = store.dispatch(enhancedApi.endpoints.authMe.initiate());
    await subscription;
    expect(meCalls).toBe(1);

    await store.dispatch(enhancedApi.endpoints.sitesList.initiate({}));
    await vi.waitFor(() => expect(meCalls).toBe(2));
    subscription.unsubscribe();
  });
});
