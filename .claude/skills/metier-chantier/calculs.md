# Calculs métier et cas vérifiés

Chaque cas ci-dessous a été calculé et vérifié. Il doit exister **un test automatisé par cas** (backend),
et les clients affichent les valeurs renvoyées par le serveur.

## 1. Expression de métré
Grammaire acceptée :
- nombres décimaux, séparateur `,` ou `.` (normaliser), espaces ignorés, aucun séparateur de milliers ;
- opérateurs `+` `-` `*` `×` `x` `X` `/` `÷`, parenthèses, moins unaire (déductions d'ouvertures : `-(1.2*2.1)`) ;
- priorités usuelles (× et ÷ avant + et −) ;
- longueur ≤ 200 caractères, profondeur de parenthèses ≤ 10 ;
- résultat > 0, arrondi à 3 décimales (`AwayFromZero`).

Implémentation : **analyseur dédié** (descente récursive ou équivalent) sur `decimal`.
Interdit : `DataTable.Compute`, évaluation de script, `dynamic`, compilation à la volée.

| Expression | Résultat | Remarque |
|---|---|---|
| `65+96+39` | 200 | |
| `135+65/2` | 167,5 | La note de terrain indiquait « 170 » : le total saisi à la main était faux |
| `(135+65)/2` | 100 | Montre pourquoi l'expression doit être écrite sans ambiguïté |
| `70.05+50+25+140/2` | 215,05 | La note indiquait « 216 » |
| `465+93+29+87.5` | 674,5 m² | Maçonnerie de la cantine, hors appuis |
| `33+55+10` | 98 ml | Appuis de la cantine : **ligne séparée en ml** |
| `328+100+5` | 433 m² | La note additionnait `+App 31` pour annoncer 464 : mélange m² + ml refusé |
| `205+80+6` | 291 m² | La note annonçait 310, et 291 + 18 = 309 : total faux et unités mélangées |
| `10/0` | erreur | `EXPRESSION_INVALIDE` |
| `65+96+` | erreur | `EXPRESSION_INVALIDE` |
| `65;96` | erreur | `EXPRESSION_INVALIDE` (caractère interdit) |

## 2. Montant d'une ligne
`montant = arrondi2(quantité × prix unitaire)` avec `MidpointRounding.AwayFromZero`.
Le total d'une situation = somme des montants **déjà arrondis** des lignes.

| Cas | Calcul | Résultat |
|---|---|---|
| Monocouche, 1 classe | 68 m² × 350 DA | 23 800,00 DA |
| Plinthes, 1 classe | 32 ml × 100 DA | 3 200,00 DA |
| Total par classe (2 lignes) | 23 800,00 + 3 200,00 | 27 000,00 DA |
| Monocouche + plinthes, 2 classes | 2 × 27 000,00 | 54 000,00 DA |
| Monocouche seule, 2 classes | 2 × 68 m² × 350 DA | 47 600,00 DA |
| Arrondi au demi-centime | 1,005 m² × 1,00 DA | **1,01 DA** (l'arrondi bancaire par défaut de .NET donnerait 1,00 : interdit) |

## 3. Ciment : unités et rapprochement avec le béton
- Masse d'un sac : paramètre du produit, 50 kg par défaut.
- 400 sacs × 50 kg = 20 000 kg = **20 T**. Cinq livraisons de 400 sacs = 2 000 sacs = **100 T**.
- Ciment théorique d'un coulage = volume (m³) × dosage (kg/m³). Exemple : 60 m³ × 350 kg/m³ = 21 000 kg = **21 T**.
- Écart (%) = (livré − théorique − stock restant) ÷ théorique × 100.
  Exemple : livré 25 T, théorique 21 T, stock 2 T → (25 − 21 − 2) ÷ 21 × 100 = **9,52 %**.
- Seuil d'alerte paramétrable par chantier (par ex. 5 %) : au-dessus, signaler à ConducteurTravaux.
- Les livraisons de l'école UV18 en 2026 totalisent **140 T** (4 × 20 T + 6 × 10 T), dont 2 livraisons à date
  incomplète (30 T) qui doivent être refusées à la saisie : **110 T acceptées** (voir donnees-test.md).

## 4. Rythme des niveaux et prévision
- Intervalle entre dalles successives du Bloc 01 : 21/07/2026 → 25/08/2026 = **35 jours** ; 25/08/2026 → 05/10/2026 = **41 jours**.
- Moyenne = 38 jours → dalle suivante prévue vers le **12/11/2026** (05/10/2026 + 38 jours).
- La prévision est indicative : l'afficher avec la méthode de calcul, jamais comme une date contractuelle.

## 5. Avancement
`avancement chantier = Σ(poids × % tâche) ÷ Σ(poids)`, poids = montant DQE de la tâche, sinon sa durée prévue.
Exemple : poids 100, 300, 600 avec 100 %, 50 %, 0 % → (100×100 + 300×50 + 600×0) ÷ 1000 = **25 %**.
Retard d'une tâche non terminée = max(0, aujourd'hui − fin prévue) en jours (fuseau Africa/Algiers).

## 6. Main-d'œuvre
- Homme-jours d'une période = nombre de pointages « présent » + 0,5 × « demi-journée ».
- Coût main-d'œuvre à la journée = Σ(homme-jours × tarif journalier de l'intervenant), arrondi à 2 décimales.

## 7. Chantier : fin contractuelle et affichage des cotes
Fin contractuelle = date de l'ODS de démarrage + délai en jours calendaires (convention à confirmer : jours calendaires,
jour de l'ODS non compté ; voir `docs/metier/socle.md`, question Q-04). Sans ODS ou sans délai : « À définir ».

| ODS | Délai | Fin contractuelle | Remarque |
|---|---|---|---|
| 02/03/2026 | 540 j | **24/08/2027** | 365 j jusqu'au 02/03/2027, puis 175 j (29 + 30 + 31 + 30 + 31 + 24) |
| 15/06/2026 | 420 j | **09/08/2027** | 365 j jusqu'au 15/06/2027, puis 55 j (15 + 31 + 9) |
| 15/01/2026 | 30 j | **14/02/2026** | |
| 01/03/2027 | 366 j | **01/03/2028** | 29/02/2028 compté (année bissextile) |

Affichage d'une cote (mètres, 2 décimales, virgule) : `+3,40` · `−1,90` · `±0,00` pour zéro. Plage acceptée : −20,00 à +60,00 (paramétrable).
