# Validation métier : demandes de matériaux, commandes et livraisons

**Slug :** `demandes-materiaux-livraisons` · **Date :** 26/11/2026 · **Auteur :** expert-metier-chantier · **Étape :** 7 de `/fonctionnalite`
**Documents lus :** besoins (`docs/metier/demandes-materiaux-livraisons.md`), plan, rapport QA (passes 1 et 2, verdict Conforme), revue R2 bis (conforme avec réserves), textes FR et AR du web et du mobile, règles de calcul du mobile, matrice des droits, réglages du serveur.

## Verdict : **Conforme, avec réserves de mise en service**

- **Aucun écart Bloquant ni Majeur.** La chaîne besoin → validation → commande → livraison avec photo du bon → réception tient sur le papier et dans le code : unités obligatoires, dates complètes, calculs faits par le serveur, prix absents du terrain, numérotation par chantier, envoi sans doublon, arabe de droite à gauche.
- **9 écarts Mineurs (dont un accepté et un de mise en service) et 3 suggestions** (liste plus bas) : à corriger dans une petite série avant de mettre l'application entre les mains d'un vrai chef de chantier. Aucun n'empêche de travailler.
- **La fonctionnalité n'est pas « prête pour le chantier » tant que 4 conditions ne sont pas levées** (section « Mise en service ») : les réponses de l'utilisateur aux questions Q-MAT, la relecture de l'arabe, un essai sur un vrai téléphone au soleil, et un catalogue de départ.
- Ce verdict porte sur ce qui a été livré, pas sur les hypothèses : 24 hypothèses H-MAT et 10 questions Q-MAT sont toujours « retenues par défaut », sans réponse d'un chef de chantier.

## Ce que j'ai vérifié moi-même, et ce que je reprends de la QA
- **Relu et recontrôlé par moi :** les textes FR et AR du web (matériaux) et les clés principales du mobile ; les règles de conversion et de statut du mobile ; le choix des dates proposées dans le formulaire de demande ; la matrice des droits du serveur ; les réglages (3 jours, tolérance 0 %, 5 photos) ; l'absence de prix dans les écrans du mobile ; les chiffres de `calculs.md` §8 et du jeu de démonstration (recalculés ci-dessous).
- **Repris du rapport QA, non rejoués :** les 2 943 tests verts, les essais sur l'API réelle (31 + 12 contrôles), les 21 parcours Playwright, les mesures de volume. Je n'ai exécuté aucun test.
- **Non vérifiable ici, ni par la QA :** téléphone réel, appareil photo, soleil, gants, hors ligne réel, durée « moins de 30 s », fluidité sur 150 photos, captures arabes (non régénérées).

## Règles non négociables

| Règle | Résultat | Preuve |
|---|---|---|
| 1. Unité obligatoire, jamais d'addition d'unités différentes | **Conforme** | Unité en pastilles, jamais en texte libre ; « Autre produit » sans unité préchoisie ; sable en m³ reçu en T refusé ; totaux « 24 m³ et 10 T » en deux lignes (règles du mobile relues, tests de la QA) |
| 2. Date complète obligatoire | **Conforme** | Calendrier et pastilles seulement ; `../08/2026` et `31/11/2026` refusés sur demande, commande, livraison (13 formes testées par la QA) ; livraison datée de demain refusée même si le téléphone est en avance |
| 3. Calculs côté serveur, `decimal` | **Conforme** | Le mobile n'a qu'un « miroir d'affichage » (équivalences, statut « à confirmer ») ; il n'écrit aucun montant ; le serveur remplace sa valeur à l'envoi |
| 4. DZD, 2 décimales, arrondi « loin de zéro » | **Conforme** | 2,5 kg × 245,25 = 613,125 → **613,13** (et non 613,12) ; 1 milliard de kg au prix maximal exact ; vecteurs communs aux trois technologies |
| 5. Numérotation par chantier, donnée par le serveur | **Conforme** | `DEM-nnn`, `LIV-nnn` ; 60 créations simultanées sans trou ; « numéro en attente » hors ligne ; `DEM-001` existe sur deux chantiers sans conflit |
| 6. Hors ligne d'abord, envoi sans doublon | **Conforme (simulateur)** | Même identifiant renvoyé trois fois = une demande, un numéro ; lot de trois jours renvoyé en entier = 25 « déjà reçu » ; validation après annulation rendue en conflit sans rien écraser |
| 7. Français + arabe (RTL), saisie < 30 s | **Conforme sur le papier, à mesurer sur le terrain** | Parité des clés FR/AR vérifiée ; boutons de 56 dp et texte de 16 sp testés ; les « 4 gestes » sont comptés selon la convention du document (un appui ou une saisie au clavier numérique = 1 geste) : taper « 300 » fait trois touches en vrai |
| 8. Données personnelles et sensibles | **Conforme** | Aucun prix pour ChefChantier et ChefEquipe (0 occurrence sur 30 routes et dans toute la synchronisation) ; téléphone fournisseur lu en ligne seulement, jamais stocké ; rien dans les journaux (preuve large : revue R2) |
| 9. Traçabilité | **Conforme** | Qui, quand (heure du serveur), « saisi le » (heure du téléphone, à part), ancien → nouveau, motif ; livraison annulée barrée, jamais effacée ; numéro jamais réutilisé |

## Statuts et trois écarts au référentiel

La table des transitions du serveur correspond au document : pas d'autre passage possible, motif obligatoire pour refus, annulation, annulation de commande, solde, et réserve « Autre ». Le statut se recalcule dans les deux sens tant que la demande n'est pas réceptionnée.

| Écart au référentiel | Dans le code | Mon avis de terrain | Décision attendue |
|---|---|---|---|
| (a) Commandée sans livraison → Validée (Achats, motif) | Présent (`Orders.Cancel` : Achats, Admin) | **À garder.** Sans lui, un fournisseur qui désiste bloque la demande pour toujours | Q-MAT-01 a |
| (b) Livrée partiellement → Livrée (« solder », Achats ou conducteur, motif) | Présent (`Requests.Settle` : Achats, Conducteur, Admin) | **À garder.** Le camion qui ne reviendra jamais est le cas le plus fréquent | Q-MAT-01 b |
| (c) Le chef de chantier n'annule pas la demande d'un chef d'équipe | Conforme à l'hypothèse (pas de `CancelAny` pour lui) | **Frottement réel** : il peut corriger toutes les demandes mais pas en annuler une faite par erreur ; il doit appeler le conducteur, qui peut aussi la refuser avec le motif « Doublon » | Q-MAT-01 c |

Je n'ai pas modifié le référentiel (`SKILL.md`) : il attend la réponse de l'utilisateur.

## Cas réels : ce qui est couvert et ce qui manque

| Cas de chantier | Traitement dans la fonctionnalité | Jugement |
|---|---|---|
| **Ciment en sacs de 50 kg** commandé en sacs, reçu en T (vrac ou palette) | Conversion sac ↔ kg ↔ T avec la masse du sac du produit ; « 10 T = 200 sacs » à l'écran ; total dans l'unité de la commande | **Couvert.** Monocouche en sacs de 25 kg : même mécanisme |
| **Rond à béton en tonnes** | Unités T et kg, par diamètre ; aucune conversion barre ↔ T | **Couvert pour la livraison** (le bon est en kg ou en T). **Faible pour la demande** : le chef d'équipe compte en barres, pas en tonnes (voir E-09) |
| **Livraison partielle** | Quantité préremplie = reste ; annonce « il restera 100 sacs » ; statut « Livrée partiellement » ; reste et écart au détail | **Couvert** |
| **Surplus** | Annonce « Surplus de +20 sacs (+5,00 %) » avant d'enregistrer ; demande « Livrée » avec écart ; aucun blocage | **Couvert, mais** sans liste « à traiter » (voir E-02) |
| **Manque définitif** | « Solder » avec motif (Achats, conducteur) | **Couvert** |
| **Retard** | « En retard de N j » en jours calendaires à l'heure d'Algérie ; vue « En retard » sur le web, filtre sur « À recevoir » du mobile | **Couvert.** Pas d'alerte envoyée au conducteur (hors périmètre, voir E-11) |
| **Un camion pour deux demandes** (même BL, deux zones) | Deux livraisons, une par demande (Q-MAT-07 A) ; avertissement « même BL » non bloquant | **Utilisable mais pénible** : deux saisies, deux fois la photo du même bon, et un avertissement de doublon à écarter à chaque fois (voir Q-MAT-07) |
| **Une demande servie par deux camions** | Deux livraisons sur la même demande, cumul automatique | **Couvert** |
| **Camion arrivé sans demande** | Livraison « non rattachée », à rattacher ensuite (avec réseau) | **Couvert** |
| **Livraison arrivée avant la commande enregistrée** (Achats ont téléphoné) | Livraison retenue, demande reste « Validée » avec badge, statut recalculé à la commande | **Couvert** |
| **Livraison refusée à la porte** | « Annuler la livraison » avec motif « Refusée à la réception » | **Couvert a minima** : la quantité refusée n'est inscrite nulle part (voir E-08) |
| **Retour au fournisseur après réception** (béton non conforme, acier rouillé découvert plus tard) | Hors périmètre ; une demande réceptionnée n'accepte plus aucune correction | **Manque** (voir E-08) |
| **Quantité du bon différente de la pesée** | Une seule quantité par livraison (la reçue) | **Manque** (voir E-08) |
| **Prix qui change d'une livraison à l'autre** (acier, sable) | La valeur d'une livraison = quantité × prix de la commande, non modifiable | **Écart au besoin** (voir E-05) |
| **Plusieurs demandes commandées en une fois par les Achats** (5 demandes de ciment, un seul bon de commande) | Une commande par demande, sans regroupement | **Utilisable mais répétitif** (voir E-07) |
| **Camion reçu par le chef d'équipe ou le gardien** | Seuls chef de chantier, conducteur, Achats peuvent enregistrer ; la date d'une livraison peut être antérieure | **Contournable** : le chef de chantier saisit plus tard avec la bonne date (voir Q-MAT-02) |

## Écarts relevés

Sévérités du skill `qualite-passation`. « Qui » = agent à qui revient la correction.

| # | Sév. | Écart | Où | Correction proposée | Qui |
|---|---|---|---|---|---|
| **E-01** | Mineur | **Dates proposées au chef d'équipe.** Pas de pastille « Aujourd'hui » : pour un besoin du jour (cas « Bloquante »), il faut ouvrir le calendrier, soit 8 gestes au lieu de 6 au plus (CA-MAT-001.2). « Semaine prochaine » tombe sur un **lundi** alors que la semaine de travail commence le **dimanche** en Algérie. **Faute de mon besoin** : la liste « Demain · +3 j · Semaine prochaine · Autre date » vient de CA-MAT-001.2, et le code l'applique à la lettre | Formulaire de demande du mobile (choix des dates) ; CA-MAT-001.2 | Ajouter « Aujourd'hui » (en tête quand l'urgence est Urgente ou Bloquante) ; « Semaine prochaine » = dimanche. Les jours de repos du chantier sont à confirmer (Q-V02). J'amende CA-MAT-001.2 en conséquence | mobile-flutter (+ web : même liste de pastilles s'il y en a) |
| **E-02** | Mineur | **« À traiter » n'existe pas.** CA-MAT-006.6 (réserve), 008.6 (surplus) et 010.6 (livraison non rattachée) annoncent une liste « À traiter » pour Achats et conducteur. Il existe des onglets Livraisons « Avec réserve », « Non rattachées », « À compléter » (web) et des filtres équivalents (mobile), mais **le surplus n'a aucune liste** : il ne se voit qu'en ouvrant chaque demande. La QA a marqué ces critères « OK » sans relever ce point | Suivi web, Livraisons mobile | Ajouter une vue ou un filtre « Surplus » (et, mieux, un compteur « À traiter » = réserves + surplus + non rattachées) dans le suivi web ; sinon retirer « À traiter » des critères | frontend-react ; architecte (décision) |
| **E-03** | Mineur | **Deux mots pour presque la même chose.** « À recevoir » (les camions attendus) et « À réceptionner » (les demandes livrées à clôturer) ; sur le terrain « réceptionner » veut aussi dire « recevoir le camion », et « réception » veut dire la réception des travaux. **En arabe, le web et le mobile ne disent pas pareil** : « للاستلام » désigne les camions attendus au mobile mais les demandes à clôturer au suivi web ; « استلام » (web) et « تأكيد الاستلام » (mobile) pour la même action ; « للمعاينة والقبول » (mobile) pour « À réceptionner » | Textes FR et AR web et mobile | Choisir un seul vocabulaire (Q-V01) et le répercuter dans les deux applications, les ARB et le glossaire | frontend-react ; mobile-flutter |
| **E-04** | Mineur | **« Matériau » sur le mobile, « Produit » sur le web** (« Nom du matériau » / « Nom du produit » ; « Autre produit » des deux côtés). Le chef de chantier dit « matériau » pour le besoin, l'acheteur dit « produit » pour le catalogue | ARB mobile, `materials.json` | Garder « Matériau » pour le terrain (demande) et « Produit » pour le catalogue des Achats, ou un seul mot ; trancher en même temps que E-03 | mobile-flutter ; frontend-react |
| **E-05** | Mineur | **Pas de prix par livraison** (écart au besoin : le tableau des champs prévoyait un prix de livraison facultatif, réservé aux rôles « prix », par défaut celui de la commande ; le plan l'a rendu calculé et non modifiable, H-ARCH-07). Sur le rond à béton et le sable le prix du jour change entre deux camions ; le BL en fait foi | Entité livraison, formulaire web | Q-V04 | architecte ; backend ; frontend |
| **E-06** | Mineur | **Tolérance de « livraison complète » unique pour tout le chantier** (0 %). Pour les sacs, 0 % est juste (on compte). Pour le vrac pesé (ciment en T, sable, acier), 19,98 T livrées pour 20 T laissent la demande « Livrée partiellement » : il faudra la solder à la main, à chaque camion. Une valeur globale à 1 % serait fausse pour les sacs (6 sacs manquants sur 600 passeraient pour complets) | Réglage global ; Q-MAT-04 | Q-MAT-04 : tolérance **par produit**, ou par unité (0 % pour sacs et pièces, x % pour T, kg, m³) | architecte ; backend |
| **E-07** | Suggestion | **Commande groupée.** Les Achats commandent « 40 T de ciment » pour cinq demandes ; ici cinq commandes, cinq fois le fournisseur et le prix (le dernier fournisseur du produit est proposé par défaut : 3 gestes chacune). Acceptable pour une première mise en service | Écran « À commander » | À réévaluer après un mois d'usage : « commander la sélection » (même fournisseur, même prix, une commande par demande en un geste) | architecte |
| **E-08** | Mineur | **Retour fournisseur et écart de pesée sans trace.** (1) Une seule quantité par livraison : la quantité du bon et la quantité refusée ne s'écrivent nulle part ; « Avec réserve » dit pourquoi, pas combien. (2) Après « Réceptionnée », plus de correction ni d'annulation, et on ne rouvre pas une demande : un défaut découvert au coulage n'a pas de chemin dans l'application | Livraison, demande réceptionnée | Q-V05 : champ « Quantité refusée » (ou « Quantité sur le bon ») sur la livraison, et/ou « Rouvrir » réservé au conducteur avec motif | architecte (décision) |
| **E-09** | Suggestion | **Unités du terrain absentes** : « barre » (rond à béton, avec poids par diamètre), « voyage » ou « camion » (sable, gravier), « palette ». Sans elles, le chef d'équipe convertit de tête avant de saisir, et le sable en m³ commandé ne se rapproche jamais d'un « 3 voyages » noté sur le bon | Référentiel des unités ; Q-MAT-05 | Q-MAT-05 (rond) et Q-V06 (voyage) : règle nouvelle à valider avant tout code | expert-métier ; architecte |
| **E-10** | Mineur (mise en service) | **Catalogue vide en production.** La démonstration (13 produits, 5 fournisseurs fictifs) ne se charge jamais en production, et il n'existe pas d'importation. Le jour 1, un chef d'équipe ouvre « + Demande » et ne trouve rien ; seul « Autre produit » marche, donc des noms libres partout | Catalogue web | Préparer avant l'essai une liste de départ de 40 à 60 matériaux avec unités et masses de sac (Q-V03) ; une importation par fichier est une suggestion | Achats (contenu) ; architecte (importation) |
| **E-11** | Suggestion | **Pas d'alerte pour une demande « Bloquante »**. Le conducteur la voit à sa prochaine synchronisation, c'est-à-dire quand il ouvre l'application. Hors périmètre (notifications), mais c'est exactement le cas du chantier qui s'arrête | Notifications | En attendant : consigne « Bloquante = on téléphone aussi » ; vue « À valider » triée Bloquante en tête (déjà le cas) ; notification dans un lot ultérieur | architecte |
| **E-12** | Mineur (accepté) | **« Commander » sur le mobile n'existe pas** (CA-MAT-005.8 reporté, écran optionnel M10). Les Achats travaillent au bureau sur le web : sans conséquence tant que les Achats ne sont pas en déplacement | Mobile | Rien à faire maintenant ; à rouvrir si les Achats le demandent | – |

**Aucun écart sur** : prix et téléphones, chantier non affecté (« introuvable »), double appui, numérotation, conflits hors ligne, photo du bon (5 au plus, reprise, EXIF retiré), arrondi, statuts.

## Traductions arabes : à faire relire

La parité des clés est vérifiée par un test, pas la justesse du terrain. À relire par un arabophone qui connaît le chantier (Q-MAT-10). Points que je soumets en priorité :

| Français | Arabe actuel | Doute |
|---|---|---|
| Demande / Commande | طلب / طلبية | Deux mots très proches : une demande de matériaux et une commande au fournisseur se confondent à l'œil |
| À recevoir / À réceptionner | للاستلام / للاستلام (web) ; للاستلام / للمعاينة والقبول (mobile) | Même mot pour deux listes (voir E-03) |
| Réceptionner | استلام (web) ; تأكيد الاستلام (mobile) | Deux formulations |
| Bloquante | معطِّلة للورشة | Compréhensible ; à valider avec les chefs d'équipe (« تستوجب التوقف » ?) |
| Livrée partiellement | تسليم جزئي | Les autres statuts sont des verbes à la forme « تم… » ; celui-ci est un nom |
| Solder | تسوية | Sens comptable ; est-ce que « تسوية النقص » est compris du conducteur ? |
| Hors taxes | دون رسوم | À faire confirmer par les Achats : le terme usuel des devis et des factures peut être différent |
| BL manquant | الوصل ناقص | Compris ? « وصل التسليم غير موجود » est plus explicite |
| ml, forfait | م.ط, جزافي | Abréviation « م.ط » peu courante sur un bon |

## Calculs recalculés pour ce contrôle (tous exacts)
- 300 sacs × 50 kg = 15 000 kg = **15 T** · 17,5 T = 17 500 kg ÷ 50 = **350 sacs** · 1,2 T de monocouche ÷ 25 kg = **48 sacs** · 20,26 T ÷ 50 = **405,2 sacs**.
- Demande de 600 sacs, livraisons de 10 T (= 200 sacs) ×3 : reste 400, puis 200, puis 0 → Livrée ; annuler la troisième : 400 sur 600, Livrée partiellement.
- Surplus : 20,4 T pour 20 T = +0,4 T = **+2,00 %** · Manque : 19,5 T = 390 sacs pour 400 sacs = −10 sacs = **−2,50 %** · 19,85 T pour 20 T = **−0,75 %** (complète seulement avec une tolérance de 1 %).
- Montant : 300 × 780,00 = **234 000,00 DZD** · 800 × 780 = 624 000,00 · 2 T × 128 000,00 = 256 000,00 · 2,5 kg × 245,25 = 613,125 → **613,13** (arrondi loin de zéro).
- Jeu de démonstration : ciment demandé 800 + 400 + 200 + 200 + 600 = **2 200 sacs** ; ciment livré 20 + 20 + 20 + 10 × 5 = **110 T = 2 200 sacs** ✓ ; DEM-011 : 2 T − 1,2 T = **0,8 T** à livrer ✓.
- Date de besoin par défaut : 25/11/2026 + 3 = **28/11/2026** ; 30/12/2026 + 3 = **02/01/2027** ; 28/02/2028 + 3 = **02/03/2028** (2028 bissextile) ✓. Le 25/11/2026 est bien un mercredi, le coulage « jeudi » est le 26/11.
- Ajout : **la semaine de travail commence le dimanche**, donc « Semaine prochaine » depuis un mercredi 25/11 doit donner le **dimanche 29/11** et non le lundi 30/11 (jour de repos à confirmer, Q-V02).

## Mise en service : ce qui manque

À lever **dans cet ordre** avant de confier l'application à un chef de chantier :

1. **Réponses de l'utilisateur** aux questions ci-dessous (Q-MAT-01 à 10 et Q-V01 à Q-V06). Tant qu'elles restent « retenu par défaut », rien n'est validé côté règles.
2. **Relecture de l'arabe** par un arabophone du terrain (tableau ci-dessus).
3. **Petite série de corrections** : E-01, E-02, E-03, E-04 (sans attendre la réponse sur E-05 à E-09).
4. **Essai sur téléphone réel**, un chantier, une semaine, un chef d'équipe et un chef de chantier : chronomètre sur la demande (cible 30 s), avec des gants, au soleil, en mode avion pendant la prise de photo du bon, en arabe. Les seuls tests faits à ce jour sont simulés.
5. **Catalogue de départ** (E-10) et liste des fournisseurs réels, par les Achats.
6. **Exploitation (devops-ci)** : dossier des photos en chemin absolu sur un volume sauvegardé ; option de base à vérifier au démarrage ; sauvegarde des photos de bons (preuve en cas de litige).
7. **Consigne d'usage** de deux lignes, à afficher : « Bloquante = on téléphone aussi » ; « Remarque de commande : jamais de prix ».

## Questions à choix pour l'utilisateur

Pour chaque question : choisir une lettre. « Ma recommandation » est un avis de terrain sans réponse d'un chef de chantier : la décision reste la vôtre. Les questions du document de besoins sont reprises avec leur numéro.

**Q-MAT-01 : les trois écarts au référentiel des statuts** (conducteur de travaux, direction)
- a) Les Achats annulent une commande sans livraison (Commandée → Validée, motif) : **A) oui** · B) non, il faut passer par le conducteur. Recommandation : A.
- b) Le conducteur ou les Achats soldent un manque définitif (Livrée partiellement → Livrée, motif) : **A) oui** · B) non. Recommandation : A.
- c) Le chef de chantier annule les demandes de ses chefs d'équipe : A) non (retenu) · B) oui, toujours · **C) oui, seulement tant qu'elles sont « Demandée »** (avant validation). Recommandation : C.
- Si vous acceptez (a) et (b) : j'ajoute les deux transitions au tableau des statuts du référentiel.

**Q-MAT-02 : qui enregistre le camion ?** (chef de chantier)
- A) chef de chantier, conducteur, Achats (retenu) · B) le chef d'équipe aussi quand il est à la porte · C) A, plus un « magasinier » comme nouveau rôle (hors des six rôles actuels).
- Recommandation : A pour l'essai ; demander au chef de chantier combien de camions arrivent en son absence.

**Q-MAT-03 : la photo du bon (qui peut montrer des prix) est-elle visible du chef de chantier ?** (direction)
- A) oui, il tient déjà le papier (retenu, décision de l'orchestrateur) · B) non : Achats, conducteur, Direction seulement. Recommandation : A.

**Q-MAT-04 : tolérance de « livraison complète »** (chef de chantier, achats)
- A) 0 % partout, on solde à la main (retenu) · B) 1 % partout · C) **0 % pour les sacs et pièces, 1 % pour le vrac pesé** (T, kg, m³) · D) autre valeur par produit.
- Recommandation : C. Les options C et D demandent un développement (aujourd'hui une seule valeur).

**Q-MAT-05 : rond à béton** (chef de chantier, achats)
- A) en T ou kg seulement (retenu) · B) ajouter « barre » avec le poids par diamètre (règle nouvelle) · C) A pour la livraison, B pour la demande seulement.
- Recommandation : A pour l'essai ; noter comment les chefs d'équipe formulent réellement leur besoin.

**Q-MAT-06 : hors taxes ou toutes taxes** (direction, comptabilité)
- A) hors taxes seulement (retenu) · B) hors taxes et toutes taxes. Le taux de TVA est **à confirmer** auprès de la Direction générale des impôts : aucun taux n'est inscrit dans l'application. Recommandation : A.

**Q-MAT-07 : un camion pour deux demandes** (chef de chantier)
- A) deux livraisons, une par demande (retenu) · B) une livraison répartie entre deux demandes (refonte lourde) · C) **A, avec deux améliorations** : l'avertissement « même BL » ne se déclenche pas quand les deux livraisons visent deux demandes différentes, et la photo du bon d'une livraison se réutilise pour la seconde.
- Recommandation : C si ce cas arrive plus d'une fois par semaine ; sinon A.

**Q-MAT-08 : « retba », « lheria », « auberge »** (chef de chantier)
- A) d'autres chantiers, créés par l'Admin (retenu) · B) des lieux de stockage : il faudra un « lieu de réception » sur la livraison. À demander au chef : ce sont des mots qu'il écrit sur les bons.

**Q-MAT-09 : date de besoin par défaut** (chef de chantier, achats)
- A) aujourd'hui + 3 jours pour tout (retenu) · B) un délai par produit (ciment 2 jours, acier 7 jours…), renseigné par les Achats. Recommandation : A pour l'essai.

**Q-MAT-10 : relecture de l'arabe**
- A) vous relisez vous-même · B) un chef de chantier ou conducteur arabophone de votre équipe · C) une personne extérieure (traducteur) puis un chef de chantier pour le vocabulaire de terrain.
- Recommandation : B (le vocabulaire de chantier compte plus que la grammaire). Fournir le tableau « Traductions arabes à relire » ci-dessus.

**Nouvelles questions de cette validation**

**Q-V01 : le mot pour clore une demande livrée** (E-03)
- A) garder « Réceptionner » / « À réceptionner » · B) « **Clôturer** » / « À clôturer » · C) « **Confirmer la réception** » / « À confirmer ». « À recevoir » reste pour les camions attendus. Recommandation : B (aucun doute avec le camion). Le même choix s'applique à l'arabe.

**Q-V02 : jours de travail du chantier** (E-01)
- A) semaine du dimanche au jeudi, vendredi et samedi de repos · B) dimanche au vendredi, samedi de repos · C) le même pour tous les chantiers, réglable par chantier plus tard.
- Sert à « Semaine prochaine » (dimanche) et, plus tard, à compter les retards en jours ouvrés. Je n'affirme aucune règle légale : à confirmer avec le chantier.

**Q-V03 : catalogue de départ** (E-10)
- A) les Achats le saisissent au fil des demandes (risque : noms libres partout) · B) **je prépare une liste de 40 à 60 matériaux courants (ciment, rond HA, briques, sable, gravier, adjuvants, plomberie, électricité) avec unités et masses de sac, que les Achats corrigent avant l'essai** · C) importation par fichier (développement).
- Recommandation : B.

**Q-V04 : prix par livraison** (E-05)
- A) un seul prix par commande (état actuel) · B) prix modifiable par livraison, réservé aux rôles « prix », par défaut celui de la commande (comme prévu au besoin). Recommandation : A pour le ciment, B si l'entreprise achète l'acier ou le sable « au prix du jour » : à demander aux Achats.

**Q-V05 : retour fournisseur et écart de pesée** (E-08)
- A) rien de plus (« Avec réserve » puis annulation, état actuel) · B) ajouter « **Quantité refusée** » sur la livraison, qui reste hors du reçu · C) B, plus « **Rouvrir une demande réceptionnée** » réservé au conducteur, avec motif, jusqu'à une date limite. Recommandation : B.

**Q-V06 : unités « voyage » (camion) pour le sable et le gravier** (E-09)
- A) m³ ou T seulement (état actuel) · B) ajouter « voyage » sans conversion (jamais additionné aux m³) · C) ajouter « voyage » avec un volume paramétrable par fournisseur (règle nouvelle). Recommandation : B.

## Points de la revue à rappeler au terrain
- La remarque d'une commande est visible du terrain : jamais de prix ni de remise dedans (texte d'aide présent sur le web).
- Une photo de bon dont l'envoi échoue plus de 7 jours est à reprendre : à écrire dans le manuel.
- Les captures arabes ne sont pas régénérées : à refaire avant la formation.

## Documents du skill
Aucun changement de `calculs.md`, `glossaire.md`, `donnees-test.md` ni `SKILL.md` : aucune règle n'est encore validée par l'utilisateur. Dès les réponses Q-MAT-01, Q-MAT-04 et Q-V01 : mise à jour du tableau des statuts, du glossaire (clôturer / recevoir) et de `calculs.md` §8 (tolérance par unité).
