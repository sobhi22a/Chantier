---
name: revue-socle-risques-et-commandes
description: Risques propres au projet Chantier, endroits sensibles du code, commandes d'audit et de mesure qui marchent (revue R1 du socle, 2026-11-24)
metadata:
  type: project
---

## Conventions
- Rapport : `docs/revues/<slug>.md` (modèle `.claude/skills/qualite-passation/modeles/rapport-revue.md`), constats `R1-NN`, sévérités Bloquant / Majeur / Mineur / Suggestion. La revue R1 du socle est `docs/revues/socle.md` (nom fixé par la demande, sans date).
- Lecture seule : ne jamais lancer `dotnet test`, `npm ci`, `flutter build` quand un autre agent teste ; travailler sur une COPIE de `bin/Release` dans le dossier temporaire de session.

## Chemins clés (endroits sensibles)
- Limiteurs : `WebApi/Extensions/ServiceCollectionExtensions.cs` (`AddLimiter`, global), `WebApi/Services/AuthRateLimiter.cs` (login/refresh), `Core/Chantier.Infrastructure/Services/LoginAttemptTracker.cs` (blocage 5/15 min par identifiant).
- Session : `WebApi/Extensions/AuthenticationExtensions.cs` (cookie, JWT, clés de protection), `WebApi/Authorization/ActiveUserValidator.cs`, `Infrastructure/Services/AuthService.cs` (rotation, réutilisation), `UserStatusProvider` (cache 60 s).
- Isolation : `WebApi/Filters/SiteScopedAttribute.cs`, `Infrastructure/Services/Sites/SiteAccess.cs`, `Core/Specifications/Sites/SiteSpecifications.cs`.
- Montant du marché : `Core/Sites/SiteResponses.cs` (omis si pas de permission), `Infrastructure/Sync/SiteSyncSource.cs`, mobile `database/daos/sites_dao.dart` (`upsertIfNewer`).
- Mobile : `android/app/src/main/AndroidManifest.xml`, `core/storage/secure_token_store.dart`, `core/network/{auth_interceptor,token_refresher}.dart`, `features/auth/data/auth_repository_impl.dart` (session 14 j, purge), `core/sync/sync_engine.dart`.

## Risques propres au projet (vérifiés le 2026-11-24)
- Le cookie est le schéma d'authentification PAR DÉFAUT (`AddIdentity`) : tout ce qui s'exécute avant `UseAuthorization` (limiteur global) ne voit PAS l'utilisateur d'un jeton Bearer. Penser à ce piège pour tout middleware placé avant l'autorisation.
- Le ticket de cookie web est sans état : rejouable après déconnexion/changement de mot de passe ; seule la désactivation du compte le coupe.
- Refresh : réponse perdue puis renvoi = réutilisation = chaîne révoquée (pas de fenêtre de grâce).
- Mobile : `upsertIfNewer` ignore les versions égales (R1-03, corrigé depuis : purge du montant dans `sync_engine.dart`, à confirmer par la QA) ; `allowBackup` désactivé depuis (R2 : vérifié) ; release signée avec la clé debug (R1-19, à revoir avant diffusion).
- `IdentityDbInitializer` n'AJOUTE que des permissions, ne retire jamais : un retrait dans la matrice du code ne se propage pas aux bases existantes.
- Compression gzip/brotli ajoutée depuis R1 ; `{"operations":[null]}` donne 400 ; corps limité à 64 Ko (R2 : constaté).
- Entités futures : toute entité avec clé étrangère vers `Sites` doit suivre le schéma de verrouillage de `SyncTouch` (interblocages mesurés par backend-dotnet, ADR 0009).
- À contrôler à chaque revue : `{"operations":[null]}` sur `/sync/push` (500 aujourd'hui), taille de corps (30 Mo par défaut), photos (lot suivant : octets magiques, EXIF, flux), SQLCipher avant tout téléphone/évaluation.

## Commandes qui marchent
- Dépendances .NET : `cd chantier-backend; DOTNET_CLI_UI_LANGUAGE=en dotnet list Chantier.sln package --vulnerable --include-transitive` (sort 0 même s'il trouve : lire la sortie).
- npm sans installer : copier `package.json` + `package-lock.json` dans un dossier temporaire puis `npm audit --omit=dev` et `npm audit` (`--json` pour trier par gravité). Production : 0 ; outillage de dev : 39 (Nx, Vitest/tinypool).
- Flutter : `flutter pub outdated --no-dev-dependencies` (lecture seule, ~1 min). APK/démarrage non mesurables sans licences Android.
- API isolée pour mesurer : copier `WebApi/Chantier.WebApi/bin/Release/net10.0` dans le dossier temporaire, `env ASPNETCORE_ENVIRONMENT=Development Database__MigrateOnStartup=false "Logging__LogLevel__Microsoft.EntityFrameworkCore.Database.Command=Information" dotnet Chantier.WebApi.dll --urls http://localhost:8199` (les user-secrets se chargent seuls ; ne jamais afficher leurs valeurs : `dotnet user-secrets list | sed 's/=.*/=<masqué>/'`). Les noms de variables avec des points exigent `env` sous Git Bash (PowerShell ne les accepte pas). Arrêter ensuite le processus du port 8199.
- Comptes de démonstration `*.dev` avec le mot de passe de `appsettings.Development.json` ; ne pas verrouiller de vrais comptes de démonstration (blocage 15 min) : tester le blocage avec un identifiant inexistant. Le limiteur global se mesure sur une fenêtre d'une minute (attendre 65 s entre deux essais).
- Scripts de mesure en `node` (`fetch`, `zlib`) ; `python` absent de l'environnement isolé, `jq` absent.

## Pièges connus
- Un seul commit (socle) sur `main` ; la fonctionnalité matériaux est dans l'arbre non commité de sa branche. Vérifier `.gitignore` (`.env`, `**/Storage/`, `*.jks`) plutôt que l'historique.
- `.env` : lecture interdite aux agents ; pour parler à SQL Server, passer par `docker exec chantier-dev-db sh -c '... -P "$MSSQL_SA_PASSWORD" ...'` (le secret reste dans le conteneur).
- Les plans SQL sur le jeu de démonstration (30 zones) ne sont pas significatifs : prévoir un jeu de 10 000 zones avant de conclure sur les index.

## Décisions (lien ADR)
- ADR 0005 accepte le blocage par identifiant seul (déni de service ciblé) et le compteur en mémoire : à reconsidérer avant l'usage réel (R1-09).
- ADR 0008 : base locale non chiffrée au socle, SQLCipher exigé avant les données personnelles.
