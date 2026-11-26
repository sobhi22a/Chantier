---
name: validation-demandes-materiaux-livraisons
description: Validation terrain du 26/11/2026 des demandes/livraisons : verdict Conforme avec réserves, écarts E-01..E-12, questions Q-V01..06 posées à l'utilisateur
metadata:
  type: project
---

`docs/metier/validation-demandes-materiaux-livraisons.md` : verdict **Conforme** (0 Bloquant, 0 Majeur, 9 Mineurs, 3 suggestions), conditions de mise en service (réponses Q-MAT, relecture arabe, essai téléphone réel, catalogue de départ).

**Why:** étape 7 de `/fonctionnalite`; la QA est verte mais n'a rien mesuré sur appareil, et les 10 Q-MAT restent « retenues par défaut » sans réponse d'un vrai chef.

**How to apply:** avant de rouvrir ce lot, relire les réponses de l'utilisateur aux Q-MAT-01..10 et Q-V01..06, puis seulement mettre à jour SKILL.md (statuts), glossaire (clôturer/recevoir) et calculs.md §8 (tolérance par unité).
- Trouvailles de terrain à ne pas oublier : pas de pastille « Aujourd'hui » et « Semaine prochaine » = lundi (la semaine de travail commence le dimanche en Algérie ; faute de mon propre CA-MAT-001.2) ; liste « À traiter » promise par les CA (réserve, surplus, non rattachée) jamais construite (surplus sans liste) ; « Recevoir » (camion) / « Réceptionner » (clôturer la demande) se confondent, et l'arabe diverge entre web et mobile (للاستلام pour deux listes) ; « Matériau » (mobile) vs « Produit » (web).
- Écarts de conception connus : prix de livraison non saisissable (H-ARCH-07, contre mon besoin), tolérance globale 0 % (sacs OK, vrac pesé non), pas de quantité refusée ni de « rouvrir » après réception, pas d'unités barre/voyage, commande non groupée, pas d'alerte pour « Bloquante ».
- Aucune règle n'a été ajoutée au skill : rien n'est validé par l'utilisateur.
