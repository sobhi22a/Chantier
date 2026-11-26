import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Un evenement de l'historique (qui, quand, ancien -> nouveau statut, motif, champs modifies).
class HistoryTile extends StatelessWidget {
  const HistoryTile({required this.event, super.key});

  final RequestHistoryEvent event;

  String _value(AppLocalizations l10n, String field, String? value) {
    if (value == null || value.isEmpty) return l10n.fieldEmpty;
    return switch (field) {
      'priority' => priorityLabel(l10n, value),
      'quantity' => _quantity(l10n, value),
      _ => value,
    };
  }

  /// `300 sac` (forme canonique du serveur) -> nombre isole + unite traduite.
  String _quantity(AppLocalizations l10n, String value) {
    final parts = value.split(' ');
    if (parts.length != 2) return value;
    return '${Formatters.isolateLtr(Formatters.decimal(parts[0]))} '
        '${unitLabel(l10n, parts[1])}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = event.fromStatus != null && event.toStatus != null
        ? l10n.historyStatusChange(
            requestStatusLabel(l10n, event.fromStatus!),
            requestStatusLabel(l10n, event.toStatus!),
          )
        : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              requestEventLabel(l10n, event.type),
              style: theme.textTheme.titleSmall,
            ),
            if (status != null) Text(status),
            if (event.reasonCode != null)
              Text(
                [
                  reasonLabel(l10n, event.reasonCode!),
                  if ((event.reasonNote ?? '').isNotEmpty) event.reasonNote!,
                ].join(' · '),
              ),
            for (final change in event.changes)
              Text(
                l10n.fieldChange(
                  requestFieldLabel(l10n, change.field),
                  // Parametres dans l'ordre alphabetique du gabarit : champ, nouvelle, ancienne.
                  _value(l10n, change.field, change.newValue),
                  _value(l10n, change.field, change.oldValue),
                ),
              ),
            Text(
              [
                Formatters.isolateLtr(Formatters.dateTime(event.occurredAt)),
                if (event.actorName != null)
                  l10n.historyBy(Formatters.isolateName(event.actorName!)),
              ].join(' · '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
