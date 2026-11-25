import { SegmentedControl } from "@mantine/core";
import { useTranslation } from "react-i18next";

import { isLanguage, SUPPORTED_LANGUAGES, type Language } from "./languages";
import { useLanguage } from "./useLanguage";

export interface LanguageSwitcherProps {
  /** Appelé après le changement local (par ex. pour mémoriser la langue du compte côté serveur). */
  onLanguageChange?: (language: Language) => void;
}

/** Choix français / arabe : un seul geste, application immédiate, accessible au clavier. */
export const LanguageSwitcher = ({ onLanguageChange }: LanguageSwitcherProps) => {
  const { t } = useTranslation("common");
  const { language, setLanguage } = useLanguage();

  const data = SUPPORTED_LANGUAGES.map((code) => ({
    value: code,
    label: <span lang={code}>{t(`language.${code}`)}</span>,
  }));

  const handleChange = (value: string) => {
    if (!isLanguage(value) || value === language) return;
    void setLanguage(value).then(() => onLanguageChange?.(value));
  };

  return <SegmentedControl aria-label={t("language.label")} data={data} value={language} onChange={handleChange} />;
};
