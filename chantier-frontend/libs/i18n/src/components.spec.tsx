import { useDirection as useMantineDirection } from "@mantine/core";
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import { LanguageSwitcher } from "./LanguageSwitcher";
import { Ltr } from "./Ltr";
import { renderWithI18n } from "./testing/renderWithI18n";
import { ZoneLabel } from "./ZoneLabel";
import type { ZoneLabelInput } from "./zoneLabelParts";

const MantineDirectionProbe = () => <output data-testid="mantine-dir">{useMantineDirection().dir}</output>;

describe("Ltr", () => {
  it("isole la valeur en gauche-à-droite, même dans une page arabe", () => {
    const { container } = renderWithI18n(<Ltr>CH-ECO-UV18</Ltr>, "ar");
    const isolated = container.querySelector("bdi");
    expect(isolated?.getAttribute("dir")).toBe("ltr");
    expect(isolated?.textContent).toBe("CH-ECO-UV18");
    expect(document.documentElement.dir).toBe("rtl");
  });
});

describe("ZoneLabel (CA-009.2, CA-014.4)", () => {
  const classroom = { block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 2 } as const;
  // Mantine ajoute des <style> dans le conteneur : on lit seulement le libellé.
  const renderLabel = (zone: ZoneLabelInput, language: "fr" | "ar") =>
    renderWithI18n(
      <p data-testid="label">
        <ZoneLabel zone={zone} />
      </p>,
      language,
    );
  const label = () => screen.getByTestId("label");

  it("écrit « Bloc 01 · +3,40 m · Classe 02 » en français", () => {
    renderLabel(classroom, "fr");
    expect(label().textContent).toBe("Bloc 01 · +3,40 m · Classe 02");
  });

  it("écrit le libellé arabe et garde la cote de gauche à droite", () => {
    renderLabel(classroom, "ar");
    expect(label().textContent).toBe("Bloc 01 · +3,40 m · قسم 02");
    const ltrValues = [...label().querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent);
    expect(ltrValues).toEqual(["+3,40 m"]);
  });

  it("n'affiche que les morceaux connus d'une zone", () => {
    const { unmount } = renderLabel({ block: "Bloc 02" }, "fr");
    expect(label().textContent).toBe("Bloc 02");
    unmount();

    renderLabel({ block: "Bloc 02", roomType: "Facade" }, "fr");
    expect(label().textContent).toBe("Bloc 02 · Façade");
  });
});

describe("LanguageSwitcher et direction", () => {
  it("bascule du français à l'arabe : lang, dir, textes et direction Mantine suivent", async () => {
    const user = userEvent.setup();
    const onLanguageChange = vi.fn();
    renderWithI18n(
      <>
        <LanguageSwitcher onLanguageChange={onLanguageChange} />
        <MantineDirectionProbe />
      </>,
      "fr",
    );
    expect(document.documentElement.lang).toBe("fr");
    expect(document.documentElement.dir).toBe("ltr");
    expect(screen.getByRole("radiogroup", { name: "Langue" })).toBeTruthy();
    expect(screen.getByTestId("mantine-dir").textContent).toBe("ltr");

    await user.click(screen.getByText("العربية"));

    await waitFor(() => expect(document.documentElement.dir).toBe("rtl"));
    expect(document.documentElement.lang).toBe("ar");
    expect(screen.getByRole("radiogroup", { name: "اللغة" })).toBeTruthy();
    await waitFor(() => expect(screen.getByTestId("mantine-dir").textContent).toBe("rtl"));
    expect(onLanguageChange).toHaveBeenCalledExactlyOnceWith("ar");
  });

  it("revient au français et rétablit ltr", async () => {
    const user = userEvent.setup();
    renderWithI18n(<LanguageSwitcher />, "ar");
    expect(document.documentElement.dir).toBe("rtl");

    await user.click(screen.getByText("Français"));

    await waitFor(() => expect(document.documentElement.dir).toBe("ltr"));
    expect(document.documentElement.lang).toBe("fr");
    expect(screen.getByRole("radiogroup", { name: "Langue" })).toBeTruthy();
  });

  it("ne déclenche rien quand on choisit la langue déjà active", async () => {
    const user = userEvent.setup();
    const onLanguageChange = vi.fn();
    renderWithI18n(<LanguageSwitcher onLanguageChange={onLanguageChange} />, "fr");

    await user.click(screen.getByText("Français"));

    expect(onLanguageChange).not.toHaveBeenCalled();
  });
});
