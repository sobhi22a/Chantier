import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Journalisation via `package:logging` (ADR 0008), jamais `print`.
///
/// Regle : **aucune donnee personnelle** dans un message (nom, identifiant de connexion,
/// telephone, mot de passe, jeton). Seuls des identifiants techniques (GUID), des codes
/// d'erreur et des compteurs sont journalises. En production, seuls les avertissements sortent.
void configureLogging({bool isRelease = kReleaseMode}) {
  Logger.root.level = isRelease ? Level.WARNING : Level.INFO;
  Logger.root.onRecord.listen((record) {
    if (isRelease) return;
    debugPrint(
      '[${record.level.name}] ${record.loggerName}: ${record.message}',
    );
  });
}
