import { useTranslation } from "react-i18next";

import { formatNumber } from "./formatters";
import { Ltr } from "./Ltr";
import { toLanguage } from "./languages";

/** Unités du référentiel (skill `metier-chantier`) : codes stables du serveur. */
export const MEASURE_UNITS = ["u", "ml", "m2", "m3", "kg", "t", "sac", "l", "h", "j", "pj", "ft"] as const;
export type MeasureUnitCode = (typeof MEASURE_UNITS)[number];

export const isMeasureUnit = (value: unknown): value is MeasureUnitCode =>
  typeof value === "string" && (MEASURE_UNITS as readonly string[]).includes(value);

/** Une quantité renvoyée par le serveur : valeur et unité voyagent toujours ensemble (règle 1). */
export interface QuantityValue {
  value?: number | null;
  unit?: string | null;
}

const NO_BREAK_SPACE = "\u00A0";
const LEFT_TO_RIGHT_ISOLATE = "\u2066";
const POP_DIRECTIONAL_ISOLATE = "\u2069";
const MAX_QUANTITY_DECIMALS = 3;

/**
 * Libellés d'unités et mise en forme des quantités : « 300 sacs », « 15 T ». Une quantité sans unité n'est jamais
 * affichée telle quelle (le point d'interrogation signale une donnée inexploitable plutôt que de la masquer).
 */
export const useQuantityFormatter = () => {
  const { t, i18n } = useTranslation("common");
  const translate = t as unknown as (key: string, options?: Record<string, unknown>) => string;
  const isArabic = toLanguage(i18n.resolvedLanguage ?? i18n.language) === "ar";

  /** « sac » ou « sacs » selon la valeur (pluriel de la langue) ; un code inconnu du client s'affiche tel quel. */
  const unitLabel = (unit: string | null | undefined, value = 1): string =>
    isMeasureUnit(unit) ? translate(`measureUnits.${unit}`, { count: value }) : (unit ?? "?");

  const unitName = (unit: string): string => (isMeasureUnit(unit) ? translate(`measureUnitNames.${unit}`) : unit);

  const numberText = (value: number | null | undefined): string =>
    value === null || value === undefined ? "?" : formatNumber(value, { maximumFractionDigits: MAX_QUANTITY_DECIMALS });

  /** Texte brut (titres, messages) ; en arabe le nombre est isolé pour rester lisible de gauche à droite. */
  const quantityText = (quantity: QuantityValue | null | undefined): string => {
    if (!quantity) return "";
    const digits = numberText(quantity.value);
    const number = isArabic ? `${LEFT_TO_RIGHT_ISOLATE}${digits}${POP_DIRECTIONAL_ISOLATE}` : digits;
    return `${number}${NO_BREAK_SPACE}${unitLabel(quantity.unit, quantity.value ?? 1)}`;
  };

  return { unitLabel, unitName, quantityText };
};

/** Quantité affichée dans une page : le nombre de gauche à droite, puis l'unité traduite. */
export const QuantityText = ({ quantity }: { quantity: QuantityValue | null | undefined }) => {
  const { unitLabel } = useQuantityFormatter();
  if (!quantity) return null;
  const digits =
    quantity.value === null || quantity.value === undefined
      ? "?"
      : formatNumber(quantity.value, { maximumFractionDigits: MAX_QUANTITY_DECIMALS });
  return (
    <span>
      <Ltr>{digits}</Ltr>
      {NO_BREAK_SPACE}
      {unitLabel(quantity.unit, quantity.value ?? 1)}
    </span>
  );
};
