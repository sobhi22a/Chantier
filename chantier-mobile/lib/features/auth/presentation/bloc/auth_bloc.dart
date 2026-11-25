import 'dart:async';

import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/features/auth/domain/auth_repository.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Etat d'authentification de l'application : verifier la session, se connecter, changer le mot
/// de passe provisoire, se deconnecter. Pilote la navigation (`GoRouterRefreshStream`).
///
/// Ecoute la couche reseau ([SessionEvents]) : jetons refuses -> reconnexion ; compte retire ->
/// donnees chantier effacees ; mot de passe provisoire -> ecran de changement. Dans tous les cas
/// la **file d'envoi est conservee**.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository repository,
    required SessionEvents sessionEvents,
  }) : _repository = repository,
       super(const AuthState.unknown()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthPasswordChangeSubmitted>(_onPasswordChange);
    on<AuthLogoutRequested>(_onLogout);
    on<_SessionEventReceived>(_onSessionEvent);
    on<_ProfileReceived>(_onProfile);

    _subscriptions = [
      sessionEvents.stream.listen((event) => add(_SessionEventReceived(event))),
      repository.profileUpdates.listen((user) => add(_ProfileReceived(user))),
    ];
  }

  final AuthRepository _repository;
  late final List<StreamSubscription<Object?>> _subscriptions;

  /// Dernier identifiant saisi, pour preremplir l'ecran de connexion (CA-001.2).
  String? get lastUserName => _repository.lastUserName;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final restored = await _repository.restoreSession();
    final user = restored.user;
    if (user == null) {
      emit(AuthState.unauthenticated(notice: _noticeFor(restored.ended)));
    } else {
      emit(_signedIn(user));
    }
  }

  Future<void> _onLogin(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // Bouton inactif pendant l'envoi : un double appui ne part qu'une fois (CA-001.6).
    if (state.isSubmitting) return;
    emit(
      state.copyWith(isSubmitting: true, clearFailure: true, clearNotice: true),
    );
    try {
      final user = await _repository.login(
        userName: event.userName.trim(),
        password: event.password,
      );
      emit(_signedIn(user));
    } on ApiException catch (error) {
      emit(AuthState.unauthenticated(failure: error));
    }
  }

  Future<void> _onPasswordChange(
    AuthPasswordChangeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state.user;
    if (state.isSubmitting || current == null) return;
    emit(state.copyWith(isSubmitting: true, clearFailure: true));
    try {
      final user = await _repository.changePassword(
        userName: current.userName,
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(_signedIn(user));
    } on ApiException catch (error) {
      emit(
        AuthState._(
          status: AuthStatus.passwordChangeRequired,
          user: current,
          failure: error,
        ),
      );
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true));
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onSessionEvent(
    _SessionEventReceived event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.unauthenticated) return;
    switch (event.event) {
      case SessionEvent.authRequired:
        // Jetons refuses : reconnexion. Base locale et file d'envoi conservees.
        emit(
          const AuthState.unauthenticated(notice: AuthNotice.sessionExpired),
        );
      case SessionEvent.accessRevoked:
        await _repository.purgeLocalData();
        emit(const AuthState.unauthenticated(notice: AuthNotice.accessRevoked));
      case SessionEvent.passwordChangeRequired:
        final user = state.user;
        if (user != null && state.status == AuthStatus.authenticated) {
          emit(
            AuthState._(
              status: AuthStatus.passwordChangeRequired,
              user: user.copyWith(mustChangePassword: true),
            ),
          );
        }
    }
  }

  void _onProfile(_ProfileReceived event, Emitter<AuthState> emit) {
    if (state.status == AuthStatus.unauthenticated ||
        state.status == AuthStatus.unknown) {
      return;
    }
    emit(_signedIn(event.user));
  }

  AuthState _signedIn(AuthUser user) => AuthState._(
    status: user.mustChangePassword
        ? AuthStatus.passwordChangeRequired
        : AuthStatus.authenticated,
    user: user,
  );

  static AuthNotice? _noticeFor(SessionEnd? ended) => switch (ended) {
    SessionEnd.expired => AuthNotice.sessionExpired,
    SessionEnd.accessRevoked => AuthNotice.accessRevoked,
    null => null,
  };

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
