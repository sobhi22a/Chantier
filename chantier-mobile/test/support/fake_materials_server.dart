import 'package:chantier_mobile/core/api/generated/export.dart';

import 'api_json.dart';

/// Serveur simule des demandes de materiaux (**aucun appel reseau reel**) : rejoue les regles du
/// contrat `docs/api/demandes-materiaux-livraisons.md` pour `request` / `create`, `update` et
/// `transition` (ADR 0011) :
///
/// * `create` idempotent par `clientId` (`applied` puis `duplicate`), numero `DEM-nnn` donne ici ;
/// * `update` : comparaison a trois valeurs par champ, tout ou rien, premiere arrivee retenue
///   (`conflict` + `CONFLIT_VERSION` + `conflictFields`) ; produit, quantite et zone verrouilles
///   apres la validation (`DEMANDE_VERROUILLEE`) ; demande close (`TRANSITION_INTERDITE`) ;
/// * `transition` : le serveur gagne sur les statuts (`duplicate` si l'etat est deja atteint,
///   `conflict` + `TRANSITION_INTERDITE` sinon) ;
/// * un renvoi du meme `clientId` rend le meme resultat (journal d'operations).
class FakeMaterialsServer {
  FakeMaterialsServer({
    this.siteId = '0192a000-0000-7000-8000-0000000000a1',
    this.productNames = const {
      '0192a000-0000-7000-8000-0000000000d1': 'Ciment CPJ 42,5',
    },
  });

  final String siteId;
  final Map<String, String> productNames;

  final Map<String, Map<String, Object?>> requests = {};
  final Map<String, String> _idByClientId = {};
  final Map<String, SyncPushResult> _journal = {};
  int _numbers = 0;
  int _versions = 51000;

  /// Nombre de demandes creees (prouve l'idempotence : jamais deux pour un meme `clientId`).
  int get createdCount => requests.length;

  /// Numeros attribues, dans l'ordre.
  List<String> get numbers => [
    for (final request in requests.values) request['number']! as String,
  ];

  Map<String, Object?>? byNumber(String number) {
    for (final request in requests.values) {
      if (request['number'] == number) return request;
    }
    return null;
  }

  /// Ligne `request` du pull pour [id] (etat actuel).
  Map<String, Object?> pullRow(String id) {
    final data = requests[id]!;
    return syncChangeJson('request', data, version: data['version']! as String);
  }

  /// Identifiant serveur de la demande creee avec ce `clientId` (`null` si inconnu).
  String? requestIdOfClient(String clientId) => _idByClientId[clientId];

  /// Le serveur a recalcule la demande (livraison saisie, corrigee, annulee) : nouvelle version.
  void bump(String id) => requests[id]!['version'] = '${_versions++}';

  /// Un autre utilisateur change des champs de la demande (ex. `{'neededBy': '2026-12-01'}`).
  void changeElsewhere(String id, Map<String, Object?> fields) {
    final data = requests[id]!;
    fields.forEach((key, value) => data[key] = value);
    data['version'] = '${_versions++}';
  }

  /// Un autre utilisateur fait passer la demande a [status] (valide, annule, refuse...).
  void setStatus(String id, String status, {Map<String, Object?>? reason}) {
    final data = requests[id]!;
    data['status'] = status;
    data['statusReason'] = reason;
    data['version'] = '${_versions++}';
  }

  SyncPushResult handle(SyncPushOperation op) {
    final known = _journal[op.clientId];
    if (known != null) return _replay(known, op);
    final result = switch (op.operation) {
      'create' => _create(op),
      'update' => _update(op),
      'transition' => _transition(op),
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
    if (known.status == 'applied') {
      final id = _idOf(known.resource);
      return SyncPushResult(
        clientId: op.clientId,
        status: 'duplicate',
        resource: id == null ? known.resource : _copy(requests[id]!),
      );
    }
    return known;
  }

  String? _idOf(Object? resource) =>
      resource is Map ? resource['id'] as String? : null;

  SyncPushResult _create(SyncPushOperation op) {
    final payload = _map(op.payload);
    final productId = payload['productId'] as String?;
    final quantity = _map(payload['quantity']);
    if (quantity['unit'] == null) {
      return SyncPushResult(
        clientId: op.clientId,
        status: 'rejected',
        code: 'UNITE_OBLIGATOIRE',
      );
    }
    final id = 'srv-${op.clientId}';
    _numbers++;
    final data = requestJson(
      id: id,
      siteId: op.siteId ?? siteId,
      clientId: op.clientId,
      number: 'DEM-${_numbers.toString().padLeft(3, '0')}',
      productId: productId,
      productName: productId == null ? null : productNames[productId],
      freeName: payload['freeProductName'] as String?,
      quantity: quantity['value']! as num,
      unit: quantity['unit']! as String,
      zoneId: payload['zoneId'] as String?,
      neededBy: payload['neededBy']! as String,
      priority: (payload['priority'] as String?) ?? 'Normal',
      note: payload['note'] as String?,
      version: '${_versions++}',
    );
    requests[id] = data;
    _idByClientId[op.clientId] = id;
    return SyncPushResult(
      clientId: op.clientId,
      status: 'applied',
      resource: _copy(data),
    );
  }

  Map<String, Object?>? _target(Map<String, Object?> payload) {
    final id = payload['requestId'] as String?;
    if (id != null) return requests[id];
    final clientId = payload['requestClientId'] as String?;
    final known = clientId == null ? null : _idByClientId[clientId];
    return known == null ? null : requests[known];
  }

  SyncPushResult _update(SyncPushOperation op) {
    final payload = _map(op.payload);
    final request = _target(payload);
    if (request == null) {
      return SyncPushResult(
        clientId: op.clientId,
        status: 'rejected',
        code: 'INTROUVABLE',
      );
    }
    final changes = _map(payload['changes']);
    final base = _map(payload['base']);
    final status = request['status']! as String;

    if (const {
      'Delivered',
      'Received',
      'Rejected',
      'Cancelled',
    }.contains(status)) {
      return _conflict(op, request, 'TRANSITION_INTERDITE');
    }
    final locked = changes.keys.any(
      (key) => const {'quantity', 'zoneId', 'productId'}.contains(key),
    );
    if (status != 'Requested' && locked) {
      return _conflict(op, request, 'DEMANDE_VERROUILLEE');
    }

    final conflicts = <String>[];
    for (final field in changes.keys) {
      final actual = _canonical(field, _current(request, field));
      final wanted = _canonical(field, changes[field]);
      final start = _canonical(field, base[field]);
      if (actual == wanted) continue;
      if (actual != start) conflicts.add(field);
    }
    if (conflicts.isNotEmpty) {
      return _conflict(op, request, 'CONFLIT_VERSION', fields: conflicts);
    }
    for (final field in changes.keys) {
      _write(request, field, changes[field]);
    }
    request['version'] = '${_versions++}';
    return SyncPushResult(
      clientId: op.clientId,
      status: 'applied',
      resource: _copy(request),
    );
  }

  SyncPushResult _transition(SyncPushOperation op) {
    final payload = _map(op.payload);
    final request = _target(payload);
    if (request == null) {
      return SyncPushResult(
        clientId: op.clientId,
        status: 'rejected',
        code: 'INTROUVABLE',
      );
    }
    final status = request['status']! as String;
    final action = payload['action'] as String?;
    final (from, to) = switch (action) {
      'approve' => (const {'Requested'}, 'Validated'),
      'reject' => (const {'Requested'}, 'Rejected'),
      'cancel' => (const {'Requested', 'Validated'}, 'Cancelled'),
      'receive' => (const {'Delivered'}, 'Received'),
      _ => (const <String>{}, ''),
    };
    if (to.isEmpty) {
      return SyncPushResult(
        clientId: op.clientId,
        status: 'rejected',
        code: 'VALIDATION',
      );
    }
    if (status == to) {
      return SyncPushResult(
        clientId: op.clientId,
        status: 'duplicate',
        resource: _copy(request),
      );
    }
    if (!from.contains(status)) {
      return _conflict(op, request, 'TRANSITION_INTERDITE');
    }
    request['status'] = to;
    if (action == 'approve') {
      final quantity = payload['quantity'];
      if (quantity is Map) request['quantity'] = Map.of(quantity);
    }
    if (action == 'reject' || action == 'cancel') {
      request['statusReason'] = {
        'code': payload['reasonCode'],
        'note': payload['reasonNote'],
      };
    }
    request['version'] = '${_versions++}';
    return SyncPushResult(
      clientId: op.clientId,
      status: 'applied',
      resource: _copy(request),
    );
  }

  SyncPushResult _conflict(
    SyncPushOperation op,
    Map<String, Object?> request,
    String code, {
    List<String>? fields,
  }) => SyncPushResult(
    clientId: op.clientId,
    status: 'conflict',
    code: code,
    current: _copy(request),
    conflictFields: fields,
  );

  // --- Formes canoniques (comme `RequestCanonical` du serveur) ------------------------------

  Object? _current(Map<String, Object?> request, String field) =>
      field == 'note' ? request['note'] : request[field];

  String? _canonical(String field, Object? value) {
    if (value == null) return null;
    if (field == 'quantity' && value is Map) {
      final number = value['value'];
      final text = number is num && number == number.roundToDouble()
          ? '${number.toInt()}'
          : '$number';
      return '$text ${value['unit']}';
    }
    if (field == 'note') {
      final text = '$value'.trim();
      return text.isEmpty ? null : text;
    }
    return '$value';
  }

  void _write(Map<String, Object?> request, String field, Object? value) {
    if (field == 'quantity') {
      request['quantity'] = Map<String, Object?>.from(value! as Map);
    } else {
      request[field] = value;
    }
  }

  Map<String, Object?> _map(Object? value) =>
      value is Map ? Map<String, Object?>.from(value) : <String, Object?>{};

  Map<String, Object?> _copy(Map<String, Object?> data) => {
    for (final entry in data.entries)
      entry.key: entry.value is Map
          ? Map<String, Object?>.from(entry.value! as Map)
          : entry.value,
  };
}
