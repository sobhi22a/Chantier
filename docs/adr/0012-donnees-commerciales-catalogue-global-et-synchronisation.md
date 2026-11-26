# ADR 0012 : Données commerciales réservées, catalogue global et synchronisation

**Date :** 2026-11-25 · **Statut :** Acceptée · **Auteur :** architecte-chantier · **Complète :** ADR 0005, ADR 0008, ADR 0009

## Contexte
Trois contraintes nouvelles apparaissent avec les demandes de matériaux (`docs/metier/demandes-materiaux-livraisons.md`) :
1. **Prix, montants, valeur reçue, n° de bon de commande** ne doivent jamais atteindre un ChefChantier ni un ChefEquipe, ni sur le réseau ni sur leur téléphone (CA-MAT-009.3, CA-MAT-010.13), comme le montant du marché (ADR 0005).
2. Le **téléphone d'un fournisseur** est une donnée de contact réservée (H-MAT-16, règle 8) ; l'ADR 0008 exige le chiffrement de la base locale (SQLCipher) **avant** de synchroniser un téléphone, et ce chiffrement n'est pas dans le socle.
3. Le **catalogue des produits** et la **liste des fournisseurs** sont communs à tous les chantiers (H-MAT-17) alors que tout le protocole de synchronisation suppose qu'une ligne appartient à un chantier (`SyncChangeRow.SiteId`, filtre sur les chantiers visibles).

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. Prix synchronisés vers les rôles autorisés (Conducteur, Achats), masqués par l'interface | Le conducteur voit les prix hors ligne | Impose SQLCipher maintenant ; un seul oubli de filtre fait fuiter ; deux formes de réponse à tester par rôle | Élevé |
| B. **Aucun champ commercial dans la synchronisation, pour personne** ; les rôles autorisés les lisent en ligne par l'API REST | Fuite impossible par la synchro ; pas de SQLCipher requis ; une seule forme de données sur le téléphone | Le conducteur ne voit pas les prix hors ligne (inutile pour valider une quantité) | Faible |
| C. Table de prix séparée, non synchronisée | Séparation nette | Jointures et table de plus pour le même effet que B | Moyen |

## Décision
**Option B.**
- **Un objet imbriqué `commercial`** (`unitPrice`, `amount`, `receivedValue`, `purchaseOrderNumber`) dans les réponses REST de commande et de demande ; il est **omis** (clé non écrite) sans la permission `Prices.View` (Admin, Direction, ConducteurTravaux, Achats). Les données de synchronisation (`*SyncData`) **ne contiennent jamais** `commercial`, quel que soit le rôle, et le push rend la forme de synchronisation (ADR 0011).
  Un seul endroit construit cet objet (`CommercialProjection`) ; un test parcourt tous les endpoints en tant que ChefChantier et ChefEquipe et échoue si la chaîne `commercial` ou un champ de prix apparaît.
- **Historique** : les modifications commerciales d'une commande sont des événements d'un type dédié `OrderCommercialEdited`, **filtré par type** (masqué sans `Prices.View`, jamais synchronisé). Aucun champ commercial ne figure dans les `Changes` des autres événements.
- **Téléphone d'un fournisseur** : permission `SupplierPhone.View` (Admin, Achats, ConducteurTravaux, ChefChantier) ; renvoyé par `GET /suppliers` et `GET /suppliers/{id}` seulement ; **jamais synchronisé** et jamais journalisé. Sur le mobile, « Appeler le fournisseur » le lit en ligne, l'affiche et lance `tel:` sans l'enregistrer. Le stocker hors ligne attend SQLCipher (lot photos et intervenants).
  Nouvelle dépendance Flutter : `url_launcher` (première partie, BSD) ; ajouter `<queries>` pour l'intention `tel:` dans le manifeste Android.
- **Entités globales** (`product`, `supplier`) : `SyncChange.siteId` et `SyncDeletion.siteId` deviennent **nullables** (`null` = global). Ces sources ignorent le filtre de chantier : tout utilisateur authentifié les reçoit (ils sont lisibles par tous les rôles, H-MAT-17). Elles ne produisent pas de pierre tombale : on désactive, on ne supprime pas (`isActive`). Changement de contrat **additif pour le serveur**, mais les clients générés (web, mobile) doivent être régénérés (`siteId` passe à nullable).
- **Entités d'un chantier** : `request`, `delivery`, `photo` (nouvelles `ISyncSource` dans `SyncTouch.TouchedEntityTypes`, un test d'architecture l'exige). La commande n'est **pas** une entité synchronisée : elle est incorporée à la demande (`order` sans `commercial`), toute écriture de commande modifiant aussi la ligne de la demande (donc sa version).
  L'historique est incorporé à la ligne de la demande ou de la livraison dont il dépend (même raison). `photo` n'est servie qu'avec `DeliveryPhotos.View` (les ChefEquipe ne reçoivent aucune ligne `photo`).
- **Permissions** : catalogue complété dans `PermissionResources` / `Permissions` / `RolePermissionMatrix` (détail dans le plan). Une permission qui change fait changer `permissionsVersion` : rechargement complet des mobiles au déploiement, attendu.
- Les prix sont donc **absents de la base du téléphone pour tous les rôles** : l'inspection de la base Drift fait partie des tests (CT-MAT-24).

## Conséquences
- Plus facile : la règle « ni prix ni téléphone sur le terrain » devient un fait structurel vérifiable ; pas de SQLCipher dans ce lot.
- Plus difficile : un acheteur qui voudrait ses prix hors ligne sur mobile ne les aura pas ; l'écran mobile de commande (optionnel, tâche MAT-M10) est en ligne seulement.
- À surveiller : tout nouveau DTO contenant un montant doit passer par `CommercialProjection` ; la décision est à revoir si l'utilisateur demande les prix sur mobile (alors : SQLCipher d'abord, ADR de remplacement).
