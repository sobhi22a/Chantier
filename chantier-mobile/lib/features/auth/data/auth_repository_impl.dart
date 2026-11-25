import 'dart:async';
import 'dart:convert';

import 'package:chantier_mobile/core/api/api_clients.dart';
import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/storage/token_pair.dart';
import 'package:chantier_mobile/core/storage/token_store.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:chantier_mobile/features/auth/domain/auth_repository.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClients api,
    required TokenStore tokenStore,
    required AppDatabase database,
    required SharedPreferences preferences,
    required AppConfig config,
    DateTime Function()? now,
    this.logoutTimeout = const Duration(seconds: 5),
  }) : _api = api,
       _tokens = tokenStore,
       _db = database,
       _prefs = preferences,
       _config = config,
       _now = now ?? DateTime.now;

  static const String lastUserNameKey = 'last_user_name';
  static final Logger _log = Logger('AuthRepository');

  final ApiClients _api;
  final TokenStore _tokens;
  final AppDatabase _db;
  final SharedPreferences _prefs;
  final AppConfig _config;
  final DateTime Function() _now;

  /// La deconnexion ne doit pas bloquer l'ecran : revocation serveur au mieux, delai court.
  final Duration logoutTimeout;

  final StreamController<AuthUser> _profiles = StreamController.broadcast();
  AuthUser? _current;

  @override
  String? get lastUserName => _prefs.getString(lastUserNameKey);

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser> get profileUpdates => _profiles.stream;

  @override
  Future<RestoredSession> restoreSession() async {
    final tokens = await _tokens.read();
    final profileJson = await _db.syncStateDao.get(SyncStateKeys.profile);
    if (tokens == null || profileJson == null) {
      return const RestoredSession.signedOut();
    }

    final lastContact = DateTime.tryParse(
      await _db.syncStateDao.get(SyncStateKeys.lastServerContactAt) ?? '',
    );
    final limit = Duration(days: _config.offlineSessionDays);
    if (lastContact == null || _now().difference(lastContact) > limit) {
      // Session trop ancienne : reconnexion demandee. Les jetons sont effaces, les saisies en
      // attente sont conservees et partiront apres reconnexion avec le meme compte (CA-002.2).
      _log.info('Session hors ligne expiree : reconnexion necessaire.');
      await _tokens.clear();
      return const RestoredSession.signedOut(SessionEnd.expired);
    }

    try {
      _current = AuthUser.fromJson(
        Map<String, Object?>.from(jsonDecode(profileJson) as Map),
      );
    } on Object {
      _log.warning('Profil local illisible : reconnexion necessaire.');
      await _tokens.clear();
      return const RestoredSession.signedOut();
    }
    return RestoredSession.signedIn(_current!);
  }

  @override
  Future<AuthUser> login({
    required String userName,
    required String password,
  }) async {
    final result = await ApiClients.guard(
      () => _api.anonymousAuth.authLogin(
        body: LoginRequest(
          userName: userName,
          password: password,
          isAppMobile: true,
        ),
      ),
    );
    final access = result.accessToken;
    final refresh = result.refreshToken;
    if (access == null || refresh == null) {
      throw const UnknownApiException();
    }

    // Telephone partage : les donnees locales d'un autre compte sont effacees avant d'ouvrir la
    // session du nouveau (sa file d'envoi reste a son proprietaire).
    final owner = await _db.syncStateDao.get(SyncStateKeys.ownerUserId);
    if (owner != null && owner != result.user.id) {
      _log.info('Autre compte sur ce telephone : donnees chantier effacees.');
      await _db.purgeSyncedData();
    }

    await _tokens.save(TokenPair(accessToken: access, refreshToken: refresh));
    try {
      // `me` reste autorise avec un mot de passe provisoire : permissions et version.
      final me = await ApiClients.guard(_api.auth.authMe);
      final user = _userFrom(me);
      final previous = await _db.syncStateDao.get(
        SyncStateKeys.permissionsVersion,
      );
      if (previous != null && previous != user.permissionsVersion) {
        // Permissions modifiees pendant l'absence : les champs visibles ont pu changer (montant
        // du marche) : il est efface tout de suite, puis rendu par le rechargement complet a ceux
        // qui y ont encore droit (R1-03). La file d'envoi n'est pas touchee.
        await _db.startFullReload(clearRestrictedFields: true);
      }
      await _store(user);
      await _prefs.setString(lastUserNameKey, userName);
      _current = user;
      return user;
    } on ApiException {
      await _tokens.clear();
      rethrow;
    }
  }

  @override
  Future<AuthUser> changePassword({
    required String userName,
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiClients.guard(
      () => _api.auth.authChangePassword(
        body: ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      ),
    );
    // Le serveur a revoque les jetons de rafraichissement : nouvelle connexion avec le nouveau
    // mot de passe, sans le redemander.
    return login(userName: userName, password: newPassword);
  }

  @override
  Future<void> applyProfile(MeResponse me) async {
    final user = _userFrom(me);
    if (_current == null || _current!.id != user.id) return;
    await _store(user);
    if (_current != user) {
      _current = user;
      if (!_profiles.isClosed) _profiles.add(user);
    }
  }

  @override
  Future<void> logout() async {
    final tokens = await _tokens.read();
    if (tokens != null) {
      try {
        await ApiClients.guard(
          () => _api.auth.authLogout(
            body: LogoutRequest(refreshToken: tokens.refreshToken),
          ),
        ).timeout(logoutTimeout);
      } on Object {
        // Hors ligne ou serveur lent : la deconnexion locale a lieu quand meme ; le jeton
        // expirera de lui-meme (14 jours, usage unique).
        _log.info('Revocation serveur impossible : deconnexion locale seule.');
      }
    }
    await _tokens.clear();
    _current = null;
    await _db.purgeSyncedData();
  }

  @override
  Future<void> purgeLocalData() async {
    await _tokens.clear();
    _current = null;
    await _db.purgeSyncedData();
  }

  @override
  Future<void> updateLanguage(String languageCode) async {
    if (_current == null) return;
    try {
      await ApiClients.guard(
        () => _api.auth.authUpdateLanguage(
          body: UpdateLanguageRequest(language: languageCode),
        ),
      );
    } on ApiException {
      // Hors ligne : le choix reste applique sur le telephone (CA-014.1).
    }
  }

  AuthUser _userFrom(MeResponse me) => AuthUser(
    id: me.id,
    userName: me.userName,
    fullName: me.fullName,
    role: me.role,
    language: me.language,
    mustChangePassword: me.mustChangePassword,
    permissions: List<String>.of(me.permissions),
    permissionsVersion: me.permissionsVersion,
  );

  Future<void> _store(AuthUser user) => _db.syncStateDao.setAll({
    SyncStateKeys.profile: jsonEncode(user.toJson()),
    SyncStateKeys.permissionsVersion: user.permissionsVersion,
    SyncStateKeys.lastServerContactAt: _now().toUtc().toIso8601String(),
  });

  Future<void> dispose() => _profiles.close();
}
