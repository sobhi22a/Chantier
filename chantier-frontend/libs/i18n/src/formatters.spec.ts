import {
  formatAmount,
  formatDateOnly,
  formatDateTime,
  formatElevation,
  formatNumber,
  formatPercent,
  formatTime,
} from "./formatters";

const NBSP = "\u00A0";
const MINUS = "\u2212";

describe("formatNumber", () => {
  it("utilise les chiffres 0-9, la virgule décimale et l'espace insécable pour les milliers", () => {
    expect(formatNumber(1234567.5)).toBe(`1${NBSP}234${NBSP}567,5`);
    expect(formatNumber(0.25, { minimumFractionDigits: 2 })).toBe("0,25");
    expect(formatNumber(12)).toBe("12");
  });

  it("n'affiche que des chiffres latins", () => {
    expect(formatNumber(1234567.89, { minimumFractionDigits: 2 })).toMatch(/^[0-9\u00A0,]+$/);
  });

  it("utilise le vrai signe moins et jamais « −0 »", () => {
    expect(formatNumber(-12.5)).toBe(`${MINUS}12,5`);
    expect(formatNumber(-0.001, { minimumFractionDigits: 2, maximumFractionDigits: 2 })).toBe("0,00");
  });

  it("renvoie du vide pour une valeur qui n'est pas un nombre", () => {
    expect(formatNumber(Number.NaN)).toBe("");
    expect(formatNumber(Number.POSITIVE_INFINITY)).toBe("");
  });
});

describe("formatAmount", () => {
  it("affiche le montant du marché en DZD avec 2 décimales (CA-007.8)", () => {
    expect(formatAmount(185000000)).toBe(`185${NBSP}000${NBSP}000,00${NBSP}DZD`);
    expect(formatAmount(96400000)).toBe(`96${NBSP}400${NBSP}000,00${NBSP}DZD`);
  });

  it("arrondit au centime, loin de zéro", () => {
    expect(formatAmount(10.005)).toBe(`10,01${NBSP}DZD`);
    expect(formatAmount(0.5)).toBe(`0,50${NBSP}DZD`);
  });

  it("n'invente rien quand la valeur est invalide", () => {
    expect(formatAmount(Number.NaN)).toBe("");
  });
});

describe("formatElevation (CA-009.2)", () => {
  it.each([
    [3.4, "+3,40"],
    [6.8, "+6,80"],
    [10.2, "+10,20"],
    [-1.9, `${MINUS}1,90`],
    [0, "±0,00"],
    [-0, "±0,00"],
    [-20, `${MINUS}20,00`],
    [60, "+60,00"],
    [0.004, "±0,00"],
  ])("%s → %s", (value, expected) => {
    expect(formatElevation(value)).toBe(expected);
  });

  it("garde la virgule décimale quelle que soit la langue", () => {
    expect(formatElevation(3.4)).not.toContain(".");
  });
});

describe("formatDateOnly", () => {
  it("affiche une date métier JJ/MM/AAAA sans décalage de fuseau", () => {
    expect(formatDateOnly("2026-11-24")).toBe("24/11/2026");
    expect(formatDateOnly("2027-08-24")).toBe("24/08/2027");
    expect(formatDateOnly("2028-02-29")).toBe("29/02/2028");
  });

  it("refuse les dates incomplètes ou impossibles (« ../08/2026 »)", () => {
    expect(formatDateOnly("../08/2026")).toBeNull();
    expect(formatDateOnly("2026-08")).toBeNull();
    expect(formatDateOnly("2026-02-30")).toBeNull();
    expect(formatDateOnly("2027-02-29")).toBeNull();
    expect(formatDateOnly("24/11/2026")).toBeNull();
  });

  it("renvoie null quand il n'y a pas de date (affichage « À définir »)", () => {
    expect(formatDateOnly(null)).toBeNull();
    expect(formatDateOnly(undefined)).toBeNull();
    expect(formatDateOnly("")).toBeNull();
  });
});

describe("formatDateTime et formatTime (fuseau Africa/Algiers)", () => {
  it("convertit l'UTC du serveur en heure d'Algérie (UTC+1)", () => {
    expect(formatDateTime("2026-11-24T10:15:00Z")).toBe("24/11/2026 11:15");
    expect(formatTime("2026-11-24T06:42:00Z")).toBe("07:42");
  });

  it("passe au jour suivant quand l'heure d'Algérie dépasse minuit", () => {
    expect(formatDateTime("2026-11-24T23:30:00Z")).toBe("25/11/2026 00:30");
  });

  it("accepte les fractions de seconde et un décalage explicite", () => {
    expect(formatDateTime("2026-11-24T10:15:00.123Z")).toBe("24/11/2026 11:15");
    expect(formatDateTime("2026-11-24T12:15:00+02:00")).toBe("24/11/2026 11:15");
  });

  it("utilise l'heure sur 24 h", () => {
    expect(formatTime("2026-11-24T13:05:00Z")).toBe("14:05");
  });

  it("refuse un horodatage sans fuseau ou invalide", () => {
    expect(formatDateTime("2026-11-24T10:15:00")).toBeNull();
    expect(formatDateTime("2026-11-24")).toBeNull();
    expect(formatDateTime("n'importe quoi")).toBeNull();
    expect(formatDateTime(null)).toBeNull();
    expect(formatTime(undefined)).toBeNull();
  });
});

describe("formatPercent", () => {
  it("affiche le pourcentage du serveur avec 2 décimales et le signe, sans jamais le recalculer", () => {
    expect(formatPercent(2)).toBe(`+2,00${NBSP}%`);
    expect(formatPercent(-66.67)).toBe(`${MINUS}66,67${NBSP}%`);
    expect(formatPercent(0)).toBe(`0,00${NBSP}%`);
    expect(formatPercent(Number.NaN)).toBe("");
  });
});
