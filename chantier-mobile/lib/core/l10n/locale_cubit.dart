import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Langue de l'interface (francais par defaut, CA-014.2), memorisee sur le telephone
/// pour pouvoir etre choisie **avant** la connexion (CA-001.8). La langue du compte
/// (`PUT /auth/me/language`) est branchee avec l'authentification (M6).
///
/// Le changement est immediat et hors ligne : `MaterialApp` reconstruit tout l'arbre,
/// y compris le sens de lecture (RTL en arabe).
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(_read(_prefs));

  static const String preferenceKey = 'app_language';
  static const String french = 'fr';
  static const String arabic = 'ar';
  static const List<String> supportedLanguageCodes = [french, arabic];
  static const List<Locale> supportedLocales = [Locale(french), Locale(arabic)];

  final SharedPreferences _prefs;

  static Locale _read(SharedPreferences prefs) {
    final code = prefs.getString(preferenceKey);
    return Locale(supportedLanguageCodes.contains(code) ? code! : french);
  }

  /// Code a envoyer dans `Accept-Language` et a memoriser cote serveur.
  String get languageCode => state.languageCode;

  Future<void> setLanguage(String code) async {
    if (!supportedLanguageCodes.contains(code) || code == state.languageCode) {
      return;
    }
    emit(Locale(code));
    await _prefs.setString(preferenceKey, code);
  }
}
