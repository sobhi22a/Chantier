import { PERMISSIONS_BY_ROLE, makeMe, makeSite, makeZone } from "./fixtures";

describe("jeu de données de test", () => {
  it("reprend la matrice de droits de l'ADR 0005", () => {
    expect(PERMISSIONS_BY_ROLE.ChefEquipe).not.toContain("Zones.Create");
    expect(PERMISSIONS_BY_ROLE.Achats).not.toContain("ContractAmount.View");
    expect(PERMISSIONS_BY_ROLE.Direction).not.toContain("Sites.Create");
    expect(PERMISSIONS_BY_ROLE.ConducteurTravaux).toContain("Zones.Delete");
    expect(PERMISSIONS_BY_ROLE.ChefChantier).not.toContain("Zones.Delete");
    expect(PERMISSIONS_BY_ROLE.Admin).toContain("AllSites.View");
  });

  it("produit des objets fictifs complets et modifiables", () => {
    expect(makeMe("Admin").permissions).toContain("Sites.Create");
    expect(makeSite({ name: "Autre" }).code).toBe("CH-ECO-UV18");
    expect(makeZone({ elevation: -1.9 }).elevation).toBe(-1.9);
  });
});
