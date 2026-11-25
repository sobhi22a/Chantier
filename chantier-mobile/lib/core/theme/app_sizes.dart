/// Contraintes ergonomiques terrain (ADR 0008, H-16, CA-014.8) : gants, soleil, une main.
abstract final class AppSizes {
  /// Cible tactile minimale de tout element interactif (dp).
  static const double minTapTarget = 48;

  /// Hauteur des boutons principaux (dp).
  static const double primaryButtonHeight = 56;

  /// Texte courant minimal (sp).
  static const double minBodyText = 16;

  /// Valeurs cles (code chantier, cote, quantite) (sp).
  static const double keyValueText = 20;

  static const double radius = 12;
  static const double borderWidth = 2;
  static const double screenPadding = 16;
}
