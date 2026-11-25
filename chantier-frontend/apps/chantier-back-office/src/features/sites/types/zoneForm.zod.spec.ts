import { makeZone } from "@chantier-frontend/testing";

import {
  emptyZoneFormValues,
  parseElevation,
  toCreateZoneRequest,
  toUpdateZoneRequest,
  zoneFormSchema,
  zoneToFormValues,
} from "./zoneForm.zod";

describe("parseElevation (CT-17, CA-011.2)", () => {
  it.each([
    ["3,4", 3.4],
    ["3.4", 3.4],
    ["+3,40", 3.4],
    ["-1,9", -1.9],
    ["−1,90", -1.9],
    ["0", 0],
    ["±0,00", 0],
    ["-20", -20],
    ["60", 60],
    ["  10,2 ", 10.2],
  ])("%s → %s", (text, expected) => {
    expect(parseElevation(text)).toBe(expected);
  });

  it("renvoie null pour une saisie vide (pas de cote)", () => {
    expect(parseElevation("")).toBeNull();
    expect(parseElevation("   ")).toBeNull();
  });

  it.each(["abc", "3,456", "1 2", "3,", ",5", "--1", "100", "1e3"])("%s est illisible", (text) => {
    expect(Number.isNaN(parseElevation(text))).toBe(true);
  });
});

describe("schéma de zone", () => {
  const valid = emptyZoneFormValues({ block: "Bloc 01", elevation: "3,4", roomType: "Classroom", roomNumber: 2 });
  const messages = (values: Parameters<typeof zoneFormSchema.safeParse>[0]) => {
    const result = zoneFormSchema.safeParse(values);
    return result.success ? [] : result.error.issues.map((issue) => `${issue.path.join(".")}:${issue.message}`);
  };

  it("accepte une zone complète et une zone réduite au bloc", () => {
    expect(messages(valid)).toEqual([]);
    expect(messages(emptyZoneFormValues({ block: "Bloc 02" }))).toEqual([]);
  });

  it("exige un bloc", () => {
    expect(messages({ ...valid, block: "  " })).toEqual(["block:sites:zones.blockRequired"]);
  });

  it.each(["-20,01", "60,01", "61", "-21"])("refuse la cote %s hors de −20,00 à +60,00 (H-15)", (elevation) => {
    expect(messages({ ...valid, elevation })).toEqual(["elevation:sites:zones.elevationOutOfRange"]);
  });

  it.each(["-20", "60", "0", ""])("accepte la cote limite %s", (elevation) => {
    expect(messages({ ...valid, elevation })).toEqual([]);
  });

  it("refuse une cote illisible", () => {
    expect(messages({ ...valid, elevation: "abc" })).toEqual(["elevation:sites:zones.elevationInvalid"]);
  });

  it.each([0, 1000, 1.5])("refuse le numéro de local %s", (roomNumber) => {
    expect(messages({ ...valid, roomNumber })).toEqual(["roomNumber:sites:zones.roomNumberInvalid"]);
  });
});

describe("requêtes de zone", () => {
  it("envoie la cote en nombre, sans clientId (création au back-office)", () => {
    const request = toCreateZoneRequest(
      emptyZoneFormValues({ block: " Bloc 01 ", elevation: "-1,9", roomType: "Classroom", roomNumber: 2 }),
    );
    expect(request).toEqual({ block: "Bloc 01", elevation: -1.9, roomType: "Classroom", roomNumber: 2, roomLabel: null });
    expect(request).not.toHaveProperty("clientId");
  });

  it("n'envoie ni numéro sans type de local, ni libellé hors « Autre »", () => {
    const request = toCreateZoneRequest(emptyZoneFormValues({ block: "Bloc 01", roomNumber: 3, roomLabel: "Façade" }));
    expect(request).toEqual({ block: "Bloc 01", elevation: null, roomType: null, roomNumber: null, roomLabel: null });
  });

  it("garde le libellé libre pour le type « Autre »", () => {
    const request = toCreateZoneRequest(emptyZoneFormValues({ block: "Bloc 02", roomType: "Other", roomLabel: "Façade cantine" }));
    expect(request).toMatchObject({ roomType: "Other", roomLabel: "Façade cantine" });
  });

  it("joint la version lue à la modification", () => {
    const zone = makeZone({ elevation: -1.9, version: "777" });
    const request = toUpdateZoneRequest(zoneToFormValues(zone), zone.version);
    expect(request).toMatchObject({ version: "777", block: "Bloc 01", elevation: -1.9 });
  });

  it("recharge une zone dans le formulaire avec la virgule décimale", () => {
    expect(zoneToFormValues(makeZone({ elevation: 3.4 })).elevation).toBe("3,4");
    expect(zoneToFormValues(makeZone({ elevation: null })).elevation).toBe("");
  });
});
