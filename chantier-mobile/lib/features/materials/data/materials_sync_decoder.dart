import 'dart:convert';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/sites/data/sync_decoder.dart';
import 'package:decimal/decimal.dart';

// Decodage des lignes `product`, `supplier`, `request`, `delivery` et `photo` de la synchronisation (ADR 0011, 0012).
//
// Ces lignes sont lues **a la main depuis le JSON** et non par les modeles generes : l'historique
// d'une demande a des statuts de depart ou d'arrivee absents (creation), des evenements de types
// ajoutes plus tard par le serveur et des enumerations que le telephone doit afficher telles que
// recues. Le client genere reste la source du contrat pour les routes et les ecritures ; ici,
// chaque champ est lu avec tolerance (un champ inconnu est ignore, un champ requis absent leve
// `SyncDecodeException` et le curseur n'avance pas).
//
// **Aucun prix, aucun telephone** : `commercial` et `phone` ne sont jamais lus, quoi que le
// serveur envoie (ADR 0012). `order_json` et `history_json` passent en plus par `MaterialJsonGuard`
// a l'ecriture (DAO).

ProductRow productRowFromJson(Map<String, Object?> json, int version) {
  try {
    final defaultUnit = _requiredString(json, 'defaultUnit', 'product');
    return ProductRow(
      id: _requiredString(json, 'id', 'product'),
      nameFr: _requiredString(json, 'nameFr', 'product'),
      nameAr: _optionalString(json, 'nameAr'),
      category: _optionalString(json, 'category') ?? 'Other',
      allowedUnits: _stringList(json['allowedUnits']) ?? [defaultUnit],
      defaultUnit: defaultUnit,
      bagMassKg: _decimal(json['bagMassKg'], 3),
      isActive: json['isActive'] as bool? ?? true,
      version: version,
    );
  } on TypeError {
    throw const SyncDecodeException('product');
  } on FormatException {
    throw const SyncDecodeException('product');
  }
}

SupplierRow supplierRowFromJson(Map<String, Object?> json, int version) {
  try {
    // `phone` n'est jamais lu : le serveur ne l'envoie pas et il ne doit pas etre stocke.
    return SupplierRow(
      id: _requiredString(json, 'id', 'supplier'),
      name: _requiredString(json, 'name', 'supplier'),
      productIds: _stringList(json['productIds']) ?? const [],
      isActive: json['isActive'] as bool? ?? true,
      version: version,
    );
  } on TypeError {
    throw const SyncDecodeException('supplier');
  } on FormatException {
    throw const SyncDecodeException('supplier');
  }
}

/// Demande du serveur (`RequestSyncData`) -> ligne locale confirmee (`isPending = false`).
MaterialRequestRow requestRowFromJson(Map<String, Object?> json, int version) {
  try {
    final product = _map(json['product']);
    final quantity = _map(json['quantity']);
    final statusReason = _map(json['statusReason']);
    final received = _map(json['receivedQuantity']);
    final remaining = _map(json['remainingQuantity']);
    final variance = _map(json['variance']);
    final duplicate = _map(json['possibleDuplicateOf']);
    final order = json['order'];
    final history = json['history'];

    final quantityValue = _decimal(quantity?['value'], 3);
    final quantityUnit = _optionalString(quantity, 'unit');
    if (quantityValue == null || quantityUnit == null) {
      // Une quantite ne voyage jamais sans son unite (regle metier n°1).
      throw const SyncDecodeException('request');
    }

    return MaterialRequestRow(
      id: _requiredString(json, 'id', 'request'),
      siteId: _requiredString(json, 'siteId', 'request'),
      clientId: _optionalString(json, 'clientId'),
      number: _optionalString(json, 'number'),
      productId: _optionalString(product, 'productId'),
      productName: _optionalString(product, 'name'),
      productNameAr: _optionalString(product, 'nameAr'),
      freeProductName: _optionalString(product, 'freeName'),
      quantityValue: quantityValue,
      quantityUnit: quantityUnit,
      zoneId: _optionalString(json, 'zoneId'),
      neededBy: _dateOnly(_requiredString(json, 'neededBy', 'request')),
      priority: _optionalString(json, 'priority') ?? 'Normal',
      note: _optionalString(json, 'note'),
      status: _requiredString(json, 'status', 'request'),
      statusReasonCode: _optionalString(statusReason, 'code'),
      statusReasonNote: _optionalString(statusReason, 'note'),
      receivedValue: _decimal(received?['value'], 3),
      remainingValue: _decimal(remaining?['value'], 3),
      varianceValue: _decimal(variance?['value'], 3),
      variancePercent: _decimal(variance?['percent'], 2),
      isSettled: json['isSettled'] as bool? ?? false,
      possibleDuplicateOfId: _optionalString(duplicate, 'id'),
      possibleDuplicateOfNumber: _optionalString(duplicate, 'number'),
      hasDeliveryWithoutOrder:
          json['hasDeliveryWithoutOrder'] as bool? ?? false,
      orderJson: order is Map ? jsonEncode(order) : null,
      historyJson: history is List ? jsonEncode(history) : null,
      requestedById: _optionalString(json, 'requestedById'),
      requestedByName: _optionalString(json, 'requestedByName'),
      archivedAt: _dateTime(json['archivedAt']),
      archivedByName: _optionalString(json, 'archivedByName'),
      version: version,
      clientCreatedAt: _dateTime(json['clientCreatedAt']),
      isPending: false,
      createdAt:
          _dateTime(json['createdAt']) ??
          (throw const SyncDecodeException('request')),
      createdByName: _optionalString(json, 'createdByName'),
      updatedAt: _dateTime(json['updatedAt']),
      updatedByName: _optionalString(json, 'updatedByName'),
    );
  } on TypeError {
    throw const SyncDecodeException('request');
  } on FormatException {
    throw const SyncDecodeException('request');
  }
}

/// Demande renvoyee par `POST /sync/push` (`resource` ou `current`) : meme forme que la ligne
/// `request` du pull.
MaterialRequestRow decodeRequestResource(Object? resource) {
  final map = _map(resource);
  if (map == null) throw const SyncDecodeException('request');
  final version = int.tryParse('${map['version']}');
  if (version == null) throw const SyncDecodeException('request');
  return requestRowFromJson(map, version);
}

/// Livraison du serveur (`DeliverySyncData`) -> ligne locale confirmee (`isPending = false`).
///
/// `photos`, `missingNote` et `commercial` ne sont **jamais lus** : les photos viennent de
/// l'entite `photo`, « BL manquant » se deduit, et aucun montant n'entre sur le telephone (ADR 0012).
DeliveryRow deliveryRowFromJson(Map<String, Object?> json, int version) {
  try {
    final product = _map(json['product']);
    final quantity = _map(json['quantity']);
    final inRequest = _map(json['quantityInRequestUnit']);
    final reserve = _map(json['reserve']);
    final cancel = _map(json['cancelReason']);
    final duplicate = _map(json['possibleDuplicateOf']);
    final history = json['history'];

    final quantityValue = _decimal(quantity?['value'], 3);
    final quantityUnit = _optionalString(quantity, 'unit');
    if (quantityValue == null || quantityUnit == null) {
      // Une quantite ne voyage jamais sans son unite (regle metier n°1).
      throw const SyncDecodeException('delivery');
    }

    return DeliveryRow(
      id: _requiredString(json, 'id', 'delivery'),
      siteId: _requiredString(json, 'siteId', 'delivery'),
      clientId: _optionalString(json, 'clientId'),
      number: _optionalString(json, 'number'),
      requestId: _optionalString(json, 'requestId'),
      unattachedReason: _optionalString(json, 'unattachedReason'),
      supplierId: _optionalString(json, 'supplierId'),
      supplierName: _optionalString(json, 'supplierName'),
      freeSupplierName: _optionalString(json, 'freeSupplierName'),
      productId: _optionalString(product, 'productId'),
      productName: _optionalString(product, 'name'),
      productNameAr: _optionalString(product, 'nameAr'),
      freeProductName: _optionalString(product, 'freeName'),
      quantityValue: quantityValue,
      quantityUnit: quantityUnit,
      quantityInRequestValue: _decimal(inRequest?['value'], 3),
      quantityInRequestUnit: _optionalString(inRequest, 'unit'),
      deliveryDate: _dateOnly(
        _requiredString(json, 'deliveryDate', 'delivery'),
        'delivery',
      ),
      deliveryNoteNumber: _optionalString(json, 'deliveryNoteNumber'),
      conformity: _optionalString(json, 'conformity') ?? 'Conform',
      reserveReasonCode: _optionalString(reserve, 'code'),
      reserveNote: _optionalString(reserve, 'note'),
      status: _optionalString(json, 'status') ?? 'Recorded',
      cancelReasonCode: _optionalString(cancel, 'code'),
      cancelReasonNote: _optionalString(cancel, 'note'),
      possibleDuplicateOfId: _optionalString(duplicate, 'id'),
      possibleDuplicateOfNumber: _optionalString(duplicate, 'number'),
      historyJson: history is List ? jsonEncode(history) : null,
      version: version,
      clientCreatedAt: _dateTime(json['clientCreatedAt']),
      isPending: false,
      createdAt:
          _dateTime(json['createdAt']) ??
          (throw const SyncDecodeException('delivery')),
      createdByName: _optionalString(json, 'createdByName'),
      updatedAt: _dateTime(json['updatedAt']),
      updatedByName: _optionalString(json, 'updatedByName'),
    );
  } on TypeError {
    throw const SyncDecodeException('delivery');
  } on FormatException {
    throw const SyncDecodeException('delivery');
  }
}

/// Livraison renvoyee par `POST /sync/push` (`resource` ou `current`) : meme forme que la ligne
/// `delivery` du pull.
DeliveryRow decodeDeliveryResource(Object? resource) {
  final map = _map(resource);
  if (map == null) throw const SyncDecodeException('delivery');
  final version = int.tryParse('${map['version']}');
  if (version == null) throw const SyncDecodeException('delivery');
  return deliveryRowFromJson(map, version);
}

/// Photo du serveur (`PhotoResponse`) : metadonnees seulement, ni chemin ni empreinte.
DeliveryPhotoRow photoRowFromJson(Map<String, Object?> json, int version) {
  try {
    return DeliveryPhotoRow(
      id: _requiredString(json, 'id', 'photo'),
      siteId: _requiredString(json, 'siteId', 'photo'),
      deliveryId: _requiredString(json, 'deliveryId', 'photo'),
      clientId: _optionalString(json, 'clientId'),
      takenAt:
          _dateTime(json['takenAt']) ??
          (throw const SyncDecodeException('photo')),
      contentType: _optionalString(json, 'contentType') ?? 'image/jpeg',
      sizeBytes: json['sizeBytes'] is int ? json['sizeBytes']! as int : null,
      contentStatus: _optionalString(json, 'contentStatus') ?? 'Pending',
      version: version,
      isPending: false,
    );
  } on TypeError {
    throw const SyncDecodeException('photo');
  } on FormatException {
    throw const SyncDecodeException('photo');
  }
}

/// Photo renvoyee par `POST /sync/push` ou `PUT .../content` : meme forme que la ligne `photo`.
DeliveryPhotoRow decodePhotoResource(Object? resource) {
  final map = _map(resource);
  if (map == null) throw const SyncDecodeException('photo');
  final version = int.tryParse('${map['version']}');
  if (version == null) throw const SyncDecodeException('photo');
  return photoRowFromJson(map, version);
}

// --- Lecture tolerante -----------------------------------------------------------------------

Map<String, Object?>? _map(Object? value) =>
    value is Map ? Map<String, Object?>.from(value) : null;

String _requiredString(Map<String, Object?>? json, String key, String entity) {
  final value = json?[key];
  if (value is String && value.isNotEmpty) return value;
  throw SyncDecodeException(entity);
}

String? _optionalString(Map<String, Object?>? json, String key) {
  final value = json?[key];
  return value is String && value.isNotEmpty ? value : null;
}

List<String>? _stringList(Object? value) {
  if (value is! List) return null;
  return [
    for (final item in value)
      if (item is String) item,
  ];
}

/// Nombre JSON -> decimal texte a l'echelle du contrat. Conversion de transport uniquement :
/// aucune arithmetique sur la valeur (regle 3).
Decimal? _decimal(Object? value, int scale) {
  if (value is num) return Decimal.parse(value.toStringAsFixed(scale));
  if (value is String) return Decimal.tryParse(value);
  return null;
}

/// `2026-11-26` (date metier sans fuseau) -> date UTC a minuit, sans glissement de fuseau.
DateTime _dateOnly(String text, [String entity = 'request']) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(text);
  if (match == null) throw SyncDecodeException(entity);
  return DateTime.utc(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

DateTime? _dateTime(Object? value) =>
    value is String ? DateTime.parse(value).toUtc() : null;
