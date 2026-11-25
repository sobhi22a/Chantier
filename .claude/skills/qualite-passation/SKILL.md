---
name: qualite-passation
description: Méthode de travail commune aux agents du projet chantier. Contient les règles d'efficacité, l'usage de la mémoire, la définition de terminé, le format du rapport de passation, les niveaux de sévérité et les modèles de documents (user story, plan, ADR, rapport QA, rapport de revue). À appliquer par chaque agent du début à la fin d'une tâche.
user-invocable: false
---

# Méthode commune des agents

## 1. Avant de commencer
- Relire ta **mémoire** (`MEMORY.md`, déjà chargée) : conventions, chemins, commandes, pièges connus.
- Lire uniquement ce qui sert la tâche : le plan et la user story cités dans la demande, puis les fichiers concernés.
  Chercher d'abord (Grep, Glob, `LSP` s'il est actif), lire ensuite. Ne jamais parcourir tout le dépôt « pour voir ».
- Établir la **ligne de base** avant de modifier : build et tests du périmètre. Si c'est déjà rouge, le noter :
  ce n'est pas à toi de le corriger, sauf si la tâche le demande.
- Information manquante : si elle bloque, s'arrêter et la poser dans « Questions ouvertes » ; sinon prendre l'hypothèse
  la plus prudente, la paramétrer plutôt que la coder en dur, et l'écrire dans le rapport.

## 2. Pendant le travail
- **Petits pas vérifiés** : modifier, compiler, tester, puis continuer. Jamais une longue série de changements sans compiler.
- Rester dans **son périmètre** : un agent ne modifie pas la partie d'un autre (backend, web, mobile, CI). Il le signale.
- Imiter l'existant : avant de créer un fichier, en lire 2 ou 3 du même type et suivre leur structure.
- Pas de code mort, pas de `TODO` sans référence, pas de simulation laissée en production, pas de secret en dur.
- Ne jamais affirmer qu'un build ou un test passe sans l'avoir exécuté. Citer la commande et son résultat réel.
- Données de test : toujours fictives (voir le skill `metier-chantier`, donnees-test.md).
- Commandes : utiliser l'outil de shell disponible (`Bash`, ou `PowerShell` sous Windows) ; aucune commande destructrice
  (suppression de base, `git push --force`, `git reset --hard`, déploiement) sans demande explicite.

## 3. Mémoire de l'agent (`.claude/agent-memory/<agent>/MEMORY.md`)
À la fin de chaque tâche, ajouter seulement des **faits durables et vérifiés**, en une ligne chacun, rangés sous :
`## Conventions` · `## Chemins clés` · `## Commandes qui marchent` · `## Pièges connus` · `## Décisions (lien ADR)`.
Garder le fichier sous 200 lignes : fusionner, corriger ou supprimer les entrées dépassées. Jamais de secret ni de donnée personnelle.

## 4. Définition de terminé (commune)
- [ ] Chaque critère d'acceptation est couvert par au moins un test, et ce test passe.
- [ ] Build OK, tests OK, analyse statique ou lint sans **nouvel** avertissement.
- [ ] Contrat d'API respecté ; tout écart est documenté et validé par l'architecte.
- [ ] Règles métier non négociables respectées (unités, dates, calculs serveur, droits, données sensibles).
- [ ] Aucun texte d'interface en dur : clés de traduction en français et en arabe.
- [ ] Migrations nommées, relues, réversibles ; aucune perte de données.
- [ ] Documents à jour : plan coché, ADR si une décision a été prise.
- [ ] Mémoire de l'agent mise à jour.
- [ ] Rapport de passation rendu.

## 5. Rapport de passation (dernier message de chaque agent, toujours ce format)
```
## Rapport : <agent> : <fonctionnalité ou tâche>
**Statut :** Terminé | Partiel | Bloqué
**Fait :**
- …
**Fichiers modifiés :**
- `chemin/fichier` : raison
**Vérifications exécutées :**
- `commande` → résultat réel (par ex. `dotnet test` → 142 réussis, 0 échec)
**Hypothèses et écarts :**
- …
**Questions ouvertes :**
- [pour qui] question
**Suite :** agent suivant + ce qu'il doit savoir (chemins des documents, points d'attention)
```
Court et factuel : pas de récit, pas de copie de code, des chemins de fichiers.

## 6. Sévérité (QA, revue, corrections)
| Niveau | Définition | Conséquence |
|---|---|---|
| Bloquant | Perte ou fuite de données, faille exploitable, calcul faux, fonctionnalité inutilisable | Corriger avant toute livraison |
| Majeur | Critère d'acceptation non respecté, régression, performance inacceptable sur le terrain | Corriger dans le lot |
| Mineur | Défaut gênant avec contournement simple | Planifier |
| Suggestion | Amélioration | Au choix de l'architecte |

## 7. Modèles de documents
- User story : [modeles/user-story.md](modeles/user-story.md) → `docs/metier/<slug>.md`
- Plan de fonctionnalité : [modeles/plan.md](modeles/plan.md) → `docs/plans/<slug>.md`
- Décision d'architecture : [modeles/adr.md](modeles/adr.md) → `docs/adr/NNNN-<slug>.md`
- Rapport QA : [modeles/rapport-qa.md](modeles/rapport-qa.md) → `docs/qa/<slug>.md`
- Rapport de revue : [modeles/rapport-revue.md](modeles/rapport-revue.md) → `docs/revues/<AAAA-MM-JJ>-<slug>.md`

`<slug>` : nom court en minuscules avec tirets, identique dans tous les documents d'une même fonctionnalité
(par ex. `demandes-materiaux`).
