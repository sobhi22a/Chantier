# Projet : gestion de chantier BTP

Application de suivi de chantier (écoles, logements, équipements publics, Algérie) pour chefs de chantier,
chefs d'équipe, conducteurs de travaux, achats et direction.
Usage principal : **téléphone, sur le terrain, réseau faible ou absent, en plein soleil, parfois avec des gants**.

## Stack
| Partie | Technologie | Utilisateurs |
|---|---|---|
| Backend | .NET 10 LTS : ASP.NET Core, EF Core 10, C# 14 | API REST, règles métier, calculs, synchronisation |
| Web | React 19.x + TypeScript | Back-office : conducteur de travaux, achats, direction, administration |
| Mobile | Flutter (Dart 3) | Saisie terrain hors ligne : chef de chantier, chefs d'équipe |

- Versions exactes : lire `global.json`, `*.csproj`, `Directory.*.props`, `package.json`, `pubspec.yaml`. Ne jamais supposer.
- Rester sur .NET 10 (LTS, supporté jusqu'en novembre 2028). Aucune montée de version majeure (.NET, React, Flutter)
  ni nouvelle bibliothèque structurante sans ADR validé (`docs/adr/`).

## Règle n°1 : l'existant d'abord
Le projet existe déjà. Avant d'écrire : lire la structure, puis 2 ou 3 fichiers du même type que celui à créer,
et **imiter les conventions en place** (architecture, nommage, langue du code, bibliothèques, style de tests).
Aucune réorganisation, aucun renommage massif, aucune réécriture « parce que c'est mieux » sans ADR.

## Le métier en une phrase
« Ce qui n'est pas écrit n'existe pas » : chaque besoin, tâche, problème, livraison ou décision devient
**une ligne numérotée, datée, avec un responsable, une unité et un statut**.

## Règles métier non négociables (détails et exemples : skill `metier-chantier`)
1. **Unité obligatoire** sur toute quantité ; jamais d'addition d'unités différentes (m² + ml interdit).
2. **Date complète obligatoire** : refuser « ../08/2026 ».
3. **Calculs côté serveur** en `decimal` (métrés, montants, totaux, avancement) ; le client affiche, il ne fait pas foi.
4. **Montants en DZD**, 2 décimales, arrondi au centime « loin de zéro » (`MidpointRounding.AwayFromZero`).
5. **Numérotation par chantier** : DEM-001, LIV-001, T-001, PB-001, SIT-001 ; unique, générée par le serveur.
6. **Hors ligne d'abord** : toute création mobile porte un `clientId` (GUID) ; le serveur est idempotent.
7. **Interface français + arabe (RTL)** ; une saisie terrain prend moins de 30 secondes.
8. **Données personnelles** (téléphones, évaluations des ouvriers) : visibles seulement par les rôles autorisés, jamais dans les logs.
9. **Traçabilité** : qui a créé, modifié, validé, et quand.

## Rôles
Admin · Direction (lecture, rapports) · ConducteurTravaux (valide demandes et situations) · Achats (commandes, livraisons)
· ChefChantier (saisit tout sur ses chantiers) · ChefEquipe (signale besoins et problèmes, photos).
Un utilisateur ne voit que les chantiers auxquels il est affecté.

## Équipe d'agents
| Agent | Quand l'utiliser |
|---|---|
| `architecte-chantier` | État des lieux, conception, contrat d'API, plan, ADR |
| `expert-metier-chantier` | User stories, règles de calcul, critères d'acceptation, validation terrain |
| `backend-dotnet` | API .NET 10, EF Core, sécurité, synchronisation |
| `frontend-react` | Back-office web |
| `mobile-flutter` | Application terrain hors ligne |
| `qa-tests` | Tests et vérification des critères d'acceptation |
| `revue-securite-perf` | Revue sécurité et performance (ne modifie pas le code) |
| `devops-ci` | Build, CI/CD, Docker, environnements, sauvegardes |

Chaîne standard (`/fonctionnalite <nom>`) : expert-metier → architecte → backend → frontend ∥ mobile
→ qa-tests ∥ revue-securite-perf → corrections → validation métier.
Connaissances partagées : skills `metier-chantier`, `contrat-api`, `qualite-passation` (préchargés dans les agents).

## Où sont les choses
| Dossier | Contenu | Auteur |
|---|---|---|
| `docs/metier/` | User stories et critères d'acceptation | expert-metier-chantier |
| `docs/architecture/` | État des lieux, vues d'ensemble | architecte-chantier |
| `docs/plans/` | Plans de fonctionnalité | architecte-chantier |
| `docs/adr/` | Décisions d'architecture | architecte-chantier |
| `docs/api/` (ou fichier OpenAPI existant) | Contrat d'API | architecte → backend |
| `docs/qa/` | Rapports QA | qa-tests |
| `docs/revues/` | Rapports sécurité et performance | revue-securite-perf |
| `.claude/agent-memory/<agent>/` | Mémoire persistante de chaque agent | chaque agent |

## Commandes
`/etat-des-lieux` (une fois) · `/socle` (une fois, sur le projet initial) · `/fonctionnalite <nom>` · `/revue [périmètre]`

Les agents sont lancés un par un ou en parallèle, et l'orchestrateur **attend leur rapport** avant l'étape suivante
(`.claude/settings.json` désactive le mode « fork » pour permettre cette attente).
