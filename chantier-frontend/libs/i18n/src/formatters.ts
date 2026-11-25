/**
 * Formateurs d'affichage. Ils ne calculent rien : ils mettent en forme les valeurs renvoyées par le serveur.
 *
 * Mêmes conventions en français et en arabe (CA-014.7, H-10) : chiffres 0 à 9, virgule décimale,
 * espace insécable entre les milliers, dates JJ/MM/AAAA, heures sur 24 h, fuseau Africa/Algiers.
 * `Intl` fournit les chiffres et le regroupement ; les séparateurs sont ensuite normalisés, car `ar-DZ`
 * renvoie sinon « . » pour les milliers et des repères bidirectionnels dans les dates.
 * Pour afficher ces valeurs dans une page arabe, les envelopper dans `<Ltr>` (sens de lecture).
 */
export const TIME_ZONE = "Africa/Algiers";
export const CURRENCY = "DZD";

const INTL_LOCALE = "fr-DZ-u-nu-latn";
const NO_BREAK_SPACE = "\u00A0";
const DECIMAL_SEPARATOR = ",";
const MINUS_SIGN = "\u2212";

export interface NumberFormatOptions {
  minimumFractionDigits?: number;
  maximumFractionDigits?: number;
}

const numberFormats = new Map<string, Intl.NumberFormat>();

const getNumberFormat = (minimumFractionDigits: number, maximumFractionDigits: number): Intl.NumberFormat => {
  const key = `${minimumFractionDigits}:${maximumFractionDigits}`;
  let format = numberFormats.get(key);
  if (!format) {
    format = new Intl.NumberFormat(INTL_LOCALE, {
      minimumFractionDigits,
      maximumFractionDigits,
      // Un résultat arrondi à zéro ne porte pas de signe moins (« −0,00 »).
      signDisplay: "negative",
    });
    numberFormats.set(key, format);
  }
  return format;
};

/** `1234567.5` → `1 234 567,5` (espace insécable). Renvoie une chaîne vide si la valeur n'est pas un nombre fini. */
export const formatNumber = (value: number, options: NumberFormatOptions = {}): string => {
  if (!Number.isFinite(value)) return "";
  const minimumFractionDigits = options.minimumFractionDigits ?? 0;
  const maximumFractionDigits = Math.max(options.maximumFractionDigits ?? 3, minimumFractionDigits);
  return getNumberFormat(minimumFractionDigits, maximumFractionDigits)
    .formatToParts(value)
    .map((part) => {
      switch (part.type) {
        case "group":
          return NO_BREAK_SPACE;
        case "decimal":
          return DECIMAL_SEPARATOR;
        case "minusSign":
          return MINUS_SIGN;
        case "plusSign":
          return "+";
        case "integer":
        case "fraction":
          return part.value;
        default:
          return "";
      }
    })
    .join("");
};

/** Montant en dinars, toujours 2 décimales : `185000000` → `185 000 000,00 DZD`. */
export const formatAmount = (value: number): string => {
  const digits = formatNumber(value, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  return digits === "" ? "" : `${digits}${NO_BREAK_SPACE}${CURRENCY}`;
};

/** Cote de niveau signée, 2 décimales, en mètres (sans l'unité) : `+3,40`, `−1,90`, `±0,00`. */
export const formatElevation = (value: number): string => {
  if (!Number.isFinite(value)) return "";
  const hundredths = Math.round(Math.abs(value) * 100);
  const digits = formatNumber(hundredths / 100, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  if (hundredths === 0) return `±${digits}`;
  return `${value > 0 ? "+" : MINUS_SIGN}${digits}`;
};

const DATE_ONLY_PATTERN = /^(\d{4})-(\d{2})-(\d{2})$/;

/**
 * Date métier (`DateOnly` du serveur, sans fuseau) : `2026-11-24` → `24/11/2026`.
 * Aucune conversion de fuseau. Renvoie `null` si la date est absente, incomplète ou impossible
 * (l'interface affiche alors « À définir » ou rien : jamais de date inventée).
 */
export const formatDateOnly = (value: string | null | undefined): string | null => {
  if (!value) return null;
  const match = DATE_ONLY_PATTERN.exec(value);
  if (!match) return null;
  const [, year, month, day] = match;
  const probe = new Date(Date.UTC(Number(year), Number(month) - 1, Number(day)));
  const isRealDate =
    probe.getUTCFullYear() === Number(year) &&
    probe.getUTCMonth() === Number(month) - 1 &&
    probe.getUTCDate() === Number(day);
  return isRealDate ? `${day}/${month}/${year}` : null;
};

// Horodatage du serveur : UTC (« Z ») ou décalage explicite. Sans fuseau, l'heure serait ambiguë : refusée.
const INSTANT_PATTERN = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?(?:Z|[+-]\d{2}:\d{2})$/;

let dateTimeFormat: Intl.DateTimeFormat | undefined;

const getInstantParts = (value: string | null | undefined): Record<string, string> | null => {
  if (!value || !INSTANT_PATTERN.test(value)) return null;
  const time = Date.parse(value);
  if (Number.isNaN(time)) return null;
  dateTimeFormat ??= new Intl.DateTimeFormat(INTL_LOCALE, {
    timeZone: TIME_ZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  });
  const parts: Record<string, string> = {};
  for (const part of dateTimeFormat.formatToParts(time)) parts[part.type] = part.value;
  return parts;
};

/** Horodatage UTC du serveur → `24/11/2026 11:15` à l'heure d'Algérie. `null` si absent ou sans fuseau. */
export const formatDateTime = (value: string | null | undefined): string | null => {
  const parts = getInstantParts(value);
  return parts ? `${parts["day"]}/${parts["month"]}/${parts["year"]} ${parts["hour"]}:${parts["minute"]}` : null;
};

/** Horodatage UTC du serveur → `11:15` à l'heure d'Algérie (24 h). */
export const formatTime = (value: string | null | undefined): string | null => {
  const parts = getInstantParts(value);
  return parts ? `${parts["hour"]}:${parts["minute"]}` : null;
};
