import { buildZoneLabelParts, formatZoneLabel, type RoomType, type ZoneLabelTexts } from "./zoneLabelParts";

const MINUS = "\u2212";

const ROOM_TYPE_NAMES: Record<RoomType, string> = {
  Classroom: "Classe",
  Corridor: "Couloir",
  Canteen: "Cantine",
  Refectory: "Réfectoire",
  Kitchen: "Cuisine",
  Office: "Bureau",
  Sanitary: "Sanitaires",
  TechnicalRoom: "Local technique",
  Facade: "Façade",
  Other: "Autre",
};

const frenchTexts: ZoneLabelTexts = { meter: "m", roomTypeName: (type) => ROOM_TYPE_NAMES[type] };

describe("libellé de zone (données de démonstration « École UV18 »)", () => {
  it.each([
    [{ block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 2 }, "Bloc 01 · +3,40 m · Classe 02"],
    [{ block: "Bloc 01", elevation: 0, roomType: "Corridor" }, "Bloc 01 · ±0,00 m · Couloir"],
    [{ block: "Bloc 01", elevation: -1.9 }, `Bloc 01 · ${MINUS}1,90 m`],
    [{ block: "Bloc 01", elevation: 10.2 }, "Bloc 01 · +10,20 m"],
    [{ block: "Bloc 02" }, "Bloc 02"],
    [{ block: "Bloc 02", elevation: 0, roomType: "Canteen" }, "Bloc 02 · ±0,00 m · Cantine"],
    [{ block: "Bloc 02", roomType: "Other", roomLabel: "Façade cantine" }, "Bloc 02 · Façade cantine"],
    [{ block: "Bloc 02", roomType: "Other" }, "Bloc 02 · Autre"],
    [{ block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 12 }, "Bloc 01 · +3,40 m · Classe 12"],
  ] as const)("%j → %s", (zone, expected) => {
    expect(formatZoneLabel(zone, frenchTexts)).toBe(expected);
  });

  it("sépare les morceaux pour que la cote puisse être isolée en gauche-à-droite", () => {
    const parts = buildZoneLabelParts(
      { block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 2 },
      frenchTexts,
    );
    expect(parts).toEqual({ block: "Bloc 01", elevation: "+3,40 m", room: "Classe 02" });
  });
});
