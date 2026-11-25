import i18next, { type i18n as I18nInstance } from "i18next";
import { initReactI18next } from "react-i18next";

import {
  applyDocumentLanguage,
  DEFAULT_LANGUAGE,
  readStoredLanguage,
  storeLanguage,
  SUPPORTED_LANGUAGES,
  toLanguage,
  type Language,
} from "./languages";
import { NAMESPACES, resources } from "./resources";

/** Isolats Unicode : gardent un code, une date ou une cote lisibles de gauche à droite dans une phrase arabe. */
const LEFT_TO_RIGHT_ISOLATE = "\u2066";
const FIRST_STRONG_ISOLATE = "\u2068";
const POP_DIRECTIONAL_ISOLATE = "\u2069";

export interface CreateI18nOptions {
  /** Pose `lang` et `dir` sur `<html>` à chaque changement de langue (défaut : oui). */
  syncDocument?: boolean;
  /** Mémorise le choix dans `localStorage` (`chantier.lang`) (défaut : oui). */
  persist?: boolean;
}

/**
 * Crée une instance i18next prête à l'emploi (ressources FR et AR embarquées : fonctionne hors ligne).
 * Formateurs d'interpolation utilisables dans les fichiers de traduction :
 * `{{date, ltr}}` (valeur à lire de gauche à droite) et `{{name, isolate}}` (texte saisi par un utilisateur).
 */
export const createI18n = (language: Language = DEFAULT_LANGUAGE, options: CreateI18nOptions = {}): I18nInstance => {
  const { syncDocument = true, persist = true } = options;
  const instance = i18next.createInstance();

  void instance.use(initReactI18next).init({
    resources,
    lng: language,
    fallbackLng: DEFAULT_LANGUAGE,
    supportedLngs: [...SUPPORTED_LANGUAGES],
    ns: [...NAMESPACES],
    defaultNS: "common",
    initAsync: false,
    interpolation: { escapeValue: false },
    react: { useSuspense: false },
  });

  instance.services.formatter?.add("ltr", (value) => `${LEFT_TO_RIGHT_ISOLATE}${String(value)}${POP_DIRECTIONAL_ISOLATE}`);
  instance.services.formatter?.add("isolate", (value) => `${FIRST_STRONG_ISOLATE}${String(value)}${POP_DIRECTIONAL_ISOLATE}`);

  if (syncDocument) applyDocumentLanguage(language);
  instance.on("languageChanged", (next) => {
    if (syncDocument) applyDocumentLanguage(next);
    if (persist) storeLanguage(toLanguage(next));
  });

  return instance;
};

/** Instance de l'application : langue mémorisée, sinon français. */
export const i18n = createI18n(readStoredLanguage());
