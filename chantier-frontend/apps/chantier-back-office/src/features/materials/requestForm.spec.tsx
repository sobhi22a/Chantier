import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import { todayDateOnly } from "@chantier-frontend/i18n";
import {
  REQUEST_DEM009_ID,
  SITE_UV18_ID,
  apiUrl,
  makeMaterialSettings,
  makeRequestDetail,
  makeSite,
  problem,
  server,
  setupMockServer,
} from "@chantier-frontend/testing";

import { mockMaterialsReads } from "../../testing/materialsMocks";
import { mockSession, renderApp } from "../../testing/renderApp";
import { addDays } from "./types/quantityMirror";

setupMockServer();

const detailPath = `/materials/requests/${SITE_UV18_ID}/${REQUEST_DEM009_ID}`;

afterEach(() => {
  document.documentElement.removeAttribute("lang");
  document.documentElement.removeAttribute("dir");
});

const openCreateForm = async (user: ReturnType<typeof userEvent.setup>) => {
  await screen.findByRole("table");
  await user.click(screen.getByRole("button", { name: "Nouvelle demande" }));
  return screen.findByRole("dialog", { name: "Nouvelle demande" });
};

const chooseCement = async (user: ReturnType<typeof userEvent.setup>, dialog: HTMLElement) => {
  await user.click(within(dialog).getByRole("textbox", { name: /^Produit/ }));
  await user.click(await screen.findByRole("option", { name: "Ciment CPJ 42,5" }));
};

describe("Demandes : création (CA-MAT-001)", () => {
  it("crée une demande : produit du catalogue, unité préremplie, équivalence en direct, date proposée par le serveur", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ sites: [makeSite()] });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ number: "DEM-010", possibleDuplicateOf: { id: "d12", number: "DEM-012" } }), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/requests");
    const dialog = await openCreateForm(user);

    await chooseCement(user, dialog);
    // Le catalogue préremplit l'unité (jamais un texte libre).
    await waitFor(() => expect((within(dialog).getByRole("textbox", { name: /^Unité/ }) as HTMLInputElement).value).toBe("Sac"));
    await user.type(within(dialog).getByRole("textbox", { name: /^Quantité/ }), "300");
    // « 300 sacs = 15 T » saute aux yeux : une faute de frappe (3000) se voit (CA-MAT-001.3).
    expect(await within(dialog).findByText("Équivalence : 300 sacs = 15 T")).toBeTruthy();

    await user.click(within(dialog).getByRole("button", { name: "Créer" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toEqual({
      productId: "00000000-0000-7000-8000-0000000000d1",
      freeProductName: null,
      quantity: { value: 300, unit: "sac" },
      zoneId: null,
      // Valeur par défaut = aujourd'hui + defaultNeededByDays du serveur (3), date d'Algérie.
      neededBy: addDays(todayDateOnly(), 3),
      priority: "Normal",
      note: null,
    });
    // Ni statut, ni numéro, ni auteur : le serveur les fixe (affectation de masse).
    expect(Object.keys(bodies[0] as object)).not.toContain("status");
    expect(await screen.findByText("Demande DEM-010 créée.")).toBeTruthy();
    expect(await screen.findByText(/Doublon possible de DEM-012/)).toBeTruthy();
  });

  it("refuse un formulaire vide et une décimale pour des sacs, sans appeler le serveur (CA-MAT-001.5, 001.6)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ sites: [makeSite()] });
    const posts: unknown[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests"), async ({ request }) => {
        posts.push(await request.json());
        return HttpResponse.json({});
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/requests");
    const dialog = await openCreateForm(user);

    await user.click(within(dialog).getByRole("button", { name: "Créer" }));
    expect(await within(dialog).findByText("Choisissez un produit ou « Autre produit ».")).toBeTruthy();
    expect(within(dialog).getByText("Choisissez une unité.")).toBeTruthy();
    expect(within(dialog).getByText("Saisissez une quantité.")).toBeTruthy();

    await chooseCement(user, dialog);
    await user.type(within(dialog).getByRole("textbox", { name: /^Quantité/ }), "2,5");
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));
    expect(await within(dialog).findByText("Nombre entier requis pour cette unité.")).toBeTruthy();
    expect(posts).toHaveLength(0);
  });

  it("accepte « Autre produit » avec un nom de 3 à 100 caractères et toutes les unités de la liste (CA-MAT-001.11)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ sites: [makeSite()] });
    const bodies: Record<string, unknown>[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/requests"), async ({ request }) => {
        bodies.push((await request.json()) as Record<string, unknown>);
        return HttpResponse.json(makeRequestDetail({ number: "DEM-011" }), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/materials/requests");
    const dialog = await openCreateForm(user);

    await user.click(within(dialog).getByRole("radio", { name: "Autre produit (hors catalogue)" }));
    await user.type(within(dialog).getByRole("textbox", { name: /^Nom du produit/ }), "Po");
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));
    expect(await within(dialog).findByText("Le nom contient de 3 à 100 caractères.")).toBeTruthy();

    await user.type(within(dialog).getByRole("textbox", { name: /^Nom du produit/ }), "ignées de porte");
    // Aucune unité n'est préchoisie pour un produit libre : « Créer » reste refusé tant qu'elle manque.
    await user.type(within(dialog).getByRole("textbox", { name: /^Quantité/ }), "40");
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));
    expect(await within(dialog).findByText("Choisissez une unité.")).toBeTruthy();
    await user.click(within(dialog).getByRole("textbox", { name: /^Unité/ }));
    await user.click(await screen.findByRole("option", { name: "Pièce" }));
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toMatchObject({ productId: null, freeProductName: "Poignées de porte", quantity: { value: 40, unit: "u" } });
  });

  it("rattache l'erreur du serveur au champ concerné et la traduit selon le code (CA-MAT-001.7)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ sites: [makeSite()] });
    server.use(http.post(apiUrl("/sites/:siteId/requests"), () => problem(422, "QUANTITE_INVALIDE", { errors: { quantity: ["Quantité invalide."] } })));
    const user = userEvent.setup();
    renderApp("/materials/requests");
    const dialog = await openCreateForm(user);

    await chooseCement(user, dialog);
    await user.type(within(dialog).getByRole("textbox", { name: /^Quantité/ }), "10");
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));

    expect(await within(dialog).findByText("La valeur doit être supérieure à 0.")).toBeTruthy();
  });

  it("avertit d'une date de besoin passée sans bloquer (CA-MAT-001.7)", async () => {
    mockSession("ChefChantier");
    mockMaterialsReads({ sites: [makeSite()] });
    server.use(http.get(apiUrl("/settings/materials"), () => HttpResponse.json(makeMaterialSettings({ defaultNeededByDays: -2 }))));
    const user = userEvent.setup();
    renderApp("/materials/requests");
    const dialog = await openCreateForm(user);

    expect(await within(dialog).findByText("Cette date est passée. Vous pouvez enregistrer quand même.")).toBeTruthy();
    expect(within(dialog).getByRole("button", { name: "Créer" }).hasAttribute("disabled")).toBe(false);
  });

  it("affiche le formulaire en arabe : RTL, libellés arabes, quantité de gauche à droite (CA-MAT-001.15)", async () => {
    mockSession("ChefChantier", { language: "ar" });
    mockMaterialsReads({ sites: [makeSite()] });
    const user = userEvent.setup();
    renderApp("/materials/requests", "ar");
    await screen.findByRole("table");
    await user.click(screen.getByRole("button", { name: "طلب جديد" }));

    const dialog = await screen.findByRole("dialog", { name: "طلب جديد" });
    expect(document.documentElement.dir).toBe("rtl");
    expect(within(dialog).getByRole("textbox", { name: /^الكمية/ }).getAttribute("dir")).toBe("ltr");
    expect(within(dialog).getByRole("radio", { name: "مادة أخرى (خارج الفهرس)" })).toBeTruthy();
    expect(within(dialog).getByRole("radio", { name: "معطِّلة للورشة" })).toBeTruthy();
    expect(within(dialog).getByRole("button", { name: "إنشاء" })).toBeTruthy();
  });
});

describe("Demandes : modification (CA-MAT-004)", () => {
  const openEdit = async (user: ReturnType<typeof userEvent.setup>) => {
    const drawer = await screen.findByRole("dialog", { name: "Demande DEM-009" });
    await user.click(await within(drawer).findByRole("button", { name: "Modifier" }));
    return screen.findByRole("dialog", { name: "Modifier la demande DEM-009" });
  };

  it("envoie tous les champs avec la version lue tant que la demande est « Demandée »", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads();
    const bodies: unknown[] = [];
    server.use(
      http.put(apiUrl("/sites/:siteId/requests/:requestId"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ quantity: { value: 400, unit: "sac" }, version: "51011" }));
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    const dialog = await openEdit(user);

    const quantity = within(dialog).getByRole("textbox", { name: /^Quantité/ });
    await user.clear(quantity);
    await user.type(quantity, "400");
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toMatchObject({
      version: "51010",
      productId: "00000000-0000-7000-8000-0000000000d1",
      quantity: { value: 400, unit: "sac" },
      neededBy: "2026-11-28",
      priority: "Blocking",
    });
    expect(await screen.findByText("Demande DEM-009 modifiée.", {}, { timeout: 4000 })).toBeTruthy();
  });

  it("verrouille produit, quantité, unité et zone après la validation : seuls date, urgence et remarque partent (CA-MAT-004.2, 004.3)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads({ detail: makeRequestDetail({ status: "Validated" }) });
    const bodies: unknown[] = [];
    server.use(
      http.put(apiUrl("/sites/:siteId/requests/:requestId"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeRequestDetail({ status: "Validated", priority: "Urgent" }));
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    const dialog = await openEdit(user);

    expect(within(dialog).getByText(/Demande validée : la quantité et le produit ne se modifient plus/)).toBeTruthy();
    expect(within(dialog).getByRole("textbox", { name: /^Quantité/ }).hasAttribute("disabled")).toBe(true);
    expect(within(dialog).getByRole("textbox", { name: /^Unité/ }).hasAttribute("disabled")).toBe(true);

    await user.click(within(dialog).getByRole("radio", { name: "Urgente" }));
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toEqual({ version: "51010", neededBy: "2026-11-28", priority: "Urgent", note: "Dalle +10,20" });
  });

  it("sur 409 CONFLIT_VERSION : indique qui a modifié, puis recharge la version actuelle (CA-MAT-004)", async () => {
    mockSession("ConducteurTravaux");
    mockMaterialsReads();
    server.use(
      http.put(apiUrl("/sites/:siteId/requests/:requestId"), () =>
        problem(409, "CONFLIT_VERSION", { current: makeRequestDetail({ quantity: { value: 450, unit: "sac" }, version: "51020", updatedByName: "Karim A." }) }),
      ),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    const dialog = await openEdit(user);

    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));
    const alert = await within(dialog).findByRole("alert");
    expect(alert.textContent).toContain("Karim A. a modifié cette demande pendant votre saisie.");

    await user.click(within(alert).getByRole("button", { name: "Recharger la version actuelle" }));
    await waitFor(() => expect((within(dialog).getByRole("textbox", { name: /^Quantité/ }) as HTMLInputElement).value).toBe("450"));
  });
});
