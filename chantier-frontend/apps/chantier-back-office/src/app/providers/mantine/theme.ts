import { createTheme, type MantineColorsTuple } from "@mantine/core";

// Bleu-vert foncé : le texte blanc sur les teintes 7 à 9 dépasse 7:1 (contraste AAA), lisible en plein soleil.
const mainAppColor: MantineColorsTuple = [
  "#e6f4f5",
  "#c2e3e6",
  "#96ced3",
  "#68b6bd",
  "#3f9ea6",
  "#238790",
  "#146e77",
  "#0b565e",
  "#064147",
  "#042f34",
];

export const mantineTheme = createTheme({
  // Cairo couvre l'arabe et le latin ; fichiers hébergés localement (@fontsource), pas de CDN.
  fontFamily: "Cairo, system-ui, sans-serif",
  headings: { fontFamily: "Cairo, system-ui, sans-serif" },
  colors: {
    primary: mainAppColor,
  },
  primaryColor: "primary",
  primaryShade: { light: 7, dark: 4 },
  // Texte noir franc plutôt que le gris par défaut.
  black: "#111111",
  defaultRadius: "md",
  // Anneau de focus visible au clavier (WCAG 2.4.7), pas au clic.
  focusRing: "auto",
  components: {
    Table: {
      defaultProps: {
        withTableBorder: true,
        withRowBorders: true,
        withColumnBorders: true,
        striped: true,
        highlightOnHover: true,
      },
    },
    // Cibles tactiles d'au moins 36 px (WCAG 2.5.8 demande 24 px).
    Button: { defaultProps: { size: "md" } },
    TextInput: { defaultProps: { size: "md" } },
    PasswordInput: { defaultProps: { size: "md" } },
    Select: { defaultProps: { size: "md" } },
    NumberInput: { defaultProps: { size: "md" } },
    ActionIcon: { defaultProps: { size: "lg" } },
  },
});
