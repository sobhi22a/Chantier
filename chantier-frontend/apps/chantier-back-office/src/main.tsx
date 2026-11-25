import { StrictMode } from "react";
import * as ReactDOM from "react-dom/client";
import { RouterProvider } from "react-router-dom";

import { setAcceptLanguageProvider } from "@chantier-frontend/api-core";
import { i18n } from "@chantier-frontend/i18n";
import { logRenderError } from "@chantier-frontend/user-interface";

import { AppProviders, backOfficeRouter } from "./app/providers";

// Polices hébergées localement (arabe + latin), jamais depuis un CDN.
import "@fontsource/cairo/400.css";
import "@fontsource/cairo/600.css";
import "@fontsource/cairo/700.css";
import "@mantine/core/styles.css";
import "@mantine/dates/styles.css";
import "@mantine/notifications/styles.css";
import "./styles.scss";

// Le serveur répond dans la langue de l'interface (en-tête Accept-Language).
setAcceptLanguageProvider(() => i18n.language);

const root = ReactDOM.createRoot(document.getElementById("root") as HTMLElement, {
  onCaughtError: logRenderError,
  onUncaughtError: logRenderError,
});

root.render(
  <StrictMode>
    <AppProviders>
      <RouterProvider router={backOfficeRouter} />
    </AppProviders>
  </StrictMode>,
);
