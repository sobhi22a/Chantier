# Plan : <fonctionnalité>

**Slug :** `<slug>` · **User stories :** `docs/metier/<slug>.md` · **Auteur :** architecte-chantier · **Statut :** Proposé | Validé

## Résumé
2 ou 3 phrases : ce qui sera livré et pourquoi.

## Modèle de données
| Entité | Champs ajoutés / modifiés | Index et contraintes | Migration |
|---|---|---|---|

## Contrat d'API
| Méthode | Route | Rôles | Requête | Réponses (codes) |
|---|---|---|---|---|
Codes d'erreur métier utilisés : …

## Synchronisation hors ligne
| Entité | Créée hors ligne ? | Modifiable hors ligne ? | Politique de conflit |
|---|---|---|---|

## Interfaces
- Web : écrans, filtres, actions.
- Mobile : écrans, actions rapides, comportement hors ligne.

## Découpage des tâches
| # | Agent | Tâche | Dépend de | Critères couverts |
|---|---|---|---|---|
| 1 | backend-dotnet | … | — | CA-1.1, CA-1.2 |
| 2 | frontend-react | … | 1 | … |
| 3 | mobile-flutter | … | 1 | … |
| 4 | qa-tests | … | 2, 3 | tous |

## Stratégie de test
Tests unitaires (règles), tests d'intégration (API + base), tests de widgets / composants, scénarios hors ligne.

## Risques
| Risque | Probabilité | Impact | Parade |
|---|---|---|---|

## Décisions
Liens vers les ADR créés ou concernés.

## Fini quand
- [ ] Tous les critères d'acceptation sont couverts par des tests qui passent
- [ ] QA et revue sans défaut Bloquant ni Majeur
- [ ] Validation métier « conforme »
