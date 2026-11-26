# Demandes de matériaux, commandes et livraisons : besoins métier

**Slug :** `demandes-materiaux-livraisons` · **Priorité :** Indispensable · **Auteur :** expert-metier-chantier · **Date :** 25/11/2026 · **Version :** 1.0 (brouillon, hypothèses à valider)

## Contexte terrain
- **Situation réelle.** Mercredi 25/11/2026, 7 h. Le chef d'équipe coffrage voit que la dalle +10,20 du Bloc 01 sera coulée jeudi et qu'il manque **15 T de ciment (300 sacs)**.
  Il est sur la dalle, sans réseau (cage d'escalier), avec des gants. Aujourd'hui il téléphone ou note sur un papier. Le conducteur de travaux l'apprend l'après-midi,
  les Achats appellent le fournisseur le lendemain, le camion arrive « vers 10 h » avec un bon de livraison illisible. Personne ne sait ce qui a été demandé, ni ce qui est vraiment arrivé.
- **Ce que montrent les notes réelles :** unités oubliées (« 10T », « 20 saces »), dates incomplètes (`../08/2026`), plusieurs lieux mélangés (école, auberge, retba), totaux faux.
  Sur l'école UV18 : 140 T de ciment annoncés, **110 T seulement exploitables**, car 30 T n'ont pas de date complète.
- **La chaîne à suivre**, chaque maillon étant une ligne numérotée, datée, avec un responsable, une unité et un statut :
  besoin (`DEM-014`) → validation par le conducteur de travaux → commande par les Achats → livraison sur chantier (`LIV-021`, avec photo du bon) → réception par le chef de chantier.
- **Qui est sur le terrain :** le chef d'équipe signale ; le chef de chantier saisit, reçoit les camions et clôt ; le conducteur de travaux valide (souvent en déplacement, réseau faible) ;
  les Achats commandent depuis le bureau ; la Direction consulte.
- **Appui sur le socle** (`docs/metier/socle.md`) : chantier courant, zones (bloc, cote, local), un utilisateur ne voit que ses chantiers, numérotation `DEM-nnn` / `LIV-nnn` donnée par le serveur,
  file d'envoi hors ligne et écran « À vérifier », FR/AR, montant du marché masqué hors rôles autorisés.

## Hypothèses retenues (à valider, voir « Questions ouvertes »)
| N° | Hypothèse | Paramétrable |
|---|---|---|
| H-MAT-01 | Une demande = **un produit**, une quantité, une unité. Pour plusieurs produits : « Ajouter un autre matériau », qui reprend zone, date et urgence. | non |
| H-MAT-02 | Pas d'étape de validation du chef de chantier : le conducteur de travaux valide directement (référentiel). | non |
| H-MAT-03 | Une demande a **une seule commande**, de même quantité et même unité. Pas de scission entre fournisseurs. | non |
| H-MAT-04 | La **commande** se saisit avec réseau (web, ou mobile connecté). Demandes, validations, refus, livraisons, réceptions et annulations de demande marchent **hors ligne**. | non |
| H-MAT-05 | Date de besoin proposée = aujourd'hui + **3 jours calendaires**. | oui |
| H-MAT-06 | Urgence : **Normale** (défaut), **Urgente**, **Bloquante** (le chantier s'arrête). | non |
| H-MAT-07 | Les unités `sac` et `u` se saisissent en **nombres entiers** ; les autres unités jusqu'à 3 décimales. | non |
| H-MAT-08 | Seules conversions : sac ↔ kg ↔ T (masse du sac du produit : 50 kg pour le ciment CPJ 42,5, 25 kg pour le monocouche). **Jamais** m³ ↔ T, ni L ↔ kg, ni barre ↔ T. | masse du sac : oui |
| H-MAT-09 | Après validation, **produit, quantité et unité sont verrouillés**. Date de besoin, urgence et remarque restent modifiables (chef de chantier, conducteur) jusqu'à « Livrée ». | non |
| H-MAT-10 | Le statut d'une demande commandée **se calcule** à partir des livraisons non annulées, dans les deux sens, tant qu'elle n'est pas réceptionnée. Tolérance de « livraison complète » : **0 %**. | oui |
| H-MAT-11 | Une livraison est un **fait de chantier** : elle n'est jamais refusée à cause du statut de la demande ; au pire elle reste « non rattachée » et signalée. | non |
| H-MAT-12 | Une date de livraison n'est jamais dans le futur (date d'Algérie). | non |
| H-MAT-13 | N° du bon de livraison (BL) et photo sont **facultatifs** à la saisie (on ne bloque pas le terrain) ; une livraison sans l'un ni l'autre porte le badge « BL manquant ». 1 à 5 photos. | non |
| H-MAT-14 | Montants **hors taxes**, en DZD, 2 décimales. La TVA n'est pas gérée (question Q-MAT-06). | non |
| H-MAT-15 | Prix et montants visibles : Admin, Direction, ConducteurTravaux, Achats. **Jamais** ChefChantier ni ChefEquipe (absents des réponses du serveur et du téléphone, comme le montant du marché). | oui |
| H-MAT-16 | Téléphone d'un fournisseur visible : Admin, Achats, ConducteurTravaux, ChefChantier (chantiers affectés). Jamais ChefEquipe, jamais dans les journaux. | non |
| H-MAT-17 | Catalogue des produits et liste des fournisseurs : **communs à tous les chantiers**, tenus par Achats et Admin sur le web. Sur le terrain, « Autre produit » (nom libre) reste possible. | non |
| H-MAT-18 | Refus, annulation, solde et réserve se choisissent dans une **liste de motifs** ; « Autre » impose une remarque. | listes : oui |
| H-MAT-19 | Archivage logique : seulement pour Refusée, Annulée et Réceptionnée ; par ConducteurTravaux et Admin ; jamais d'effacement. | non |
| H-MAT-20 | Seuls `DEM` et `LIV` sont numérotés. La commande n'a **pas de numéro propre** : on la cite par sa demande (« commande de DEM-014 »), avec un n° de bon de commande facultatif. | non |
| H-MAT-21 | **Doublon possible** = même chantier, même produit, même zone (ou aucune zone), autre demande encore ouverte (Demandée ou Validée). Avertissement, jamais un blocage. | non |
| H-MAT-22 | Les retards se comptent en jours calendaires à l'heure d'Algérie. | non |
| H-MAT-23 | Une livraison sert **une seule demande** (Q-MAT-07). | non |
| H-MAT-24 | Les traductions arabes sont à faire relire (H-19 du socle). | non |

## Droits par rôle (synthèse)
O = autorisé, — = refusé, « aff. » = sur les chantiers affectés seulement.

| Action | Admin | Direction | ConducteurTravaux | Achats | ChefChantier | ChefEquipe |
|---|---|---|---|---|---|---|
| Voir demandes, commandes (sans prix) et livraisons | O (tous) | O aff. | O aff. | O aff. | O aff. | O aff. |
| Voir prix, montants, valeur reçue | O | O aff. | O aff. | O aff. | — | — |
| Voir le téléphone d'un fournisseur | O | — | O aff. | O aff. | O aff. | — |
| Voir les photos de bons de livraison | O | O aff. | O aff. | O aff. | O aff. (Q-MAT-03) | — |
| Créer une demande | O | — | O aff. | — | O aff. | O aff. |
| Modifier une demande avant validation | O | — | O aff. | — | O aff. (toutes du chantier) | la sienne seulement |
| Modifier date, urgence, remarque après validation | O | — | O aff. | — | O aff. | — |
| Annuler une demande (Demandée ou Validée) | O | — | O aff. | — | la sienne | la sienne |
| Valider, refuser, ajuster la quantité | O | — | O aff. | — | — | — |
| Commander, modifier la commande | O | — | — | O aff. | — | — |
| Annuler une commande sans livraison (Q-MAT-01) | O | — | — | O aff. | — | — |
| Solder une commande (Q-MAT-01) | O | — | O aff. | O aff. | — | — |
| Enregistrer une livraison, la rattacher à une demande | O | — | O aff. | O aff. | O aff. | — |
| Corriger ou annuler une livraison | O | — | O aff. | O aff. | O aff. | — |
| Réceptionner (Livrée → Réceptionnée) | O | — | — | — | O aff. | — |
| Archiver, restaurer une demande | O | — | O aff. | — | — | — |
| Tenir le catalogue produits et les fournisseurs (web) | O | — | — | O | — | — |
| Voir le catalogue et les noms de fournisseurs | O | O | O | O | O | O |

Direction n'a aucun bouton d'écriture. L'action de l'Admin est toujours tracée (qui, quand).

## User stories

### US-MAT-001 : Signaler un besoin de matériau  ·  Indispensable
En tant que chef d'équipe ou chef de chantier, je veux signaler un besoin en 4 gestes, même sans réseau, afin que le conducteur le voie avant que le chantier s'arrête.

**Critères d'acceptation**
- CA-MAT-001.1 (nominal) : Étant donné que je suis ChefChantier sur « École UV18 » (chantier courant, dernière zone « Bloc 01 · +10,20 m »), quand j'appuie sur « + Demande », je touche « Ciment CPJ 42,5 », je tape 300 puis j'appuie sur « Envoyer »,
  alors la demande existe avec l'unité **sac** (défaut du produit), la zone par défaut, « pour le » = aujourd'hui + 3 jours, urgence Normale, statut **Demandée**, mon nom comme demandeur ; après envoi elle reçoit son numéro (`DEM-014` par exemple).
- CA-MAT-001.2 (rapidité) : Depuis l'accueil du chantier courant, le cas nominal prend **4 gestes** et moins de 30 s ; changer la zone (pastilles des 3 dernières zones), la date (pastilles « Demain · +3 j · Semaine prochaine · Autre date ») ou l'urgence coûte **1 geste** chacune ;
  au plus 6 gestes quand deux valeurs changent. Une zone hors des 3 dernières passe par le sélecteur du socle (3 gestes au plus). Comptage : un appui ou une saisie au clavier numérique = 1 geste.
- CA-MAT-001.3 (équivalence) : Dès que je tape la quantité, l'écran affiche l'équivalent en masse quand le produit s'y prête : « 300 sacs = 15 T » ; « 15 sacs = 750 kg ». Une faute de frappe (3000 au lieu de 300) saute aux yeux. Aucune équivalence pour m³, u, L.
- CA-MAT-001.4 (hors ligne) : Étant donné qu'il n'y a pas de réseau, quand j'appuie sur « Envoyer », alors la demande est gardée sur le téléphone, marquée « En attente d'envoi », avec « DEM · numéro en attente » et mon heure de saisie ; elle est visible dans « Mes demandes » et dans « Envois en attente ». Aucun message d'échec.
- CA-MAT-001.5 (unité manquante) : L'unité est une liste de pastilles (jamais un texte libre). Pour un produit du catalogue elle est préremplie ; pour « Autre produit » aucune n'est préchoisie et « Envoyer » reste inactif tant qu'aucune n'est choisie (code `UNITE_OBLIGATOIRE` si le serveur reçoit une demande sans unité).
- CA-MAT-001.6 (quantité) : Une quantité vide, 0 ou négative est refusée (`QUANTITE_INVALIDE`). « 2,5 » et « 2.5 » sont acceptés pour kg, T, m³, L ; une unité `sac` ou `u` avec décimale est refusée avec « Nombre entier requis ». Au plus 3 décimales.
- CA-MAT-001.7 (date) : « Pour le » se choisit par pastilles ou calendrier, jamais au clavier. Une date incomplète ou impossible reçue par le serveur (`../12/2026`, `31/11/2026`) est refusée (`DATE_INVALIDE`). Une date passée donne l'avertissement « Cette date est passée » avec « Envoyer quand même » : pas de blocage.
- CA-MAT-001.8 (double appui, renvoi) : Deux appuis sur « Envoyer » créent **une** demande. Une demande renvoyée deux fois par un mauvais réseau n'existe qu'une fois et ne consomme qu'**un** numéro.
- CA-MAT-001.9 (doublon possible) : Étant donné une demande ouverte `DEM-012` pour le même produit et la même zone, quand j'enregistre la mienne, alors un avertissement non bloquant propose « Voir DEM-012 » ou « C'est une autre demande ». Si le doublon n'est connu qu'à l'arrivée sur le serveur, la demande est créée et le conducteur voit « Doublon possible de DEM-012 ».
- CA-MAT-001.10 (autre matériau) : Après l'envoi, « Ajouter un autre matériau » rouvre le formulaire avec le même chantier, la même zone, la même date et la même urgence ; il faut choisir le produit et la quantité (3 gestes de plus).
- CA-MAT-001.11 (produit libre) : « Autre produit » demande un nom (de 3 à 100 caractères) et une unité de la liste. La demande est acceptée ; les Achats pourront la rattacher à un produit du catalogue.
- CA-MAT-001.12 (grande liste de produits) : Avec 300 produits, les 6 produits les plus demandés sur ce chantier sont des tuiles ; une recherche tolérante aux abréviations et accents (« cim », « ha 12 », « brik 12 ») répond en moins de 2 s, sans réseau.
- CA-MAT-001.13 (mauvais rôle) : Le bouton « + Demande » n'existe pas pour Achats ni Direction ; le serveur refuse aussi (`INTERDIT`) et rien n'est enregistré.
- CA-MAT-001.14 (mauvais chantier) : Un chantier non affecté est « introuvable ». Une zone d'un autre chantier est refusée (« Cette zone n'appartient pas à ce chantier »). Un chantier archivé refuse la saisie (`CHANTIER_ARCHIVE`) ; hors ligne, la demande part dans « À vérifier » avec ce motif.
- CA-MAT-001.15 (arabe, soleil) : Tous les libellés, noms de produits et unités existent en arabe ; numéros, quantités, cotes et dates restent de gauche à droite. Boutons principaux de 56 dp, texte d'au moins 16 sp, urgence et statut en icône **et** texte.

### US-MAT-002 : Suivre mes demandes et leur statut  ·  Indispensable
En tant que chef d'équipe, je veux voir où en sont mes demandes afin de savoir si le ciment arrive avant la coulée.

**Critères d'acceptation**
- CA-MAT-002.1 (nominal) : « Demandes » affiche par défaut les demandes **à suivre** du chantier courant (Demandée, Validée, Commandée, Livrée partiellement, Livrée), triées Bloquante, Urgente, Normale, puis par date de besoin croissante.
  Chaque ligne : numéro (ou « numéro en attente »), produit, quantité **avec unité**, zone, « pour le », urgence et statut (icône et texte).
- CA-MAT-002.2 (détail) : Le détail montre l'historique (statut, qui, quand, motif), puis la commande (fournisseur, livraison prévue), puis les livraisons liées avec **reçu cumulé, reste à livrer et écart**. Les prix n'y figurent que pour les rôles autorisés (US-MAT-009).
- CA-MAT-002.3 (hors ligne) : Sans réseau, la liste et le détail s'affichent en moins de 2 s à partir du téléphone avec « Données du JJ/MM/AAAA HH:MM » ; les demandes en attente d'envoi portent la marque « En attente d'envoi ».
- CA-MAT-002.4 (retard) : Une demande non encore Livrée dont « pour le » est dépassé affiche « En retard de N j » (N = aujourd'hui − date de besoin, voir calculs). « Pour le » du jour : pas de retard.
- CA-MAT-002.5 (filtres) : Pastilles : À suivre · Terminées (Réceptionnée) · Refusées et annulées · Archivées. Un filtre « Mes demandes » est actif par défaut pour un ChefEquipe, « Toutes » pour les autres.
- CA-MAT-002.6 (recherche) : Chercher « DEM-014 » ou « cim » retrouve la demande ; la recherche reste dans les chantiers affectés, et chaque résultat affiche le code du chantier (deux chantiers ont chacun un `DEM-001`).
- CA-MAT-002.7 (rôles) : Un ChefEquipe voit toutes les demandes de son chantier (sans prix) mais n'agit que sur les siennes ; la Direction consulte sans bouton d'action.
- CA-MAT-002.8 (mauvais chantier) : Un chantier non affecté n'apparaît ni dans la liste, ni dans la recherche, ni dans les messages ; l'ouvrir par lien donne « introuvable ».
- CA-MAT-002.9 (grande liste) : Avec 500 demandes sur un chantier, les 20 premières s'affichent en moins de 2 s et la liste se charge au fil du défilement ; sur le web, pagination et tri par colonne.
- CA-MAT-002.10 (unité) : Aucune quantité n'est jamais affichée sans son unité, dans la liste, le détail, les messages et les totaux.

### US-MAT-003 : Valider ou refuser une demande  ·  Indispensable
En tant que conducteur de travaux, je veux valider ou refuser en 2 gestes, même en déplacement, afin que les Achats commandent sans attendre.

**Critères d'acceptation**
- CA-MAT-003.1 (nominal) : « À valider » liste les demandes Demandée de mes chantiers, urgence puis date de besoin. Je touche une demande, puis **« Valider »** : 2 gestes ; elle passe à **Validée** avec mon nom et l'heure du serveur.
- CA-MAT-003.2 (refus) : « Refuser » ouvre une liste de motifs (Déjà commandé · Stock suffisant sur le chantier · Quantité à revoir · Hors budget · Autre) ; « Autre » impose une remarque. Sans motif : refus impossible. Statut **Refusée**, demandeur informé à sa prochaine synchronisation.
- CA-MAT-003.3 (ajustement) : « Valider avec une autre quantité » permet de baisser ou d'augmenter la quantité (même unité, non modifiable). L'ancienne et la nouvelle quantité sont conservées dans l'historique (« 300 sacs → 200 sacs ») et visibles du demandeur. Quantité ≤ 0 : `QUANTITE_INVALIDE`.
- CA-MAT-003.4 (hors ligne) : Sans réseau, ma validation ou mon refus est gardé sur le téléphone : la demande affiche « Validation en attente d'envoi » et reste **Demandée** pour tous les autres tant que le serveur ne l'a pas acceptée.
- CA-MAT-003.5 (conflit à l'envoi) : Étant donné que le demandeur a annulé la demande pendant que j'étais hors ligne, quand ma validation arrive, alors elle est mise dans « À vérifier » avec « Demande annulée par le demandeur avant votre validation » ; le serveur garde l'état Annulée.
- CA-MAT-003.6 (double action) : Deux appuis sur « Valider », ou deux conducteurs qui valident la même demande, donnent une seule validation ; la seconde reçoit « Déjà validée », sans erreur. Valider une demande Refusée, Annulée ou déjà Commandée : `TRANSITION_INTERDITE`.
- CA-MAT-003.7 (mauvais rôle) : Les boutons Valider, Refuser et l'ajustement n'existent que pour ConducteurTravaux (et Admin) ; un ChefChantier ou ChefEquipe qui force l'appel reçoit `INTERDIT`.
- CA-MAT-003.8 (mauvais chantier) : Je ne vois et ne valide que les demandes de mes chantiers ; un chantier non affecté est « introuvable ».
- CA-MAT-003.9 (grande liste) : Avec 80 demandes à valider, je filtre par chantier, urgence, produit et zone. Sur le web, je sélectionne jusqu'à 50 demandes et j'appuie sur « Valider » : chacune est validée et tracée **individuellement** ; celles qui ne peuvent pas l'être sont listées avec leur motif.

### US-MAT-004 : Corriger ou annuler ma demande  ·  Indispensable
En tant que chef d'équipe, je veux corriger ou annuler une demande faite par erreur afin de ne pas faire commander pour rien.

**Critères d'acceptation**
- CA-MAT-004.1 (nominal) : Tant qu'une demande est **Demandée**, son auteur peut modifier produit, quantité, unité, zone, date, urgence et remarque ; le ChefChantier et le ConducteurTravaux le peuvent pour toutes les demandes du chantier. L'historique garde « ancienne → nouvelle valeur ».
- CA-MAT-004.2 (verrouillage) : Après validation, produit, quantité et unité ne se modifient plus : message « Demande validée : la quantité et le produit ne se modifient plus. Annulez-la et créez-en une nouvelle. » (`DEMANDE_VERROUILLEE`) avec le bouton « Annuler et recréer », qui préremplit une nouvelle demande.
- CA-MAT-004.3 (date, urgence) : Jusqu'à « Livrée », le ChefChantier et le ConducteurTravaux peuvent changer « pour le », l'urgence et la remarque ; les Achats voient le changement dans leur liste. Les mêmes validations de date (`DATE_INVALIDE`) et de quantité (`QUANTITE_INVALIDE`) s'appliquent.
- CA-MAT-004.4 (annuler) : « Annuler » est possible en statut Demandée ou Validée, par le demandeur ou le ConducteurTravaux, avec un motif de la liste (Erreur de saisie · Plus besoin · Doublon · Autre). Statut **Annulée** ; le numéro n'est jamais réutilisé.
- CA-MAT-004.5 (déjà commandée) : Annuler une demande Commandée, Livrée partiellement ou Livrée est refusé (`TRANSITION_INTERDITE`) avec « Contactez les Achats ».
- CA-MAT-004.6 (hors ligne) : Sans réseau, je corrige ou j'annule ; l'action part à la prochaine synchronisation. Corriger une demande **jamais envoyée** modifie simplement la saisie en attente, sans conflit possible.
- CA-MAT-004.7 (doublon) : Deux appuis sur « Annuler » donnent une seule annulation et un seul motif.
- CA-MAT-004.8 (mauvais rôle) : Un ChefEquipe ne modifie ni n'annule la demande d'un collègue (boutons absents, serveur `INTERDIT`) ; Achats et Direction n'ont aucun de ces boutons.
- CA-MAT-004.9 (mauvais chantier) : Modifier ou annuler une demande d'un chantier non affecté : « introuvable ».

### US-MAT-005 : Commander auprès d'un fournisseur  ·  Indispensable
En tant qu'acheteur, je veux transformer une demande validée en commande afin de savoir ce qui est commandé, chez qui, pour quand et pour combien.

**Critères d'acceptation**
- CA-MAT-005.1 (liste) : « À commander » liste les demandes **Validée** de mes chantiers, urgence puis date de besoin, avec les totaux par produit et unité (US-MAT-013).
- CA-MAT-005.2 (nominal) : Je touche « Commander » : fournisseur = dernier fournisseur utilisé pour ce produit, date de commande = aujourd'hui, **quantité et unité identiques à la demande et non modifiables**. J'enregistre : statut **Commandée**, fournisseur et date de livraison prévue visibles du chantier (sans prix pour le terrain).
- CA-MAT-005.3 (montant) : Le prix unitaire hors taxes se saisit **par unité de commande** (l'unité s'affiche à côté du champ et ne se tape pas) ; le montant est calculé par le serveur : 300 sacs × 780,00 DZD = **234 000,00 DZD**. Arrondi « loin de zéro » ; le total n'additionne que des DZD.
- CA-MAT-005.4 (champs) : Fournisseur obligatoire. Prix : facultatif à la commande (« À renseigner »), mais s'il est donné il est supérieur à 0. Date de commande : complète, pas dans le futur (`DATE_INVALIDE`). Livraison prévue : complète et pas avant la date de commande ; si elle dépasse la date de besoin de N jours, avertissement « Livraison prévue N j après le besoin », sans blocage.
- CA-MAT-005.5 (doublon) : Deux appuis sur « Enregistrer » créent une commande. Commander une demande déjà commandée : refusé (`COMMANDE_EXISTANTE`) avec « Déjà commandée ».
- CA-MAT-005.6 (modifier) : Tant que la demande n'est pas Livrée, les Achats modifient fournisseur, date prévue, prix, n° de bon de commande ; la quantité et l'unité restent verrouillées. Changer le prix recalcule montant et valeur reçue ; l'historique garde l'ancienne valeur.
- CA-MAT-005.7 (annuler sans livraison) : Étant donné une commande sans aucune livraison, quand j'appuie sur « Annuler la commande » avec un motif (Fournisseur indisponible · Prix refusé · Autre), alors la demande repasse à **Validée** et réapparaît dans « À commander » (extension au référentiel : Q-MAT-01). Avec au moins une livraison, c'est refusé (`TRANSITION_INTERDITE`).
- CA-MAT-005.8 (réseau) : Sans réseau, le bouton « Commander » du mobile affiche « Réseau nécessaire pour commander » ; rien ne part, rien ne se perd (H-MAT-04).
- CA-MAT-005.9 (mauvais rôle) : Seuls Achats et Admin commandent ; le ConducteurTravaux voit la commande mais n'a pas le bouton ; le serveur refuse (`INTERDIT`). Commander une demande qui n'est pas Validée : `TRANSITION_INTERDITE`.
- CA-MAT-005.10 (mauvais chantier) : Commander pour un chantier non affecté : « introuvable ».
- CA-MAT-005.11 (grande liste) : Avec 300 demandes validées, filtres par chantier, produit, urgence, zone ; la liste s'affiche par pages ; la recherche répond en moins de 2 s.
- CA-MAT-005.12 (visibilité) : ChefChantier et ChefEquipe voient fournisseur, date prévue et statut, **jamais** prix, montant ni n° de bon de commande (US-MAT-009).

### US-MAT-006 : Recevoir un camion et enregistrer la livraison  ·  Indispensable
En tant que chef de chantier, je veux enregistrer une livraison en quelques gestes, à la porte du chantier, afin de savoir ce qui est arrivé et ce qui reste à livrer.

**Critères d'acceptation**
- CA-MAT-006.1 (nominal) : « À recevoir » liste les commandes attendues (Commandée ou Livrée partiellement), date prévue la plus proche en premier. Je touche la commande : le formulaire s'ouvre avec produit, fournisseur, **quantité = reste à livrer**, **unité de la commande**, date = aujourd'hui. « Enregistrer » crée la livraison `LIV-nnn`.
- CA-MAT-006.2 (rapidité) : Depuis l'accueil du chantier : tuile « À recevoir », commande, « Enregistrer » = **3 gestes** si la quantité reçue est le reste ; avec la photo du bon : **6 gestes** ; une quantité différente ajoute 1 geste. À simplifier si le test terrain dépasse 30 s.
- CA-MAT-006.3 (complète, partielle, surplus) : L'écran dit en toutes lettres avant l'enregistrement : « Livraison partielle : il restera 100 sacs » · « Livraison complète » · « Surplus de +20 sacs (+5,00 %) ». Après l'enregistrement, le détail de la demande affiche reçu cumulé, reste et écart (règles de calcul).
- CA-MAT-006.4 (unité) : Je peux recevoir en T un ciment commandé en sacs : « 10 T = 200 sacs » s'affiche et le total se calcule dans l'unité de la commande. Une unité non convertible (sable commandé en m³, livré en T) est refusée : `UNITES_INCOMPATIBLES`, avec « Saisissez en m³, l'unité de la commande ». Aucune addition d'unités différentes.
- CA-MAT-006.5 (quantité, date) : Quantité ≤ 0 : `QUANTITE_INVALIDE` ; `sac` ou `u` avec décimale refusé. Date de livraison par calendrier uniquement ; incomplète : `DATE_INVALIDE` ; dans le futur : `DATE_INVALIDE` avec « La date de livraison ne peut pas être dans le futur ». Une date antérieure à la demande : avertissement seulement.
- CA-MAT-006.6 (conformité) : « Conforme » est préchoisi. « Avec réserve » ouvre une liste (Quantité manquante · Produit abîmé · Mauvais produit · Autre) ; la réserve est visible des Achats et du conducteur dans « À traiter ».
- CA-MAT-006.7 (hors ligne) : Sans réseau, la livraison est gardée sur le téléphone avec « LIV · numéro en attente », prise en compte tout de suite dans l'affichage **provisoire** de la demande (marqué « à confirmer ») ; le serveur recalcule à l'envoi (US-MAT-010).
- CA-MAT-006.8 (double appui) : Deux appuis sur « Enregistrer » créent une seule livraison et un seul numéro.
- CA-MAT-006.9 (même BL deux fois) : Étant donné un BL déjà saisi pour le même fournisseur, le même chantier et le même produit, quand je saisis le même n° de BL, alors un avertissement propose « Voir LIV-006 » ou « C'est une autre livraison » ; le serveur signale le doublon possible aux Achats sans le refuser.
- CA-MAT-006.10 (mauvais rôle) : « + Livraison » n'existe ni pour ChefEquipe, ni pour Direction ; le serveur refuse (`INTERDIT`).
- CA-MAT-006.11 (mauvais chantier) : On ne choisit que des commandes des chantiers affectés ; relier une livraison à la demande d'un autre chantier : « introuvable ». Chantier archivé : `CHANTIER_ARCHIVE`.
- CA-MAT-006.12 (grande liste) : Avec 100 commandes à recevoir, recherche par fournisseur, produit ou numéro, et filtre « Aujourd'hui · Cette semaine · En retard ».
- CA-MAT-006.13 (suite) : Quand la livraison complète la commande, l'écran propose « DEM-014 est livrée. Réceptionner maintenant ? » (US-MAT-008).

### US-MAT-007 : Garder la preuve : n° et photo du bon de livraison  ·  Indispensable
En tant que chef de chantier, je veux photographier le bon de livraison afin d'avoir une preuve en cas de litige sur la quantité ou le prix.

**Critères d'acceptation**
- CA-MAT-007.1 (nominal) : « Photographier le bon » ouvre l'appareil photo en 1 geste ; après la prise, je vois la vignette avec « Reprendre » et « Garder ». La photo est liée à la livraison (et seulement à elle).
- CA-MAT-007.2 (hors ligne) : La livraison est valable **sans** que la photo soit partie : « Photo en attente d'envoi (2) » s'affiche dans « Envois en attente ». La photo ne se perd pas si l'envoi échoue ; elle part dès que le réseau le permet, une à la fois.
- CA-MAT-007.3 (plusieurs) : Je peux ajouter jusqu'à 5 photos (recto, verso, bon signé). Une sixième est refusée avec « 5 photos au maximum ».
- CA-MAT-007.4 (renvoi) : Une photo renvoyée après coupure n'apparaît qu'une fois.
- CA-MAT-007.5 (fichier invalide) : Un fichier qui n'est pas une image, ou trop lourd après réduction, est refusé avec un message clair (cible de 1 à 2 Mo par photo, ADR 0004).
- CA-MAT-007.6 (n° de BL) : Le n° de BL est un texte court (30 caractères au plus), mis en majuscules, sans espace en début ni en fin. Facultatif.
- CA-MAT-007.7 (BL manquant) : Une livraison sans n° de BL **et** sans photo porte le badge « BL manquant » et figure dans « À compléter » des Achats ; on peut compléter plus tard, jusqu'à la réception de la demande.
- CA-MAT-007.8 (droits) : Les photos de bons sont visibles selon le tableau des droits ; un ChefEquipe ne voit pas les photos de bons (elles peuvent montrer des prix). Les photos déjà envoyées ne sont pas stockées en entier sur le téléphone : elles se chargent à la demande, avec réseau.
- CA-MAT-007.9 (mauvais chantier) : Une photo n'est accessible qu'aux utilisateurs affectés au chantier de la livraison.
- CA-MAT-007.10 (grande liste) : Une livraison avec 5 photos se charge sans bloquer l'écran ; une journée de 30 livraisons en attente (150 photos) part par petits lots, sans figer l'application.

### US-MAT-008 : Statut automatique, réception et solde  ·  Indispensable
En tant que chef de chantier, je veux que le statut de la demande suive les livraisons, puis la clore d'un geste afin que la liste ne montre que ce qui reste à faire.

**Critères d'acceptation**
- CA-MAT-008.1 (règle) : Pour une demande commandée, avec Qc la quantité commandée et Qr le reçu cumulé (livraisons non annulées, converties dans l'unité de la commande) : Qr = 0 → **Commandée** ; 0 < Qr < Qc → **Livrée partiellement** ; Qr ≥ Qc → **Livrée**. Le serveur fait foi (cas chiffrés en calculs.md §8).
- CA-MAT-008.2 (recalcul) : Quand une livraison est ajoutée, corrigée ou annulée, le statut se recalcule tout de suite, dans les deux sens, **tant que la demande n'est pas Réceptionnée** ; chaque changement est historisé (« Recalcul suite à l'annulation de LIV-006 »).
- CA-MAT-008.3 (réceptionner) : Sur une demande **Livrée**, le ChefChantier appuie sur « Réceptionner » (1 geste, remarque facultative) : statut **Réceptionnée**. Aussi proposé dans « À réceptionner » et à la fin d'une livraison complète.
- CA-MAT-008.4 (interdits) : Réceptionner une demande qui n'est pas Livrée : `TRANSITION_INTERDITE`. Le ConducteurTravaux et les Achats n'ont pas ce bouton.
- CA-MAT-008.5 (solder) : Sur une demande **Livrée partiellement**, les Achats ou le ConducteurTravaux peuvent « Solder » avec un motif (Le fournisseur ne livrera pas le reste · Quantité suffisante · Autre) : la demande passe à **Livrée** avec « manque : −10 sacs (−2,50 %) » (extension au référentiel, Q-MAT-01). Sans livraison du tout : refusé, utiliser l'annulation de commande.
- CA-MAT-008.6 (surplus) : Si Qr > Qc, la demande est Livrée avec « Surplus +0,4 T (+2,00 % de 20 T) » visible des Achats et du chantier ; aucun blocage, mais le surplus est listé dans « À traiter ».
- CA-MAT-008.7 (tolérance) : Avec une tolérance paramétrée à 1 %, une livraison de 19,85 T pour 20 T (−0,75 %) rend la demande Livrée ; avec la tolérance par défaut (0 %), elle reste Livrée partiellement avec 0,15 T à livrer.
- CA-MAT-008.8 (hors ligne) : « Réceptionner » marche sans réseau. Si, à l'envoi, une livraison annulée entre-temps a fait repasser la demande à Livrée partiellement, l'action est mise dans « À vérifier » : « La demande n'est plus complète ».
- CA-MAT-008.9 (mauvais rôle, chantier) : Un ChefEquipe n'a aucun bouton de statut ; un chantier non affecté est « introuvable ».
- CA-MAT-008.10 (après réception) : Une demande Réceptionnée n'accepte plus de livraison ni de correction (`DEMANDE_NON_OUVERTE`) ; une livraison qui arrive ensuite est enregistrée « non rattachée » (US-MAT-011).

### US-MAT-009 : Chacun ne voit que ce qui le concerne  ·  Indispensable
En tant que direction, je veux que les prix et les contacts des fournisseurs ne soient vus que par les bons rôles afin de protéger les négociations d'achat.

**Critères d'acceptation**
- CA-MAT-009.1 (matrice) : Pour chacun des 6 rôles, les actions du tableau « Droits par rôle » sont possibles et celles marquées « — » sont **absentes** de l'écran (bouton non affiché, pas seulement grisé).
- CA-MAT-009.2 (côté serveur) : Un rôle qui force une action interdite reçoit `INTERDIT` et rien n'est enregistré ; un chantier non affecté donne « introuvable », **identique** à un chantier inexistant, pour demandes, commandes, livraisons, photos, listes, recherches et exports.
- CA-MAT-009.3 (prix) : Pour ChefChantier et ChefEquipe, prix unitaire, montant de commande et valeur reçue sont **absents des réponses du serveur et du stockage du téléphone** (pas seulement cachés à l'écran), y compris dans les listes, les exports et les messages.
- CA-MAT-009.4 (téléphone du fournisseur) : Absent pour ChefEquipe et Direction, présent pour Admin, Achats, ConducteurTravaux et ChefChantier sur ses chantiers ; **jamais** dans les journaux techniques ni dans les messages d'erreur.
- CA-MAT-009.5 (changement de rôle) : Si un Admin retire un droit à un utilisateur qui a déjà saisi hors ligne, les saisies qui ne sont plus permises sont refusées avec le motif dans « À vérifier » ; les autres passent (même règle que CA-003.3 du socle).
- CA-MAT-009.6 (Direction) : La Direction voit prix et montants des chantiers affectés et n'a aucun bouton d'écriture.
- CA-MAT-009.7 (traçabilité) : Chaque demande, commande, livraison, transition et correction garde qui, quand (heure du serveur) et, pour une saisie hors ligne, l'heure du téléphone à part (« saisi le »).
- CA-MAT-009.8 (grande liste) : N/A : aucune liste propre à cette histoire.

### US-MAT-010 : Envoyer sans perte, et trancher les conflits  ·  Indispensable
En tant que chef de chantier, je veux que ma journée hors ligne parte correctement, et que, si le serveur a changé entre-temps, on me dise clairement ce qui a été retenu.

**Critères d'acceptation**
- CA-MAT-010.1 (nominal) : Étant donné 20 demandes et 5 livraisons saisies pendant 3 jours sans réseau, quand le réseau revient, alors tout part par lots dans l'ordre de saisie ; chaque élément existe **une seule fois** ; les numéros se suivent dans l'ordre d'arrivée au serveur (`DEM-015`, `DEM-016`…) ; « À jour » s'affiche avec l'heure.
- CA-MAT-010.2 (demande validée pendant mon édition hors ligne) : Étant donné une demande Demandée que je modifie hors ligne (300 → 400 sacs) et que le conducteur a **validée** entre-temps, quand ma modification arrive, alors elle n'est **pas appliquée** (le serveur garde la validation) et l'écran « À vérifier » montre côte à côte « Votre version : 400 sacs » et « Version du serveur : 300 sacs, validée ».
  Deux choix : **« Garder la version du serveur »** ; **« Créer une nouvelle demande avec mes valeurs »** (préremplie). Rien n'est supprimé sans mon choix.
- CA-MAT-010.3 (annulée ou refusée entre-temps) : Même règle si la demande est devenue Annulée, Refusée ou Commandée : le serveur gagne, ma modification va dans « À vérifier » avec le statut actuel.
- CA-MAT-010.4 (même champ modifié par deux personnes) : Si le ChefChantier et le conducteur changent chacun la date de besoin hors ligne avec deux valeurs différentes, la première arrivée est retenue et la seconde va dans « À vérifier » avec « Date modifiée par une autre personne » et les deux valeurs.
- CA-MAT-010.5 (champs différents) : Si l'un change la date et l'autre l'urgence, les deux modifications sont appliquées sans message.
- CA-MAT-010.6 (livraison sur une demande clôturée) : Étant donné une livraison saisie hors ligne pour DEM-014 qui est devenue Annulée ou Réceptionnée, quand elle arrive, alors elle est **enregistrée** (c'est un fait de chantier), marquée « non rattachée » avec le motif, et signalée aux Achats et au conducteur dans « À traiter ».
- CA-MAT-010.7 (livraison avant commande) : Étant donné une livraison saisie pour une demande encore **Validée** (les Achats ont commandé au téléphone sans l'enregistrer), alors elle est enregistrée et **retenue** : la demande reste Validée avec le badge « Livraison reçue sans commande enregistrée ». Quand les Achats enregistrent la commande, le statut se calcule aussitôt à partir des livraisons (Commandée puis Livrée partiellement ou Livrée, les deux étapes historisées).
- CA-MAT-010.8 (chantier retiré, compte désactivé) : Les saisies d'un chantier qui ne m'est plus affecté vont dans « À vérifier » avec le motif et ne sont jamais perdues en silence (CA-002.6 du socle).
- CA-MAT-010.9 (renvoi) : Toute saisie renvoyée avec le même identifiant unique renvoie la ressource existante sans erreur ni nouveau numéro.
- CA-MAT-010.10 (ordre) : Pour une même demande, la création part avant la modification, qui part avant l'annulation, même si l'envoi a été interrompu.
- CA-MAT-010.11 (affichage provisoire) : Tant que le serveur n'a pas répondu, les statuts calculés sur le téléphone portent « à confirmer » ; à la réponse, la valeur du serveur remplace la mienne sans que je doive intervenir.
- CA-MAT-010.12 (grande file) : Avec 200 saisies en attente (demandes, livraisons, photos), l'envoi se fait par lots, la liste « Envois en attente » reste fluide et chaque saisie garde son ordre de création.
- CA-MAT-010.13 (confidentialité) : Aucun prix n'est écrit sur le téléphone d'un ChefChantier ou d'un ChefEquipe, même en cas de conflit ou d'erreur.
- CA-MAT-010.14 (heure) : Le serveur décide avec l'ordre d'arrivée et son horloge ; l'heure du téléphone ne sert qu'à l'information « saisi le ».

### US-MAT-011 : Enregistrer une livraison sans demande, puis la rattacher  ·  Important
En tant que chef de chantier, je veux enregistrer un camion arrivé sans demande connue afin de ne pas perdre la trace de ce qui est entré sur le chantier.

**Critères d'acceptation**
- CA-MAT-011.1 (nominal) : « + Livraison » sans choisir de demande propose produit, fournisseur (liste, ou « Autre fournisseur » en nom libre), quantité, unité (liste), date (aujourd'hui). La livraison est enregistrée avec le badge **« Non rattachée »**.
- CA-MAT-011.2 (rattacher) : Le ChefChantier, le ConducteurTravaux ou les Achats ouvrent la livraison, touchent « Rattacher » et choisissent une demande **Commandée, Livrée partiellement ou Validée** du même chantier et du même produit ; les statuts se recalculent.
- CA-MAT-011.3 (règles) : Produit différent : refusé (`PRODUIT_DIFFERENT`). Unité non convertible vers l'unité de la commande : `UNITES_INCOMPATIBLES`. Demande Annulée, Refusée ou Réceptionnée : `DEMANDE_NON_OUVERTE`. Une livraison ne se rattache qu'à une seule demande (H-MAT-23).
- CA-MAT-011.4 (hors ligne) : Création hors ligne comme US-MAT-006 ; le rattachement se fait avec réseau (web ou mobile connecté).
- CA-MAT-011.5 (doublon) : Mêmes règles que CA-MAT-006.8 et CA-MAT-006.9.
- CA-MAT-011.6 (unité, date) : Mêmes règles que CA-MAT-006.4 et CA-MAT-006.5 ; unité obligatoire (`UNITE_OBLIGATOIRE`).
- CA-MAT-011.7 (mauvais rôle, chantier) : ChefEquipe sans bouton ; chantier non affecté « introuvable ».
- CA-MAT-011.8 (grande liste) : Le filtre « Non rattachées » (web et mobile) liste les livraisons à traiter, avec recherche par produit et fournisseur ; 200 lignes s'affichent par pages.

### US-MAT-012 : Corriger ou annuler une livraison  ·  Important
En tant que chef de chantier, je veux corriger une quantité mal saisie afin que les totaux restent justes.

**Critères d'acceptation**
- CA-MAT-012.1 (corriger) : Le ChefChantier, le ConducteurTravaux et les Achats peuvent modifier quantité, unité, date, n° de BL, conformité d'une livraison tant que sa demande n'est pas Réceptionnée. L'historique garde « ancienne → nouvelle valeur », qui, quand ; le numéro `LIV-nnn` ne change pas.
- CA-MAT-012.2 (annuler) : « Annuler la livraison » exige un motif (Saisie en double · Erreur de quantité · Refusée à la réception · Autre). Elle reste visible, barrée, et **n'entre plus dans aucun total** ; son numéro n'est pas réutilisé.
- CA-MAT-012.3 (recalcul) : Après correction ou annulation, le reçu cumulé, le reste, l'écart et le statut de la demande se recalculent immédiatement (exemple : annuler LIV-008 ramène DEM-005 de Livrée à Livrée partiellement, 400 sacs reçus sur 600).
- CA-MAT-012.4 (après réception) : Sur une demande Réceptionnée, correction et annulation sont refusées (`DEMANDE_NON_OUVERTE`).
- CA-MAT-012.5 (hors ligne) : Corriger ou annuler marche sans réseau ; conflit avec une autre correction : règles de US-MAT-010 (même champ : première arrivée retenue).
- CA-MAT-012.6 (doublon) : Deux appuis sur « Annuler » donnent une seule annulation.
- CA-MAT-012.7 (unité, date) : Les validations de quantité, d'unité et de date (pas dans le futur) sont celles de US-MAT-006 ; changer pour une unité non convertible : `UNITES_INCOMPATIBLES`.
- CA-MAT-012.8 (mauvais rôle, chantier) : ChefEquipe et Direction sans bouton ; chantier non affecté « introuvable ».
- CA-MAT-012.9 (grande liste) : N/A : la correction porte sur une livraison à la fois.

### US-MAT-013 : Suivre ce qui reste à valider, commander, recevoir et réceptionner  ·  Important
En tant qu'acheteur ou conducteur de travaux, je veux un tableau clair par chantier afin de ne rien oublier.

**Critères d'acceptation**
- CA-MAT-013.1 (nominal) : Sur le web, cinq vues par chantier, avec compteurs : **À valider** (Demandée), **À commander** (Validée), **Attendues** (Commandée et Livrée partiellement, date prévue), **En retard** (date prévue dépassée sans livraison complète, ou date de besoin dépassée), **À réceptionner** (Livrée).
- CA-MAT-013.2 (totaux par produit et unité) : « À commander » additionne par produit et par unité, dans la famille convertible : 100 sacs + 5 T + 200 sacs de ciment = **400 sacs (= 20 T)** ; 2 T + 500 kg de rond HA Ø12 = **2,5 T**.
- CA-MAT-013.3 (unités différentes) : Des unités non convertibles ne s'additionnent **jamais** : 24 m³ et 10 T de sable donnent deux lignes ; des produits différents (Ø10 et Ø12) donnent des lignes différentes.
- CA-MAT-013.4 (montants) : Pour Admin, Direction, ConducteurTravaux et Achats : montant commandé, valeur reçue et total par chantier en DZD, 2 décimales, séparateur de milliers. Absents pour les autres rôles.
- CA-MAT-013.5 (retard) : « En retard de 2 j » se calcule en jours calendaires à l'heure d'Algérie (calculs.md §8).
- CA-MAT-013.6 (grande liste) : Avec 1 000 demandes, filtres (chantier, produit, urgence, zone, fournisseur, période), tri, pagination ; réponse en moins de 2 s.
- CA-MAT-013.7 (hors ligne) : Vue web, réseau nécessaire. Sur mobile, « À valider » (conducteur), « À recevoir » (chef de chantier) et « À réceptionner » existent hors ligne, avec « Données du … ».
- CA-MAT-013.8 (mauvais rôle, chantier) : Un chantier non affecté n'apparaît dans aucune vue ni aucun compteur ; ChefEquipe n'a que « Mes demandes ».

### US-MAT-014 : Archiver une demande terminée  ·  Important
En tant que conducteur de travaux, je veux ranger les demandes terminées afin que les listes restent lisibles, sans rien effacer.

**Critères d'acceptation**
- CA-MAT-014.1 (nominal) : Je peux archiver une demande Refusée, Annulée ou Réceptionnée : elle disparaît des listes par défaut, reste consultable (filtre « Archivées »), avec qui, quand.
- CA-MAT-014.2 (interdits) : Archiver une demande ouverte (Demandée, Validée, Commandée, Livrée partiellement, Livrée) : `TRANSITION_INTERDITE`.
- CA-MAT-014.3 (restaurer) : Je peux restaurer une demande archivée ; elle reprend son statut.
- CA-MAT-014.4 (numéros) : Le numéro d'une demande archivée n'est jamais réattribué ; ses livraisons et photos restent liées et consultables.
- CA-MAT-014.5 (hors ligne) : Archiver et restaurer nécessitent le réseau (acte rare, hors ligne non proposé).
- CA-MAT-014.6 (doublon) : Deux appuis donnent un seul archivage.
- CA-MAT-014.7 (mauvais rôle, chantier) : Seuls ConducteurTravaux et Admin ; chantier non affecté « introuvable » ; chantier archivé : lecture seule.
- CA-MAT-014.8 (grande liste) : Sur le web, « Archiver les terminées » sur une sélection de jusqu'à 100 demandes ; chacune est tracée individuellement.

### US-MAT-015 : Tenir le catalogue des matériaux et la liste des fournisseurs  ·  Indispensable
En tant qu'acheteur, je veux tenir la liste des produits et des fournisseurs afin que tout le monde demande et reçoive les mêmes références, avec les bonnes unités.

**Critères d'acceptation**
- CA-MAT-015.1 (produit) : Un produit a un nom français (obligatoire), un nom arabe (facultatif, sinon le nom français s'affiche), une catégorie, au moins une **unité autorisée**, une **unité par défaut** parmi elles, et la **masse d'un sac** (kg) si l'unité `sac` est autorisée (50 pour le ciment CPJ 42,5, 25 pour le monocouche).
- CA-MAT-015.2 (unités) : Les unités se choisissent dans la liste du référentiel (`u`, `ml`, `m2`, `m3`, `kg`, `t`, `sac`, `l`…), jamais en texte libre. `sac` sans masse de sac : refusé. Les produits mesurés en masse ne proposent que `sac`, `kg`, `t` selon leur fiche.
- CA-MAT-015.3 (modifier la masse du sac) : Changer la masse d'un sac **ne change pas** les quantités déjà saisies ; les conversions des livraisons se recalculent avec la masse de la fiche à jour, et l'historique garde l'ancienne valeur. À faire avec confirmation.
- CA-MAT-015.4 (fournisseur) : Un fournisseur a un nom (obligatoire, unique), un téléphone (facultatif, format algérien), les produits fournis (facultatif).
- CA-MAT-015.5 (doublon) : Un nom de produit ou de fournisseur déjà existant : « Existe déjà » (la casse et les espaces ne comptent pas). Deux appuis rapides ne créent qu'un seul enregistrement.
- CA-MAT-015.6 (désactiver) : Un produit ou un fournisseur n'est jamais supprimé : il se **désactive**, ne se propose plus pour les nouvelles saisies, et reste affiché dans l'historique.
- CA-MAT-015.7 (rattacher un produit libre) : Une demande en « Autre produit » peut être reliée à un produit du catalogue par les Achats ; la quantité et l'unité saisies sont conservées et vérifiées (unité autorisée pour ce produit, sinon `UNITES_INCOMPATIBLES`).
- CA-MAT-015.8 (rôles) : Seuls Achats et Admin modifient. Tous les rôles voient produits et noms de fournisseurs ; le téléphone du fournisseur suit CA-MAT-009.4.
- CA-MAT-015.9 (grande liste) : Avec 300 produits et 100 fournisseurs : recherche, filtre par catégorie et par état, pagination ; réponse en moins de 2 s.
- CA-MAT-015.10 (hors ligne) : La gestion se fait sur le web, avec réseau. Le téléphone reçoit produits actifs et noms de fournisseurs à la synchronisation et les garde hors ligne.
- CA-MAT-015.11 (arabe) : Toute catégorie, tout produit livré par défaut et toute unité existent en arabe (voir vocabulaire).

### US-MAT-016 : Données de démonstration « demandes et livraisons »  ·  Indispensable
En tant que testeur ou formateur, je veux un jeu de demandes et de livraisons réaliste sur l'École UV18 afin de démontrer et vérifier toutes les règles.

**Critères d'acceptation**
- CA-MAT-016.1 (nominal) : Après chargement : 13 produits, 5 fournisseurs, 12 demandes et 10 livraisons sur `CH-ECO-UV18`, 1 demande sur `CH-LOG-OL40` (voir « Données de test »).
- CA-MAT-016.2 (répétable) : Charger deux fois ne crée aucun doublon ni aucun trou de numérotation.
- CA-MAT-016.3 (jamais en production) : Mêmes règles que CA-018.3 du socle (développement et démonstration seulement).
- CA-MAT-016.4 (cas à vérifier) : (a) `chef.dev` voit 12 demandes et aucun prix ; (b) `achats.dev` voit les prix ; (c) `nonaffecte.dev` ne voit rien ; (d) `DEM-001` existe sur les deux chantiers sans conflit ; (e) le ciment livré à l'école totalise **110 T = 2 200 sacs** ; (f) `DEM-005` est Livrée et à réceptionner ; (g) `DEM-011` est Livrée partiellement, reste 0,8 T.

## Champs

### Demande
| Champ | Obligatoire | Type / unité | Valeurs possibles | Valeur par défaut |
|---|---|---|---|---|
| Numéro | auto | `DEM-nnn`, par chantier, donné par le serveur | | « numéro en attente » sur le téléphone |
| Chantier | oui | lien | mes chantiers | chantier courant |
| Produit | oui (ou produit libre) | catalogue | produits actifs | aucun ; tuiles des 6 plus demandés |
| Nom du produit libre | oui si « Autre produit » | texte 3 à 100 caractères | | vide |
| Quantité | oui | nombre > 0, 3 décimales ; entier pour `sac` et `u` | | vide (clavier numérique ouvert) |
| Unité | oui | liste | unités autorisées du produit | unité par défaut du produit ; aucune pour un produit libre |
| Zone | non | zone du socle | « Non précisée » possible | dernière zone utilisée |
| Pour le | oui | date complète | pastilles ou calendrier | aujourd'hui + 3 jours (paramétrable) |
| Urgence | oui | liste | Normale · Urgente · Bloquante | Normale |
| Usage ou remarque | non | texte, 200 caractères | | vide |
| Demandeur | auto | utilisateur | | utilisateur connecté |
| Statut | auto | liste | Demandée · Validée · Refusée · Commandée · Livrée partiellement · Livrée · Réceptionnée · Annulée | Demandée |
| Motif | selon transition | liste + remarque | refus, annulation | aucun |
| Saisi le | auto | date et heure du téléphone | information seulement | |
| Archivée | auto | oui / non | | non |

### Commande (une par demande)
| Champ | Obligatoire | Type / unité | Valeurs possibles | Valeur par défaut |
|---|---|---|---|---|
| Demande | oui | lien | demande Validée | demande ouverte à l'écran |
| Fournisseur | oui | liste | fournisseurs actifs | dernier fournisseur utilisé pour ce produit |
| Date de commande | oui | date complète, pas dans le futur | | aujourd'hui |
| Livraison prévue le | non | date complète, pas avant la date de commande | | vide |
| Quantité, unité | auto | identiques à la demande, non modifiables | | |
| Prix unitaire HT | non | DZD, 2 décimales, > 0, **par unité de commande** | | vide (« À renseigner ») |
| Montant HT | calculé | DZD, 2 décimales | | calculé par le serveur |
| N° du bon de commande | non | texte, 50 caractères | | vide |
| Remarque | non | texte | | vide |

### Livraison
| Champ | Obligatoire | Type / unité | Valeurs possibles | Valeur par défaut |
|---|---|---|---|---|
| Numéro | auto | `LIV-nnn`, par chantier, donné par le serveur | | « numéro en attente » |
| Chantier | oui | lien | mes chantiers | chantier courant |
| Demande liée | non | lien | Commandée, Livrée partiellement, Validée | la commande touchée dans « À recevoir » ; sinon vide (« Non rattachée ») |
| Fournisseur | oui | liste ou « Autre fournisseur » (nom libre) | | celui de la commande |
| Produit | oui | catalogue ou nom libre | | celui de la demande |
| Quantité reçue | oui | nombre > 0 ; entier pour `sac` et `u` | | **reste à livrer** |
| Unité | oui | liste : unité de la commande ou convertible | | unité de la commande |
| Date de livraison | oui | date complète, pas dans le futur | | aujourd'hui |
| N° du BL | non | texte, 30 caractères, majuscules | | vide |
| Photos du BL | non | 1 à 5 images | | aucune |
| Conformité | oui | Conforme · Avec réserve | | Conforme |
| Réserve | oui si « Avec réserve » | liste + remarque | Quantité manquante · Produit abîmé · Mauvais produit · Autre | vide |
| Prix unitaire HT | non, rôles « prix » seulement | DZD, 2 décimales | | prix de la commande |
| Reçu par | auto | utilisateur | | utilisateur connecté |
| État | auto | liste | Enregistrée · Annulée (motif) | Enregistrée |
| Saisi le | auto | date et heure du téléphone | information seulement | |

### Produit du catalogue
| Champ | Obligatoire | Type / unité | Valeurs possibles | Valeur par défaut |
|---|---|---|---|---|
| Nom (français) | oui | texte | | |
| Nom (arabe) | non | texte | | vide (nom français affiché) |
| Catégorie | oui | liste | Liants · Acier · Maçonnerie · Granulats · Adjuvants · Second œuvre · Autre | Autre |
| Unités autorisées | oui | une ou plusieurs unités du référentiel | | |
| Unité par défaut | oui | une des unités autorisées | | première unité autorisée |
| Masse d'un sac | oui si `sac` autorisée | kg | | 50 |
| État | oui | actif · désactivé | | actif |

### Fournisseur
| Champ | Obligatoire | Type / unité | Valeurs possibles | Valeur par défaut |
|---|---|---|---|---|
| Nom | oui | texte, unique | | |
| Téléphone | non | texte, format algérien | | vide |
| Produits fournis | non | liste de produits | | vide |
| État | oui | actif · désactivé | | actif |

### Motifs (listes paramétrables, H-MAT-18)
| Cas | Motifs proposés |
|---|---|
| Refus | Déjà commandé · Stock suffisant sur le chantier · Quantité à revoir · Hors budget · Autre |
| Annulation de la demande | Erreur de saisie · Plus besoin · Doublon · Autre |
| Annulation de la commande | Fournisseur indisponible · Prix refusé · Autre |
| Solde | Le fournisseur ne livrera pas le reste · Quantité suffisante · Autre |
| Annulation de la livraison | Saisie en double · Erreur de quantité · Refusée à la réception · Autre |
| Réserve à la réception | Quantité manquante · Produit abîmé · Mauvais produit · Autre |

## Règles de calcul
Ajoutées à `calculs.md` (section 8) avec les cas chiffrés recalculés. Rappel :

1. **Conversions** (seules autorisées) : 1 sac = *m* kg (*m* = masse du sac du produit) ; 1 T = 1 000 kg. Résultat arrondi à 3 décimales, « loin de zéro ».
   - 300 sacs de ciment (50 kg) = 15 000 kg = **15 T** ; 17,5 T = 17 500 kg = **350 sacs** ; 1,2 T de monocouche (25 kg) = **48 sacs** ; 20,26 T de ciment = **405,2 sacs**.
   - Refusées : m³ ↔ T (sable, gravier), L ↔ kg, barre ↔ T : `UNITES_INCOMPATIBLES`.
2. **Reçu cumulé** Qr = somme des livraisons non annulées, chacune convertie dans l'unité de la commande. **Reste** = max(0, Qc − Qr). **Écart** = Qr − Qc ; **écart %** = écart ÷ Qc × 100, 2 décimales.
3. **Statut** : Qr = 0 → Commandée ; 0 < Qr < Qc → Livrée partiellement ; Qr ≥ Qc → Livrée (avec la tolérance paramétrée : |écart %| ≤ tolérance et écart < 0 compte comme complète).
   - DEM-005 : Qc = 600 sacs ; après LIV-006 (10 T = 200 sacs) reste 400 → Livrée partiellement ; après LIV-007 reste 200 → Livrée partiellement ; après LIV-008 reste 0 → **Livrée**.
   - Surplus : commande 20 T, reçu 20,4 T → écart +0,4 T = **+2,00 %**. Manque : commande 400 sacs, reçu 19,5 T = 390 sacs → écart −10 sacs = **−2,50 %**.
4. **Montant** = arrondi à 2 décimales (loin de zéro) de quantité × prix unitaire, dans l'unité de la commande ; **valeur reçue** = somme des valeurs arrondies des livraisons. 300 sacs × 780,00 = **234 000,00 DZD** ; 2,5 kg × 245,25 = 613,125 → **613,13 DZD** (l'arrondi bancaire de .NET donnerait 613,12 : interdit).
5. **Totaux d'un tableau de suivi** : par produit et par unité, additionnés seulement dans la famille convertible ; jamais m² + ml, ni m³ + T.
6. **Retard** = max(0, aujourd'hui − date de besoin ou date prévue), en jours calendaires, heure d'Algérie.
7. **Date de besoin par défaut** = aujourd'hui + 3 jours : 25/11/2026 → **28/11/2026** ; 30/12/2026 → **02/01/2027** ; 28/02/2028 → **02/03/2028** (2028 bissextile).

## Statuts et droits
| Objet | Transition | Qui | Motif | Hors ligne |
|---|---|---|---|---|
| Demande | Demandée → Validée | ConducteurTravaux (Admin) | non (ajustement de quantité tracé) | oui |
| Demande | Demandée → Refusée | ConducteurTravaux (Admin) | **oui** (liste, remarque si Autre) | oui |
| Demande | Demandée ou Validée → Annulée | demandeur ou ConducteurTravaux (Admin) | **oui** | oui |
| Demande | Validée → Commandée | Achats (Admin) | non | non (réseau) |
| Demande | Commandée → Livrée partiellement → Livrée | **automatique** selon les livraisons | non | calculé par le serveur |
| Demande | Livrée partiellement → Livrée (solde) | Achats ou ConducteurTravaux (Admin) | **oui** (extension, Q-MAT-01) | non |
| Demande | Commandée (sans livraison) → Validée | Achats (Admin) | **oui** (extension, Q-MAT-01) | non |
| Demande | Livrée → Réceptionnée | ChefChantier (Admin) | non | oui |
| Demande | terminée (Refusée, Annulée, Réceptionnée) → archivée | ConducteurTravaux (Admin) | non (tracé) | non |
| Livraison | Enregistrée → Annulée | ChefChantier, ConducteurTravaux, Achats (Admin) | **oui** | oui |

Tout le reste est refusé : `TRANSITION_INTERDITE`. Le **recalcul automatique** (une livraison annulée fait repasser Livrée en Livrée partiellement, ou Livrée partiellement en Commandée) n'est pas une action de personne : il suit les livraisons tant que la demande n'est pas Réceptionnée et il est historisé.
Chaque transition est historisée : qui, quand, ancien → nouveau statut, motif.

## Écrans attendus (mobile / web)
| Écran | Plateforme | Action principale | Gestes / temps visé |
|---|---|---|---|
| Accueil du chantier (tuiles Demandes, À recevoir, À réceptionner, À valider) | mobile | entrer en 1 geste | 1 geste |
| Nouvelle demande | mobile + web | Envoyer un besoin | 4 gestes, moins de 30 s |
| Mes demandes, détail et historique | mobile + web | Suivre, modifier, annuler | 1 geste pour ouvrir |
| À valider, Valider / Refuser | mobile + web | Valider | 2 gestes |
| À commander, Commande | web (mobile connecté) | Commander | formulaire à une page |
| À recevoir | mobile + web | Choisir la commande attendue | 1 geste |
| Réception d'une livraison, photo du bon | mobile + web | Enregistrer | 3 gestes (6 avec photo) |
| Livraisons, détail, Non rattachées | mobile + web | Corriger, annuler, rattacher | lecture |
| À réceptionner | mobile | Réceptionner | 1 geste |
| À vérifier (conflits) | mobile | Garder le serveur, ou recréer | 1 geste |
| Tableau de suivi (5 vues) | web | Consulter | lecture |
| Catalogue produits, fournisseurs | web | Créer, désactiver | formulaire à une page |

## Disponible sans réseau
| Disponible sans réseau (mobile) | Nécessite le réseau |
|---|---|
| Créer, corriger, annuler une demande | Commander, modifier ou annuler une commande, solder |
| Valider, refuser (conducteur) | Rattacher une livraison à une demande |
| Enregistrer, corriger, annuler une livraison ; prendre les photos | Envoi des photos, réception des changements des autres |
| Réceptionner une demande livrée | Archiver, restaurer ; gérer le catalogue et les fournisseurs (web) |
| Consulter listes et détails (données du dernier envoi) | Charger une photo de bon déjà envoyée |

## Messages (FR / AR, à faire relire : H-MAT-24)
| Cas | Français | Arabe |
|---|---|---|
| `QUANTITE_INVALIDE` | La quantité doit être supérieure à 0. | يجب أن تكون الكمية أكبر من 0. |
| `UNITE_OBLIGATOIRE` | Choisissez une unité. | اختر الوحدة. |
| `DATE_INVALIDE` | La date est incomplète ou impossible. | التاريخ غير مكتمل أو غير ممكن. |
| `UNITES_INCOMPATIBLES` | Ces deux unités ne peuvent pas être additionnées. Saisissez dans l'unité de la commande. | لا يمكن جمع هاتين الوحدتين. أدخل الكمية بوحدة الطلبية. |
| `TRANSITION_INTERDITE` | Cette action n'est pas possible dans l'état actuel de la demande. | هذا الإجراء غير ممكن في الحالة الحالية للطلب. |
| `DEMANDE_VERROUILLEE` (nouveau) | Demande validée : la quantité et le produit ne se modifient plus. Annulez-la et créez-en une nouvelle. | تمت المصادقة على الطلب: لا يمكن تعديل الكمية والمادة. ألغِه وأنشئ طلباً جديداً. |
| `DEMANDE_NON_OUVERTE` (nouveau) | Cette demande n'accepte plus de livraison. | هذا الطلب لا يقبل تسليماً جديداً. |
| `COMMANDE_EXISTANTE` (nouveau) | Cette demande est déjà commandée. | تم تقديم طلبية لهذا الطلب من قبل. |
| `PRODUIT_DIFFERENT` (nouveau) | Le produit de la livraison n'est pas celui de la demande. | مادة التسليم ليست مادة الطلب. |
| Doublon possible | Une demande semblable existe déjà : DEM-012. | يوجد طلب مشابه: DEM-012. |

Les quatre codes « nouveau » sont à ajouter au catalogue d'erreurs (`docs/api/codes-erreur.md`) par le backend, avec leurs textes FR et AR.

## Vocabulaire FR / AR (à faire relire, H-MAT-24)
| Français | Arabe | Français | Arabe |
|---|---|---|---|
| Demande de matériaux | طلب مواد | Commande | طلبية |
| Livraison | تسليم | Bon de livraison (BL) | وصل التسليم |
| Fournisseur | مورّد | Produit, matériau | مادة |
| Quantité | الكمية | Unité | الوحدة |
| Urgence | الأولوية | Normale | عادية |
| Urgente | مستعجلة | Bloquante | معطِّلة للورشة |
| Pour le (date de besoin) | لتاريخ | Reste à livrer | المتبقي للتسليم |
| Écart | الفارق | Surplus | زيادة |
| Demandée | تم الطلب | Validée | تمت المصادقة |
| Refusée | تم الرفض | Commandée | تم تقديم الطلبية |
| Livrée partiellement | تسليم جزئي | Livrée | تم التسليم |
| Réceptionnée | تم الاستلام | Annulée | ملغى |
| Valider | مصادقة | Refuser | رفض |
| Commander | تقديم طلبية | Réceptionner | استلام |
| Solder | تسوية | Annuler | إلغاء |
| Conforme | مطابق | Avec réserve | مع تحفظ |
| À valider | بانتظار المصادقة | À recevoir | بانتظار الاستلام |
| Prix unitaire | سعر الوحدة | Montant | المبلغ |
| Sac | كيس | Tonne | طن |
| Mètre cube | متر مكعب | Litre | لتر |
| Pièce | قطعة | Kilogramme | كيلوغرام |
| Ciment | إسمنت | Rond à béton HA | حديد التسليح HA |
| Brique creuse | آجر مجوف | Sable | رمل |
| Gravier | حصى | Adjuvant | مادة مضافة |

## Données de test
Réutiliser le jeu « École UV18 » (`docs/metier/socle.md`, comptes `*.dev`, 26 zones) et les livraisons de ciment 2026 de `donnees-test.md`. Tout est fictif, **prix compris**. Le détail est reporté dans `donnees-test.md` (section « Demandes, commandes et livraisons »).

### Catalogue (13 produits)
| N° | Produit | Unités autorisées | Défaut | Masse du sac |
|---|---|---|---|---|
| P-01 | Ciment CPJ 42,5 | sac, T, kg | sac | 50 kg |
| P-02 à P-06 | Rond à béton HA Ø8, Ø10, Ø12, Ø14, Ø16 | T, kg | T | |
| P-07 | Brique creuse 8 trous | u | u | |
| P-08 | Brique creuse 12 trous | u | u | |
| P-09 | Sable de maçonnerie | m³, T | m³ | |
| P-10 | Gravier 8/15 | m³, T | m³ | |
| P-11 | Adjuvant plastifiant | L | L | |
| P-12 | Mortier monocouche | sac, T, kg | sac | 25 kg |
| P-13 | Fil d'attache | kg | kg | |

### Fournisseurs (fictifs)
| N° | Nom | Téléphone fictif | Produits |
|---|---|---|---|
| F-01 | Cimenterie Sigma (fictive) | 0550 00 00 21 | ciment, monocouche |
| F-02 | Aciers Delta (fictifs) | 0550 00 00 22 | rond HA, fil d'attache |
| F-03 | Briqueterie Epsilon (fictive) | 0550 00 00 23 | briques |
| F-04 | Sablière Zêta (fictive) | 0550 00 00 24 | sable, gravier |
| F-05 | Adjuvants Êta (fictifs) | 0550 00 00 25 | adjuvants |

### Demandes de l'École UV18 (12) et de CH-LOG-OL40 (1)
Prix fictifs : ciment 780,00 DZD/sac ; rond HA 128 000,00 DZD/T ; brique creuse 8 trous 27,50 DZD/u.

| N° | Produit | Quantité | Zone | Pour le | Urgence | Demandeur | Statut final | Remarque |
|---|---|---|---|---|---|---|---|---|
| DEM-001 | Ciment CPJ 42,5 | 800 sacs (40 T) | Bloc 01 · ±0,00 m | 18/07/2026 | Urgente | `chef.dev` | Réceptionnée | LIV-001 et LIV-002 ; 624 000,00 DZD |
| DEM-002 | Ciment CPJ 42,5 | 400 sacs (20 T) | Bloc 01 · +3,40 m | 19/08/2026 | Normale | `chef.dev` | Réceptionnée | LIV-003 ; 312 000,00 DZD |
| DEM-003 | Ciment CPJ 42,5 | 200 sacs (10 T) | Bloc 01 · +6,80 m | 21/09/2026 | Normale | `chef.dev` | Réceptionnée | LIV-004 ; 156 000,00 DZD |
| DEM-004 | Ciment CPJ 42,5 | 200 sacs (10 T) | Bloc 01 · +10,20 m | 21/10/2026 | Normale | `chef.dev` | Réceptionnée | LIV-005 ; 156 000,00 DZD |
| DEM-005 | Ciment CPJ 42,5 | 600 sacs (30 T) | Bloc 02 · ±0,00 m · Cantine | 04/11/2026 | Normale | `chef.dev` | **Livrée** (à réceptionner) | LIV-006, 007, 008 ; 468 000,00 DZD |
| DEM-006 | Rond à béton HA Ø12 | 3,5 T | Bloc 01 · +10,20 m | 03/12/2026 | Urgente | `equipe.dev` | Demandée | à valider |
| DEM-007 | Brique creuse 8 trous | 12 000 u | Bloc 02 · ±0,00 m · Cantine | 10/12/2026 | Normale | `chef.dev` | Validée | validée par `conducteur.dev` |
| DEM-008 | Sable de maçonnerie | 24 m³ | Bloc 02 · ±0,00 m · Réfectoire | 30/11/2026 | Normale | `equipe.dev` | Refusée | motif « Stock suffisant sur le chantier » |
| DEM-009 | Ciment CPJ 42,5 | 300 sacs (15 T) | Bloc 01 · +10,20 m | 26/11/2026 | **Bloquante** | `chef.dev` | Commandée | Cimenterie Sigma ; 234 000,00 DZD ; livraison prévue 26/11/2026 |
| DEM-010 | Adjuvant plastifiant | 200 L | Bloc 01 · +10,20 m | 27/11/2026 | Normale | `equipe.dev` | Annulée | motif « Erreur de saisie » |
| DEM-011 | Rond à béton HA Ø10 | 2 T | Bloc 01 · +10,20 m | 19/11/2026 | Normale | `chef.dev` | **Livrée partiellement** | Aciers Delta ; 256 000,00 DZD ; LIV-009 : 1,2 T ; reste 0,8 T |
| DEM-012 | Mortier monocouche | 40 sacs (1 T) | Bloc 02 · façade cantine (sans cote) | 06/12/2026 | Normale | `equipe.dev` | Demandée | sac de 25 kg |
| DEM-001 de `CH-LOG-OL40` | Brique creuse 12 trous | 8 000 u | Bloc A · ±0,00 m | 12/12/2026 | Normale | `conducteur.dev` | Demandée | invisible de `chef.dev` |

### Livraisons de l'École UV18 (10)
| N° | Date | Demande | Produit | Quantité reçue | = en unité de la commande | Fournisseur |
|---|---|---|---|---|---|---|
| LIV-001 | 18/07/2026 | DEM-001 | Ciment | 20 T | 400 sacs | Sigma |
| LIV-002 | 21/07/2026 | DEM-001 | Ciment | 20 T | 400 sacs | Sigma |
| LIV-003 | 19/08/2026 | DEM-002 | Ciment | 20 T | 400 sacs | Sigma |
| LIV-004 | 21/09/2026 | DEM-003 | Ciment | 10 T | 200 sacs | Sigma |
| LIV-005 | 21/10/2026 | DEM-004 | Ciment | 10 T | 200 sacs | Sigma |
| LIV-006 | 04/11/2026 | DEM-005 | Ciment | 10 T | 200 sacs | Sigma |
| LIV-007 | 05/11/2026 | DEM-005 | Ciment | 10 T | 200 sacs | Sigma |
| LIV-008 | 14/11/2026 | DEM-005 | Ciment | 10 T | 200 sacs | Sigma |
| LIV-009 | 19/11/2026 | DEM-011 | Rond HA Ø10 | 1,2 T | 1,2 T | Aciers Delta |
| LIV-010 | 22/11/2026 | **non rattachée** | Gravier 8/15 | 12 m³ | 12 m³ | Sablière Zêta |

Contrôle : ciment livré à l'école = 20 + 20 + 20 + 10 + 10 + 10 + 10 + 10 = **110 T = 2 200 sacs** ; demandes de ciment DEM-001 à DEM-005 = 800 + 400 + 200 + 200 + 600 = **2 200 sacs**. Cela correspond aux 110 T de livraisons acceptées de `donnees-test.md` ; les 3 livraisons à date incomplète (dont 30 T pour l'école) sont les cas négatifs ci-dessous.
Une photo de bon fictive est liée à LIV-006. Un jeu volumineux (500 demandes, 300 produits) est **généré par les tests**, pas chargé dans la démonstration standard.

### Cas négatifs à tester
| Saisie | Résultat attendu |
|---|---|
| Quantité 0, −5 ou vide | `QUANTITE_INVALIDE` |
| 2,5 sacs de ciment ou 100,5 briques | refusé : nombre entier requis |
| « Autre produit » sans unité | `UNITE_OBLIGATOIRE` |
| Date de besoin `../12/2026` ou `31/11/2026` | `DATE_INVALIDE` |
| Date de besoin 20/11/2026 (passée) un 25/11/2026 | avertissement, acceptée |
| Livraison datée 27/11/2026 un 25/11/2026 | `DATE_INVALIDE` (futur) |
| Livraison de 30 T de sable pour une commande en m³ | `UNITES_INCOMPATIBLES` |
| Commander DEM-006 (Demandée) ou réceptionner DEM-009 (Commandée) | `TRANSITION_INTERDITE` |
| Valider DEM-004 (Réceptionnée) | `TRANSITION_INTERDITE` |
| Modifier la quantité de DEM-007 (Validée) | `DEMANDE_VERROUILLEE` |
| `equipe.dev` valide DEM-006 | `INTERDIT`, rien d'enregistré |
| `chef.dev` ouvre DEM-001 de `CH-LOG-OL40` | « introuvable », identique à un chantier inexistant |
| `chef.dev` demande le prix de DEM-009 | absent de la réponse |
| Rattacher LIV-010 (gravier) à DEM-009 (ciment) | `PRODUIT_DIFFERENT` |
| Refuser une demande sans motif | refusé, motif obligatoire |
| Même demande envoyée deux fois (même identifiant) | une seule demande, un seul numéro |

## Points d'attention pour la suite (architecte)
Formulés sans code ; à traiter dans le plan.
- **Prix = champ réservé** : mêmes précautions que le montant du marché (absent des réponses et de la synchronisation hors rôles « prix »).
- **Photo du bon de livraison** : ce lot en a besoin avant le lot « photos » complet. Prévoir le minimum (métadonnées d'abord, image ensuite, reprise, liaison à la livraison) en respectant l'ADR 0004.
- **Numérotation** : `DEM` et `LIV` utilisent le service de numérotation du socle, après vérification de l'identifiant unique de saisie.
- **Synchronisation** : les demandes, livraisons et leurs photos se créent et se modifient hors ligne ; la commande **non**. Catalogue, noms de fournisseurs, demandes, commandes et livraisons se reçoivent au téléphone (sans prix selon le rôle). Toute nouvelle entité du chantier entre dans la liste des éléments « touchés » lors d'une affectation.
- **Conflits** : sur les statuts, le serveur gagne ; sur les textes et dates, champ par champ, la première arrivée est retenue et l'autre va dans « À vérifier ».
- **Nouveaux codes d'erreur** : `DEMANDE_VERROUILLEE`, `DEMANDE_NON_OUVERTE`, `COMMANDE_EXISTANTE`, `PRODUIT_DIFFERENT`.
- **Droits** : nouvelles permissions à ajouter à la matrice (demandes, commandes, livraisons, prix, catalogue) ; le tableau « Droits par rôle » ci-dessus en est la source.
- **Écarts avec le référentiel des statuts** : trois cas (Q-MAT-01) à valider avant de les coder.

## Couverture des cas obligatoires par histoire
« N/A » signifie qu'il n'y a rien à tester dans ce cas, avec la raison.

| Histoire | Nominal | Hors ligne | Unité / date manquante | Doublon | Mauvais rôle / chantier | Grande liste |
|---|---|---|---|---|---|---|
| 001 | .1 .2 .3 | .4 | .5 .6 .7 | .8 .9 | .13 .14 | .12 |
| 002 | .1 .2 | .3 | .10 (unité) ; date : N/A (lecture) | N/A (lecture) | .7 .8 | .9 |
| 003 | .1 .2 .3 | .4 .5 | .3 (quantité) ; date : N/A | .6 | .7 .8 | .9 |
| 004 | .1 .2 .4 | .6 | .3 | .7 | .8 .9 | N/A (une demande à la fois) |
| 005 | .1 .2 .3 | .8 | .3 .4 | .5 | .9 .10 | .11 |
| 006 | .1 .2 .3 | .7 | .4 .5 | .8 .9 | .10 .11 | .12 |
| 007 | .1 .3 | .2 | .5 .6 (BL absent .7) | .4 | .8 .9 | .10 |
| 008 | .1 .2 .3 | .8 | N/A (aucune saisie de quantité ou de date) | N/A (statut calculé) | .4 .9 | N/A (une demande à la fois) |
| 009 | .1 .3 .6 | .5 | N/A (aucune saisie) | N/A | .2 .4 | N/A (aucune liste propre) |
| 010 | .1 .2 | .1 .11 | N/A (règles de saisie reprises des autres histoires) | .9 | .8 .13 | .12 |
| 011 | .1 .2 | .4 | .6 | .5 | .7 | .8 |
| 012 | .1 .2 .3 | .5 | .7 | .6 | .8 | N/A (une livraison à la fois) |
| 013 | .1 .2 .3 | .7 | N/A (lecture) | N/A (lecture) | .8 | .6 |
| 014 | .1 .3 | .5 | N/A (aucune saisie) | .6 | .7 | .8 |
| 015 | .1 .2 .4 | .10 | .1 .2 | .5 | .8 | .9 |
| 016 | .1 | N/A (données de démonstration) | N/A | .2 | .4 | N/A (jeu volumineux généré par les tests) |

## Hors périmètre
- Facturation, paiement des fournisseurs, rapprochement de factures, TVA et montants TTC (Q-MAT-06).
- Retours de marchandise au fournisseur, avoirs, contentieux : une livraison refusée se saisit « Avec réserve » puis « Annulée » avec son motif.
- Stock du magasin, consommation par zone, inventaire, transferts entre chantiers.
- Une demande avec plusieurs fournisseurs, ou une commande groupant plusieurs demandes ; une livraison répartie sur plusieurs demandes (Q-MAT-07).
- Lien avec un coulage ou une tâche, et rapprochement du ciment livré avec le ciment théorique d'un coulage (calculs.md §3) : lot « Tâches, avancement et coulages ». Ce lot-ci fournit le ciment livré, cumulé par chantier et par unité.
- Notifications poussées au conducteur (« demande urgente ») : il voit « À valider » à la synchronisation. Notifications : hors périmètre du socle.
- Appel d'offres, comparaison de devis, budget par lot.
- Rouvrir une demande Réceptionnée.
- Photos générales du chantier, galerie, lien photo ↔ tâche ou problème (lot « photos »).
- Édition hors ligne des commandes par les Achats (H-MAT-04).

## Questions ouvertes
Les réponses retenues par défaut sont marquées « retenu » ; la question n'est posée que si la réponse change le fonctionnement ou la responsabilité.

- [direction, conducteur de travaux] **Q-MAT-01 : trois cas absents du tableau des statuts du référentiel.**
  (a) Les Achats peuvent-ils annuler une commande sans aucune livraison (Commandée → Validée, motif obligatoire) ? Retenu : **oui**, sinon une commande défaillante bloque la demande.
  (b) Les Achats ou le conducteur peuvent-ils « solder » un manque définitif (Livrée partiellement → Livrée, motif) ? Retenu : **oui**, sinon une demande reste ouverte pour toujours.
  (c) Le chef de chantier peut-il annuler les demandes de ses chefs d'équipe ? Retenu : **non** (référentiel : demandeur ou conducteur seulement).
  À répondre pour chaque point : accepter ou refuser. Si (a) ou (b) est refusé, retirer CA-MAT-005.7 et CA-MAT-008.5.
- [chef de chantier] **Q-MAT-02 : qui enregistre le camion ?** A) chef de chantier, conducteur, Achats seulement (retenu) · B) le chef d'équipe aussi quand il est à la porte.
- [direction] **Q-MAT-03 : les bons de livraison portent souvent les prix.** A) le chef de chantier voit la photo, il tient déjà le papier (retenu) · B) la photo n'est visible que d'Achats, conducteur et Direction (le chef de chantier garde le papier).
- [chef de chantier] **Q-MAT-04 : tolérance de « livraison complète » pour les produits en vrac pesés au camion (ciment en T, sable).** A) 0 %, il faut solder (retenu) · B) 1 % · C) 2 % · D) autre valeur par produit.
- [chef de chantier, achats] **Q-MAT-05 : rond à béton.** A) commandé et reçu en T ou kg (retenu) · B) en barres : il faudra le poids d'une barre par diamètre et ajouter une conversion barre ↔ kg (règle nouvelle à valider).
- [direction, comptabilité] **Q-MAT-06 : montants hors taxes ou toutes taxes ?** A) hors taxes seulement (retenu) · B) hors taxes et toutes taxes. Le taux de TVA applicable est **à confirmer** : source à consulter, la Direction générale des impôts (DGI), textes en vigueur ; aucun taux n'est codé en dur.
- [chef de chantier] **Q-MAT-07 : un camion pour deux demandes (un même BL pour deux zones).** A) deux livraisons, une par demande (retenu) · B) une livraison répartie entre deux demandes.
- [chef de chantier] **Q-MAT-08 : « retba », « lheria », « auberge » (notes de livraison).** A) autres chantiers, à créer par l'Admin (retenu) · B) lieux de stockage : il faudra un « lieu de réception » sur la livraison. (Question déjà posée dans le référentiel.)
- [chef de chantier, achats] **Q-MAT-09 : date de besoin par défaut.** A) aujourd'hui + 3 jours pour tout (retenu) · B) délai habituel par produit, renseigné dans le catalogue par les Achats.
- [arabophone du terrain] **Q-MAT-10 :** relire les traductions arabes (statuts, « Bloquante », « Solder », noms de produits).
