// Configuration ESLint commune aux projets React (app + libs).
// Chaque projet fait : `export default [...reactConfig]` pour rester identique à la convention Kardinal
// tout en gardant les règles de l'ADR 0007 au même endroit.
import nx from "@nx/eslint-plugin";
import baseConfig from "./eslint.config.mjs";

export default [
  ...baseConfig,
  ...nx.configs["flat/react"],
  {
    files: ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx"],
    rules: {
      // Kardinal désactivait cette règle : ici elle reste active (effets avec dépendances correctes).
      "react-hooks/exhaustive-deps": "error",
    },
  },
  {
    // ADR 0007 : aucun texte en dur dans l'interface, tout passe par i18n.
    files: ["**/*.tsx"],
    ignores: ["**/*.spec.tsx", "**/*.test.tsx", "**/testing/**"],
    rules: {
      "react/jsx-no-literals": [
        "error",
        {
          noStrings: true,
          ignoreProps: true,
          // Séparateurs purement typographiques, sans langue.
          allowedStrings: ["·", "/", "-", "–", "—", ":", "|", "(", ")", "+", "−", "±"],
        },
      ],
    },
  },
  { ignores: ["**/out-tsc"] },
];
