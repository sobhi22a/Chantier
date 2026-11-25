import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:chantier_mobile/features/sites/data/sync_decoder.dart';

/// Resultat de l'application d'une page de synchronisation.
class PullApplyResult {
  const PullApplyResult({required this.applied, required this.ignored});

  /// Lignes ecrites ou supprimees (hors lignes deja connues et entites inconnues).
  final int applied;

  /// Lignes ignorees : version deja connue, ou entite que cette version ne connait pas.
  final int ignored;
}

/// Donnees locales des chantiers, zones et affectations.
///
/// **Lecture** : l'interface lit ici (flux Drift), jamais le reseau (ADR 0008).
/// **Ecriture** : seulement via la synchronisation (`applyPullPage`, `applyPushedZone`) et la
/// saisie hors ligne (zones, tache M8).
class SitesRepository {
  SitesRepository(this._db);

  final AppDatabase _db;

  // --- Lecture (flux reactifs) -------------------------------------------------------------

  Stream<List<SiteRow>> watchSites({bool includeArchived = false}) =>
      _db.sitesDao.watchSites(includeArchived: includeArchived);

  Stream<SiteRow?> watchSite(String siteId) => _db.sitesDao.watchSite(siteId);

  Future<SiteRow?> getSite(String siteId) => _db.sitesDao.getSite(siteId);

  Stream<List<ZoneRow>> watchZones(
    String siteId, {
    bool includeArchived = false,
  }) => _db.zonesDao.watchBySite(siteId, includeArchived: includeArchived);

  Stream<List<SiteMemberRow>> watchMembers(String siteId) =>
      _db.siteMembersDao.watchBySite(siteId);

  // --- Pull --------------------------------------------------------------------------------

  /// Applique **une page** du pull dans UNE transaction, curseur compris : le curseur n'avance
  /// qu'avec la page appliquee (reprise exacte apres coupure, CA-012.2). Idempotent : rejouer la
  /// meme page ne change rien (une ligne n'est ecrite que si sa version est plus recente).
  ///
  /// Toute la page est decodee **avant** la premiere ecriture : une ligne illisible leve
  /// [SyncDecodeException] sans rien modifier.
  Future<PullApplyResult> applyPullPage(
    SyncPullResponse page, {
    required String ownerUserId,
  }) async {
    final decoded = [for (final change in page.changes) decodeChange(change)];

    return _db.transaction(() async {
      // Rechargement complet (permissions modifiees, curseur invalide) : les lignes de meme
      // version ecrasent les locales, pour qu'un champ retire ne survive pas (R1-03).
      final overwrite =
          await _db.syncStateDao.get(SyncStateKeys.fullReload) == 'true';
      var applied = 0;
      var ignored = 0;
      for (final change in decoded) {
        final written = switch (change) {
          SiteChange(:final row) => await _db.sitesDao.upsertIfNewer(
            row,
            overwrite: overwrite,
          ),
          ZoneChange(:final row) => await _db.zonesDao.upsertIfNewer(
            row,
            overwrite: overwrite,
          ),
          MemberChange(:final row) => await _db.siteMembersDao.upsertIfNewer(
            row,
            overwrite: overwrite,
          ),
          UnknownEntityChange() => false,
        };
        written ? applied++ : ignored++;
      }
      for (final deletion in page.deleted) {
        final removed = switch (deletion.entity) {
          // Suppression en cascade : le chantier emporte ses zones et ses affectations.
          'site' => await _db.sitesDao.deleteSite(deletion.id),
          'zone' => await _db.zonesDao.deleteZone(deletion.id),
          'member' => await _db.siteMembersDao.deleteMember(deletion.id),
          _ => 0,
        };
        removed > 0 ? applied++ : ignored++;
      }
      await _db.syncStateDao.setAll({
        SyncStateKeys.cursor: page.cursor,
        SyncStateKeys.ownerUserId: ownerUserId,
        if (!page.hasMore) SyncStateKeys.initialSyncDone: 'true',
      });
      // Derniere page : le rechargement est termine.
      if (!page.hasMore && overwrite) {
        await _db.syncStateDao.remove(SyncStateKeys.fullReload);
      }
      return PullApplyResult(applied: applied, ignored: ignored);
    });
  }

  // --- Push --------------------------------------------------------------------------------

  /// Zone confirmee par le serveur (`applied` ou `duplicate`) pour l'operation [operationClientId].
  ///
  /// * cas normal : la zone locale en attente (`id = clientId`) est **remplacee** par celle du
  ///   serveur (meme `clientId`) ;
  /// * [merged] : une zone identique, creee par un autre telephone, a ete retenue (CA-011.6) ;
  ///   la zone locale en attente est supprimee et la zone retenue est enregistree, **sans erreur
  ///   affichee**. Les saisies futures qui referenceront la zone locale devront etre rattachees
  ///   a la zone retenue (aucune saisie ne reference encore les zones au socle).
  Future<void> applyPushedZone({
    required String operationClientId,
    required Object? resource,
    required bool merged,
  }) async {
    final retained = resource == null ? null : decodeZoneResource(resource);
    await _db.transaction(() async {
      if (merged) {
        final local = await _db.zonesDao.getById(operationClientId);
        if (local != null && local.isPending) {
          await _db.zonesDao.deleteZone(operationClientId);
        }
      }
      if (retained != null) await _db.zonesDao.upsertIfNewer(retained);
    });
  }

  /// « Abandonner » : supprime la zone locale en attente (jamais une zone confirmee).
  Future<void> discardPendingZone(String clientId) async {
    final local = await _db.zonesDao.getById(clientId);
    if (local != null && local.isPending) {
      await _db.zonesDao.deleteZone(clientId);
    }
  }
}
