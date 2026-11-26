import 'dart:convert';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/converters/date_only_text.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Entite et operations de la file d'envoi pour les demandes de materiaux (ADR 0011).
abstract final class RequestEntity {
  static const String name = 'request';
  static const String create = 'create';
  static const String update = 'update';
  static const String transition = 'transition';

  static const String approve = 'approve';
  static const String reject = 'reject';
  static const String cancel = 'cancel';
  static const String receive = 'receive';
}

/// Champs d'une demande que le telephone peut modifier hors ligne (tant qu'elle est `Requested`,
/// puis seulement date, urgence et remarque : le serveur tranche, `DEMANDE_VERROUILLEE`).
/// Le produit ne se corrige pas : « Annuler et recreer » (decision de la tache M4).
abstract final class RequestFieldKeys {
  static const String productId = 'productId';
  static const String freeProductName = 'freeProductName';
  static const String quantity = 'quantity';
  static const String zoneId = 'zoneId';
  static const String neededBy = 'neededBy';
  static const String priority = 'priority';
  static const String note = 'note';

  /// Ordre d'affichage dans « A verifier ».
  static const List<String> editable = [
    quantity,
    zoneId,
    neededBy,
    priority,
    note,
  ];
}

/// Saisie d'une demande (formulaire « Nouvelle demande » ou « Corriger »).
///
/// L'unite est **obligatoire** : une [Quantity] porte toujours la sienne. Exactement un de
/// [productId] et [freeProductName] (« Autre produit »).
class RequestDraft extends Equatable {
  const RequestDraft({
    required this.quantity,
    required this.neededBy,
    this.productId,
    this.freeProductName,
    this.zoneId,
    this.zoneIsPending = false,
    this.priority = RequestPriority.normal,
    this.note,
  }) : assert(
         (productId == null) != (freeProductName == null),
         'exactement un de productId et freeProductName',
       );

  final String? productId;
  final String? freeProductName;
  final Quantity quantity;

  /// Zone du chantier : identifiant du serveur, ou `clientId` d'une zone encore en attente
  /// ([zoneIsPending]).
  final String? zoneId;
  final bool zoneIsPending;

  /// Date de besoin complete (UTC a minuit).
  final DateTime neededBy;
  final RequestPriority priority;
  final String? note;

  @override
  List<Object?> get props => [
    productId,
    freeProductName,
    quantity,
    zoneId,
    zoneIsPending,
    neededBy,
    priority,
    note,
  ];
}

/// Demande visee par une operation : son identifiant serveur, ou le `clientId` de sa creation tant
/// que le serveur n'a pas repondu (ADR 0011, point 5).
class RequestRef extends Equatable {
  const RequestRef.server(String this.requestId) : requestClientId = null;

  const RequestRef.client(String this.requestClientId) : requestId = null;

  /// Reference d'une ligne locale : `clientId` si elle est en attente, identifiant serveur sinon.
  factory RequestRef.of(MaterialRequestRow row) => row.isPending
      ? RequestRef.client(row.clientId ?? row.id)
      : RequestRef.server(row.id);

  final String? requestId;
  final String? requestClientId;

  Map<String, Object?> toJson() => {
    if (requestId != null) 'requestId': requestId,
    if (requestClientId != null) 'requestClientId': requestClientId,
  };

  @override
  List<Object?> get props => [requestId, requestClientId];
}

/// Corps (`payload`) des operations `request` de `POST /sync/push` (ADR 0011).
///
/// Les nombres partent en JSON avec leur valeur exacte (conversion de transport, aucun calcul) ;
/// jamais de statut, de numero ni d'auteur : le serveur seul les fixe.
abstract final class RequestPayloads {
  static Map<String, Object?> quantityJson(Quantity quantity) => {
    'value': _number(quantity.value),
    'unit': quantity.unit.code,
  };

  /// `create` : champs de la demande, zone par `zoneId` ou `zoneClientId` (zone creee hors ligne).
  static Map<String, Object?> create(RequestDraft draft, DateTime now) => {
    'clientCreatedAt': now.toUtc().toIso8601String(),
    if (draft.productId != null) 'productId': draft.productId,
    if (draft.freeProductName != null) 'freeProductName': draft.freeProductName,
    'quantity': quantityJson(draft.quantity),
    if (draft.zoneId != null)
      (draft.zoneIsPending ? 'zoneClientId' : 'zoneId'): draft.zoneId,
    'neededBy': DateOnlyTextConverter.format(draft.neededBy),
    'priority': draft.priority.code,
    if ((draft.note ?? '').isNotEmpty) 'note': draft.note,
  };

  /// `update` : nouvelles valeurs (`changes`) et valeurs vues par le telephone (`base`), pour la
  /// comparaison a trois valeurs du serveur. Chaque champ modifie a sa valeur de depart.
  static Map<String, Object?> update({
    required RequestRef ref,
    required DateTime now,
    required Map<String, Object?> changes,
    required Map<String, Object?> base,
  }) => {
    ...ref.toJson(),
    'clientCreatedAt': now.toUtc().toIso8601String(),
    'changes': changes,
    'base': base,
  };

  static Map<String, Object?> transition({
    required RequestRef ref,
    required DateTime now,
    required String action,
    Quantity? quantity,
    String? reasonCode,
    String? reasonNote,
    String? note,
  }) => {
    ...ref.toJson(),
    'clientCreatedAt': now.toUtc().toIso8601String(),
    'action': action,
    if (quantity != null) 'quantity': quantityJson(quantity),
    if (reasonCode != null) 'reasonCode': reasonCode,
    if ((reasonNote ?? '').isNotEmpty) 'reasonNote': reasonNote,
    if ((note ?? '').isNotEmpty) 'note': note,
  };

  /// Valeur JSON d'une quantite : `300` reste `300`, `2.5` reste `2.5`.
  static Object _number(Decimal value) => value.isInteger
      ? value.toBigInt().toInt()
      : double.parse(value.toString());
}

/// Modification calculee entre l'etat affiche d'une demande et la saisie corrigee.
class RequestEdit extends Equatable {
  const RequestEdit({required this.changes, required this.base});

  /// Champs modifies, avec leur nouvelle valeur.
  final Map<String, Object?> changes;

  /// Valeur de depart de ces memes champs, telle que vue par le telephone.
  final Map<String, Object?> base;

  bool get isEmpty => changes.isEmpty;

  /// Compare [shown] (etat affiche, surcouche comprise) a [draft] : seuls les champs
  /// **differents** sont envoyes. Un produit change n'est pas modifiable ici.
  static RequestEdit diff(MaterialRequestRow shown, RequestDraft draft) {
    final changes = <String, Object?>{};
    final base = <String, Object?>{};

    final shownQuantity = shown.quantity;
    if (shownQuantity == null || shownQuantity != draft.quantity) {
      changes[RequestFieldKeys.quantity] = RequestPayloads.quantityJson(
        draft.quantity,
      );
      base[RequestFieldKeys.quantity] = shownQuantity == null
          ? null
          : RequestPayloads.quantityJson(shownQuantity);
    }
    if (shown.zoneId != draft.zoneId) {
      changes[RequestFieldKeys.zoneId] = draft.zoneId;
      base[RequestFieldKeys.zoneId] = shown.zoneId;
    }
    if (shown.neededBy != draft.neededBy) {
      changes[RequestFieldKeys.neededBy] = DateOnlyTextConverter.format(
        draft.neededBy,
      );
      base[RequestFieldKeys.neededBy] = DateOnlyTextConverter.format(
        shown.neededBy,
      );
    }
    if (shown.priority != draft.priority.code) {
      changes[RequestFieldKeys.priority] = draft.priority.code;
      base[RequestFieldKeys.priority] = shown.priority;
    }
    final newNote = _blankToNull(draft.note);
    if (_blankToNull(shown.note) != newNote) {
      changes[RequestFieldKeys.note] = newNote;
      base[RequestFieldKeys.note] = _blankToNull(shown.note);
    }
    return RequestEdit(changes: changes, base: base);
  }

  static String? _blankToNull(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  List<Object?> get props => [changes, base];
}

/// Lecture d'une operation de la file d'envoi.
extension RequestOperationRowX on OutboxRow {
  bool get isRequestOperation => entity == RequestEntity.name;

  Map<String, Object?> get payload {
    final decoded = jsonDecode(payloadJson);
    return decoded is Map ? Map<String, Object?>.from(decoded) : const {};
  }

  /// `approve`, `reject`, `cancel` ou `receive` pour une `transition`, sinon `null`.
  String? get transitionAction => operation == RequestEntity.transition
      ? payload['action'] as String?
      : null;

  /// Identifiant serveur (`requestId`) ou `clientId` (`requestClientId`) vise par l'operation.
  /// Pour un `create`, la demande est designee par le `clientId` de l'operation elle-meme.
  RequestRef? get requestRef {
    if (!isRequestOperation) return null;
    if (operation == RequestEntity.create) return RequestRef.client(clientId);
    final data = payload;
    final id = data['requestId'];
    if (id is String) return RequestRef.server(id);
    final client = data['requestClientId'];
    return client is String ? RequestRef.client(client) : null;
  }

  /// Vrai si l'operation vise la demande [row] (par son identifiant serveur ou son `clientId`).
  bool targets(MaterialRequestRow row) {
    final ref = requestRef;
    if (ref == null) return false;
    return (ref.requestId != null && ref.requestId == row.id) ||
        (ref.requestClientId != null &&
            (ref.requestClientId == row.clientId ||
                ref.requestClientId == row.id));
  }
}

/// Saisie reconstituee a partir d'une ligne (etat du serveur) et des modifications de l'utilisateur
/// [changes] (`changes` d'une operation `update`) : sert a « Refaire ma modification » et a
/// « Creer une nouvelle demande avec mes valeurs ». `null` si la quantite est illisible.
RequestDraft? draftFromRow(
  MaterialRequestRow row, {
  Map<String, Object?> changes = const {},
}) {
  var quantity = row.quantity;
  final changedQuantity = changes[RequestFieldKeys.quantity];
  if (changedQuantity is Map) {
    final unit = MeasureUnit.tryParse('${changedQuantity['unit']}');
    final value = Decimal.tryParse('${changedQuantity['value']}');
    if (unit != null && value != null) quantity = Quantity(value, unit);
  }
  if (quantity == null) return null;
  final free = row.productId == null
      ? (row.freeProductName ?? row.productName)
      : null;
  if (row.productId == null && free == null) return null;
  final neededBy = changes[RequestFieldKeys.neededBy];
  final priority = changes[RequestFieldKeys.priority];
  final note = changes.containsKey(RequestFieldKeys.note)
      ? changes[RequestFieldKeys.note] as String?
      : row.note;
  return RequestDraft(
    productId: row.productId,
    freeProductName: free,
    quantity: quantity,
    zoneId: changes.containsKey(RequestFieldKeys.zoneId)
        ? changes[RequestFieldKeys.zoneId] as String?
        : row.zoneId,
    neededBy: neededBy is String
        ? DateOnlyTextConverter.parse(neededBy)
        : row.neededBy,
    priority:
        RequestPriority.tryParse(
          priority is String ? priority : row.priority,
        ) ??
        RequestPriority.normal,
    note: note,
  );
}

/// Saisie reconstituee a partir de la charge utile d'un `create` refuse (« Corriger ma saisie »).
RequestDraft? draftFromCreatePayload(Map<String, Object?> payload) {
  final quantity = payload[RequestFieldKeys.quantity];
  if (quantity is! Map) return null;
  final unit = MeasureUnit.tryParse('${quantity['unit']}');
  final value = Decimal.tryParse('${quantity['value']}');
  final neededBy = payload[RequestFieldKeys.neededBy];
  if (unit == null || value == null || neededBy is! String) return null;
  final productId = payload[RequestFieldKeys.productId] as String?;
  final freeName = payload[RequestFieldKeys.freeProductName] as String?;
  if ((productId == null) == (freeName == null)) return null;
  final clientZone = payload['zoneClientId'] as String?;
  return RequestDraft(
    productId: productId,
    freeProductName: freeName,
    quantity: Quantity(value, unit),
    zoneId: clientZone ?? payload[RequestFieldKeys.zoneId] as String?,
    zoneIsPending: clientZone != null,
    neededBy: DateOnlyTextConverter.parse(neededBy),
    priority:
        RequestPriority.tryParse(
          payload[RequestFieldKeys.priority] as String?,
        ) ??
        RequestPriority.normal,
    note: payload[RequestFieldKeys.note] as String?,
  );
}
