import { MATERIAL_MATRIX, PERMISSIONS_BY_ROLE, makeMe, makeProduct, makeRequest, makeSite, makeZone } from "./fixtures";

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

  it("reprend la matrice des permissions des matériaux (contrat, ADR 0012)", () => {
    expect(Object.keys(MATERIAL_MATRIX)).toHaveLength(28);
    // Prix : jamais pour les rôles du terrain (CA-MAT-009.3).
    expect(PERMISSIONS_BY_ROLE.ChefChantier).not.toContain("Prices.View");
    expect(PERMISSIONS_BY_ROLE.ChefEquipe).not.toContain("Prices.View");
    expect(PERMISSIONS_BY_ROLE.Direction).toContain("Prices.View");
    // La Direction consulte sans bouton d'écriture (CA-MAT-009.6).
    expect(PERMISSIONS_BY_ROLE.Direction.filter((permission) => /\.(Create|Update|UpdateAny|Approve|Cancel|CancelAny|Archive)$/.test(permission) && !/^(Zones|Sites)\./.test(permission))).toEqual([]);
    // Valider : conducteur et administrateur seulement ; le chef d'équipe n'annule que les siennes.
    expect(PERMISSIONS_BY_ROLE.ChefChantier).not.toContain("Requests.Approve");
    expect(PERMISSIONS_BY_ROLE.ChefEquipe).toContain("Requests.Cancel");
    expect(PERMISSIONS_BY_ROLE.ChefEquipe).not.toContain("Requests.CancelAny");
    expect(PERMISSIONS_BY_ROLE.ChefEquipe).not.toContain("SupplierPhone.View");
  });

  it("produit des produits et des demandes fictifs complets", () => {
    expect(makeProduct().bagMassKg).toBe(50);
    expect(makeRequest({ number: "DEM-010" }).quantity).toEqual({ value: 300, unit: "sac" });
  });
});
