# ADR 0007 : Web : routeur, état, formulaires, UI et internationalisation FR/AR (RTL)

**Date :** 2026-11-24 · **Statut :** Acceptée · **Auteur :** architecte-chantier

## Contexte
Le back-office sert le conducteur de travaux, les achats, la direction et l'administration. Kardinal fournit une base complète : Nx, React 19, Redux Toolkit + RTK Query,
Mantine 8, react-hook-form + Zod 4, react-router-dom 7 (`docs/architecture/reference-kardinal.md`, §3). Manques de Kardinal : aucune i18n, aucun test, types d'API écrits à la main.
Règle 7 : interface en français **et** en arabe (RTL).

## Options étudiées
| Sujet | Option retenue | Alternatives écartées |
|---|---|---|
| Espace de travail | **Nx 21 + npm workspaces** (comme Kardinal) | Vite seul (perd les bibliothèques partagées et les graphes de dépendances) |
| Routeur | **react-router-dom 7**, `createBrowserRouter` (comme Kardinal) | TanStack Router (rupture sans gain décisif) |
| État serveur | **RTK Query** (comme Kardinal), endpoints générés (ADR 0006) | TanStack Query (second système de cache à côté de Redux) |
| État client | **Redux Toolkit** minimal : `authentication`, `networkActivity`, `ui` | Zustand (une bibliothèque de plus) |
| Formulaires | **react-hook-form** + **Zod 4** via `@hookform/resolvers/zod` | Mantine `useForm` (Kardinal n'en utilise pas), Formik |
| UI | **Mantine 8** + `@mantine/dates` + `@tabler/icons-react` (comme Kardinal) | MUI, shadcn/ui (rupture) |
| i18n | **i18next + react-i18next** (bibliothèque `libs/i18n`) | `react-intl` (messages ICU lourds pour ce besoin), solution maison |
| Tests | **Vitest 3 + Testing Library + MSW 2**, Playwright pour un parcours de bout en bout | Jest (rupture avec Vite) |

## Décision
Imiter Kardinal pour tout sauf l'internationalisation, les tests et les types d'API.

**Structure** (`chantier-frontend/`) :
```
apps/chantier-back-office/        src/{app,features,shared}  (même découpage que Kardinal)
apps/chantier-back-office-e2e/    Playwright
libs/api-core/                    ApplicationApiService, baseQuery (Problem Details), code généré
libs/authentication/              AuthProvider, PermissionsGuard, pages de connexion
libs/state-store/                 store Redux, hooks typés (useAppChantierSelector / Dispatch)
libs/user-interface/              composants génériques, useNotifications, ErrorBoundary
libs/i18n/                        configuration i18next, ressources fr/ar, hook useDirection
```
Alias `@chantier-frontend/<lib>` (`tsconfig.base.json` et alias Vite, comme Kardinal). Une fonctionnalité = `components/ containers/ sections/ services/ types/` (inchangé).
Ports de développement : web **3600**, API **8195** (pour cohabiter avec Kardinal sur 3500/8095). Variable `VITE_BACKEND_API_BASE_URL`.

**Routes.** `/sign-in`, `/` (redirection vers la première route autorisée), `/sites`, `/sites/:siteId`, `/unauthorized`. Garde `PermissionsGuard resourceKey="Sites"` (mêmes composants que Kardinal).
Les permissions viennent de `GET /api/v1/auth/me` (liste `Ressource.Action`) et sont rangées au format Kardinal `{ [ressource]: { View, Create, Update, Delete } }`.

**Formulaires.** Schéma Zod par formulaire (`types/*.zod.ts`), `z.infer` pour le type, messages d'erreur traduits par clé. Le serveur reste juge : les erreurs 400/422 (`errors` par champ, `code`) sont rattachées aux champs.

**Erreurs.** La `baseQuery` normalise toute erreur en `ApiError { status, code, title, detail, errors, traceId }`. Le hook `useApiErrorMessage` traduit `errors:<CODE>` ; code inconnu → message générique + `traceId` affiché pour le support.

**i18n et RTL.**
- Langues `fr` (par défaut) et `ar` ; choix mémorisé (`localStorage: chantier.lang`) ; sélecteur dans l'en-tête.
- Ressources : `libs/i18n/src/locales/<lng>/<espace>.json` (`common`, `auth`, `sites`, `errors`) ; clés `espace:section.element`. **Aucun texte en dur** : règle ESLint `react/jsx-no-literals`.
- Un test unitaire échoue si les clés de `fr` et `ar` diffèrent ou si une valeur est vide.
- Direction : `DirectionProvider` de Mantine alimenté par la langue ; `<html lang dir>` synchronisé ; styles en **propriétés logiques** (`margin-inline-start`, `inset-inline-end`, `text-align: start`) ; les flèches directionnelles s'inversent (`.rtl-flip`).
- Chiffres latins 0 à 9 dans les deux langues (H-10) : `Intl` avec `ar-DZ-u-nu-latn` ; dayjs `ar-dz` ; fuseau d'affichage `Africa/Algiers` ; dates métier `2026-11-24` affichées `24/11/2026` ; heures sur 24 h ; virgule décimale, séparateur de milliers en espace ; montants `185 000 000,00 DZD`.
- **Sens de lecture** : en arabe, codes (`CH-ECO-UV18`), dates, montants et cotes restent de **gauche à droite** : composant `<Ltr>` (`<bdi dir="ltr">`) obligatoire pour ces valeurs ; tests de rendu en arabe.
- Le nom du chantier s'affiche en arabe s'il existe (`nameAr`), sinon en français (H-20). La langue de l'utilisateur vient de `GET /auth/me` (`language`) et se mémorise par `PUT /auth/me/language`.
- Police Cairo (arabe + latin) **hébergée localement** (`@fontsource/cairo`), pas de CDN.

**Qualité.** `npm ci` sans `--legacy-peer-deps` visé (chaque conflit à documenter) ; TypeScript `strict` (config de Kardinal) ; React 19.x en plage de correctifs.

## Conséquences
- Plus facile : un développeur de Kardinal retrouve ses repères ; types et hooks d'API automatiques ; bascule FR/AR vérifiée par tests.
- Plus difficile : tout écran doit avoir ses deux traductions et être contrôlé en RTL ; les composants Mantine tiers (dates) demandent une vérification RTL.
- À surveiller : poids du bundle (Mantine + dates) ; conflits de pairs React 19 ; qualité des traductions arabes (relecture par un locuteur du métier avant livraison).
