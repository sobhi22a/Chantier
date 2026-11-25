# ADR 0004 : Stockage des photos

**Date :** 2026-11-24 · **Statut :** Acceptée · **Auteur :** architecte-chantier

## Contexte
Les photos (avancement, bons de livraison, problèmes) arrivent depuis des téléphones en réseau faible, parfois par lots de plusieurs dizaines
après une journée hors ligne. Le contrat impose : métadonnées d'abord, binaire ensuite (`PUT /photos/{id}/content`, reprise possible),
taille maximale, type vérifié par les octets magiques, nom de stockage aléatoire, hors du dossier web, miniature, EXIF retiré des images servies.
Aucune photo n'est créée dans le socle : cet ADR fixe la cible pour que le socle prépare le terrain (interface, configuration, dossier).

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. Colonne `varbinary(max)` en base | Une seule sauvegarde, transactionnel | Base qui gonfle (Express 10 Go), sauvegardes lourdes, lectures lentes | Élevé |
| B. **Disque du serveur** derrière `IPhotoStorage` | Simple, rapide, gratuit, sauvegardable par dossier ; aucune dépendance cloud | Une seule machine ; cohérence base/fichiers à gérer | Faible |
| C. Stockage objet compatible S3 (MinIO, S3, Azure Blob) | Évolutif, multi-serveurs | Service supplémentaire à exploiter, coûts, dépendance réseau externe | Moyen |

## Décision
**Option B** derrière une interface `IPhotoStorage` (`Core/Abstractions`) : `SaveAsync`, `OpenReadAsync`, `DeleteAsync`. Implémentation `FileSystemPhotoStorage`
(Infrastructure), dossier racine `Storage:PhotosRoot` **hors du dossier web**, volume Docker dédié en conteneur. Passer à S3 plus tard = une autre implémentation, sans changer le métier.
- Chemin : `<racine>/<siteId>/<AAAA>/<MM>/<guid-aléatoire>.<ext>` ; le nom d'origine n'est jamais utilisé comme chemin ; protection contre `..` testée.
- Métadonnées en base (`Photo`, entité de la fonctionnalité « photos », hors socle) avec empreinte SHA-256 pour dédoublonner un renvoi.
- Traitement d'image : **pas de SixLabors.ImageSharp** (licence partagée payante pour une entreprise de cette taille). Candidat retenu : **SkiaSharp** (MIT) pour réencoder,
  réduire et produire la miniature, ce qui supprime l'EXIF ; confirmé par un ADR de détail lors de la fonctionnalité « photos ».
- Côté mobile : compression avant envoi (taille cible 1 à 2 Mo), envoi **un fichier à la fois**, reprise par le moteur de la file d'envoi (ADR 0009) ; fichiers conservés dans le stockage privé de l'application jusqu'à confirmation.
- Sauvegarde : le dossier photos et la base sont sauvegardés ensemble (tâche `devops-ci`, lot ultérieur) ; un contrôle de cohérence signale les métadonnées sans fichier.

## Conséquences
- Plus facile : lecture rapide, coût nul, aucun service à ajouter.
- Plus difficile : disponibilité liée à une machine ; la restauration doit remettre base et dossier dans le même état.
- À surveiller : quota disque (prévoir une alerte à 80 %), antivirus sur le dossier, droits d'accès du compte de service.
- Dans le socle : seulement le paramètre `Storage:PhotosRoot` (valeur de développement) et le volume dans `docker-compose.dev.yml`. L'interface `IPhotoStorage` est créée avec la fonctionnalité « photos » (pas de code mort).
