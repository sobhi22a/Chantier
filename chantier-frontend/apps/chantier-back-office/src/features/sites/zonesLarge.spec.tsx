import { screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import type { ZoneResponse } from "@chantier-frontend/api-core";
import { SITE_UV18_ID, apiUrl, makeSite, makeZone, server, setupMockServer } from "@chantier-frontend/testing";

import { mockSession, renderApp } from "../../testing/renderApp";
import { COLLAPSE_ABOVE_ZONES, ZONES_PER_STEP } from "./components/ZonesByBlock.component";

setupMockServer();
// 5 000 zones chargées par 25 pages dans jsdom : plus long que le délai de test par défaut.
vi.setConfig({ testTimeout: 30_000 });

const detailPath = `/sites/${SITE_UV18_ID}`;

/** `blocks` blocs de `perBlock` zones chacun (cotes de 0 à 9 niveaux, numéros de local croissants). */
const makeZones = (blocks: number, perBlock: number): ZoneResponse[] =>
  Array.from({ length: blocks * perBlock }, (_, index) =>
    makeZone({
      id: `z-${String(index).padStart(5, "0")}`,
      block: `Bloc ${String(Math.floor(index / perBlock) + 1).padStart(2, "0")}`,
      elevation: (Math.floor((index % perBlock) / 50) % 10) * 3.4,
      roomType: "Classroom",
      roomNumber: (index % 50) + 1,
    }),
  );

const mockZones = (zones: ZoneResponse[]) => {
  mockSession("ConducteurTravaux");
  server.use(
    http.get(apiUrl("/sites/:siteId"), () => HttpResponse.json(makeSite())),
    http.get(apiUrl("/sites/:siteId/members"), () => HttpResponse.json({ items: [] })),
    http.get(apiUrl("/sites/:siteId/zones"), ({ request }) => {
      const url = new URL(request.url);
      const offset = Number(url.searchParams.get("cursor") ?? 0);
      const size = Number(url.searchParams.get("pageSize") ?? 50);
      const next = offset + size < zones.length ? String(offset + size) : null;
      return HttpResponse.json({ items: zones.slice(offset, offset + size), nextCursor: next });
    }),
  );
};

// 25 pages de 200 zones chargées une par une par le faux serveur : plus long que le délai par défaut.
const LOADED = { timeout: 20000 };

const zoneLines = (region: HTMLElement) => within(region).queryAllByRole("listitem");

describe("fiche avec beaucoup de zones : repli par bloc et affichage progressif (S-1)", () => {
  afterEach(() => {
    document.documentElement.removeAttribute("lang");
    document.documentElement.removeAttribute("dir");
  });

  it(`garde tous les blocs ouverts jusqu'à ${COLLAPSE_ABOVE_ZONES} zones`, async () => {
    mockZones(makeZones(3, 50));
    renderApp(detailPath);

    const bloc = await screen.findByRole("region", { name: "Bloc 01" }, LOADED);
    expect(zoneLines(bloc)).toHaveLength(50);
    expect(within(bloc).getByRole("button", { name: /^Bloc 01/ }).getAttribute("aria-expanded")).toBe("true");
  });

  it("replie les blocs au-delà du seuil : aucune ligne de zone dans le DOM, mais le nombre de zones par bloc", async () => {
    mockZones(makeZones(10, 500));
    renderApp(detailPath);

    const first = await screen.findByRole("region", { name: "Bloc 01" }, LOADED);
    expect(await screen.findByRole("region", { name: "Bloc 10" }, LOADED)).toBeTruthy();
    expect(within(first).getByRole("button", { name: /^Bloc 01/ }).getAttribute("aria-expanded")).toBe("false");
    expect(within(first).getByText("500 zones")).toBeTruthy();
    expect(screen.queryAllByRole("listitem")).toHaveLength(0);
    // Le DOM reste petit même avec 5 000 zones chargées.
    expect(document.querySelectorAll("*").length).toBeLessThan(2500);
  });

  it(`ouvre un bloc : ${ZONES_PER_STEP} zones d'abord, puis ${ZONES_PER_STEP} de plus à chaque « Afficher plus de zones »`, async () => {
    mockZones(makeZones(10, 500));
    const user = userEvent.setup();
    renderApp(detailPath);
    const bloc = await screen.findByRole("region", { name: "Bloc 02" }, LOADED);

    await user.click(within(bloc).getByRole("button", { name: /^Bloc 02/ }));

    expect(within(bloc).getByRole("button", { name: /^Bloc 02/ }).getAttribute("aria-expanded")).toBe("true");
    expect(zoneLines(bloc)).toHaveLength(ZONES_PER_STEP);
    expect(within(bloc).getByText("100 sur 500 affichées")).toBeTruthy();

    await user.click(within(bloc).getByRole("button", { name: "Afficher plus de zones" }));

    expect(zoneLines(bloc)).toHaveLength(ZONES_PER_STEP * 2);
    expect(within(bloc).getByText("200 sur 500 affichées")).toBeTruthy();
    // Les autres blocs restent repliés.
    expect(zoneLines(screen.getByRole("region", { name: "Bloc 03" }))).toHaveLength(0);
  });

  it("n'affiche plus le bouton quand toutes les zones du bloc sont visibles", async () => {
    mockZones(makeZones(10, 500));
    const user = userEvent.setup();
    renderApp(detailPath);
    const bloc = await screen.findByRole("region", { name: "Bloc 01" }, LOADED);
    await user.click(within(bloc).getByRole("button", { name: /^Bloc 01/ }));

    for (let step = 0; step < 4; step += 1) {
      await user.click(within(bloc).getByRole("button", { name: "Afficher plus de zones" }));
    }

    expect(zoneLines(bloc)).toHaveLength(500);
    expect(within(bloc).queryByRole("button", { name: "Afficher plus de zones" })).toBeNull();
  });

  it("referme un bloc ouvert", async () => {
    mockZones(makeZones(10, 500));
    const user = userEvent.setup();
    renderApp(detailPath);
    const bloc = await screen.findByRole("region", { name: "Bloc 01" }, LOADED);
    const toggle = within(bloc).getByRole("button", { name: /^Bloc 01/ });

    await user.click(toggle);
    expect(zoneLines(bloc).length).toBeGreaterThan(0);
    await user.click(toggle);

    expect(zoneLines(bloc)).toHaveLength(0);
    expect(toggle.getAttribute("aria-expanded")).toBe("false");
  });

  it("garde les zones triées (cote la plus basse d'abord) dans la tranche affichée", async () => {
    mockZones(makeZones(10, 500));
    const user = userEvent.setup();
    renderApp(detailPath);
    const bloc = await screen.findByRole("region", { name: "Bloc 01" }, LOADED);

    await user.click(within(bloc).getByRole("button", { name: /^Bloc 01/ }));

    const lines = zoneLines(bloc).map((item) => item.textContent ?? "");
    expect(lines[0]).toBe("±0,00 m · Classe 01");
    expect(lines[49]).toBe("±0,00 m · Classe 50");
    expect(lines[50]).toBe("+3,40 m · Classe 01");
  });

  it("affiche le bouton et le compteur en arabe, de droite à gauche", async () => {
    mockZones(makeZones(10, 500));
    mockSession("ConducteurTravaux", { language: "ar" });
    const user = userEvent.setup();
    renderApp(detailPath, "ar");
    const bloc = await screen.findByRole("region", { name: "Bloc 01" }, LOADED);

    await user.click(within(bloc).getByRole("button", { name: /^Bloc 01/ }));

    expect(document.documentElement.dir).toBe("rtl");
    expect(within(bloc).getByRole("button", { name: "عرض مناطق أخرى" })).toBeTruthy();
    expect(bloc.textContent).toContain("معروضة");
    const ltr = [...bloc.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent);
    expect(ltr).toEqual(expect.arrayContaining(["±0,00 m"]));
  });
});
