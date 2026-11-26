import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import {
  SITE_UV18_ID,
  apiUrl,
  makeFollowUp,
  makeOrder,
  makeRequest,
  makeSite,
  makeZone,
  problem,
  server,
  setupMockServer,
  type TestRole,
} from "@chantier-frontend/testing";

import { mockMaterialsReads, paged } from "../../testing/materialsMocks";
import { mockSession, renderApp } from "../../testing/renderApp";

setupMockServer();

const NBSP = String.fromCharCode(160);
const path = `/materials/follow-up?siteId=${SITE_UV18_ID}`;

afterEach(() => {
  document.documentElement.removeAttribute("lang");
  document.documentElement.removeAttribute("dir");
});

describe("Suivi d'un chantier : cinq vues et compteurs (CA-MAT-013.1)", () => {
  it("affiche les cinq compteurs du serveur et liste la vue choisie par le serveur (jamais recalculée ici)", async () => {
    mockSession("ConducteurTravaux");
    const { siteRequests, followUpCalls } = mockMaterialsReads({ requests: [makeRequest()] });
    const user = userEvent.setup();
    renderApp(path);

    expect(await screen.findByRole("heading", { level: 1, name: "Suivi des approvisionnements" })).toBeTruthy();
    const group = await screen.findByRole("group", { name: "Vue" });
    for (const [label, count] of [["À valider", 2], ["À commander", 1], ["Attendues", 3], ["En retard", 1], ["À réceptionner", 1]] as const) {
      expect(within(group).getByRole("button", { name: `${label} : ${count}` })).toBeTruthy();
    }
    expect(followUpCalls).toContain(SITE_UV18_ID);
    await waitFor(() => expect(siteRequests[0]?.searchParams.get("view")).toBe("toApprove"));

    await user.click(within(group).getByRole("button", { name: "En retard : 1" }));
    await waitFor(() => expect(siteRequests.at(-1)?.searchParams.get("view")).toBe("late"));
    expect(await screen.findByRole("heading", { level: 2, name: "Demandes en retard" })).toBeTruthy();
  });

  it("garde la vue dans l'adresse et montre fournisseur, date prévue dépassée et retard en orange avec texte (CA-MAT-013.5)", async () => {
    mockSession("Achats");
    const late = makeRequest({
      status: "Ordered",
      overdueDays: 2,
      order: makeOrder({ expectedDeliveryDate: "2026-11-20" }),
    });
    const { siteRequests } = mockMaterialsReads({ requests: [late] });
    renderApp(`${path}&view=late`);

    const table = await screen.findByRole("table");
    expect(siteRequests[0]?.searchParams.get("view")).toBe("late");
    expect(within(table).getByText("En retard de 2 jours")).toBeTruthy();
    expect(within(table).getByText("Cimenterie Sigma (fictive)")).toBeTruthy();
    expect(within(table).getByText("20/11/2026")).toBeTruthy();
    expect(within(table).getByText("Livraison prévue dépassée")).toBeTruthy();
  });

  it("« À commander » : totaux par produit et par unité tels que le serveur les renvoie, 400 sacs = 20 T (CA-MAT-013.2, 013.3)", async () => {
    mockSession("Achats");
    mockMaterialsReads({
      requests: [makeRequest({ status: "Validated" })],
      followUp: makeFollowUp({
        toOrderTotals: [
          { productId: "a", name: "Ciment CPJ 42,5", total: { value: 400, unit: "sac" }, massEquivalent: { value: 20, unit: "t" }, requestCount: 3 },
          { productId: "b", name: "Rond HA Ø12", total: { value: 2.5, unit: "t" }, massEquivalent: null, requestCount: 2 },
          { productId: "c", name: "Sable 0/3", total: { value: 24, unit: "m3" }, massEquivalent: null, requestCount: 1 },
          { productId: "c", name: "Sable 0/3", total: { value: 10, unit: "t" }, massEquivalent: null, requestCount: 1 },
        ],
      }),
    });
    renderApp(`${path}&view=toOrder`);

    const totals = await screen.findByRole("region", { name: "Totaux à commander" });
    const text = within(totals).getAllByRole("row").map((row) => row.textContent);
    expect(text).toHaveLength(5);
    expect(text[1]).toContain(`400${NBSP}sacs`);
    expect(text[1]).toContain(`20${NBSP}T`);
    expect(text[3]).toContain(`24${NBSP}m³`);
    expect(text[4]).toContain(`10${NBSP}T`);
  });

  it("montre les montants du chantier seulement quand le serveur les fournit : Direction oui, chef de chantier non (CA-MAT-013.4)", async () => {
    mockSession("Direction");
    mockMaterialsReads({ requests: [] });
    const first = renderApp(path);
    const amounts = await screen.findByRole("group", { name: "Montants du chantier" });
    expect(within(amounts).getByText(/2.206.000,00.DZD/)).toBeTruthy();
    expect(within(amounts).getByText(/1.950.000,00.DZD/)).toBeTruthy();
    first.unmount();

    mockSession("ChefChantier");
    mockMaterialsReads({ requests: [], followUp: makeFollowUp({ commercial: undefined }) });
    renderApp(path);
    await screen.findByRole("group", { name: "Vue" });
    expect(screen.queryByRole("group", { name: "Montants du chantier" })).toBeNull();
    expect(document.body.textContent).not.toMatch(/DZD/);
  });

  it("demande de choisir un chantier quand l'utilisateur en a plusieurs ; prend le seul chantier d'office", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads();
    const first = renderApp("/materials/follow-up");
    expect(await screen.findByText("Choisissez un chantier pour voir son suivi.")).toBeTruthy();
    first.unmount();

    mockSession("ConducteurTravaux");
    const { followUpCalls } = mockMaterialsReads({ sites: [makeSite()] });
    renderApp("/materials/follow-up");
    await screen.findByRole("group", { name: "Vue" });
    expect(followUpCalls).toEqual([SITE_UV18_ID]);
  });

  it("affiche l'état vide et l'état d'erreur de la vue", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ requests: [] });
    const first = renderApp(path);
    expect(await screen.findByText("Aucune demande dans cette vue.")).toBeTruthy();
    first.unmount();

    mockSession("ConducteurTravaux");
    mockMaterialsReads();
    server.use(http.get(apiUrl("/sites/:siteId/requests"), () => problem(500, "ERREUR_INTERNE")));
    renderApp(path);
    expect(await screen.findByText(/Erreur du serveur/)).toBeTruthy();
  });

  it("propose l'archivage des demandes terminées (lots de 100 de la liste des demandes) et leur restauration", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ requests: [] });
    renderApp(path);

    const open = await screen.findByRole("link", { name: "Archiver des demandes terminées" });
    expect(open.getAttribute("href")).toBe(`/materials/requests?siteId=${SITE_UV18_ID}&view=received`);
    expect(screen.getByRole("link", { name: "Voir les demandes archivées" }).getAttribute("href")).toContain("view=archived");
  });

  it("affiche le suivi en arabe : RTL, compteurs et vues traduits, chiffres de gauche à droite (CA-MAT-020)", async () => {
    mockSession("ConducteurTravaux", { language: "ar" });
    mockMaterialsReads({ requests: [makeRequest()] });
    renderApp(path, "ar");

    expect(await screen.findByRole("heading", { level: 1, name: "متابعة التموين" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
    const group = await screen.findByRole("group", { name: "العرض" });
    expect(within(group).getByRole("button", { name: "بانتظار المصادقة: 2" })).toBeTruthy();
    expect(within(group).getByRole("button", { name: "المتأخرة: 1" })).toBeTruthy();
    const ltr = [...group.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent);
    expect(ltr).toEqual(["2", "1", "3", "1", "1"]);
  });
});

describe("Accès au suivi (CA-MAT-013.8)", () => {
  it.each<[TestRole, boolean]>([
    ["Admin", true],
    ["Direction", true],
    ["ConducteurTravaux", true],
    ["Achats", true],
    ["ChefChantier", true],
    ["ChefEquipe", false],
  ])("%s : entrée « Suivi » du menu = %s", async (role, visible) => {
    mockSession(role);
    mockMaterialsReads({ requests: [] });
    renderApp(path);

    if (visible) {
      expect(await screen.findByRole("heading", { level: 1, name: "Suivi des approvisionnements" })).toBeTruthy();
      expect(screen.getAllByRole("link", { name: "Suivi" }).length).toBeGreaterThan(0);
    } else {
      expect(await screen.findByText("Accès non autorisé")).toBeTruthy();
      expect(screen.queryByRole("link", { name: "Suivi" })).toBeNull();
    }
  });
});

describe("Libellés de zone sans une lecture par ligne (revue R2-06)", () => {
  const numbered = (count: number) =>
    Array.from({ length: count }, (_, index) =>
      makeRequest({
        id: `00000000-0000-7000-8000-${String(index + 1).padStart(12, "0")}`,
        number: `DEM-${String(index + 1).padStart(3, "0")}`,
        zoneId: index % 2 === 0 ? "00000000-0000-7000-8000-0000000000b1" : "00000000-0000-7000-8000-0000000000b2",
      }),
    );

  it("lit les zones d'un chantier par pages groupées : une liste de 50 demandes ne fait aucun GET /zones/{id}", async () => {
    mockSession("ConducteurTravaux");
    const zones = [makeZone(), makeZone({ id: "00000000-0000-7000-8000-0000000000b2", block: "Bloc 02", elevation: 0, roomType: null, roomNumber: null })];
    mockMaterialsReads({ requests: numbered(50), totalCount: 50, zones });
    let listCalls = 0;
    let singleCalls = 0;
    server.use(
      http.get(apiUrl("/sites/:siteId/zones"), () => {
        listCalls += 1;
        return HttpResponse.json({ items: zones, nextCursor: null });
      }),
      http.get(apiUrl("/sites/:siteId/zones/:zoneId"), () => {
        singleCalls += 1;
        return HttpResponse.json(zones[0]);
      }),
    );
    renderApp("/materials/to-approve");

    const table = await screen.findByRole("table");
    await waitFor(() => expect(within(table).getAllByText(/Bloc 02/).length).toBe(25));
    expect(within(table).getAllByText(/Bloc 01/).length).toBe(25);
    expect(listCalls).toBe(1);
    expect(singleCalls).toBe(0);
  });

  it("retombe sur la lecture d'une seule zone quand elle manque à l'annuaire (chantier de plus de 1 000 zones)", async () => {
    mockSession("ConducteurTravaux");
    const missing = makeZone({ id: "00000000-0000-7000-8000-0000000000b9", block: "Bloc 09", elevation: 3.4, roomType: null, roomNumber: null });
    mockMaterialsReads({ requests: [makeRequest({ zoneId: missing.id })], zones: [] });
    const singles: string[] = [];
    server.use(
      http.get(apiUrl("/sites/:siteId/zones"), () => HttpResponse.json({ items: [], nextCursor: null })),
      http.get(apiUrl("/sites/:siteId/zones/:zoneId"), ({ params }) => {
        singles.push(String(params["zoneId"]));
        return HttpResponse.json(missing);
      }),
    );
    renderApp("/materials/to-approve");

    expect(await screen.findByText(/Bloc 09/)).toBeTruthy();
    expect(singles).toEqual([missing.id]);
  });

  it("garde les valeurs inutiles hors de portée : la demande n'a pas de zone, aucun appel", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ requests: [makeRequest({ zoneId: null })] });
    let calls = 0;
    server.use(
      http.get(apiUrl("/sites/:siteId/zones"), () => {
        calls += 1;
        return HttpResponse.json(paged([]));
      }),
    );
    renderApp("/materials/to-approve");

    expect(await screen.findByText("Non précisée")).toBeTruthy();
    expect(calls).toBe(0);
  });
});
