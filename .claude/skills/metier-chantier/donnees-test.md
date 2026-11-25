# Jeu de données de test : « École UV18 » (fictif)

Inspiré des notes réelles d'un chef de chantier, **anonymisé** : noms et téléphones fictifs.
Ne jamais mettre de vraies personnes ni de vrais numéros dans le code, les tests ou les captures.

## Chantier et zones
- Chantier `CH-ECO-UV18` « École UV18 », type école, maître d'ouvrage « Direction des équipements publics (fictive) ».
- Blocs : Bloc 01, Bloc 02. Cotes du Bloc 01 : −1,90 · ±0,00 · +3,40 · +6,80 · +10,20.
- Locaux : classes 01 à 06 (RDC), classes du 1er étage, couloir RDC, couloir 1er, cantine, réfectoire, cuisine.

Comptes de démonstration (1 par rôle + 1 non affecté), 2e chantier `CH-LOG-OL40` et liste complète des 26 zones :
voir `docs/metier/socle.md` (section « Données de démonstration »).

## Coulages du Bloc 01
| Date | Ouvrage | Cote |
|---|---|---|
| 20/05/2026 | Semelles + longrines | −1,90 |
| 08/06/2026 | Voile périphérique + amorces de poteaux | — |
| 18/06/2026 | Essai de compactage (essai, pas un coulage) | — |
| 04/07/2026 | Longrines | ±0,00 |
| 21/07/2026 | Dalle | ±0,00 |
| 30/07/2026 | Poteaux | +3,40 |
| 03/08/2026 | Poteaux + voiles | +3,40 |
| 25/08/2026 | Dalle | +3,40 |
| 22/09/2026 | Poteaux-voiles + poteaux | +6,80 |
| 05/10/2026 | Dalle | +6,80 |
| 20/10/2026 | Poteaux-voiles + poteaux | +10,20 |

Volumes et dosages : absents des notes. Pour les tests, utiliser des valeurs explicites (par ex. dalle = 60 m³, 350 kg/m³).

## Intervenants (fictifs)
| Nom | Métier | Équipe / entreprise | Téléphone |
|---|---|---|---|
| Yacine B. | Coffreur | Équipe coffrage 1 | 0550 00 00 01 |
| Samir K. | Coffreur | Équipe coffrage 1 | 0550 00 00 02 |
| Nabil T. | Ferrailleur | Équipe ferraillage | 0550 00 00 03 |
| Rachid M. | Manœuvre | — | 0550 00 00 04 |
| Omar D. | Chauffeur + manœuvre | — | 0550 00 00 05 |
| Lyes A. | Gardien | — | 0550 00 00 06 |
| Sous-traitant Alpha | Crépissage | Sous-traitant | 0550 00 00 07 |
| Sous-traitant Bêta | Maçonnerie | Sous-traitant | 0550 00 00 08 |
| Sous-traitant Gamma | Monocouche + plinthes | Sous-traitant | 0550 00 00 09 |

## Livraisons de ciment 2026
| Date saisie | Destination | Quantité | Résultat attendu |
|---|---|---|---|
| `../01/2026` | Retba | 10 T | **Refusée** : `DATE_INVALIDE` |
| 18/07/2026 | École UV18 | 20 T | Acceptée |
| 21/07/2026 | École UV18 | 20 T | Acceptée |
| `../08/2026` | École UV18 | 20 T | **Refusée** : `DATE_INVALIDE` |
| 19/08/2026 | École UV18 | 20 T | Acceptée |
| 21/09/2026 | École UV18 | 10 T | Acceptée |
| 24/09/2026 | Auberge | 10 T | Acceptée (autre chantier) |
| `../10/2026` | École UV18 | 10 T | **Refusée** : `DATE_INVALIDE` |
| 21/10/2026 | École UV18 | 10 T | Acceptée |
| 04/11/2026 | École UV18 | 10 T | Acceptée |
| 05/11/2026 | École UV18 | 10 T | Acceptée |
| 14/11/2026 | École UV18 | 10 T | Acceptée |

Total livré à l'école si toutes les dates étaient complètes : 140 T. Total des seules livraisons acceptées : 110 T
(les 2 livraisons refusées de l'école représentent 30 T à ressaisir avec leur date exacte).
Historique 2023 (fournisseur Sedik, destination Retba) : 5 × 400 sacs = 2 000 sacs = 100 T.

## Situations des sous-traitants
| Sous-traitant | Lot | Local | Expression | Unité | Quantité attendue |
|---|---|---|---|---|---|
| Alpha | Crépissage | Couloir RDC bloc 01 | `65+96+39` | m² | 200 |
| Alpha | Crépissage | Réfectoire | `135+65/2` | m² | 167,5 |
| Alpha | Crépissage | Cuisine | `70.05+50+25+140/2` | m² | 215,05 |
| Alpha | Crépissage | Façade cantine | `371` | m² | 371 |
| Bêta | Maçonnerie | Cantine | `465+93+29+87.5` | m² | 674,5 |
| Bêta | Appuis | Cantine | `33+55+10` | ml | 98 |
| Bêta | Maçonnerie | Classes RDC | `328+100+5` | m² | 433 |
| Bêta | Appuis | Classes RDC | `31` | ml | 31 |
| Bêta | Maçonnerie | Classes 1er | `205+80+6` | m² | 291 |
| Bêta | Appuis | Classes 1er | `18` | ml | 18 |
| Bêta | Maçonnerie | Couloir 1er bloc 01 | `65+96+39` | m² | 200 |
| Gamma | Monocouche (350 DA/m²) | Classes 01 + 02 RDC bloc 01 | `68*2` | m² | 136 → 47 600,00 DA |
| Gamma | Plinthes (100 DA/ml) | Classes 01 + 02 RDC bloc 01 | `32*2` | ml | 64 → 6 400,00 DA |

Total de la situation de Gamma : 54 000,00 DA.
Test négatif : une ligne `328+100+5+31` déclarée en m² avec la mention « App » doit être signalée comme suspecte (unités mélangées).
