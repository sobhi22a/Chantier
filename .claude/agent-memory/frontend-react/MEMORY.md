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

- Lot matériaux (W1-W4) : `features/{catalog,materials}` ; permissions nommées `can("Requests.Approve")` (liste brute `permissions` dans la tranche auth) en plus de `can(ressource, action)` ; quantités via `QuantityText` / `useQuantityFormatter` (jamais un nombre sans unité) ; miroir de calcul BigInt `features/materials/types/quantityMirror.ts` (vecteurs lus dans `docs/api/vecteurs-materiaux.json`) ; fixtures matériaux dans `libs/testing` + `src/testing/materialsMocks.ts`.
- Liste de demandes : filtres/tri/page dans l'URL (`useRequestFilters`), lots regroupés par chantier (`groupBySite`), tiroir de détail par route `/materials/requests/:siteId/:requestId`.

- Lot matériaux tranche B (W5-W7) : `features/materials/{components,containers,types}` : commande (`OrderForm`, `OrderFormModal.container`), livraisons (`Deliveries*`, `DeliveryForm`, `DeliveryDetailDrawer`), suivi (`FollowUp.container`), routes `/materials/{to-order,deliveries,follow-up}` ; `libs/api-core/src/lib/{photoContent,zoneDirectory}.ts` (endpoints injectés : photo lue en `blob:` par la session, annuaire des zones d'un chantier, 5 pages de 200 puis repli `GET /zones/{id}`) ; tags `DELIVERIES` et `FOLLOW_UP` dans `enhancedApi.ts` ; fixtures `makeOrder/makeDelivery/makeFollowUp/makePhoto` dans `libs/testing`.
- Aucune permission de suivi dédiée : `FOLLOW_UP_PERMISSIONS` (libs/authentication) = une parmi UpdateAny, Approve, Settle, Orders.Create, Prices.View (exclut ChefEquipe) ; `PermissionsGuard anyOf`.

## Commandes qui marchent
- Essai réel : API `ASPNETCORE_ENVIRONMENT=Development Seed__Demo=true dotnet run --no-build --no-launch-profile --urls http://localhost:8195` (chaîne SQL via `.env`, voir mémoire backend) ; fetch avec cookie jar dans un test jetable ; arrêter ensuite le processus `Chantier.WebApi`.
- `cd chantier-frontend && npm run verify` (= `nx run-many -t lint test build typecheck`) ; dev : `npx nx serve chantier-back-office` (3600, strictPort).

- Playwright réel : `QA_DEMO_PASSWORD` lu par `node -e` dans `appsettings.Development.json` (jamais affiché) ; `signIn` doit attendre de quitter `/sign-in` (la page de connexion a aussi un h1) ; supprimer `test-output/` ensuite. L'API de dev est coupée quand le backend compile : relancer par `Start-Process powershell -File scripts\dev.ps1 -Api` (détaché) ; lancée depuis bash elle meurt avec l'appel.

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

- Prix/montants : afficher seulement si l'objet `commercial` est présent (jamais selon le rôle) ; une valeur déjà posée (commande, BL) se remplace sans s'effacer : n'envoyer que les champs changés et non vides (écarts 11, 19).
- Photos : jsdom n'a ni `Blob.arrayBuffer`, ni canvas, ni `createObjectURL` ; son Blob est envoyé comme texte par fetch (Node) : le corps binaire et le Content-Type du PUT ne se testent qu'avec Playwright. `FileReader` en repli pour le SHA-256.
- `getApiBaseUrl()` lève sans `VITE_BACKEND_API_BASE_URL` : pour Playwright sur `nx preview`, construire avec `VITE_BACKEND_API_BASE_URL=http://localhost:8195 npx nx build chantier-back-office` (sinon page « Une erreur est survenue ») ; l'API de dev est tuée à intervalles par la compilation du backend : relancer et lancer les tests dans le même appel PowerShell.
- `RequestsTable` : `showOrder` ajoute fournisseur et livraison prévue ; liste de livraisons = route d'un CHANTIER (pas de liste transversale) : chantier choisi d'office s'il n'y en a qu'un.
- Cache RTK : `AuthProvider` fait `resetApiState` sur TRANSITION seulement (session finie par 401, ou autre `id` de profil) ; réagir à l'état « sans profil » boucle (le reset relit `/auth/me`). `renderApp` renvoie aussi `store`.
- Photos : `useDeliveryPhotoUpload` garde `{clientId, photoId, fichier réduit}` après un échec reprenable (réseau, >= 500) ; « Réessayer l'envoi » ne refait que le PUT (ou rejoue le POST avec le même `clientId`) ; refus 4xx abandonne l'essai ; compteur de places = max(photoCount, photos listées).

## Décisions (lien ADR)
- ADR 0007 (web/i18n/RTL), ADR 0006 (client généré : W3, après B6).
- Le générateur RTK rend TOUS les champs de `MaterialRequestDetailResponse` facultatifs (héritage) : relire par `asRequestDetail()` (cast documenté).
- Magasin de notifications Mantine global : `notifications.clean()` après chaque test (setup-dom), sinon la limite de 3 masque les suivantes ; `testTimeout` 20 s et `asyncUtilTimeout` 4 s sous charge.
- `getByText` normalise les espaces du DOM (NBSP en espace) mais pas la chaîne attendue : écrire une espace simple, ou matcher fonction pour `<span><bdi>300</bdi> sacs</span>`.
- Python/Write convertissent ` ` en vrai caractère : vérifier par grep et remplacer par l'échappement via `chr(92)`.
- `PUT /requests` ne peut pas retirer une zone (écart 6 du contrat) ; après validation seuls date, urgence, remarque partent.
- `crossSiteRequestsList` sert toutes les listes web (chantier optionnel) ; une ligne de liste lit sa zone par `GET /zones/{id}` (cache RTK), à surveiller sur 50 lignes.
- `tsc -p` direct lit les `dist` périmés des libs : vérifier avec `nx run-many -t typecheck`.
