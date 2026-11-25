import { HttpResponse } from "msw";
import { setupServer } from "msw/node";

/** Base de l'API dans les tests (`test.env.VITE_BACKEND_API_BASE_URL` des vite.config). */
export const API_BASE_URL = "http://api.test";

/** URL absolue d'une route `/api/v1` : `apiUrl("/sites/:siteId")`. */
export const apiUrl = (path: string): string => `${API_BASE_URL}/api/v1${path}`;

/** Réponse d'erreur Problem Details (RFC 9457) comme celle du serveur. */
export const problem = (status: number, code: string, extra: Record<string, unknown> = {}) =>
  HttpResponse.json(
    { type: `https://chantier.local/errors/${code.toLowerCase()}`, title: "Erreur", status, code, traceId: "00-test-trace", ...extra },
    { status, headers: { "Content-Type": "application/problem+json" } },
  );

export const server = setupServer();

/**
 * À appeler en haut d'un fichier de test : démarre le faux serveur et refuse toute requête non prévue
 * (un test qui oublie un handler échoue au lieu d'appeler le réseau).
 */
export const setupMockServer = (): typeof server => {
  beforeAll(() => server.listen({ onUnhandledRequest: "error" }));
  afterEach(() => server.resetHandlers());
  afterAll(() => server.close());
  return server;
};
