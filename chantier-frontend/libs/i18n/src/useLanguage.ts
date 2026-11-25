import { useTranslation } from "react-i18next";

import { getDirection, toLanguage, type Direction, type Language } from "./languages";

export interface UseLanguageResult {
  language: Language;
  direction: Direction;
  setLanguage: (language: Language) => Promise<void>;
}

/** Langue courante, sens d'écriture et changement de langue (immédiat, sans rechargement ni réseau). */
export const useLanguage = (): UseLanguageResult => {
  const { i18n } = useTranslation();
  const language = toLanguage(i18n.resolvedLanguage ?? i18n.language);
  return {
    language,
    direction: getDirection(language),
    setLanguage: async (next) => {
      await i18n.changeLanguage(next);
    },
  };
};
