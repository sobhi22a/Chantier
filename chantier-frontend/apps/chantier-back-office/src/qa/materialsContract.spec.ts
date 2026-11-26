import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import { MATERIAL_MATRIX, type TestRole } from "@chantier-frontend/testing";

/**
 * Q3 : les trois parties lisent le même tableau de droits. Le contrat (`docs/api/demandes-materiaux-livraisons.md`, section « Permissions »)
 * est la source ; le serveur le teste (`MaterialPermissionMatrixTests`), ce test-ci vérifie que la copie du web (jeu de données des tests,
 * qui fixe les boutons présents ou absents dans tous les écrans) ne dérive pas.
 */
const ROLES: TestRole[] = ["Admin", "Direction", "ConducteurTravaux", "Achats", "ChefChantier", "ChefEquipe"];

const contract = readFileSync(resolve(__dirname, "../../../../../docs/api/demandes-materiaux-livraisons.md"), "utf8");

const contractMatrix = (): Record<string, TestRole[]> => {
  const section = contract.split("\n## Permissions")[1]?.split("\n## ")[0] ?? "";
  const matrix: Record<string, TestRole[]> = {};
  for (const line of section.split("\n").filter((row) => /^\|\s*`/.test(row))) {
    const cells = line.split("|").slice(1, -1).map((cell) => cell.trim());
    const permissions = [...(cells[0] ?? "").matchAll(/`([A-Za-z]+\.[A-Za-z]+)`/g)].map((match) => match[1] as string);
    const roles = ROLES.filter((_, index) => cells[index + 1] === "O");
    for (const permission of permissions) {
      matrix[permission] = roles;
    }
  }
  return matrix;
};

describe("Droits des matériaux : le web lit le même tableau que le contrat", () => {
  it("compte les 28 permissions du contrat, ni plus ni moins", () => {
    const fromContract = contractMatrix();
    expect(Object.keys(fromContract).sort()).toEqual(Object.keys(MATERIAL_MATRIX).sort());
    expect(Object.keys(fromContract)).toHaveLength(28);
  });

  it.each(Object.keys(MATERIAL_MATRIX))("%s : mêmes rôles dans le contrat et dans le jeu de données du web", (permission) => {
    expect([...(MATERIAL_MATRIX[permission] ?? [])].sort()).toEqual([...(contractMatrix()[permission] ?? [])].sort());
  });

  it("n'accorde aucun droit d'écriture à la Direction ni aucun prix au terrain (règles 8 et 9 du métier)", () => {
    const fromContract = contractMatrix();
    const writes = Object.entries(fromContract).filter(([permission]) => /\.(Create|Update|UpdateAny|Approve|Cancel|CancelAny|Receive|Settle|Archive|LinkProduct|Attach)$/.test(permission));
    expect(writes.length).toBeGreaterThan(15);
    expect(writes.filter(([, roles]) => roles.includes("Direction"))).toEqual([]);
    expect(fromContract["Prices.View"]).not.toContain("ChefChantier");
    expect(fromContract["Prices.View"]).not.toContain("ChefEquipe");
    expect(fromContract["SupplierPhone.View"]).not.toContain("ChefEquipe");
    expect(fromContract["SupplierPhone.View"]).not.toContain("Direction");
  });
});
