# ADR 0013 : Photos des bons de livraison, minimum avant le lot « photos »

**Date :** 2026-11-25 · **Statut :** Acceptée · **Auteur :** architecte-chantier · **Complète :** ADR 0004

## Contexte
Les livraisons ont besoin de la photo du bon (US-MAT-007) avant le lot « photos » complet (galerie, GPS, liens avec tâches et problèmes, miniatures). L'ADR 0004 fixe la cible (disque derrière `IPhotoStorage`, métadonnées d'abord puis binaire, contrôle par octets magiques, nom aléatoire, EXIF retiré, SkiaSharp candidat) mais reporte le choix de la bibliothèque de traitement d'image au lot « photos ».
Contraintes : réseau faible, jusqu'à 150 photos en attente après trois jours hors ligne (CA-MAT-007.10), pas de nouvelle bibliothèque structurante côté serveur sans ADR, pas d'ImageSharp (licence).

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. Tout l'ADR 0004 maintenant (SkiaSharp, miniatures, HEIC, EXIF par réencodage) | Un seul chantier d'image | Ajoute une bibliothèque native et son ADR au premier lot métier ; retarde la livraison | Moyen à élevé |
| B. **Minimum sans bibliothèque** : JPEG seulement, EXIF retiré par suppression des segments de métadonnées (sans réencodage), pas de miniature, réduction faite par le client | Zéro dépendance serveur ; image servie intacte et sans coordonnées GPS ; livraison rapide | JPEG seulement ; pas de miniature (l'écran affiche l'image réduite par le client) | Faible |
| C. Pas de photo avant le lot photos | Rien à faire | Contraire à l'exigence « preuve du bon » (indispensable) | Inacceptable |

## Décision
**Option B**, conforme à l'ADR 0004 (disque, `IPhotoStorage`, chemin aléatoire, octets magiques) et sans le remplacer.
- **Entité `Photo`** générique et `ISiteScoped` / `IHasClientId` : `DeliveryId` (obligatoire dans ce lot, le lot « photos » le rendra nullable et ajoutera les autres liens), `TakenAt` (téléphone, information), `ContentType`, `SizeBytes`, `Sha256`, `StorageKey`, `ContentStatus` (`Pending` | `Uploaded`).
- **Deux temps** (contrat `contrat-api`) : (1) métadonnées, créables **hors ligne** par l'opération `photo` / `create` (idempotente par `clientId`) ou par `POST /sites/{siteId}/deliveries/{deliveryId}/photos` ; (2) binaire par `PUT /sites/{siteId}/photos/{photoId}/content` (corps = image, `Content-Type: image/jpeg`, **hors synchronisation de lot** car 1 Mo de limite du push).
- **Reprise** : le fichier cible fait 1 à 2 Mo ; la reprise est le **renvoi complet** du fichier, idempotent par `Sha256` (même contenu renvoyé = 200 sans effet ; contenu différent sur une photo déjà envoyée = 409 `PHOTO_DEJA_ENVOYEE`). Pas de reprise par plage d'octets (complexité sans gain à cette taille).
- **Contrôles serveur** : octets magiques JPEG (`FF D8 FF`) sinon 415 `TYPE_FICHIER_REFUSE` ; taille ≤ `Storage:MaxPhotoBytes` (5 Mo par défaut, la cible du mobile est 2 Mo) sinon 413 `FICHIER_TROP_GROS` ; 5 photos au plus par livraison non annulée sinon 422 `PHOTOS_TROP_NOMBREUSES` (limite `Materials:MaxPhotosPerDelivery`) ; empreinte SHA-256 recalculée et comparée à celle déclarée.
  Une limite de corps propre à cette route (par attribut `RequestSizeLimit`, 6 Mo) ; le proxy ne relève sa limite que sur cette route (`docs/exploitation/proxy-et-production.md`).
- **EXIF** : `JpegMetadataStripper` retire les segments `APP1` (Exif, XMP) et `APP13` du flux JPEG **sans réencoder**, avant écriture sur disque. Un JPEG illisible (segments incohérents) est refusé (422 `TYPE_FICHIER_REFUSE`), pas stocké tel quel. HEIC et PNG : refusés dans ce lot (le mobile envoie toujours du JPEG ; la galerie n'est pas proposée).
- **Lecture** : `GET /sites/{siteId}/photos/{photoId}/content`, authentifié, permission `DeliveryPhotos.View` (ni ChefEquipe, ni mobile par défaut), en-têtes `X-Content-Type-Options: nosniff`, `Cache-Control: private, max-age=3600`, jamais d'URL publique. Pas de miniature : l'interface réduit à l'affichage.
- **Stockage** : `FileSystemPhotoStorage` (ADR 0004), `Storage:PhotosRoot` dans `appsettings` (valeur de développement `./Storage/Photos`), volume Docker dédié, sauvegarde quotidienne (déjà prévue dans `docs/exploitation/proxy-et-production.md`). Écriture : fichier temporaire, puis déplacement, puis mise à jour de la ligne dans la même transaction ; en cas d'échec le fichier est supprimé.
- **Mobile** : prise de vue par `image_picker` (caméra uniquement, `imageQuality` et `maxWidth` fixés pour viser ≤ 2 Mo), copie dans le stockage privé de l'application avec `path_provider` (`<dossier privé>/<ownerUserId>/pending_photos/`), envoi **un fichier à la fois** par le moteur après le push des métadonnées, suppression du fichier local à la confirmation. Les photos déjà envoyées ne sont pas stockées en base : elles sont téléchargées à la demande (cache temporaire purgé à la déconnexion).
  Nouvelles dépendances Flutter (première partie, BSD) : `image_picker`, `path_provider`.
- **Web** : sélection d'un fichier JPEG, réduction par canvas (1 600 px, qualité 0,7) avant envoi ; l'affichage utilise l'URL authentifiée par cookie.
- Pas de suppression de photo dans ce lot (le lot « photos » ajoutera retirer / remplacer).

## Conséquences
- Plus facile : preuve du bon livrée sans SkiaSharp ; format et contrôles identiques à ceux que le lot « photos » étendra ; pas de coordonnées GPS dans les images servies.
- Plus difficile : le lot « photos » devra ajouter miniatures, HEIC et PNG sans casser les clients ; une photo prise à l'envers (rotation EXIF) n'est pas corrigée côté serveur : le mobile applique l'orientation avant réduction.
- À surveiller : disque (alerte à 80 %), antivirus sur le dossier, durée d'envoi de 150 photos en 3G (un fichier à la fois, reprise automatique), cohérence base / fichiers (contrôle signalant les métadonnées `Uploaded` sans fichier).
