import { MantineProvider } from "@mantine/core";
import { render, type RenderResult } from "@testing-library/react";
import type { i18n as I18nInstance } from "i18next";
import type { ReactElement } from "react";
import { I18nextProvider } from "react-i18next";

import { createI18n } from "../i18n";
import { LanguageDirectionProvider } from "../LanguageDirectionProvider";
import type { Language } from "../languages";

/** Affiche un composant avec les mêmes fournisseurs que l'application (i18n, direction, Mantine). */
export const renderWithI18n = (
  ui: ReactElement,
  language: Language = "fr",
): RenderResult & { i18n: I18nInstance } => {
  const instance: I18nInstance = createI18n(language, { persist: false });
  const result = render(
    <I18nextProvider i18n={instance}>
      <LanguageDirectionProvider>
        <MantineProvider>{ui}</MantineProvider>
      </LanguageDirectionProvider>
    </I18nextProvider>,
  );
  return { ...result, i18n: instance };
};
