---
name: kardinal-reference
description: Où est la référence Kardinal-app, ses pièges (Drift/Freezed annoncés mais inutilisés, deux versions du mobile) et où sont les analyses écrites
metadata:
  type: project
---

Chantier imite Kardinal-app (même auteur, e-commerce pharma) ; analyse complète : `docs/architecture/reference-kardinal.md`.

- Référence officielle demandée : `D:\projects\Project_init\Kardinal-app` (backend et web complets, **mobile réduit** : auth + clients, sans base locale).
- Mobile complet (base locale, synchro) : `D:\projects\Kardinal-app\Mobile-app` (lecture seule, ne jamais modifier Kardinal).
- **Piège** : les `CLAUDE.md` de Kardinal disent « Drift + Freezed » mais le code n'en utilise aucun (aucun import, aucun `*.g.dart`). La vraie base locale est du sqflite écrit à la main, jetons dans SharedPreferences, i18n en `Map` Dart.
- Dossiers cibles Chantier : `chantier-backend/` (Core/Chantier.Core, Core/Chantier.Infrastructure, WebApi/Chantier.WebApi, Tests/), `chantier-frontend/` (Nx), `chantier-mobile/` (Flutter Android).

**Why:** l'utilisateur veut imiter Kardinal par défaut et ne s'écarter que pour une règle non négociable de `CLAUDE.md`.
**How to apply:** avant de citer un « pattern Kardinal » pour le mobile, vérifier qu'il existe vraiment dans le code ; écarts déjà tranchés dans les ADR 0001 à 0010.
