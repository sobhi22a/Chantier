import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import type { MeasureUnitCode } from "@chantier-frontend/i18n";

import {
  addDays,
  announceDelivery,
  checkQuantity,
  convertQuantity,
  equivalenceFor,
  milliToText,
  normalizeQuantityText,
  parseMilli,
  QuantityMirrorError,
} from "./quantityMirror";

interface Vectors {
  conversions: {
    name: string;
    from: { value: string; unit: MeasureUnitCode };
    to: MeasureUnitCode;
    bagMassKg: string | null;
    expected?: { value: string; unit: string };
    error?: string;
  }[];
  quantityRules: { name: string; quantity: { value: string; unit: string }; error?: string; valid?: boolean }[];
  defaultNeededBy: { today: string; days: number; expected: string }[];
  status: {
    name: string;
    ordered: { value: string; unit: MeasureUnitCode };
    bagMassKg: string | null;
    deliveries: { value: string; unit: MeasureUnitCode }[];
    tolerancePercent: string;
    expected?: { remaining: string; variance: string; variancePercent: string; status: string };
    error?: string;
  }[];
}

// Les mêmes vecteurs que les tests .NET et Dart (ADR 0014, CT-MAT-01) : un seul fichier, jamais copié.
const vectors = JSON.parse(readFileSync(resolve(__dirname, "../../../../../../../docs/api/vecteurs-materiaux.json"), "utf8")) as Vectors;

describe("miroir de calcul : conversions (vecteurs partagés)", () => {
  it.each(vectors.conversions)("$name", ({ from, to, bagMassKg, expected, error }) => {
    const milli = parseMilli(from.value);
    expect(milli).not.toBeNull();
    const source = { milli: milli as bigint, unit: from.unit };
    if (error) {
      expect(() => convertQuantity(source, to, bagMassKg)).toThrow(QuantityMirrorError);
      try {
        convertQuantity(source, to, bagMassKg);
      } catch (caught) {
        expect((caught as QuantityMirrorError).code).toBe(error);
      }
      return;
    }
    const result = convertQuantity(source, to, bagMassKg);
    expect({ value: milliToText(result.milli), unit: result.unit }).toEqual(expected);
  });
});

describe("miroir de calcul : règles de quantité (vecteurs partagés)", () => {
  it.each(vectors.quantityRules)("$name", ({ quantity, error, valid }) => {
    // Un négatif n'est pas un décimal positif : il tombe dans QUANTITE_INVALIDE comme dans le serveur.
    expect(checkQuantity(quantity.value, quantity.unit)).toBe(valid ? null : (error ?? null));
  });
});

describe("miroir de calcul : date de besoin proposée (vecteurs partagés)", () => {
  it.each(vectors.defaultNeededBy)("$today + $days jours = $expected", ({ today, days, expected }) => {
    expect(addDays(today, days)).toBe(expected);
  });

  it("refuse une date incomplète", () => {
    expect(() => addDays("../08/2026", 3)).toThrow(RangeError);
  });
});

describe("miroir de calcul : saisie et équivalence (CA-MAT-001.3)", () => {
  it("accepte la virgule ou le point décimal et refuse le reste", () => {
    expect(normalizeQuantityText("2,5")).toBe("2.5");
    expect(normalizeQuantityText(" 1 200 ")).toBe("1200");
    expect(normalizeQuantityText("2,5,1")).toBeNull();
    expect(normalizeQuantityText("abc")).toBeNull();
    expect(normalizeQuantityText("")).toBeNull();
  });

  it("arrondit loin de zéro : 0,0005 t en kg et 405,2 sacs", () => {
    const tonnes = convertQuantity({ milli: parseMilli("20.26") as bigint, unit: "t" }, "sac", "50");
    expect(milliToText(tonnes.milli)).toBe("405.2");
  });

  it("propose 300 sacs = 15 T, 15 sacs = 750 kg, 15 T = 300 sacs et rien pour m³, u, L", () => {
    const equivalent = (value: string, unit: MeasureUnitCode, bag: string | null) => {
      const result = equivalenceFor({ milli: parseMilli(value) as bigint, unit }, bag);
      return result ? `${milliToText(result.milli)} ${result.unit}` : null;
    };
    expect(equivalent("300", "sac", "50")).toBe("15 t");
    expect(equivalent("15", "sac", "50")).toBe("750 kg");
    expect(equivalent("15", "t", "50")).toBe("300 sac");
    expect(equivalent("2500", "kg", null)).toBe("2.5 t");
    expect(equivalent("24", "m3", null)).toBeNull();
    expect(equivalent("100", "u", null)).toBeNull();
    expect(equivalent("200", "l", null)).toBeNull();
    // Sac sans masse de sac : aucune équivalence inventée.
    expect(equivalent("10", "sac", null)).toBeNull();
  });
});

describe("miroir de calcul : annonce avant l'enregistrement d'une livraison (CA-MAT-006.3, vecteurs de statut)", () => {
  const milliOf = (quantity: { value: string; unit: MeasureUnitCode }) => ({ milli: parseMilli(quantity.value) as bigint, unit: quantity.unit });

  // La dernière livraison du vecteur est celle qu'on annonce ; les précédentes forment le reçu cumulé dans l'unité de la commande.
  const cases = vectors.status.filter((vector) => vector.deliveries.length > 0);

  it.each(cases)("$name", ({ ordered, bagMassKg, deliveries, tolerancePercent, expected, error }) => {
    const requested = milliOf(ordered);
    const previous = error ? 0n : deliveries.slice(0, -1).reduce((sum, delivery) => sum + convertQuantity(milliOf(delivery), ordered.unit, bagMassKg).milli, 0n);
    const last = deliveries[deliveries.length - 1] as { value: string; unit: MeasureUnitCode };
    const announcement = announceDelivery({
      entered: milliOf(last),
      requested,
      received: { milli: previous, unit: ordered.unit },
      bagMassKg,
      tolerancePercent: Number(tolerancePercent),
    });

    if (error || !expected) {
      // Unité non convertible : pas d'annonce (le serveur répondra UNITES_INCOMPATIBLES).
      expect(announcement).toBeNull();
    } else if (expected.status === "PartiallyDelivered") {
      expect(announcement?.kind).toBe("partial");
      if (announcement?.kind === "partial") expect(milliToText(announcement.remaining.milli)).toBe(expected.remaining);
    } else if (Number(expected.variance) > 0) {
      expect(announcement?.kind).toBe("surplus");
      if (announcement?.kind === "surplus") {
        expect(milliToText(announcement.surplus.milli)).toBe(expected.variance);
        expect(Number(announcement.percentHundredths) / 100).toBe(Number(expected.variancePercent));
      }
    } else {
      expect(announcement?.kind).toBe("complete");
    }
  });

  it("annonce « surplus de +20 sacs (+5,00 %) » et refuse une unité non convertible", () => {
    const surplus = announceDelivery({
      entered: { milli: parseMilli("420") as bigint, unit: "sac" },
      requested: { milli: parseMilli("400") as bigint, unit: "sac" },
      received: { milli: 0n, unit: "sac" },
      bagMassKg: "50",
      tolerancePercent: 0,
    });
    expect(surplus).toEqual({ kind: "surplus", surplus: { milli: 20000n, unit: "sac" }, percentHundredths: 500n });

    const incompatible = announceDelivery({
      entered: { milli: parseMilli("10") as bigint, unit: "t" },
      requested: { milli: parseMilli("24") as bigint, unit: "m3" },
      received: { milli: 0n, unit: "m3" },
      bagMassKg: null,
      tolerancePercent: 0,
    });
    expect(incompatible).toBeNull();
  });
});
