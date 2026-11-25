# Équipe d'agents experts : gestion de chantier (v2.1)

## Nouveautés de la v2.1
- **`/socle`** : construit le socle technique à partir du projet initial. Il livre un premier parcours « Mes chantiers »
  qui marche de bout en bout : connexion, API, web, mobile hors ligne, traductions FR/AR et CI.
- **`.claude/settings.json`** :
  - l'orchestrateur attend le rapport de chaque agent avant l'étape suivante (le mode « fork » est désactivé) ;
  - les commandes de build et de test (`dotnet`, `flutter`, `dart`, `npm run`) passent sans demander ;
  - `git push` et `dotnet ef database …` demandent toujours votre accord ;
  - les fichiers `.env` et les clés de signature Android ne peuvent pas être lus.
- **`/fonctionnalite` et `/revue`** attendent explicitement les rapports. `/fonctionnalite` reprend là où elle s'était arrêtée.

## Ce que contient la v2
- **8 agents.** Chacun suit une méthode d'expert, vérifie lui-même son travail et applique des standards précis
  pour .NET 10 / EF Core 10, React 19 ou Flutter hors ligne. Tous partagent une définition de « terminé » et un format de rapport.
- **Une mémoire persistante par agent** (`memory: project`, dans `.claude/agent-memory/<agent>/`).
- **Des connaissances partagées** sous forme de skills préchargés : `metier-chantier`, `contrat-api` et `qualite-passation`.
- **Le bon modèle pour chaque rôle** : Opus pour l'architecture, le métier et la sécurité ; Sonnet pour le développement, la QA et le DevOps.

```
CLAUDE.md                         contexte court, chargé par tous
.claude/settings.json             attente des agents, permissions, protection des secrets
.claude/agents/                   architecte-chantier, expert-metier-chantier, backend-dotnet, frontend-react,
                                  mobile-flutter, qa-tests, revue-securite-perf, devops-ci
.claude/skills/
  metier-chantier/                domaine, calculs vérifiés, glossaire terrain, données de test
  contrat-api/                    conventions d'API et de synchronisation
  qualite-passation/              méthode commune + modeles/ (user story, plan, ADR, rapports)
  etat-des-lieux/  socle/  fonctionnalite/  revue/      les 4 commandes
```

## Démarrage rapide (à partir du projet initial)

### 1. Prérequis sur le PC
- **Claude Code**, avec un abonnement Pro, Max, Team ou Enterprise (ou un compte Console).
  - Windows (PowerShell) : `irm https://claude.ai/install.ps1 | iex`
  - Ou l'application de bureau Claude, onglet **Code**.
- **Git for Windows** (recommandé : il fournit Git Bash, utilisé par les agents).
- **SDK .NET 10**, **Node.js LTS**, **Flutter** (avec Android Studio et le SDK Android).
- Une base de données de développement (celle que l'architecte retiendra, ou Docker).
- Vérifier : `claude --version`, `dotnet --version`, `node --version`, `flutter doctor`, `git --version`.

### 2. Installer les agents dans le projet
1. Décompresser l'archive à la **racine du projet** : le dossier qui contient (ou contiendra) les applications backend, web et mobile.
2. Si un `CLAUDE.md` existe déjà, ajouter ce contenu à la suite au lieu de le remplacer.
3. Mettre le projet sous git **avant** que les agents ne modifient quoi que ce soit :
   ```
   git init
   dotnet new gitignore
   git add .
   git commit -m "Projet initial + agents"
   ```

### 3. Lancer Claude Code à la racine
- Terminal : se placer dans le dossier racine (`cd C:\chemin\du\projet`), puis taper `claude`.
- Ou application de bureau : onglet **Code**, environnement **Local**, **Open folder…**, choisir la racine.
- Au premier lancement, accepter de faire confiance au dossier. Sans cela, les autorisations et le réglage d'attente
  des agents de `.claude/settings.json` ne s'appliquent pas. Si vous venez de le faire, quittez (`/exit`) et relancez `claude` une fois.

### 4. Vérifier que tout est chargé
- `/status` : la ligne « Setting sources » doit mentionner les réglages du projet.
- Taper `/` : les commandes `/etat-des-lieux`, `/socle`, `/fonctionnalite` et `/revue` apparaissent.
- Demander « Liste les agents disponibles dans ce projet » : les 8 agents doivent être cités.

### 5. Choisir le mode de permission
- **Accept edits** ou **Auto** : les agents travaillent sans demander à chaque fichier.
- Vous relisez ensuite les changements avec `git diff` ou la vue des différences de l'application.
- Pour changer de mode : `Shift+Tab` dans le terminal, ou le sélecteur sous la zone de saisie dans l'application.
- Jamais « Bypass permissions ».

### 6. Enchaîner les commandes
| Ordre | Commande | Ce qui se passe | Votre rôle |
|---|---|---|---|
| 1 | `/etat-des-lieux` | L'architecte analyse le projet sans le modifier, lance les builds et les tests, et écrit `docs/architecture/etat-des-lieux.md` | Lire le document, répondre aux questions |
| 2 | `/socle` | Choix techniques (ADR), puis premier parcours « Mes chantiers » de bout en bout, CI et guide de démarrage local | Valider les ADR et le plan au point de contrôle |
| 3 | `/fonctionnalite demandes de matériaux et livraisons` | Besoins → plan → backend → web et mobile → QA et revue → corrections → validation métier | Valider le plan, répondre aux questions métier |
| 4 | `/revue` | QA et revue sécurité/performance sur les changements en cours | Décider des corrections |
| 5 | `git commit` | Point de sauvegarde après chaque lot | Relire, puis valider |

Ensuite, une fonctionnalité à la fois, dans l'ordre conseillé ci-dessous.

## Bonnes pratiques pendant le travail
- **Une fonctionnalité par session.** Faire `/clear` entre deux lots : les documents (`docs/`) et la mémoire des agents gardent l'essentiel.
- **Suivre l'avancement** : `/tasks` dans le terminal ; le panneau des tâches dans l'application.
- **Revenir en arrière** : `/rewind`, ou git (`git diff`, `git restore`, `git checkout`).
- **Surveiller la consommation** : `/usage`. Si les limites sont vite atteintes, passer certains agents de `opus` à `sonnet`.
- **Reprendre** : `/resume` pour retrouver une session ; relancer `/fonctionnalite <même nom>` reprend à l'étape non terminée.
- **Ne pas lancer `/init`** : le `CLAUDE.md` du projet est déjà prêt.

## Facultatif : code intelligence
Ces plugins permettent aux agents de voir les erreurs de type juste après chaque modification.
- **C#** : `dotnet tool install --global csharp-ls` (demande le SDK .NET 10 ; `~/.dotnet/tools` doit être dans le PATH),
  puis dans Claude Code : `/plugin install csharp-lsp@claude-plugins-official`.
- **TypeScript** : `npm install -g typescript-language-server typescript`,
  puis `/plugin install typescript-lsp@claude-plugins-official`.
- **Dart / Flutter** : pas de plugin officiel ; l'agent mobile utilise `flutter analyze`.
- **Si aucun diagnostic n'apparaît** : `/plugin`, onglet **Errors**.

## Ordre conseillé des fonctionnalités (après `/socle`)
1. Intervenants, équipes et affectations détaillées.
2. Demandes et livraisons (avec photo du bon de livraison).
3. Journal du jour et pointage.
4. Tâches, coulages et photos d'avancement.
5. Problèmes et solutions, décisions.
6. Situations des sous-traitants (métrés, montants).
7. Tableaux de bord, rapport hebdomadaire, rapprochement entre ciment livré et béton coulé.

## Personnaliser
- **Modèles** : modifier `model:` dans un agent (`opus`, `sonnet`, `haiku`, `fable`, `inherit`) et `effort:` (`low` à `max`, selon le modèle).
- **Mémoire** : versionner `.claude/agent-memory/` pour la partager avec l'équipe, ou passer à `memory: local` pour la garder sur votre poste.
- **Règles métier** : les ajouter dans `.claude/skills/metier-chantier/` (par exemple un nouveau cas dans `calculs.md`), pas dans les agents.
- **Permissions** : compléter `.claude/settings.json`. Vos préférences personnelles vont dans `.claude/settings.local.json`.
- **CLAUDE.md** : le garder court. Il est lu à chaque échange, par chaque agent.

## À faire trancher par un chef de chantier
Les réponses sont à inscrire dans `metier-chantier/SKILL.md`, section « Questions ouvertes ».
- Les chiffres après les noms des ouvriers (« coff21 », « ferr 16 », « manover 18 ») : tarif, équipe ou autre ?
- « App » dans les métrés : appuis de fenêtres en ml, payés à part ?
- « Cader classe » : de quoi s'agit-il, et dans quelle unité ?
- Retenue de garantie sur les situations des sous-traitants : oui ou non, et à quel taux ?
- « retba », « lheria », « auberge » : autres chantiers ou lieux de stockage ?
