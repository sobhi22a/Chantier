import 'dart:convert';

import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/user_prefs.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:equatable/equatable.dart';

/// Saisie d'une zone (formulaire « Ajouter une zone »).
class NewZone extends Equatable {
  const NewZone({
    required this.clientId,
    required this.siteId,
    required this.userId,
    required this.block,
    required this.label,
    this.elevation,
    this.roomType,
    this.roomNumber,
    this.roomLabel,
  });

  /// GUID cree a l'ouverture du formulaire (anti-doublon).
  final String clientId;
  final String siteId;
  final String userId;
  final String block;
  final Decimal? elevation;
  final String? roomType;
  final int? roomNumber;
  final String? roomLabel;

  /// Libelle lisible pour « Envois en attente » (`Bloc 01 · +3,40 m · Classe 07`).
  final String label;

  @override
  List<Object?> get props => [
    clientId,
    siteId,
    userId,
    block,
    elevation,
    roomType,
    roomNumber,
    roomLabel,
    label,
  ];
}

sealed class ZoneSaveResult {
  const ZoneSaveResult();
}

/// Zone enregistree sur le telephone, en attente d'envoi.
final class ZoneSaved extends ZoneSaveResult {
  const ZoneSaved(this.zone);

  final ZoneRow zone;
}

/// Meme bloc, meme cote et meme local : « Cette zone existe deja » ; l'ecran ouvre la zone
/// existante (CA-011.4).
final class ZoneAlreadyExists extends ZoneSaveResult {
  const ZoneAlreadyExists(this.existing);

  final ZoneRow existing;
}

/// Le meme formulaire a deja ete enregistre (double appui) : rien n'est ecrit une seconde fois.
final class ZoneAlreadySaved extends ZoneSaveResult {
  const ZoneAlreadySaved();
}

/// Creation de zones, **hors ligne d'abord** : ecriture locale et operation d'envoi dans UNE
/// transaction (CT-21).
class ZonesRepository {
  ZonesRepository({
    required AppDatabase database,
    required OutboxRepository outbox,
    DateTime Function()? now,
    this.onLocalWrite,
  }) : _db = database,
       _outbox = outbox,
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final OutboxRepository _outbox;
  final DateTime Function() _now;

  /// Appele apres un enregistrement : declenche l'envoi 2 s plus tard (`SyncScheduler`).
  final void Function()? onLocalWrite;

  /// Enregistre [zone]. Si [replacing] est fourni (« Corriger »), l'operation refusee et sa zone
  /// locale sont remplacees dans la meme transaction.
  Future<ZoneSaveResult> save(NewZone zone, {OutboxRow? replacing}) async {
    final duplicate = await _findDuplicate(zone, ignoring: replacing?.clientId);
    if (duplicate != null) return ZoneAlreadyExists(duplicate);

    final now = _now().toUtc();
    final row = ZoneRow(
      id: zone.clientId,
      siteId: zone.siteId,
      clientId: zone.clientId,
      block: zone.block,
      elevation: zone.elevation,
      roomType: zone.roomType,
      roomNumber: zone.roomNumber,
      roomLabel: zone.roomLabel,
      version: 0,
      isPending: true,
      createdAt: now,
    );
    final saved = await _outbox.saveWithOperation(
      operation: OutboxOperationsCompanion.insert(
        clientId: zone.clientId,
        ownerUserId: zone.userId,
        entity: 'zone',
        operation: 'create',
        siteId: Value(zone.siteId),
        label: zone.label,
        payloadJson: jsonEncode(_payload(zone, now)),
        createdAt: now,
      ),
      localWrite: () async {
        if (replacing != null) {
          await _db.zonesDao.deleteZone(replacing.clientId);
          await _db.outboxDao.deleteOperation(replacing.id);
        }
        await _db.zonesDao.insertPending(row);
        await _db.userPrefsDao.set(
          zone.userId,
          UserPrefKeys.lastZoneId,
          zone.clientId,
        );
      },
    );
    if (!saved) return const ZoneAlreadySaved();
    onLocalWrite?.call();
    return ZoneSaved(row);
  }

  Future<ZoneRow?> _findDuplicate(NewZone zone, {String? ignoring}) async {
    final all = await _db.zonesDao
        .watchBySite(zone.siteId, includeArchived: true)
        .first;
    for (final existing in all) {
      // Ni la zone en cours de correction, ni celle que CE formulaire vient d'enregistrer
      // (double appui : « deja enregistre », pas « existe deja »).
      if (existing.id == ignoring || existing.id == zone.clientId) continue;
      if (existing.block == zone.block &&
          existing.elevation == zone.elevation &&
          existing.roomType == zone.roomType &&
          existing.roomNumber == zone.roomNumber &&
          (existing.roomLabel ?? '') == (zone.roomLabel ?? '')) {
        return existing;
      }
    }
    return null;
  }

  /// Corps de `POST /sync/push` (`SyncPushOperation.payload`) : champs de la ressource. La cote
  /// part comme nombre JSON a deux decimales (conversion de transport, aucun calcul).
  static Map<String, Object?> _payload(NewZone zone, DateTime now) => {
    'clientCreatedAt': now.toIso8601String(),
    'block': zone.block,
    if (zone.elevation != null)
      'elevation': double.parse(zone.elevation!.toStringAsFixed(2)),
    if (zone.roomType != null) 'roomType': zone.roomType,
    if (zone.roomNumber != null) 'roomNumber': zone.roomNumber,
    if ((zone.roomLabel ?? '').isNotEmpty) 'roomLabel': zone.roomLabel,
  };

  /// Derniere zone utilisee (preselectionnee, CA-009.1, CA-011.1), si elle existe encore.
  Future<ZoneRow?> lastUsedZone(String userId) async {
    final id = await _db.userPrefsDao.get(userId, UserPrefKeys.lastZoneId);
    return id == null ? null : _db.zonesDao.getById(id);
  }

  Future<void> rememberZone(String userId, String zoneId) =>
      _db.userPrefsDao.set(userId, UserPrefKeys.lastZoneId, zoneId);

  Stream<List<ZoneRow>> watchZones(String siteId) =>
      _db.zonesDao.watchBySite(siteId);
}
