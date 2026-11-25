import 'package:chantier_mobile/database/app_database.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Donnees de test **fictives** (jeu « Ecole UV18 » du skill metier-chantier).

SiteRow siteRow({
  String id = 'site-uv18',
  String code = 'CH-ECO-UV18',
  String name = 'École UV18',
  String? nameAr,
  int version = 100,
  Decimal? contractAmount,
  DateTime? archivedAt,
  DateTime? odsDate,
  DateTime? contractualEndDate,
}) => SiteRow(
  id: id,
  code: code,
  name: name,
  nameAr: nameAr,
  type: 'School',
  wilaya: 'Blida',
  commune: 'Boufarik',
  latitude: Decimal.parse('36.575'),
  longitude: Decimal.parse('2.912'),
  owner: 'Direction des équipements publics (fictive)',
  contractNumber: 'M-2026-UV18-001',
  contractAmount: contractAmount,
  delayDays: 540,
  odsDate: odsDate,
  contractualEndDate: contractualEndDate,
  archivedAt: archivedAt,
  version: version,
  createdAt: DateTime.utc(2026, 11, 24, 8),
  createdByName: 'Farid L.',
  updatedAt: null,
  updatedByName: null,
);

ZoneRow zoneRow({
  String id = 'zone-1',
  String siteId = 'site-uv18',
  String? clientId,
  String block = 'Bloc 01',
  String? elevation = '3.40',
  String? roomType = 'Classroom',
  int? roomNumber = 2,
  String? roomLabel,
  int version = 200,
  bool isPending = false,
  DateTime? archivedAt,
}) => ZoneRow(
  id: id,
  siteId: siteId,
  clientId: clientId,
  block: block,
  elevation: elevation == null ? null : Decimal.parse(elevation),
  roomType: roomType,
  roomNumber: roomNumber,
  roomLabel: roomLabel,
  archivedAt: archivedAt,
  version: version,
  isPending: isPending,
  createdAt: DateTime.utc(2026, 11, 24, 8, 5),
  createdByName: 'Farid L.',
  updatedAt: null,
);

/// Zone creee hors ligne : `id = clientId`, `version = 0`.
ZoneRow pendingZoneRow({
  required String clientId,
  String siteId = 'site-uv18',
  String block = 'Bloc 01',
  String? elevation = '3.40',
  String? roomType = 'Classroom',
  int? roomNumber = 7,
}) => zoneRow(
  id: clientId,
  siteId: siteId,
  clientId: clientId,
  block: block,
  elevation: elevation,
  roomType: roomType,
  roomNumber: roomNumber,
  version: 0,
  isPending: true,
);

SiteMemberRow memberRow({
  String id = 'member-1',
  String siteId = 'site-uv18',
  String userId = 'user-chef',
  String fullName = 'Mourad B.',
  String role = 'ChefChantier',
  int version = 300,
}) => SiteMemberRow(
  id: id,
  siteId: siteId,
  userId: userId,
  fullName: fullName,
  role: role,
  assignedAt: DateTime.utc(2026, 11, 24, 8, 10),
  version: version,
);

OutboxOperationsCompanion outboxOp({
  required String clientId,
  String owner = 'user-a',
  String siteId = 'site-uv18',
  String label = 'Zone Bloc 01 · +3,40 m · Classe 07',
  DateTime? createdAt,
}) => OutboxOperationsCompanion.insert(
  clientId: clientId,
  ownerUserId: owner,
  entity: 'zone',
  operation: 'create',
  siteId: Value(siteId),
  label: label,
  payloadJson: '{"block":"Bloc 01"}',
  createdAt: createdAt ?? DateTime.utc(2026, 11, 24, 6, 58),
);
