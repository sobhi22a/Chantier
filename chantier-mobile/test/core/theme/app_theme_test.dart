import 'dart:math' as math;

import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/theme/app_theme.dart';
import 'package:chantier_mobile/core/theme/terrain_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// Rapport de contraste WCAG entre deux couleurs opaques.
double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Contraste plein soleil (ADR 0008 : >= 4,5:1, vise 7:1)', () {
    final pairs = <String, (Color, Color, double)>{
      'texte principal sur fond': (AppColors.onSurface, AppColors.surface, 7),
      'texte secondaire sur fond': (
        AppColors.onSurfaceVariant,
        AppColors.surface,
        7,
      ),
      'texte sur bouton principal': (AppColors.onPrimary, AppColors.primary, 7),
      'texte sur bouton secondaire': (
        AppColors.onSecondary,
        AppColors.secondary,
        7,
      ),
      'texte sur conteneur principal': (
        AppColors.onPrimaryContainer,
        AppColors.primaryContainer,
        7,
      ),
      'texte sur conteneur secondaire': (
        AppColors.onSecondaryContainer,
        AppColors.secondaryContainer,
        7,
      ),
      'erreur sur fond': (AppColors.error, AppColors.surface, 4.5),
      'texte sur erreur': (AppColors.onError, AppColors.error, 4.5),
      'texte sur conteneur d erreur': (
        AppColors.onErrorContainer,
        AppColors.errorContainer,
        7,
      ),
      'succes sur fond': (AppColors.success, AppColors.surface, 7),
      'succes sur son conteneur (barre de synchro)': (
        AppColors.success,
        AppColors.successContainer,
        7,
      ),
      'avertissement sur son conteneur (barre de synchro)': (
        AppColors.warning,
        AppColors.warningContainer,
        7,
      ),
      'avertissement sur fond': (AppColors.warning, AppColors.surface, 7),
      'texte sur fond gris des listes': (
        AppColors.onSurface,
        AppColors.surfaceContainer,
        7,
      ),
      // Contour des champs : composant d'interface, seuil WCAG 3:1.
      'contour des champs': (AppColors.outline, AppColors.surface, 3),
    };

    pairs.forEach((name, spec) {
      test('$name >= ${spec.$3}:1', () {
        expect(contrastRatio(spec.$1, spec.$2), greaterThanOrEqualTo(spec.$3));
      });
    });
  });

  group('Ergonomie terrain', () {
    final theme = AppTheme.light();

    test('aucun style de texte sous 16 sp', () {
      final text = theme.textTheme;
      final styles = <String, TextStyle?>{
        'displaySmall': text.displaySmall,
        'headlineMedium': text.headlineMedium,
        'headlineSmall': text.headlineSmall,
        'titleLarge': text.titleLarge,
        'titleMedium': text.titleMedium,
        'titleSmall': text.titleSmall,
        'bodyLarge': text.bodyLarge,
        'bodyMedium': text.bodyMedium,
        'bodySmall': text.bodySmall,
        'labelLarge': text.labelLarge,
        'labelMedium': text.labelMedium,
        'labelSmall': text.labelSmall,
      };
      styles.forEach((name, style) {
        expect(style, isNotNull, reason: name);
        expect(
          style!.fontSize,
          greaterThanOrEqualTo(AppSizes.minBodyText),
          reason: name,
        );
        expect(style.fontFamily, AppTheme.fontFamily, reason: name);
      });
    });

    test('valeurs cles a 20 sp minimum', () {
      final extension = theme.extension<TerrainStyles>();

      expect(extension, isNotNull);
      expect(
        extension!.keyValue.fontSize,
        greaterThanOrEqualTo(AppSizes.keyValueText),
      );
    });

    test('boutons principaux 56 dp, autres boutons 48 dp', () {
      Size? minSize(ButtonStyle? style) =>
          style?.minimumSize?.resolve(<WidgetState>{});

      for (final style in [
        theme.filledButtonTheme.style,
        theme.elevatedButtonTheme.style,
        theme.outlinedButtonTheme.style,
        theme.segmentedButtonTheme.style,
      ]) {
        expect(minSize(style)!.height, AppSizes.primaryButtonHeight);
      }
      for (final style in [
        theme.textButtonTheme.style,
        theme.iconButtonTheme.style,
      ]) {
        expect(minSize(style)!.height, greaterThanOrEqualTo(48));
        expect(minSize(style)!.width, greaterThanOrEqualTo(48));
      }
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
    });

    test('theme clair unique, Material 3', () {
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
    });
  });
}
