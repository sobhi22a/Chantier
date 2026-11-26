import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/converters/material_json_guard.dart';
import 'package:chantier_mobile/database/tables/deliveries.dart';
import 'package:chantier_mobile/database/tables/material_requests.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:drift/drift.dart';

part 'material_requests_dao.g.dart';

/// Vues de la liste des demandes (CA-MAT-002.1, 002.5, 003.1, 006.1). Les demandes **archivees**
/// n'apparaissent que dans [archived].
enum RequestListView {
  /// « A suivre » : demandee, validee, commandee, livree partiellement, livree.
  toFollow({
    RequestStatus.requested,
    RequestStatus.validated,
    RequestStatus.ordered,
    RequestStatus.partiallyDelivered,
    RequestStatus.delivered,
  }),

  /// « Terminees » : receptionnees.
  received({RequestStatus.received}),

  /// « Refusees et annulees ».
  closed({RequestStatus.rejected, RequestStatus.cancelled}),

  /// « A valider » (conducteur) : demandees.
  toApprove({RequestStatus.requested}),

  /// « A recevoir » : commandees ou livrees partiellement.
  expected({RequestStatus.ordered, RequestStatus.partiallyDelivered}),

  /// « A receptionner » : livrees.
  toReception({RequestStatus.delivered}),

  /// « Archivees » : toute demande archivee, quel que soit son statut.
  archived({});

  const RequestListView(this.statuses);

  final Set<RequestStatus> statuses;
}

/// Acces aux demandes de materiaux, y compris celles creees hors ligne.
///
/// **Aucun prix, aucun telephone** ne passe par ce DAO : `order_json` et `history_json` sont
/// passes dans `MaterialJsonGuard` avant toute ecriture (ADR 0012).
@DriftAccessor(tables: [MaterialRequests, Deliveries])
class MaterialRequestsDao extends DatabaseAccessor<AppDatabase>
    with _$MaterialRequestsDaoMixin {
  MaterialRequestsDao(super.attachedDatabase);

  /// Tri « urgence puis date de besoin » (CA-MAT-002.1) : Bloquante, Urgente, Normale.
  static const String _priorityRank =
      "CASE priority WHEN 'Blocking' THEN 0 WHEN 'Urgent' THEN 1 ELSE 2 END";

  /// Flux reactif d'une vue pour un chantier. [requestedById] : « Mes demandes ».
  ///
  /// Les vues d'attente sont triees par urgence puis date de besoin ; « terminees », « refusees
  /// et annulees » et « archivees » par date de creation decroissante. Une demande creee hors
  /// ligne est incluse des l'ecriture locale (affichee « en attente d'envoi »).
  Stream<List<MaterialRequestRow>> watchView(
    String siteId,
    RequestListView view, {
    String? requestedById,
  }) {
    final query = select(materialRequests)
      ..where((t) => t.siteId.equals(siteId));
    if (view == RequestListView.archived) {
      query.where((t) => t.archivedAt.isNotNull());
    } else {
      query.where(
        (t) =>
            t.archivedAt.isNull() &
            t.status.isIn([for (final s in view.statuses) s.code]),
      );
    }
    if (requestedById != null) {
      query.where((t) => t.requestedById.equals(requestedById));
    }
    final byUrgency =
        view == RequestListView.toFollow ||
        view == RequestListView.toApprove ||
        view == RequestListView.expected ||
        view == RequestListView.toReception;
    query.orderBy(
      byUrgency
          ? [
              (t) => OrderingTerm(
                expression: const CustomExpression<int>(_priorityRank),
              ),
              (t) => OrderingTerm.asc(t.neededBy),
              (t) => OrderingTerm.asc(t.createdAt),
            ]
          : [(t) => OrderingTerm.desc(t.createdAt)],
    );
    return query.watch();
  }

  /// Toutes les demandes d'un chantier, archivees comprises : les vues de la liste se calculent
  /// ensuite avec la surcouche des saisies en attente (statut **affiche**, pas seulement stocke).
  Stream<List<MaterialRequestRow>> watchBySite(String siteId) =>
      (select(materialRequests)..where((t) => t.siteId.equals(siteId))).watch();

  /// Comme [watchBySite] **sans** `history_json` (le gros texte, jamais lu par une liste) : une
  /// premiere synchronisation de 2 000 demandes ne recompose pas ~4 Mo de texte a chaque page
  /// (R2-07). La commande (`order_json`, petite : fournisseur et date prevue de « A recevoir »)
  /// reste lue ; l'historique ne l'est qu'au detail ([watchById]).
  Stream<List<MaterialRequestRow>> watchBySiteLight(String siteId) {
    final columns = [
      for (final column in materialRequests.$columns)
        column.$name == 'history_json'
            ? 'NULL AS ${column.$name}'
            : column.$name,
    ];
    return customSelect(
      'SELECT ${columns.join(', ')} FROM material_requests WHERE site_id = ?1',
      variables: [Variable<String>(siteId)],
      readsFrom: {materialRequests},
    ).map((row) => materialRequests.map(row.data)).watch();
  }

  /// Correction d'une demande **jamais envoyee** (meme transaction que la modification de sa
  /// saisie dans la file d'envoi).
  Future<void> replacePending(MaterialRequestRow row) async {
    assert(row.isPending && row.version == 0 && row.clientId == row.id);
    await into(
      materialRequests,
    ).insertOnConflictUpdate(_guarded(row).toCompanion(false));
  }

  Stream<MaterialRequestRow?> watchById(String id) => (select(
    materialRequests,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<MaterialRequestRow?> getById(String id) => (select(
    materialRequests,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<MaterialRequestRow?> findByClientId(String siteId, String clientId) =>
      (select(materialRequests)..where(
            (t) => t.siteId.equals(siteId) & t.clientId.equals(clientId),
          ))
          .getSingleOrNull();

  Future<int> countBySite(String siteId) async {
    final count = materialRequests.id.count();
    final query = selectOnly(materialRequests)
      ..addColumns([count])
      ..where(materialRequests.siteId.equals(siteId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Produits les plus demandes sur ce chantier (tuiles de « Nouvelle demande », CA-MAT-001.12),
  /// calcules **localement**, demandes en attente d'envoi comprises. Les demandes refusees ou
  /// annulees sont ecartees : elles ne disent pas ce qu'on commande vraiment. A egalite : le
  /// produit demande le plus recemment d'abord.
  Future<List<String>> topProductIds(String siteId, {int limit = 6}) async {
    final count = materialRequests.id.count();
    final latest = materialRequests.createdAt.max();
    final query = selectOnly(materialRequests)
      ..addColumns([materialRequests.productId, count, latest])
      ..where(
        materialRequests.siteId.equals(siteId) &
            materialRequests.productId.isNotNull() &
            materialRequests.status.isNotIn([
              RequestStatus.rejected.code,
              RequestStatus.cancelled.code,
            ]),
      )
      ..groupBy([materialRequests.productId])
      ..orderBy([OrderingTerm.desc(count), OrderingTerm.desc(latest)])
      ..limit(limit);
    final rows = await query.get();
    return [for (final row in rows) row.read(materialRequests.productId)!];
  }

  /// Demande creee **hors ligne** : `id = clientId`, `version = 0`, `isPending = true`.
  /// A appeler dans la meme transaction que l'ajout a la file d'envoi (`OutboxRepository`).
  Future<void> insertPending(MaterialRequestRow row) async {
    assert(row.isPending && row.version == 0 && row.clientId == row.id);
    await into(materialRequests).insert(_guarded(row));
  }

  /// Applique une demande recue du serveur (pull ou resultat `applied` / `duplicate` d'un push).
  ///
  /// * meme identifiant deja present : ecrite seulement si la version est plus recente
  ///   (ou egale avec [overwrite], rechargement complet) ;
  /// * demande locale en attente de meme `clientId` (identifiant different) : **remplacee** par
  ///   celle du serveur, sans doublon, et les livraisons qui la designaient par son `clientId`
  ///   sont **rattachees** a l'identifiant du serveur (meme transaction).
  /// Retourne `true` si une ligne a ete ecrite.
  Future<bool> upsertIfNewer(
    MaterialRequestRow row, {
    bool overwrite = false,
  }) => transaction(() async {
    final existing = await getById(row.id);
    if (existing != null) {
      if (existing.version > row.version) return false;
      if (existing.version == row.version && !overwrite) return false;
      // toCompanion(false) : un `null` recu (commande annulee, motif efface) ECRASE l'ancien.
      await into(
        materialRequests,
      ).insertOnConflictUpdate(_guarded(row).toCompanion(false));
      return true;
    }
    final clientId = row.clientId;
    if (clientId != null) {
      final local = await findByClientId(row.siteId, clientId);
      if (local != null) {
        await _reattachDeliveries(from: local.id, to: row.id);
        await deleteRequest(local.id);
      }
    }
    await into(materialRequests).insert(_guarded(row));
    return true;
  });

  /// Les livraisons saisies pour une demande encore en attente la designaient par son `clientId`.
  Future<void> _reattachDeliveries({required String from, required String to}) {
    if (from == to) return Future.value();
    return (update(deliveries)..where((t) => t.requestId.equals(from))).write(
      DeliveriesCompanion(requestId: Value(to)),
    );
  }

  /// Pierre tombale ou abandon d'une demande locale en attente.
  Future<int> deleteRequest(String id) =>
      (delete(materialRequests)..where((t) => t.id.equals(id))).go();

  MaterialRequestRow _guarded(MaterialRequestRow row) => row.copyWith(
    orderJson: Value(MaterialJsonGuard.sanitizeOrder(row.orderJson)),
    historyJson: Value(MaterialJsonGuard.sanitizeHistory(row.historyJson)),
  );
}
