# Mémoire frontend-react

## Conventions
- Nx 21.6.11 + npm workspaces, React ~19.3, Mantine 8, i18next 27 / react-i18next 18, Vite 7, Vitest 3 ; `npm ci` / `npm install` passent SANS `--legacy-peer-deps`.
- Alias `@chantier-frontend/*` dans `tsconfig.base.json`, résolus dans Vite par `nxViteTsPaths()` (pas d'alias écrits à la main).
- ESLint partagé : `chantier-frontend/eslint.react.mjs` (jsx-no-literals sur .tsx hors tests, exhaustive-deps actif) ; chaque projet fait `export default [...reactConfig]`.
- i18n : langue = source unique i18next ; `createI18n(lng,{persist,syncDocument})` pour les tests ; `renderWithI18n` (libs/i18n/src/testing) et `renderWithProviders` (user-interface) ; formateurs `{{x, ltr}}` et `{{x, isolate}}` dans les JSON arabes.
- Formateurs : `fr-DZ-u-nu-latn` + normalisation (NBSP milliers, virgule, vrai signe moins U+2212) ; même rendu FR et AR.

## Chemins clés
- Client d'API : `libs/api-core/openapi-config.ts` + `src/generated/chantierApi.ts` (généré) + `src/lib/enhancedApi.ts` (tags) ; `npm run generate:api`.
- Écrans : `apps/chantier-back-office/src/features/sites/{components,containers,sections,types}` ; routes `src/app/providers/router/routers.tsx` (pages en `lazy`).
- Tests : `libs/testing` (MSW + fixtures), `apps/chantier-back-office/src/testing/renderApp.tsx` (`mockSession`, `renderApp(path, lang)`).
- `chantier-frontend/libs/i18n/src` (languages, i18n, formatters, zoneLabelParts, Ltr, ZoneLabel, LanguageSwitcher, LanguageDirectionProvider, locales/).
- `chantier-frontend/apps/chantier-back-office/src/app/providers/AppProviders.tsx` (Redux > i18n > direction > Mantine > dates > notifications > ErrorBoundary).

## Commandes qui marchent
- Essai réel : API `ASPNETCORE_ENVIRONMENT=Development Seed__Demo=true dotnet run --no-build --no-launch-profile --urls http://localhost:8195` (chaîne SQL via `.env`, voir mémoire backend) ; fetch avec cookie jar dans un test jetable ; arrêter ensuite le processus `Chantier.WebApi`.
- `cd chantier-frontend && npm run verify` (= `nx run-many -t lint test build typecheck`) ; dev : `npx nx serve chantier-back-office` (3600, strictPort).

## Pièges connus
- RTK Query : un NOUVEL abonné à une requête en erreur la relance ; `isLoading` redevient vrai sans donnée. Ne jamais démonter les enfants sur `isLoading` d'une requête dont les enfants s'abonnent aussi (boucle sur `GET /auth/me` 401) : les gardes lisent la tranche Redux.
- RTK Query invalide aussi après une mutation en échec : `invalidatesTags` doit renvoyer `[]` sur erreur (`onSuccess` dans enhancedApi).
- Langue du compte appliquée UNE fois par session (ref par userId), sinon la relecture de `/auth/me` écrase le choix local.
- `i18n.t` (instance) lit la langue à l'appel ; le `t` de `useTranslation` est figé au rendu (erreurs/notifications après un changement de langue).
- Zod 4 : `z.number().int()` dans une union devient un message d'union ; utiliser `.refine(Number.isInteger, clé)`.
- Tests Mantine : `MantineProvider env="test"` (AppProviders `mantineEnv`) ; libellés « Nom * » (regex `^Nom \*?$`) ; Select/Autocomplete dupliquent le libellé (`getAllByLabelText()[0]`).
- Heredocs ET scripts python via bash : les `
` dans une chaîne source sont convertis ; utiliser Edit/Write pour tout code contenant des `
` ou apostrophes.
- Heredocs bash avec apostrophes françaises dans le contenu : la commande échoue sans rien écrire (EOF) ; utiliser l'outil Write.
- Espace insécable / signes Unicode littéraux dans le code : ESLint `no-irregular-whitespace` ; utiliser ` `, `−`, `⁦`.
- ESLint doit ignorer `**/build` et `**/out-tsc` (sinon il lint les sorties générées).
- `nx sync` réécrit `tsconfig.base.json` (mise en forme multi-lignes) ; éditer par motif, pas par chaîne exacte.
- Helpers de test exportés : annoter le type de retour (TS2742 avec `@testing-library/dom/node_modules/pretty-format`).
- `signDisplay: "negative"` exige `lib: es2023`.
- Écrire `chantier-frontend/.env.development` est refusé par une règle de permission : repli en dur dans `apps/chantier-back-office/vite.config.ts` (mode development seulement) + `.env.example`.
- Arabe : pluriel i18next à 6 formes (`_zero,_one,_two,_few,_many,_other`) ; Mantine `DirectionProvider` doit être synchronisé par `LanguageDirectionProvider`.

- Fiche volumineuse : `ZonesByBlock` replie les blocs au-delà de 150 zones et affiche 100 zones par tranche ; 5 000 zones = 286 nœuds DOM (avant : 105 k).
- Valeurs par défaut d'un formulaire de création issues du serveur : attendre `fulfilledTimeStamp >= ouverture` (le cache peut être périmé), sinon `defaultValues` figés avec une valeur ancienne.
- Tests de 5 000 zones : `findBy*` avec `{ timeout: 20000 }` et `vi.setConfig({ testTimeout: 30000 })`.

## Décisions (lien ADR)
- ADR 0007 (web/i18n/RTL), ADR 0006 (client généré : W3, après B6).
