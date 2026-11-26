import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import {
  SITE_OL40_ID,
  SITE_UV18_ID,
  apiUrl,
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

afterEach(() => {
  document.documentElement.removeAttribute("lang");
  document.documentElement.removeAttribute("dir");
});

const numbered = (count: number, siteFor: (index: number) => string = () => SITE_UV18_ID) =>
  Array.from({ length: count }, (_, index) =>
    makeRequest({
      id: `00000000-0000-7000-8000-${String(index + 1).padStart(12, "0")}`,
      number: `DEM-${String(index + 1).padStart(3, "0")}`,
      siteId: siteFor(index),
      siteCode: siteFor(index) === SITE_UV18_ID ? "CH-ECO-UV18" : "CH-LOG-OL40",
    }),
  );

describe("À valider : file du conducteur (CA-MAT-003)", () => {
  it("liste les demandes « Demandée » de tous les chantiers, 50 par page, avec les actions en une ligne", async () => {
    mockSession("ConducteurTravaux");
    const { listRequests } = mockMaterialsReads({ requests: numbered(2) });
    renderApp("/materials/to-approve");

    const table = await screen.findByRole("table");
    expect(within(table).getAllByRole("row")).toHaveLength(3);
    expect(listRequests[0]?.searchParams.get("view")).toBe("toApprove");
    expect(listRequests[0]?.searchParams.get("pageSize")).toBe("50");
    expect(within(table).getByRole("button", { name: "Valider DEM-001" })).toBeTruthy();
    expect(within(table).getByRole("button", { name: "Refuser DEM-001" })).toBeTruthy();
    expect(within(table).getByRole("button", { name: "Valider avec une autre quantité DEM-001" })).toBeTruthy();
  });

  it("valide en un clic : une seule requête, sans corps de quantité (CA-MAT-003.1)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ requests: numbered(1) });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/approve"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ status: "Validated" }));
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/to-approve");

    await user.click(await screen.findByRole("button", { name: "Valider DEM-001" }));

    await waitFor(() => expect(bodies).toEqual([{}]));
    expect(await screen.findByText("Demande DEM-001 validée.")).toBeTruthy();
  });

  it("refuse avec un motif obligatoire de la liste du serveur ; sans motif, aucun appel (CA-MAT-003.2)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ requests: numbered(1) });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/reject"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ status: "Rejected" }));
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/to-approve");

    await user.click(await screen.findByRole("button", { name: "Refuser DEM-001" }));
    const dialog = await screen.findByRole("dialog", { name: "Refuser la demande DEM-001 ?" });
    await user.click(within(dialog).getByRole("button", { name: "Refuser la demande" }));
    expect(await within(dialog).findByText("Choisissez un motif.")).toBeTruthy();
    expect(bodies).toHaveLength(0);

    await user.click(within(dialog).getByRole("textbox", { name: /Motif/ }));
    await user.click(await screen.findByRole("option", { name: "Stock suffisant sur le chantier" }));
    await user.click(within(dialog).getByRole("button", { name: "Refuser la demande" }));

    await waitFor(() => expect(bodies).toEqual([{ reasonCode: "StockSufficient", reasonNote: null }]));
    expect(await screen.findByText("Demande DEM-001 refusée.")).toBeTruthy();
  });

  it("valide avec une autre quantité : l'unité reste celle de la demande, une quantité nulle est refusée (CA-MAT-003.3)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ requests: numbered(1) });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/:requestId/approve"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ status: "Validated", quantity: { value: 200, unit: "sac" } }));
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/to-approve");

    await user.click(await screen.findByRole("button", { name: "Valider avec une autre quantité DEM-001" }));
    const dialog = await screen.findByRole("dialog", { name: "Valider DEM-001 avec une autre quantité" });
    expect(within(dialog).getByText(/Quantité demandée : 300\s+sacs/)).toBeTruthy();
    const input = within(dialog).getByRole("textbox", { name: /^Quantité validée/ });

    await user.clear(input);
    await user.type(input, "0");
    await user.click(within(dialog).getByRole("button", { name: "Valider avec cette quantité" }));
    expect(await within(dialog).findByText(/La quantité doit être supérieure à 0/)).toBeTruthy();
    expect(bodies).toHaveLength(0);

    await user.clear(input);
    await user.type(input, "200");
    await user.click(within(dialog).getByRole("button", { name: "Valider avec cette quantité" }));
    await waitFor(() => expect(bodies).toEqual([{ quantity: { value: 200, unit: "sac" } }]));
  });

  it("valide un lot de 50 : un appel par chantier, résultat demande par demande avec le motif traduit (CA-MAT-003.9)", async () => {
    mockSession("ConducteurTravaux");
    // 30 demandes à l'École UV18 et 20 aux Oliviers.
    const requests = numbered(50, (index) => (index < 30 ? SITE_UV18_ID : SITE_OL40_ID));
    mockMaterialsReads({ requests, totalCount: 50 });
    const calls: { siteId: string; ids: string[] }[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests/batch/approve"), async ({ request, params }) => {
        const { requestIds } = (await request.json()) as { requestIds: string[] };
        calls.push({ siteId: String(params["siteId"]), ids: requestIds });
        return HttpResponse.json({
          results: requestIds.map((requestId, index) => ({
            requestId,
            // Une demande déjà annulée par son auteur, une déjà validée : jamais d'erreur globale.
            outcome: requestId.endsWith("1") && params["siteId"] === SITE_UV18_ID ? "rejected" : index === 1 ? "duplicate" : "applied",
            code: requestId.endsWith("1") && params["siteId"] === SITE_UV18_ID ? "TRANSITION_INTERDITE" : null,
          })),
        });
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/to-approve");

    await screen.findByRole("table");
    await user.click(screen.getByRole("checkbox", { name: "Sélectionner toutes les demandes de la page" }));
    expect(await screen.findByText("50 demandes sélectionnées")).toBeTruthy();
    await user.click(screen.getByRole("button", { name: "Valider la sélection" }));

    const results = await screen.findByRole("dialog", { name: "Résultat du lot" });
    expect(calls.map((call) => [call.siteId, call.ids.length])).toEqual([[SITE_UV18_ID, 30], [SITE_OL40_ID, 20]]);
    expect(within(results).getAllByRole("row")).toHaveLength(51);
    // Une ligne refusée porte son motif traduit (jamais le texte du serveur).
    expect(within(results).getAllByText("Ce changement de statut n'est pas autorisé.").length).toBeGreaterThan(0);
    expect(within(results).getByRole("status").textContent).toMatch(/refusée/);
  });

  it("ne laisse pas dépasser 50 demandes : les cases restantes sont désactivées (limite du lot)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ requests: numbered(55), totalCount: 55 });
    const user = userEvent.setup();
    renderApp("/materials/to-approve");

    await screen.findByRole("table");
    await user.click(screen.getByRole("checkbox", { name: "Sélectionner toutes les demandes de la page" }));

    expect(await screen.findByText("Limite de 50 demandes atteinte.")).toBeTruthy();
    expect(screen.getByRole("checkbox", { name: "Sélectionner DEM-055" }).hasAttribute("disabled")).toBe(true);
    expect(screen.getByRole("checkbox", { name: "Sélectionner DEM-001" }).hasAttribute("disabled")).toBe(false);
  });

  it("affiche l'état vide, puis la file en arabe (RTL, actions traduites)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ requests: [] });
    const first = renderApp("/materials/to-approve");
    expect(await screen.findByText("Aucune demande à valider.")).toBeTruthy();
    first.unmount();

    mockSession("ConducteurTravaux", { language: "ar" });
    mockMaterialsReads({ requests: numbered(1) });
    renderApp("/materials/to-approve", "ar");
    expect(await screen.findByRole("heading", { level: 1, name: "طلبات بانتظار المصادقة" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
    expect(await screen.findByRole("button", { name: "مصادقة DEM-001" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "رفض DEM-001" })).toBeTruthy();
  });

  it("traduit l'erreur d'une validation refusée sans rien casser (CA-MAT-003.6)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ requests: numbered(1) });
    server.use(http.post(apiUrl("/sites/:siteId/requests/:requestId/approve"), () => problem(422, "TRANSITION_INTERDITE")));
    const user = userEvent.setup();
    renderApp("/materials/to-approve");

    await user.click(await screen.findByRole("button", { name: "Valider DEM-001" }));
    expect(await screen.findByText("Ce changement de statut n'est pas autorisé.")).toBeTruthy();
  });
});

describe("Accès aux écrans de demandes (CA-MAT-009.1)", () => {
  it.each<[TestRole, boolean]>([
    ["Admin", true],
    ["ConducteurTravaux", true],
    ["ChefChantier", false],
    ["ChefEquipe", false],
    ["Achats", false],
    ["Direction", false],
  ])("%s : menu et page « À valider » accessibles = %s", async (role, allowed) => {
    mockSession(role);
    mockMaterialsReads({ requests: numbered(1) });
    renderApp("/materials/to-approve");

    if (allowed) {
      expect(await screen.findByRole("heading", { level: 1, name: "Demandes à valider" })).toBeTruthy();
      expect(screen.getAllByRole("link", { name: "À valider" }).length).toBeGreaterThan(0);
    } else {
      expect(await screen.findByText("Accès non autorisé")).toBeTruthy();
      expect(screen.queryByRole("link", { name: "À valider" })).toBeNull();
    }
  });

  it("montre les sections du menu selon les droits : Achats voit les demandes et le catalogue, ChefEquipe seulement les demandes", async () => {
    mockSession("Achats");
    mockMaterialsReads();
    const purchasing = renderApp("/materials/requests");
    await screen.findByRole("table");
    expect(screen.getByRole("link", { name: "Demandes de matériaux" })).toBeTruthy();
    expect(screen.getByRole("link", { name: "Produits" })).toBeTruthy();
    expect(screen.getByRole("link", { name: "Fournisseurs" })).toBeTruthy();
    purchasing.unmount();

    mockSession("ChefEquipe");
    mockMaterialsReads();
    renderApp("/materials/requests");
    await screen.findByRole("table");
    expect(screen.getByRole("link", { name: "Demandes de matériaux" })).toBeTruthy();
    // Le catalogue est lisible par tous les rôles (Products.View) : la lecture seule, sans bouton d'écriture.
    expect(screen.queryByRole("button", { name: "Nouveau produit" })).toBeNull();
  });
});
