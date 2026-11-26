import type { MeasureUnitCode } from "@chantier-frontend/i18n";

/**
 * Miroir d'AFFICHAGE du calcul des quantités (ADR 0014) : équivalence « 300 sacs = 15 T » pendant la frappe, contrôle de
 * saisie et date de besoin proposée. Il ne décide de rien : le serveur recalcule toujours et sa valeur fait foi.
 * Aucun `number` flottant : les valeurs sont des entiers `BigInt` en millièmes d'unité, arrondis « loin de zéro ».
 * Testé par les vecteurs partagés `docs/api/vecteurs-materiaux.json` (mêmes cas que .NET et Dart).
 */
export type QuantityErrorCode = "QUANTITE_INVALIDE" | "QUANTITE_ENTIERE_REQUISE" | "UNITES_INCOMPATIBLES";

export class QuantityMirrorError extends Error {
  constructor(readonly code: QuantityErrorCode) {
    super(code);
    this.name = "QuantityMirrorError";
  }
}

const MILLI = 1000n;
const DECIMALS = 3;
const INTEGER_ONLY_UNITS: readonly string[] = ["sac", "u"];
const DECIMAL_PATTERN = /^(\d+)(?:\.(\d+))?$/;

/** « 17.5 » → 17500n. `null` si le texte n'est pas un décimal positif ou a plus de 3 décimales. */
export const parseMilli = (text: string): bigint | null => {
  const match = DECIMAL_PATTERN.exec(text.trim());
  if (!match) return null;
  const [, integerPart = "", fraction = ""] = match;
  if (fraction.length > DECIMALS) return null;
  return BigInt(integerPart) * MILLI + BigInt(fraction.padEnd(DECIMALS, "0"));
};

/** 15000n → « 15 » ; 405200n → « 405.2 » (sans zéros inutiles, point décimal : forme des vecteurs). */
export const milliToText = (milli: bigint): string => {
  const negative = milli < 0n;
  const absolute = negative ? -milli : milli;
  const integerPart = absolute / MILLI;
  const fraction = (absolute % MILLI).toString().padStart(DECIMALS, "0").replace(/0+$/, "");
  return `${negative ? "-" : ""}${integerPart}${fraction ? `.${fraction}` : ""}`;
};

/** Nombre renvoyé par le serveur (3 décimales au plus) → millièmes ; l'arrondi ne fait que retirer le bruit binaire du JSON. */
export const numberToMilli = (value: number): bigint => BigInt(Math.round(value * 1000));

/** Division entière arrondie « loin de zéro » (jamais l'arrondi bancaire). */
const divideAwayFromZero = (numerator: bigint, denominator: bigint): bigint => {
  const quotient = numerator / denominator;
  const remainder = numerator % denominator;
  return remainder * 2n >= denominator ? quotient + 1n : quotient;
};

const isMassUnit = (unit: string): boolean => unit === "kg" || unit === "t" || unit === "sac";

/** Masse en kg d'une unité, en rationnel (numérateur, dénominateur) exprimé en millièmes de kg par millième d'unité. */
const kilogramsPerUnit = (unit: string, bagMassMilli: bigint | null): readonly [bigint, bigint] => {
  if (unit === "kg") return [1n, 1n];
  if (unit === "t") return [1000n, 1n];
  if (bagMassMilli === null || bagMassMilli <= 0n) throw new QuantityMirrorError("UNITES_INCOMPATIBLES");
  return [bagMassMilli, MILLI]; // 1 sac = bagMassMilli / 1000 kg
};

export interface MilliQuantity {
  milli: bigint;
  unit: MeasureUnitCode;
}

/**
 * Convertit dans une unité cible. Seules conversions : sac ↔ kg ↔ T avec la masse du sac du produit.
 * Même unité : valeur inchangée. Toute autre paire : `UNITES_INCOMPATIBLES`.
 */
export const convertQuantity = (from: MilliQuantity, to: MeasureUnitCode, bagMassKg: string | null): MilliQuantity => {
  if (from.unit === to) return { milli: from.milli, unit: to };
  if (!isMassUnit(from.unit) || !isMassUnit(to)) throw new QuantityMirrorError("UNITES_INCOMPATIBLES");
  const bagMassMilli = bagMassKg === null ? null : parseMilli(bagMassKg);
  const [fromNumerator, fromDenominator] = kilogramsPerUnit(from.unit, bagMassMilli);
  const [toNumerator, toDenominator] = kilogramsPerUnit(to, bagMassMilli);
  const milli = divideAwayFromZero(from.milli * fromNumerator * toDenominator, fromDenominator * toNumerator);
  return { milli, unit: to };
};

/**
 * Contrôle de saisie (confort, jamais décisionnel) : > 0, 3 décimales au plus, entier pour `sac` et `u`.
 * Renvoie le code d'erreur du serveur correspondant, ou `null` si la saisie est acceptable.
 */
export const checkQuantity = (valueText: string, unit: string): QuantityErrorCode | null => {
  const milli = parseMilli(valueText);
  if (milli === null || milli <= 0n) return "QUANTITE_INVALIDE";
  if (INTEGER_ONLY_UNITS.includes(unit) && milli % MILLI !== 0n) return "QUANTITE_ENTIERE_REQUISE";
  return null;
};

/** Saisie « 2,5 » ou « 2.5 » (espaces ignorés) → texte au point décimal ; `null` si illisible. */
export const normalizeQuantityText = (input: string): string | null => {
  const text = input.replace(/[\s\u00A0]/g, "").replace(",", ".");
  return DECIMAL_PATTERN.test(text) ? text : null;
};

const DATE_PATTERN = /^(\d{4})-(\d{2})-(\d{2})$/;

/** Date de besoin proposée : aujourd'hui + N jours calendaires (`2028-02-28` + 3 → `2028-03-02`). */
export const addDays = (dateOnly: string, days: number): string => {
  const match = DATE_PATTERN.exec(dateOnly);
  if (!match) throw new RangeError("Date complète attendue (AAAA-MM-JJ)");
  const [, year, month, day] = match;
  const shifted = new Date(Date.UTC(Number(year), Number(month) - 1, Number(day) + days));
  return shifted.toISOString().slice(0, 10);
};

/** Jours calendaires entre deux dates complètes (`to` − `from`) : avertissement indicatif « livraison prévue N j après le besoin ». */
export const daysBetween = (from: string, to: string): number => {
  const start = DATE_PATTERN.exec(from);
  const end = DATE_PATTERN.exec(to);
  if (!start || !end) throw new RangeError("Date complète attendue (AAAA-MM-JJ)");
  const toUtc = (match: RegExpExecArray) => Date.UTC(Number(match[1]), Number(match[2]) - 1, Number(match[3]));
  return Math.round((toUtc(end) - toUtc(start)) / 86_400_000);
};

/** Équivalence affichée sous la quantité : sac → T (ou kg sous une tonne), T ou kg → sacs, kg ↔ T. `null` si non pertinente. */
export const equivalenceFor = (
  quantity: MilliQuantity,
  bagMassKg: string | null,
): MilliQuantity | null => {
  const hasBag = bagMassKg !== null && parseMilli(bagMassKg) !== null;
  const attempt = (to: MeasureUnitCode): MilliQuantity | null => {
    try {
      return convertQuantity(quantity, to, bagMassKg);
    } catch {
      return null;
    }
  };
  switch (quantity.unit) {
    case "sac": {
      if (!hasBag) return null;
      const tonnes = attempt("t");
      return tonnes && tonnes.milli >= MILLI ? tonnes : attempt("kg");
    }
    case "t":
      return hasBag ? attempt("sac") : attempt("kg");
    case "kg":
      return hasBag ? attempt("sac") : attempt("t");
    default:
      return null;
  }
};

/** Annonce faite avant d'enregistrer une livraison (CA-MAT-006.3) : indicative, le serveur recalcule et sa valeur fait foi. */
export type DeliveryAnnouncement =
  | { kind: "partial"; remaining: MilliQuantity }
  | { kind: "complete" }
  | { kind: "surplus"; surplus: MilliQuantity; percentHundredths: bigint };

export interface DeliveryAnnouncementInput {
  /** Quantité saisie, dans l'unité saisie. */
  entered: MilliQuantity;
  /** Quantité de la demande (unité de la commande). */
  requested: MilliQuantity;
  /** Reçu cumulé avant cette livraison (unité de la commande). */
  received: MilliQuantity;
  bagMassKg: string | null;
  /** Tolérance de « livraison complète » en pourcentage du manque (réglage du serveur). */
  tolerancePercent: number;
}

/**
 * Livraison partielle, complète ou en surplus, comparée dans l'unité de la commande (conversion sac ↔ kg ↔ T seulement).
 * `null` quand la conversion est impossible (le serveur répondra `UNITES_INCOMPATIBLES`) ou la quantité de la demande nulle.
 */
export const announceDelivery = (input: DeliveryAnnouncementInput): DeliveryAnnouncement | null => {
  if (input.requested.milli <= 0n) return null;
  let entered: MilliQuantity;
  try {
    entered = convertQuantity(input.entered, input.requested.unit, input.bagMassKg);
  } catch {
    return null;
  }
  const variance = input.received.milli + entered.milli - input.requested.milli;
  if (variance === 0n) return { kind: "complete" };
  const percentHundredths = divideAwayFromZero((variance < 0n ? -variance : variance) * 10000n, input.requested.milli);
  if (variance > 0n) return { kind: "surplus", surplus: { milli: variance, unit: input.requested.unit }, percentHundredths };
  const toleranceHundredths = BigInt(Math.round(input.tolerancePercent * 100));
  if (percentHundredths <= toleranceHundredths) return { kind: "complete" };
  return { kind: "partial", remaining: { milli: -variance, unit: input.requested.unit } };
};
