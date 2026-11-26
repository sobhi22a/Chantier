import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';

/// Quantite **avec son unite** (« 300 sac », « 15 T », « 2,5 kg ») : jamais un nombre seul
/// (CA-MAT-002.10). Chiffres 0-9, virgule decimale, espace pour les milliers, comme partout
/// (`Formatters`). En interface arabe, a placer dans un `LtrText` ou a isoler avec
/// `Formatters.isolateLtr` quand l'unite est latine.
String formatQuantity(AppLocalizations l10n, Quantity quantity) =>
    '${Formatters.decimal(quantity.value.toString())} '
    '${unitLabel(l10n, quantity.unit.code)}';

/// Quantite prete a afficher dans un `Text` (liste, detail) : le nombre est isole de gauche a
/// droite (`300`), l'unite suit le sens de la langue (« 300 كيس » en arabe, « 300 sac » en
/// francais). Jamais un nombre sans unite.
String quantityDisplay(AppLocalizations l10n, Quantity quantity) =>
    '${Formatters.isolateLtr(Formatters.decimal(quantity.value.toString()))} '
    '${unitLabel(l10n, quantity.unit.code)}';
