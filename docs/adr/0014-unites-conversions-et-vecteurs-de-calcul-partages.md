# ADR 0014 : Unités, conversions et vecteurs de calcul partagés

**Date :** 2026-11-25 · **Statut :** Acceptée · **Auteur :** architecte-chantier · **Complète :** règle 3 (calculs côté serveur), ADR 0008 (« aucune arithmétique sur quantités côté mobile »)

## Contexte
Les demandes et livraisons imposent des conversions (sac ↔ kg ↔ T selon la masse du sac du produit), des cumuls dans l'unité de la commande, un statut calculé et des totaux sans mélange d'unités (`docs/metier/demandes-materiaux-livraisons.md`, `calculs.md` §8).
La règle 3 dit que le serveur décide. Mais deux écrans doivent **afficher** des valeurs calculées **sans réseau** : « 300 sacs = 15 T » pendant la frappe (CA-MAT-001.3) et l'état provisoire « à confirmer » après une livraison saisie hors ligne (CA-MAT-006.7, CA-MAT-010.11).
La règle « aucune règle dupliquée entre web et mobile » ne peut donc pas être appliquée à la lettre pour l'affichage.

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. Aucun calcul sur le client ; le mobile affiche « à confirmer » sans chiffre | Règle 3 respectée à la lettre | L'équivalence anti-faute de frappe disparaît (3000 au lieu de 300) ; aucun cumul hors ligne | Mauvais pour le terrain |
| B. **Miroir d'affichage** : une petite fonction de conversion et de cumul par client, **non décisionnelle**, testée par les **mêmes vecteurs** que le serveur ; le serveur recalcule et sa valeur remplace toujours celle du client | Le terrain voit ses chiffres ; une seule vérité (le serveur) ; dérive détectée par les tests | Trois implémentations de ~40 lignes à tenir synchrones | Faible |
| C. Service de calcul appelé par le client | Une seule implémentation | Inutilisable hors ligne | Inacceptable |

## Décision
**Option B.**
- **Serveur (fait foi)** : `Chantier.Core/Materials/` : `MeasureUnit` (codes stables `u`, `ml`, `m2`, `m3`, `kg`, `t`, `sac`, `l`, `h`, `j`, `pj`, `ft`, sérialisés par `[JsonStringEnumMemberName]`), `Quantity(decimal Value, MeasureUnit Unit)`, `UnitConverter` (seules conversions : `sac` ↔ `kg` ↔ `t` ; masse du sac du produit ; arrondi à 3 décimales `AwayFromZero` ; toute autre paire : `UNITES_INCOMPATIBLES`), `QuantityRules` (unités entières `sac` et `u`, > 0, 3 décimales), `RequestStatusCalculator`, `QuantityAggregator` (totaux par produit et par famille convertible), `Money.Round` (2 décimales `AwayFromZero`), `OverdueCalculator`. Aucune dépendance à EF ni à HTTP : tests unitaires purs.
- **Vecteurs partagés** : `docs/api/vecteurs-materiaux.json` (tirés de `calculs.md` §8, recalculés) est lu par les tests .NET, Dart et TypeScript. Toute règle de calcul modifiée change d'abord ce fichier.
- **Miroirs d'affichage** : web (`libs/i18n` ou `features/materials/types/quantityMirror.ts`) et mobile (`features/materials/domain/quantity_mirror.dart`, paquet `decimal`, jamais `double`) n'implémentent que la **conversion**, le **cumul** et le **statut provisoire** ; ils n'écrivent jamais un montant ni un total de chantier. Tout chiffre issu d'un miroir est étiqueté « à confirmer » tant que le serveur n'a pas répondu.
- Le **serveur recalcule toujours** (jamais confiance au client) : `Delivery.QuantityInRequestUnit`, `MaterialRequest.ReceivedQuantity`, le statut et les montants sont calculés à l'écriture, dans la transaction, par le domaine.
- **Paramètres** : `Materials:DeliveryTolerancePercent` (0), `Product.BagMassKg` (par produit), pas de constante en dur ; une masse de sac modifiée recalcule les livraisons des demandes ouvertes du produit.

## Conséquences
- Plus facile : les trois plateformes prouvent leur accord avec le serveur ; une règle nouvelle (barres d'acier, option B de Q-MAT-05) = une ligne de table de conversion + de nouveaux vecteurs.
- Plus difficile : toute évolution du calcul demande de toucher trois suites de tests ; le miroir ne doit pas grossir (revue de code : pas de montant ni de règle de statut hors du domaine serveur).
- À surveiller : écart d'arrondi entre `decimal` (.NET), `decimal` (paquet Dart) et le web, qui n'a **aucune bibliothèque décimale** (`package.json`) : le miroir web calcule en **entiers `BigInt` en millièmes** (aucun `number` flottant, aucune nouvelle bibliothèque) ; les vecteurs couvrent 405,2 sacs, 613,125 et 122,625.
