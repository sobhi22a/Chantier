import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import type { SiteResponse, ZoneResponse } from "@chantier-frontend/api-core";
import {
  SITE_OL40_ID,
  SITE_UV18_ID,
  apiUrl,
  makeMember,
  makeSite,
  makeZone,
  problem,
  server,
  setupMockServer,
  type TestRole,
} from "@chantier-frontend/testing";

import { mockSession, renderApp } from "../../testing/renderApp";

setupMockServer();

const NBSP = " ";
const MINUS = "−";

const page = (items: SiteResponse[], totalCount = items.length, pageNumber = 1) => ({
  items,
  page: pageNumber,
  pageSize: 20,
  totalCount,
});

/** Zones de démonstration « École UV18 » : cotes −1,90 · ±0,00 · +3,40 · +6,80 et locaux (donnees-test.md). */
const uv18Zones: ZoneResponse[] = [
  makeZone({ id: "z-10", block: "Bloc 01", elevation: 10.2, roomType: null, roomNumber: null }),
  makeZone({ id: "z-2", block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 2 }),
  makeZone({ id: "z-m1", block: "Bloc 01", elevation: -1.9, roomType: null, roomNumber: null }),
  makeZone({ id: "z-0", block: "Bloc 01", elevation: 0, roomType: "Corridor", roomNumber: null }),
  makeZone({ id: "z-b2", block: "Bloc 02", elevation: 0, roomType: "Canteen", roomNumber: null }),
  makeZone({ id: "z-f", block: "Bloc 02", elevation: null, roomType: "Other", roomNumber: null, roomLabel: "Façade cantine" }),
];

const mockSite = (site: SiteResponse = makeSite(), zones: ZoneResponse[] = uv18Zones, role?: TestRole) => {
  if (role) mockSession(role);
  server.use(
    http.get(apiUrl("/sites/:siteId"), () => HttpResponse.json(site)),
    http.get(apiUrl("/sites/:siteId/zones"), () => HttpResponse.json({ items: zones, nextCursor: null })),
    http.get(apiUrl("/sites/:siteId/members"), () =>
      HttpResponse.json({
        items: [
          makeMember({ userId: "u1", fullName: "Mourad B.", role: "ChefChantier" }),
          makeMember({ userId: "u2", fullName: "Toufik G.", role: "ChefEquipe" }),
        ],
      }),
    ),
  );
};

const detailPath = `/sites/${SITE_UV18_ID}`;

describe("Mes chantiers : liste (CT-3, CT-11)", () => {
  afterEach(() => {
    document.documentElement.removeAttribute("lang");
    document.documentElement.removeAttribute("dir");
  });

  it("affiche code, nom, commune / wilaya et fin contractuelle calculée par le serveur (français)", async () => {
    mockSession("ConducteurTravaux");
    const requests: URL[] = [];
    server.use(
      http.get(apiUrl("/sites"), ({ request }) => {
        requests.push(new URL(request.url));
        return HttpResponse.json(
          page([
            makeSite(),
            makeSite({ id: SITE_OL40_ID, code: "CH-LOG-OL40", name: "40 logements Les Oliviers", type: "Housing", contractualEndDate: null }),
          ]),
        );
      }),
    );
    renderApp("/sites");

    const table = await screen.findByRole("table");
    const rows = within(table).getAllByRole("row");
    expect(rows).toHaveLength(3);
    const first = within(rows[1] as HTMLElement).getAllByRole("cell");
    expect(first.map((cell) => cell.textContent)).toEqual(["CH-ECO-UV18", "École UV18", "Boufarik / Blida", "24/08/2027", "Actif"]);
    // Fin contractuelle absente : « À définir », jamais une date inventée (CA-007.3).
    expect(within(rows[2] as HTMLElement).getAllByRole("cell")[3]?.textContent).toBe("À définir");
    expect(requests[0]?.searchParams.get("pageSize")).toBe("20");
    expect(requests[0]?.searchParams.get("page")).toBe("1");
  });

  it("affiche la liste en arabe : nom arabe, RTL, codes et dates de gauche à droite (CA-014.4, CA-014.6)", async () => {
    mockSession("ConducteurTravaux", { language: "ar" });
    server.use(
      http.get(apiUrl("/sites"), () =>
        HttpResponse.json(page([makeSite({ nameAr: "مدرسة UV18" }), makeSite({ id: SITE_OL40_ID, code: "CH-LOG-OL40", name: "40 logements", nameAr: null })])),
      ),
    );
    renderApp("/sites", "ar");

    expect(await screen.findByRole("heading", { level: 1, name: "ورشاتي" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
    const table = screen.getByRole("table");
    expect(within(table).getByRole("columnheader", { name: "الرمز" })).toBeTruthy();
    expect(within(table).getByRole("link", { name: "مدرسة UV18" })).toBeTruthy();
    // Sans nom arabe : le nom français (H-20).
    expect(within(table).getByRole("link", { name: "40 logements" })).toBeTruthy();
    const ltr = [...table.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent);
    expect(ltr).toContain("CH-ECO-UV18");
    expect(ltr).toContain("24/08/2027");
    expect(within(table).getAllByText("نشطة").length).toBeGreaterThan(0);
  });

  it("montre l'état vide avec « Actualiser » (CA-006.3), en français puis en arabe", async () => {
    mockSession("ChefChantier");
    server.use(http.get(apiUrl("/sites"), () => HttpResponse.json(page([]))));
    const { unmount } = renderApp("/sites");
    expect(await screen.findByText("Aucun chantier ne vous est affecté. Contactez votre administrateur.")).toBeTruthy();
    expect(screen.getByRole("button", { name: "Actualiser" })).toBeTruthy();
    unmount();

    mockSession("ChefChantier", { language: "ar" });
    renderApp("/sites", "ar");
    expect(await screen.findByText("لم تُسنَد إليك أي ورشة. اتصل بالمسؤول.")).toBeTruthy();
    expect(screen.getByRole("button", { name: "تحديث" })).toBeTruthy();
  });

  it("montre l'état d'erreur traduit avec la référence du support et « Réessayer »", async () => {
    mockSession("ChefChantier");
    let fail = true;
    server.use(
      http.get(apiUrl("/sites"), () => (fail ? problem(500, "ERREUR_INTERNE") : HttpResponse.json(page([makeSite()])))),
    );
    const user = userEvent.setup();
    renderApp("/sites");

    const alert = await screen.findByRole("alert");
    expect(alert.textContent).toContain("Erreur du serveur");
    expect(alert.textContent).toContain("Référence pour le support : 00-test-trace");

    fail = false;
    await user.click(screen.getByRole("button", { name: "Réessayer" }));
    expect(await screen.findByRole("table")).toBeTruthy();
  });

  it("reflète les filtres de l'URL dans la requête serveur (lien partageable)", async () => {
    mockSession("Admin");
    const requests: URL[] = [];
    server.use(
      http.get(apiUrl("/sites"), ({ request }) => {
        requests.push(new URL(request.url));
        return HttpResponse.json(page([makeSite()], 45, 2));
      }),
    );
    renderApp("/sites?q=uv18&type=School&archived=1&page=2");

    await screen.findByRole("table");
    const url = requests[0] as URL;
    expect(url.searchParams.get("q")).toBe("uv18");
    expect(url.searchParams.get("type")).toBe("School");
    expect(url.searchParams.get("includeArchived")).toBe("true");
    expect(url.searchParams.get("page")).toBe("2");
    expect((screen.getByLabelText("Rechercher par nom ou code") as HTMLInputElement).value).toBe("uv18");
    expect((screen.getByLabelText("Afficher les archivés") as HTMLInputElement).checked).toBe(true);
  });

  it("recherche côté serveur et met la recherche dans l'URL", async () => {
    mockSession("Admin");
    const requests: URL[] = [];
    server.use(
      http.get(apiUrl("/sites"), ({ request }) => {
        requests.push(new URL(request.url));
        return HttpResponse.json(page([makeSite()]));
      }),
    );
    const user = userEvent.setup();
    const { router } = renderApp("/sites");
    await screen.findByRole("table");

    await user.type(screen.getByLabelText("Rechercher par nom ou code"), "ol40");

    await waitFor(() => expect(requests.at(-1)?.searchParams.get("q")).toBe("ol40"));
    expect(router.state.location.search).toBe("?q=ol40");
  });

  it("pagine côté serveur : 45 chantiers = 3 pages, la page choisie va dans l'URL", async () => {
    mockSession("Admin");
    const requests: URL[] = [];
    server.use(
      http.get(apiUrl("/sites"), ({ request }) => {
        const url = new URL(request.url);
        requests.push(url);
        return HttpResponse.json(page([makeSite()], 45, Number(url.searchParams.get("page"))));
      }),
    );
    const user = userEvent.setup();
    const { router } = renderApp("/sites");
    await screen.findByRole("table");
    expect(screen.getByText("45 éléments")).toBeTruthy();

    await user.click(screen.getByRole("button", { name: "Page 2 sur 3" }));

    await waitFor(() => expect(requests.at(-1)?.searchParams.get("page")).toBe("2"));
    expect(router.state.location.search).toBe("?page=2");
  });

  it("affiche un chantier archivé avec le texte « Archivé » (pas la couleur seule)", async () => {
    mockSession("Admin");
    server.use(http.get(apiUrl("/sites"), () => HttpResponse.json(page([makeSite({ archivedAt: "2026-11-01T08:00:00Z" })]))));
    renderApp("/sites?archived=1");

    const row = (await screen.findAllByRole("row"))[1] as HTMLElement;
    expect(within(row).getByText("Archivé")).toBeTruthy();
  });

  it.each([
    ["Admin", true],
    ["Direction", false],
    ["ConducteurTravaux", false],
    ["Achats", false],
    ["ChefChantier", false],
    ["ChefEquipe", false],
  ] as const)("%s : bouton « Nouveau chantier » présent = %s (absent, jamais grisé)", async (role, visible) => {
    mockSession(role);
    server.use(http.get(apiUrl("/sites"), () => HttpResponse.json(page([makeSite()]))));
    renderApp("/sites");

    await screen.findByRole("table");
    expect(screen.queryByRole("button", { name: "Nouveau chantier" }) !== null).toBe(visible);
  });
});

describe("Fiche chantier (CT-3, CT-18, CT-20, CT-17)", () => {
  afterEach(() => {
    document.documentElement.removeAttribute("lang");
    document.documentElement.removeAttribute("dir");
  });

  it("affiche informations, montant, fin contractuelle 24/08/2027, zones par bloc et personnes affectées (français)", async () => {
    mockSite(makeSite(), uv18Zones, "ConducteurTravaux");
    renderApp(detailPath);

    expect(await screen.findByRole("heading", { level: 1, name: "École UV18" })).toBeTruthy();
    const main = screen.getByRole("main");
    const text = main.textContent ?? "";
    expect(text).toContain("CH-ECO-UV18");
    expect(text).toContain("Blida");
    expect(text).toContain("Boufarik");
    expect(text).toContain(`185${NBSP}000${NBSP}000,00${NBSP}DZD`);
    expect(text).toContain("M-2026-UV18-001");
    expect(text).toContain("540 jours");
    expect(text).toContain("02/03/2026");
    expect(text).toContain("24/08/2027");
    expect(text).toContain("Mourad B.");
    expect(text).toContain("Chef d'équipe");
    // « Créé par … le … » à l'heure d'Algérie (UTC+1) : 08:00 UTC = 09:00.
    expect(text).toContain("Créé par Farid L. le 24/11/2026 09:00");
  });

  it("n'écrit jamais de téléphone ni d'identifiant de connexion dans la fiche (H-17)", async () => {
    mockSite(makeSite(), uv18Zones, "Admin");
    renderApp(detailPath);

    await screen.findByRole("heading", { level: 1, name: "École UV18" });
    expect(screen.getByRole("main").textContent).not.toMatch(/0550|\.dev/);
  });

  it("range les zones par bloc, cote signée du plus bas au plus haut (CT-17)", async () => {
    mockSite(makeSite(), uv18Zones, "ConducteurTravaux");
    renderApp(detailPath);

    const bloc01 = await screen.findByRole("region", { name: "Bloc 01" });
    const lines = within(bloc01)
      .getAllByRole("listitem")
      .map((item) => item.textContent);
    expect(lines).toEqual([
      `${MINUS}1,90 m`,
      "±0,00 m · Couloir",
      "+3,40 m · Classe 02",
      "+10,20 m",
    ]);
    const bloc02 = screen.getByRole("region", { name: "Bloc 02" });
    expect(within(bloc02).getAllByRole("listitem").map((item) => item.textContent)).toEqual([
      "Façade cantine",
      "±0,00 m · Cantine",
    ]);
    expect(within(bloc01).getByText("4 zones")).toBeTruthy();
  });

  it("affiche la fiche en arabe : RTL, nom arabe, cotes et dates de gauche à droite, zones sans texte brut", async () => {
    mockSite(makeSite({ nameAr: "مدرسة UV18" }), uv18Zones, "ConducteurTravaux");
    mockSession("ConducteurTravaux", { language: "ar" });
    renderApp(detailPath, "ar");

    expect(await screen.findByRole("heading", { level: 1, name: "مدرسة UV18" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
    const main = screen.getByRole("main");
    const ltr = [...main.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent);
    expect(ltr).toEqual(expect.arrayContaining(["CH-ECO-UV18", `185${NBSP}000${NBSP}000,00${NBSP}DZD`, "24/08/2027", "02/03/2026", "+3,40 m", `${MINUS}1,90 m`]));
    expect(main.textContent).toContain("قسم 02");
    expect(main.textContent).toContain("رواق");
    expect(main.textContent).toContain("مطعم مدرسي");
    expect(main.textContent).toContain("مدرسة");
    expect(main.textContent).not.toMatch(/Classroom|Corridor|School|sites:|errors:/);
    expect(within(main).getByRole("heading", { level: 2, name: "المناطق" })).toBeTruthy();
    expect(main.textContent).toContain("رئيس الفريق");
  });

  it("n'affiche aucune ligne « Montant » quand le serveur ne l'envoie pas (ChefEquipe, CT-20)", async () => {
    const withoutAmount = makeSite();
    delete withoutAmount.contractAmount;
    mockSite(withoutAmount, uv18Zones, "ChefEquipe");
    renderApp(detailPath);

    await screen.findByRole("heading", { level: 1, name: "École UV18" });
    const text = screen.getByRole("main").textContent ?? "";
    expect(text).not.toContain("Montant du marché");
    expect(text).not.toContain("DZD");
    // Le reste du marché reste visible.
    expect(text).toContain("24/08/2027");
  });

  it("affiche « À définir » sans ODS ni délai, sans inventer de date (CA-007.3)", async () => {
    mockSite(makeSite({ odsDate: null, delayDays: null, contractualEndDate: null, contractNumber: null }), [], "Admin");
    renderApp(detailPath);

    await screen.findByRole("heading", { level: 1, name: "École UV18" });
    const text = screen.getByRole("main").textContent ?? "";
    expect(text.match(/À définir/g)?.length).toBe(4);
    expect(text).not.toMatch(/Invalid|NaN|undefined|null/);
    expect(screen.getByText("Aucune zone pour ce chantier.")).toBeTruthy();
  });

  it.each([
    // rôle, modifier le chantier, archiver le chantier, ajouter une zone, modifier une zone, archiver une zone
    ["Admin", true, true, true, true, true],
    ["ConducteurTravaux", false, false, true, true, true],
    ["ChefChantier", false, false, true, true, false],
    ["Direction", false, false, false, false, false],
    ["Achats", false, false, false, false, false],
    ["ChefEquipe", false, false, false, false, false],
  ] as const)("%s : actions présentes selon les droits (CA-003.1, CA-003.4)", async (role, editSite, archiveSite, addZone, editZone, archiveZone) => {
    mockSite(makeSite(), [makeZone()], role);
    renderApp(detailPath);

    await screen.findByRole("heading", { level: 1, name: "École UV18" });
    await screen.findByRole("region", { name: "Bloc 01" });
    const present = (name: RegExp | string) => screen.queryByRole("button", { name }) !== null;
    expect(present("Modifier")).toBe(editSite);
    expect(present("Archiver")).toBe(archiveSite);
    expect(present("Ajouter une zone")).toBe(addZone);
    expect(present(/^Modifier la zone/)).toBe(editZone);
    expect(present(/^Archiver la zone/)).toBe(archiveZone);
  });

  it("un chantier archivé est en lecture seule ; l'Admin peut le restaurer", async () => {
    mockSite(makeSite({ archivedAt: "2026-11-20T08:00:00Z", archivedByName: "Farid L." }), [makeZone()], "Admin");
    renderApp(detailPath);

    await screen.findByRole("heading", { level: 1, name: "École UV18" });
    expect(screen.getByText("Chantier archivé : consultation seule, aucune nouvelle saisie.")).toBeTruthy();
    expect(screen.getByRole("main").textContent).toContain("Archivé par Farid L. le 20/11/2026 09:00");
    for (const name of ["Modifier", "Archiver", "Ajouter une zone", /^Modifier la zone/, /^Archiver la zone/]) {
      expect(screen.queryByRole("button", { name })).toBeNull();
    }
    expect(screen.getByRole("button", { name: "Restaurer" })).toBeTruthy();
  });

  it("archive le chantier après confirmation explicite", async () => {
    mockSite(makeSite(), [], "Admin");
    let archivedCalls = 0;
    server.use(
      http.post(apiUrl("/sites/:siteId/archive"), () => {
        archivedCalls += 1;
        return HttpResponse.json(makeSite({ archivedAt: "2026-11-24T10:00:00Z", archivedByName: "Farid L." }));
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    await screen.findByRole("heading", { level: 1, name: "École UV18" });

    await user.click(screen.getByRole("button", { name: "Archiver" }));
    const dialog = await screen.findByRole("dialog", { name: "Archiver ce chantier ?" });
    expect(archivedCalls).toBe(0);

    await user.click(within(dialog).getByRole("button", { name: "Archiver" }));

    await waitFor(() => expect(archivedCalls).toBe(1));
    expect(await screen.findByText("Chantier archivé.")).toBeTruthy();
  });

  it("n'archive rien quand on annule la confirmation", async () => {
    mockSite(makeSite(), [], "Admin");
    let archivedCalls = 0;
    server.use(
      http.post(apiUrl("/sites/:siteId/archive"), () => {
        archivedCalls += 1;
        return HttpResponse.json(makeSite());
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    await screen.findByRole("heading", { level: 1, name: "École UV18" });

    await user.click(screen.getByRole("button", { name: "Archiver" }));
    const dialog = await screen.findByRole("dialog");
    await user.click(within(dialog).getByRole("button", { name: "Annuler" }));

    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    expect(archivedCalls).toBe(0);
  });

  it("archive une zone après confirmation, puis la zone archivée peut être restaurée", async () => {
    mockSite(makeSite(), [makeZone({ id: "zz1" })], "ConducteurTravaux");
    const calls: string[] = [];
    server.use(
      http.post(apiUrl("/sites/:siteId/zones/:zoneId/archive"), ({ params }) => {
        calls.push(`archive ${String(params["zoneId"])}`);
        return HttpResponse.json(makeZone({ id: "zz1", archivedAt: "2026-11-24T10:00:00Z" }));
      }),
    );
    const user = userEvent.setup();
    renderApp(detailPath);
    await screen.findByRole("region", { name: "Bloc 01" });

    await user.click(screen.getByRole("button", { name: /^Archiver la zone/ }));
    const dialog = await screen.findByRole("dialog", { name: "Archiver cette zone ?" });
    await user.click(within(dialog).getByRole("button", { name: "Archiver" }));

    await waitFor(() => expect(calls).toEqual(["archive zz1"]));
    expect(await screen.findByText("Zone archivée.")).toBeTruthy();
  });

  it("affiche « introuvable » à l'identique pour un chantier absent ou non affecté, sans « Réessayer » (CT-3)", async () => {
    mockSession("ChefChantier");
    server.use(http.get(apiUrl("/sites/:siteId"), () => problem(404, "INTROUVABLE")));
    renderApp(`/sites/${SITE_OL40_ID}`);

    const alert = await within(await screen.findByRole("main")).findByRole("alert");
    expect(alert.textContent).toContain("Élément introuvable.");
    expect(screen.queryByRole("button", { name: "Réessayer" })).toBeNull();
    expect(screen.getByRole("link", { name: "Retour à la liste" })).toBeTruthy();
  });

  it("charge toutes les pages de zones du serveur (curseur)", async () => {
    mockSession("ConducteurTravaux");
    server.use(
      http.get(apiUrl("/sites/:siteId"), () => HttpResponse.json(makeSite())),
      http.get(apiUrl("/sites/:siteId/members"), () => HttpResponse.json({ items: [] })),
      http.get(apiUrl("/sites/:siteId/zones"), ({ request }) => {
        const cursor = new URL(request.url).searchParams.get("cursor");
        return cursor
          ? HttpResponse.json({ items: [makeZone({ id: "p2", block: "Bloc 02", elevation: 0, roomType: null, roomNumber: null })], nextCursor: null })
          : HttpResponse.json({ items: [makeZone({ id: "p1" })], nextCursor: "o:1" });
      }),
    );
    renderApp(detailPath);

    expect(await screen.findByRole("region", { name: "Bloc 01" })).toBeTruthy();
    expect(await screen.findByRole("region", { name: "Bloc 02" })).toBeTruthy();
  });
});
