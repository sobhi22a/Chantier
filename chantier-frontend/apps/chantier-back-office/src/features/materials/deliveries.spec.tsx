import { createHash } from "node:crypto";

import { fireEvent, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import { todayDateOnly } from "@chantier-frontend/i18n";
import {
  DELIVERY_LIV006_ID,
  PERMISSIONS_BY_ROLE,
  PHOTO_BL_ID,
  REQUEST_DEM009_ID,
  SITE_UV18_ID,
  SUPPLIER_SIGMA_ID,
  apiUrl,
  makeDelivery,
  makeDeliveryDetail,
  makeMe,
  makeOrder,
  makePhoto,
  makeRequest,
  makeRequestDetail,
  makeSite,
  problem,
  server,
  setupMockServer,
  type TestRole,
} from "@chantier-frontend/testing";

import { mockMaterialsReads } from "../../testing/materialsMocks";
import { mockSession, renderApp } from "../../testing/renderApp";

setupMockServer();

const NBSP = String.fromCharCode(160);
const listPath = `/materials/deliveries?siteId=${SITE_UV18_ID}`;
const detailPath = `/materials/deliveries/${SITE_UV18_ID}/${DELIVERY_LIV006_ID}`;
const JPEG_BYTES = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);

/** Une quantité affichée « <nombre> unité » : le nombre est isolé (bdi), le texte complet est celui du <span> englobant. */
const quantityMatcher = (text: string) => (_content: string, element: Element | null) =>
  element?.tagName === "SPAN" && element.textContent === text && element.querySelector("bdi") !== null;

/** DEM-005 : 600 sacs commandés, 400 déjà reçus, reste 200 (vecteurs de calcul). */
const openRequestDetail = (overrides = {}) =>
  makeRequestDetail({
    status: "PartiallyDelivered",
    quantity: { value: 600, unit: "sac" },
    receivedQuantity: { value: 400, unit: "sac" },
    remainingQuantity: { value: 200, unit: "sac" },
    order: makeOrder(),
    ...overrides,
  });

const supplierField = (dialog: HTMLElement) => within(dialog).getAllByRole("textbox", { name: /^Fournisseur/ })[0] as HTMLInputElement;

beforeEach(() => {
  // jsdom n'a ni URL d'objet ni canvas : on les remplace par des doublures simples (la réduction réelle se fait dans le navigateur).
  URL.createObjectURL = vi.fn(() => "blob:test/photo-1");
  URL.revokeObjectURL = vi.fn();
});

afterEach(() => {
  document.documentElement.removeAttribute("lang");
  document.documentElement.removeAttribute("dir");
  vi.restoreAllMocks();
});

describe("Livraisons : liste (CA-MAT-011.8, 007.7, 006.6)", () => {
  it("affiche numéro, date, produit, fournisseur, quantité avec unité et équivalent, BL, demande et état", async () => {
    mockSession("Achats");
    const { listDeliveries } = mockMaterialsReads({ deliveries: [makeDelivery()] });
    renderApp(listPath);

    const table = await screen.findByRole("table");
    const row = within(table).getAllByRole("row")[1] as HTMLElement;
    const cells = within(row).getAllByRole("cell").map((cell) => cell.textContent);
    expect(cells).toEqual(
      expect.arrayContaining(["LIV-006", "04/11/2026", "Ciment CPJ 42,5", "Cimenterie Sigma (fictive)", "BL-4471", "DEM-009"]),
    );
    // 10 T reçues et leur équivalent 200 sacs dans l'unité de la demande : jamais deux unités additionnées.
    expect(within(row).getByText(quantityMatcher(`10${NBSP}T`))).toBeTruthy();
    expect(within(row).getByText(/^= 200\s+sacs$/)).toBeTruthy();
    expect(within(row).getByText("Enregistrée")).toBeTruthy();
    // Valeur calculée par le serveur : colonne présente car `commercial` est fourni (Prices.View).
    expect(within(table).getByText("Valeur")).toBeTruthy();
    expect(within(row).getByText(/156.000,00.DZD/)).toBeTruthy();
    expect(listDeliveries[0]?.searchParams.get("pageSize")).toBe("20");
    expect(listDeliveries[0]?.searchParams.get("unattached")).toBeNull();
  });

  it("n'affiche ni colonne ni montant quand le serveur n'envoie pas `commercial` (chef de chantier)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveries: [makeDelivery({ commercial: undefined })] });
    renderApp(listPath);

    const table = await screen.findByRole("table");
    expect(within(table).queryByText("Valeur")).toBeNull();
    expect(table.textContent).not.toMatch(/DZD/);
  });

  it("filtre par onglet côté serveur : Non rattachées, À compléter, Avec réserve ; badges avec icône et texte", async () => {
    mockSession("ConducteurTravaux");
    const { listDeliveries } = mockMaterialsReads({
      deliveries: [
        makeDelivery({ id: "d1", number: "LIV-010", requestId: null, requestNumber: null, unattachedReason: "RequestNotOpen", deliveryNoteNumber: null, missingNote: true }),
        makeDelivery({ id: "d2", number: "LIV-011", conformity: "WithReserve", reserve: { code: "DamagedProduct", note: null } }),
        makeDelivery({ id: "d3", number: "LIV-012", status: "Cancelled" }),
      ],
    });
    const user = userEvent.setup();
    renderApp(listPath);

    const table = await screen.findByRole("table");
    expect(within(table).getByText("Non rattachée")).toBeTruthy();
    expect(within(table).getByText("BL manquant")).toBeTruthy();
    expect(within(table).getAllByText("Avec réserve").length).toBeGreaterThan(0);
    expect(within(table).getByText("Annulée")).toBeTruthy();

    await user.click(screen.getByText("Non rattachées"));
    await waitFor(() => expect(listDeliveries.at(-1)?.searchParams.get("unattached")).toBe("true"));
    await user.click(screen.getByText("À compléter"));
    await waitFor(() => expect(listDeliveries.at(-1)?.searchParams.get("missingNote")).toBe("true"));
    await user.click(screen.getAllByText("Avec réserve")[0] as HTMLElement);
    await waitFor(() => expect(listDeliveries.at(-1)?.searchParams.get("withReserve")).toBe("true"));
  });

  it("garde le chantier, la recherche et l'onglet dans l'adresse (lien partageable)", async () => {
    mockSession("Achats");
    const { listDeliveries } = mockMaterialsReads({ deliveries: [makeDelivery()] });
    renderApp(`${listPath}&tab=unattached&q=BL-4471&status=Recorded&page=2`);

    await screen.findByRole("table");
    const call = listDeliveries[0];
    expect(call?.searchParams.get("unattached")).toBe("true");
    expect(call?.searchParams.get("q")).toBe("BL-4471");
    expect(call?.searchParams.get("status")).toBe("Recorded");
    expect(call?.searchParams.get("page")).toBe("2");
  });

  it("demande de choisir un chantier quand l'utilisateur en a plusieurs, et prend le seul chantier d'office", async () => {
    mockSession("Achats");
    mockMaterialsReads({ deliveries: [makeDelivery()] });
    const first = renderApp("/materials/deliveries");
    expect(await screen.findByText("Choisissez un chantier pour voir ses livraisons.")).toBeTruthy();
    first.unmount();

    mockSession("Achats");
    mockMaterialsReads({ deliveries: [makeDelivery()], sites: [makeSite()] });
    renderApp("/materials/deliveries");
    expect(await screen.findByRole("table")).toBeTruthy();
  });

  it("affiche l'état vide et l'état d'erreur avec « Réessayer »", async () => {
    mockSession("Achats");
    mockMaterialsReads({ deliveries: [] });
    const empty = renderApp(listPath);
    expect(await screen.findByText("Aucune livraison dans cette vue.")).toBeTruthy();
    empty.unmount();

    mockSession("Achats");
    mockMaterialsReads({ deliveries: [] });
    server.use(http.get(apiUrl("/sites/:siteId/deliveries"), () => problem(500, "ERREUR_INTERNE")));
    renderApp(listPath);
    expect(await screen.findByText(/Erreur du serveur/)).toBeTruthy();
    expect(screen.getByRole("button", { name: "Réessayer" })).toBeTruthy();
  });

  it("montre la liste en arabe : RTL, badges et unités traduits, numéros et dates de gauche à droite (CA-MAT-020)", async () => {
    mockSession("Achats", { language: "ar" });
    mockMaterialsReads({ deliveries: [makeDelivery({ requestId: null, requestNumber: null, unattachedReason: "RequestNotOpen" })] });
    renderApp(listPath, "ar");

    expect(await screen.findByRole("heading", { level: 1, name: "التسليمات" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
    const table = await screen.findByRole("table");
    expect(within(table).getByText("غير مرتبط بطلب")).toBeTruthy();
    expect(within(table).getByText("مسجَّل")).toBeTruthy();
    expect(within(table).getAllByText("طن", { exact: false }).length).toBeGreaterThan(0);
    const ltr = [...table.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent);
    expect(ltr).toContain("LIV-006");
    expect(ltr).toContain("04/11/2026");
    expect(ltr).toContain("10");
  });
});

describe("Nouvelle livraison depuis une demande (CA-MAT-006.1 à 006.8)", () => {
  const createPath = `/materials/deliveries?create=1&siteId=${SITE_UV18_ID}&requestId=${REQUEST_DEM009_ID}`;

  it("préremplit produit, fournisseur, unité de la commande et reste à livrer ; annonce « livraison complète »", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: openRequestDetail(), deliveries: [] });
    renderApp(createPath);

    const dialog = await screen.findByRole("dialog", { name: "Livraison pour DEM-009" });
    expect((within(dialog).getByRole("textbox", { name: /^Quantité reçue/ }) as HTMLInputElement).value).toBe("200");
    expect((within(dialog).getAllByRole("textbox", { name: /^Unité/ })[0] as HTMLInputElement).value).toBe("Sac");
    await waitFor(() => expect(supplierField(dialog).value).toBe("Cimenterie Sigma (fictive)"));
    expect(await within(dialog).findByText("Livraison complète.")).toBeTruthy();
  });

  it("annonce partielle, puis surplus avec conversion T → sacs, avant l'enregistrement (CA-MAT-006.3, 006.4)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: openRequestDetail(), deliveries: [] });
    const user = userEvent.setup();
    renderApp(createPath);

    const dialog = await screen.findByRole("dialog", { name: "Livraison pour DEM-009" });
    const quantity = within(dialog).getByRole("textbox", { name: /^Quantité reçue/ });
    await user.clear(quantity);
    await user.type(quantity, "150");
    expect(await within(dialog).findByText(/Livraison partielle : il restera 50\s+sacs\./)).toBeTruthy();

    // 15 T = 300 sacs : 400 + 300 = 700 pour 600 commandés, surplus de 100 sacs (+16,67 %).
    await user.clear(quantity);
    await user.type(quantity, "15");
    await user.click(within(dialog).getAllByRole("textbox", { name: /^Unité/ })[0] as HTMLElement);
    await user.click(await screen.findByRole("option", { name: "Tonne (T)" }));
    expect(await within(dialog).findByText(/Surplus de \+100\s+sacs \(\+16,67\s%\)\./)).toBeTruthy();
    expect(within(dialog).getByText(/Équivalence : 15\s+T = 300\s+sacs/)).toBeTruthy();
  });

  it("n'envoie que des champs saisis : demande, fournisseur, quantité avec unité, date ; aucun statut, numéro ni prix (CT-MAT-12)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: openRequestDetail(), deliveries: [] });
    const bodies: Record<string, unknown>[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries"), async ({ request }) => {
        bodies.push((await request.json()) as Record<string, unknown>);
        return HttpResponse.json(makeDeliveryDetail({ number: "LIV-009" }), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp(createPath);

    const dialog = await screen.findByRole("dialog", { name: "Livraison pour DEM-009" });
    await waitFor(() => expect(supplierField(dialog).value).toBe("Cimenterie Sigma (fictive)"));
    await user.type(within(dialog).getByRole("textbox", { name: /N° du bon de livraison/ }), "bl-4471");
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toMatchObject({
      requestId: REQUEST_DEM009_ID,
      supplierId: SUPPLIER_SIGMA_ID,
      quantity: { value: 200, unit: "sac" },
      deliveryDate: todayDateOnly(),
      conformity: "Conform",
      productId: null,
      deliveryNoteNumber: "bl-4471",
    });
    for (const forbidden of ["status", "number", "amount", "unitPrice", "commercial"]) expect(bodies[0]).not.toHaveProperty(forbidden);
    expect(typeof bodies[0]?.["clientId"]).toBe("string");
    expect(await screen.findByText("Livraison LIV-009 enregistrée.")).toBeTruthy();
    // La fiche de la livraison s'ouvre pour ajouter les photos du bon.
    expect(await screen.findByRole("dialog", { name: "Livraison LIV-006" })).toBeTruthy();
  });

  it("garde le même clientId quand on réessaie après un échec : un seul numéro (CA-MAT-006.8)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: openRequestDetail(), deliveries: [] });
    const clientIds: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries"), async ({ request }) => {
        clientIds.push(((await request.json()) as { clientId: string }).clientId);
        return clientIds.length === 1 ? problem(500, "ERREUR_INTERNE") : HttpResponse.json(makeDeliveryDetail(), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp(createPath);

    const dialog = await screen.findByRole("dialog", { name: "Livraison pour DEM-009" });
    await waitFor(() => expect(supplierField(dialog).value).not.toBe(""));
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));
    expect(await within(dialog).findByText(/Erreur du serveur/)).toBeTruthy();
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));

    await waitFor(() => expect(clientIds).toHaveLength(2));
    expect(clientIds[0]).toBe(clientIds[1]);
  });

  it("exige un motif pour « Avec réserve » (et une remarque pour « Autre ») et l'envoie (CA-MAT-006.6)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: openRequestDetail(), deliveries: [] });
    const bodies: Record<string, unknown>[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries"), async ({ request }) => {
        bodies.push((await request.json()) as Record<string, unknown>);
        return HttpResponse.json(makeDeliveryDetail({ conformity: "WithReserve" }), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp(createPath);

    const dialog = await screen.findByRole("dialog", { name: "Livraison pour DEM-009" });
    await waitFor(() => expect(supplierField(dialog).value).not.toBe(""));
    await user.click(within(dialog).getByText("Avec réserve"));
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));
    expect(await within(dialog).findByText("Choisissez un motif de réserve.")).toBeTruthy();
    expect(bodies).toHaveLength(0);

    await user.click(within(dialog).getByRole("textbox", { name: /Motif de la réserve/ }));
    await user.click(await screen.findByRole("option", { name: "Autre" }));
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));
    expect(await within(dialog).findByText("Précisez le motif dans la remarque.")).toBeTruthy();

    await user.click(within(dialog).getByRole("textbox", { name: /Motif de la réserve/ }));
    await user.click(await screen.findByRole("option", { name: "Produit abîmé" }));
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));
    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toMatchObject({ conformity: "WithReserve", reserveReasonCode: "DamagedProduct" });
  });

  it("refuse une quantité décimale en sacs sans appeler le serveur (QUANTITE_ENTIERE_REQUISE)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: openRequestDetail(), deliveries: [] });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeDeliveryDetail(), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp(createPath);

    const dialog = await screen.findByRole("dialog", { name: "Livraison pour DEM-009" });
    await waitFor(() => expect(supplierField(dialog).value).not.toBe(""));
    const quantity = within(dialog).getByRole("textbox", { name: /^Quantité reçue/ });
    await user.clear(quantity);
    await user.type(quantity, "12,5");
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));

    expect(await within(dialog).findByText("Nombre entier requis pour cette unité.")).toBeTruthy();
    expect(bodies).toHaveLength(0);
  });

  it("n'offre que des unités convertibles avec celle de la commande : sac, kg, T, jamais m³ (CA-MAT-006.4)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: openRequestDetail(), deliveries: [] });
    const user = userEvent.setup();
    renderApp(createPath);

    const dialog = await screen.findByRole("dialog", { name: "Livraison pour DEM-009" });
    await waitFor(() => expect(supplierField(dialog).value).not.toBe(""));
    await user.click(within(dialog).getAllByRole("textbox", { name: /^Unité/ })[0] as HTMLElement);
    const options = (await screen.findAllByRole("option")).map((option) => option.textContent);
    expect(options).toEqual(expect.arrayContaining(["Sac", "Tonne (T)", "Kilogramme (kg)"]));
    expect(options).not.toContain("Mètre cube (m³)");
  });

  it("enregistre une livraison sans demande : « Non rattachée » avec son motif, jamais refusée (CA-MAT-011.1, 010.6)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveries: [] });
    const bodies: Record<string, unknown>[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries"), async ({ request }) => {
        bodies.push((await request.json()) as Record<string, unknown>);
        return HttpResponse.json(
          makeDeliveryDetail({ number: "LIV-010", requestId: null, requestNumber: null, unattachedReason: "NoRequestChosen", quantityInRequestUnit: null }),
          { status: 201 },
        );
      }),
    );
    const user = userEvent.setup();
    renderApp(`/materials/deliveries?create=1&siteId=${SITE_UV18_ID}`);

    const dialog = await screen.findByRole("dialog", { name: "Nouvelle livraison" });
    await user.click(within(dialog).getByText("Autre produit"));
    await user.type(within(dialog).getByRole("textbox", { name: /^Nom du produit/ }), "Gravier 15/25 (fictif)");
    await user.click(within(dialog).getByText("Autre fournisseur"));
    await user.type(within(dialog).getByRole("textbox", { name: /^Nom du fournisseur/ }), "Carrière fictive");
    await user.type(within(dialog).getByRole("textbox", { name: /^Quantité reçue/ }), "24");
    await user.click(within(dialog).getAllByRole("textbox", { name: /^Unité/ })[0] as HTMLElement);
    await user.click(await screen.findByRole("option", { name: "Mètre cube (m³)" }));
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toMatchObject({
      requestId: null,
      productId: null,
      freeProductName: "Gravier 15/25 (fictif)",
      freeSupplierName: "Carrière fictive",
      supplierId: null,
      quantity: { value: 24, unit: "m3" },
    });
    expect(await screen.findByText("Livraison LIV-010 enregistrée, non rattachée : Aucune demande choisie.")).toBeTruthy();
  });

  it("signale un doublon de BL sans bloquer, et traduit UNITES_INCOMPATIBLES (CA-MAT-006.9, 006.4)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: openRequestDetail(), deliveries: [] });
    let calls = 0;
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries"), () => {
        calls += 1;
        return calls === 1
          ? problem(422, "UNITES_INCOMPATIBLES")
          : HttpResponse.json(makeDeliveryDetail({ possibleDuplicateOf: { id: "x", number: "LIV-006" } }), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp(createPath);

    const dialog = await screen.findByRole("dialog", { name: "Livraison pour DEM-009" });
    await waitFor(() => expect(supplierField(dialog).value).not.toBe(""));
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));
    expect(await within(dialog).findByText("Les unités sont différentes : elles ne peuvent pas être additionnées.")).toBeTruthy();
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));
    expect(await screen.findByText(/Doublon possible de LIV-006 : la livraison est enregistrée/)).toBeTruthy();
  });

  it("propose de réceptionner quand la livraison complète la demande (CA-MAT-006.13)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ detail: makeRequestDetail({ status: "Delivered" }), deliveries: [] });
    const received: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries"), () => HttpResponse.json(makeDeliveryDetail(), { status: 201 })),
      http.post(apiUrl("/sites/:siteId/requests/:requestId/receive"), async ({ request }) => {
        received.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ status: "Received" }));
      }),
    );
    const user = userEvent.setup();
    renderApp(`/materials/deliveries?create=1&siteId=${SITE_UV18_ID}&requestId=${REQUEST_DEM009_ID}`);

    const dialog = await screen.findByRole("dialog", { name: "Livraison pour DEM-009" });
    await waitFor(() => expect(supplierField(dialog).value).toBe(""));
    await user.click(within(dialog).getByRole("textbox", { name: /Nom du fournisseur|^Fournisseur/ }));
    // Le fournisseur n'est pas défini sur une demande validée sans commande : on le choisit dans le catalogue.
    await user.click(await screen.findByRole("option", { name: "Cimenterie Sigma (fictive)" }));
    await user.type(within(dialog).getByRole("textbox", { name: /^Quantité reçue/ }), "{Control>}a{/Control}300");
    await user.click(within(dialog).getByRole("button", { name: "Nouvelle livraison" }));

    const prompt = await screen.findByRole("dialog", { name: "DEM-009 est livrée. Réceptionner maintenant ?" });
    await user.click(within(prompt).getByRole("button", { name: "Réceptionner" }));
    await waitFor(() => expect(received).toEqual([{ note: null }]));
    expect(await screen.findByText("Demande DEM-009 réceptionnée.")).toBeTruthy();
  });
});

describe("Livraison : fiche, correction, annulation, rattachement (CA-MAT-011, 012)", () => {
  it("montre la livraison, son historique et ses actions selon les droits : corriger, annuler, pas de rattachement", async () => {
    mockSession("ChefChantier");
    // Le serveur n'envoie pas `commercial` sans Prices.View : la fiche n'affiche donc aucune valeur.
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail({ commercial: undefined }), detail: openRequestDetail() });
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    expect(within(drawer).getByRole("button", { name: "Corriger" })).toBeTruthy();
    expect(within(drawer).getByRole("button", { name: "Annuler la livraison" })).toBeTruthy();
    expect(within(drawer).queryByRole("button", { name: "Rattacher à une demande" })).toBeNull();
    expect(within(drawer).getByText(quantityMatcher(`10${NBSP}T`))).toBeTruthy();
    expect(within(drawer).getByText(quantityMatcher(`200${NBSP}sacs`))).toBeTruthy();
    expect(within(drawer).getByText("Livraison enregistrée")).toBeTruthy();
    // Le chef de chantier n'a pas Prices.View : aucune valeur dans la fiche (CA-MAT-009.3).
    expect(drawer.textContent).not.toMatch(/DZD/);
  });

  it("n'offre ni correction ni annulation à la direction ni au chef d'équipe (CA-MAT-012.8)", async () => {
    mockSession("Direction");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: openRequestDetail() });
    const first = renderApp(detailPath);
    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    expect(within(drawer).queryByRole("button", { name: "Corriger" })).toBeNull();
    expect(within(drawer).queryByRole("button", { name: "Annuler la livraison" })).toBeNull();
    // La direction voit la valeur : le serveur la fournit avec Prices.View.
    expect(within(drawer).getByText(/156.000,00.DZD/)).toBeTruthy();
    first.unmount();

    mockSession("ChefEquipe");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail({ photos: null, commercial: null }), detail: openRequestDetail() });
    renderApp(detailPath);
    const second = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    expect(within(second).queryByRole("button", { name: "Corriger" })).toBeNull();
    expect(second.textContent).not.toMatch(/DZD/);
  });

  it("n'offre plus de correction ni d'annulation quand la demande liée est réceptionnée (DEMANDE_NON_OUVERTE, CA-MAT-012.4)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: makeRequestDetail({ status: "Received" }) });
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    expect(await within(drawer).findByText("La demande liée est réceptionnée : la livraison ne se corrige plus.")).toBeTruthy();
    expect(within(drawer).queryByRole("button", { name: "Corriger" })).toBeNull();
    expect(within(drawer).queryByRole("button", { name: "Annuler la livraison" })).toBeNull();
  });

  it("corrige la quantité : seuls les champs changés partent avec la version ; un n° de BL ne s'efface pas (CA-MAT-012.1)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: openRequestDetail() });
    const bodies: Record<string, unknown>[] = [];
    server.use(
      http.put(apiUrl("/sites/:siteId/deliveries/:deliveryId"), async ({ request }) => {
        bodies.push((await request.json()) as Record<string, unknown>);
        return HttpResponse.json(makeDeliveryDetail({ quantity: { value: 12, unit: "t" }, version: "49801" }));
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);

    await user.click(await screen.findByRole("button", { name: "Corriger" }));
    const dialog = await screen.findByRole("dialog", { name: "Corriger la livraison LIV-006" });
    const quantity = within(dialog).getByRole("textbox", { name: /^Quantité reçue/ });
    expect((quantity as HTMLInputElement).value).toBe("10");
    await user.clear(quantity);
    await user.type(quantity, "12");
    await user.clear(within(dialog).getByRole("textbox", { name: /N° du bon de livraison/ }));
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    await waitFor(() => expect(bodies).toEqual([{ version: "49800", quantity: { value: 12, unit: "t" } }]));
    expect(await screen.findByText("Livraison LIV-006 corrigée.")).toBeTruthy();
  });

  it("propose de recharger après un conflit de version et ne perd pas la saisie sans choix (CONFLIT_VERSION)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: openRequestDetail() });
    server.use(
      http.put(apiUrl("/sites/:siteId/deliveries/:deliveryId"), () =>
        problem(409, "CONFLIT_VERSION", { current: makeDeliveryDetail({ version: "49900", quantity: { value: 11, unit: "t" }, updatedByName: "Karim A." }) }),
      ),
    );
    const user = userEvent.setup();
    renderApp(detailPath);

    await user.click(await screen.findByRole("button", { name: "Corriger" }));
    const dialog = await screen.findByRole("dialog", { name: "Corriger la livraison LIV-006" });
    const quantity = within(dialog).getByRole("textbox", { name: /^Quantité reçue/ });
    await user.clear(quantity);
    await user.type(quantity, "12");
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    expect(await within(dialog).findByText("Karim A. a modifié cette livraison pendant votre saisie.")).toBeTruthy();
    await user.click(within(dialog).getByRole("button", { name: "Recharger la version actuelle" }));
    await waitFor(() => expect((within(dialog).getByRole("textbox", { name: /^Quantité reçue/ }) as HTMLInputElement).value).toBe("11"));
  });

  it("annule la livraison avec un motif obligatoire de la liste du serveur (CA-MAT-012.2)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: openRequestDetail() });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries/:deliveryId/cancel"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeDeliveryDetail({ status: "Cancelled" }));
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);

    await user.click(await screen.findByRole("button", { name: "Annuler la livraison" }));
    const dialog = await screen.findByRole("dialog", { name: "Annuler la livraison LIV-006 ?" });
    await user.click(within(dialog).getByRole("button", { name: "Annuler la livraison" }));
    expect(await within(dialog).findByText("Choisissez un motif.")).toBeTruthy();
    expect(bodies).toHaveLength(0);

    await user.click(within(dialog).getByRole("textbox", { name: /Motif/ }));
    await user.click(await screen.findByRole("option", { name: "Saisie en double" }));
    await user.click(within(dialog).getByRole("button", { name: "Annuler la livraison" }));

    await waitFor(() => expect(bodies).toEqual([{ reasonCode: "DoubleEntry", reasonNote: null }]));
    expect(await screen.findByText("Livraison LIV-006 annulée.")).toBeTruthy();
  });

  it("rattache une livraison non rattachée à une demande ouverte du même produit ; traduit PRODUIT_DIFFERENT (CA-MAT-011.2, 011.3)", async () => {
    mockSession("ConducteurTravaux");
    const unattached = makeDeliveryDetail({ requestId: null, requestNumber: null, unattachedReason: "RequestNotOpen", quantityInRequestUnit: null });
    const open = makeRequest({ status: "Ordered", order: makeOrder() });
    const { siteRequests } = mockMaterialsReads({ deliveryDetail: unattached, requests: [open, makeRequest({ id: "closed", number: "DEM-001", status: "Received" })] });
    let calls = 0;
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries/:deliveryId/attach"), async ({ request }) => {
        bodies.push(await request.json());
        calls += 1;
        return calls === 1 ? problem(422, "PRODUIT_DIFFERENT") : HttpResponse.json(makeDeliveryDetail());
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    expect(await within(drawer).findByText(/Livraison non rattachée à une demande : La demande n'accepte plus de livraison\./)).toBeTruthy();
    await user.click(within(drawer).getByRole("button", { name: "Rattacher à une demande" }));
    const dialog = await screen.findByRole("dialog", { name: "Rattacher LIV-006 à une demande" });
    await user.click(within(dialog).getByRole("textbox", { name: /^Demande/ }));
    // Seules les demandes qui acceptent une livraison se proposent : DEM-001 est réceptionnée, donc absente.
    expect(screen.queryByRole("option", { name: /DEM-001/ })).toBeNull();
    await user.click(await screen.findByRole("option", { name: /DEM-009/ }));
    expect(siteRequests.some((url) => url.searchParams.get("productId") !== null)).toBe(true);

    await user.click(within(dialog).getByRole("button", { name: "Rattacher" }));
    expect(await within(dialog).findByText("Le produit de la livraison n'est pas celui de la demande.")).toBeTruthy();
    await user.click(within(dialog).getByRole("button", { name: "Rattacher" }));
    await waitFor(() => expect(bodies).toEqual([{ requestId: REQUEST_DEM009_ID }, { requestId: REQUEST_DEM009_ID }]));
    expect(await screen.findByText("Livraison LIV-006 rattachée à DEM-009.")).toBeTruthy();
  });

  it("réceptionne la demande depuis la fiche quand elle est livrée (CA-MAT-008.3)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: makeRequestDetail({ status: "Delivered" }) });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/receive"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ status: "Received" }));
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);

    await user.click(await screen.findByRole("button", { name: "Réceptionner" }));
    const dialog = await screen.findByRole("dialog", { name: "Réceptionner DEM-009 ?" });
    await user.click(within(dialog).getByRole("button", { name: "Réceptionner" }));
    await waitFor(() => expect(bodies).toEqual([{ note: null }]));
    expect(await screen.findByText("Demande DEM-009 réceptionnée.")).toBeTruthy();
  });

  it("affiche la fiche en arabe : RTL, actions traduites, numéros de gauche à droite", async () => {
    mockSession("ChefChantier", { language: "ar" });
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: openRequestDetail() });
    renderApp(detailPath, "ar");

    const drawer = await screen.findByRole("dialog", { name: /التسليم/ });
    expect(document.documentElement.dir).toBe("rtl");
    expect(await within(drawer).findByRole("button", { name: "تصحيح" })).toBeTruthy();
    expect(within(drawer).getByRole("button", { name: "إلغاء التسليم" })).toBeTruthy();
    const ltr = [...drawer.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent);
    expect(ltr).toContain("BL-4471");
    expect(ltr).toContain("04/11/2026");
  });
});

describe("Photos du bon (CA-MAT-007, ADR 0013)", () => {
  const withPhotos = () =>
    makeDeliveryDetail({
      photoCount: 2,
      photos: [
        { id: PHOTO_BL_ID, contentStatus: "Uploaded", sizeBytes: 4, takenAt: "2026-11-04T08:10:00Z" },
        { id: "00000000-0000-7000-8000-000000000b02", contentStatus: "Pending", sizeBytes: 4, takenAt: "2026-11-04T08:12:00Z" },
      ],
    });

  it("lit la photo avec la session (jamais d'URL publique) et signale un envoi incomplet", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: withPhotos(), detail: openRequestDetail() });
    const reads: string[] = [];
    server.use(
      http.get(apiUrl("/sites/:siteId/photos/:photoId/content"), ({ params }) => {
        reads.push(String(params["photoId"]));
        return new HttpResponse(JPEG_BYTES, { headers: { "Content-Type": "image/jpeg" } });
      }),
    );
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    const image = await within(drawer).findByRole("img", { name: "Bon de livraison, photo 1" });
    expect(image.getAttribute("src")).toBe("blob:test/photo-1");
    expect(within(drawer).getByText("Envoi incomplet")).toBeTruthy();
    // Seule la photo envoyée est lue ; la photo en attente n'a pas de fichier.
    expect(reads).toEqual([PHOTO_BL_ID]);
  });

  it("ne lit aucune photo sans DeliveryPhotos.View (le chef d'équipe : elles peuvent montrer des prix, CA-MAT-007.8)", async () => {
    mockSession("ChefEquipe");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail({ photoCount: 2, photos: null, commercial: null }), detail: openRequestDetail() });
    let reads = 0;
    server.use(
      http.get(apiUrl("/sites/:siteId/photos/:photoId/content"), () => {
        reads += 1;
        return new HttpResponse(null, { status: 404 });
      }),
    );
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    expect(await within(drawer).findByText("Les photos du bon ne sont pas visibles avec votre rôle.")).toBeTruthy();
    expect(within(drawer).queryByLabelText("Ajouter une photo du bon")).toBeNull();
    expect(reads).toBe(0);
  });

  it("réduit le JPEG, calcule l'empreinte, crée les métadonnées puis envoie le fichier (idempotent par clientId)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: openRequestDetail() });
    // Doublures du navigateur : une image 3000 × 2000 réduite dans un canvas.
    const drawImage = vi.fn();
    globalThis.createImageBitmap = vi.fn(async () => ({ width: 3000, height: 2000, close: vi.fn() })) as unknown as typeof createImageBitmap;
    vi.spyOn(HTMLCanvasElement.prototype, "getContext").mockReturnValue({ drawImage } as unknown as CanvasRenderingContext2D);
    vi.spyOn(HTMLCanvasElement.prototype, "toBlob").mockImplementation((callback) => callback(new Blob([JPEG_BYTES], { type: "image/jpeg" })));

    const metadata: Record<string, unknown>[] = [];
    const uploads: { type: string | null; size: number }[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries/:deliveryId/photos"), async ({ request }) => {
        metadata.push((await request.json()) as Record<string, unknown>);
        return HttpResponse.json(makePhoto({ contentStatus: "Pending" }), { status: 201 });
      }),
      http.put(apiUrl("/sites/:siteId/photos/:photoId/content"), async ({ request }) => {
        uploads.push({ type: request.headers.get("content-type"), size: (await request.arrayBuffer()).byteLength });
        return HttpResponse.json(makePhoto());
      }),
    );
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    const input = (await waitFor(() => {
      const found = drawer.querySelector('input[type="file"]');
      if (!found) throw new Error("champ fichier absent");
      return found;
    })) as HTMLInputElement;
    expect(input.getAttribute("accept")).toBe("image/jpeg");
    fireEvent.change(input, { target: { files: [new File([JPEG_BYTES], "bl.jpg", { type: "image/jpeg" })] } });

    await waitFor(() => expect(uploads).toHaveLength(1));
    // Réduite à 1 600 px de grand côté, jamais agrandie.
    expect(drawImage).toHaveBeenCalledWith(expect.anything(), 0, 0, 1600, 1067);
    expect(metadata[0]).toMatchObject({
      contentType: "image/jpeg",
      sizeBytes: 4,
      sha256: createHash("sha256").update(JPEG_BYTES).digest("hex"),
    });
    expect(typeof metadata[0]?.["clientId"]).toBe("string");
    // Le corps binaire et son Content-Type sont vérifiés dans le navigateur réel (Playwright) : le Blob de jsdom n'est pas
    // reconnu par le fetch de Node, qui l'envoie comme du texte.
    expect(uploads).toHaveLength(1);
    expect(await screen.findByText("Photo ajoutée à la livraison LIV-006.")).toBeTruthy();
  });

  const stubCanvas = () => {
    globalThis.createImageBitmap = vi.fn(async () => ({ width: 800, height: 600, close: vi.fn() })) as unknown as typeof createImageBitmap;
    vi.spyOn(HTMLCanvasElement.prototype, "getContext").mockReturnValue({ drawImage: vi.fn() } as unknown as CanvasRenderingContext2D);
    vi.spyOn(HTMLCanvasElement.prototype, "toBlob").mockImplementation((callback) => callback(new Blob([JPEG_BYTES], { type: "image/jpeg" })));
  };
  const chooseFile = async (drawer: HTMLElement) => {
    const input = (await waitFor(() => {
      const found = drawer.querySelector('input[type="file"]');
      if (!found) throw new Error("champ fichier absent");
      return found;
    })) as HTMLInputElement;
    fireEvent.change(input, { target: { files: [new File([JPEG_BYTES], "bl.jpg", { type: "image/jpeg", lastModified: 1_700_000_000_000 })] } });
  };

  it("reprend la photo en attente après un échec du fichier : pas de nouvelle photo, un seul POST (revue R3-04)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: openRequestDetail() });
    stubCanvas();
    const posts: unknown[] = [];
    let puts = 0;
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries/:deliveryId/photos"), async ({ request }) => {
        posts.push(((await request.json()) as { clientId: string }).clientId);
        return HttpResponse.json(makePhoto({ contentStatus: "Pending" }), { status: 201 });
      }),
      http.put(apiUrl("/sites/:siteId/photos/:photoId/content"), () => {
        puts += 1;
        return puts === 1 ? problem(503, "ERREUR_TEMPORAIRE") : HttpResponse.json(makePhoto());
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    await chooseFile(drawer);
    // Le code 503 est traduit (D-2 QA, R3-02) et l'envoi peut être repris.
    expect(await within(drawer).findByText(/Le serveur est momentanément occupé/)).toBeTruthy();
    await user.click(within(drawer).getByRole("button", { name: "Réessayer l'envoi" }));

    expect(await screen.findByText("Photo ajoutée à la livraison LIV-006.")).toBeTruthy();
    expect(puts).toBe(2);
    expect(posts).toHaveLength(1);
  });

  it("rejoue les métadonnées avec le même clientId quand c'est elles qui ont échoué", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: openRequestDetail() });
    stubCanvas();
    const clientIds: string[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries/:deliveryId/photos"), async ({ request }) => {
        clientIds.push(((await request.json()) as { clientId: string }).clientId);
        return clientIds.length === 1 ? problem(500, "ERREUR_INTERNE") : HttpResponse.json(makePhoto({ contentStatus: "Pending" }), { status: 201 });
      }),
      http.put(apiUrl("/sites/:siteId/photos/:photoId/content"), () => HttpResponse.json(makePhoto())),
    );
    const user = userEvent.setup();
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    await chooseFile(drawer);
    await user.click(await within(drawer).findByRole("button", { name: "Réessayer l'envoi" }));

    expect(await screen.findByText("Photo ajoutée à la livraison LIV-006.")).toBeTruthy();
    expect(clientIds).toHaveLength(2);
    expect(clientIds[0]).toBe(clientIds[1]);
  });

  it("ne propose pas de réessayer après un refus définitif du serveur (TYPE_FICHIER_REFUSE, 415)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: openRequestDetail() });
    stubCanvas();
    server.use(http.post(apiUrl("/sites/:siteId/deliveries/:deliveryId/photos"), () => problem(415, "TYPE_FICHIER_REFUSE")));
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    await chooseFile(drawer);
    expect(await within(drawer).findByText("Le fichier doit être une image JPEG valide.")).toBeTruthy();
    expect(within(drawer).queryByRole("button", { name: "Réessayer l'envoi" })).toBeNull();
  });

  it("refuse un fichier qui n'est pas un JPEG sans rien envoyer, et traduit le refus du serveur (TYPE_FICHIER_REFUSE)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail(), detail: openRequestDetail() });
    let posts = 0;
    server.use(
      http.post(apiUrl("/sites/:siteId/deliveries/:deliveryId/photos"), () => {
        posts += 1;
        return problem(415, "TYPE_FICHIER_REFUSE");
      }),
    );
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    const input = (await waitFor(() => {
      const found = drawer.querySelector('input[type="file"]');
      if (!found) throw new Error("champ fichier absent");
      return found;
    })) as HTMLInputElement;
    fireEvent.change(input, { target: { files: [new File(["x"], "bl.png", { type: "image/png" })] } });

    expect(await within(drawer).findByText("Choisissez une image JPEG.")).toBeTruthy();
    expect(posts).toBe(0);
  });

  it("bloque l'ajout à 5 photos par livraison (CA-MAT-007.3)", async () => {
    mockSession("ChefChantier");
    const photos = Array.from({ length: 5 }, (_, index) => ({
      id: `00000000-0000-7000-8000-00000000c0${index}`,
      contentStatus: "Uploaded" as const,
      sizeBytes: 4,
      takenAt: "2026-11-04T08:10:00Z",
    }));
    mockMaterialsReads({ deliveryDetail: makeDeliveryDetail({ photoCount: 5, photos }), detail: openRequestDetail() });
    server.use(http.get(apiUrl("/sites/:siteId/photos/:photoId/content"), () => new HttpResponse(JPEG_BYTES, { headers: { "Content-Type": "image/jpeg" } })));
    renderApp(detailPath);

    const drawer = await screen.findByRole("dialog", { name: "Livraison LIV-006" });
    expect(await within(drawer).findByText("5 photos au maximum par livraison.")).toBeTruthy();
    expect(drawer.querySelector('input[type="file"]')).toBeNull();
  });
});

describe("Accès aux livraisons (CA-MAT-009.1, 006.10, 011.7)", () => {
  it.each<[TestRole, boolean]>([
    ["Admin", true],
    ["ConducteurTravaux", true],
    ["Achats", true],
    ["ChefChantier", true],
    ["ChefEquipe", false],
    ["Direction", false],
  ])("%s : bouton « Nouvelle livraison » présent = %s, liste toujours lisible", async (role, canCreate) => {
    mockSession(role);
    mockMaterialsReads({ deliveries: [makeDelivery({ commercial: undefined })] });
    renderApp(listPath);

    expect(await screen.findByRole("table")).toBeTruthy();
    expect(screen.getAllByRole("link", { name: "Livraisons" }).length).toBeGreaterThan(0);
    if (canCreate) expect(screen.getByRole("button", { name: "Nouvelle livraison" })).toBeTruthy();
    else expect(screen.queryByRole("button", { name: "Nouvelle livraison" })).toBeNull();
  });

  it("donne la matrice des permissions du serveur : la liste n'est réservée à personne d'autre que les rôles sans Deliveries.View", async () => {
    mockSession("Achats", { permissions: PERMISSIONS_BY_ROLE.Achats.filter((permission) => permission !== "Deliveries.View") });
    mockMaterialsReads();
    renderApp(listPath);

    expect(await screen.findByText("Accès non autorisé")).toBeTruthy();
    expect(makeMe("Achats").permissions).toContain("Deliveries.View");
  });
});
