import 'dart:ui';

import 'package:chantier_mobile/core/l10n/locale_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  test('francais par defaut (CA-014.2)', () async {
    final cubit = LocaleCubit(await _prefs());

    expect(cubit.state, const Locale('fr'));
    expect(cubit.languageCode, 'fr');
  });

  test('relit la langue memorisee', () async {
    final cubit = LocaleCubit(await _prefs({LocaleCubit.preferenceKey: 'ar'}));

    expect(cubit.state, const Locale('ar'));
  });

  test('valeur memorisee inconnue : retour au francais', () async {
    final cubit = LocaleCubit(await _prefs({LocaleCubit.preferenceKey: 'en'}));

    expect(cubit.state, const Locale('fr'));
  });

  test('setLanguage emet la nouvelle langue et la memorise', () async {
    final prefs = await _prefs();
    final cubit = LocaleCubit(prefs);
    final emitted = <Locale>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.setLanguage('ar');
    await Future<void>.delayed(Duration.zero);

    expect(emitted, [const Locale('ar')]);
    expect(prefs.getString(LocaleCubit.preferenceKey), 'ar');
    await subscription.cancel();
  });

  test('langue non prise en charge ou identique : aucune emission', () async {
    final cubit = LocaleCubit(await _prefs());
    final emitted = <Locale>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.setLanguage('en');
    await cubit.setLanguage('fr');
    await Future<void>.delayed(Duration.zero);

    expect(emitted, isEmpty);
    await subscription.cancel();
  });
}
