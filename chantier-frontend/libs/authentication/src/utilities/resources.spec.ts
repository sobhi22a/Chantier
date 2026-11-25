import { AUTHENTICATION_ROUTES, PERMISSIONS_RESOURCES } from "./resources";

describe("constantes d'authentification", () => {
  it("expose des routes uniques commençant par « / » (sauf le joker)", () => {
    const paths = Object.values(AUTHENTICATION_ROUTES);
    expect(new Set(paths).size).toBe(paths.length);
    for (const path of paths.filter((value) => value !== AUTHENTICATION_ROUTES.WILD_CARD)) {
      expect(path.startsWith("/")).toBe(true);
    }
  });

  it("utilise les noms de ressources du catalogue de permissions du serveur (ADR 0005)", () => {
    expect(Object.values(PERMISSIONS_RESOURCES).sort()).toEqual([
      "AllSites",
      "ContractAmount",
      "SiteMembers",
      "Sites",
      "Zones",
    ]);
  });
});
