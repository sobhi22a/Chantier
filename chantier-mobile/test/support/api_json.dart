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
}) => {
  'changes': changes,
  'deleted': deleted,
  'cursor': cursor,
  'hasMore': hasMore,
};
