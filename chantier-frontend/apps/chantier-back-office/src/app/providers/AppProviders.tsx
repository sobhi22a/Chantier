import { MantineProvider } from "@mantine/core";
import { Notifications } from "@mantine/notifications";
import type { i18n as I18nInstance } from "i18next";
import type { ReactNode } from "react";
import { I18nextProvider } from "react-i18next";
import { Provider } from "react-redux";

import { i18n, LanguageDirectionProvider } from "@chantier-frontend/i18n";
import { chantierStore, type ChantierStore } from "@chantier-frontend/state-store";
import { GenericErrorBoundaryComponent } from "@chantier-frontend/user-interface";

import { GlobalLoader } from "../../shared/components/GlobalLoader";
import { LanguageDatesProvider } from "./dates/LanguageDatesProvider";
import { mantineTheme } from "./mantine/theme";

export interface AppProvidersProps {
  children: ReactNode;
  /** Magasin Redux ; remplaçable dans les tests. */
  store?: ChantierStore;
  /** Instance i18next ; remplaçable dans les tests. */
  i18nInstance?: I18nInstance;
  /** `test` : Mantine sans animations ni portails différés (tests seulement). */
  mantineEnv?: "default" | "test";
}

/** Fournisseurs de l'application, de l'extérieur vers l'intérieur : Redux, i18n, direction, thème, dates, notifications. */
export const AppProviders = ({ children, store = chantierStore, i18nInstance = i18n, mantineEnv = "default" }: AppProvidersProps) => (
  <Provider store={store}>
    <I18nextProvider i18n={i18nInstance}>
      <LanguageDirectionProvider>
        <MantineProvider theme={mantineTheme} forceColorScheme="light" env={mantineEnv}>
          <LanguageDatesProvider>
            <Notifications position="bottom-center" limit={3} />
            <GlobalLoader />
            <GenericErrorBoundaryComponent>{children}</GenericErrorBoundaryComponent>
          </LanguageDatesProvider>
        </MantineProvider>
      </LanguageDirectionProvider>
    </I18nextProvider>
  </Provider>
);
