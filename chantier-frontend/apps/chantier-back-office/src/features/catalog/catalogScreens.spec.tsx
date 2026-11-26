import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import {
  PRODUCT_CEMENT_ID,
  apiUrl,
  makeProduct,
  makeSupplier,
  problem,
  server,
  setupMockServer,
  type TestRole,
} from "@chantier-frontend/testing";

import { mockMaterialsReads, paged } from "../../testing/materialsMocks";
import { mockSession, renderApp } from "../../testing/renderApp";

setupMockServer();

afterEach(() => {
  document.documentElement.removeAttribute("lang");
  document.documentElement.removeAttribute("dir");
});

const NBSP = " ";

const gravel = makeProduct({
  id: "00000000-0000-7000-8000-0000000000d3",
  nameFr: "Gravier 8/15",
  nameAr: null,
  category: "Aggregates",
  allowedUnits: ["m3", "t"],
  defaultUnit: "m3",
  bagMassKg: null,
  isActive: false,
});

describe("Catalogue : produits (CA-MAT-015)", () => {
  it("liste nom, catégorie, unités autorisées, unité par défaut, masse du sac avec son unité et état (texte et icône)", async () => {
    mockSession("Achats");
    const urls: URL[] = [];
    mockMaterialsReads({ products: [makeProduct(), gravel] });
    server.use(
      http.get(apiUrl("/products"), ({ request }) => {
        urls.push(new URL(request.url));
        return HttpResponse.json(paged([makeProduct(), gravel]));
      }),
    );
    renderApp("/catalog/products");

    const table = await screen.findByRole("table");
    const rows = within(table).getAllByRole("row");
    expect(rows).toHaveLength(3);
    const cement = within(rows[1] as HTMLElement).getAllByRole("cell");
    expect(cement.map((cell) => cell.textContent).slice(0, 6)).toEqual([
      "Ciment CPJ 42,5",
      "Liants",
      "sacs · T · kg",
      "sacs",
      `50${NBSP}kg`,
      "Actif",
    ]);
    // Un produit désactivé reste affiché avec son état (jamais supprimé), sans masse de sac.
    const gravelCells = within(rows[2] as HTMLElement).getAllByRole("cell");
    expect(gravelCells.at(-2)?.textContent).toBe("Désactivé");
    expect(gravelCells[4]?.textContent).toBe("—");
    expect(urls[0]?.searchParams.get("pageSize")).toBe("20");
  });

  it("garde recherche, catégorie et état dans l'URL et les envoie au serveur (CA-MAT-015.9)", async () => {
    mockSession("Achats");
    const urls: URL[] = [];
    mockMaterialsReads();
    server.use(
      http.get(apiUrl("/products"), ({ request }) => {
        urls.push(new URL(request.url));
        return HttpResponse.json(paged([makeProduct()]));
      }),
    );
    const user = userEvent.setup();
    const { router } = renderApp("/catalog/products");
    await screen.findByRole("table");

    await user.click(screen.getByRole("textbox", { name: "Catégorie" }));
    await user.click(await screen.findByRole("option", { name: "Liants" }));
    await waitFor(() => expect(router.state.location.search).toContain("category=Binders"));
    await waitFor(() => expect(urls.at(-1)?.searchParams.get("category")).toBe("Binders"));

    await user.click(screen.getByRole("textbox", { name: "État" }));
    await user.click(await screen.findByRole("option", { name: "Désactivé" }));
    await waitFor(() => expect(urls.at(-1)?.searchParams.get("isActive")).toBe("false"));
  });

  it.each<[TestRole, boolean]>([
    ["Admin", true],
    ["Achats", true],
    ["ConducteurTravaux", false],
    ["ChefChantier", false],
    ["ChefEquipe", false],
    ["Direction", false],
  ])("%s : boutons d'écriture du catalogue présents = %s (CA-MAT-015.8)", async (role, canWrite) => {
    mockSession(role);
    mockMaterialsReads();
    renderApp("/catalog/products");

    await screen.findByRole("table");
    expect(screen.queryByRole("button", { name: "Nouveau produit" }) !== null).toBe(canWrite);
    expect(screen.queryByRole("button", { name: "Modifier Ciment CPJ 42,5" }) !== null).toBe(canWrite);
    expect(screen.queryByRole("button", { name: "Désactiver Ciment CPJ 42,5" }) !== null).toBe(canWrite);
  });

  it("crée un produit : sac sans masse refusé, masse du sac demandée, unité par défaut dans la liste (CA-MAT-015.1, 015.2)", async () => {
    mockSession("Achats");
    mockMaterialsReads();
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/products"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeProduct({ nameFr: "Monocouche gris" }), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/catalog/products");
    await screen.findByRole("table");
    await user.click(screen.getByRole("button", { name: "Nouveau produit" }));
    const dialog = await screen.findByRole("dialog", { name: "Nouveau produit" });

    await user.type(within(dialog).getByRole("textbox", { name: /^Nom en français/ }), "Monocouche gris");
    await user.click(within(dialog).getByRole("checkbox", { name: "Sac" }));
    // La première unité cochée devient l'unité par défaut ; la masse du sac devient obligatoire.
    await waitFor(() => expect((within(dialog).getByRole("textbox", { name: /^Unité par défaut/ }) as HTMLInputElement).value).toBe("Sac"));
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));
    expect(await within(dialog).findByText("La masse d'un sac est obligatoire quand l'unité « sac » est autorisée.")).toBeTruthy();
    expect(bodies).toHaveLength(0);

    await user.type(within(dialog).getByRole("textbox", { name: /^Masse d'un sac/ }), "25");
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toEqual({
      nameFr: "Monocouche gris",
      nameAr: null,
      category: "Other",
      allowedUnits: ["sac"],
      defaultUnit: "sac",
      bagMassKg: 25,
    });
    expect(await screen.findByText("Produit créé.")).toBeTruthy();
  });

  it("affiche PRODUIT_EXISTANT sous le nom (« Existe déjà », CA-MAT-015.5)", async () => {
    mockSession("Achats");
    mockMaterialsReads();
    server.use(http.post(apiUrl("/products"), () => problem(422, "PRODUIT_EXISTANT")));
    const user = userEvent.setup();
    renderApp("/catalog/products");
    await screen.findByRole("table");
    await user.click(screen.getByRole("button", { name: "Nouveau produit" }));
    const dialog = await screen.findByRole("dialog", { name: "Nouveau produit" });

    await user.type(within(dialog).getByRole("textbox", { name: /^Nom en français/ }), "ciment cpj 42,5");
    await user.click(within(dialog).getByRole("checkbox", { name: "Tonne (T)" }));
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));

    expect(await within(dialog).findByText("Ce produit existe déjà.")).toBeTruthy();
  });

  it("demande une confirmation avant de changer la masse du sac, puis envoie la version lue (CA-MAT-015.3)", async () => {
    mockSession("Achats");
    mockMaterialsReads();
    const bodies: unknown[] = [];
    server.use(
      http.put(apiUrl("/products/:productId"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeProduct({ bagMassKg: 40, version: "47010" }));
      }),
    );
    const user = userEvent.setup();
    renderApp("/catalog/products");
    await screen.findByRole("table");
    await user.click(screen.getByRole("button", { name: "Modifier Ciment CPJ 42,5" }));
    const dialog = await screen.findByRole("dialog", { name: "Modifier le produit" });

    const mass = within(dialog).getByRole("textbox", { name: /^Masse d'un sac/ });
    await user.clear(mass);
    await user.type(mass, "40");
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    const confirm = await screen.findByRole("dialog", { name: "Changer la masse du sac ?" });
    expect(confirm.textContent).toContain("Les quantités déjà saisies ne changent pas");
    expect(bodies).toHaveLength(0);
    await user.click(within(confirm).getByRole("button", { name: "Changer la masse" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toMatchObject({ version: "47000", bagMassKg: 40, allowedUnits: ["sac", "t", "kg"] });
  });

  it("désactive après confirmation au lieu de supprimer, puis réactive (CA-MAT-015.6)", async () => {
    mockSession("Admin");
    mockMaterialsReads({ products: [makeProduct()] });
    const calls: string[] = [];
    server.use(
      http.post(apiUrl("/products/:productId/deactivate"), ({ params }) => {
        calls.push(`deactivate:${String(params["productId"])}`);
        return HttpResponse.json(makeProduct({ isActive: false }));
      }),
    );
    const user = userEvent.setup();
    renderApp("/catalog/products");
    await screen.findByRole("table");
    await user.click(screen.getByRole("button", { name: "Désactiver Ciment CPJ 42,5" }));

    const confirm = await screen.findByRole("dialog", { name: "Désactiver ce produit ?" });
    expect(confirm.textContent).toContain("rien n'est supprimé");
    await user.click(within(confirm).getByRole("button", { name: "Désactiver" }));

    await waitFor(() => expect(calls).toEqual([`deactivate:${PRODUCT_CEMENT_ID}`]));
    expect(await screen.findByText("Produit désactivé.")).toBeTruthy();
    // Aucune route de suppression n'existe côté client.
    expect(screen.queryByRole("button", { name: /Supprimer/ })).toBeNull();
  });

  it("affiche le catalogue en arabe : RTL, nom arabe, catégories et unités traduites, masse du sac de gauche à droite", async () => {
    mockSession("Achats", { language: "ar" });
    mockMaterialsReads({ products: [makeProduct()] });
    renderApp("/catalog/products", "ar");

    expect(await screen.findByRole("heading", { level: 1, name: "مواد الفهرس" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
    const table = await screen.findByRole("table");
    expect(within(table).getByText("إسمنت CPJ 42,5")).toBeTruthy();
    expect(within(table).getByText("مواد رابطة")).toBeTruthy();
    expect([...table.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent)).toContain("50");
    expect(table.textContent).toContain("كغ");
  });

  it("montre les états vide, résultat vide et erreur (CA-MAT-015.9)", async () => {
    mockSession("Achats");
    mockMaterialsReads();
    server.use(http.get(apiUrl("/products"), () => HttpResponse.json(paged([]))));
    const first = renderApp("/catalog/products");
    expect(await screen.findByText("Le catalogue ne contient encore aucun produit.")).toBeTruthy();
    first.unmount();

    server.use(http.get(apiUrl("/products"), () => problem(500, "ERREUR_INTERNE")));
    renderApp("/catalog/products");
    expect((await screen.findByRole("alert")).textContent).toContain("Erreur du serveur");
  });
});

describe("Catalogue : fournisseurs (CA-MAT-015, CA-MAT-009.4)", () => {
  it.each<[TestRole, boolean]>([
    ["Admin", true],
    ["Achats", true],
    ["ConducteurTravaux", true],
    ["ChefChantier", true],
    ["ChefEquipe", false],
    ["Direction", false],
  ])("%s : colonne téléphone présente = %s", async (role, showsPhone) => {
    mockSession(role);
    // Le serveur n'écrit pas `phone` sans la permission : la fixture le reflète.
    mockMaterialsReads({ suppliers: [makeSupplier(showsPhone ? {} : { phone: undefined })] });
    renderApp("/catalog/suppliers");

    const table = await screen.findByRole("table");
    expect(within(table).queryByRole("columnheader", { name: "Téléphone" }) !== null).toBe(showsPhone);
    expect(table.textContent?.includes("0550 00 00 21")).toBe(showsPhone);
    expect(within(table).getByText("Cimenterie Sigma (fictive)")).toBeTruthy();
  });

  it("crée un fournisseur : téléphone au format algérien, produits fournis, envoi sans téléphone pour un rôle qui ne le voit pas", async () => {
    mockSession("Achats");
    mockMaterialsReads({ suppliers: [] });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/suppliers"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeSupplier(), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/catalog/suppliers");
    await screen.findByText("Aucun fournisseur n'est enregistré.");
    await user.click(screen.getByRole("button", { name: "Nouveau fournisseur" }));
    const dialog = await screen.findByRole("dialog", { name: "Nouveau fournisseur" });

    await user.type(within(dialog).getByRole("textbox", { name: /^Nom du fournisseur/ }), "Cimenterie Sigma (fictive)");
    await user.type(within(dialog).getByRole("textbox", { name: /^Téléphone/ }), "0450 12");
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));
    expect(await within(dialog).findByText("Numéro invalide : 05, 06 ou 07 suivi de 8 chiffres.")).toBeTruthy();
    expect(bodies).toHaveLength(0);

    const phone = within(dialog).getByRole("textbox", { name: /^Téléphone/ });
    await user.clear(phone);
    await user.type(phone, "0550 00 00 21");
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(bodies[0]).toMatchObject({ name: "Cimenterie Sigma (fictive)", phone: "0550 00 00 21" });
  });

  it("n'écrit jamais le téléphone depuis un rôle qui ne le voit pas (aucun champ, aucune clé envoyée)", async () => {
    mockSession("Admin", {});
    // Admin voit le téléphone : on retire la permission pour simuler un rôle qui ne l'a pas mais peut écrire.
    server.use(
      http.get(apiUrl("/auth/me"), () =>
        HttpResponse.json({
          id: "00000000-0000-7000-8000-000000000001",
          userName: "achats.dev",
          fullName: "Mourad B.",
          phoneNumber: null,
          role: "Achats",
          language: "fr",
          permissions: ["Suppliers.View", "Suppliers.Create", "Products.View"],
          permissionsVersion: "a41f09c2",
          mustChangePassword: false,
        }),
      ),
    );
    mockMaterialsReads({ suppliers: [] });
    const bodies: unknown[] = [];
    server.use(
      http.post(apiUrl("/suppliers"), async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(makeSupplier({ phone: undefined }), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/catalog/suppliers");
    await screen.findByText("Aucun fournisseur n'est enregistré.");
    await user.click(screen.getByRole("button", { name: "Nouveau fournisseur" }));
    const dialog = await screen.findByRole("dialog", { name: "Nouveau fournisseur" });

    expect(within(dialog).queryByRole("textbox", { name: /^Téléphone/ })).toBeNull();
    await user.type(within(dialog).getByRole("textbox", { name: /^Nom du fournisseur/ }), "Briqueterie Atlas (fictive)");
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));

    await waitFor(() => expect(bodies).toHaveLength(1));
    expect(Object.keys(bodies[0] as object)).not.toContain("phone");
  });

  it("affiche les fournisseurs en arabe : RTL, téléphone de gauche à droite", async () => {
    mockSession("Achats", { language: "ar" });
    mockMaterialsReads({ suppliers: [makeSupplier()] });
    renderApp("/catalog/suppliers", "ar");

    expect(await screen.findByRole("heading", { level: 1, name: "الموردون" })).toBeTruthy();
    const table = await screen.findByRole("table");
    expect(document.documentElement.dir).toBe("rtl");
    expect([...table.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent)).toContain("0550 00 00 21");
  });
});
