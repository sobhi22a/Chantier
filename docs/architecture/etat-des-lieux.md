# État des lieux : Chantier

**Auteur :** architecte-chantier · **Date :** 2026-11-24 · **Portée :** dépôt `d:\projects\Chantier`

## 1. Carte du dépôt
Le dépôt est **vide** : aucun projet .NET, React ou Flutter, aucun script, aucune CI. Contenu réel :

| Élément | Rôle |
|---|---|
| `CLAUDE.md`, `LISEZMOI.md` | Contexte du projet et mode d'emploi des agents |
| `.claude/` | 8 agents, 7 skills, `settings.json` (autorisations `dotnet`, `flutter`, `npm run`) |
| `.gitignore` | `bin/ obj/ node_modules/ build/ .dart_tool/ .env *.user .claude/settings.local.json` |
| `.git` | Initialisé, sans commit applicatif |
| `docs/` | Créé par ce passage : `architecture/`, `plans/`, `adr/`, `api/` |

## 2. Outils installés sur le poste (vérifiés)

| Outil | Version | Commentaire |
|---|---|---|
| SDK .NET | **10.0.301** (aussi 9.0.316, 9.0.203, 5.0.408) | Épingler le 10 dans `global.json` |
| `dotnet-ef` (global) | 10.0.11 | Conforme à EF Core 10 |
| Node.js / npm | 22.13.1 / 11.3.0 | |
| Flutter | 3.35.7 (Dart 3.9.x), canal stable | Dépôt Flutter vieux d'un an : mise à jour à décider (voir risques) |
| Docker | 29.2.1 | Sert à la base de données en local et aux tests d'intégration |
| SQL Server | `MSSQLLocalDB` disponible, `sqlcmd` présent | Option de repli sans Docker |
| PostgreSQL (`psql`) | absent | |
| Git | 2.54.0 | |
| Locale du poste | `fr-DZ` | Cohérent avec un usage en Algérie |

`flutter doctor` : toolchain Android **non prête** (licences non acceptées, Android Studio absent) ; chaîne Windows C++ incomplète
(sans importance : on ne cible pas Windows). Action utilisateur avant le premier build APK : `flutter doctor --android-licenses`.

## 3. Ligne de base (build et tests)
Aucune application n'existe : **rien à compiler ni à tester**. Les commandes de référence seront figées par `devops-ci` (plan `socle`, tâche D1).

## 4. Ce qui est à créer

| Partie | Dossier | Contenu minimal du socle |
|---|---|---|
| Backend | `chantier-backend/` | Solution .NET 10 en 3 couches + tests unitaires et d'intégration, première migration, authentification, modules `Sites` et `Sync` |
| Web | `chantier-frontend/` | Espace de travail Nx, application `chantier-back-office`, 5 bibliothèques, i18n FR/AR |
| Mobile | `chantier-mobile/` | Application Flutter Android, base locale Drift, file d'envoi, moteur de synchronisation |
| Contrat | `docs/api/openapi.json` (généré) | OpenAPI 3.1 versionné ; `docs/api/socle.md` décrit les endpoints avant l'écriture du backend |
| CI | `azure-pipelines.yml` (racine) | Trois jobs + contrôle du contrat |
| Exploitation | `docker-compose.dev.yml`, `docs/exploitation/demarrage-local.md` | Base locale, démarrage de bout en bout |

## 5. Écarts avec le modèle de domaine (`metier-chantier`)
Aucune entité n'existe. Le socle ne crée que : `Site`, `Zone`, `SiteMember` (affectation), `SiteCounter` (numérotation par chantier, fondation), `Wilaya` et `Commune` (référentiel), `AppUser`, `AppRole`, `RefreshToken`.
Les 14 autres entités du référentiel (`Worker`, `Request`, `Delivery`, `WorkTask`, `ConcretePour`, `Issue`, `SubcontractorStatement`, …)
sont **manquantes** et arrivent par fonctionnalités (`/fonctionnalite`).

## 6. Dette technique et risques déjà identifiés

| Sévérité | Risque | Parade |
|---|---|---|
| Majeur | Toolchain Android non prête : aucun APK ne se compile | Action utilisateur : accepter les licences (Android Studio non obligatoire si les outils en ligne de commande suffisent) |
| Majeur | Flutter 3.35.7 date d'octobre 2025 : paquets récents pourraient exiger un Dart plus récent | Figer les versions compatibles à la création ; ne pas monter Flutter sans ADR (règle du projet) |
| Mineur | Aucune base de données installée en dehors de LocalDB et de Docker | `docker-compose.dev.yml` (SQL Server 2022) ; LocalDB en repli |
| Mineur | Plateforme du dépôt distant inconnue (Azure DevOps, GitHub…) | Pipeline en Azure Pipelines par imitation de Kardinal ; commandes portables (ADR 0010) |

## 7. Bibliothèques à risque
Voir `docs/architecture/reference-kardinal.md` : à éviter dès le départ : AutoMapper et MediatR (licence commerciale), FluentAssertions 8+ (idem),
MassTransit 9 (idem), Six Labors ImageSharp (licence partagée, usage commercial payant), Isar et Hive (maintenance incertaine), Moq conservé en 4.20.72.

## 8. Plan et questions
- Plan priorisé : `docs/plans/socle.md` (lot 0), puis lots proposés en fin de plan.
- Décisions : `docs/adr/0001` à `0010`.
- Hypothèses prises sans consulter l'utilisateur (à confirmer au fil de l'eau) : section « Hypothèses » de `docs/plans/socle.md`.
