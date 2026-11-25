---
name: revue
description: Revue complète d'un périmètre (fonctionnalité, dossier ou changements en cours) par qa-tests et revue-securite-perf en parallèle, avec une liste consolidée de corrections priorisées.
argument-hint: "[slug, dossier, ou vide pour les changements en cours]"
disable-model-invocation: true
---

# Revue : $ARGUMENTS

1. **Déterminer le périmètre.**
   - Si « $ARGUMENTS » est vide : les changements en cours (`git status`, `git diff`).
   - Sinon : la fonctionnalité (slug) ou le dossier indiqué.
2. **Lancer en parallèle** `qa-tests` et `revue-securite-perf` sur ce périmètre, puis **attendre leurs deux rapports**.
   Chacun produit son rapport dans `docs/qa/` ou `docs/revues/`.
3. **Consolider** les deux rapports en une seule liste triée par sévérité, de Bloquant à Suggestion.
   - Pour chaque constat : la preuve (fichier:ligne) et l'agent à qui corriger.
   - Fusionner les doublons.
4. **Présenter la liste** à l'utilisateur et proposer de faire corriger les défauts Bloquant et Majeur par les agents concernés.
   Ne rien corriger sans son accord.
