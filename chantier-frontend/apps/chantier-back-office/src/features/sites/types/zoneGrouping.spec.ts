import { makeZone } from "@chantier-frontend/testing";

import { groupZonesByBlock } from "./zoneGrouping";

describe("regroupement des zones (CA-009.2)", () => {
  it("groupe par bloc et trie les cotes du plus bas au plus haut, une zone sans cote en premier", () => {
    const zones = [
      makeZone({ id: "1", block: "Bloc 01", elevation: 10.2, roomType: null, roomNumber: null }),
      makeZone({ id: "2", block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 2 }),
      makeZone({ id: "3", block: "Bloc 01", elevation: -1.9, roomType: null, roomNumber: null }),
      makeZone({ id: "4", block: "Bloc 01", elevation: 0, roomType: null, roomNumber: null }),
      makeZone({ id: "5", block: "Bloc 01", elevation: null, roomType: null, roomNumber: null }),
      makeZone({ id: "6", block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 1 }),
      makeZone({ id: "7", block: "Bloc 01", elevation: 3.4, roomType: "Corridor", roomNumber: null }),
      makeZone({ id: "8", block: "Bloc 02", elevation: 0, roomType: "Canteen", roomNumber: null }),
    ];

    const groups = groupZonesByBlock(zones);

    expect(groups.map((group) => group.block)).toEqual(["Bloc 01", "Bloc 02"]);
    expect(groups[0]?.zones.map((zone) => zone.id)).toEqual(["5", "3", "4", "6", "2", "7", "1"]);
  });

  it("range les blocs dans l'ordre naturel (Bloc 2 avant Bloc 10)", () => {
    const groups = groupZonesByBlock([
      makeZone({ id: "a", block: "Bloc 10" }),
      makeZone({ id: "b", block: "Bloc 2" }),
      makeZone({ id: "c", block: "Bloc 1" }),
    ]);
    expect(groups.map((group) => group.block)).toEqual(["Bloc 1", "Bloc 2", "Bloc 10"]);
  });

  it("ne modifie pas la liste reçue", () => {
    const zones = [makeZone({ id: "x", elevation: 5 }), makeZone({ id: "y", elevation: 1 })];
    groupZonesByBlock(zones);
    expect(zones.map((zone) => zone.id)).toEqual(["x", "y"]);
  });
});
