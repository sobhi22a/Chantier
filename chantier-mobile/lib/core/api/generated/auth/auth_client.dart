// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/auth_result.dart';
import '../models/change_password_request.dart';
import '../models/login_request.dart';
import '../models/logout_request.dart';
import '../models/me_response.dart';
import '../models/refresh_request.dart';
import '../models/update_language_request.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  /// Changer son mot de passe (obligatoire après un mot de passe provisoire). Révoque tous les jetons de rafraîchissement.
  @POST('/api/v1/auth/change-password')
  Future<void> authChangePassword({
    @Body() required ChangePasswordRequest body,
  });

  /// Se connecter.
  ///
  /// Web (`isAppMobile = false`) : cookie de session HttpOnly. Mobile : jeton d'accès de 15 min et jeton de.
  /// rafraîchissement de 14 jours. Identifiant faux, mot de passe faux et compte désactivé donnent la même réponse.
  @POST('/api/v1/auth/login')
  Future<AuthResult> authLogin({@Body() required LoginRequest body});

  /// Se déconnecter : efface le cookie et révoque le jeton de rafraîchissement fourni.
  @POST('/api/v1/auth/logout')
  Future<void> authLogout({@Body() LogoutRequest? body});

  /// Mon profil et mes permissions. Le téléphone n'est renvoyé qu'à son titulaire.
  @GET('/api/v1/auth/me')
  Future<MeResponse> authMe();

  /// Changer ma langue (français ou arabe).
  @PUT('/api/v1/auth/me/language')
  Future<void> authUpdateLanguage({
    @Body() required UpdateLanguageRequest body,
  });

  /// Renouveler les jetons (mobile). L'ancien jeton de rafraîchissement n'est plus accepté.
  @POST('/api/v1/auth/refresh')
  Future<AuthResult> authRefresh({@Body() required RefreshRequest body});
}
