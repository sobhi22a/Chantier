import { render, screen } from "@testing-library/react";
import { I18nextProvider } from "react-i18next";

import { todayDateOnly } from "./formatters";
import { createI18n } from "./i18n";
import { QuantityText, useQuantityFormatter } from "./quantity";

const NBSP = "\u00A0";

const Probe = ({ value, unit }: { value: number; unit: string }) => {
  const { quantityText, unitName } = useQuantityFormatter();
  return (
    <p>
      <span data-testid="text">{quantityText({ value, unit })}</span>
      <span data-testid="name">{unitName(unit)}</span>
      <QuantityText quantity={{ value, unit }} />
    </p>
  );
};

const renderProbe = (language: "fr" | "ar", value: number, unit: string) =>
  render(
    <I18nextProvider i18n={createI18n(language, { persist: false, syncDocument: false })}>
      <Probe value={value} unit={unit} />
    </I18nextProvider>,
  );

describe("quantités : l'unité accompagne toujours la valeur (CA-MAT-002.10)", () => {
  it("accorde l'unité en français : 1 sac, 300 sacs, 15 T", () => {
    const { unmount } = renderProbe("fr", 300, "sac");
    expect(screen.getByTestId("text").textContent).toBe(`300${NBSP}sacs`);
    unmount();
    const one = renderProbe("fr", 1, "sac");
    expect(screen.getByTestId("text").textContent).toBe(`1${NBSP}sac`);
    one.unmount();
    renderProbe("fr", 15, "t");
    expect(screen.getByTestId("text").textContent).toBe(`15${NBSP}T`);
  });

  it("garde 3 décimales au plus, virgule décimale et chiffres 0-9", () => {
    renderProbe("fr", 20.26, "t");
    expect(screen.getByTestId("text").textContent).toBe(`20,26${NBSP}T`);
  });

  it("isole le nombre en arabe et traduit l'unité (pluriel arabe)", () => {
    const { unmount } = renderProbe("ar", 300, "sac");
    expect(screen.getByTestId("text").textContent).toBe(`\u2066300\u2069${NBSP}كيس`);
    unmount();
    renderProbe("ar", 5, "sac");
    expect(screen.getByTestId("text").textContent).toContain("أكياس");
  });

  it("affiche le nombre dans un isolat de gauche à droite", () => {
    const { container } = renderProbe("ar", 15, "t");
    expect([...container.querySelectorAll('bdi[dir="ltr"]')].map((node) => node.textContent)).toContain("15");
  });

  it("garde un code d'unité inconnu tel quel (ensemble ouvert)", () => {
    renderProbe("fr", 2, "zz");
    expect(screen.getByTestId("name").textContent).toBe("zz");
  });
});

describe("todayDateOnly", () => {
  it("donne la date d'Algérie (UTC+1) et non celle d'UTC", () => {
    expect(todayDateOnly(new Date("2026-11-25T23:30:00Z"))).toBe("2026-11-26");
    expect(todayDateOnly(new Date("2026-11-25T08:00:00Z"))).toBe("2026-11-25");
  });
});
