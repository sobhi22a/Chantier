---
name: socle
description: Construit le socle technique à partir du projet initial (squelette .NET 10, React, Flutter), avec un premier parcours « Mes chantiers » qui marche de bout en bout. Couvre la connexion, les rôles, l'API, la base locale et la synchronisation mobile, les traductions FR/AR et la CI. À lancer une seule fois, juste après /etat-des-lieux.
argument-hint: "[précisions facultatives, ex. base PostgreSQL, hébergement Windows]"
disable-model-invocation: true
---

# Socle technique : premier parcours de bout en bout

Tu es l'orchestrateur. Objectif : passer du projet initial à un **squelette qui marche de bout en bout**, sur lequel
chaque fonctionnalité viendra ensuite se brancher. À la fin :
- un chef de chantier se connecte et voit « Mes chantiers » sur le web et sur le mobile, même hors ligne ;
- la CI vérifie les trois applications.

Précisions de l'utilisateur (peut être vide) : $ARGUMENTS

À chaque étape :
- délègue au bon agent (outil Agent) et **attends son rapport avant de passer à la suite** ;
- transmets les **chemins** des documents, pas leur contenu.

Arrête-toi dès qu'une décision revient à l'utilisateur. Crée une liste de tâches qui reprend les étapes ci-dessous.

## Étape 0 : vérifier
- `docs/architecture/etat-des-lieux.md` doit exister. Sinon, proposer `/etat-des-lieux` et attendre.
- Si le dossier n'est pas un dépôt git, proposer `git init` et un premier commit avant toute modification.
  S'il l'est, proposer une branche `socle`.
- Si une des trois applications n'existe pas encore, l'architecte prévoit de la créer avec l'outil officiel
  (`dotnet new`, `npm create vite@latest`, `flutter create`) dans le dossier choisi.

## Étape 1 : décisions de base (`architecte-chantier`)
Demander `docs/plans/socle.md` et un ADR pour chaque choix structurant, avec ses options et sa justification :
- organisation de la solution .NET (projets, modules) et style d'endpoints ;
- base de données et fournisseur EF Core ; stockage des photos ;
- authentification (jetons, rafraîchissement, stockage côté web et mobile), rôles et affectation aux chantiers ;
- génération des clients web et mobile depuis l'OpenAPI ;
- web : routeur, état serveur, formulaires, bibliothèque d'UI, i18n FR/AR ;
- mobile : gestion d'état, navigation, base locale, file d'envoi et moteur de synchronisation ;
- outils de test de chaque partie et plateforme de CI.

Le plan découpe le socle en tâches par agent. Le parcours témoin est « Mes chantiers » : la liste, puis la fiche d'un chantier avec ses zones.

**Point de contrôle** : résumer les ADR et le plan à l'utilisateur, puis attendre son accord avant tout code.

## Étape 2 : métier minimal (`expert-metier-chantier`)
Peut être lancée en même temps que l'étape 1. Demander `docs/metier/socle.md`, qui couvre :
- la connexion, les rôles et l'affectation aux chantiers ;
- la liste « Mes chantiers », la fiche chantier et ses zones (blocs, cotes, locaux).

Avec des critères d'acceptation, dont : un utilisateur ne voit jamais un chantier qui ne lui est pas affecté.

## Étape 3 : backend (`backend-dotnet`)
Demander, puis exiger un build et des tests verts :
- la structure, la base de données et la première migration ;
- l'authentification et les rôles, les erreurs Problem Details ;
- l'OpenAPI généré et versionné dans le dépôt ;
- les endpoints chantiers, zones et affectations, et un premier endpoint de synchronisation (pull) ;
- les données de démonstration « École UV18 », pour l'environnement de développement uniquement ;
- les tests.

## Étape 4 : clients, en parallèle (`frontend-react` et `mobile-flutter`)
Lancer les deux, puis attendre leurs deux rapports.
- **Web** : mise en page, routage, connexion, client API généré, i18n FR/AR avec RTL,
  pages « Mes chantiers » et fiche chantier, tests.
- **Mobile** : structure, connexion et stockage sécurisé des jetons, base locale, file d'envoi et moteur de synchronisation
  (au moins le pull des chantiers), indicateur de synchronisation, i18n FR/AR, écran « Mes chantiers » lisible hors ligne, tests.

## Étape 5 : CI et démarrage local (`devops-ci`)
- Pipeline build + tests des trois applications et contrôle du contrat OpenAPI, sur la plateforme choisie dans l'ADR.
- `docs/exploitation/demarrage-local.md` : comment lancer la base, l'API, le web et le mobile sur un poste de développement.

## Étape 6 : vérification (`qa-tests` et `revue-securite-perf`)
- Lancer les deux en parallèle, puis attendre leurs deux rapports.
- Faire corriger les défauts Bloquant et Majeur par les agents concernés, puis relancer `qa-tests` (au plus 2 boucles).

## Étape 7 : clôture
Résumer en 10 lignes au plus :
- ce qui marche ;
- comment lancer et tester en local (commandes, compte de démonstration) ;
- les ADR pris et les défauts mineurs restants ;
- la suite conseillée : `/fonctionnalite demandes de matériaux et livraisons`.

Proposer ensuite un commit « Socle technique ».
