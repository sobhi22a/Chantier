# chantier-frontend

Back-office web de Chantier : React 19, TypeScript strict, Nx 21 (npm workspaces), Mantine 8, Redux Toolkit / RTK Query, i18next (français et arabe, RTL).
Décisions : `docs/adr/0006` (client d'API généré) et `docs/adr/0007` (web, i18n, RTL). Plan : `docs/plans/socle.md` (tâches W1 à W5).

## Démarrer
```powershell
cd chantier-frontend
npm ci                          # sans --legacy-peer-deps
npx nx serve chantier-back-office   # http://localhost:3600
```
- URL de l'API : `VITE_BACKEND_API_BASE_URL` (modèle : `.env.example`, surcharge locale : `.env.local`). En développement, `http://localhost:8195` par défaut.

## Vérifier
```powershell
npm run verify    # nx run-many -t lint test build typecheck
```
Un projet seul : `npx nx test i18n`, `npx nx lint chantier-back-office`, etc. Le parcours Playwright (`chantier-back-office-e2e`) se lance avec `npx nx e2e chantier-back-office-e2e` après `npx playwright install`.

## Client d'API généré (ADR 0006)
```powershell
npm run generate:api    # docs/api/openapi.json -> libs/api-core/src/generated/chantierApi.ts
```
- Le fichier généré est **commité et jamais modifié à la main** ; la CI régénère puis fait `git diff --exit-code libs/api-core/src/generated`.
- Réglages : `libs/api-core/openapi-config.ts` (`@rtk-query/codegen-openapi`, hooks et hooks « lazy »). Les noms de hooks viennent des `operationId` (`Sites_List` -> `useSitesListQuery`).
- Étiquettes de cache : `libs/api-core/src/lib/enhancedApi.ts` (une mutation en échec n'invalide rien).
- Toute erreur est normalisée en `ApiError` (`status`, `code`, `errors`, `traceId`) ; `useApiErrorMessage` la traduit depuis le `code`.

## Structure
| Dossier | Contenu |
|---|---|
| `apps/chantier-back-office` | Application Vite (port 3600) : `src/{app,features,shared}` |
| `apps/chantier-back-office-e2e` | Playwright |
| `libs/api-core` | `ApplicationApiService` (RTK Query), activité réseau, étiquettes de cache |
| `libs/authentication` | Session (`AuthProvider`, gardes), permissions, connexion, changement de mot de passe, déconnexion |
| `libs/state-store` | Magasin Redux, hooks typés, tranche `authentication` |
| `libs/user-interface` | Chargement, vide, erreur, confirmation, ErrorBoundary, notifications, erreurs de formulaire |
| `libs/testing` | Tests seulement : faux serveur MSW, données fictives « École UV18 » |
| `libs/i18n` | i18next FR/AR, direction, formateurs (date, montant DZD, cote), `<Ltr>`, `LanguageSwitcher` |

## Règles
- Aucun texte en dur dans le JSX (règle ESLint `react/jsx-no-literals`) : clés dans `libs/i18n/src/locales/{fr,ar}/*.json`. Un test échoue si les clés FR et AR diffèrent.
- Propriétés CSS logiques (`margin-inline-start`, `inset-inline-end`…), jamais `left` / `right`.
- Codes, dates, montants et cotes : `<Ltr>` ou les formateurs de `@chantier-frontend/i18n`. Le client n'effectue aucun calcul métier.
- Les alias `@chantier-frontend/*` pointent vers les sources (`tsconfig.base.json`).
