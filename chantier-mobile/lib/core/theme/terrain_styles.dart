import 'package:flutter/material.dart';

/// Styles propres au terrain, absents de [ThemeData] : valeurs cles (code chantier,
/// cote, quantite) a 20 sp minimum. A utiliser avec [TerrainThemeContext.keyValueStyle].
@immutable
class TerrainStyles extends ThemeExtension<TerrainStyles> {
  const TerrainStyles({required this.keyValue});

  final TextStyle keyValue;

  @override
  TerrainStyles copyWith({TextStyle? keyValue}) =>
      TerrainStyles(keyValue: keyValue ?? this.keyValue);

  @override
  TerrainStyles lerp(ThemeExtension<TerrainStyles>? other, double t) {
    if (other is! TerrainStyles) return this;
    return TerrainStyles(
      keyValue: TextStyle.lerp(keyValue, other.keyValue, t) ?? keyValue,
    );
  }
}

extension TerrainThemeContext on BuildContext {
  /// Style des valeurs cles (>= 20 sp, gras).
  TextStyle get keyValueStyle =>
      Theme.of(this).extension<TerrainStyles>()!.keyValue;
}
