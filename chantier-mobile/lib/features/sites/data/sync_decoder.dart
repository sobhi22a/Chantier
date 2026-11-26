import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/data/materials_sync_decoder.dart';
import 'package:decimal/decimal.dart';

/// Une ligne de synchronisation decodee **selon `entity`** : le champ `data` du contrat est un
/// objet libre (`SyncChange.data`), un seul schema OpenAPI ne peut pas dependre de `entity`
/// (ADR 0006, ADR 0009). Chaque entite connue est decodee par son modele genere.
sealed class DecodedChange {
  const DecodedChange();

  String get id;

  /// Version serveur, comparee **numeriquement** (ADR 0009).
  int get version;
}

final class SiteChange extends DecodedChange {
  const SiteChange(this.row);

  final SiteRow row;

  @override
  String get id => row.id;

  @override
  int get version => row.version;
}

final class ZoneChange extends DecodedChange {
  const ZoneChange(this.row);

  final ZoneRow row;

  @override
  String get id => row.id;

  @override
  int get version => row.version;
}

final class MemberChange extends DecodedChange {
  const MemberChange(this.row);

  final SiteMemberRow row;

  @override
  String get id => row.id;

  @override
  int get version => row.version;
}

/// Produit du catalogue (entite **globale** : `siteId` nul, ADR 0012).
final class ProductChange extends DecodedChange {
  const ProductChange(this.row);

  final ProductRow row;

  @override
  String get id => row.id;

  @override
  int get version => row.version;
}

/// Fournisseur (entite **globale**, sans telephone, ADR 0012).
final class SupplierChange extends DecodedChange {
  const SupplierChange(this.row);

  final SupplierRow row;

  @override
  String get id => row.id;

  @override
  int get version => row.version;
}

/// Demande de materiaux d'un chantier (sans champ commercial, ADR 0012).
final class RequestChange extends DecodedChange {
  const RequestChange(this.row);

  final MaterialRequestRow row;

  @override
  String get id => row.id;

  @override
  int get version => row.version;
}

/// Livraison d'un chantier (sans montant, sans photos, sans « BL manquant », ADR 0012).
final class DeliveryChange extends DecodedChange {
  const DeliveryChange(this.row);

  final DeliveryRow row;

  @override
  String get id => row.id;

  @override
  int get version => row.version;
}

/// Photo d'un bon de livraison : metadonnees seulement. Le serveur n'envoie aucune ligne a un
/// role sans `DeliveryPhotos.View`.
final class PhotoChange extends DecodedChange {
  const PhotoChange(this.row);

  final DeliveryPhotoRow row;

  @override
  String get id => row.id;

  @override
  int get version => row.version;
}

/// Entite que cette version de l'application ne connait pas (`wilaya`...) : ignoree, comme le
/// demande le contrat (« un client ignore une entite qu'il ne connait pas »).
final class UnknownEntityChange extends DecodedChange {
  const UnknownEntityChange({
    required this.entity,
    required this.id,
    required this.version,
  });

  final String entity;

  @override
  final String id;

  @override
  final int version;
}

/// Ligne illisible (champ requis absent, version non numerique) : la page entiere echoue et le
/// curseur n'avance pas, plutot que de perdre une ligne en silence.
class SyncDecodeException implements Exception {
  const SyncDecodeException(this.entity);

  final String entity;

  @override
  String toString() => 'SyncDecodeException(entity: $entity)';
}

/// Decode `SyncChange` -> ligne locale.
DecodedChange decodeChange(SyncChange change) {
  final version = _version(change.version, change.entity);
  final data = change.data;
  switch (change.entity) {
    case 'site':
      return SiteChange(siteRowFromJson(_asMap(data, 'site'), version));
    case 'zone':
      return ZoneChange(zoneRowFromJson(_asMap(data, 'zone'), version));
    case 'member':
      return MemberChange(memberRowFromJson(_asMap(data, 'member'), version));
    case 'product':
      return ProductChange(
        productRowFromJson(_asMap(data, 'product'), version),
      );
    case 'supplier':
      return SupplierChange(
        supplierRowFromJson(_asMap(data, 'supplier'), version),
      );
    case 'request':
      return RequestChange(
        requestRowFromJson(_asMap(data, 'request'), version),
      );
    case 'delivery':
      return DeliveryChange(
        deliveryRowFromJson(_asMap(data, 'delivery'), version),
      );
    case 'photo':
      return PhotoChange(photoRowFromJson(_asMap(data, 'photo'), version));
    default:
      return UnknownEntityChange(
        entity: change.entity,
        id: change.id,
        version: version,
      );
  }
}

/// Zone renvoyee par `POST /sync/push` (`resource`) : meme forme que la ligne `zone` du pull.
ZoneRow decodeZoneResource(Object? resource) {
  final map = _asMap(resource, 'zone');
  return zoneRowFromJson(map, _version(map['version'], 'zone'));
}

SiteRow siteRowFromJson(Map<String, Object?> json, int version) {
  try {
    final site = SiteResponse.fromJson(json);
    return SiteRow(
      id: site.id,
      code: site.code,
      name: site.name,
      nameAr: site.nameAr,
      // Chaine du contrat conservee telle quelle (pas de perte si un type est ajoute).
      type: json['type']! as String,
      wilaya: site.wilaya,
      commune: site.commune,
      latitude: _decimal(site.latitude, 6),
      longitude: _decimal(site.longitude, 6),
      owner: site.owner,
      contractNumber: site.contractNumber,
      // Absent sans la permission `ContractAmount.View` : la colonne reste vide (CA-012.7).
      contractAmount: _decimal(site.contractAmount, 2),
      delayDays: site.delayDays,
      odsDate: _dateOnly(site.odsDate),
      contractualEndDate: _dateOnly(site.contractualEndDate),
      archivedAt: site.archivedAt,
      version: version,
      createdAt: site.createdAt,
      createdByName: site.createdByName ?? '',
      updatedAt: site.updatedAt,
      updatedByName: site.updatedByName,
    );
  } on TypeError {
    throw const SyncDecodeException('site');
  } on FormatException {
    throw const SyncDecodeException('site');
  }
}

ZoneRow zoneRowFromJson(Map<String, Object?> json, int version) {
  try {
    final zone = ZoneResponse.fromJson(json);
    return ZoneRow(
      id: zone.id,
      siteId: zone.siteId,
      clientId: zone.clientId,
      block: zone.block,
      elevation: _decimal(zone.elevation, 2),
      // Chaine du contrat conservee telle quelle (un type inconnu ne devient pas `$unknown`).
      roomType: json['roomType'] as String?,
      roomNumber: zone.roomNumber,
      roomLabel: zone.roomLabel,
      archivedAt: zone.archivedAt,
      version: version,
      isPending: false,
      createdAt: zone.createdAt,
      createdByName: zone.createdByName,
      updatedAt: zone.updatedAt,
    );
  } on TypeError {
    throw const SyncDecodeException('zone');
  } on FormatException {
    throw const SyncDecodeException('zone');
  }
}

SiteMemberRow memberRowFromJson(Map<String, Object?> json, int version) {
  try {
    final member = SyncMemberData.fromJson(json);
    return SiteMemberRow(
      id: member.id,
      siteId: member.siteId,
      userId: member.userId,
      fullName: member.fullName,
      role: member.role,
      assignedAt: member.assignedAt,
      version: version,
    );
  } on TypeError {
    throw const SyncDecodeException('member');
  } on FormatException {
    throw const SyncDecodeException('member');
  }
}

int _version(Object? raw, String entity) {
  final parsed = raw is String ? int.tryParse(raw) : null;
  if (parsed == null) throw SyncDecodeException(entity);
  return parsed;
}

Map<String, Object?> _asMap(Object? value, String entity) {
  if (value is Map) return Map<String, Object?>.from(value);
  throw SyncDecodeException(entity);
}

/// JSON number -> decimal texte a l'echelle du contrat. Conversion de transport uniquement :
/// aucune arithmetique sur la valeur (regle 3). `toStringAsFixed` evite la notation
/// scientifique et retablit les zeros finaux perdus par le JSON (`3.4` -> `3.40`).
Decimal? _decimal(double? value, int scale) =>
    value == null ? null : Decimal.parse(value.toStringAsFixed(scale));

/// Date metier (`2026-03-02`) -> date UTC a minuit, sans glissement de fuseau.
DateTime? _dateOnly(DateTime? value) =>
    value == null ? null : DateTime.utc(value.year, value.month, value.day);
