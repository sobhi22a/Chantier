import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';

/// Authentification mobile : connexion, session hors ligne, deconnexion (CA-001, CA-002).
abstract interface class AuthRepository {
  /// Dernier identifiant saisi (prerempli, CA-001.2) : non sensible, hors base chiffree.
  String? get lastUserName;

  /// Utilisateur connecte (en memoire), ou `null`. Lu par la synchronisation.
  AuthUser? get currentUser;

  /// Flux des profils recus du serveur (permissions, mot de passe provisoire).
  Stream<AuthUser> get profileUpdates;

  /// Au demarrage : session utilisable **hors ligne** si le dernier contact reussi avec le
  /// serveur date de moins de [offline session days] jours (CA-002.1), sinon reconnexion
  /// demandee, saisies conservees (CA-002.2).
  Future<RestoredSession> restoreSession();

  /// Connexion (reseau necessaire : « Premiere connexion : reseau necessaire »). Leve une
  /// `ApiException` typee. Si les donnees locales appartiennent a un autre compte, elles sont
  /// effacees (telephone partage, CA-002.4) ; la file d'envoi de chacun est conservee.
  Future<AuthUser> login({required String userName, required String password});

  /// Change le mot de passe provisoire puis se reconnecte : le serveur revoque tous les jetons
  /// de rafraichissement au changement.
  Future<AuthUser> changePassword({
    required String userName,
    required String currentPassword,
    required String newPassword,
  });

  /// Memorise le profil recu de `GET /auth/me` (appele par la synchronisation).
  Future<void> applyProfile(MeResponse me);

  /// Deconnexion : jetons revoques cote serveur si possible, effaces ici, donnees synchronisees
  /// purgees. La file d'envoi est **conservee** pour son proprietaire.
  Future<void> logout();

  /// Compte retire (`ACCES_RETIRE`) : efface les donnees chantier ; la file est conservee.
  Future<void> purgeLocalData();

  /// Memorise la langue du compte (`PUT /auth/me/language`), sans bloquer ni echouer hors ligne.
  Future<void> updateLanguage(String languageCode);
}
