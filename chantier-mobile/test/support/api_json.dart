// Corps JSON conformes a `docs/api/openapi.json` (donnees fictives).

Map<String, Object?> userJson({
  String id = '0192a000-0000-7000-8000-000000000015',
  String userName = 'chef.dev',
  String fullName = 'Mourad B.',
  String role = 'ChefChantier',
  String language = 'fr',
  bool mustChangePassword = false,
}) => {
  'id': id,
  'userName': userName,
  'fullName': fullName,
  'role': role,
  'language': language,
  'mustChangePassword': mustChangePassword,
};

/// Reponse de `POST /auth/login` (mobile) ou `POST /auth/refresh`.
Map<String, Object?> authResultJson({
  String accessToken = 'ACCESS-NEW-SECRET',
  String refreshToken = 'REFRESH-NEW-SECRET',
  bool mustChangePassword = false,
}) => {
  'user': userJson(mustChangePassword: mustChangePassword),
  'accessToken': accessToken,
  'refreshToken': refreshToken,
  'expiresIn': 900,
};

/// Reponse de `GET /auth/me`.
Map<String, Object?> meJson({
  String id = '0192a000-0000-7000-8000-000000000015',
  String userName = 'chef.dev',
  String fullName = 'Mourad B.',
  String role = 'ChefChantier',
  String language = 'fr',
  List<String> permissions = const [
    'Sites.View',
    'Zones.View',
    'Zones.Create',
    'Zones.Update',
    'SiteMembers.View',
  ],
  String permissionsVersion = 'a41f09c2',
  bool mustChangePassword = false,
}) => {
  'id': id,
  'userName': userName,
  'fullName': fullName,
  'phoneNumber': '0550 00 00 15',
  'role': role,
  'language': language,
  'permissions': permissions,
  'permissionsVersion': permissionsVersion,
  'mustChangePassword': mustChangePassword,
};

/// `SiteResponse` (exemple de `docs/api/socle.md`, chantier fictif).
Map<String, Object?> siteJson({
  String id = '0192a000-0000-7000-8000-0000000000a1',
  String code = 'CH-ECO-UV18',
  String name = 'École UV18',
  String? nameAr,
  String version = '48213',
  double? contractAmount,
  String? odsDate = '2026-03-02',
  String? contractualEndDate = '2027-08-24',
  String? archivedAt,
}) => {
  'id': id,
  'code': code,
  'name': name,
  'nameAr': nameAr,
  'type': 'School',
  'wilaya': 'Blida',
  'commune': 'Boufarik',
  'latitude': 36.575,
  'longitude': 2.912,
  'owner': 'Direction des équipements publics (fictive)',
  'contractNumber': 'M-2026-UV18-001',
  if (contractAmount != null) 'contractAmount': contractAmount,
  'delayDays': 540,
  'odsDate': odsDate,
  'contractualEndDate': contractualEndDate,
  'archivedAt': archivedAt,
  'archivedByName': null,
  'version': version,
  'createdAt': '2026-11-24T08:00:00Z',
  'createdByName': 'Farid L.',
  'updatedAt': null,
  'updatedByName': null,
};

/// `ZoneResponse`.
Map<String, Object?> zoneJson({
  String id = '0192a000-0000-7000-8000-0000000000b1',
  String siteId = '0192a000-0000-7000-8000-0000000000a1',
  String? clientId,
  String block = 'Bloc 01',
  num? elevation = 3.4,
  String? roomType = 'Classroom',
  int? roomNumber = 2,
  String? roomLabel,
  String version = '48230',
  String? archivedAt,
}) => {
  'id': id,
  'siteId': siteId,
  'clientId': clientId,
  'clientCreatedAt': null,
  'block': block,
  'elevation': elevation,
  'roomType': roomType,
  'roomNumber': roomNumber,
  'roomLabel': roomLabel,
  'archivedAt': archivedAt,
  'archivedByName': null,
  'version': version,
  'createdAt': '2026-11-24T08:05:00Z',
  'createdByName': 'Farid L.',
  'updatedAt': null,
  'updatedByName': null,
};

/// `SyncMemberData`.
Map<String, Object?> memberJson({
  String id = '0192a000-0000-7000-8000-0000000000c1',
  String siteId = '0192a000-0000-7000-8000-0000000000a1',
  String userId = '0192a000-0000-7000-8000-000000000015',
  String fullName = 'Mourad B.',
  String role = 'ChefChantier',
}) => {
  'id': id,
  'siteId': siteId,
  'userId': userId,
  'fullName': fullName,
  'role': role,
  'assignedAt': '2026-11-24T08:10:00Z',
};

Map<String, Object?> syncChangeJson(
  String entity,
  Map<String, Object?> data, {
  required String version,
}) => {
  'entity': entity,
  'id': data['id'],
  'siteId': entity == 'site' ? data['id'] : data['siteId'],
  'version': version,
  'data': data,
};

Map<String, Object?> syncPullJson({
  List<Map<String, Object?>> changes = const [],
  List<Map<String, Object?>> deleted = const [],
  String cursor = '48301',
  bool hasMore = false,
  bool? resetRequired,
}) => {
  'changes': changes,
  'deleted': deleted,
  'cursor': cursor,
  'hasMore': hasMore,
  'resetRequired': ?resetRequired,
};

/// `ProductResponse` (ligne `product` du pull : entite globale, `siteId` nul).
Map<String, Object?> productJson({
  String id = '0192a000-0000-7000-8000-0000000000d1',
  String nameFr = 'Ciment CPJ 42,5',
  String? nameAr = 'إسمنت CPJ 42,5',
  String category = 'Binders',
  List<String> allowedUnits = const ['sac', 't', 'kg'],
  String defaultUnit = 'sac',
  num? bagMassKg = 50,
  bool isActive = true,
  String version = '47000',
}) => {
  'id': id,
  'nameFr': nameFr,
  'nameAr': nameAr,
  'category': category,
  'allowedUnits': allowedUnits,
  'defaultUnit': defaultUnit,
  'bagMassKg': bagMassKg,
  'isActive': isActive,
  'deactivatedAt': null,
  'version': version,
  'createdAt': '2026-11-24T08:00:00Z',
  'createdByName': 'Karim A.',
  'updatedAt': null,
  'updatedByName': null,
};

/// `SupplierSyncData` : **sans telephone** (ADR 0012).
Map<String, Object?> supplierJson({
  String id = '0192a000-0000-7000-8000-0000000000e1',
  String name = 'Cimenterie Sigma (fictive)',
  List<String> productIds = const ['0192a000-0000-7000-8000-0000000000d1'],
  bool isActive = true,
  String version = '47001',
}) => {
  'id': id,
  'name': name,
  'productIds': productIds,
  'isActive': isActive,
  'deactivatedAt': null,
  'version': version,
  'createdAt': '2026-11-24T08:00:00Z',
  'createdByName': 'Karim A.',
  'updatedAt': null,
  'updatedByName': null,
};

/// `RequestSyncData` : demande d'un chantier, **sans** `commercial` ni `siteCode`.
Map<String, Object?> requestJson({
  String id = '0192a000-0000-7000-8000-0000000000f1',
  String siteId = '0192a000-0000-7000-8000-0000000000a1',
  String? clientId,
  String number = 'DEM-009',
  String? productId = '0192a000-0000-7000-8000-0000000000d1',
  String? productName = 'Ciment CPJ 42,5',
  String? freeName,
  num quantity = 300,
  String unit = 'sac',
  String? zoneId,
  String neededBy = '2026-11-28',
  String priority = 'Normal',
  String? note,
  String status = 'Requested',
  Map<String, Object?>? statusReason,
  Map<String, Object?>? order,
  List<Map<String, Object?>>? history,
  String requestedById = '0192a000-0000-7000-8000-000000000015',
  String version = '51010',
}) => {
  'id': id,
  'siteId': siteId,
  'clientId': clientId,
  'clientCreatedAt': '2026-11-25T06:58:00Z',
  'number': number,
  'product': {
    'productId': productId,
    'name': productName,
    'nameAr': null,
    'freeName': freeName,
  },
  'quantity': {'value': quantity, 'unit': unit},
  'zoneId': zoneId,
  'neededBy': neededBy,
  'priority': priority,
  'note': note,
  'status': status,
  'statusReason': statusReason,
  'isSettled': false,
  'overdueDays': 0,
  'possibleDuplicateOf': null,
  'order': order,
  'requestedById': requestedById,
  'requestedByName': 'Mourad B.',
  'archivedAt': null,
  'archivedByName': null,
  'version': version,
  'createdAt': '2026-11-25T07:00:00Z',
  'createdByName': 'Mourad B.',
  'updatedAt': null,
  'updatedByName': null,
  'history': ?history,
};

/// Ligne `SyncChange` d'une entite **globale** (`siteId` nul).
Map<String, Object?> globalSyncChangeJson(
  String entity,
  Map<String, Object?> data, {
  required String version,
}) => {
  'entity': entity,
  'id': data['id'],
  'siteId': null,
  'version': version,
  'data': data,
};

/// `MaterialSettingsResponse`.
Map<String, Object?> materialSettingsJson({
  int defaultNeededByDays = 3,
  num deliveryTolerancePercent = 0,
}) => {
  'defaultNeededByDays': defaultNeededByDays,
  'deliveryTolerancePercent': deliveryTolerancePercent,
  'maxPhotosPerDelivery': 5,
  'maxPhotoBytes': 5242880,
  'noteMaxLength': 200,
  'reasons': {
    'rejection': ['AlreadyOrdered', 'StockSufficient', 'Other'],
    'requestCancellation': ['EntryError', 'NoLongerNeeded', 'Other'],
    'orderCancellation': ['SupplierUnavailable', 'Other'],
    'settle': ['SupplierWillNotDeliver', 'Other'],
    'deliveryCancellation': ['DoubleEntry', 'Other'],
    'reserve': ['QuantityMissing', 'Other'],
  },
};

/// `DeliverySyncData` : livraison d'un chantier, **sans** `commercial`, `photos` ni `missingNote`.
Map<String, Object?> deliveryJson({
  String id = '0192a000-0000-7000-8000-000000000601',
  String siteId = '0192a000-0000-7000-8000-0000000000a1',
  String? clientId,
  String number = 'LIV-006',
  String? requestId = '0192a000-0000-7000-8000-0000000000f1',
  String? requestNumber = 'DEM-009',
  String? unattachedReason,
  String? supplierId = '0192a000-0000-7000-8000-0000000000e1',
  String? supplierName = 'Cimenterie Sigma (fictive)',
  String? freeSupplierName,
  String? productId = '0192a000-0000-7000-8000-0000000000d1',
  String? productName = 'Ciment CPJ 42,5',
  String? freeProductName,
  num quantity = 10,
  String unit = 't',
  num? quantityInRequest = 200,
  String? unitInRequest = 'sac',
  String deliveryDate = '2026-11-04',
  String? deliveryNoteNumber = 'BL-4471',
  String conformity = 'Conform',
  Map<String, Object?>? reserve,
  String status = 'Recorded',
  Map<String, Object?>? cancelReason,
  List<Map<String, Object?>>? history,
  String version = '49800',
}) => {
  'id': id,
  'siteId': siteId,
  'clientId': clientId,
  'clientCreatedAt': '2026-11-04T08:05:00Z',
  'number': number,
  'requestId': requestId,
  'requestNumber': requestNumber,
  'unattachedReason': unattachedReason,
  'supplierId': supplierId,
  'supplierName': supplierName,
  'freeSupplierName': freeSupplierName,
  'product': {
    'productId': productId,
    'name': productName,
    'nameAr': null,
    'freeName': freeProductName,
  },
  'quantity': {'value': quantity, 'unit': unit},
  'quantityInRequestUnit': quantityInRequest == null
      ? null
      : {'value': quantityInRequest, 'unit': unitInRequest},
  'deliveryDate': deliveryDate,
  'deliveryNoteNumber': deliveryNoteNumber,
  'conformity': conformity,
  'reserve': reserve,
  'status': status,
  'cancelReason': cancelReason,
  'possibleDuplicateOf': null,
  'version': version,
  'createdAt': '2026-11-04T08:10:00Z',
  'createdByName': 'Mourad B.',
  'updatedAt': null,
  'updatedByName': null,
  'history': ?history,
};

/// `PhotoResponse` (ligne `photo` du pull, ou reponse de creation des metadonnees).
Map<String, Object?> photoJson({
  String id = '0192a000-0000-7000-8000-000000000701',
  String siteId = '0192a000-0000-7000-8000-0000000000a1',
  String deliveryId = '0192a000-0000-7000-8000-000000000601',
  String? clientId,
  int sizeBytes = 1480000,
  String contentStatus = 'Uploaded',
  String version = '49900',
}) => {
  'id': id,
  'siteId': siteId,
  'deliveryId': deliveryId,
  'clientId': clientId,
  'takenAt': '2026-11-04T08:10:00Z',
  'contentType': 'image/jpeg',
  'sizeBytes': sizeBytes,
  'contentStatus': contentStatus,
  'uploadedAt': contentStatus == 'Uploaded' ? '2026-11-04T08:20:00Z' : null,
  'version': version,
  'createdAt': '2026-11-04T08:11:00Z',
};
