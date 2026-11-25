import type { ConfigFile } from "@rtk-query/codegen-openapi";

// Génère libs/api-core/src/generated/chantierApi.ts depuis docs/api/openapi.json (ADR 0006).
// Fichier généré : jamais modifié à la main. Commande : `npm run generate:api` (à la racine de chantier-frontend).
const config: ConfigFile = {
  schemaFile: "../../../docs/api/openapi.json",
  apiFile: "./src/lib/ApplicationApi.service.ts",
  apiImport: "ApplicationApiService",
  outputFile: "./src/generated/chantierApi.ts",
  exportName: "chantierApi",
  hooks: { queries: true, lazyQueries: true, mutations: true },
};

export default config;
