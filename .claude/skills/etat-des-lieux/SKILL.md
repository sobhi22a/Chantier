---
name: etat-des-lieux
description: Lance l'état des lieux complet du projet existant (.NET 10, React, Flutter) par l'agent architecte-chantier, sans modifier le code. À utiliser au démarrage, puis après une évolution importante.
argument-hint: "[point d'attention facultatif]"
disable-model-invocation: true
context: fork
agent: architecte-chantier
background: false
---

Réalise l'état des lieux du projet (mode A de ta méthode) sans modifier aucun fichier de code.

Point d'attention demandé par l'utilisateur (peut être vide) : $ARGUMENTS

Livrables :
1. `docs/architecture/etat-des-lieux.md`, qui contient :
   - la carte du dépôt et les versions réelles ;
   - l'architecture des trois parties ;
   - la ligne de base : build et tests exécutés, avec les résultats réels ;
   - les écarts avec le modèle de domaine ;
   - la dette et les risques classés par sévérité, avec preuves ;
   - les bibliothèques à risque (licence, maintenance) ;
   - le plan de lots priorisés ;
   - les questions ouvertes.
2. Ta mémoire mise à jour : chemins clés, commandes de build et de test qui marchent, conventions.
3. Le rapport de passation. Il se termine par les 3 premiers lots recommandés et les questions à poser à l'utilisateur.
