part of 'auth_bloc.dart';

enum AuthStatus {
  /// Restauration de la session en cours (ecran de demarrage).
  unknown,
  unauthenticated,

  /// Mot de passe provisoire : changement obligatoire avant d'aller plus loin (CA-001.7).
  passwordChangeRequired,
  authenticated,
}

/// Message a afficher sur l'ecran de connexion apres une fin de session.
enum AuthNotice {
  /// Jetons refuses ou session hors ligne trop ancienne : saisies conservees.
  sessionExpired,

  /// Compte desactive : « Acces retire, contactez votre administrateur ».
  accessRevoked,
}

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user,
    this.isSubmitting = false,
    this.failure,
    this.notice,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.unauthenticated({ApiException? failure, AuthNotice? notice})
    : this._(
        status: AuthStatus.unauthenticated,
        failure: failure,
        notice: notice,
      );

  /// Utilisateur connecte (session ouverte, mot de passe definitif).
  const AuthState.authenticated(AuthUser this.user)
    : status = AuthStatus.authenticated,
      isSubmitting = false,
      failure = null,
      notice = null;

  final AuthStatus status;
  final AuthUser? user;

  /// Envoi en cours : le bouton est inactif (anti-doublon).
  final bool isSubmitting;

  /// Derniere erreur typee (traduite par `code`, jamais le texte du serveur).
  final ApiException? failure;
  final AuthNotice? notice;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    bool? isSubmitting,
    bool clearFailure = false,
    bool clearNotice = false,
  }) => AuthState._(
    status: status,
    user: user,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    failure: clearFailure ? null : failure,
    notice: clearNotice ? null : notice,
  );

  @override
  List<Object?> get props => [status, user, isSubmitting, failure, notice];
}
