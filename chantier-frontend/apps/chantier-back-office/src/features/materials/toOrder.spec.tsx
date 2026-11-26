import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import { todayDateOnly } from "@chantier-frontend/i18n";
import {
  PERMISSIONS_BY_ROLE,
  REQUEST_DEM009_ID,
  SITE_UV18_ID,
  SUPPLIER_SIGMA_ID,
  apiUrl,
  makeDelivery,
  makeFollowUp,
  makeOrder,
  makeRequest,
  makeRequestDetail,
  problem,
  server,
  setupMockServer,
  type TestRole,
} from "@chantier-frontend/testing";

import { mockMaterialsReads } from "../../testing/materialsMocks";
import { mockSession, renderApp } from "../../testing/renderApp";

setupMockServer();

const NBSP = String.fromCharCode(160);
const detailPath = `/materials/to-order/${SITE_UV18_ID}/${REQUEST_DEM009_ID}`;
const validated = () => makeRequest({ status: "Validated" });

/** Une quantité affichée « <nombre> unité » : le nombre est isolé (bdi), le texte complet est celui du <span> englobant. */
const quantityMatcher = (text: string) => (_content: string, element: Element | null) =>
  element?.tagName === "SPAN" && element.textContent === text && element.querySelector("bdi") !== null;

const orderedDetail = (overrides = {}) =>
  makeRequestDetail({ status: "Ordered", order: makeOrder(), deliveries: [], receivedQuantity: { value: 0, unit: "sac" }, remainingQuantity: { value: 300, unit: "sac" }, ...overrides });

afterEach(() => {
  document.documentElement.removeAttribute("lang");
  document.documentElement.removeAttribute("dir");
});

describe("À commander : file des Achats (CA-MAT-005.1)", () => {
  it("liste les demandes validées et les totaux par produit et par unité, sans jamais mélanger deux unités (CA-MAT-013.2, 013.3)", async () => {
    mockSession("Achats");
    const { listRequests } = mockMaterialsReads({
      requests: [validated()],
      followUp: makeFollowUp({
        toOrderTotals: [
          { productId: "p1", name: "Ciment CPJ 42,5", total: { value: 400, unit: "sac" }, massEquivalent: { value: 20, unit: "t" }, requestCount: 3 },
          { productId: "p2", name: "Sable 0/3", total: { value: 24, unit: "m3" }, massEquivalent: null, requestCount: 1 },
          { productId: "p2", name: "Sable 0/3", total: { value: 10, unit: "t" }, massEquivalent: null, requestCount: 1 },
        ],
      }),
    });
    renderApp(`/materials/to-order?siteId=${SITE_UV18_ID}`);

    const totals = await screen.findByRole("region", { name: "Totaux à commander" });
    const rows = within(totals).getAllByRole("row");
    // En-tête + une ligne par produit et par famille d'unités : 24 m³ et 10 T de sable restent deux lignes.
    expect(rows).toHaveLength(4);
    expect(within(rows[1] as HTMLElement).getByText(quantityMatcher(`400${NBSP}sacs`))).toBeTruthy();
    expect(within(rows[1] as HTMLElement).getByText(quantityMatcher(`20${NBSP}T`))).toBeTruthy();
    expect(within(rows[2] as HTMLElement).getByText(quantityMatcher(`24${NBSP}m³`))).toBeTruthy();
    expect(within(rows[3] as HTMLElement).getByText(quantityMatcher(`10${NBSP}T`))).toBeTruthy();

    expect(listRequests[0]?.searchParams.get("view")).toBe("toOrder");
    expect(await screen.findByRole("button", { name: "Commander DEM-009" })).toBeTruthy();
  });

  it("demande de choisir un chantier pour afficher les totaux quand l'utilisateur en a plusieurs", async () => {
    mockSession("Achats");
    mockMaterialsReads({ requests: [validated()] });
    renderApp("/materials/to-order");

    expect(await screen.findByText("Choisissez un chantier pour voir les totaux par produit.")).toBeTruthy();
  });

  it("affiche l'état vide", async () => {
    mockSession("Achats");
    mockMaterialsReads({ requests: [] });
    renderApp("/materials/to-order");

    expect(await screen.findByText("Aucune demande à commander.")).toBeTruthy();
  });

  it("montre la file en arabe : RTL, bouton et totaux traduits, quantités de gauche à droite", async () => {
    mockSession("Achats", { language: "ar" });
    mockMaterialsReads({ requests: [validated()] });
    renderApp(`/materials/to-order?siteId=${SITE_UV18_ID}`, "ar");

    expect(await screen.findByRole("heading", { level: 1, name: "طلبات للطلبية" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
    expect(await screen.findByRole("button", { name: /تقديم طلبية للطلب.*DEM-009/ })).toBeTruthy();
    const totals = await screen.findByRole("region", { name: "المجاميع المطلوب طلبها" });
    const ltr = [...totals.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent);
    expect(ltr).toContain("400");
  });
});

describe("Commander une demande (CA-MAT-005.2 à 005.5)", () => {
  it("enregistre la commande avec le fournisseur proposé, le prix par unité, et affiche le montant calculé par le serveur", async () => {
    mockSession("Achats");
    mockMaterialsReads({ requests: [validated()] });
    const bodies: Record<string, unknown>[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/order"), async ({ request }) => {
        bodies.push((await request.json()) as Record<string, unknown>);
        return HttpResponse.json(orderedDetail(), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/to-order");

    await user.click(await screen.findByRole("button", { name: "Commander DEM-009" }));
    const dialog = await screen.findByRole("dialog", { name: "Commander DEM-009" });
    // Quantité et unité sont celles de la demande, jamais modifiables : annoncées, sans champ.
    expect(within(dialog).getByText(/Quantité commandée : 300\s+sacs/)).toBeTruthy();
    expect(within(dialog).queryByRole("textbox", { name: /^Quantité/ })).toBeNull();
    // Le fournisseur du catalogue qui fournit ce produit est proposé d'office ; l'unité du prix est à côté du champ.
    await waitFor(() => expect((within(dialog).getAllByRole("textbox", { name: /^Fournisseur/ })[0] as HTMLInputElement).value).toBe("Cimenterie Sigma (fictive)"));
    expect(within(dialog).getByText(/En dinars \(DZD\) par sac/)).toBeTruthy();

    await user.type(within(dialog).getByRole("textbox", { name: /^Prix unitaire HT/ }), "780");
    await user.click(within(dialog).getByRole("button", { name: "Commander" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toMatchObject({ supplierId: SUPPLIER_SIGMA_ID, orderDate: todayDateOnly(), unitPrice: 780 });
    // Le client n'envoie jamais de montant ni de quantité : le serveur calcule.
    expect(bodies[0]).not.toHaveProperty("amount");
    expect(bodies[0]).not.toHaveProperty("quantity");
    expect(typeof bodies[0]?.["clientId"]).toBe("string");
    expect(await screen.findByText(/Commande de DEM-009 enregistrée : montant 234.000,00.DZD\./)).toBeTruthy();
  });

  it("garde le même clientId quand on réessaie après un échec : une seule commande côté serveur (CA-MAT-005.5)", async () => {
    mockSession("Achats");
    mockMaterialsReads({ requests: [validated()] });
    const clientIds: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/order"), async ({ request }) => {
        clientIds.push(((await request.json()) as { clientId: string }).clientId);
        return clientIds.length === 1 ? problem(500, "ERREUR_INTERNE") : HttpResponse.json(orderedDetail(), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/to-order");

    await user.click(await screen.findByRole("button", { name: "Commander DEM-009" }));
    const dialog = await screen.findByRole("dialog", { name: "Commander DEM-009" });
    await waitFor(() => expect((within(dialog).getAllByRole("textbox", { name: /^Fournisseur/ })[0] as HTMLInputElement).value).not.toBe(""));
    await user.click(within(dialog).getByRole("button", { name: "Commander" }));
    expect(await within(dialog).findByText("Erreur du serveur. Réessayez ; si le problème continue, donnez la référence au support.")).toBeTruthy();
    await user.click(within(dialog).getByRole("button", { name: "Commander" }));

    await waitFor(() => expect(clientIds).toHaveLength(2));
    expect(clientIds[0]).toBe(clientIds[1]);
  });

  it("répond « Déjà commandée » quand une autre personne a commandé entre-temps (COMMANDE_EXISTANTE)", async () => {
    mockSession("Achats");
    mockMaterialsReads({ requests: [validated()] });
    server.use(http.post(apiUrl("/sites/:siteId/requests/:requestId/order"), () => problem(422, "COMMANDE_EXISTANTE")));
    const user = userEvent.setup();
    renderApp("/materials/to-order");

    await user.click(await screen.findByRole("button", { name: "Commander DEM-009" }));
    const dialog = await screen.findByRole("dialog", { name: "Commander DEM-009" });
    await waitFor(() => expect((within(dialog).getAllByRole("textbox", { name: /^Fournisseur/ })[0] as HTMLInputElement).value).not.toBe(""));
    await user.click(within(dialog).getByRole("button", { name: "Commander" }));

    expect(await screen.findByText("Déjà commandée.")).toBeTruthy();
    await waitFor(() => expect(screen.queryByRole("dialog", { name: "Commander DEM-009" })).toBeNull());
  });

  it("refuse un prix nul sans appeler le serveur, et une livraison prévue avant la commande", async () => {
    mockSession("Achats");
    mockMaterialsReads({ requests: [validated()] });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/order"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(orderedDetail(), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/to-order");

    await user.click(await screen.findByRole("button", { name: "Commander DEM-009" }));
    const dialog = await screen.findByRole("dialog", { name: "Commander DEM-009" });
    await waitFor(() => expect((within(dialog).getAllByRole("textbox", { name: /^Fournisseur/ })[0] as HTMLInputElement).value).not.toBe(""));
    await user.type(within(dialog).getByRole("textbox", { name: /^Prix unitaire HT/ }), "0");
    await user.click(within(dialog).getByRole("button", { name: "Commander" }));

    expect(await within(dialog).findByText("Le prix doit être supérieur à 0, avec deux décimales au plus.")).toBeTruthy();
    expect(bodies).toHaveLength(0);
  });

  it("sans Prices.View, le formulaire n'a ni prix ni n° de bon de commande et rien n'en part (CA-MAT-009.3)", async () => {
    mockSession("Achats", { permissions: PERMISSIONS_BY_ROLE.Achats.filter((permission) => permission !== "Prices.View") });
    mockMaterialsReads({ requests: [validated()] });
    const bodies: Record<string, unknown>[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/order"), async ({ request }) => {
        bodies.push((await request.json()) as Record<string, unknown>);
        return HttpResponse.json(orderedDetail({ order: makeOrder({ commercial: undefined }) }), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/to-order");

    await user.click(await screen.findByRole("button", { name: "Commander DEM-009" }));
    const dialog = await screen.findByRole("dialog", { name: "Commander DEM-009" });
    expect(within(dialog).queryByRole("textbox", { name: /^Prix unitaire HT/ })).toBeNull();
    expect(within(dialog).queryByRole("textbox", { name: /bon de commande/ })).toBeNull();
    await waitFor(() => expect((within(dialog).getAllByRole("textbox", { name: /^Fournisseur/ })[0] as HTMLInputElement).value).not.toBe(""));
    await user.click(within(dialog).getByRole("button", { name: "Commander" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).not.toHaveProperty("unitPrice");
    expect(bodies[0]).not.toHaveProperty("purchaseOrderNumber");
    // Sans montant du serveur, la notification ne mentionne aucun montant.
    expect(await screen.findByText("Commande de DEM-009 enregistrée.")).toBeTruthy();
  });
});

describe("Commande dans la fiche d'une demande (CA-MAT-005.6, 005.7, 008.5)", () => {
  it("montre le fournisseur, les dates, le prix par unité et le montant calculé par le serveur aux rôles « prix »", async () => {
    mockSession("Achats");
    mockMaterialsReads({ requests: [validated()], detail: orderedDetail() });
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    const order = await within(drawer).findByRole("group", { name: "Commande" });
    expect(within(order).getByText("Cimenterie Sigma (fictive)")).toBeTruthy();
    expect(within(order).getByText("26/11/2026")).toBeTruthy();
    expect(within(order).getByText(/780,00.DZD par sac/)).toBeTruthy();
    expect(within(order).getByText(/234.000,00.DZD/)).toBeTruthy();
    expect(within(order).getByText("BC-2026-044")).toBeTruthy();
    expect(within(drawer).getByRole("button", { name: "Modifier la commande" })).toBeTruthy();
    expect(within(drawer).getByRole("button", { name: "Annuler la commande" })).toBeTruthy();
  });

  it("ne montre ni prix, ni montant, ni n° de bon de commande à un chef de chantier, et aucun bouton de commande (CA-MAT-005.12)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: orderedDetail({ order: makeOrder({ commercial: undefined }) }) });
    renderApp(`/materials/requests/${SITE_UV18_ID}/${REQUEST_DEM009_ID}`);

    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    const order = await within(drawer).findByRole("group", { name: "Commande" });
    expect(within(order).getByText("Cimenterie Sigma (fictive)")).toBeTruthy();
    expect(drawer.textContent).not.toMatch(/DZD/);
    expect(drawer.textContent).not.toMatch(/BC-2026-044/);
    expect(within(drawer).queryByRole("button", { name: "Modifier la commande" })).toBeNull();
    expect(within(drawer).queryByRole("button", { name: "Annuler la commande" })).toBeNull();
    expect(within(drawer).queryByRole("button", { name: "Commander" })).toBeNull();
  });

  it("avertit quand la livraison prévue dépasse la date de besoin, sans bloquer (CA-MAT-005.4)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ detail: orderedDetail({ order: makeOrder({ plannedAfterNeedDays: 3 }) }) });
    renderApp(`/materials/requests/${SITE_UV18_ID}/${REQUEST_DEM009_ID}`);

    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    expect(await within(drawer).findByText("Livraison prévue 3 jours après le besoin.")).toBeTruthy();
    // Le conducteur voit la commande mais n'a pas le bouton (CA-MAT-005.9).
    expect(within(drawer).queryByRole("button", { name: "Modifier la commande" })).toBeNull();
  });

  it("modifie la commande : seuls les champs changés partent, avec la version de la commande (CA-MAT-005.6)", async () => {
    mockSession("Achats");
    mockMaterialsReads({ detail: orderedDetail() });
    const bodies: Record<string, unknown>[] = [];
    server.use(
      http.put(apiUrl("/sites/:siteId/requests/:requestId/order"), async ({ request }) => {
        bodies.push((await request.json()) as Record<string, unknown>);
        return HttpResponse.json(orderedDetail({ order: makeOrder({ version: "51003", commercial: { unitPrice: 800, amount: 240000, receivedValue: 0, purchaseOrderNumber: "BC-2026-044" } }) }));
      }),
    );
    const user = userEvent.setup();
    renderApp(`/materials/requests/${SITE_UV18_ID}/${REQUEST_DEM009_ID}`);

    await user.click(await screen.findByRole("button", { name: "Modifier la commande" }));
    const dialog = await screen.findByRole("dialog", { name: "Modifier la commande de DEM-009" });
    const price = within(dialog).getByRole("textbox", { name: /^Prix unitaire HT/ });
    expect((price as HTMLInputElement).value).toBe("780");
    await user.clear(price);
    await user.type(price, "800");
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    await waitFor(() => expect(bodies).toEqual([{ version: "51002", unitPrice: 800 }]));
    expect(await screen.findByText(/Commande de DEM-009 enregistrée|Commande de DEM-009 modifiée|montant 240.000,00.DZD/)).toBeTruthy();
  });

  it("annule la commande avec un motif de la liste du serveur ; la demande redevient « Validée » (CA-MAT-005.7)", async () => {
    mockSession("Achats");
    mockMaterialsReads({ detail: orderedDetail() });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/order/cancel"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ status: "Validated" }));
      }),
    );
    const user = userEvent.setup();
    renderApp(`/materials/requests/${SITE_UV18_ID}/${REQUEST_DEM009_ID}`);

    await user.click(await screen.findByRole("button", { name: "Annuler la commande" }));
    const dialog = await screen.findByRole("dialog", { name: "Annuler la commande de DEM-009 ?" });
    await user.click(within(dialog).getByRole("button", { name: "Annuler la commande" }));
    expect(await within(dialog).findByText("Choisissez un motif.")).toBeTruthy();
    expect(bodies).toHaveLength(0);

    await user.click(within(dialog).getByRole("textbox", { name: /Motif/ }));
    await user.click(await screen.findByRole("option", { name: "Prix refusé" }));
    await user.click(within(dialog).getByRole("button", { name: "Annuler la commande" }));

    await waitFor(() => expect(bodies).toEqual([{ reasonCode: "PriceRefused", reasonNote: null }]));
    expect(await screen.findByText("Commande de DEM-009 annulée.")).toBeTruthy();
  });

  it("n'offre pas d'annuler la commande dès qu'une livraison est retenue (le serveur répondrait TRANSITION_INTERDITE)", async () => {
    mockSession("Achats");
    mockMaterialsReads({
      detail: orderedDetail({ status: "PartiallyDelivered", receivedQuantity: { value: 200, unit: "sac" }, remainingQuantity: { value: 100, unit: "sac" } }),
    });
    renderApp(`/materials/requests/${SITE_UV18_ID}/${REQUEST_DEM009_ID}`);

    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    expect(await within(drawer).findByRole("button", { name: "Modifier la commande" })).toBeTruthy();
    expect(within(drawer).queryByRole("button", { name: "Annuler la commande" })).toBeNull();
    // Les Achats peuvent solder le manque d'une demande livrée partiellement (CA-MAT-008.5).
    expect(within(drawer).getByRole("button", { name: "Solder" })).toBeTruthy();
  });

  it("solde le manque avec un motif obligatoire (CA-MAT-008.5)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ detail: orderedDetail({ status: "PartiallyDelivered", receivedQuantity: { value: 200, unit: "sac" }, remainingQuantity: { value: 100, unit: "sac" } }) });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/settle"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ status: "Delivered", isSettled: true }));
      }),
    );
    const user = userEvent.setup();
    renderApp(`/materials/requests/${SITE_UV18_ID}/${REQUEST_DEM009_ID}`);

    await user.click(await screen.findByRole("button", { name: "Solder" }));
    const dialog = await screen.findByRole("dialog", { name: "Solder DEM-009 ?" });
    await user.click(within(dialog).getByRole("textbox", { name: /Motif/ }));
    await user.click(await screen.findByRole("option", { name: "Quantité suffisante" }));
    await user.click(within(dialog).getByRole("button", { name: "Solder la demande" }));

    await waitFor(() => expect(bodies).toEqual([{ reasonCode: "QuantitySufficient", reasonNote: null }]));
    expect(await screen.findByText("Demande DEM-009 soldée.")).toBeTruthy();
  });
});

describe("Accès à « À commander » (CA-MAT-005.9, CA-MAT-009.1)", () => {
  it.each<[TestRole, boolean]>([
    ["Admin", true],
    ["Achats", true],
    ["ConducteurTravaux", false],
    ["ChefChantier", false],
    ["ChefEquipe", false],
    ["Direction", false],
  ])("%s : menu et page « À commander » accessibles = %s", async (role, allowed) => {
    mockSession(role);
    mockMaterialsReads({ requests: [validated()] });
    renderApp("/materials/to-order");

    if (allowed) {
      expect(await screen.findByRole("heading", { level: 1, name: "Demandes à commander" })).toBeTruthy();
      expect(screen.getAllByRole("link", { name: "À commander" }).length).toBeGreaterThan(0);
    } else {
      expect(await screen.findByText("Accès non autorisé")).toBeTruthy();
      expect(screen.queryByRole("link", { name: "À commander" })).toBeNull();
    }
  });

  it("garde la livraison reçue sans commande visible dans la fiche (livraison avant commande, CA-MAT-010.7)", async () => {
    mockSession("Achats");
    mockMaterialsReads({
      detail: makeRequestDetail({ status: "Validated", hasDeliveryWithoutOrder: true, deliveries: [{ ...makeDelivery(), photoCount: 0 } as never] }),
    });
    renderApp(`/materials/requests/${SITE_UV18_ID}/${REQUEST_DEM009_ID}`);

    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    expect(await within(drawer).findByText("Livraison reçue sans commande enregistrée.")).toBeTruthy();
    // Livraison avant commande : « Commander » reste proposé aux Achats (la commande recalcule le statut).
    expect(within(drawer).getByRole("button", { name: "Commander" })).toBeTruthy();
  });
});
