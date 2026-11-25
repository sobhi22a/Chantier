import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import { SITE_OL40_ID, apiUrl, makeSite, server, setupMockServer, type TestRole } from "@chantier-frontend/testing";

import { mockSession, renderApp } from "../../testing/renderApp";

setupMockServer();

const wilayas = [
  { code: "09", nameFr: "Blida", nameAr: "البليدة" },
  { code: "16", nameFr: "Alger", nameAr: "الجزائر" },
];

const field = (dialog: HTMLElement, label: RegExp): HTMLInputElement => within(dialog).getAllByLabelText(label)[0] as HTMLInputElement;

/** `GET /sites` : la liste de l'écran (page 1) et la demande du « dernier chantier créé » (tri −createdAt, 1 élément). */
const mockSites = (lastCreated: ReturnType<typeof makeSite> | null, role: TestRole = "Admin") => {
  mockSession(role);
  const requests: URL[] = [];
  const communeCodes: string[] = [];
  server.use(
    http.get(apiUrl("/sites"), ({ request }) => {
      const url = new URL(request.url);
      requests.push(url);
      const isLastCreatedQuery = url.searchParams.get("sort") === "-createdAt";
      const items = isLastCreatedQuery ? (lastCreated ? [lastCreated] : []) : [];
      return HttpResponse.json({ items, page: 1, pageSize: Number(url.searchParams.get("pageSize")), totalCount: items.length });
    }),
    http.get(apiUrl("/reference/wilayas"), () => HttpResponse.json(wilayas)),
    http.get(apiUrl("/reference/wilayas/:code/communes"), ({ params }) => {
      communeCodes.push(String(params["code"]));
      return HttpResponse.json([{ nameFr: "Boufarik", nameAr: "بوفاريك" }]);
    }),
  );
  return { requests, communeCodes };
};

const openForm = async (user: ReturnType<typeof userEvent.setup>) => {
  await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });
  await user.click(screen.getByRole("button", { name: "Nouveau chantier" }));
  return screen.findByRole("dialog", { name: "Nouveau chantier" });
};

describe("formulaire chantier : valeurs par défaut (CA-008.6, D-5)", () => {
  it("propose la wilaya et le maître d'ouvrage du dernier chantier créé", async () => {
    const { requests } = mockSites(makeSite({ id: SITE_OL40_ID, wilaya: "Blida", owner: "Office de promotion immobilière (fictif)" }));
    const user = userEvent.setup();
    renderApp("/sites");
    const dialog = await openForm(user);

    await waitFor(() => expect(field(dialog, /^Wilaya/).value).toBe("Blida"));
    expect(field(dialog, /^Maître d'ouvrage/).value).toBe("Office de promotion immobilière (fictif)");
    // Question posée au serveur : le chantier le plus récent, archivés compris.
    const lastQuery = requests.find((url) => url.searchParams.get("sort") === "-createdAt");
    expect(lastQuery?.searchParams.get("pageSize")).toBe("1");
    expect(lastQuery?.searchParams.get("includeArchived")).toBe("true");
  });

  it("charge tout de suite les communes de la wilaya proposée", async () => {
    const { communeCodes } = mockSites(makeSite({ wilaya: "Alger" }));
    const user = userEvent.setup();
    renderApp("/sites");
    const dialog = await openForm(user);

    await waitFor(() => expect(field(dialog, /^Wilaya/).value).toBe("Alger"));
    await waitFor(() => expect(communeCodes).toEqual(["16"]));
    await user.click(field(dialog, /^Commune/));
    expect(await screen.findByRole("option", { name: "Boufarik" })).toBeTruthy();
  });

  it("laisse les champs vides quand aucun chantier n'existe encore", async () => {
    mockSites(null);
    const user = userEvent.setup();
    renderApp("/sites");
    const dialog = await openForm(user);

    await waitFor(() => expect(within(dialog).getAllByLabelText(/^Wilaya/).length).toBeGreaterThan(0));
    expect(field(dialog, /^Wilaya/).value).toBe("");
    expect(field(dialog, /^Maître d'ouvrage/).value).toBe("");
  });

  it("laisse choisir une autre wilaya que celle proposée", async () => {
    mockSites(makeSite({ wilaya: "Blida" }));
    const user = userEvent.setup();
    renderApp("/sites");
    const dialog = await openForm(user);
    await waitFor(() => expect(field(dialog, /^Wilaya/).value).toBe("Blida"));

    await user.click(field(dialog, /^Wilaya/));
    await user.click(await screen.findByRole("option", { name: "Alger" }));

    await waitFor(() => expect(field(dialog, /^Wilaya/).value).toBe("Alger"));
  });

  it("reprend le dernier chantier créé à chaque ouverture du formulaire (pas une valeur périmée)", async () => {
    mockSites(makeSite({ wilaya: "Blida" }));
    const user = userEvent.setup();
    renderApp("/sites");
    let dialog = await openForm(user);
    await waitFor(() => expect(field(dialog, /^Wilaya/).value).toBe("Blida"));
    await user.click(within(dialog).getByRole("button", { name: "Annuler" }));
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());

    server.use(
      http.get(apiUrl("/sites"), ({ request }) => {
        const isLast = new URL(request.url).searchParams.get("sort") === "-createdAt";
        return HttpResponse.json({ items: isLast ? [makeSite({ wilaya: "Alger" })] : [], page: 1, pageSize: 1, totalCount: 1 });
      }),
    );
    await user.click(screen.getByRole("button", { name: "Nouveau chantier" }));
    dialog = await screen.findByRole("dialog", { name: "Nouveau chantier" });

    await waitFor(() => expect(field(dialog, /^Wilaya/).value).toBe("Alger"));
  });

  it("n'applique rien en modification : la fiche garde sa propre wilaya", async () => {
    mockSession("Admin");
    server.use(
      http.get(apiUrl("/sites/:siteId"), () => HttpResponse.json(makeSite({ wilaya: "Alger", owner: "MOA propre" }))),
      http.get(apiUrl("/sites/:siteId/zones"), () => HttpResponse.json({ items: [], nextCursor: null })),
      http.get(apiUrl("/sites/:siteId/members"), () => HttpResponse.json({ items: [] })),
      http.get(apiUrl("/reference/wilayas"), () => HttpResponse.json(wilayas)),
      http.get(apiUrl("/reference/wilayas/:code/communes"), () => HttpResponse.json([])),
    );
    const sortQueries: string[] = [];
    server.events.on("request:start", ({ request }) => {
      if (new URL(request.url).searchParams.get("sort")) sortQueries.push(request.url);
    });
    const user = userEvent.setup();
    renderApp(`/sites/${makeSite().id}`);
    await screen.findByRole("heading", { level: 1, name: "École UV18" });

    await user.click(screen.getByRole("button", { name: "Modifier" }));
    const dialog = await screen.findByRole("dialog", { name: "Modifier le chantier" });

    expect(field(dialog, /^Wilaya/).value).toBe("Alger");
    expect(field(dialog, /^Maître d'ouvrage/).value).toBe("MOA propre");
    expect(sortQueries).toEqual([]);
  });
});
