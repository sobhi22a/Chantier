part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

/// Au demarrage : restaure la session (hors ligne possible).
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({required this.userName, required this.password});

  final String userName;
  final String password;

  /// Jamais de mot de passe dans les journaux ni dans les comparaisons de debogage.
  @override
  List<Object?> get props => [userName];

  @override
  String toString() => 'AuthLoginSubmitted()';
}

final class AuthPasswordChangeSubmitted extends AuthEvent {
  const AuthPasswordChangeSubmitted({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  String toString() => 'AuthPasswordChangeSubmitted()';
}

/// Deconnexion **deja confirmee** par l'utilisateur (ecran de confirmation en deux temps quand
/// des saisies sont en attente).
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class _SessionEventReceived extends AuthEvent {
  const _SessionEventReceived(this.event);

  final SessionEvent event;

  @override
  List<Object?> get props => [event];
}

final class _ProfileReceived extends AuthEvent {
  const _ProfileReceived(this.user);

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}
