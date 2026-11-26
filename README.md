# Chantier

Suivi de chantier BTP (Algérie) : API .NET 10, back-office React, application terrain Flutter hors ligne.
Contexte et règles : `CLAUDE.md`. Plan en cours : `docs/plans/socle.md`.

## Structure
| Dossier | Contenu | Créé par |
|---|---|---|
| `chantier-backend/` | Solution .NET 10 (`global.json` déjà présent) | tâche B1 |
| `chantier-frontend/` | Espace de travail Nx, React 19 (port 3600) | tâche W1 |
| `chantier-mobile/` | Projet Flutter Android | tâche M1 |
| `docs/` | métier, architecture, plans, ADR, API, QA, revues, exploitation | agents |
| `scripts/` | scripts de développement (`dev.ps1`) | devops-ci |

Les trois dossiers d'application sont créés par leurs agents (les générateurs `create-nx-workspace` et `flutter create` veulent un dossier vide ou absent).

## Prérequis
- SDK .NET 10 (`dotnet --version` doit afficher `10.0.x`), Node.js 22, Flutter 3.35.7 (épinglé), Docker.

## Démarrer la base de développement
```powershell
.\scripts\dev.ps1          # crée .env (mot de passe aléatoire) si absent, démarre SQL Server 2022, attend « healthy »
.\scripts\dev.ps1 -Down    # arrête (données conservées)
.\scripts\dev.ps1 -Reset   # supprime aussi le volume (confirmation demandée)
```
- Base : `127.0.0.1,14335`, utilisateur `sa`, mot de passe dans `.env` (jamais committé ; modèle : `.env.example`).
- Chaîne de connexion de l'API : `ConnectionStrings__ChantierDb` en variable d'environnement ou `dotnet user-secrets` (jamais dans `appsettings*.json`), par exemple :
  `Server=127.0.0.1,14335;Database=ChantierDev;User Id=sa;Password=<.env>;TrustServerCertificate=True`
- Repli sans Docker : `MSSQLLocalDB` (`Server=(localdb)\MSSQLLocalDB;Database=ChantierDev;Trusted_Connection=True`).

## Ports
API 8195 · Web 3600 · SQL Server 14335.

## Suite
Démarrage complet (API avec données de démonstration, web, mobile) : tâche D2, `docs/exploitation/demarrage-local.md`.
