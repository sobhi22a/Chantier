import { mantineTheme } from "./theme";

// Luminance relative et rapport de contraste WCAG 2.x.
const luminance = (hex: string): number => {
  const [r, g, b] = [1, 3, 5].map((start) => {
    const channel = parseInt(hex.slice(start, start + 2), 16) / 255;
    return channel <= 0.03928 ? channel / 12.92 : ((channel + 0.055) / 1.055) ** 2.4;
  }) as [number, number, number];
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
};
const contrast = (foreground: string, background: string): number => {
  const [lighter, darker] = [luminance(foreground), luminance(background)].sort((a, b) => b - a) as [number, number];
  return (lighter + 0.05) / (darker + 0.05);
};

describe("thème Mantine (contraste élevé, plein soleil)", () => {
  const primary = mantineTheme.colors?.["primary"] as readonly string[];
  const lightShade = (mantineTheme.primaryShade as { light: number }).light;

  it("garde un contraste d'au moins 7:1 entre le texte blanc et la couleur des boutons (WCAG AAA)", () => {
    expect(contrast("#ffffff", primary[lightShade] as string)).toBeGreaterThanOrEqual(7);
  });

  it("garde un texte courant noir franc sur fond blanc", () => {
    expect(contrast(mantineTheme.black as string, "#ffffff")).toBeGreaterThanOrEqual(15);
  });

  it("utilise la police Cairo, qui couvre l'arabe et le latin", () => {
    expect(mantineTheme.fontFamily).toContain("Cairo");
  });
});
