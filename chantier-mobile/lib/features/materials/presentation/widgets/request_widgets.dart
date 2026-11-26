import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/l10n/quantity_format.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/terrain_styles.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/domain/algeria_date.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/zones/domain/zone_format.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Petite etiquette icone + texte : l'etat n'est **jamais** indique par la couleur seule.
class StateBadge extends StatelessWidget {
  const StateBadge({
    required this.icon,
    required this.text,
    this.color = AppColors.primary,
    super.key,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 4),
      // `Flexible` : a 320 dp et police x2, le texte passe a la ligne.
      Flexible(
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
        ),
      ),
    ],
  );
}

/// Statut d'une demande : texte traduit + icone ; « A confirmer » quand il vient d'une saisie en
/// attente (le serveur le remplacera).
class RequestStatusLine extends StatelessWidget {
  const RequestStatusLine({required this.view, super.key});

  final RequestView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final row = view.row;
    final status = row.statusValue;
    final (icon, color) = switch (status) {
      RequestStatus.requested => (Icons.hourglass_top, AppColors.warning),
      RequestStatus.validated => (Icons.check_circle, AppColors.success),
      RequestStatus.rejected ||
      RequestStatus.cancelled => (Icons.cancel, AppColors.error),
      RequestStatus.received => (Icons.inventory, AppColors.success),
      _ => (Icons.local_shipping, AppColors.primary),
    };
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        StateBadge(
          icon: icon,
          text: requestStatusLabel(l10n, row.status),
          color: color,
        ),
        if (view.isStatusProvisional)
          StateBadge(
            icon: Icons.schedule,
            text: l10n.materialToConfirm,
            color: AppColors.primary,
          ),
        if (view.isNotYetSent || view.hasPendingChanges)
          StateBadge(
            icon: Icons.cloud_upload,
            text: l10n.requestPendingSend,
            color: AppColors.primary,
          ),
        if (view.needsCheck)
          StateBadge(
            icon: Icons.error,
            text: l10n.requestNeedsCheck,
            color: AppColors.error,
          ),
      ],
    );
  }
}

/// Une demande dans une liste : numero (ou « Numero en attente »), materiau, quantite **avec
/// unite**, date de besoin, retard, statut.
class RequestTile extends StatelessWidget {
  const RequestTile({
    required this.view,
    required this.zones,
    required this.today,
    required this.onTap,
    this.footer,
    super.key,
  });

  final RequestView view;
  final Map<String, ZoneRow> zones;

  /// Jour d'Algerie courant (pour le retard).
  final DateTime today;
  final VoidCallback onTap;

  /// Boutons d'action sous la ligne (ecran « A valider »).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final row = view.row;
    final quantity = row.quantity;
    final zone = row.zoneId == null ? null : zones[row.zoneId];
    final overdue = AlgeriaDate.requestOverdueDays(
      status: row.statusValue,
      neededBy: row.neededBy,
      today: today,
    );
    final priority = row.priorityValue;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: row.hasNumber
                            ? LtrText(row.number!, style: context.keyValueStyle)
                            : Text(
                                l10n.materialNumberPending,
                                style: theme.textTheme.titleSmall,
                              ),
                      ),
                      if (priority != null &&
                          priority != RequestPriority.normal)
                        StateBadge(
                          icon: priority == RequestPriority.blocking
                              ? Icons.block
                              : Icons.priority_high,
                          text: priorityLabel(l10n, row.priority),
                          color: AppColors.error,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.isolateName(
                      requestProductName(row, languageCode),
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  // Jamais une quantite sans unite.
                  Text(
                    quantity == null
                        ? '${row.quantityValue} ${row.quantityUnit}'
                        : quantityDisplay(l10n, quantity),
                    style: context.keyValueStyle,
                  ),
                  if (zone != null) Text(zoneLabelForDisplay(l10n, zone)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.requestNeededBy(
                      Formatters.isolateLtr(Formatters.date(row.neededBy)),
                    ),
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (overdue > 0)
                    StateBadge(
                      icon: Icons.warning_amber,
                      text: l10n.materialOverdueDays(overdue.toString()),
                      color: AppColors.error,
                    ),
                  const SizedBox(height: 8),
                  RequestStatusLine(view: view),
                ],
              ),
            ),
          ),
          ?footer,
        ],
      ),
    );
  }
}
