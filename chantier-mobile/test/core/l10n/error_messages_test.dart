import 'dart:io';
import 'dart:ui';

import 'package:chantier_mobile/core/l10n/error_messages.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Codes de la premiere colonne du catalogue `docs/api/codes-erreur.md`.
List<String> _catalogCodes() {
  final file = File('../docs/api/codes-erreur.md');
  expect(
    file.existsSync(),
    isTrue,
    reason: 'catalogue introuvable : ${file.absolute.path}',
  );
  final codes = <String>[];
  for (final line in file.readAsLinesSync()) {
    if (!line.startsWith('| `')) continue;
    final firstCell = line.split('|')[1];
    codes.addAll(
      RegExp(r'`([A-Z][A-Z_]+)`').allMatches(firstCell).map((m) => m.group(1)!),
    );
  }
  return codes;
}

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  test('le catalogue est bien lu', () {
    expect(
      _catalogCodes(),
      containsAll(['ZONE_EXISTANTE', 'ACCES_RETIRE', 'UNITE_OBLIGATOIRE']),
    );
  });

  test(
    'tout code du catalogue a un message en francais ET en arabe (CA-014.5, CA-014.9)',
    () {
      final missing = <String>[];
      for (final code in _catalogCodes()) {
        for (final l10n in [fr, ar]) {
          final message = errorMessageForCode(l10n, code);
          if (message == null || message.trim().isEmpty) {
            missing.add('$code (${l10n.localeName})');
          }
        }
      }

      expect(missing, isEmpty);
    },
  );

  test('CA-001.3 : message unique et exact pour les identifiants invalides', () {
    expect(
      errorMessageForCode(fr, 'IDENTIFIANTS_INVALIDES'),
      'Identifiant ou mot de passe incorrect, ou compte inactif. Contactez votre administrateur.',
    );
  });

  test(
    'le code prime sur le type, le texte brut du serveur n est jamais utilise',
    () {
      const error = BusinessRuleApiException(
        status: 422,
        code: 'ZONE_EXISTANTE',
      );

      expect(
        apiErrorMessage(fr, error),
        'Cette zone existe déjà sur ce chantier.',
      );
      expect(apiErrorMessage(ar, error), contains('المنطقة'));
    },
  );

  test('code inconnu : message selon le type d erreur', () {
    const unknownCode = 'CODE_DU_FUTUR';
    expect(
      apiErrorMessage(
        fr,
        const BusinessRuleApiException(status: 422, code: unknownCode),
      ),
      fr.errorUnknown,
    );
    expect(
      apiErrorMessage(
        fr,
        const ServerApiException(status: 500, code: unknownCode),
      ),
      fr.errorErreurInterne,
    );
  });

  test('erreurs de transport traduites', () {
    expect(apiErrorMessage(fr, const NetworkApiException()), fr.errorNetwork);
    expect(apiErrorMessage(ar, const NetworkApiException()), ar.errorNetwork);
    expect(apiErrorMessage(fr, const TimeoutApiException()), fr.errorTimeout);
    expect(apiErrorMessage(fr, const UnknownApiException()), fr.errorUnknown);
  });

  test('aucun message n expose un texte technique', () {
    final technical = RegExp(
      r'exception|stack|sql|null|\bhttp\b',
      caseSensitive: false,
    );
    for (final l10n in [fr, ar]) {
      for (final code in _catalogCodes()) {
        final message = errorMessageForCode(l10n, code)!;
        expect(
          technical.hasMatch(message),
          isFalse,
          reason: '$code : $message',
        );
      }
    }
  });
}
