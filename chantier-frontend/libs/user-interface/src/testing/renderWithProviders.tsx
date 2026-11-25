import { MantineProvider } from "@mantine/core";
import { Notifications } from "@mantine/notifications";
import { render, type RenderResult } from "@testing-library/react";
import type { i18n as I18nInstance } from "i18next";
import type { ReactElement } from "react";
import { I18nextProvider } from "react-i18next";

import { createI18n, LanguageDirectionProvider, type Language } from "@chantier-frontend/i18n";

/** Affiche un composant avec les mêmes fournisseurs que l'application (i18n, direction, Mantine, notifications). */
export const renderWithProviders = (
  ui: ReactElement,
  language: Language = "fr",
): RenderResult & { i18n: I18nInstance } => {
  const i18n = createI18n(language, { persist: false });
  const result = render(
    <I18nextProvider i18n={i18n}>
      <LanguageDirectionProvider>
        <MantineProvider>
          <Notifications />
          {ui}
        </MantineProvider>
      </LanguageDirectionProvider>
    </I18nextProvider>,
  );
  return { ...result, i18n };
};
