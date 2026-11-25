---
name: decisions-socle
description: Décisions structurantes du socle non évidentes à relire dans le code (curseur de synchro, affectation, archivage, écarts au skill contrat-api et périmètre)
metadata:
  type: project
---

Détails dans `docs/adr/0001` à `0010`, plan `docs/plans/socle.md`, contrat `docs/api/socle.md`, user stories `docs/metier/socle.md` (réconciliés le 2026-11-24). À retenir (non dérivable du code futur) :
- Base **SQL Server 2022** surtout pour `rowversion` + `MIN_ACTIVE_ROWVERSION()` : curseur de synchro sans perte ; bascule vers PostgreSQL confinée à `SqlServerSyncClock`, au convertisseur `RowVersion` et à `UseSqlServer`.
- `GET /sync/changes` : `siteId` **facultatif** (écart au skill `contrat-api`, ADR 0009) ; le skill n'a pas été modifié (à faire valider par l'utilisateur).
- Pas de DELETE : `archive` / `restore` (chantier, zone) ; permission `Delete` = archiver (H-13 « rien n'est effacé »). Affectation retirée = suppression logique tracée.
- Seul **Admin** voit tous les chantiers (`AllSites.View`, H-02) ; Direction seulement ses affectations (Q-02 ouverte, = une claim à ajouter).
- Refresh 14 jours (H-05) ; blocage de connexion par identifiant (429 `TROP_D_ESSAIS`) géré en mémoire, pas par le verrouillage Identity ; compte désactivé = `ACCES_RETIRE` même avec jeton valide.
- Montant du marché omis des réponses et de la synchro sans `ContractAmount.View` ; `permissionsVersion` change → resynchro complète mobile.
- Affecter « touche » chantier + zones + affectations pour que le mobile les reçoive ; retirer produit une pierre tombale `site`.
- Zone créée hors ligne = premier chemin d'écriture (handler `zone`, fusion `merged` des doublons) ; renommer/archiver hors ligne = lot suivant.
- **Périmètre** : stories 004 (comptes), 005 (écrans), 016.3, 016.5 déclarées « Indispensable » par l'expert mais renvoyées au lot Administration juste après le socle (à confirmer par l'utilisateur).
- Pas d'AutoMapper/MediatR/FluentAssertions ≥ 8/ImageSharp ; ports 8195 (API) et 3600 (web) pour cohabiter avec Kardinal.
- Risques à valider dès B2/B6 : convertisseur `RowVersion` gros-boutiste, lecture de l'OpenAPI 3.1 par `@rtk-query/codegen-openapi` et `swagger_parser`.

**Why:** ces choix engagent la synchronisation et la sécurité de toutes les fonctionnalités à venir.
**How to apply:** toute nouvelle entité de chantier doit avoir `ISiteScoped`, un `ISyncSource`, une entrée dans le « toucher à l'affectation » et une politique de conflit dans son plan.
