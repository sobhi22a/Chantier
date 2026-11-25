import { notifications } from "@mantine/notifications";
import { act, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";

import { GenericErrorBoundaryComponent } from "./genericComponents/genericErrorBoundaryComponent/GenericErrorBoundary.component";
import GenericLoaderComponent from "./genericComponents/genericLoaderComponent/GenericLoader.component";
import { logRenderError } from "./genericUtilities/logRenderError";
import { useNotifications, type NotificationType } from "./genericHooks/useNotifications";
import { renderWithProviders } from "./testing/renderWithProviders";

describe("GenericLoaderComponent", () => {
  it("annonce le chargement en français", () => {
    renderWithProviders(<GenericLoaderComponent />, "fr");
    const status = screen.getByRole("status");
    expect(status.textContent).toBe("Chargement en cours…");
  });

  it("annonce le chargement en arabe", () => {
    renderWithProviders(<GenericLoaderComponent />, "ar");
    expect(screen.getByRole("status").textContent).toBe("جارٍ التحميل…");
    expect(document.documentElement.dir).toBe("rtl");
  });

  it("affiche un texte fourni par l'appelant", () => {
    renderWithProviders(<GenericLoaderComponent loaderText="Préparation" />, "fr");
    expect(screen.getByRole("status").textContent).toBe("Préparation");
  });
});

const Boom = (): never => {
  throw new TypeError("secret-à-ne-pas-afficher");
};

describe("GenericErrorBoundaryComponent", () => {
  let consoleError: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    // React journalise lui-même les erreurs interceptées : on les rend silencieuses dans ce test.
    consoleError = vi.spyOn(console, "error").mockImplementation(() => undefined);
  });

  afterEach(() => {
    consoleError.mockRestore();
  });

  it("affiche un écran d'erreur traduit sans montrer le message technique (français)", () => {
    renderWithProviders(
      <GenericErrorBoundaryComponent>
        <Boom />
      </GenericErrorBoundaryComponent>,
      "fr",
    );
    const alert = screen.getByRole("alert");
    expect(alert.textContent).toContain("Erreur de l'application");
    expect(alert.textContent).toContain("TypeError");
    expect(alert.textContent).not.toContain("secret-à-ne-pas-afficher");
    expect(screen.getByRole("button", { name: "Recharger l'application" })).toBeTruthy();
  });

  it("affiche l'écran d'erreur en arabe avec le type d'erreur de gauche à droite", () => {
    renderWithProviders(
      <GenericErrorBoundaryComponent>
        <Boom />
      </GenericErrorBoundaryComponent>,
      "ar",
    );
    expect(screen.getByRole("alert").textContent).toContain("خطأ في التطبيق");
    expect(screen.getByRole("button", { name: "إعادة تحميل التطبيق" })).toBeTruthy();
    expect(screen.getByText("TypeError").getAttribute("dir")).toBe("ltr");
  });

  it("laisse passer les enfants quand tout va bien", () => {
    renderWithProviders(
      <GenericErrorBoundaryComponent>
        <p>contenu</p>
      </GenericErrorBoundaryComponent>,
      "fr",
    );
    expect(screen.getByText("contenu")).toBeTruthy();
  });
});

const Notifier = ({ type }: { type: NotificationType }) => {
  const { showNotification } = useNotifications();
  const [shown, setShown] = useState(false);
  return (
    <button
      type="button"
      onClick={() => {
        showNotification({ type, message: "Message de test", autoClose: false });
        setShown(true);
      }}
    >
      {shown ? "affichée" : "afficher"}
    </button>
  );
};

describe("useNotifications", () => {
  afterEach(async () => {
    // La file de notifications est globale : on la vide entre deux tests.
    await act(async () => {
      notifications.clean();
    });
  });

  it.each([
    ["success", "fr", "Succès"],
    ["error", "fr", "Erreur"],
    ["warning", "ar", "تنبيه"],
    ["info", "ar", "معلومة"],
  ] as const)("titre traduit du type %s en %s", async (type, language, title) => {
    renderWithProviders(<Notifier type={type} />, language);

    await userEvent.setup().click(screen.getByRole("button"));

    await waitFor(() => expect(screen.getByText(title)).toBeTruthy());
    expect(screen.getByText("Message de test")).toBeTruthy();
  });
});

describe("logRenderError", () => {
  let consoleError: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    consoleError = vi.spyOn(console, "error").mockImplementation(() => undefined);
  });

  afterEach(() => {
    consoleError.mockRestore();
    vi.unstubAllEnvs();
  });

  const logged = () => JSON.stringify(consoleError.mock.calls.map((call) => call.map(String)));

  it("n'écrit jamais le message de l'erreur dans la console en production", () => {
    vi.stubEnv("DEV", false);
    logRenderError(new TypeError("secret-à-ne-pas-afficher"), { componentStack: "at Boom" });
    expect(logged()).toContain("TypeError");
    expect(logged()).toContain("at Boom");
    expect(logged()).not.toContain("secret-à-ne-pas-afficher");
  });

  it("garde le message complet en développement", () => {
    vi.stubEnv("DEV", true);
    logRenderError(new TypeError("détail utile au développeur"));
    expect(logged()).toContain("détail utile au développeur");
  });

  it("accepte une valeur qui n'est pas une erreur", () => {
    vi.stubEnv("DEV", false);
    logRenderError("texte brut confidentiel");
    expect(logged()).not.toContain("texte brut confidentiel");
  });
});
