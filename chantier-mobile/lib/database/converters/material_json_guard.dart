import 'dart:convert';

/// Garde-fou **a l'ecriture** : ni prix, ni montant, ni numero de bon de commande, ni telephone
/// ne doivent entrer dans la base du telephone, pour aucun role (ADR 0012, CT-MAT-22).
///
/// Le serveur n'envoie deja aucune de ces donnees dans la synchronisation ; ce garde est la
/// seconde barriere (un oubli du serveur ou un decodeur trop permissif ne fait pas fuiter un prix
/// jusqu'au disque). Il fonctionne par **liste blanche** : une cle inconnue est ecartee.
///
/// Les DAO des demandes l'appliquent a `order_json` et `history_json` avant toute ecriture.
abstract final class MaterialJsonGuard {
  /// Cles conservees de la commande incorporee a une demande (sans `commercial`).
  static const Set<String> orderKeys = {
    'id',
    'supplierId',
    'supplierName',
    'orderDate',
    'expectedDeliveryDate',
    'plannedAfterNeedDays',
    'note',
    'version',
  };

  /// Cles conservees d'un evenement d'historique.
  static const Set<String> eventKeys = {
    'id',
    'type',
    'fromStatus',
    'toStatus',
    'reasonCode',
    'reasonNote',
    'changes',
    'actorName',
    'occurredAt',
    'deviceAt',
    'source',
  };

  /// Cles conservees d'un changement `{field, old, new}` d'un evenement.
  /// Champs de l'etat d'une demande rendu avec un conflit (`current`) qui peuvent etre gardes :
  /// liste blanche, `order` et `history` repassent ensuite par leurs gardes.
  static const Set<String> requestStateKeys = {
    'id',
    'siteId',
    'clientId',
    'clientCreatedAt',
    'number',
    'product',
    'quantity',
    'zoneId',
    'neededBy',
    'priority',
    'note',
    'status',
    'statusReason',
    'receivedQuantity',
    'remainingQuantity',
    'variance',
    'isSettled',
    'overdueDays',
    'possibleDuplicateOf',
    'hasDeliveryWithoutOrder',
    'requestedById',
    'requestedByName',
    'archivedAt',
    'archivedByName',
    'version',
    'createdAt',
    'createdByName',
    'updatedAt',
    'updatedByName',
  };

  /// Champs de l'etat d'une livraison rendu avec un conflit (`current`) qui peuvent etre gardes :
  /// jamais `commercial` (montant), jamais `photos`.
  static const Set<String> deliveryStateKeys = {
    'id',
    'siteId',
    'clientId',
    'clientCreatedAt',
    'number',
    'requestId',
    'requestNumber',
    'unattachedReason',
    'supplierId',
    'supplierName',
    'freeSupplierName',
    'product',
    'quantity',
    'quantityInRequestUnit',
    'deliveryDate',
    'deliveryNoteNumber',
    'conformity',
    'reserve',
    'status',
    'cancelReason',
    'possibleDuplicateOf',
    'photoCount',
    'version',
    'createdAt',
    'createdByName',
    'updatedAt',
    'updatedByName',
  };

  static const Set<String> changeKeys = {'field', 'old', 'new'};

  /// Types d'evenement qui portent un prix : jamais conserves.
  static const Set<String> sensitiveEventTypes = {'OrderCommercialEdited'};

  /// Nom de champ qui designe une donnee commerciale ou un contact (ecarte d'un `changes`).
  static final RegExp _sensitiveField = RegExp(
    r'price|prix|amount|montant|commercial|purchase|phone|telephone|tel$',
    caseSensitive: false,
  );

  /// Commande incorporee : liste blanche. `null` ou illisible : `null`.
  /// Etat d'une demande renvoye avec un `conflict` : seuls les champs de la liste blanche sont
  /// gardes, jamais un prix ni un telephone, meme si le serveur en envoyait par erreur.
  static String? sanitizeRequestState(Object? state) {
    if (state is! Map) return null;
    final kept = <String, Object?>{
      for (final entry in state.entries)
        if (requestStateKeys.contains(entry.key)) '${entry.key}': entry.value,
    };
    final order = state['order'];
    if (order is Map) {
      kept['order'] = _decode(sanitizeOrder(jsonEncode(order)));
    }
    final history = state['history'];
    if (history is List) {
      kept['history'] = _decode(sanitizeHistory(jsonEncode(history)));
    }
    return jsonEncode(kept);
  }

  /// Etat d'une livraison renvoye avec un `conflict` : meme liste blanche, jamais un montant.
  static String? sanitizeDeliveryState(Object? state) {
    if (state is! Map) return null;
    final kept = <String, Object?>{
      for (final entry in state.entries)
        if (deliveryStateKeys.contains(entry.key)) '${entry.key}': entry.value,
    };
    final history = state['history'];
    if (history is List) {
      kept['history'] = _decode(sanitizeHistory(jsonEncode(history)));
    }
    return jsonEncode(kept);
  }

  static String? sanitizeOrder(String? json) {
    final decoded = _decode(json);
    if (decoded is! Map<String, Object?>) return null;
    return jsonEncode({
      for (final entry in decoded.entries)
        if (orderKeys.contains(entry.key)) entry.key: entry.value,
    });
  }

  /// Historique : evenements sensibles retires, cles inconnues ecartees, changements portant sur
  /// un champ commercial retires. `null` ou illisible : `null`.
  static String? sanitizeHistory(String? json) {
    final decoded = _decode(json);
    if (decoded is! List) return null;
    final events = <Map<String, Object?>>[];
    for (final item in decoded) {
      if (item is! Map<String, Object?>) continue;
      if (sensitiveEventTypes.contains(item['type'])) continue;
      final event = <String, Object?>{
        for (final entry in item.entries)
          if (eventKeys.contains(entry.key)) entry.key: entry.value,
      };
      final changes = event['changes'];
      if (changes is List) {
        event['changes'] = [
          for (final change in changes)
            if (change is Map<String, Object?> &&
                !_sensitiveField.hasMatch('${change['field']}'))
              {
                for (final entry in change.entries)
                  if (changeKeys.contains(entry.key)) entry.key: entry.value,
              },
        ];
      }
      events.add(event);
    }
    return jsonEncode(events);
  }

  static Object? _decode(String? json) {
    if (json == null) return null;
    try {
      return jsonDecode(json);
    } on FormatException {
      return null;
    }
  }
}
