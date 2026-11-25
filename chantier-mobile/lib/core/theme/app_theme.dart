import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/theme/terrain_styles.dart';
import 'package:flutter/material.dart';

/// Theme « terrain » : gros boutons, fort contraste, texte >= 16 sp.
/// Un seul theme clair : l'usage principal est en plein soleil.
abstract final class AppTheme {
  /// Police embarquee dans les assets (`pubspec.yaml`) : elle couvre le latin et l'arabe.
  static const String fontFamily = 'Cairo';

  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    surfaceContainerHighest: AppColors.surfaceContainer,
    surfaceContainerLow: AppColors.surfaceContainer,
    outline: AppColors.outline,
    outlineVariant: AppColors.outline,
  );

  static TextStyle _style(double size, {FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: 1.4,
        color: AppColors.onSurface,
      );

  /// Echelle typographique : aucun style sous 16 sp.
  static TextTheme get textTheme => TextTheme(
    displaySmall: _style(32, weight: FontWeight.w700),
    headlineMedium: _style(28, weight: FontWeight.w700),
    headlineSmall: _style(24, weight: FontWeight.w700),
    titleLarge: _style(22, weight: FontWeight.w700),
    titleMedium: _style(AppSizes.keyValueText, weight: FontWeight.w700),
    titleSmall: _style(18, weight: FontWeight.w700),
    bodyLarge: _style(18),
    bodyMedium: _style(AppSizes.minBodyText),
    bodySmall: _style(AppSizes.minBodyText),
    labelLarge: _style(18, weight: FontWeight.w700),
    labelMedium: _style(AppSizes.minBodyText, weight: FontWeight.w700),
    labelSmall: _style(AppSizes.minBodyText, weight: FontWeight.w700),
  );

  static ThemeData light() {
    final text = textTheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
    );
    const primaryButtonSize = Size(88, AppSizes.primaryButtonHeight);
    const smallButtonSize = Size(AppSizes.minTapTarget, AppSizes.minTapTarget);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 24);
    const outlineSide = BorderSide(
      color: AppColors.primary,
      width: AppSizes.borderWidth,
    );

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      borderSide: BorderSide(color: color, width: width),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: AppColors.surface,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: [TerrainStyles(keyValue: text.titleMedium!)],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        toolbarHeight: 64,
        titleTextStyle: text.titleLarge!.copyWith(color: AppColors.onPrimary),
        iconTheme: const IconThemeData(color: AppColors.onPrimary, size: 28),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: primaryButtonSize,
          padding: buttonPadding,
          textStyle: text.labelLarge,
          shape: shape,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: primaryButtonSize,
          padding: buttonPadding,
          textStyle: text.labelLarge,
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: primaryButtonSize,
          padding: buttonPadding,
          textStyle: text.labelLarge,
          shape: shape,
          side: outlineSide,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: smallButtonSize,
          padding: buttonPadding,
          textStyle: text.labelLarge,
          shape: shape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: smallButtonSize, iconSize: 28),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: primaryButtonSize,
          textStyle: text.labelLarge,
          // SegmentedButton calcule sa hauteur a partir de la taille de police et du
          // remplissage vertical (et ignore minimumSize) : 18 sp + 2 x 19 = 56 dp.
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: (AppSizes.primaryButtonHeight - 18) / 2,
          ),
          side: outlineSide,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(16),
        labelStyle: text.bodyLarge!.copyWith(color: AppColors.onSurfaceVariant),
        hintStyle: text.bodyLarge!.copyWith(color: AppColors.onSurfaceVariant),
        errorStyle: text.bodyMedium!.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w700,
        ),
        border: border(AppColors.outline, AppSizes.borderWidth),
        enabledBorder: border(AppColors.outline, AppSizes.borderWidth),
        focusedBorder: border(AppColors.primary, 3),
        errorBorder: border(AppColors.error, AppSizes.borderWidth),
        focusedErrorBorder: border(AppColors.error, 3),
      ),
      listTileTheme: ListTileThemeData(
        minTileHeight: 56,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodyMedium!.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          side: const BorderSide(color: AppColors.outline, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onSurface,
        contentTextStyle: text.bodyLarge!.copyWith(color: AppColors.surface),
        actionTextColor: AppColors.primaryContainer,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
      ),
    );
  }
}
