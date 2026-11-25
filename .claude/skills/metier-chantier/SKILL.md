---
name: metier-chantier
description: Référentiel métier du suivi de chantier BTP en Algérie. Couvre le modèle de domaine, les statuts et transitions, les unités, les codes de validation et les calculs (métrés, montants, ciment/béton, avancement), ainsi que le glossaire terrain FR ↔ code. À consulter pour toute fonctionnalité, règle ou test qui touche le métier.
user-invocable: false
---

# Référentiel métier : suivi de chantier

Fichiers complémentaires, à lire quand le sujet l'exige :
- [glossaire.md](glossaire.md) : termes et abréviations du terrain (« coff », « ferr », « PV », « App »…), leur sens et leur nom dans le code.
- [calculs.md](calculs.md) : formules et cas chiffrés vérifiés, **à reprendre tels quels dans les tests**.
- [donnees-test.md](donnees-test.md) : jeu de données fictif « École UV18 » (seed, tests, démos).

## Contexte terrain
- Maîtres d'ouvrage souvent publics (par ex. la direction des équipements publics de la wilaya pour les écoles).
  Vocabulaire des marchés : ODS, CPS, BPU, DQE, attachements, situations de travaux, décomptes, avenants,
  PV de réception provisoire et définitive, réserves. Contrôle technique (CTC) et laboratoire pour les essais.
- Entreprise générale + sous-traitants payés au métré (maçonnerie, crépissage, monocouche, plinthes), au forfait ou à la journée.
- Réalité des notes de terrain : dates incomplètes, unités oubliées, abréviations, totaux faux, plusieurs chantiers mélangés.
  L'application doit **guider** la saisie (valeurs par défaut, listes, sélecteurs) et **refuser** les données inexploitables.

## Modèle de domaine
Les noms de code (anglais) sont une proposition : suivre le nommage déjà présent dans le projet.

| Entité (code) | Champs clés | Règles |
|---|---|---|
| Chantier (`Site`) | code (CH-ECO-UV18), nom, type d'ouvrage, wilaya, commune, GPS, maître d'ouvrage, n° de marché, montant, délai (jours), date de l'ODS de démarrage | La fin contractuelle = ODS + délai (calculée) |
| Zone (`Zone`) | chantier, bloc (Bloc 01), cote en m (−1,90 · ±0,00 · +3,40…), local (classe 01, couloir, réfectoire) | Cote en `decimal`, affichée signée |
| Intervenant (`Worker`) | nom, téléphone, métier, entreprise ou sous-traitant, équipe, rémunération (jour / métré / forfait), tarif, date d'arrivée, actif | Téléphone et évaluations = données sensibles |
| Équipe (`Crew`) | nom, chef d'équipe, métier dominant | |
| Pointage (`Attendance`) | intervenant, date, statut (présent / absent / retard / demi-journée), heures | Un seul pointage par intervenant et par jour |
| Journal du jour (`DailyLog`) | chantier, date, météo, effectif, travaux réalisés, visites, incidents | Un seul journal par chantier et par jour |
| Fournisseur (`Supplier`) | nom, téléphone, produits | |
| Demande (`Request`) | DEM-n°, type, désignation, quantité + unité, pour le (date), zone, priorité, motif, demandeur, statut | Transitions ci-dessous |
| Livraison (`Delivery`) | LIV-n°, demande liée (optionnelle), fournisseur, date, produit, quantité + unité, n° de BL + photo, chantier destinataire, prix unitaire (optionnel) | Livraisons partielles autorisées |
| Tâche (`WorkTask`) | T-n°, libellé, zone, lot, équipe, début et fin prévus, début et fin réels, % d'avancement, poids, statut, dépendances | |
| Coulage (`ConcretePour`) | tâche liée, ouvrage (semelle, longrine, voile, poteau, poteau-voile, dalle, escalier), zone + cote, volume m³, dosage (kg/m³), éprouvettes (nombre, lot), ferraillage réceptionné par / le | |
| Essai (`QualityTest`) | type (éprouvettes 7 j / 28 j, affaissement, compactage), date, laboratoire, résultat, conforme | |
| Photo (`Photo`) | chantier, zone, date-heure, GPS, légende, auteur, lien vers tâche / problème / livraison / coulage | |
| Problème (`Issue`) | PB-n°, catégorie, description, photo, impact (délai / coût / sécurité), solution, responsable, échéance, statut | |
| Décision (`Decision`) | date, avec qui, sujet, décision, à faire par, pour le | |
| Situation sous-traitant (`SubcontractorStatement`) | SIT-n°, sous-traitant, période, lignes de métré, total, statut | |
| Ligne de métré (`MeasurementLine`) | lot, ouvrage / zone, expression (« 65+96+39 »), quantité calculée, unité, prix unitaire, montant | **Une seule unité par ligne** |

Toutes les entités modifiables portent : `id`, `clientId` (si créées sur mobile), `createdBy/At`, `updatedBy/At`,
un jeton de version (concurrence et synchronisation) et une suppression logique (`deletedAt`).

## Statuts et transitions (tout le reste est refusé : `TRANSITION_INTERDITE`)
| Objet | Transitions autorisées (rôle) |
|---|---|
| Demande | Demandée → Validée ou Refusée (ConducteurTravaux) · Validée → Commandée (Achats) · Commandée → Livrée partiellement → Livrée (automatique selon les livraisons) · Livrée → Réceptionnée (ChefChantier) · Demandée ou Validée → Annulée (demandeur ou ConducteurTravaux) |
| Tâche | À venir → En cours → Terminée → Réceptionnée (ConducteurTravaux) · En cours ↔ Bloquée |
| Problème | Ouvert → En cours → Résolu → Vérifié · Résolu → Rouvert → En cours |
| Situation | Brouillon → Soumise → Validée ou Rejetée (ConducteurTravaux) · Validée → Payée · Rejetée → Brouillon |

Motif obligatoire pour : Refusée, Annulée, Bloquée (avec un problème lié), Rejetée, Rouvert.
Chaque transition est historisée (qui, quand, ancien → nouveau statut, motif).

## Unités autorisées
| Code | Libellé | Exemples |
|---|---|---|
| `u` | unité, pièce | portes, sacs d'adjuvant |
| `ml` | mètre linéaire | plinthes, appuis, longrines |
| `m2` (affiché m²) | mètre carré | maçonnerie, crépissage, monocouche, carrelage |
| `m3` (affiché m³) | mètre cube | béton, terrassement |
| `kg` | kilogramme | acier |
| `t` (affiché T) | tonne | ciment, acier, sable en vrac |
| `sac` | sac (masse paramétrable, 50 kg par défaut) | ciment |
| `l` (affiché L) | litre | adjuvants |
| `h` | heure | engins |
| `j` | jour | location |
| `pj` (affiché pers·j) | homme-jour | main-d'œuvre |
| `ft` | forfait | prestations |

Seules conversions autorisées : `sac` ↔ `kg` ↔ `t` (via la masse du sac du produit). Aucune autre conversion implicite.

## Codes de validation (message clair en français et en arabe côté client)
| Cas | Code |
|---|---|
| Quantité sans unité | `UNITE_OBLIGATOIRE` |
| Addition ou agrégation d'unités différentes | `UNITES_INCOMPATIBLES` |
| Date incomplète ou impossible | `DATE_INVALIDE` |
| Expression de métré invalide (caractère interdit, parenthèses, division par zéro, trop longue) | `EXPRESSION_INVALIDE` |
| Quantité ≤ 0 | `QUANTITE_INVALIDE` |
| Transition de statut non autorisée | `TRANSITION_INTERDITE` |
| Même `clientId` renvoyé | pas d'erreur : renvoyer la ressource existante |
| Chantier non affecté à l'utilisateur | 404 (ne pas révéler son existence) |
| Demande « pour le » dans le passé | avertissement, pas de blocage |

## Calculs (formules et cas vérifiés : [calculs.md](calculs.md))
- **Métré** : expression arithmétique évaluée par le serveur, l'expression saisie est conservée ; quantité à 3 décimales.
- **Montant** = quantité × prix unitaire, arrondi à 2 décimales, `MidpointRounding.AwayFromZero`
  (attention : l'arrondi par défaut de .NET est bancaire).
- **Ciment** : 1 sac = 50 kg par défaut (paramètre du produit), donc 20 sacs = 1 T.
- **Ciment théorique** d'un coulage = volume (m³) × dosage (kg/m³, par ex. 350, paramétrable par formule).
- **Avancement** d'un chantier = moyenne des % des tâches pondérée par leur poids (montant DQE, sinon durée).

## Données sensibles
- Téléphones, tarifs et évaluations des ouvriers : rôles ChefChantier, ConducteurTravaux et Admin uniquement.
- Une évaluation est factuelle, datée et signée (auteur), jamais un simple symbole (par ex. 👎) sans motif.
- Aucune donnée personnelle dans les logs, les messages d'erreur, les jeux de test ou les captures.

## Questions ouvertes (à faire trancher par un chef de chantier)
- Chiffres après les noms dans les notes (« coff21 », « ferr 16 », « manover 18 ») : tarif journalier, numéro d'équipe ou autre ?
- « App » dans les métrés : appuis de fenêtres en ml, payés séparément ?
- « Cader classe » : cadres ou encadrements ? Quelle unité ?
- Retenue de garantie sur les situations des sous-traitants : oui ou non, quel taux ?
- « retba », « lheria », « auberge » : autres chantiers ou lieux de stockage ?

Tant qu'une question n'est pas tranchée : **paramétrer plutôt que coder en dur**, et le signaler dans le rapport.
