export const SUPPORTED_LANGUAGES = ["fr", "ar"] as const;
export type Language = (typeof SUPPORTED_LANGUAGES)[number];
export type Direction = "ltr" | "rtl";

export const DEFAULT_LANGUAGE: Language = "fr";
/** Clé du choix mémorisé dans le navigateur (ADR 0007). */
export const LANGUAGE_STORAGE_KEY = "chantier.lang";

export const isLanguage = (value: unknown): value is Language =>
  typeof value === "string" && (SUPPORTED_LANGUAGES as readonly string[]).includes(value);

/** Ramène « ar-DZ », « fr-FR »… à une langue prise en charge, sinon au français. */
export const toLanguage = (value: string | null | undefined): Language => {
  const base = value?.toLowerCase().split("-")[0];
  return isLanguage(base) ? base : DEFAULT_LANGUAGE;
};

export const getDirection = (language: string | null | undefined): Direction =>
  toLanguage(language) === "ar" ? "rtl" : "ltr";

export const readStoredLanguage = (): Language => {
  try {
    return toLanguage(globalThis.localStorage?.getItem(LANGUAGE_STORAGE_KEY));
  } catch {
    // Stockage indisponible (mode privé, politique du navigateur) : langue par défaut.
    return DEFAULT_LANGUAGE;
  }
};

export const storeLanguage = (language: Language): void => {
  try {
    globalThis.localStorage?.setItem(LANGUAGE_STORAGE_KEY, language);
  } catch {
    // Le choix s'applique quand même pour la session en cours.
  }
};

/** Pose `lang` et `dir` sur `<html>` (ADR 0007) ; sans effet hors navigateur. */
export const applyDocumentLanguage = (language: string): void => {
  if (typeof document === "undefined") return;
  const lang = toLanguage(language);
  document.documentElement.lang = lang;
  document.documentElement.dir = getDirection(lang);
};
