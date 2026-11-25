import 'dart:async';

import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/features/auth/domain/auth_repository.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';

/// Faux depot d'authentification, scriptable (aucun appel reseau).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.restored = const RestoredSession.signedOut()});

  RestoredSession restored;
  AuthUser? loginResult;
  ApiException? loginError;
  ApiException? changePasswordError;

  /// Si defini, `login` attend ce `Completer` (simule un envoi en cours).
  Completer<void>? loginGate;

  int loginCalls = 0;
  int logoutCalls = 0;
  int purgeCalls = 0;
  final List<String> languageUpdates = [];
  final List<(String, String)> loginAttempts = [];

  final StreamController<AuthUser> _profiles = StreamController.broadcast();
  AuthUser? _current;

  @override
  String? lastUserName;

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser> get profileUpdates => _profiles.stream;

  void pushProfile(AuthUser user) => _profiles.add(user);

  @override
  Future<RestoredSession> restoreSession() async {
    _current = restored.user;
    return restored;
  }

  @override
  Future<AuthUser> login({
    required String userName,
    required String password,
  }) async {
    loginCalls++;
    loginAttempts.add((userName, password));
    await loginGate?.future;
    final error = loginError;
    if (error != null) throw error;
    _current = loginResult ?? testUser();
    return _current!;
  }

  @override
  Future<AuthUser> changePassword({
    required String userName,
    required String currentPassword,
    required String newPassword,
  }) async {
    final error = changePasswordError;
    if (error != null) throw error;
    _current = testUser();
    return _current!;
  }

  @override
  Future<void> applyProfile(MeResponse me) async {}

  @override
  Future<void> logout() async {
    logoutCalls++;
    _current = null;
  }

  @override
  Future<void> purgeLocalData() async {
    purgeCalls++;
    _current = null;
  }

  @override
  Future<void> updateLanguage(String languageCode) async =>
      languageUpdates.add(languageCode);

  Future<void> dispose() => _profiles.close();
}

AuthUser testUser({
  String id = '0192a000-0000-7000-8000-000000000015',
  String userName = 'chef.dev',
  String role = 'ChefChantier',
  String language = 'fr',
  bool mustChangePassword = false,
  List<String> permissions = const [
    'Sites.View',
    'Zones.View',
    'Zones.Create',
    'Zones.Update',
    'SiteMembers.View',
  ],
  String permissionsVersion = 'a41f09c2',
}) => AuthUser(
  id: id,
  userName: userName,
  fullName: 'Mourad B.',
  role: role,
  language: language,
  mustChangePassword: mustChangePassword,
  permissions: permissions,
  permissionsVersion: permissionsVersion,
);
