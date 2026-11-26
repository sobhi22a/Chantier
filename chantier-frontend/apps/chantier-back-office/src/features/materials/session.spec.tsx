import { screen, waitFor } from "@testing-library/react";

import { ApplicationApiService } from "@chantier-frontend/api-core";
import { makeMe, setupMockServer } from "@chantier-frontend/testing";

import { mockMaterialsReads } from "../../testing/materialsMocks";
import { mockSession, renderApp } from "../../testing/renderApp";

setupMockServer();

const cachedQueries = (store: ReturnType<typeof renderApp>["store"]) =>
  Object.values((store.getState() as unknown as { ApplicationApi: { queries: Record<string, { endpointName: string } | undefined> } }).ApplicationApi.queries)
    .map((entry) => entry?.endpointName)
    .filter((name) => name !== "authMe");

describe("Cache de données et fin de session (revue R3-03)", () => {
  it("vide le cache (prix, photos) quand la session expire, sans déconnexion volontaire", async () => {
    mockSession("Achats");
    mockMaterialsReads();
    const { store } = renderApp("/materials/requests");
    await screen.findByRole("table");
    expect(cachedQueries(store)).toContain("crossSiteRequestsList");

    // La session expire : le profil répond 401 à la prochaine lecture.
    mockSession(null);
    store.dispatch(ApplicationApiService.util.invalidateTags([{ type: "ME", id: "CURRENT" }]));

    await waitFor(() => expect(cachedQueries(store)).not.toContain("crossSiteRequestsList"));
    expect(cachedQueries(store)).not.toContain("productsList");
  });

  it("vide le cache quand un autre compte se connecte dans le même onglet", async () => {
    mockSession("Achats");
    const { listRequests } = mockMaterialsReads();
    const { store } = renderApp("/materials/requests");
    await screen.findByRole("table");
    expect(listRequests).toHaveLength(1);

    // Autre compte : le profil change d'identifiant, la liste en cache de l'ancien ne doit plus servir.
    mockSession("ConducteurTravaux", { id: "00000000-0000-7000-8000-0000000000ff" });
    store.dispatch(ApplicationApiService.util.invalidateTags([{ type: "ME", id: "CURRENT" }]));

    await waitFor(() => expect(store.getState().authentication.userId).toBe("00000000-0000-7000-8000-0000000000ff"));
    // Le cache de l'ancien compte est remis à zéro : la liste est relue pour le nouveau (sans cela, rien ne la relirait).
    await waitFor(() => expect(listRequests.length).toBeGreaterThan(1));
    expect(makeMe("Achats").id).not.toBe("00000000-0000-7000-8000-0000000000ff");
  });
});
