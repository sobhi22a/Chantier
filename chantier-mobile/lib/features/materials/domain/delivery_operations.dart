import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/converters/date_only_text.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Entites et operations de la file d'envoi pour les livraisons et leurs photos (ADR 0011, 0013).
/// N° de bon de livraison : sans espace en debut ni en fin, en **majuscules** (CA-MAT-007.6) ;
/// vide : `null`. Le serveur applique la meme regle : le telephone envoie et affiche la meme forme.
String? normalizeNoteNumber(String? text) {
  final trimmed = text?.trim().toUpperCase();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

abstract final class DeliveryEntity {
  static const String name = 'delivery';
  static const String create = 'create';
  static const String update = 'update';
  static const String transition = 'transition';
  static const String cancel = 'cancel';
}

abstract final class PhotoEntity {
  static const String name = 'photo';
  static const String create = 'create';
  static const String jpeg = 'image/jpeg';
}

/// Champs d'une livraison corrigeables hors ligne : ce sont **les noms du contrat** (`changes` et
/// `base` de l'operation `delivery` / `update`).
abstract final class DeliveryFieldKeys {
  static const String quantity = 'quantity';
  static const String deliveryDate = 'deliveryDate';
  static const String deliveryNoteNumber = 'deliveryNoteNumber';
  static const String conformity = 'conformity';
  static const String reserveReasonCode = 'reserveReasonCode';
  static const String reserveNote = 'reserveNote';

  /// Ordre d'affichage dans « A verifier ».
  static const List<String> editable = [
    quantity,
    deliveryDate,
    deliveryNoteNumber,
    conformity,
    reserveReasonCode,
    reserveNote,
  ];
}

/// Livraison visee par une operation : son identifiant serveur, ou le `clientId` de sa creation
/// tant que le serveur n'a pas repondu.
class DeliveryRef extends Equatable {
  const DeliveryRef.server(String this.deliveryId) : deliveryClientId = null;

  const DeliveryRef.client(String this.deliveryClientId) : deliveryId = null;

  factory DeliveryRef.of(DeliveryRow row) => row.isPending
      ? DeliveryRef.client(row.clientId ?? row.id)
      : DeliveryRef.server(row.id);

  final String? deliveryId;
  final String? deliveryClientId;

  Map<String, Object?> toJson() => {
    if (deliveryId != null) 'deliveryId': deliveryId,
    if (deliveryClientId != null) 'deliveryClientId': deliveryClientId,
  };

  @override
  List<Object?> get props => [deliveryId, deliveryClientId];
}

/// Saisie d'une livraison (formulaire « Recevoir »).
///
/// L'unite est **obligatoire** (une [Quantity] porte toujours la sienne). Rattachee a une demande :
/// le serveur impose le produit de la demande ; sinon [productId] ou [freeProductName] et un
/// fournisseur de la liste ou un nom libre.
class DeliveryDraft extends Equatable {
  const DeliveryDraft({
    required this.quantity,
    required this.deliveryDate,
    this.request,
    this.supplierId,
    this.freeSupplierName,
    this.productId,
    this.freeProductName,
    this.deliveryNoteNumber,
    this.conformity = Conformity.conform,
    this.reserveReasonCode,
    this.reserveNote,
  });

  /// Demande de la livraison (`null` = non rattachee, fait de chantier).
  final RequestRef? request;
  final String? supplierId;
  final String? freeSupplierName;

  /// Seulement sans demande : produit du catalogue ou nom libre.
  final String? productId;
  final String? freeProductName;
  final Quantity quantity;

  /// Date complete (UTC a minuit), jamais dans le futur.
  final DateTime deliveryDate;

  /// Majuscules, sans espace de bord, 30 caracteres au plus (`normalizeNoteNumber`).
  final String? deliveryNoteNumber;
  final Conformity conformity;
  final String? reserveReasonCode;
  final String? reserveNote;

  @override
  List<Object?> get props => [
    request,
    supplierId,
    freeSupplierName,
    productId,
    freeProductName,
    quantity,
    deliveryDate,
    deliveryNoteNumber,
    conformity,
    reserveReasonCode,
    reserveNote,
  ];
}

/// Correction d'une livraison (formulaire « Corriger la livraison »).
class DeliveryEditDraft extends Equatable {
  const DeliveryEditDraft({
    required this.quantity,
    required this.deliveryDate,
    this.deliveryNoteNumber,
    this.conformity = Conformity.conform,
    this.reserveReasonCode,
    this.reserveNote,
  });

  final Quantity quantity;
  final DateTime deliveryDate;
  final String? deliveryNoteNumber;
  final Conformity conformity;
  final String? reserveReasonCode;
  final String? reserveNote;

  @override
  List<Object?> get props => [
    quantity,
    deliveryDate,
    deliveryNoteNumber,
    conformity,
    reserveReasonCode,
    reserveNote,
  ];
}

/// Corps (`payload`) des operations `delivery` et `photo` de `POST /sync/push` (ADR 0011, 0013).
///
/// Jamais de numero, de statut, de montant, de motif de non-rattachement ni d'auteur : le serveur
/// seul les fixe. Les nombres partent avec leur valeur exacte (aucun calcul).
abstract final class DeliveryPayloads {
  /// `create` : produit force par la demande quand elle est designee ; sinon produit et
  /// fournisseur de la saisie.
  static Map<String, Object?> create(DeliveryDraft draft, DateTime now) => {
    'clientCreatedAt': now.toUtc().toIso8601String(),
    ...?draft.request?.toJson(),
    if (draft.supplierId != null) 'supplierId': draft.supplierId,
    if (draft.freeSupplierName != null)
      'freeSupplierName': draft.freeSupplierName,
    if (draft.request == null && draft.productId != null)
      'productId': draft.productId,
    if (draft.request == null && draft.freeProductName != null)
      'freeProductName': draft.freeProductName,
    'quantity': RequestPayloads.quantityJson(draft.quantity),
    'deliveryDate': DateOnlyTextConverter.format(draft.deliveryDate),
    if (normalizeNoteNumber(draft.deliveryNoteNumber) != null)
      'deliveryNoteNumber': normalizeNoteNumber(draft.deliveryNoteNumber),
    'conformity': draft.conformity.code,
    if (draft.conformity == Conformity.withReserve &&
        draft.reserveReasonCode != null)
      'reserveReasonCode': draft.reserveReasonCode,
    if ((draft.reserveNote ?? '').isNotEmpty) 'reserveNote': draft.reserveNote,
  };

  static Map<String, Object?> update({
    required DeliveryRef ref,
    required DateTime now,
    required Map<String, Object?> changes,
    required Map<String, Object?> base,
  }) => {
    ...ref.toJson(),
    'clientCreatedAt': now.toUtc().toIso8601String(),
    'changes': changes,
    'base': base,
  };

  static Map<String, Object?> cancel({
    required DeliveryRef ref,
    required DateTime now,
    required String reasonCode,
    String? reasonNote,
  }) => {
    ...ref.toJson(),
    'clientCreatedAt': now.toUtc().toIso8601String(),
    'action': DeliveryEntity.cancel,
    'reasonCode': reasonCode,
    if ((reasonNote ?? '').isNotEmpty) 'reasonNote': reasonNote,
  };

  /// Metadonnees d'une photo du bon : le fichier part ensuite par `PUT` direct (un a la fois).
  static Map<String, Object?> photo({
    required DeliveryRef delivery,
    required DateTime now,
    required DateTime takenAt,
    required int sizeBytes,
    required String sha256,
  }) => {
    ...delivery.toJson(),
    'clientCreatedAt': now.toUtc().toIso8601String(),
    'takenAt': takenAt.toUtc().toIso8601String(),
    'contentType': PhotoEntity.jpeg,
    'sizeBytes': sizeBytes,
    'sha256': sha256,
  };
}

/// Modification calculee entre la livraison affichee et la saisie corrigee.
///
/// Le serveur ne sait pas **effacer** une valeur deja posee (contrat, ecart 16) : un champ vide ne
/// produit donc aucune modification. Chaque champ modifie porte sa valeur de depart (`base`) ; une
/// valeur de depart absente (n° de BL, reserve) part en chaine vide, forme que le serveur lit comme
/// « rien », sinon il refuse la comparaison a trois valeurs.
class DeliveryEdit extends Equatable {
  const DeliveryEdit({required this.changes, required this.base});

  final Map<String, Object?> changes;
  final Map<String, Object?> base;

  bool get isEmpty => changes.isEmpty;

  static DeliveryEdit diff(DeliveryRow shown, DeliveryEditDraft draft) {
    final changes = <String, Object?>{};
    final base = <String, Object?>{};

    final shownQuantity = shown.quantity;
    if (shownQuantity == null || shownQuantity != draft.quantity) {
      changes[DeliveryFieldKeys.quantity] = RequestPayloads.quantityJson(
        draft.quantity,
      );
      base[DeliveryFieldKeys.quantity] = shownQuantity == null
          ? null
          : RequestPayloads.quantityJson(shownQuantity);
    }
    if (shown.deliveryDate != draft.deliveryDate) {
      changes[DeliveryFieldKeys.deliveryDate] = DateOnlyTextConverter.format(
        draft.deliveryDate,
      );
      base[DeliveryFieldKeys.deliveryDate] = DateOnlyTextConverter.format(
        shown.deliveryDate,
      );
    }
    final newNote = normalizeNoteNumber(draft.deliveryNoteNumber);
    final oldNote = normalizeNoteNumber(shown.deliveryNoteNumber);
    if (newNote != null && newNote != oldNote) {
      changes[DeliveryFieldKeys.deliveryNoteNumber] = newNote;
      base[DeliveryFieldKeys.deliveryNoteNumber] = oldNote ?? '';
    }
    if (shown.conformity != draft.conformity.code) {
      changes[DeliveryFieldKeys.conformity] = draft.conformity.code;
      base[DeliveryFieldKeys.conformity] = shown.conformity;
    }
    if (draft.conformity == Conformity.withReserve) {
      final code = draft.reserveReasonCode;
      if (code != null && code != shown.reserveReasonCode) {
        changes[DeliveryFieldKeys.reserveReasonCode] = code;
        base[DeliveryFieldKeys.reserveReasonCode] =
            shown.reserveReasonCode ?? '';
      }
      final note = _blankToNull(draft.reserveNote);
      if (note != null && note != _blankToNull(shown.reserveNote)) {
        changes[DeliveryFieldKeys.reserveNote] = note;
        base[DeliveryFieldKeys.reserveNote] =
            _blankToNull(shown.reserveNote) ?? '';
      }
    }
    return DeliveryEdit(changes: changes, base: base);
  }

  static String? _blankToNull(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  List<Object?> get props => [changes, base];
}

/// Lecture d'une operation de la file d'envoi qui concerne une livraison ou sa photo.
extension DeliveryOperationRowX on OutboxRow {
  bool get isDeliveryOperation => entity == DeliveryEntity.name;

  bool get isPhotoOperation => entity == PhotoEntity.name;

  /// `cancel` pour une `transition` de livraison, sinon `null`.
  String? get deliveryAction =>
      isDeliveryOperation && operation == DeliveryEntity.transition
      ? payload['action'] as String?
      : null;

  /// Livraison visee par l'operation : pour un `create`, celle que l'operation cree ; pour une
  /// photo, la livraison qui la porte.
  DeliveryRef? get deliveryRef {
    if (isDeliveryOperation && operation == DeliveryEntity.create) {
      return DeliveryRef.client(clientId);
    }
    if (!isDeliveryOperation && !isPhotoOperation) return null;
    final data = payload;
    final id = data['deliveryId'];
    if (id is String) return DeliveryRef.server(id);
    final client = data['deliveryClientId'];
    return client is String ? DeliveryRef.client(client) : null;
  }

  /// Vrai si l'operation vise la livraison [row] (identifiant serveur ou `clientId`).
  bool targetsDelivery(DeliveryRow row) {
    final ref = deliveryRef;
    if (ref == null) return false;
    return (ref.deliveryId != null && ref.deliveryId == row.id) ||
        (ref.deliveryClientId != null &&
            (ref.deliveryClientId == row.clientId ||
                ref.deliveryClientId == row.id));
  }

  /// Demande designee par la creation d'une livraison (`requestId` ou `requestClientId`).
  RequestRef? get deliveryRequestRef {
    if (!isDeliveryOperation || operation != DeliveryEntity.create) return null;
    final data = payload;
    final id = data['requestId'];
    if (id is String) return RequestRef.server(id);
    final client = data['requestClientId'];
    return client is String ? RequestRef.client(client) : null;
  }
}

/// Saisie reconstituee a partir de la charge utile d'une creation refusee (« Corriger ma saisie »).
DeliveryDraft? draftFromDeliveryPayload(Map<String, Object?> payload) {
  final quantity = payload[DeliveryFieldKeys.quantity];
  if (quantity is! Map) return null;
  final unit = MeasureUnit.tryParse('${quantity['unit']}');
  final value = Decimal.tryParse('${quantity['value']}');
  final date = payload[DeliveryFieldKeys.deliveryDate];
  if (unit == null || value == null || date is! String) return null;
  final requestId = payload['requestId'];
  final requestClientId = payload['requestClientId'];
  return DeliveryDraft(
    request: requestId is String
        ? RequestRef.server(requestId)
        : requestClientId is String
        ? RequestRef.client(requestClientId)
        : null,
    supplierId: payload['supplierId'] as String?,
    freeSupplierName: payload['freeSupplierName'] as String?,
    productId: payload['productId'] as String?,
    freeProductName: payload['freeProductName'] as String?,
    quantity: Quantity(value, unit),
    deliveryDate: DateOnlyTextConverter.parse(date),
    deliveryNoteNumber:
        payload[DeliveryFieldKeys.deliveryNoteNumber] as String?,
    conformity:
        Conformity.tryParse(payload[DeliveryFieldKeys.conformity] as String?) ??
        Conformity.conform,
    reserveReasonCode: payload[DeliveryFieldKeys.reserveReasonCode] as String?,
    reserveNote: payload[DeliveryFieldKeys.reserveNote] as String?,
  );
}

/// Saisie reconstituee a partir d'une livraison (etat du serveur) et des modifications de
/// l'utilisateur [changes] (`changes` d'une operation `update`) : sert a « Refaire ma
/// modification ». `null` si la quantite est illisible.
DeliveryDraft? draftFromDeliveryChanges(
  DeliveryRow row, {
  Map<String, Object?> changes = const {},
}) {
  var quantity = row.quantity;
  final changed = changes[DeliveryFieldKeys.quantity];
  if (changed is Map) {
    final unit = MeasureUnit.tryParse('${changed['unit']}');
    final value = Decimal.tryParse('${changed['value']}');
    if (unit != null && value != null) quantity = Quantity(value, unit);
  }
  if (quantity == null) return null;
  final date = changes[DeliveryFieldKeys.deliveryDate];
  final conformity = changes[DeliveryFieldKeys.conformity];
  return DeliveryDraft(
    quantity: quantity,
    deliveryDate: date is String
        ? DateOnlyTextConverter.parse(date)
        : row.deliveryDate,
    deliveryNoteNumber:
        (changes[DeliveryFieldKeys.deliveryNoteNumber] as String?) ??
        row.deliveryNoteNumber,
    conformity:
        Conformity.tryParse(
          conformity is String ? conformity : row.conformity,
        ) ??
        Conformity.conform,
    reserveReasonCode:
        (changes[DeliveryFieldKeys.reserveReasonCode] as String?) ??
        row.reserveReasonCode,
    reserveNote:
        (changes[DeliveryFieldKeys.reserveNote] as String?) ?? row.reserveNote,
  );
}
