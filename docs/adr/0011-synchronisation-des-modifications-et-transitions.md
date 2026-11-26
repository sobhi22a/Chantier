# ADR 0011 : Synchronisation des modifications et des transitions (opérations `update` et `transition`)

**Date :** 2026-11-25 · **Statut :** Acceptée · **Auteur :** architecte-chantier · **Complète :** ADR 0009

## Contexte
Le socle ne pousse qu'un seul type d'opération : `zone` / `create` (ajout seul, jamais de conflit). Les demandes de matériaux et les livraisons (`docs/metier/demandes-materiaux-livraisons.md`, US-MAT-010) obligent à pousser aussi
des **modifications** (`update`) et des **changements de statut** (`transition`) saisis hors ligne, pendant que d'autres personnes agissent sur les mêmes lignes.
Cas imposés par le métier : une demande modifiée hors ligne (300 → 400 sacs) puis **validée** entre-temps ; deux personnes qui changent la date de besoin ; une validation qui arrive après une annulation ; une réception d'une demande qui n'est plus complète.
Le skill `contrat-api` dit « texte libre : la dernière écriture gagne champ par champ », alors que l'expert métier demande « la première arrivée est retenue, l'autre va dans À vérifier ». Rien dans l'ADR 0009 ne dit comment rendre une opération `update` ou `transition` idempotente :
pour un `create`, l'index unique `(siteId, clientId)` suffit ; une modification n'a pas de ligne propre qui porte son `clientId`.

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. Conflit dès que `baseVersion` ≠ version serveur | Très simple, déterministe | Presque toute modification concurrente va dans « À vérifier », même sur des champs différents (contraire à CA-MAT-010.5) ; un renvoi après coupure fait un faux conflit | Faible, mais mauvais pour le terrain |
| B. **Comparaison à trois valeurs par champ** (valeur de base vue par le téléphone, valeur actuelle du serveur, nouvelle valeur), tout ou rien par opération, première arrivée retenue | Champs différents : aucune friction ; même champ : un seul gagnant, l'autre visible ; le serveur reste maître | Le téléphone envoie aussi les valeurs de base ; plus de code dans les handlers | Moyen |
| C. Dernière écriture gagne (skill) | Aucun conflit à afficher | Un chef de chantier écrase silencieusement une décision du conducteur ; viole « le serveur gagne sur les statuts » | Élevé (perte silencieuse) |
| D. Fusion automatique CRDT | Aucun conflit | Disproportionné, inutile pour des formulaires courts | Élevé |

## Décision
**Option B**, avec les règles suivantes (reprises dans `docs/api/demandes-materiaux-livraisons.md`).

1. **Sens des résultats d'une opération** (ADR 0009 précisé) : `rejected` = l'opération n'a **jamais été légitime** (droit manquant, validation, chantier archivé ou non affecté, entité inconnue) ; `conflict` = elle était valable à l'écriture mais **l'état du serveur a changé** (demande validée, annulée, déjà commandée, champ modifié par un autre). Dans les deux cas rien n'est appliqué et la ligne passe dans « À vérifier » ; seul `conflict` porte l'état du serveur (`current`).
   `SyncPushResult.Conflict` reçoit en plus un `code` (`DEMANDE_VERROUILLEE`, `TRANSITION_INTERDITE`, `DEMANDE_NON_OUVERTE`, `CONFLIT_VERSION`) et la liste `conflictFields` (champs en désaccord) : ajouts **additifs** au schéma du résultat.
2. **`update`** : `payload = { <cible>Id | <cible>ClientId, clientCreatedAt?, changes: { champ: nouvelleValeur }, base: { champ: valeurVueParLeTéléphone } }`, `baseVersion` informatif. Pour chaque champ de `changes` :
   valeur actuelle = `base` → appliquer ; valeur actuelle = nouvelle valeur → rien à faire ; sinon **champ en conflit**. Si au moins un champ est en conflit, **aucun champ de l'opération n'est appliqué** (tout ou rien) : `conflict` + `conflictFields` + `current`. Les champs verrouillés par le statut (produit, quantité, unité après validation) donnent `conflict` avec `DEMANDE_VERROUILLEE`, jamais une application partielle.
   Écart assumé avec le skill (« dernière écriture gagne ») : la première arrivée est retenue, **conformément à la demande de l'expert métier** (CA-MAT-010.4) ; il est consigné dans `docs/api/demandes-materiaux-livraisons.md`. L'API REST (`PUT` avec `version`) reste stricte : version périmée = 409 `CONFLIT_VERSION`.
3. **`transition`** : fondée sur l'**état**, pas sur la version. Cible déjà dans l'état visé = `duplicate` (idempotent : « Déjà validée »). Transition impossible depuis l'état actuel = `conflict` avec `TRANSITION_INTERDITE`. Le serveur gagne toujours sur les statuts.
4. **Journal d'opérations** `SyncOperationLog (ClientId unique, UserId, Entity, Operation, Outcome, Code?, ResourceId?, CreatedAt)` : écrit **dans la transaction de l'opération** ; un renvoi du même `clientId` rend le même résultat (`duplicate` si appliquée, sinon le même `conflict` / `rejected` avec un `current` à jour) sans rien rejouer. Conservation 90 jours comme les pierres tombales ; la purge est reportée avec celle des pierres tombales. Les `create` restent idempotents par l'index unique de l'entité.
5. **Références entre lignes créées hors ligne** : `requestClientId`, `deliveryClientId`, `zoneClientId` (ADR 0009) acceptés partout où l'identifiant serveur est attendu ; le serveur résout par `(siteId, clientId)`. Une `…ClientId` introuvable sur une **livraison** n'est pas une erreur : la livraison est un fait de chantier, elle est enregistrée « non rattachée » (motif `RequestMissing`). Partout ailleurs : `rejected` `INTROUVABLE`.
6. **Forme des données rendues par le push** (`resource`, `current`) : **forme de synchronisation** (sans champs commerciaux, voir ADR 0012), jamais la réponse REST complète : un push ne peut pas faire fuiter un prix vers un téléphone.
7. **Ordre** : l'ordre d'envoi d'un même téléphone est l'ordre de création (ADR 0009). Le serveur n'essaie pas de le reconstituer ; une opération qui dépend d'une création échouée est `rejected` (`INTROUVABLE`) ou, pour une livraison, « non rattachée ».

## Conséquences
- Plus facile : le terrain ne voit un conflit que si deux personnes ont réellement touché au même champ ; un renvoi après coupure ne crée jamais de faux conflit ; une nouvelle entité modifiable hors ligne = un handler `update` et un `transition` qui réutilisent le même comparateur à trois valeurs (classe commune `FieldMergeEvaluator`).
- Plus difficile : le mobile doit mémoriser la valeur de base de chaque champ modifié ; l'écran « À vérifier » doit montrer les deux versions côte à côte.
- À surveiller : taille de `SyncOperationLog` (une ligne par opération non `create`, purge à écrire avant un an d'exploitation) ; messages de conflit à traduire en arabe par un relecteur du terrain.
