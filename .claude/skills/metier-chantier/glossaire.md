# Glossaire terrain ↔ code

Les notes de chantier utilisent des abréviations et des fautes de frappe. L'application doit les comprendre
(recherche, import) et toujours afficher le terme correct. Les noms de code sont des propositions :
suivre le nommage déjà en place dans le projet.

## Métiers et intervenants
| Écrit sur le terrain | Terme correct | Code (proposition) |
|---|---|---|
| coff, coffreur | Coffreur | `Trade.Formworker` |
| ferr, ferrailleur | Ferrailleur | `Trade.SteelFixer` |
| manover, manœuvre | Manœuvre | `Trade.Laborer` |
| maçon | Maçon | `Trade.Mason` |
| st | Sous-traitant | `Subcontractor` |
| chauffeur | Chauffeur | `Trade.Driver` |
| gardien | Gardien | `Trade.Watchman` |
| équipe coff | Équipe de coffrage | `Crew` (métier dominant : coffrage) |

## Ouvrages et structure
| Écrit sur le terrain | Terme correct | Code (proposition) |
|---|---|---|
| semelle | Semelle (fondation) | `StructuralElement.Footing` |
| longrine | Longrine | `StructuralElement.GroundBeam` |
| voile, voil | Voile (mur en béton armé) | `StructuralElement.Wall` |
| voile P | Voile périphérique (à confirmer) | `StructuralElement.Wall` |
| PV | Poteaux-voiles | `StructuralElement.ColumnsAndWalls` |
| amorces poteaux | Amorces (attentes) de poteaux | `StructuralElement.ColumnStarters` |
| poteaux | Poteaux | `StructuralElement.Column` |
| dalle | Dalle | `StructuralElement.Slab` |
| niv, cote, ±0.00, +3.40 | Cote de niveau (m) | `Zone.Level` (`decimal`) |
| essaie de compactage | Essai de compactage | `QualityTest.Compaction` |
| éprouvettes | Éprouvettes de béton (7 j / 28 j) | `QualityTest.ConcreteSpecimen` |
| coulage | Coulage du béton | `ConcretePour` |

## Second œuvre et métrés
| Écrit sur le terrain | Terme correct | Code (proposition) |
|---|---|---|
| Crip, crépi | Crépissage | `WorkPackage.Rendering` |
| mono, monoucouch, monocouche | Enduit monocouche | `WorkPackage.SingleCoatRender` |
| plainte, plinthe | Plinthe | `WorkPackage.Skirting` |
| maçonnerie | Maçonnerie | `WorkPackage.Masonry` |
| App | Appuis de fenêtres (à confirmer), en ml | ligne de métré séparée, unité `ml` |
| Cader | Cadres / encadrements (à confirmer) | à définir |
| rds, RDC | Rez-de-chaussée | `Zone` (niveau) |
| 1er | Premier étage | `Zone` (niveau) |
| métré | Métré (quantité mesurée) | `MeasurementLine` |
| situation | Situation de travaux (état des sommes dues) | `SubcontractorStatement` |

## Approvisionnement
| Écrit sur le terrain | Terme correct | Code (proposition) |
|---|---|---|
| saces, sacs | Sacs (50 kg par défaut) | unité `sac` |
| T, 10T, 20 T | Tonnes | unité `t` |
| BL | Bon de livraison | `Delivery.DeliveryNoteNumber` + photo |
| Sedik ciments | Fournisseur (exemple de la note) | `Supplier` |
| école, auberge, retba, lheria | Chantiers ou lieux de destination (à confirmer) | `Site` |

## Mots de l'application (socle)
| Terme affiché | Sens | Code (proposition) |
|---|---|---|
| Mes chantiers | Liste des chantiers auxquels l'utilisateur est affecté | `Site` + `SiteAssignment` |
| Affectation | Lien entre un utilisateur et un chantier ; sans lui, le chantier est invisible | `SiteAssignment` |
| Chantier courant | Dernier chantier ouvert, préchoisi dans tous les formulaires | état local de l'utilisateur |
| Zone | Où : bloc + cote (facultative) + local (facultatif) | `Zone` |
| En attente d'envoi / À vérifier | Saisie faite sans réseau, pas encore envoyée / refusée par le serveur | file d'envoi |

## Marchés publics et suivi
| Terme | Sens | Code (proposition) |
|---|---|---|
| ODS | Ordre de service (démarrage, arrêt, reprise) | `ServiceOrder` |
| CPS | Cahier des prescriptions spéciales | document |
| BPU | Bordereau des prix unitaires | `UnitPriceSchedule` |
| DQE | Devis quantitatif et estimatif | `BillOfQuantities` |
| Attachement | Relevé contradictoire des travaux exécutés | `WorkRecord` |
| Décompte | Calcul des sommes dues pour une période | `PaymentCertificate` |
| PV de réception | Procès-verbal de réception provisoire / définitive | `HandoverCertificate` |
| Réserves | Défauts à lever avant réception | `Snag` |
| CTC | Organisme de contrôle technique | `Stakeholder` (contrôle) |
| Maître d'ouvrage | Client | `Owner` |
| Maître d'œuvre, BET | Bureau d'études qui conçoit et suit | `Engineer` |
| Pointage | Présence journalière | `Attendance` |
| Journal de chantier | Rapport du jour | `DailyLog` |
