import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import {
  PERMISSIONS_BY_ROLE,
  REQUEST_DEM009_ID,
  SITE_UV18_ID,
  apiUrl,
  makeMe,
  makeRequest,
  makeRequestDetail,
  problem,
  server,
  setupMockServer,
  type TestRole,
} from "@chantier-frontend/testing";

import { mockSession, renderApp } from "../../testing/renderApp";
import { mockMaterialsReads, paged } from "../../testing/materialsMocks";

setupMockServer();

const NBSP = " ";
const detailPath = `/materials/requests/${SITE_UV18_ID}/${REQUEST_DEM009_ID}`;
const ME_ID = makeMe().id;

/** Une quantité affichée « <nombre> unité » : le nombre est isolé (bdi), le texte complet est celui du <span> englobant. */
const quantityMatcher = (text: string) => (_content: string, element: Element | null) =>
  element?.tagName === "SPAN" && element.textContent === text && element.querySelector("bdi") !== null;

afterEach(() => {
  document.documentElement.removeAttribute("lang");
  document.documentElement.removeAttribute("dir");
});

describe("Demandes : liste (CA-MAT-002)", () => {
  it("affiche numéro, chantier, produit, quantité avec unité, zone, pour le, urgence et statut (français)", async () => {
    mockSession("ConducteurTravaux");
    const { listRequests } = mockMaterialsReads({ requests: [makeRequest()] });
    renderApp("/materials/requests");

    const table = await screen.findByRole("table");
    const row = within(table).getAllByRole("row")[1] as HTMLElement;
    await waitFor(() => expect(within(row).getByText("Bloc 01 · +10,20 m")).toBeTruthy());
    const cells = within(row).getAllByRole("cell").map((cell) => cell.textContent);
    expect(cells).toEqual(
      expect.arrayContaining(["DEM-009", "CH-ECO-UV18", "Ciment CPJ 42,5", `300${NBSP}sacs`, "Bloc 01 · +10,20 m", "28/11/2026", "Bloquante", "Demandée"]),
    );
    // La liste par défaut est « À suivre », paginée côté serveur.
    expect(listRequests[0]?.searchParams.get("view")).toBe("toFollow");
    expect(listRequests[0]?.searchParams.get("pageSize")).toBe("20");
    expect(listRequests[0]?.searchParams.get("page")).toBe("1");
  });

  it("affiche la liste en arabe : RTL, statuts et unités traduits, numéro et date de gauche à droite (CA-MAT-001.15)", async () => {
    mockSession("ConducteurTravaux", { language: "ar" });
    mockMaterialsReads({ requests: [makeRequest()] });
    renderApp("/materials/requests", "ar");

    expect(await screen.findByRole("heading", { level: 1, name: "طلبات المواد" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
    const table = await screen.findByRole("table");
    expect(within(table).getByText("تم الطلب")).toBeTruthy();
    expect(within(table).getByText("معطِّلة للورشة")).toBeTruthy();
    expect(within(table).getAllByText("كيس", { exact: false }).length).toBeGreaterThan(0);
    const ltr = [...table.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent);
    expect(ltr).toContain("DEM-009");
    expect(ltr).toContain("28/11/2026");
    expect(ltr).toContain("300");
  });

  it("montre le retard en orange avec son texte (CA-MAT-002.4)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ requests: [makeRequest({ overdueDays: 2 })] });
    renderApp("/materials/requests");

    expect(await screen.findByText("En retard de 2 jours")).toBeTruthy();
  });

  it("garde vue, recherche et tri dans l'URL et les envoie au serveur", async () => {
    mockSession("ConducteurTravaux");
    const { listRequests } = mockMaterialsReads({ requests: [makeRequest()] });
    const user = userEvent.setup();
    const { router } = renderApp("/materials/requests");
    await screen.findByRole("table");

    await user.click(screen.getByText("Terminées"));
    await waitFor(() => expect(router.state.location.search).toContain("view=received"));
    await waitFor(() => expect(listRequests.at(-1)?.searchParams.get("view")).toBe("received"));

    await user.type(screen.getByRole("textbox", { name: "Rechercher" }), "DEM-009");
    await waitFor(() => expect(router.state.location.search).toContain("q=DEM-009"), { timeout: 3000 });
    await waitFor(() => expect(listRequests.at(-1)?.searchParams.get("q")).toBe("DEM-009"));

    await user.click(await screen.findByRole("button", { name: "Trier par Pour le" }));
    await waitFor(() => expect(router.state.location.search).toContain("sort=neededBy"));
    await waitFor(() => expect(listRequests.at(-1)?.searchParams.get("sort")).toBe("neededBy"));
  });

  it("propose « Mes demandes » par défaut au chef d'équipe (CA-MAT-002.5)", async () => {
    mockSession("ChefEquipe");
    const { listRequests } = mockMaterialsReads({ requests: [makeRequest()] });
    renderApp("/materials/requests");

    await screen.findByRole("table");
    expect(listRequests[0]?.searchParams.get("mine")).toBe("true");
    expect((screen.getByRole("checkbox", { name: "Mes demandes" }) as HTMLInputElement).checked).toBe(true);
  });

  it("montre l'état vide, puis l'état d'erreur traduit avec « Réessayer » (français puis arabe)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads();
    server.use(http.get(apiUrl("/requests"), () => HttpResponse.json(paged([]))));
    const first = renderApp("/materials/requests");
    expect(await screen.findByText("Aucune demande dans cette vue.")).toBeTruthy();
    first.unmount();

    mockSession("ConducteurTravaux", { language: "ar" });
    server.use(http.get(apiUrl("/requests"), () => problem(500, "ERREUR_INTERNE")));
    renderApp("/materials/requests", "ar");
    const alert = await screen.findByRole("alert");
    expect(alert.textContent).toContain("خطأ في الخادم");
    expect(within(alert).getByRole("button", { name: "إعادة المحاولة" })).toBeTruthy();
  });

  it.each<[TestRole, boolean]>([
    ["Admin", true],
    ["ConducteurTravaux", true],
    ["ChefChantier", true],
    ["ChefEquipe", true],
    ["Achats", false],
    ["Direction", false],
  ])("%s : bouton « Nouvelle demande » présent = %s (CA-MAT-001.13)", async (role, expected) => {
    mockSession(role);
    mockMaterialsReads();
    renderApp("/materials/requests");
    await screen.findByRole("table");
    expect(screen.queryByRole("button", { name: "Nouvelle demande" }) !== null).toBe(expected);
  });
});

describe("Demandes : tiroir de détail (CA-MAT-002.2)", () => {
  it("montre la quantité, le reçu, le reste et l'écart avec leur unité, et l'historique", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({
      detail: makeRequestDetail({
        status: "PartiallyDelivered",
        quantity: { value: 600, unit: "sac" },
        receivedQuantity: { value: 200, unit: "sac" },
        remainingQuantity: { value: 400, unit: "sac" },
        variance: { value: -400, unit: "sac", percent: -66.67 },
        history: [
          {
            id: "h1",
            type: "QuantityAdjusted",
            fromStatus: null,
            toStatus: null,
            reasonCode: null,
            reasonNote: null,
            changes: [{ field: "quantity", old: "300 sac", new: "200 sac" }],
            actorName: "Karim A.",
            occurredAt: "2026-11-25T09:00:00Z",
            deviceAt: null,
            source: "Api",
          },
          {
            id: "h2",
            type: "Rejected",
            fromStatus: "Requested",
            toStatus: "Rejected",
            reasonCode: "StockSufficient",
            reasonNote: null,
            changes: null,
            actorName: "Karim A.",
            occurredAt: "2026-11-25T09:05:00Z",
            deviceAt: "2026-11-25T08:50:00Z",
            source: "Sync",
          },
        ],
      }),
    });
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    expect(within(drawer).getByText(quantityMatcher(`600${NBSP}sacs`))).toBeTruthy();
    expect(within(drawer).getByText(quantityMatcher(`200${NBSP}sacs`))).toBeTruthy();
    expect(within(drawer).getByText(quantityMatcher(`400${NBSP}sacs`))).toBeTruthy();
    expect(within(drawer).getByText("−66,67 %")).toBeTruthy();
    // Historique : quantité ancienne → nouvelle avec unités, motif traduit, heure du serveur (UTC+1) et « saisi le » du téléphone.
    expect(within(drawer).getByText("300 sacs → 200 sacs", { exact: false })).toBeTruthy();
    expect(within(drawer).getByText("10:00", { exact: false })).toBeTruthy();
    expect(within(drawer).getByText("Motif : Stock suffisant sur le chantier")).toBeTruthy();
    expect(within(drawer).getByText("Saisi hors ligne le 25/11/2026 09:50")).toBeTruthy();
  });

  it("n'affiche jamais de prix ni de montant dans le détail (CA-MAT-009.3)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads();
    renderApp(detailPath);
    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    expect(drawer.textContent).not.toMatch(/DZD|prix|Prix/);
  });

  it("affiche le détail en arabe, de droite à gauche, avec les valeurs de gauche à droite", async () => {
    mockSession("ConducteurTravaux", { language: "ar" });
    mockMaterialsReads();
    renderApp(detailPath, "ar");

    const drawer = await screen.findByRole("dialog", { name: /الطلب/ });
    expect(document.documentElement.dir).toBe("rtl");
    expect(within(drawer).getByText("الكمية المطلوبة")).toBeTruthy();
    expect([...drawer.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent)).toContain("28/11/2026");
  });

  it("signale un chantier non affecté comme introuvable, sans autre détail (CA-MAT-002.8)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads();
    server.use(http.get(apiUrl("/sites/:siteId/requests/:requestId"), () => problem(404, "INTROUVABLE")));
    renderApp(detailPath);

    const alert = await screen.findByRole("alert");
    expect(alert.textContent).toContain("Élément introuvable.");
  });

  // Matrice des actions : (rôle, demande de qui, statut) → boutons présents. Une action interdite est absente, pas grisée.
  const OTHER_USER = "00000000-0000-7000-8000-0000000000ff";
  const labels = ["Valider", "Valider avec une autre quantité", "Refuser", "Modifier", "Annuler la demande", "Archiver", "Restaurer", "Rattacher un produit du catalogue"];

  it.each<[TestRole, string, "own" | "other", Partial<ReturnType<typeof makeRequest>>, string[]]>([
    ["ConducteurTravaux", "demande d'un collègue, Demandée", "other", {}, ["Valider", "Valider avec une autre quantité", "Refuser", "Modifier", "Annuler la demande"]],
    ["Admin", "demande d'un collègue, Demandée", "other", {}, ["Valider", "Valider avec une autre quantité", "Refuser", "Modifier", "Annuler la demande"]],
    ["ChefChantier", "demande d'un collègue, Demandée", "other", {}, ["Modifier"]],
    ["ChefChantier", "sa demande, Demandée", "own", {}, ["Modifier", "Annuler la demande"]],
    ["ChefEquipe", "sa demande, Demandée", "own", {}, ["Modifier", "Annuler la demande"]],
    ["ChefEquipe", "demande d'un collègue", "other", {}, []],
    ["Achats", "demande Demandée", "other", {}, []],
    ["Direction", "demande Demandée", "other", {}, []],
    ["ChefChantier", "demande Validée (date modifiable)", "other", { status: "Validated" }, ["Modifier"]],
    ["ChefEquipe", "sa demande Validée", "own", { status: "Validated" }, ["Annuler la demande"]],
    ["ConducteurTravaux", "demande Commandée", "other", { status: "Ordered" }, ["Modifier"]],
    ["ConducteurTravaux", "demande Refusée", "other", { status: "Rejected" }, ["Archiver"]],
    ["Direction", "demande Refusée", "other", { status: "Rejected" }, []],
    ["ConducteurTravaux", "demande archivée", "other", { status: "Cancelled", archivedAt: "2026-11-26T08:00:00Z", archivedByName: "Karim A." }, ["Restaurer"]],
    ["Achats", "produit libre ouverte", "other", { product: { productId: null, name: null, nameAr: null, freeName: "Poignées de porte" } }, ["Rattacher un produit du catalogue"]],
    ["ChefChantier", "produit libre ouverte", "other", { product: { productId: null, name: null, nameAr: null, freeName: "Poignées de porte" } }, ["Modifier"]],
  ])("%s, %s : actions proposées (CA-MAT-009.1)", async (role, _label, owner, overrides, expected) => {
    mockSession(role);
    mockMaterialsReads({ detail: makeRequestDetail({ requestedById: owner === "own" ? ME_ID : OTHER_USER, ...overrides }) });
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    await within(drawer).findByRole("group", { name: "Actions" });
    // `name` en chaîne est une correspondance exacte : « Valider » ne retrouve pas « Valider avec une autre quantité ».
    const present = labels.filter((label) => within(drawer).queryByRole("button", { name: label }) !== null);
    expect(present.sort()).toEqual([...expected].sort());
    // Sécurité de la table : la liste brute des permissions du rôle est bien celle du contrat.
    expect(PERMISSIONS_BY_ROLE[role].includes("Prices.View")).toBe(role !== "ChefChantier" && role !== "ChefEquipe");
  });

  it("annule avec un motif : « Autre » impose une remarque, puis envoie le motif et traduit le résultat (CA-MAT-004.4)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: makeRequestDetail({ requestedById: ME_ID }) });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/cancel"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ status: "Cancelled", statusReason: { code: "NoLongerNeeded", note: null } }));
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    await user.click(await within(drawer).findByRole("button", { name: "Annuler la demande" }));

    const dialog = await screen.findByRole("dialog", { name: "Annuler la demande DEM-009 ?" });
    // Sans motif : aucun appel.
    await user.click(within(dialog).getByRole("button", { name: "Annuler la demande" }));
    expect(await within(dialog).findByText("Choisissez un motif.")).toBeTruthy();
    expect(bodies).toHaveLength(0);

    // « Autre » sans remarque : refusé côté client.
    await user.click(within(dialog).getByRole("textbox", { name: /Motif/ }));
    await user.click(await screen.findByRole("option", { name: "Autre" }));
    await user.click(within(dialog).getByRole("button", { name: "Annuler la demande" }));
    expect(await within(dialog).findByText("Précisez le motif dans la remarque.")).toBeTruthy();
    expect(bodies).toHaveLength(0);

    await user.click(within(dialog).getByRole("textbox", { name: /Motif/ }));
    await user.click(await screen.findByRole("option", { name: "Plus besoin" }));
    await user.click(within(dialog).getByRole("button", { name: "Annuler la demande" }));
    await waitFor(() => expect(bodies).toEqual([{ reasonCode: "NoLongerNeeded", reasonNote: null }]));
    expect(await screen.findByText("Demande DEM-009 annulée.")).toBeTruthy();
  });

  it("traduit TRANSITION_INTERDITE reçu à l'annulation d'une demande déjà commandée (CA-MAT-004.5)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ detail: makeRequestDetail({ status: "Validated" }) });
    server.use(http.post(apiUrl("/sites/:siteId/requests/:requestId/cancel"), () => problem(422, "TRANSITION_INTERDITE")));
    const user = userEvent.setup();
    renderApp(detailPath);
    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    await user.click(await within(drawer).findByRole("button", { name: "Annuler la demande" }));
    const dialog = await screen.findByRole("dialog", { name: "Annuler la demande DEM-009 ?" });
    await user.click(within(dialog).getByRole("textbox", { name: /Motif/ }));
    await user.click(await screen.findByRole("option", { name: "Doublon" }));
    await user.click(within(dialog).getByRole("button", { name: "Annuler la demande" }));

    expect((await within(dialog).findByRole("alert")).textContent).toContain("Ce changement de statut n'est pas autorisé.");
  });
});
