# ADR 0003 : Base de données (SQL Server) et conventions EF Core

**Date :** 2026-11-24 · **Statut :** Acceptée · **Auteur :** architecte-chantier

## Contexte
Une seule base pour tout le monolithe. Kardinal utilise SQL Server (Oracle en secondaire, inutile). Exigences de Chantier :
- synchronisation hors ligne **sans perte** : il faut un curseur serveur monotone fiable, y compris quand deux transactions
  se terminent dans le désordre ;
- audit automatique, suppression logique, concurrence optimiste, montants `decimal` ;
- disponibilité locale (poste de développement) et en Algérie : hébergement probable sur un serveur de l'entreprise ou une machine louée,
  sans dépendance obligatoire à un service cloud étranger.

Poste de développement vérifié : Docker 29.2.1, `MSSQLLocalDB` présent, `sqlcmd` présent, **`psql` absent**.

## Options étudiées
| Option | Avantages | Inconvénients | Coût / risque |
|---|---|---|---|
| A. **SQL Server 2022** (Developer en conteneur pour dev et CI ; Express ou Standard en production) | Identique à Kardinal (outils, sauvegardes, compétences) ; `rowversion` + `MIN_ACTIVE_ROWVERSION()` donnent un curseur de synchro **sans trou** nativement ; LocalDB et Docker déjà là ; Express gratuit (10 Go par base, photos sur disque donc hors base) | Licence payante au-delà d'Express ; image Docker lourde (≥ 2 Go de RAM) ; GUID v7 non séquentiels pour l'index clusterisé | Faible |
| B. PostgreSQL | Gratuit sans limite ; UUID v7 triés naturellement ; hébergement Linux très répandu | `psql`/serveur à installer ; pas d'équivalent de `MIN_ACTIVE_ROWVERSION` (curseur à reconstruire avec `xmin` ou une séquence + fenêtre de sécurité) ; rupture avec Kardinal | Moyen (synchro à concevoir) |
| C. SQLite côté serveur | Zéro installation | Une seule écriture à la fois ; pas fait pour plusieurs conducteurs et chefs de chantier | Élevé |

## Décision
**Option A : SQL Server 2022.** Imiter Kardinal par défaut ; aucune règle non négociable ne l'exclut ; la synchronisation hors ligne (règle 6) y est
même plus sûre. Développement : conteneur `mcr.microsoft.com/mssql/server:2022-latest` (`docker-compose.dev.yml`), `MSSQLLocalDB` en repli.
Production : Express tant que la base reste sous 10 Go, sinon Standard. Le coût de bascule vers PostgreSQL reste **confiné** à trois endroits :
`UseSqlServer`, le convertisseur `RowVersion`, la classe `SqlServerSyncClock` (ADR 0009).

### Conventions EF Core 10 (toutes obligatoires)
1. **`BasicEntity`** (`Core/Entities/Common`) : `Id` (`Guid.CreateVersion7()`, jamais généré par la base), `CreatedAt`, `CreatedBy`, `UpdatedAt?`, `UpdatedBy?`,
   `DeletedAt?`, `DeletedBy?`, `RowVersion`. Horodatages en `DateTimeOffset` UTC. Les entités créables hors ligne ajoutent `ClientId` et `ClientCreatedAt?` (interface `IHasClientId` : « saisi le » du téléphone, information seulement) ;
   les entités d'un chantier portent `SiteId` (interface `ISiteScoped`). **Archivage ≠ suppression logique** : un chantier ou une zone « supprimé » est **archivé** (`ArchivedAt/ArchivedBy`, visible, restaurable, lecture seule, H-13) ;
   `DeletedAt` sert aux lignes techniques (affectation retirée, futures lignes de saisie) et n'est jamais exposé comme action utilisateur sur un chantier ou une zone.
2. **Audit automatique** : un `SaveChangesInterceptor` (`AuditingInterceptor`) remplit création, modification et suppression à partir de `ICurrentUser`
   (identité du jeton) et de `TimeProvider`. Hors requête (seeders, tâches), l'auteur est `SystemActor.Id` (GUID fixe). Le client ne fournit **jamais** ces champs.
3. **Suppression logique** : `DbSet.Remove` est converti en `DeletedAt/DeletedBy` par l'intercepteur. Un **filtre de requête nommé** `"SoftDelete"` (EF Core 10) est appliqué
   à toutes les entités `BasicEntity` par convention ; la synchronisation le désactive nommément (`IgnoreQueryFilters(["SoftDelete"])`) pour lire les pierres tombales.
4. **Concurrence et curseur** : `RowVersion` = `rowversion` SQL Server, exposé au code en `ulong` via un convertisseur **gros-boutiste** (`BinaryPrimitives`), car
   `NumberToBytesConverter` est petit-boutiste et fausserait les comparaisons. La propriété `version` de l'API est la valeur décimale de ce `ulong` (chaîne). Le point
   est un **risque à valider tout de suite** (tâche B2) par un test d'ordre ; repli : requêtes `FromSql` avec `CAST(RowVersion AS bigint)`.
5. **Types** : montants `decimal(18,2)`, quantités `decimal(18,3)`, cotes `decimal(7,2)`, GPS `decimal(9,6)` ; convention globale `HavePrecision(18,3)` pour empêcher tout `decimal`
   sans précision explicite. Dates métier en `DateOnly` (colonne `date`). **Énumérations stockées en chaînes** (`HaveConversion<string>()`, longueur 50), jamais en entiers
   (contrat d'API) : écart avec Kardinal qui stocke des `int`.
6. **Index** : unicité métier **filtrée** `WHERE DeletedAt IS NULL` (ex. `Sites.Code`, `SiteMembers(SiteId, UserId)`) ; index `(SiteId, RowVersion)` sur chaque table synchronisée ;
   index unique `(SiteId, ClientId)` sur chaque entité créable hors ligne (ADR 0009).
7. **Configurations Fluent API** par entité dans `Infrastructure/Persistence/Configurations/` (et non dans `Core` comme chez Kardinal).
8. **Chaîne de connexion** `ConnectionStrings:ChantierDb` ; secrets via `user-secrets` ou variables d'environnement (`ConnectionStrings__ChantierDb`), jamais dans `appsettings*.json`.
9. **Migrations** : `dotnet ef migrations add <Nom> --project Core/Chantier.Infrastructure --startup-project WebApi/Chantier.WebApi` ; nom explicite, `Down` fonctionnel,
   **aucun `DropTable` accidentel**, relecture obligatoire ; une migration appliquée n'est jamais modifiée. En développement : migration automatique au démarrage si
   `Database:MigrateOnStartup = true`. Ailleurs : script idempotent (`dotnet ef migrations script --idempotent`) appliqué par le déploiement.
10. **Données de référence** (rôles, claims) : seeder idempotent au démarrage, comme Kardinal. **Données de démonstration** « École UV18 » : seulement si `Seed:Demo = true` **et** environnement Development.

## Conséquences
- Plus facile : curseur de synchro robuste ; audit impossible à oublier ; requêtes de lecture toujours filtrées sur les lignes supprimées.
- Plus difficile : le GUID v7 ne produit pas d'insertions séquentielles dans un index clusterisé SQL Server (fragmentation possible) ; acceptable sous quelques millions de lignes ; revoir si besoin.
- À surveiller : la limite de 10 Go d'Express (les photos restent hors base, ADR 0004) ; la mémoire du conteneur SQL Server sur les postes modestes.
