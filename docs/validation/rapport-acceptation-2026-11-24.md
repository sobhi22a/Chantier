# Rapport d'acceptation — 2026-11-24

- **Périmètre** : mise en place de l'agent `validateur-demandes` et des autorisations automatiques de `.claude/settings.json`
- **Décideur** : utilisateur (demande du 24/11/2026)
- **Source** : `D:\projects\Chantier\.claude\settings.json`, `D:\projects\Chantier\.claude\agents\validateur-demandes.md`

## Demandes métier (DEM, suppressions, commandes)
| Reçues | Acceptées | Refusées | À compléter |
|---|---|---|---|
| 0 | 0 | 0 | 0 |

Aucune demande n'existe encore : le module « demandes et livraisons » n'est pas codé (socle seulement). `docs/validation/en-attente.md` est vide ; l'agent le lira dès qu'il contiendra des lignes, ou lira l'API une fois le module livré.

## Autorisations acceptées automatiquement (sans demande)
| Catégorie | Acceptées |
|---|---|
| Build et tests | `dotnet restore/build/test/format/clean/run`, `flutter pub/analyze/test/build/clean`, `dart format`, `build_runner`, `npm run/test/ci/install`, `npx nx`, `docker compose` |
| Base de données | `dotnet ef migrations *` (création de migration) |
| Git (lecture et indexation) | `status`, `diff`, `log`, `add` |
| Script local | `scripts/dev.ps1` |
| Suppressions | uniquement des dossiers **générés** : `chantier-frontend/node_modules`, `dist`, `.nx`, `coverage` ; `chantier-mobile/build`, `.dart_tool` ; `chantier-backend/TestResults` ; `.dev` |

## Autorisations qui restent soumises à ton accord
| Commande | Pourquoi |
|---|---|
| `git push`, `git commit`, `git reset`, `git clean` | irréversible ou sort du poste ; le commit « Socle technique » attend ton accord |
| `dotnet ef database *` | modifie la base |
| Toute suppression hors des dossiers générés ci-dessus | risque de perdre du code ou des documents |

## Refusées (inchangé)
- Lecture de `.env`, `.env.*`, `key.properties`, `*.jks`, `*.keystore` : secrets.

## Points d'attention
- Un agent ne peut pas répondre à une demande d'autorisation à ta place : seule la liste blanche de `settings.json` la supprime. Elle s'applique après redémarrage de la session.
- Je n'ai pas mis « tout accepter » : une suppression accidentelle de sources ou une poussée vers un dépôt distant ne se rattrape pas.
- Les suppressions métier restent logiques (archivage tracé) ; l'agent ne fait jamais de suppression physique.
