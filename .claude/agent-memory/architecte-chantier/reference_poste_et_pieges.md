---
name: poste-et-pieges
description: Outils installés sur le poste (versions vérifiées au 2026-11-24) et pièges d'outillage rencontrés (shell, éditions de fichiers)
metadata:
  type: reference
---

Poste (Windows 11, locale fr-DZ) vérifié le 2026-11-24 : .NET SDK 10.0.301 (+9.x, 5.0), `dotnet-ef` 10.0.11, Node 22.13.1 / npm 11.3.0, Flutter 3.35.7 (Dart 3.9), Docker 29.2.1, `MSSQLLocalDB` + `sqlcmd`, Git 2.54, **pas de `psql`**.
`flutter doctor` : licences Android non acceptées, Android Studio absent (action utilisateur : `flutter doctor --android-licenses`).

Pièges d'outillage :
- Ne jamais lancer `python` nu dans Bash (ouvre un REPL qui bloque 120 s).
- `sed -i` avec des chemins Windows à antislashs ne remplace rien : utiliser l'outil Edit.
- Le dossier `D:\projects\Chantier` a la branche git `master` ; le skill `socle` propose une branche `socle`.
- Plan, ADR et contrat du socle : `docs/plans/socle.md`, `docs/adr/0001` à `0010`, `docs/api/socle.md`.

**How to apply:** revérifier les versions avant de les citer (elles évoluent) ; relire `docs/architecture/etat-des-lieux.md` pour l'état à jour.
