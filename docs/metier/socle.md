# Socle : connexion, rôles, chantiers, zones et usage hors ligne : besoins métier

**Slug :** `socle` · **Priorité :** Indispensable · **Auteur :** expert-metier-chantier · **Date :** 24/11/2026 · **Version :** 1.0 (brouillon, hypothèses à valider)

## Contexte terrain
- Le chef de chantier ouvre l'application sur son téléphone à 7 h, dehors, en plein soleil, souvent avec des gants. Le réseau est faible
  ou absent (sous-sol, cage d'escalier, zone isolée). Il doit voir « son » chantier en 1 geste et saisir sans attendre le réseau.
- Une entreprise mène plusieurs chantiers en même temps. Sur papier, les notes mélangent les chantiers (école, auberge, autres lieux).
  Règle d'or : **chacun ne voit que ses chantiers**, et chaque saisie est rattachée au bon chantier dès l'ouverture de l'écran.
- Un chantier se découpe en **zones** : blocs (Bloc 01), cotes de niveau (−1,90 · ±0,00 · +3,40 · +6,80 · +10,20) et locaux
  (classe 01, couloir, réfectoire). Toute saisie future (demande de matériel, coulage, problème, photo) dira « où ».
- Aujourd'hui : cahier et notes dispersées, chantiers et dates mélangés. Le socle donne à tous les besoins suivants un même point
  de départ : qui est connecté, sur quel chantier, dans quelle zone, avec quels droits, et si ses saisies sont bien parties.

## Hypothèses retenues (à valider, voir « Questions ouvertes »)
| N° | Hypothèse | Paramétrable |
|---|---|---|
| H-01 | Un utilisateur a **un seul rôle** pour tous ses chantiers. | non |
| H-02 | L'Admin voit **tous** les chantiers (il doit pouvoir les administrer). Direction, ConducteurTravaux, Achats, ChefChantier, ChefEquipe ne voient **que** les chantiers affectés. | non |
| H-03 | Connexion par **identifiant + mot de passe** (pas par téléphone, pas de SMS). | non |
| H-04 | Blocage temporaire après **5** échecs de connexion, pendant **15 minutes**. | oui |
| H-05 | Une session déjà ouverte reste utilisable hors ligne **14 jours**. Au-delà, reconnexion avec réseau. | oui |
| H-06 | Le **montant du marché** n'est visible que par Admin, Direction et ConducteurTravaux. | oui |
| H-07 | Une zone = **bloc** (obligatoire) + **cote** (facultative) + **local** (facultatif). Une même combinaison n'existe qu'une fois par chantier. | non |
| H-08 | Ajouter ou renommer une zone : Admin, ConducteurTravaux, ChefChantier. Archiver une zone : Admin, ConducteurTravaux. | oui |
| H-09 | Le délai du marché est en **jours calendaires** ; fin contractuelle = date de l'ODS + délai. | oui |
| H-10 | Chiffres **0 à 9** dans les deux langues. Les cotes, codes et dates restent lisibles de gauche à droite, même en arabe. | non |
| H-11 | Dates et heures affichées à l'heure d'Algérie (fuseau Africa/Algiers) ; la référence est l'heure du serveur. | non |
| H-12 | Alerte « données anciennes » après **24 h** sans synchronisation. | oui |
| H-13 | Rien n'est effacé : un chantier, une zone ou un compte « supprimé » est **archivé / désactivé** et reste dans l'historique. | non |
| H-14 | Wilayas et communes viennent d'une **liste de référence modifiable**. Le découpage officiel évolue (58 puis 69 wilayas annoncées en 2026) : **ne pas figer la liste dans le code**. Liste officielle à confirmer sur le Journal officiel (joradp.dz). | oui |
| H-15 | Une cote est comprise entre **−20,00 m et +60,00 m**, avec 2 décimales. | oui |
| H-16 | Boutons : cible tactile d'au moins 48 dp ; 56 dp pour les boutons principaux (gants). | non |
| H-17 | Le téléphone d'un compte n'est visible que par l'Admin et le titulaire du compte. | non |
| H-18 | Dans les données de démonstration, cantine, réfectoire et cuisine sont dans le Bloc 02 (choix de démonstration, pas un fait de chantier). | non |
| H-19 | Les traductions arabes de ce document sont à faire relire par un arabophone du terrain. | non |
| H-20 | Un chantier a un nom en français (obligatoire) et un nom en arabe (facultatif) ; sans nom arabe, on affiche le nom français. | non |

## Droits par rôle (synthèse)
O = autorisé, — = refusé, « aff. » = sur les chantiers affectés seulement.

| Action | Admin | Direction | ConducteurTravaux | Achats | ChefChantier | ChefEquipe |
|---|---|---|---|---|---|---|
| Se connecter, changer sa langue et son mot de passe | O | O | O | O | O | O |
| Voir « Mes chantiers », la fiche, les zones | O (tous) | O aff. | O aff. | O aff. | O aff. | O aff. |
| Voir le montant du marché | O | O aff. | O aff. | — | — | — |
| Créer, modifier, archiver un chantier | O | — | — | — | — | — |
| Ajouter ou renommer une zone | O | — | O aff. | — | O aff. | — |
| Archiver une zone | O | — | O aff. | — | — | — |
| Créer, désactiver un compte, changer un rôle | O | — | — | — | — | — |
| Affecter ou retirer un utilisateur d'un chantier | O | — | — | — | — | — |
| Voir le téléphone d'un compte | O | — | — | — | — | — |
| Voir « créé par / modifié par » | O | O aff. | O aff. | O aff. | O aff. | O aff. |
| Voir l'historique détaillé (anciennes valeurs) | O | O aff. | O aff. | — | — | — |
| Voir le journal des connexions | O | — | — | — | — | — |

Chacun voit son propre téléphone dans son profil.

## User stories

### US-SOCLE-001 : Se connecter  ·  Indispensable
En tant qu'utilisateur (n'importe quel rôle), je veux me connecter avec mon identifiant et mon mot de passe afin d'accéder à mes chantiers.

**Critères d'acceptation**
- CA-001.1 (nominal) : Étant donné un compte actif et du réseau, quand j'entre mon identifiant et mon mot de passe puis j'appuie sur « Se connecter », alors j'arrive sur « Mes chantiers » (moins de 10 s sur réseau faible, à valider en test terrain).
- CA-001.2 (rapide) : Étant donné que je me suis déjà connecté sur ce téléphone, quand j'ouvre l'écran de connexion, alors mon dernier identifiant est prérempli : il reste **3 gestes** (toucher le mot de passe, le saisir, « Se connecter »).
- CA-001.3 (erreur) : Quand l'identifiant ou le mot de passe est faux, ou que le compte est désactivé, alors le message est identique dans tous les cas : « Identifiant ou mot de passe incorrect, ou compte inactif. Contactez votre administrateur. » Rien ne révèle si l'identifiant existe.
- CA-001.4 (blocage) : Étant donné 5 échecs d'affilée sur un identifiant (H-04), quand je réessaie dans les 15 minutes, alors la connexion est refusée avec « Trop d'essais, réessayez plus tard », même avec le bon mot de passe. L'événement est noté dans le journal des connexions.
- CA-001.5 (hors ligne, jamais connecté) : Étant donné aucune session sur ce téléphone et pas de réseau, quand j'appuie sur « Se connecter », alors un message clair dit « Première connexion : réseau nécessaire » avec un bouton « Réessayer ». Pas d'écran blanc, pas de chargement sans fin.
- CA-001.6 (double appui) : Quand j'appuie deux fois de suite sur « Se connecter », alors une seule demande part (le bouton est inactif pendant l'envoi).
- CA-001.7 (premier mot de passe) : Étant donné un mot de passe provisoire donné par l'Admin, quand je me connecte pour la première fois, alors je dois en choisir un nouveau (longueur minimale paramétrable, proposée : 8 caractères) avant d'aller plus loin.
- CA-001.8 (langue) : Quand j'ouvre l'écran de connexion, alors je peux choisir français ou arabe avant de me connecter ; le choix s'applique immédiatement.
- CA-001.9 (confort terrain) : Le mot de passe est masqué avec un bouton « afficher » ; les champs et boutons respectent H-16.
- CA-001.10 (rôle) : Après connexion, seuls les écrans et boutons autorisés pour mon rôle apparaissent (voir US-SOCLE-003).

### US-SOCLE-002 : Rester utilisable sans réseau, puis me déconnecter sans rien perdre  ·  Indispensable
En tant que chef de chantier, je veux que l'application s'ouvre sans réseau après ma première connexion afin de travailler toute la journée sur le terrain.

**Critères d'acceptation**
- CA-002.1 (nominal) : Étant donné une session ouverte il y a moins de 14 jours (H-05), quand j'ouvre l'application sans réseau, alors j'arrive directement sur « Mes chantiers », sans me reconnecter.
- CA-002.2 (session trop ancienne) : Étant donné plus de 14 jours sans réseau, quand j'ouvre l'application, alors la connexion est demandée. Mes saisies non envoyées sont conservées et partent après reconnexion **avec le même compte**.
- CA-002.3 (déconnexion avec envois en attente) : Étant donné N saisies non envoyées, quand j'appuie sur « Se déconnecter », alors un écran dit « N saisies ne sont pas encore envoyées » avec les boutons « Envoyer d'abord » et « Rester connecté » en gros et en premier ; « Se déconnecter quand même » est petit, en dernier, et demande une seconde confirmation.
- CA-002.4 (téléphone partagé) : Étant donné que A se déconnecte puis que B se connecte sur le même téléphone, alors B ne voit aucun chantier, zone ni saisie en attente de A ; les données de A sont effacées du téléphone à sa déconnexion (hors saisies en attente conservées pour A seul, CA-002.2).
- CA-002.5 (compte désactivé ou retiré) : Étant donné que l'Admin désactive mon compte, quand mon téléphone se synchronise, alors l'accès est refusé, un message « Accès retiré, contactez votre administrateur » s'affiche et les données chantier sont effacées du téléphone. Le serveur n'enregistre jamais de saisie au nom d'un compte désactivé (voir question Q-09).
- CA-002.6 (mauvais chantier) : Une saisie en attente qui vise un chantier qui ne m'est plus affecté est refusée au moment de l'envoi, mise de côté dans « À vérifier » avec le motif, et jamais perdue sans que je le voie (voir US-SOCLE-012).

### US-SOCLE-003 : Chaque rôle ne voit et ne fait que ce qui le concerne  ·  Indispensable
En tant que conducteur de travaux, je veux que les droits soient respectés afin que personne ne modifie ou ne voie ce qui ne le concerne pas.

**Critères d'acceptation**
- CA-003.1 (nominal) : Pour chacun des 6 rôles, les actions de la matrice « Droits par rôle » sont possibles et celles marquées « — » sont absentes de l'écran (bouton non affiché, pas seulement grisé).
- CA-003.2 (mauvais rôle, côté serveur) : Quand un ChefEquipe tente quand même une action interdite (par exemple ajouter une zone), alors le serveur la refuse (« Action non autorisée pour votre rôle ») et rien n'est enregistré.
- CA-003.3 (rôle changé hors ligne) : Étant donné qu'un Admin retire un droit à un utilisateur qui a déjà saisi hors ligne, quand ses saisies arrivent, alors celles qui ne sont plus permises sont refusées avec le motif dans « À vérifier » ; les autres passent.
- CA-003.4 (Direction en lecture) : Un utilisateur Direction n'a aucun bouton de création ou de modification dans le socle.
- CA-003.5 (données sensibles) : Pour un ChefEquipe ou Achats, le montant du marché est **absent** des réponses du serveur et du stockage local du téléphone (pas seulement caché à l'écran).
- CA-003.6 (changement de rôle) : Le nouveau rôle s'applique à la prochaine connexion ou synchronisation ; l'ancien et le nouveau rôle, qui l'a changé et quand, sont conservés (US-SOCLE-016).

### US-SOCLE-004 : Gérer les comptes utilisateurs  ·  Indispensable
En tant qu'administrateur, je veux créer et désactiver des comptes afin que seules les bonnes personnes accèdent à l'application.

**Critères d'acceptation**
- CA-004.1 (nominal) : Quand je crée un compte avec nom complet, identifiant, rôle et langue, alors le compte existe, actif, avec un mot de passe provisoire à communiquer à la personne ; il m'est montré une seule fois.
- CA-004.2 (doublon) : Étant donné un identifiant déjà utilisé, quand je valide, alors la création est refusée avec « Identifiant déjà utilisé ». Deux appuis rapides sur « Créer » ne créent qu'un seul compte.
- CA-004.3 (champ manquant) : Sans nom complet, identifiant ou rôle, la création est refusée et le champ fautif est indiqué ; le rôle n'a **pas** de valeur par défaut (choix volontaire pour éviter un rôle trop large).
- CA-004.4 (mauvais rôle) : Un utilisateur non Admin n'a pas accès à cet écran, ni par un lien direct.
- CA-004.5 (désactivation) : Quand je désactive un compte, alors il ne peut plus se connecter ni se synchroniser ; son nom reste affiché dans l'historique. Un compte n'est jamais supprimé.
- CA-004.6 (dernier Admin) : Le dernier Admin actif ne peut être ni désactivé ni rétrogradé : « Il doit rester au moins un administrateur actif ».
- CA-004.7 (réinitialisation) : Je peux réinitialiser un mot de passe : un nouveau mot de passe provisoire est généré ; l'ancien ne marche plus ; l'utilisateur doit en choisir un autre (CA-001.7).
- CA-004.8 (grande liste) : Avec 200 comptes, la liste se filtre par nom, rôle et état (actif / désactivé) et s'affiche par pages ; la recherche répond en moins de 2 s.
- CA-004.9 (hors ligne) : La gestion des comptes est faite sur le web, avec réseau ; sur le téléphone, elle n'existe pas.

### US-SOCLE-005 : Affecter un utilisateur à un chantier  ·  Indispensable
En tant qu'administrateur, je veux affecter des personnes à un chantier afin qu'elles ne voient que celui-là.

**Critères d'acceptation**
- CA-005.1 (nominal) : Depuis la fiche chantier, quand je choisis un utilisateur dans la liste (avec recherche) et valide « Affecter », alors il voit ce chantier dans « Mes chantiers » à sa prochaine synchronisation.
- CA-005.2 (aussi depuis le compte) : Depuis la fiche d'un utilisateur, je peux affecter plusieurs chantiers d'un coup.
- CA-005.3 (doublon) : Étant donné un utilisateur déjà affecté, quand je l'affecte à nouveau (ou en double appui), alors il n'y a toujours qu'une affectation et le message dit « Déjà affecté ».
- CA-005.4 (retrait immédiat côté serveur) : Quand je retire une affectation, alors l'accès du serveur est coupé **tout de suite** : toute demande de cet utilisateur pour ce chantier est traitée comme si le chantier n'existait pas.
- CA-005.5 (retrait, téléphone hors ligne) : À la prochaine synchronisation, le chantier disparaît de « Mes chantiers » et ses données sont effacées du téléphone. Les saisies non envoyées sur ce chantier vont dans « À vérifier » (CA-002.6).
- CA-005.6 (compte désactivé) : On ne peut pas affecter un compte désactivé.
- CA-005.7 (mauvais rôle) : Seul l'Admin affecte et retire (question Q-05 : le ConducteurTravaux pour ses chantiers ?).
- CA-005.8 (grande liste) : La liste des personnes affectées à un chantier se filtre par rôle ; la liste des utilisateurs aussi.
- CA-005.9 (trace) : Chaque affectation et retrait garde qui, quand, quel utilisateur, quel chantier.

### US-SOCLE-006 : Voir « Mes chantiers »  ·  Indispensable
En tant que chef de chantier, je veux voir la liste de mes chantiers dès l'ouverture afin d'entrer sur le bon en 1 geste.

**Critères d'acceptation**
- CA-006.1 (nominal) : Étant donné que je suis ChefChantier affecté seulement à « École UV18 », quand j'ouvre « Mes chantiers », alors je vois **uniquement** `CH-ECO-UV18` ; le chantier `CH-LOG-OL40` n'apparaît nulle part (liste, recherche, sélecteurs, messages).
- CA-006.2 (jamais un chantier non affecté) : Étant donné un chantier qui existe mais qui ne m'est pas affecté, quand je le demande directement (lien, identifiant copié, code saisi, zone ou fiche de ce chantier), alors la réponse est « introuvable », **identique** à celle d'un chantier qui n'existe pas (même message, même code de réponse). Même règle pour les zones, les listes, les recherches et les exports du chantier.
- CA-006.3 (utilisateur non affecté) : Étant donné un compte sans aucune affectation, quand j'ouvre « Mes chantiers », alors je vois « Aucun chantier ne vous est affecté. Contactez votre administrateur. » et un bouton « Actualiser ».
- CA-006.4 (rapide) : Chaque ligne montre le code, le nom (dans ma langue), la commune et la wilaya ; je touche une ligne pour ouvrir : **1 geste**.
- CA-006.5 (hors ligne) : Sans réseau, la liste s'affiche en moins de 2 s à partir du téléphone, avec « Données du JJ/MM/AAAA HH:MM ».
- CA-006.6 (grande liste) : Avec 50 chantiers (cas Admin ou Direction), une recherche par nom ou code apparaît, les 20 premiers s'affichent en moins de 2 s, et la liste se charge au fil du défilement.
- CA-006.7 (chantier courant) : Le chantier courant est repéré (marque + premier de la liste). Voir US-SOCLE-010.
- CA-006.8 (archivés) : Les chantiers archivés sont masqués par défaut ; un filtre « Afficher les archivés » les montre en lecture seule.
- CA-006.9 (Admin) : L'Admin voit tous les chantiers (H-02) ; les autres rôles ne voient que leurs affectations, y compris la Direction.

### US-SOCLE-007 : Consulter la fiche d'un chantier  ·  Indispensable
En tant que chef d'équipe, je veux ouvrir la fiche du chantier afin de retrouver où il est, qui y travaille et ses zones.

**Critères d'acceptation**
- CA-007.1 (nominal) : La fiche montre : code, nom, type d'ouvrage, wilaya, commune, position GPS (si connue), maître d'ouvrage, n° de marché, montant (selon le rôle), délai en jours, date de l'ODS de démarrage, **fin contractuelle calculée**, zones, personnes affectées (nom, rôle, jamais le téléphone), créé par / modifié par.
- CA-007.2 (calcul) : Étant donné l'ODS du 02/03/2026 et un délai de 540 jours, alors la fin contractuelle affichée est **24/08/2027**. Calcul fait par le serveur (voir « Règles de calcul »).
- CA-007.3 (donnée manquante) : Étant donné un chantier sans date d'ODS ou sans délai, alors la fin contractuelle affiche « À définir » (pas d'erreur, pas de date inventée).
- CA-007.4 (droits) : Le montant n'apparaît que pour Admin, Direction et ConducteurTravaux (H-06) ; pour les autres, la ligne n'existe pas.
- CA-007.5 (hors ligne) : Toute la fiche est disponible sans réseau, sauf la carte. Le bouton « Voir sur la carte » est remplacé par les coordonnées écrites ; il n'y a aucune erreur.
- CA-007.6 (arabe) : En arabe, la fiche est lue de droite à gauche ; les codes, dates, montants et cotes restent lisibles de gauche à droite (US-SOCLE-013).
- CA-007.7 (mauvais chantier) : Une fiche non affectée est « introuvable » (CA-006.2).
- CA-007.8 (montants) : Le montant est affiché en DZD avec 2 décimales et des séparateurs de milliers : « 185 000 000,00 DZD ».

### US-SOCLE-008 : Créer, modifier et archiver un chantier  ·  Indispensable
En tant qu'administrateur, je veux créer un chantier afin que les équipes puissent y saisir.

**Critères d'acceptation**
- CA-008.1 (nominal) : Quand je renseigne les champs obligatoires et valide, alors le chantier est créé avec son code unique ; je peux enchaîner sur « Affecter des personnes » et « Ajouter des zones ».
- CA-008.2 (code) : Le code (par exemple `CH-ECO-UV18`) est proposé automatiquement à partir du type d'ouvrage et du nom, modifiable **avant** la création, unique, jamais modifiable ensuite.
- CA-008.3 (doublon) : Un code déjà pris est refusé avec un message clair. Deux appuis rapides sur « Créer » ne créent qu'un seul chantier.
- CA-008.4 (date incomplète) : Une date d'ODS du type « ../08/2026 » est refusée (`DATE_INVALIDE`). La date se choisit avec un calendrier, jamais au clavier libre.
- CA-008.5 (délai) : Le délai est un nombre entier de jours supérieur à 0 ; sinon `QUANTITE_INVALIDE`. L'unité « jours » est affichée à côté du champ et ne se tape pas ; le montant est toujours en DZD.
- CA-008.6 (wilaya, commune) : La wilaya se choisit dans une liste, puis la commune dans la liste de cette wilaya (avec recherche). Par défaut, la wilaya du dernier chantier créé.
- CA-008.7 (mauvais rôle) : Seul l'Admin voit les boutons « Créer », « Modifier », « Archiver ».
- CA-008.8 (archivage) : Un chantier archivé ne reçoit plus de nouvelle saisie ; son historique, ses numéros et ses zones restent consultables. Il peut être réactivé par l'Admin.
- CA-008.9 (modification simultanée) : Si deux Admin modifient la fiche en même temps, le second reçoit « Modifié entre-temps par <nom> » et choisit de recharger ; aucune modification n'en écrase une autre sans qu'on le sache.
- CA-008.10 (hors ligne) : Cet écran est disponible sur le web avec réseau ; pas sur le téléphone.

### US-SOCLE-009 : Choisir une zone (bloc, cote, local)  ·  Indispensable
En tant que chef de chantier, je veux choisir « où » en 3 gestes afin que chaque saisie future soit bien localisée.

**Critères d'acceptation**
- CA-009.1 (nominal) : Le sélecteur de zone propose Bloc, puis Cote, puis Local, avec la **dernière zone utilisée** préchoisie. Pour rester sur la même zone : 1 geste (« Valider »). Pour changer de local : 3 gestes au plus.
- CA-009.2 (affichage) : Une zone s'écrit « Bloc 01 · +3,40 m · Classe 02 ». La cote est toujours signée (+3,40 · −1,90) et **±0,00** pour zéro, avec 2 décimales et la virgule en français comme en arabe. Les cotes sont triées du plus bas au plus haut (−1,90, ±0,00, +3,40, +6,80, +10,20).
- CA-009.3 (hors ligne) : Toutes les zones de mes chantiers sont disponibles sans réseau.
- CA-009.4 (grande liste) : Avec 300 zones (10 blocs), le choix par étapes évite de défiler, et une recherche libre (« cl 02 ») retrouve « Classe 02 » en moins de 2 s.
- CA-009.5 (mauvais chantier) : Un sélecteur ne montre jamais les zones d'un autre chantier. Si une saisie envoie une zone qui n'appartient pas au chantier de la saisie, le serveur la refuse avec « Cette zone n'appartient pas à ce chantier ».
- CA-009.6 (zone archivée) : Une zone archivée n'est plus proposée pour une nouvelle saisie, mais reste affichée dans les anciennes saisies.
- CA-009.7 (zone facultative) : Selon la future fonctionnalité, la zone peut être facultative ; le sélecteur sait alors afficher « Non précisée ».

### US-SOCLE-010 : Retrouver mon chantier courant partout  ·  Important
En tant que chef de chantier, je veux que mon dernier chantier soit déjà choisi afin de ne pas le re-sélectionner à chaque saisie.

**Critères d'acceptation**
- CA-010.1 (nominal) : Quand j'ouvre un chantier, il devient mon chantier courant ; son code et son nom court sont visibles en haut de chaque écran. Tout formulaire s'ouvre avec ce chantier prérempli.
- CA-010.2 (un seul chantier) : Si un seul chantier m'est affecté, il est courant dès la première connexion. S'il y en a plusieurs et aucun courant, je dois en choisir un avant toute saisie.
- CA-010.3 (changer) : Je change de chantier courant en **2 gestes** (toucher l'en-tête, toucher un chantier), même sans réseau.
- CA-010.4 (perte d'affectation) : Si mon chantier courant ne m'est plus affecté, alors il n'est plus courant, un message m'en informe et je dois en choisir un autre.
- CA-010.5 (téléphone partagé) : Le chantier courant est propre à chaque utilisateur ; il n'est jamais repris par un autre compte sur le même téléphone.
- CA-010.6 (anti-erreur) : Quand le chantier courant change, les formulaires déjà ouverts affichent clairement l'ancien chantier ; ils ne sont pas basculés en silence.

### US-SOCLE-011 : Ajouter ou renommer une zone  ·  Important
En tant que chef de chantier, je veux ajouter une zone depuis le terrain afin de saisir tout de suite quand un nouveau local apparaît.

**Critères d'acceptation**
- CA-011.1 (nominal) : Depuis la fiche, « + Zone » ouvre un écran où le bloc et la cote sont préchoisis (dernier bloc, dernière cote utilisés). Je choisis le type de local dans une liste (Classe, Couloir, Cantine, Réfectoire, Cuisine, Bureau, Sanitaires, Local technique, Façade, Autre), j'ajuste le numéro avec « + / − », puis « Enregistrer ». **5 gestes** depuis « Mes chantiers », moins de 30 s.
- CA-011.2 (nouvelle cote) : Si la cote n'existe pas, « Autre cote » ouvre un clavier numérique avec une touche +/− ; « 3,4 » et « 3.4 » donnent +3,40 m. Ce cas, plus long (8 gestes), est accepté car rare (une fois par niveau).
- CA-011.3 (unité et plage) : L'unité de la cote est toujours le mètre, affichée et non modifiable. Une cote hors de −20,00 à +60,00 (H-15) est refusée avec un message clair. Des lettres sont impossibles à saisir.
- CA-011.4 (doublon) : Une zone avec le même bloc, la même cote et le même local existe déjà : message « Cette zone existe déjà » et l'écran ouvre la zone existante. Un double appui sur « Enregistrer » crée une seule zone.
- CA-011.5 (hors ligne) : Sans réseau, la zone est créée sur le téléphone avec la marque « En attente d'envoi » et peut servir tout de suite dans d'autres écrans.
- CA-011.6 (même zone créée par deux personnes hors ligne) : À la synchronisation, la première arrivée reste ; la seconde est fusionnée avec elle (pas de doublon) et les saisies de la seconde pointent vers la zone retenue ; personne n'est prévenu d'une « erreur » inutile.
- CA-011.7 (renvoi) : Une zone renvoyée deux fois par un mauvais réseau n'apparaît qu'une seule fois (même identifiant unique de saisie).
- CA-011.8 (mauvais rôle) : Le bouton « + Zone » n'existe pas pour ChefEquipe, Achats ni Direction ; le serveur refuse aussi (CA-003.2).
- CA-011.9 (mauvais chantier) : Impossible d'ajouter une zone à un chantier non affecté (« introuvable ») ou archivé.
- CA-011.10 (archiver) : ConducteurTravaux et Admin archivent une zone avec confirmation. Elle disparaît des choix mais pas de l'historique.
- CA-011.11 (grande liste) : Le choix des blocs et cotes existants se fait par pastilles ; au-delà de 8 valeurs, une recherche s'affiche.

### US-SOCLE-012 : Savoir ce que je vois sans réseau  ·  Indispensable
En tant que chef de chantier, je veux savoir exactement ce qui marche hors ligne afin de ne pas être bloqué au milieu d'un coulage.

| Disponible sans réseau | Nécessite le réseau |
|---|---|
| Ouvrir l'application (session de moins de 14 jours) | Première connexion, changement de mot de passe |
| Mes chantiers, fiche chantier (hors carte), zones, noms des personnes affectées | Carte, nouvelles affectations, nouveaux chantiers |
| Ajouter une zone (ChefChantier, ConducteurTravaux) | Gestion des comptes, des affectations et des chantiers (web) |
| Changer de langue, de chantier courant | Recevoir les modifications faites par les autres |
| Voir et corriger les envois en attente | |

**Critères d'acceptation**
- CA-012.1 (nominal) : Étant donné le mode avion, quand j'ouvre l'application, alors j'atteins « Mes chantiers » en moins de 3 s ; aucun message d'erreur réseau bloquant n'apparaît.
- CA-012.2 (première préparation) : Après la première connexion, un écran « Préparation de vos chantiers… » montre l'avancement chantier par chantier ; je peux utiliser les chantiers déjà reçus. Si le réseau coupe, la préparation reprend où elle s'était arrêtée.
- CA-012.3 (coupure en cours de saisie) : Si le réseau tombe au moment d'enregistrer, la saisie est gardée sur le téléphone, marquée « En attente d'envoi », sans message d'échec ni perte.
- CA-012.4 (réseau faible) : Sur un réseau très lent ou instable, la synchronisation avance par petits lots, reprend après coupure et ne bloque jamais l'écran : je peux continuer à saisir.
- CA-012.5 (données anciennes) : Au-delà de 24 h sans synchronisation (H-12), un bandeau non bloquant dit « Données du JJ/MM/AAAA HH:MM ».
- CA-012.6 (chantier non affecté absent du téléphone) : Aucune donnée d'un chantier non affecté (ni zones, ni fiche) n'est présente sur le téléphone, même cachée, après une synchronisation.
- CA-012.7 (champs réservés) : Les champs réservés à d'autres rôles (montant du marché) ne sont jamais enregistrés sur le téléphone.
- CA-012.8 (fonction web seule) : Sur le téléphone, une fonction réservée au web n'est pas proposée (pas de bouton qui échoue).

### US-SOCLE-013 : Voir l'état de mes envois (indicateur de synchronisation)  ·  Indispensable
En tant que chef de chantier, je veux voir d'un coup d'œil si mes saisies sont parties afin de ne rien perdre.

| État | Texte (FR) | Texte (AR) | Quand |
|---|---|---|---|
| À jour | À jour · 07:42 | محدّث · 07:42 | Tout est envoyé, dernière synchronisation réussie |
| Hors ligne | Hors ligne | بدون اتصال | Pas de réseau, rien en attente |
| En attente | 3 à envoyer | 3 في انتظار الإرسال | Saisies créées, pas encore envoyées |
| En cours | Synchronisation… | جارٍ المزامنة… | Envoi ou réception en cours |
| Problème | 2 à vérifier | 2 للمراجعة | Saisies refusées par le serveur : à corriger ou abandonner |

**Critères d'acceptation**
- CA-013.1 (nominal) : L'état est affiché en haut de **tous** les écrans, avec une icône **et** un texte (pas la couleur seule : lisible au soleil).
- CA-013.2 (exactitude) : Après 3 zones créées hors ligne, l'indicateur affiche « 3 à envoyer » ; une fois le réseau revenu et l'envoi réussi, « À jour » avec l'heure.
- CA-013.3 (détail) : Toucher l'indicateur ouvre « Envois en attente » : liste (type, libellé, date et heure de saisie, état) et un gros bouton « Synchroniser maintenant ».
- CA-013.4 (automatique) : La synchronisation part toute seule quand le réseau revient, à l'ouverture de l'application, et à intervalle régulier quand elle est ouverte (proposé : 5 minutes, paramétrable).
- CA-013.5 (double appui) : Deux appuis sur « Synchroniser maintenant » lancent une seule synchronisation.
- CA-013.6 (renvoi, pas de doublon) : Une saisie envoyée deux fois (coupure au mauvais moment) n'existe qu'une fois sur le serveur et n'est comptée qu'une fois ; son numéro n'avance pas deux fois.
- CA-013.7 (refus) : Une saisie refusée reste dans « À vérifier » avec le motif en français ou en arabe (par exemple « La date est incomplète »), et deux choix : « Corriger » ou « Abandonner » (avec confirmation). Elle n'est jamais supprimée sans que l'utilisateur le décide.
- CA-013.8 (date complète) : La dernière synchronisation réussie s'écrit « aujourd'hui HH:MM » ou « JJ/MM/AAAA HH:MM » ; jamais une date partielle.
- CA-013.9 (mauvaise personne) : L'indicateur et la liste ne comptent que mes saisies.
- CA-013.10 (grande liste) : Avec 200 saisies en attente après plusieurs jours sans réseau, l'envoi se fait par lots, la liste reste fluide et chaque saisie conserve son ordre de création.

### US-SOCLE-014 : Utiliser l'application en français et en arabe  ·  Indispensable
En tant que chef d'équipe arabophone, je veux l'application en arabe, de droite à gauche, afin de la comprendre sans effort.

**Critères d'acceptation**
- CA-014.1 (nominal) : Je change de langue en 2 gestes depuis les réglages (et depuis l'écran de connexion) ; l'écran change immédiatement, même sans réseau, sans redémarrage. Le choix est mémorisé pour mon compte.
- CA-014.2 (défaut) : La langue par défaut d'un nouveau compte est le français, choisie par l'Admin à la création.
- CA-014.3 (miroir) : En arabe, l'écran est inversé : flèche de retour, listes, onglets, indicateur de synchronisation, alignement du texte.
- CA-014.4 (nombres) : En arabe, les nombres, cotes, codes et dates restent lisibles de gauche à droite : « +3,40 m », « CH-ECO-UV18 », « 24/08/2027 », « DEM-001 » ne sont jamais retournés ni écrits « 3,40+ ».
- CA-014.5 (rien en dur) : Tous les textes (écrans, messages d'erreur du serveur, états de synchronisation, noms de rôles, types de local) existent en français **et** en arabe ; aucun texte brut du type « error.date_invalid » n'est visible.
- CA-014.6 (noms de chantier) : Le nom arabe d'un chantier s'affiche en arabe s'il existe, sinon le nom français (H-20).
- CA-014.7 (formats) : Dates JJ/MM/AAAA, heures sur 24 h, virgule décimale, séparateur de milliers en espace, chiffres 0 à 9 dans les deux langues (H-10).
- CA-014.8 (lisibilité) : Texte courant d'au moins 16 sp, valeurs clés (code chantier, cote) d'au moins 20 sp, fort contraste (soleil) ; à valider sur un téléphone en plein jour.
- CA-014.9 (messages de validation) : Les codes `UNITE_OBLIGATOIRE`, `DATE_INVALIDE`, `QUANTITE_INVALIDE`, `EXPRESSION_INVALIDE`, `TRANSITION_INTERDITE`, `UNITES_INCOMPATIBLES` ont un message clair dans les deux langues.

### US-SOCLE-015 : Numérotation par chantier  ·  Indispensable (fondation technique)
En tant que conducteur de travaux, je veux que chaque demande, livraison, tâche, problème et situation ait un numéro propre à son chantier afin de les citer sans confusion (« DEM-014 de l'école »).

**Critères d'acceptation**
- CA-015.1 (nominal) : Chaque chantier a ses compteurs indépendants pour DEM, LIV, T, PB et SIT, qui démarrent à 001. La première demande de l'École UV18 est `DEM-001` ; la première demande de `CH-LOG-OL40` est aussi `DEM-001`.
- CA-015.2 (donné par le serveur) : Le numéro est donné par le serveur à la réception. Sur le téléphone, une saisie non envoyée affiche « DEM · numéro en attente » ; le téléphone n'invente jamais de numéro.
- CA-015.3 (pas de doublon) : Si deux personnes créent chacune une demande au même moment sur le même chantier, elles reçoivent deux numéros différents, qui se suivent.
- CA-015.4 (renvoi) : Une saisie renvoyée avec le même identifiant unique ne consomme pas de nouveau numéro.
- CA-015.5 (jamais réutilisé) : Un numéro d'une saisie annulée ou archivée n'est pas réattribué ; un trou dans la suite est normal.
- CA-015.6 (format) : Au moins 3 chiffres ; au-delà de 999, le numéro s'allonge (`DEM-1000`), sans troncature.
- CA-015.7 (immuable) : Un numéro ne change jamais après attribution.
- CA-015.8 (zones) : Les zones ne sont pas numérotées (H-07) : elles sont repérées par leur libellé (« Bloc 01 · +3,40 m · Classe 02 »).
- CA-015.9 (vérifiable) : Cette histoire se contrôle par des essais automatiques sur le serveur ; elle n'a pas d'écran propre dans le socle.

### US-SOCLE-016 : Savoir qui a fait quoi, et quand  ·  Indispensable
En tant que direction, je veux savoir qui a créé ou modifié une information afin de retrouver une responsabilité en cas de litige.

**Critères d'acceptation**
- CA-016.1 (nominal) : Chaque chantier, zone, compte et affectation conserve : créé par, créé le, modifié par, modifié le. La fiche affiche « Créé par <nom> le JJ/MM/AAAA HH:MM · Modifié par <nom> le JJ/MM/AAAA HH:MM ».
- CA-016.2 (heure de référence) : Les dates et heures de création et de modification sont celles du serveur, jamais l'heure du téléphone. Pour une saisie faite hors ligne, l'heure de saisie sur le téléphone est conservée à part (« saisi le ») ; les deux sont visibles dans l'historique détaillé.
- CA-016.3 (historique) : L'historique détaillé (rôles Admin, Direction, ConducteurTravaux) liste les changements : qui, quand, ancienne valeur, nouvelle valeur. Il couvre aussi les changements de rôle, d'affectation, d'activation de compte et d'archivage.
- CA-016.4 (rien d'effacé) : Aucune donnée n'est détruite : un élément « supprimé » est archivé avec qui et quand ; l'Admin peut le consulter.
- CA-016.5 (journal des connexions) : L'Admin voit pour chaque connexion : date et heure, compte, réussite ou échec. Aucun mot de passe n'y figure.
- CA-016.6 (modification simultanée) : Voir CA-008.9 : la valeur d'un autre n'est jamais écrasée sans avertissement.
- CA-016.7 (mauvais rôle) : Achats, ChefChantier et ChefEquipe voient « créé par / modifié par » mais pas les anciennes valeurs.

### US-SOCLE-017 : Aucune donnée personnelle dans les journaux techniques  ·  Indispensable
En tant que responsable de la protection des données, je veux que les téléphones et noms ne traînent nulle part afin de respecter les personnes.

**Critères d'acceptation**
- CA-017.1 (journaux) : Étant donné les données de démonstration (téléphones fictifs `0550 00 00 11` à `0550 00 00 17`), quand je réalise connexion réussie, connexion échouée, synchronisation, ajout de zone et une erreur volontaire, alors une recherche de ces numéros, des noms complets, des mots de passe et des jetons de session dans **tous** les journaux du serveur, du web et du mobile ne trouve **rien**. Le compte n'y est désigné que par un numéro interne anonyme.
- CA-017.2 (messages d'erreur) : Aucun message d'erreur affiché ne contient le nom, l'identifiant ou le téléphone d'une personne.
- CA-017.3 (rapports de plantage et statistiques) : Mêmes interdits.
- CA-017.4 (réponses) : Le téléphone d'un compte n'est présent dans les réponses du serveur que pour l'Admin et le titulaire (H-17) ; pas seulement caché à l'écran.
- CA-017.5 (jeux de test et captures) : Les jeux de test, documents et captures n'utilisent que des noms et numéros fictifs (voir « Données de démonstration »).
- CA-017.6 (téléphone perdu) : Étant donné un téléphone perdu, quand l'Admin désactive le compte, alors à la prochaine connexion du téléphone l'accès est refusé (CA-002.5). Voir question Q-10 sur le verrouillage du téléphone lui-même.

### US-SOCLE-018 : Données de démonstration « École UV18 »  ·  Indispensable
En tant que testeur ou formateur, je veux un chantier réaliste prêt à l'emploi afin de démontrer et vérifier toutes les règles ci-dessus.

**Critères d'acceptation**
- CA-018.1 (nominal) : Après chargement des données de démonstration : 2 chantiers, 7 comptes, 26 zones pour l'École UV18 (détail ci-dessous), les affectations du tableau.
- CA-018.2 (répétable) : Charger deux fois les données de démonstration ne crée aucun doublon.
- CA-018.3 (jamais en production) : Ces données et ces comptes n'existent qu'en développement et démonstration ; mot de passe de développement unique, lu dans la configuration locale, jamais dans le code ni dans ce document ; absent de la production.
- CA-018.4 (cas à vérifier) : (a) `chef.dev` voit 1 chantier ; (b) `conducteur.dev` en voit 2 ; (c) `nonaffecte.dev` n'en voit aucun ; (d) la demande directe de `CH-LOG-OL40` par `chef.dev` répond « introuvable » ; (e) la fin contractuelle de l'École UV18 est 24/08/2027 ; (f) `equipe.dev` ne voit pas le montant du marché.

## Données de démonstration (fictives)

### Chantiers
| Code | Nom | Type | Wilaya / commune | Maître d'ouvrage | N° de marché | Montant | Délai | ODS de démarrage | Fin contractuelle |
|---|---|---|---|---|---|---|---|---|---|
| `CH-ECO-UV18` | École UV18 | École | Blida / Boufarik | Direction des équipements publics (fictive) | M-2026-UV18-001 | 185 000 000,00 DZD | 540 jours | 02/03/2026 | 24/08/2027 |
| `CH-LOG-OL40` | 40 logements Les Oliviers | Logements | Blida / Boufarik | Office de promotion immobilière (fictif) | M-2026-OL40-007 | 96 400 000,00 DZD | 420 jours | 15/06/2026 | 09/08/2027 |

Vérification de la fin du second chantier : 15/06/2026 + 420 jours. De 15/06/2026 à 15/06/2027, 365 jours ; reste 55 jours : 15/06 + 15 j = 30/06 ; + 31 j = 31/07 (46 jours) ; + 9 j = 09/08/2027. Total 15 + 31 + 9 = 55. Exact.

### Comptes (identifiants de développement)
| Identifiant | Nom (fictif) | Rôle | Téléphone fictif | Chantiers affectés |
|---|---|---|---|---|
| `admin.dev` | Farid L. | Admin | 0550 00 00 11 | tous (H-02) |
| `direction.dev` | Meriem S. | Direction | 0550 00 00 12 | UV18, OL40 |
| `conducteur.dev` | Slimane H. | ConducteurTravaux | 0550 00 00 13 | UV18, OL40 |
| `achats.dev` | Amel R. | Achats | 0550 00 00 14 | UV18, OL40 |
| `chef.dev` | Mourad B. | ChefChantier | 0550 00 00 15 | UV18 seulement |
| `equipe.dev` | Toufik G. | ChefEquipe | 0550 00 00 16 | UV18 seulement |
| `nonaffecte.dev` | Nadia Z. | ChefChantier | 0550 00 00 17 | **aucun** |

### Zones de l'École UV18 : 26 zones
| Groupe | Contenu | Nombre |
|---|---|---|
| Blocs entiers | Bloc 01, Bloc 02 | 2 |
| Cotes du Bloc 01 | −1,90 · ±0,00 · +3,40 · +6,80 · +10,20 | 5 |
| Locaux du Bloc 01, rez-de-chaussée (±0,00) | Classe 01 à Classe 06, Couloir | 7 |
| Locaux du Bloc 01, 1er étage (+3,40) | Classe 01 à Classe 06, Couloir | 7 |
| Cote du Bloc 02 | ±0,00 | 1 |
| Locaux du Bloc 02 | Cantine, Réfectoire, Cuisine (±0,00), Façade cantine (sans cote) | 4 |
| **Total** | 2 + 5 + 7 + 7 + 1 + 4 | **26** |

Le même nom de local (Classe 01) existe donc à deux cotes (±0,00 et +3,40) : c'est la combinaison bloc + cote + local qui est unique. `CH-LOG-OL40` : Bloc A (zone entière), cote ±0,00, cote +2,80 (3 zones). Les locaux de l'École UV18 correspondent aux locaux des situations de `donnees-test.md`.

Aucun nom de personne réelle, aucun vrai numéro, aucune vraie donnée de marché n'est utilisé.

## Champs

### Utilisateur
| Champ | Obligatoire | Type / unité | Valeurs possibles | Valeur par défaut |
|---|---|---|---|---|
| Nom complet | oui | texte | | |
| Identifiant | oui | texte, minuscules, sans espace, unique | | |
| Rôle | oui | liste | Admin · Direction · ConducteurTravaux · Achats · ChefChantier · ChefEquipe | aucune (choix volontaire) |
| Téléphone | non | texte, format algérien | | vide |
| Langue | oui | liste | français · arabe | français |
| État | oui | liste | actif · désactivé | actif |

### Chantier
| Champ | Obligatoire | Type / unité | Valeurs possibles | Valeur par défaut |
|---|---|---|---|---|
| Code | oui | `CH-XXX-XXXX` unique | | proposé par le serveur |
| Nom (français) | oui | texte | | |
| Nom (arabe) | non | texte | | vide (H-20) |
| Type d'ouvrage | oui | liste | École · Logements · Équipement public · Autre | École |
| Wilaya | oui | liste de référence | voir H-14 | wilaya du dernier chantier créé |
| Commune | oui | liste (dépend de la wilaya) | | |
| Position GPS | non | latitude, longitude (degrés décimaux) | | vide |
| Maître d'ouvrage | oui | texte (suggestions) | | dernier utilisé |
| N° de marché | non | texte | | |
| Montant du marché | non | DZD, 2 décimales | | |
| Délai | non | jours, entier > 0 | | |
| Date de l'ODS de démarrage | non | date complète (calendrier) | | |
| Fin contractuelle | calculée | date | | calculée par le serveur |
| État | oui | liste | actif · archivé | actif |

### Zone
| Champ | Obligatoire | Type / unité | Valeurs possibles | Valeur par défaut |
|---|---|---|---|---|
| Chantier | oui | lien | mes chantiers | chantier courant |
| Bloc | oui | liste + nouveau | Bloc 01, Bloc 02… | dernier bloc utilisé |
| Cote | non | mètres, 2 décimales, signée | −20,00 à +60,00 (H-15) | dernière cote utilisée |
| Type de local | non | liste | Classe · Couloir · Cantine · Réfectoire · Cuisine · Bureau · Sanitaires · Local technique · Façade · Autre | vide |
| Numéro du local | non | entier ≥ 1 | | 1 (ou suite du dernier numéro du même type) |
| Libellé libre | non | texte | seulement si type = Autre | vide |
| État | oui | liste | active · archivée | active |

### Affectation
| Champ | Obligatoire | Type / unité | Valeurs possibles | Valeur par défaut |
|---|---|---|---|---|
| Utilisateur | oui | lien (compte actif) | | |
| Chantier | oui | lien | | chantier ouvert à l'écran |
| État | oui | liste | active · retirée | active |

Une affectation concerne un utilisateur et un chantier ; elle ne porte pas de date de fin (H-13 : le retrait est tracé avec qui et quand).

## Règles de calcul
Ajoutées à `calculs.md` (section 7). Rappel :
- **Fin contractuelle** = date de l'ODS + délai (en jours calendaires, H-09). Exemples recalculés :
  - 02/03/2026 + 540 j = **24/08/2027** (365 j jusqu'au 02/03/2027, puis 175 j : 29 j de mars, 30 d'avril, 31 de mai, 30 de juin, 31 de juillet, 24 d'août).
  - 15/06/2026 + 420 j = **09/08/2027** (voir vérification ci-dessus).
  - 15/01/2026 + 30 j = **14/02/2026**.
  - 01/03/2027 + 366 j = **01/03/2028** (année bissextile 2028 : le 29/02/2028 est compté).
- **Affichage de la cote** : valeur positive « +3,40 », négative « −1,90 », zéro « ±0,00 ».
- **Compteurs** : prochain numéro = dernier numéro attribué du chantier et du type + 1, jamais réutilisé (CA-015).
- Aucun calcul de quantité dans le socle ; aucun total, donc aucune addition d'unités.

## Statuts et droits
| Objet | États | Qui change | Motif obligatoire |
|---|---|---|---|
| Compte | actif ↔ désactivé | Admin | non (tracé) |
| Chantier | actif ↔ archivé | Admin | non (tracé) |
| Zone | active ↔ archivée | Admin, ConducteurTravaux | non (tracé) |
| Affectation | active → retirée | Admin | non (tracé) |
| Saisie du téléphone | en attente → en cours → envoyée · en attente → à vérifier → corrigée ou abandonnée | automatique ; l'utilisateur corrige ou abandonne | oui, motif du refus affiché |

Les statuts des demandes, tâches, problèmes et situations ne font pas partie du socle.

## Écrans attendus
| Écran | Plateforme | Action principale | Gestes / temps visé |
|---|---|---|---|
| Connexion | mobile + web | Se connecter ; choisir la langue | 3 gestes si identifiant mémorisé |
| Mes chantiers | mobile + web | Ouvrir un chantier ; recherche si > 5 | 1 geste |
| Fiche chantier | mobile + web | Consulter ; « + Zone » (selon rôle) | 1 geste pour aller aux zones |
| Sélecteur de zone | mobile (réutilisable) | Choisir bloc, cote, local | 1 à 3 gestes |
| Ajouter une zone | mobile + web | Créer une zone | 5 gestes, moins de 30 s |
| Envois en attente | mobile | Synchroniser, corriger, abandonner | 1 geste pour synchroniser |
| Réglages | mobile + web | Langue, mot de passe, déconnexion | 2 gestes pour la langue |
| Chantiers (administration) | web | Créer, modifier, archiver | formulaire à une page |
| Comptes (administration) | web | Créer, désactiver, réinitialiser | formulaire à une page |
| Affectations (administration) | web | Affecter, retirer | par chantier et par utilisateur |
| Journal des connexions | web | Consulter | lecture |

## Couverture des cas obligatoires par histoire
« N/A » signifie qu'il n'y a rien à tester dans ce cas, avec la raison.

| Histoire | Nominal | Hors ligne | Unité / date manquante | Doublon | Mauvais rôle / chantier | Grande liste |
|---|---|---|---|---|---|---|
| 001 | .1 | .5 | N/A (aucune quantité ni date saisie) | .6 | .3 | N/A |
| 002 | .1 | .1 .2 | N/A | N/A | .4 .6 | N/A |
| 003 | .1 | .3 | N/A | N/A | .2 .5 | N/A |
| 004 | .1 | .9 | .3 | .2 | .4 | .8 |
| 005 | .1 | .5 | N/A | .3 | .7 .6 | .8 |
| 006 | .1 | .5 | N/A | N/A | .2 .3 | .6 |
| 007 | .1 | .5 | .3 | N/A | .4 .7 | N/A |
| 008 | .1 | .10 | .4 .5 | .3 | .7 | N/A |
| 009 | .1 | .3 | .7 | N/A | .5 | .4 |
| 010 | .1 | .3 | N/A | N/A | .4 .5 | N/A |
| 011 | .1 | .5 | .2 .3 | .4 .6 .7 | .8 .9 | .11 |
| 012 | .1 | .1 .3 | N/A | N/A | .6 .7 | N/A |
| 013 | .1 | .2 | N/A | .5 .6 | .9 | .10 |
| 014 | .1 | .1 | .9 | N/A | N/A | N/A |
| 015 | .1 | .2 | N/A | .3 .4 | N/A (technique) | .6 |
| 016 | .1 | .2 | N/A | N/A | .7 | N/A |
| 017 | .1 | N/A | N/A | N/A | .4 | N/A |
| 018 | .1 | N/A | N/A | .2 | .4 | N/A |

## Hors périmètre
- Pointage, intervenants, équipes, journal du jour, demandes, livraisons, tâches, coulages, essais, photos, problèmes, situations (autres fonctionnalités, qui utiliseront le socle).
- Statuts de chantier liés aux ODS d'arrêt et de reprise, réception provisoire et définitive.
- Double identification (SMS, code), connexion par téléphone, mot de passe oublié en libre-service (l'Admin réinitialise).
- Import des zones depuis un tableau, cartes hors ligne, notifications.
- Vue Direction avec tableaux de bord et rapports.

## Questions ouvertes
- [chef de chantier] Q-01 : Dans un chantier réel, comment découpez-vous les zones : bloc, cote, local, ou aussi « axes » ou « travées » ? Faut-il d'autres types de local que ceux proposés ?
- [direction] Q-02 : La Direction doit-elle voir **tous** les chantiers sans affectation individuelle (comme l'Admin) ? Hypothèse actuelle : non.
- [direction] Q-03 : Qui peut voir le montant du marché ? Le chef de chantier doit-il le connaître ?
- [conducteur de travaux] Q-04 : Le délai se compte-t-il en jours calendaires ou ouvrables, et le jour de l'ODS compte-t-il ? (H-09)
- [direction] Q-05 : Le ConducteurTravaux peut-il affecter ou retirer des personnes sur ses chantiers, ou seulement l'Admin ?
- [chef de chantier] Q-06 : Un même utilisateur peut-il avoir un rôle différent selon le chantier (par exemple chef d'équipe sur l'un, chef de chantier sur l'autre) ? (H-01)
- [chef de chantier] Q-07 : Combien de temps peut-on rester sans réseau sans pouvoir se reconnecter (14 jours proposés) ? Un code de verrouillage du téléphone est-il souhaité ?
- [chef de chantier] Q-08 : Les cantine, réfectoire et cuisine sont-ils dans un bloc à part ? Les « façades » sont-elles des zones à part entière ?
- [direction] Q-09 : Si un compte est désactivé alors que des saisies sont en attente sur son téléphone, faut-il les récupérer (par un autre compte) ou les abandonner ?
- [direction] Q-10 : Faut-il un blocage à distance du téléphone perdu, au-delà de la désactivation du compte ?
- [direction] Q-11 : Liste officielle des wilayas et communes à charger (58 ou 69 wilayas) : à confirmer sur le Journal officiel (joradp.dz) avant la mise en service. Le chantier d'une commune rattachée à une nouvelle wilaya garde-t-il l'ancienne ?
- [arabophone du terrain] Q-12 : Relire les traductions arabes (rôles, « bloc », « cote », « local », « synchronisation », états) : H-19.
- [chef de chantier] Q-13 : Le téléphone d'un collègue doit-il être visible par les chefs de chantier pour l'appeler ? Hypothèse actuelle : non, Admin seulement. (H-17)
- [chef de chantier] Q-14 : Les chiffres arabes orientaux (٠١٢٣) sont-ils souhaités ? Hypothèse actuelle : chiffres 0 à 9. (H-10)

## Vocabulaire FR / AR (à faire relire, H-19)
| Français | Arabe | Français | Arabe |
|---|---|---|---|
| Chantier | ورشة | Mes chantiers | ورشاتي |
| Zone | منطقة | Bloc | بلوك |
| Cote (niveau) | المنسوب | Local | محل |
| Classe | قسم | Couloir | رواق |
| Cantine | مطعم مدرسي | Réfectoire | قاعة الأكل |
| Cuisine | مطبخ | Façade | واجهة |
| Rez-de-chaussée | الطابق الأرضي | 1er étage | الطابق الأول |
| Se connecter | تسجيل الدخول | Se déconnecter | تسجيل الخروج |
| Identifiant | اسم المستخدم | Mot de passe | كلمة المرور |
| Synchroniser | مزامنة | Hors ligne | بدون اتصال |
| À envoyer | في انتظار الإرسال | À vérifier | للمراجعة |
| Maître d'ouvrage | صاحب المشروع | N° de marché | رقم الصفقة |
| Ordre de service (ODS) | أمر بالخدمة | Délai | الأجل |
| Wilaya | ولاية | Commune | بلدية |
| Archiver | أرشفة | Montant | المبلغ |
| Admin | المسؤول | Direction | الإدارة |
| ConducteurTravaux | مسؤول متابعة الأشغال | Achats | المشتريات |
| ChefChantier | رئيس الورشة | ChefEquipe | رئيس الفريق |
