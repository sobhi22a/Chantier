import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import type { SiteResponse, ZoneResponse } from "@chantier-frontend/api-core";
import {
  SITE_UV18_ID,
  apiUrl,
  makeSite,
  makeZone,
  problem,
  server,
  setupMockServer,
  type TestRole,
} from "@chantier-frontend/testing";

import { mockSession, renderApp } from "../../testing/renderApp";

setupMockServer();

const MINUS = "−";
const detailPath = `/sites/${SITE_UV18_ID}`;

const wilayas = [
  { code: "09", nameFr: "Blida", nameAr: "البليدة" },
  { code: "16", nameFr: "Alger", nameAr: "الجزائر" },
];
const communes = [
  { nameFr: "Boufarik", nameAr: "بوفاريك" },
  { nameFr: "Blida", nameAr: "البليدة" },
];

const mockDetail = (role: TestRole, site: SiteResponse = makeSite(), zones: ZoneResponse[] = [makeZone()], language: "fr" | "ar" = "fr") => {
  mockSession(role, { language });
  server.use(
    http.get(apiUrl("/sites/:siteId"), () => HttpResponse.json(site)),
    http.get(apiUrl("/sites/:siteId/zones"), () => HttpResponse.json({ items: zones, nextCursor: null })),
    http.get(apiUrl("/sites/:siteId/members"), () => HttpResponse.json({ items: [] })),
    http.get(apiUrl("/reference/wilayas"), () => HttpResponse.json(wilayas)),
    http.get(apiUrl("/reference/wilayas/:code/communes"), () => HttpResponse.json(communes)),
  );
};

/** Champ par son libellé (Mantine ajoute « * » aux champs obligatoires et peut dupliquer le libellé du champ caché). */
const field = (dialog: HTMLElement, label: RegExp): HTMLInputElement => within(dialog).getAllByLabelText(label)[0] as HTMLInputElement;

/** Texte de l'aperçu de la zone (les morceaux sont dans des éléments distincts). */
const preview = (dialog: HTMLElement): string => within(dialog).getByText("Aperçu").parentElement?.textContent ?? "";

const openZoneForm = async (user: ReturnType<typeof userEvent.setup>) => {
  await screen.findByRole("region", { name: "Bloc 01" });
  await user.click(screen.getByRole("button", { name: "Ajouter une zone" }));
  return screen.findByRole("dialog", { name: "Nouvelle zone" });
};

describe("formulaire zone (CT-17, CA-011.2, CA-011.3)", () => {
  afterEach(() => {
    document.documentElement.removeAttribute("lang");
    document.documentElement.removeAttribute("dir");
  });

  it("crée une zone : la cote 3,4 part en nombre +3,40, sans clientId, avec un aperçu signé", async () => {
    mockDetail("ConducteurTravaux");
    let body: unknown;
    server.use(
      http.post(apiUrl("/sites/:siteId/zones"), async ({ request }) => {
        body = await request.json();
        return HttpResponse.json(makeZone({ id: "new", roomNumber: 7 }), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    const dialog = await openZoneForm(user);

    // Bloc préchoisi : le premier bloc connu du chantier.
    expect((field(dialog, /^Bloc/)).value).toBe("Bloc 01");
    await user.type(within(dialog).getByLabelText(/^Cote/), "3,4");
    await user.click(field(dialog, /^Type de local/));
    await user.click(await screen.findByRole("option", { name: "Classe" }));
    await user.type(within(dialog).getByLabelText("Numéro du local"), "7");

    expect(preview(dialog)).toContain("Bloc 01 · +3,40 m · Classe 07");
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));

    await waitFor(() => expect(body).toBeDefined());
    expect(body).toEqual({ block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 7, roomLabel: null });
    expect(await screen.findByText("Zone ajoutée.")).toBeTruthy();
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
  });

  it("accepte la cote négative avec le vrai signe moins et l'écrit −1,90 dans l'aperçu", async () => {
    mockDetail("ConducteurTravaux");
    const user = userEvent.setup();
    renderApp(detailPath);
    const dialog = await openZoneForm(user);

    await user.type(within(dialog).getByLabelText(/^Cote/), `${MINUS}1,9`);

    expect(preview(dialog)).toContain(`Bloc 01 · ${MINUS}1,90 m`);
  });

  it.each(["61", "-20,5", "abc"])("refuse la cote %s sans appeler le serveur, avec un message clair", async (elevation) => {
    mockDetail("ConducteurTravaux");
    let posted = false;
    server.use(
      http.post(apiUrl("/sites/:siteId/zones"), () => {
        posted = true;
        return HttpResponse.json(makeZone(), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    const dialog = await openZoneForm(user);

    await user.type(within(dialog).getByLabelText(/^Cote/), elevation);
    await user.click(within(dialog).getByRole("button", { name: "Créer" }));

    const expected = elevation === "abc" ? "Saisir un nombre en mètres" : "La cote est en dehors de la plage autorisée.";
    expect((await within(dialog).findByText(new RegExp(expected))).textContent).toContain(expected);
    expect(posted).toBe(false);
  });

  it("affiche l'unité (mètre) à côté de la cote et la plage autorisée", async () => {
    mockDetail("ConducteurTravaux");
    const user = userEvent.setup();
    renderApp(detailPath);
    const dialog = await openZoneForm(user);

    expect(dialog.textContent).toContain(`Plage autorisée : de ${MINUS}20,00 m à +60,00 m.`);
    expect(within(dialog).getAllByText("m").length).toBeGreaterThan(0);
  });

  it.each([
    ["fr", "Cette zone existe déjà."],
    ["ar", "هذه المنطقة موجودة من قبل."],
  ] as const)("affiche ZONE_EXISTANTE (%s) traduit depuis le code, dans une alerte du formulaire", async (language, message) => {
    mockDetail("ConducteurTravaux", makeSite(), [makeZone()], language);
    server.use(http.post(apiUrl("/sites/:siteId/zones"), () => problem(422, "ZONE_EXISTANTE", { detail: "texte serveur" })));
    const user = userEvent.setup();
    renderApp(detailPath, language);
    await screen.findByRole("region", { name: "Bloc 01" });
    await user.click(screen.getByRole("button", { name: language === "fr" ? "Ajouter une zone" : "إضافة منطقة" }));
    const dialog = await screen.findByRole("dialog");

    await user.click(within(dialog).getByRole("button", { name: language === "fr" ? "Créer" : "إنشاء" }));

    const alert = await within(dialog).findByRole("alert");
    expect(alert.textContent).toContain(message);
    expect(alert.textContent).not.toContain("texte serveur");
  });

  it("rattache une erreur 400 par champ du serveur au champ concerné", async () => {
    mockDetail("ConducteurTravaux");
    server.use(
      http.post(apiUrl("/sites/:siteId/zones"), () =>
        problem(400, "VALIDATION", { errors: { elevation: ["La cote est hors plage (message serveur)."] } }),
      ),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    const dialog = await openZoneForm(user);

    await user.click(within(dialog).getByRole("button", { name: "Créer" }));

    expect(await within(dialog).findByText("Valeur invalide.")).toBeTruthy();
    expect(dialog.textContent).not.toContain("message serveur");
  });

  it("modifie une zone en renvoyant la version lue ; sur 409 propose de recharger la version actuelle", async () => {
    mockDetail("ConducteurTravaux", makeSite(), [makeZone({ id: "zz1", version: "100" })]);
    const bodies: unknown[] = [];
    server.use(
      http.put(apiUrl("/sites/:siteId/zones/:zoneId"), async ({ request }) => {
        bodies.push(await request.json());
        return problem(409, "CONFLIT_VERSION", {
          current: makeZone({ id: "zz1", version: "101", elevation: 6.8, updatedByName: "Farid L.", updatedAt: "2026-11-24T10:00:00Z" }),
        });
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    await screen.findByRole("region", { name: "Bloc 01" });

    await user.click(screen.getByRole("button", { name: /^Modifier la zone/ }));
    const dialog = await screen.findByRole("dialog", { name: "Modifier la zone" });
    expect((within(dialog).getByLabelText(/^Cote/) as HTMLInputElement).value).toBe("3,4");
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    const alert = await within(dialog).findByRole("alert");
    expect(alert.textContent).toContain("Modifié entre-temps");
    expect(alert.textContent).toContain("Farid L.");
    expect(bodies).toEqual([{ version: "100", block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 2, roomLabel: null }]);

    await user.click(within(dialog).getByRole("button", { name: "Recharger la version actuelle" }));

    await waitFor(() => expect((within(dialog).getByLabelText(/^Cote/) as HTMLInputElement).value).toBe("6,8"));
    expect(within(dialog).queryByRole("alert")).toBeNull();
  });

  it("affiche le formulaire de zone en arabe, de droite à gauche, la cote restant de gauche à droite", async () => {
    mockDetail("ConducteurTravaux", makeSite(), [makeZone()], "ar");
    const user = userEvent.setup();
    renderApp(detailPath, "ar");
    await screen.findByRole("region", { name: "Bloc 01" });
    await user.click(screen.getByRole("button", { name: "إضافة منطقة" }));
    const dialog = await screen.findByRole("dialog", { name: "منطقة جديدة" });

    expect(document.documentElement.dir).toBe("rtl");
    expect(within(dialog).getByLabelText(/^المنسوب/).getAttribute("dir")).toBe("ltr");
    expect(dialog.textContent).toContain(`المجال المسموح به: من \u2066${MINUS}20,00 m\u2069 إلى \u2066+60,00 m\u2069.`);
    await user.type(within(dialog).getByLabelText(/^المنسوب/), "3,4");
    const ltrValues = [...dialog.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent);
    expect(ltrValues).toContain("+3,40 m");
  });
});

describe("formulaire chantier (CT-7, CT-18, CA-008)", () => {
  afterEach(() => {
    document.documentElement.removeAttribute("lang");
    document.documentElement.removeAttribute("dir");
  });

  const mockList = () =>
    server.use(
      http.get(apiUrl("/sites"), () => HttpResponse.json({ items: [], page: 1, pageSize: 20, totalCount: 0 })),
      http.get(apiUrl("/reference/wilayas"), () => HttpResponse.json(wilayas)),
      http.get(apiUrl("/reference/wilayas/:code/communes"), () => HttpResponse.json(communes)),
    );

  const openSiteForm = async (user: ReturnType<typeof userEvent.setup>) => {
    await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });
    await user.click(screen.getByRole("button", { name: "Nouveau chantier" }));
    return screen.findByRole("dialog", { name: "Nouveau chantier" });
  };

  const choose = async (user: ReturnType<typeof userEvent.setup>, dialog: HTMLElement, label: RegExp, option: string) => {
    await user.click(field(dialog, label));
    await user.click(await screen.findByRole("option", { name: option }));
  };

  it("propose le code depuis le serveur, charge les communes de la wilaya puis crée le chantier", async () => {
    mockSession("Admin");
    mockList();
    const suggestions: URL[] = [];
    let body: unknown;
    server.use(
      http.get(apiUrl("/sites/code-suggestion"), ({ request }) => {
        suggestions.push(new URL(request.url));
        return HttpResponse.json({ code: "CH-ECO-UV18" });
      }),
      http.post(apiUrl("/sites"), async ({ request }) => {
        body = await request.json();
        return HttpResponse.json(makeSite(), { status: 201 });
      }),
      http.get(apiUrl("/sites/:siteId"), () => HttpResponse.json(makeSite())),
      http.get(apiUrl("/sites/:siteId/zones"), () => HttpResponse.json({ items: [], nextCursor: null })),
      http.get(apiUrl("/sites/:siteId/members"), () => HttpResponse.json({ items: [] })),
    );
    const user = userEvent.setup();
    const { router } = renderApp("/sites");
    const dialog = await openSiteForm(user);

    await user.type(field(dialog, /^Nom \*?$/), "École UV18");
    await user.tab();
    await waitFor(() => expect(field(dialog, /^Code/).value).toBe("CH-ECO-UV18"));
    expect(suggestions[0]?.searchParams.get("name")).toBe("École UV18");
    expect(suggestions[0]?.searchParams.get("type")).toBe("School");

    await choose(user, dialog, /^Wilaya/, "Blida");
    await user.click(field(dialog, /^Commune/));
    await user.click(await screen.findByRole("option", { name: "Boufarik" }));
    await user.type(within(dialog).getByLabelText(/^Maître d'ouvrage/), "Direction des équipements publics (fictive)");
    await user.type(within(dialog).getByLabelText(/^Délai/), "540");
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    await waitFor(() => expect(body).toBeDefined());
    expect(body).toEqual({
      code: "CH-ECO-UV18",
      name: "École UV18",
      nameAr: null,
      type: "School",
      wilaya: "Blida",
      commune: "Boufarik",
      owner: "Direction des équipements publics (fictive)",
      contractNumber: null,
      contractAmount: null,
      delayDays: 540,
      odsDate: null,
      latitude: null,
      longitude: null,
    });
    // La fiche du chantier créé s'ouvre (CA-008.1).
    await waitFor(() => expect(router.state.location.pathname).toBe(detailPath));
  });

  it("refuse un formulaire vide avec les champs obligatoires indiqués, sans appeler le serveur", async () => {
    mockSession("Admin");
    mockList();
    let posted = false;
    server.use(
      http.post(apiUrl("/sites"), () => {
        posted = true;
        return HttpResponse.json(makeSite(), { status: 201 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/sites");
    const dialog = await openSiteForm(user);

    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    expect((await within(dialog).findAllByText("Ce champ est obligatoire.")).length).toBeGreaterThanOrEqual(3);
    expect(within(dialog).getByText("Le code contient 3 à 30 caractères : lettres majuscules, chiffres et tirets.")).toBeTruthy();
    expect(posted).toBe(false);
  });

  it("affiche CODE_CHANTIER_EXISTANT sous le champ code (CA-008.3)", async () => {
    mockSession("Admin");
    mockList();
    server.use(
      http.get(apiUrl("/sites/code-suggestion"), () => HttpResponse.json({ code: "CH-ECO-UV18" })),
      http.post(apiUrl("/sites"), () => problem(422, "CODE_CHANTIER_EXISTANT")),
    );
    const user = userEvent.setup();
    renderApp("/sites");
    const dialog = await openSiteForm(user);

    await user.type(field(dialog, /^Nom \*?$/), "École UV18");
    await user.tab();
    await waitFor(() => expect(field(dialog, /^Code/).value).toBe("CH-ECO-UV18"));
    await choose(user, dialog, /^Wilaya/, "Blida");
    await user.type(field(dialog, /^Commune/), "Boufarik");
    await user.type(within(dialog).getByLabelText(/^Maître d'ouvrage/), "MOA fictif");
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    expect(await within(dialog).findByText("Ce code de chantier est déjà utilisé.")).toBeTruthy();
    expect(within(dialog).queryByRole("alert")).toBeNull();
  });

  it("modifie un chantier : version lue envoyée, code verrouillé et absent de la requête", async () => {
    mockDetail("Admin");
    let body: Record<string, unknown> | undefined;
    server.use(
      http.put(apiUrl("/sites/:siteId"), async ({ request }) => {
        body = (await request.json()) as Record<string, unknown>;
        return HttpResponse.json(makeSite({ name: "École UV18 bis", version: "48214" }));
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    await screen.findByRole("heading", { level: 1, name: "École UV18" });

    await user.click(screen.getByRole("button", { name: "Modifier" }));
    const dialog = await screen.findByRole("dialog", { name: "Modifier le chantier" });
    const code = within(dialog).getByLabelText(/^Code/) as HTMLInputElement;
    expect(code.value).toBe("CH-ECO-UV18");
    expect(code.disabled).toBe(true);
    expect((within(dialog).getByLabelText(/^Délai/) as HTMLInputElement).value).toBe("540");
    expect((within(dialog).getByLabelText(/^Montant du marché/) as HTMLInputElement).value).toBe("185 000 000,00");

    const name = field(dialog, /^Nom \*?$/);
    await user.clear(name);
    await user.type(name, "École UV18 bis");
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    await waitFor(() => expect(body).toBeDefined());
    expect(body).toMatchObject({ version: "48213", name: "École UV18 bis", delayDays: 540, odsDate: "2026-03-02", contractAmount: 185000000 });
    expect(body).not.toHaveProperty("code");
    expect(await screen.findByText("Chantier modifié.")).toBeTruthy();
  });

  it("sur 409 CONFLIT_VERSION : « Modifié entre-temps par … » et rechargement de la version actuelle (CT-7)", async () => {
    mockDetail("Admin");
    server.use(
      http.put(apiUrl("/sites/:siteId"), () =>
        problem(409, "CONFLIT_VERSION", {
          current: makeSite({ name: "École UV18 (modifiée)", version: "48299", updatedByName: "Meriem S.", updatedAt: "2026-11-24T10:00:00Z" }),
        }),
      ),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    await screen.findByRole("heading", { level: 1, name: "École UV18" });
    await user.click(screen.getByRole("button", { name: "Modifier" }));
    const dialog = await screen.findByRole("dialog", { name: "Modifier le chantier" });

    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    const alert = await within(dialog).findByRole("alert");
    expect(alert.textContent).toContain("Modifié entre-temps");
    expect(alert.textContent).toContain("Ce chantier a été modifié par Meriem S. avant votre enregistrement.");

    await user.click(within(dialog).getByRole("button", { name: "Recharger la version actuelle" }));

    await waitFor(() => expect((field(dialog, /^Nom \*?$/) as HTMLInputElement).value).toBe("École UV18 (modifiée)"));
    expect(within(dialog).queryByRole("alert")).toBeNull();
  });

  it("rattache DATE_INVALIDE au champ de la date d'ODS (CA-008.4)", async () => {
    mockDetail("Admin");
    server.use(http.put(apiUrl("/sites/:siteId"), () => problem(400, "DATE_INVALIDE")));
    const user = userEvent.setup();
    renderApp(detailPath);
    await screen.findByRole("heading", { level: 1, name: "École UV18" });
    await user.click(screen.getByRole("button", { name: "Modifier" }));
    const dialog = await screen.findByRole("dialog", { name: "Modifier le chantier" });

    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    expect(await within(dialog).findByText("La date est incomplète ou impossible. Choisissez une date complète.")).toBeTruthy();
  });

  it("n'affiche pas le champ montant quand le rôle ne le voit pas (aucune donnée du montant dans le formulaire)", async () => {
    // Rôle fictif avec le droit de modifier mais sans voir le montant : le formulaire ne propose pas le champ.
    const site = makeSite();
    delete site.contractAmount;
    mockSession("Admin", {
      permissions: ["Sites.View", "Sites.Update", "Sites.Delete", "Zones.View", "SiteMembers.View"],
    });
    server.use(
      http.get(apiUrl("/sites/:siteId"), () => HttpResponse.json(site)),
      http.get(apiUrl("/sites/:siteId/zones"), () => HttpResponse.json({ items: [], nextCursor: null })),
      http.get(apiUrl("/sites/:siteId/members"), () => HttpResponse.json({ items: [] })),
      http.get(apiUrl("/reference/wilayas"), () => HttpResponse.json(wilayas)),
      http.get(apiUrl("/reference/wilayas/:code/communes"), () => HttpResponse.json(communes)),
    );
    let body: Record<string, unknown> | undefined;
    server.use(
      http.put(apiUrl("/sites/:siteId"), async ({ request }) => {
        body = (await request.json()) as Record<string, unknown>;
        return HttpResponse.json(site);
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    await screen.findByRole("heading", { level: 1, name: "École UV18" });
    await user.click(screen.getByRole("button", { name: "Modifier" }));
    const dialog = await screen.findByRole("dialog", { name: "Modifier le chantier" });

    expect(within(dialog).queryByLabelText(/^Montant du marché/)).toBeNull();
    await user.click(within(dialog).getByRole("button", { name: "Enregistrer" }));

    await waitFor(() => expect(body).toBeDefined());
    expect(body).not.toHaveProperty("contractAmount");
  });

  it("affiche le formulaire chantier en arabe : libellés arabes, RTL, code de gauche à droite (CT-11)", async () => {
    mockSession("Admin", { language: "ar" });
    mockList();
    const user = userEvent.setup();
    renderApp("/sites", "ar");
    await screen.findByRole("heading", { level: 1, name: "ورشاتي" });

    await user.click(screen.getByRole("button", { name: "ورشة جديدة" }));
    const dialog = await screen.findByRole("dialog", { name: "ورشة جديدة" });

    expect(document.documentElement.dir).toBe("rtl");
    expect(within(dialog).getByLabelText(/^الرمز/).getAttribute("dir")).toBe("ltr");
    expect(within(dialog).getByLabelText(/^الاسم بالعربية/).getAttribute("dir")).toBe("rtl");
    for (const label of [/^الولاية/, /^البلدية/, /^صاحب المشروع/, /^الأجل/, /^مبلغ الصفقة/, /^أمر بالخدمة/]) {
      expect(field(dialog, label)).toBeTruthy();
    }
    await user.click(within(dialog).getByRole("button", { name: "حفظ" }));
    expect((await within(dialog).findAllByText("هذا الحقل إجباري.")).length).toBeGreaterThanOrEqual(3);
  });
});
