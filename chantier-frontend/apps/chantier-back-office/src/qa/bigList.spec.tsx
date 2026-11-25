import { screen } from "@testing-library/react";
import { http, HttpResponse } from "msw";

import { SITE_UV18_ID, apiUrl, makeMember, makeSite, makeZone, server, setupMockServer } from "@chantier-frontend/testing";

import { mockSession, renderApp } from "../testing/renderApp";

setupMockServer();

/**
 * Q1 : une fiche chantier avec 5 000 zones (10 blocs) reste utilisable : toutes les zones sont chargées par pages de 200
 * (curseur) et le dernier bloc apparaît. Seuil volontairement large (jsdom est lent) ; le nombre de noeuds DOM est journalisé (voir défaut D-6 du rapport).
 */
describe("grande liste : fiche d'un chantier de 5 000 zones", () => {
  afterEach(() => {
    document.documentElement.removeAttribute("lang");
    document.documentElement.removeAttribute("dir");
  });

  it("charge les 25 pages et affiche le dernier bloc sans dépasser le seuil", async () => {
    const total = 5000;
    const zones = Array.from({ length: total }, (_, index) =>
      makeZone({
        id: `z-${String(index).padStart(5, "0")}`,
        block: `Bloc ${String(Math.floor(index / 500) + 1).padStart(2, "0")}`,
        elevation: (Math.floor(index / 50) % 10) * 3.4 - 1.9,
        roomType: "Classroom",
        roomNumber: (index % 50) + 1,
      }),
    );
    let pages = 0;
    mockSession("ConducteurTravaux");
    server.use(
      http.get(apiUrl("/sites/:siteId"), () => HttpResponse.json(makeSite())),
      http.get(apiUrl("/sites/:siteId/members"), () => HttpResponse.json({ items: [makeMember()] })),
      http.get(apiUrl("/sites/:siteId/zones"), ({ request }) => {
        pages += 1;
        const url = new URL(request.url);
        const offset = Number(url.searchParams.get("cursor") ?? 0);
        const size = Number(url.searchParams.get("pageSize") ?? 50);
        const items = zones.slice(offset, offset + size);
        const next = offset + size < total ? String(offset + size) : null;
        return HttpResponse.json({ items, nextCursor: next });
      }),
    );

    const started = performance.now();
    renderApp(`/sites/${SITE_UV18_ID}`);
    await screen.findByRole("heading", { level: 1, name: "École UV18" });
    await screen.findAllByText("Bloc 10", {}, { timeout: 60_000 });
    const elapsed = performance.now() - started;

    console.info(`QA 5000 zones : ${pages} appels, rendu en ${Math.round(elapsed)} ms, ${document.querySelectorAll("*").length} noeuds DOM`);
    expect(pages).toBeGreaterThanOrEqual(25);
    expect(elapsed).toBeLessThan(60_000);
  }, 120_000);
});
