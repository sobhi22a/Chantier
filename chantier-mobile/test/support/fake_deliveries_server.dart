import 'package:chantier_mobile/core/api/generated/export.dart';

import 'api_json.dart';
import 'fake_materials_server.dart';

/// Serveur simule des livraisons et de leurs photos (**aucun appel reseau reel**) : rejoue les
/// regles du contrat `docs/api/demandes-materiaux-livraisons.md` (ADR 0011, 0013) pour les
/// operations `delivery` (`create`, `update`, `transition` `cancel`) et `photo` (`create`) :
///
/// * `create` idempotent par `clientId` (`applied` puis `duplicate`), numero `LIV-nnn` donne ici ;
/// * **une livraison n'est jamais refusee a cause du statut de la demande** : demande close ou
///   inconnue = « non rattachee » avec son motif ; demande validee = rattachee et retenue ;
/// * le statut de la demande est **recalcule dans les deux sens** (conversions sac / kg / T avec un
///   sac de 50 kg), la demande `Received` n'est plus recalculee ;
/// * `update` : trois valeurs par champ (`CONFLIT_VERSION` + `conflictFields`), livraison annulee
///   (`TRANSITION_INTERDITE`), demande receptionnee (`DEMANDE_NON_OUVERTE`) ;
/// * `photo` / `create` : 5 photos au plus (`PHOTOS_TROP_NOMBREUSES`), idempotent.
class FakeDeliveriesServer {
  FakeDeliveriesServer(this.materials, {this.maxPhotos = 5});

  final FakeMaterialsServer materials;
  int maxPhotos;

  final Map<String, Map<String, Object?>> deliveries = {};
  final Map<String, Map<String, Object?>> photos = {};
  final Map<String, String> _deliveryByClientId = {};
  final Map<String, SyncPushResult> _journal = {};
  int _numbers = 0;
  int _versions = 60000;

  /// Empreintes declarees a la creation des metadonnees (`photoId` -> sha256).
  final Map<String, String> declaredSha = {};

  int get createdCount => deliveries.length;
  int get photoCount => photos.length;

  List<String> get numbers => [
    for (final delivery in deliveries.values) delivery['number']! as String,
  ];

  Map<String, Object?>? byNumber(String number) {
    for (final delivery in deliveries.values) {
      if (delivery['number'] == number) return delivery;
    }
    return null;
  }

  Map<String, Object?> pullRow(String id) {
    final data = deliveries[id]!;
    return syncChangeJson(
      'delivery',
      data,
      version: data['version']! as String,
    );
  }

  Map<String, Object?> pullPhotoRow(String id) {
    final data = photos[id]!;
    return syncChangeJson('photo', data, version: data['version']! as String);
  }

  /// Un autre utilisateur annule la livraison.
  void cancelElsewhere(String id) {
    final data = deliveries[id]!;
    data['status'] = 'Cancelled';
    data['cancelReason'] = {'code': 'DoubleEntry', 'note': null};
    data['version'] = '${_versions++}';
    _recompute(data['requestId'] as String?);
  }

  /// Un autre utilisateur corrige des champs de la livraison (`{'deliveryNoteNumber': 'BL-1'}`).
  void changeElsewhere(String id, Map<String, Object?> fields) {
    final data = deliveries[id]!;
    fields.forEach((key, value) => data[key] = value);
    data['version'] = '${_versions++}';
    _recompute(data['requestId'] as String?);
  }

  /// Le fichier de la photo est arrive : le serveur la passe a `Uploaded`.
  void markUploaded(String photoId, int sizeBytes) {
    final data = photos[photoId]!;
    data['contentStatus'] = 'Uploaded';
    data['sizeBytes'] = sizeBytes;
    data['uploadedAt'] = '2026-11-25T09:00:00Z';
    data['version'] = '${_versions++}';
  }

  SyncPushResult handle(SyncPushOperation op) {
    final known = _journal[op.clientId];
    if (known != null) return _replay(known, op);
    final result = switch ((op.entity, op.operation)) {
      ('delivery', 'create') => _create(op),
      ('delivery', 'update') => _update(op),
      ('delivery', 'transition') => _cancel(op),
      ('photo', 'create') => _createPhoto(op),
      _ => SyncPushResult(
        clientId: op.clientId,
        status: 'rejected',
        code: 'ENTITE_NON_SYNCHRONISABLE',
      ),
    };
    _journal[op.clientId] = result;
    return result;
  }

  SyncPushResult _replay(SyncPushResult known, SyncPushOperation op) {
    if (known.status != 'applied') return known;
    final id = (known.resource as Map?)?['id'] as String?;
    final current = id == null ? null : (deliveries[id] ?? photos[id]);
    return SyncPushResult(
      clientId: op.clientId,
      status: 'duplicate',
      resource: current == null ? known.resource : _copy(current),
    );
  }

  // --- delivery / create --------------------------------------------------------------------

  SyncPushResult _create(SyncPushOperation op) {
    final payload = _map(op.payload);
    final quantity = _map(payload['quantity']);
    if (quantity['unit'] == null) {
      return _rejected(op, 'UNITE_OBLIGATOIRE');
    }
    final date = payload['deliveryDate'] as String?;
    if (date == null) return _rejected(op, 'DATE_INVALIDE');

    String? requestId = payload['requestId'] as String?;
    var reason =
        payload['requestId'] == null && payload['requestClientId'] == null
        ? 'NoRequestChosen'
        : null;
    final clientRef = payload['requestClientId'] as String?;
    if (requestId == null && clientRef != null) {
      requestId = materials.requestIdOfClient(clientRef);
      if (requestId == null) reason = 'RequestMissing';
    }
    final request = requestId == null ? null : materials.requests[requestId];
    if (requestId != null && request == null) {
      return _rejected(op, 'INTROUVABLE');
    }
    if (request != null) {
      const open = {'Validated', 'Ordered', 'PartiallyDelivered', 'Delivered'};
      if (!open.contains(request['status'])) {
        reason = 'RequestNotOpen';
        requestId = null;
      } else if (!_convertible(
        '${quantity['unit']}',
        '${_map(request['quantity'])['unit']}',
      )) {
        return _rejected(op, 'UNITES_INCOMPATIBLES');
      }
    }

    final attached = reason == null && request != null;
    final id = 'liv-srv-${op.clientId}';
    _numbers++;
    final productId = attached
        ? _map(request['product'])['productId'] as String?
        : payload['productId'] as String?;
    final data = deliveryJson(
      id: id,
      siteId: op.siteId ?? materials.siteId,
      clientId: op.clientId,
      number: 'LIV-${_numbers.toString().padLeft(3, '0')}',
      requestId: attached ? requestId : null,
      requestNumber: attached ? request['number'] as String? : null,
      unattachedReason: attached ? null : reason,
      supplierId: payload['supplierId'] as String?,
      supplierName: payload['supplierId'] == null ? null : 'Fournisseur',
      freeSupplierName: payload['freeSupplierName'] as String?,
      productId: productId,
      productName: productId == null ? null : materials.productNames[productId],
      freeProductName: attached
          ? _map(request['product'])['freeName'] as String?
          : payload['freeProductName'] as String?,
      quantity: quantity['value']! as num,
      unit: quantity['unit']! as String,
      quantityInRequest: attached
          ? _inUnit(
              quantity['value']! as num,
              '${quantity['unit']}',
              '${_map(request['quantity'])['unit']}',
            )
          : null,
      unitInRequest: attached ? '${_map(request['quantity'])['unit']}' : null,
      deliveryDate: date,
      deliveryNoteNumber: _upper(payload['deliveryNoteNumber'] as String?),
      conformity: (payload['conformity'] as String?) ?? 'Conform',
      reserve: payload['reserveReasonCode'] == null
          ? null
          : {
              'code': payload['reserveReasonCode'],
              'note': payload['reserveNote'],
            },
      version: '${_versions++}',
    );
    deliveries[id] = data;
    _deliveryByClientId[op.clientId] = id;
    if (attached) _recompute(requestId);
    return SyncPushResult(
      clientId: op.clientId,
      status: 'applied',
      resource: _copy(data),
    );
  }

  // --- delivery / update --------------------------------------------------------------------

  SyncPushResult _update(SyncPushOperation op) {
    final payload = _map(op.payload);
    final delivery = _target(payload);
    if (delivery == null) return _rejected(op, 'INTROUVABLE');
    final changes = _map(payload['changes']);
    final base = _map(payload['base']);

    if (delivery['status'] == 'Cancelled') {
      return _conflict(op, delivery, 'TRANSITION_INTERDITE');
    }
    if (_requestStatus(delivery) == 'Received') {
      return _conflict(op, delivery, 'DEMANDE_NON_OUVERTE');
    }
    for (final field in changes.keys) {
      if (!base.containsKey(field)) return _rejected(op, 'VALIDATION');
    }

    final conflicts = <String>[];
    for (final field in changes.keys) {
      final actual = _canonical(field, _current(delivery, field));
      final wanted = _canonical(field, changes[field]);
      final start = _canonical(field, base[field]);
      if (actual == wanted) continue;
      if (actual != start) conflicts.add(field);
    }
    if (conflicts.isNotEmpty) {
      return _conflict(op, delivery, 'CONFLIT_VERSION', fields: conflicts);
    }
    for (final field in changes.keys) {
      _write(delivery, field, changes[field]);
    }
    delivery['version'] = '${_versions++}';
    _recompute(delivery['requestId'] as String?);
    return SyncPushResult(
      clientId: op.clientId,
      status: 'applied',
      resource: _copy(delivery),
    );
  }

  // --- delivery / transition (cancel) -------------------------------------------------------

  SyncPushResult _cancel(SyncPushOperation op) {
    final payload = _map(op.payload);
    final delivery = _target(payload);
    if (delivery == null) return _rejected(op, 'INTROUVABLE');
    if (delivery['status'] == 'Cancelled') {
      return SyncPushResult(
        clientId: op.clientId,
        status: 'duplicate',
        resource: _copy(delivery),
      );
    }
    if (_requestStatus(delivery) == 'Received') {
      return _conflict(op, delivery, 'DEMANDE_NON_OUVERTE');
    }
    delivery['status'] = 'Cancelled';
    delivery['cancelReason'] = {
      'code': payload['reasonCode'],
      'note': payload['reasonNote'],
    };
    delivery['version'] = '${_versions++}';
    _recompute(delivery['requestId'] as String?);
    return SyncPushResult(
      clientId: op.clientId,
      status: 'applied',
      resource: _copy(delivery),
    );
  }

  // --- photo / create -----------------------------------------------------------------------

  SyncPushResult _createPhoto(SyncPushOperation op) {
    final payload = _map(op.payload);
    final delivery = _target(payload);
    if (delivery == null) return _rejected(op, 'INTROUVABLE');
    final deliveryId = delivery['id']! as String;
    final existing = photos.values.where((p) => p['deliveryId'] == deliveryId);
    if (existing.length >= maxPhotos) {
      return _rejected(op, 'PHOTOS_TROP_NOMBREUSES');
    }
    final id = 'photo-srv-${op.clientId}';
    final data = photoJson(
      id: id,
      siteId: op.siteId ?? materials.siteId,
      deliveryId: deliveryId,
      clientId: op.clientId,
      sizeBytes: (payload['sizeBytes']! as num).toInt(),
      contentStatus: 'Pending',
      version: '${_versions++}',
    );
    photos[id] = data;
    declaredSha[id] = payload['sha256']! as String;
    return SyncPushResult(
      clientId: op.clientId,
      status: 'applied',
      resource: _copy(data),
    );
  }

  // --- Recalcul du statut de la demande -----------------------------------------------------

  static const Map<String, double> _kilos = {'kg': 1, 't': 1000, 'sac': 50};

  bool _convertible(String from, String to) =>
      from == to || (_kilos.containsKey(from) && _kilos.containsKey(to));

  double _inUnit(num value, String from, String to) =>
      from == to ? value.toDouble() : value * _kilos[from]! / _kilos[to]!;

  void _recompute(String? requestId) {
    if (requestId == null) return;
    final request = materials.requests[requestId];
    if (request == null) return;
    final status = request['status']! as String;
    const recalculated = {'Ordered', 'PartiallyDelivered', 'Delivered'};
    if (!recalculated.contains(status) && status != 'Validated') return;

    final ordered = _map(request['quantity']);
    final unit = ordered['unit']! as String;
    var received = 0.0;
    for (final delivery in deliveries.values) {
      if (delivery['requestId'] != requestId ||
          delivery['status'] == 'Cancelled') {
        continue;
      }
      final quantity = _map(delivery['quantity']);
      received += _inUnit(
        quantity['value']! as num,
        '${quantity['unit']}',
        unit,
      );
    }
    final target = (ordered['value']! as num).toDouble();
    request['receivedQuantity'] = {'value': received, 'unit': unit};
    request['remainingQuantity'] = {
      'value': received >= target ? 0 : target - received,
      'unit': unit,
    };
    request['variance'] = {'value': received - target, 'unit': unit};
    if (status != 'Validated') {
      request['status'] = received == 0
          ? 'Ordered'
          : received >= target
          ? 'Delivered'
          : 'PartiallyDelivered';
    }
    materials.bump(requestId);
  }

  // --- Outils -------------------------------------------------------------------------------

  Map<String, Object?>? _target(Map<String, Object?> payload) {
    final id = payload['deliveryId'] as String?;
    if (id != null) return deliveries[id];
    final clientId = payload['deliveryClientId'] as String?;
    final known = clientId == null ? null : _deliveryByClientId[clientId];
    return known == null ? null : deliveries[known];
  }

  String? _requestStatus(Map<String, Object?> delivery) {
    final requestId = delivery['requestId'] as String?;
    return requestId == null
        ? null
        : materials.requests[requestId]?['status'] as String?;
  }

  Object? _current(Map<String, Object?> delivery, String field) =>
      switch (field) {
        'reserveReasonCode' => _map(delivery['reserve'])['code'],
        'reserveNote' => _map(delivery['reserve'])['note'],
        _ => delivery[field],
      };

  void _write(Map<String, Object?> delivery, String field, Object? value) {
    switch (field) {
      case 'quantity':
        delivery['quantity'] = Map<String, Object?>.from(value! as Map);
      case 'deliveryNoteNumber':
        delivery['deliveryNoteNumber'] = _upper(value as String?);
      case 'reserveReasonCode' || 'reserveNote':
        final reserve = Map<String, Object?>.from(_map(delivery['reserve']));
        reserve[field == 'reserveReasonCode' ? 'code' : 'note'] = value;
        delivery['reserve'] = reserve;
      default:
        delivery[field] = value;
    }
  }

  String? _canonical(String field, Object? value) {
    if (value == null) return null;
    if (field == 'quantity' && value is Map) {
      final number = value['value'];
      final text = number is num && number == number.roundToDouble()
          ? '${number.toInt()}'
          : '$number';
      return '$text ${value['unit']}';
    }
    final text = '$value'.trim();
    if (text.isEmpty) return null;
    return field == 'deliveryNoteNumber' ? text.toUpperCase() : text;
  }

  String? _upper(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed.toUpperCase();
  }

  SyncPushResult _rejected(SyncPushOperation op, String code) =>
      SyncPushResult(clientId: op.clientId, status: 'rejected', code: code);

  SyncPushResult _conflict(
    SyncPushOperation op,
    Map<String, Object?> delivery,
    String code, {
    List<String>? fields,
  }) => SyncPushResult(
    clientId: op.clientId,
    status: 'conflict',
    code: code,
    current: _copy(delivery),
    conflictFields: fields,
  );

  Map<String, Object?> _map(Object? value) =>
      value is Map ? Map<String, Object?>.from(value) : <String, Object?>{};

  Map<String, Object?> _copy(Map<String, Object?> data) => {
    for (final entry in data.entries)
      entry.key: entry.value is Map
          ? Map<String, Object?>.from(entry.value! as Map)
          : entry.value,
  };
}
