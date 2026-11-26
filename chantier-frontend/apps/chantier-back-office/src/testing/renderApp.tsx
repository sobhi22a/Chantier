import { render, type RenderResult } from "@testing-library/react";
import { http, HttpResponse } from "msw";
import { createMemoryRouter, RouterProvider } from "react-router-dom";

import { setAcceptLanguageProvider, type MeResponse } from "@chantier-frontend/api-core";
import { createI18n, type Language } from "@chantier-frontend/i18n";
import { createChantierStore } from "@chantier-frontend/state-store";
import { apiUrl, makeMe, problem, server, type TestRole } from "@chantier-frontend/testing";

import { AppProviders, backOfficeRoutes } from "../app/providers";

/** `GET /auth/me` répond avec ce profil ; `null` : aucune session (401). */
export const mockSession = (role: TestRole | null, overrides: Partial<MeResponse> = {}) => {
  server.use(
    http.get(apiUrl("/auth/me"), () => (role ? HttpResponse.json(makeMe(role, overrides)) : problem(401, "NON_AUTHENTIFIE"))),
  );
};

export interface RenderedApp extends RenderResult {
  router: ReturnType<typeof createMemoryRouter>;
  store: ReturnType<typeof createChantierStore>;
}

/** L'application complète (fournisseurs, routes, faux serveur MSW) à une adresse donnée. */
export const renderApp = (path: string, language: Language = "fr"): RenderedApp => {
  const i18nInstance = createI18n(language, { persist: false });
  setAcceptLanguageProvider(() => i18nInstance.language);
  const router = createMemoryRouter(backOfficeRoutes, { initialEntries: [path] });
  const store = createChantierStore();
  const result = render(
    <AppProviders i18nInstance={i18nInstance} store={store} mantineEnv="test">
      <RouterProvider router={router} />
    </AppProviders>,
  );
  return { ...result, router, store };
};
