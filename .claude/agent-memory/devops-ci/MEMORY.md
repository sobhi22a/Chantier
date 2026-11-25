## Conventions
- Compose dev : `docker-compose.dev.yml` à la racine, service `db` (conteneur `chantier-dev-db`), SQL Server 2022, port hôte 14335, mot de passe via `.env` (`MSSQL_SA_PASSWORD`, obligatoire, jamais en dur).
- `global.json` vit dans `chantier-backend/` (ADR 0001), SDK 10.0.100 + rollForward latestFeature.
- Les dossiers `chantier-*` sont créés par leurs agents (Nx et `flutter create` veulent un dossier vide/absent) : ne pas y mettre de `.gitkeep`.
- Scripts de CI dans `scripts/ci/` : `.ps1` en ASCII sans BOM (Windows PowerShell 5.1 + pwsh), `.sh` appelé par `bash` (pas de bit exécutable sous Windows). Procédure et durées : `docs/exploitation/ci.md`.

## Chemins clés
- `scripts/dev.ps1` (-Down, -Reset) ; D2 le complète. `.env` généré avec mot de passe aléatoire, jamais affiché.
- Secrets : `.env` (ignoré, lecture interdite aux agents), `ConnectionStrings__ChantierDb`, `JwtSettings__Key` en CI (générée par exécution, jamais stockée).
- `azure-pipelines.yml` (jobs `paquets_interdits`, `backend`, `web`, `mobile`) ; `scripts/ci/check-banned-packages.ps1` (+ `banned-packages.allow`, exception = ligne avec `# ADR NNNN`) ; `scripts/ci/check-generated-drift.sh [--optional]` (voit aussi les fichiers non suivis).
- Contrat, client web (`generate:api`) et client mobile (swagger_parser -> build_runner -> `dart format lib`) : contrôles actifs sans `--optional` (B6, W3, M4 faits). Rejoué en local : aucun écart (hachages, pas de commit).
- `scripts/dev.ps1` (D2) : `-Api -Web -All -Mobile -Phone -Status -Down -Reset` ; état dans `.dev/` (ignoré) ; doc `docs/exploitation/demarrage-local.md`. API testée : conducteur.dev 2 sites, chef.dev 1, nonaffecte.dev 0.

## Commandes qui marchent
- `docker compose -f docker-compose.dev.yml config` exige `MSSQL_SA_PASSWORD` (échec voulu sinon).
- `dotnet --version` → 10.0.301 sur le poste (SDK 5, 9 et 10 installés ; global.json choisit le 10).
- Backend local : `dotnet build -c Release -warnaserror` OK ; tests 137 unitaires + 269 intégration (Testcontainers, ~62 s) ; `dotnet format --verify-no-changes` ~12 s.
- Web : `npm ci` dans une COPIE du dossier (le `node_modules` du dépôt est verrouillé par EPERM quand un outil l'utilise) ; `nx run-many -t lint test build typecheck` ~25 s.
- Mobile local : `flutter analyze` ~48 s, `flutter test` ~13 s, `dart run drift_dev schema dump/generate` sans écart, `dart format --set-exit-if-changed lib test` OK.

## Pièges connus
- Job `e2e` : le `webServer` Playwright lance `nx preview` qui rebuild le web ; sans `VITE_BACKEND_API_BASE_URL` la page affiche « Réseau indisponible » (8 tests en échec). Le cache Nx ignore cette variable (`NX_SKIP_NX_CACHE=true` en local). API et tests dans la même étape CI.
- Un processus API lancé par `dev.ps1` depuis une commande d'outil meurt à la fin de l'appel : tester API + client dans le MÊME appel.
- Le build `web-build` de la CI n'a pas `VITE_BACKEND_API_BASE_URL` : non déployable tel quel (voir `docs/exploitation/proxy-et-production.md`).
- PowerShell : variables insensibles à la casse, `$status` écrase le paramètre `[switch]$Status` ; les enfants lancés par Start-Process gardent ouvert le tube de sortie du script (un `| Select` attend la fin des enfants).
- Pas d'`adb` ni d'émulateur sur le poste : lancement mobile jamais testé.
- Premier `docker pull` de l'image mssql : ~1,5 Go, plus de 3 min ; le script dépasse le délai d'un appel foreground.
- Healthcheck : `mssql-tools18` demande `-C` (certificat auto-signé) ; `$$` pour échapper dans compose.
- Azure YAML : un scalaire non quoté contenant `: ` casse l'analyse (ex. `displayName`) ; valider avec `python -c "yaml.safe_load"`.
- `$PSScriptRoot` dans les valeurs par défaut de `param()` est vide en PS 5.1 : calculer dans le corps. `'\\'` écrit par Python dans un script PowerShell devient une chaîne vide : utiliser `[char]92`.
- `dotnet list package --vulnerable` sort 0 même s'il trouve des paquets : analyser la sortie (`DOTNET_CLI_UI_LANGUAGE=en`, gravité High/Critical).
- Tests web `i18n` et mobile `error_messages_test` lisent `docs/api/codes-erreur.md` : un nouveau code backend non traduit FR+AR rend la CI rouge (cas vu : `MOT_DE_PASSE_A_CHANGER`, 2026-11-24).
- Pas encore de commit ni de remote : `git diff` ne peut pas être testé sur le dépôt réel (script testé dans un dépôt temporaire).

## Décisions (lien ADR)
- Production = VPS Hostinger derrière proxy inverse, domaine unique (web + `/api/`), CORS inutile ; réglages réels de l'API : `ForwardedHeaders__{Enabled,KnownProxies__n,KnownNetworks__n,ForwardLimit}`, `DataProtection__{CertificatePath,CertificatePassword,AllowUnencryptedKeys}`, `Bootstrap__Admin*`. Docs : `proxy-et-production.md`, `signature-android.md` (aucune clé générée). `docker-compose.dev.yml` publie la base sur 127.0.0.1 (R1-18).
- Job CI `e2e` non bloquant (continueOnError) jusqu'à 5 exécutions stables.
- SQL Server 2022 conteneur (ADR 0003) ; CI Azure Pipelines (ADR 0010), D1 faite (jamais exécutée sur Azure), durées d'agent à consigner dans `docs/exploitation/ci.md`.
- Job `paquets_interdits` séparé (rapide, échoue en premier) plus rescan des transitifs .NET dans `backend` ; `dart format` ajouté au job mobile (hors liste ADR 0010, commande du README mobile).
