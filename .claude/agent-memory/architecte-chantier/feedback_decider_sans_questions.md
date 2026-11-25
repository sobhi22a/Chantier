---
name: decider-sans-questions
description: L'utilisateur ne veut pas de questions pendant la conception : décider, justifier dans un ADR, signaler seulement les écarts importants
metadata:
  type: feedback
---

Pendant `/socle` et la conception, ne pas poser de questions : trancher (base de données, auth, bibliothèques), écrire la justification dans un ADR, lister les hypothèses dans le plan (section « Hypothèses ») et ne signaler au rapport que les écarts importants.

**Why:** demande explicite de l'utilisateur lors du premier passage (2026-11-24).
**How to apply:** toute décision non évidente = ADR + ligne dans les hypothèses du plan ; « Questions ouvertes » du rapport réservées aux vrais blocages (ex. licences Android à accepter).
