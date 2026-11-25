---
name: fonctionnalite
description: Fait réaliser une fonctionnalité de bout en bout par l'équipe d'agents du projet chantier, avec des points de contrôle. Enchaîne besoins, plan validé, backend, web et mobile, QA et revue, corrections, puis validation métier.
argument-hint: "<fonctionnalité, ex. demandes de matériaux et livraisons>"
disable-model-invocation: true
---

# Orchestration de la fonctionnalité : $ARGUMENTS

Tu es l'orchestrateur. À chaque étape :
- tu délègues au bon agent (outil Agent) et **tu attends son rapport avant de passer à la suite** ;
- tu transmets les **chemins** des documents, pas leur contenu ;
- tu vérifies son rapport de passation.

Tu t'arrêtes dès qu'une décision revient à l'utilisateur.

## Étape 0 : préparer
- Choisir un slug court (minuscules, tirets) pour « $ARGUMENTS ».
- Créer une liste de tâches qui reprend les étapes ci-dessous.
- Si `docs/architecture/etat-des-lieux.md` n'existe pas, proposer d'abord `/etat-des-lieux` et attendre la réponse.
- Si le socle n'existe pas encore (pas d'authentification, pas de base locale mobile, pas de CI), proposer d'abord `/socle`.
- Si le dossier est un dépôt git, proposer une branche `fonctionnalite/<slug>`.
- Si `docs/plans/<slug>.md` existe déjà, reprendre à la première étape non terminée au lieu de tout recommencer.

## Étape 1 : besoins (`expert-metier-chantier`)
- Demander `docs/metier/<slug>.md`, rédigé selon le modèle user-story.
- Si des questions ouvertes bloquent, les poser à l'utilisateur (questions à choix), puis faire compléter le document.

## Étape 2 : plan (`architecte-chantier`)
- Demander `docs/plans/<slug>.md`, la mise à jour du contrat et les ADR éventuels.
- **Point de contrôle** : présenter à l'utilisateur un résumé du plan (stories retenues, endpoints, écrans, risques,
  nombre de tâches). Attendre son accord avant d'écrire du code.

## Étape 3 : backend (`backend-dotnet`)
- Lui transmettre le plan et le contrat.
- Exiger un rapport « Terminé » avec :
  - un build et des tests réellement exécutés et verts ;
  - l'OpenAPI régénéré.
- Sinon, faire corriger avant d'aller plus loin.

## Étape 4 : clients (`frontend-react` et `mobile-flutter`)
- Les lancer en parallèle si les deux sont concernés, puis attendre leurs deux rapports.
- Chacun reçoit le plan, le contrat et le rapport du backend.

## Étape 5 : vérification (`qa-tests` et `revue-securite-perf`)
- Les lancer en parallèle, puis attendre leurs deux rapports.
- Périmètre : la fonctionnalité, ou le diff de la branche si git est disponible.

## Étape 6 : corrections
- Renvoyer chaque défaut Bloquant ou Majeur à l'agent concerné, avec le chemin du rapport et l'identifiant du défaut.
- Relancer ensuite `qa-tests` sur les corrections.
- Au plus 2 boucles. Au-delà, s'arrêter et présenter la situation à l'utilisateur.

## Étape 7 : validation métier (`expert-metier-chantier`)
- Verdict « Conforme » ou « À corriger ».
- Si « À corriger », revenir à l'étape 6.

## Étape 8 : clôture
Résumer à l'utilisateur, en 10 lignes au plus :
- ce qui est livré ;
- comment le tester (commandes, comptes, écrans) ;
- les défauts mineurs restants et les questions ouvertes ;
- la prochaine fonctionnalité conseillée.

Proposer un commit. Si la CI ou le déploiement doivent changer, proposer `devops-ci`.

## Règles
- Ne jamais sauter la QA.
- Ne jamais annoncer un résultat qu'un agent n'a pas réellement vérifié.
- Si un agent rend un rapport « Bloqué », s'arrêter et demander à l'utilisateur.
