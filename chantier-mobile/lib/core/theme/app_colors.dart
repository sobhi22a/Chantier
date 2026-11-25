import 'package:flutter/painting.dart';

/// Palette « plein soleil » : tous les couples texte/fond depassent 4,5:1 (WCAG AA),
/// les textes principaux 7:1 (verifie par `test/core/theme/app_theme_test.dart`).
/// Aucune information n'est portee par la couleur seule (icone + texte).
abstract final class AppColors {
  static const Color primary = Color(0xFF0A3A75);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD6E4F7);
  static const Color onPrimaryContainer = Color(0xFF031D3D);

  static const Color secondary = Color(0xFF8A3B00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFFE0C7);
  static const Color onSecondaryContainer = Color(0xFF3A1900);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF111827);
  static const Color onSurfaceVariant = Color(0xFF374151);
  static const Color surfaceContainer = Color(0xFFF1F3F6);
  static const Color outline = Color(0xFF4B5563);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  /// Etats de synchronisation (toujours associes a une icone et a un texte).
  static const Color success = Color(0xFF14532D);
  static const Color successContainer = Color(0xFFD7F0DD);
  static const Color warning = Color(0xFF7A4100);
  static const Color warningContainer = Color(0xFFFFF1D9);
}
