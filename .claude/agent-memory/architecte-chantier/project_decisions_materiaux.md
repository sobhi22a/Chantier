---
name: decisions-materiaux
description: Décisions structurantes du lot demandes de matériaux et livraisons (sync update/transition, prix jamais sur mobile, catalogue global, photos du bon) et hypothèses à valider
metadata:
  type: project
---

Plan `docs/plans/demandes-materiaux-livraisons.md` (34 tâches, tranches A « demander et valider » puis B « commander et recevoir »), contrat `docs/api/demandes-materiaux-livraisons.md`, vecteurs `docs/api/vecteurs-materiaux.json`, ADR 0011 à 0014 (écrits le 2026-11-25). À retenir :
- **Sync update/transition** (ADR 0011) : comparaison à trois valeurs par champ (`changes` + `base`), tout ou rien par opération, **première arrivée retenue** (écart assumé au skill « dernière écriture gagne »), `SyncOperationLog` pour l'idempotence des non-`create`, `rejected` = jamais légitime, `conflict` = état serveur changé.
- **Prix jamais sur un téléphone, pour aucun rôle** (ADR 0012) : objet `commercial` omis sans `Prices.View` et absent de toute synchro ; téléphone fournisseur jamais synchronisé (lu en ligne puis `tel:`), donc pas de SQLCipher dans ce lot.
- `SyncChange.siteId` devient **nullable** (entités globales `product`, `supplier`) ; la commande est **incorporée** à la demande (pas d'entité de synchro propre), l'historique aussi.
- Photos du bon (ADR 0013) : JPEG seulement, EXIF retiré sans réencodage (pas de SkiaSharp), pas de miniature, un `PUT` complet idempotent ; Flutter : `image_picker`, `path_provider`, `url_launcher`.
- Calculs (ADR 0014) : domaine serveur pur + **miroirs d'affichage** web (BigInt) et mobile testés par les mêmes vecteurs JSON.
- Entité `MaterialRequest` / route `/requests` ; statuts Q-MAT-01 a et b retenus, c refusé (ChefChantier n'annule que les siennes).
- Écart de périmètre : écran mobile « Commander » optionnel (M10) ; pas de suppression de photo ; pas de « détacher » une livraison.

**Why:** ces choix engagent la sécurité des prix, la synchronisation et le coût de reprise de tout le lot.
**How to apply:** toute nouvelle entité de chantier suit le patron (ISiteScoped + source de synchro + `TouchedEntityTypes` + politique de conflit) ; tout nouveau montant passe par `CommercialProjection` ; hypothèses à valider listées dans le plan (section dédiée), ne pas redemander.
