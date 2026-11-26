import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/l10n/quantity_format.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/terrain_styles.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_listing.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_widgets.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Etat d'une livraison : annulee / enregistree, « a confirmer », en attente d'envoi, « a verifier »,
/// « Non rattachee », « BL manquant », reserve. Texte **et** icone, jamais la couleur seule.
class DeliveryStatusLine extends StatelessWidget {
  const DeliveryStatusLine({required this.view, super.key});

  final DeliveryView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final row = view.row;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        StateBadge(
          icon: row.isCancelled ? Icons.cancel : Icons.local_shipping,
          text: deliveryStatusLabel(l10n, row.status),
          color: row.isCancelled ? AppColors.error : AppColors.success,
        ),
        if (view.isProvisional)
          StateBadge(icon: Icons.schedule, text: l10n.materialToConfirm),
        if (view.isNotYetSent || view.hasPendingChanges)
          StateBadge(icon: Icons.cloud_upload, text: l10n.requestPendingSend),
        if (view.needsCheck)
          StateBadge(
            icon: Icons.error,
            text: l10n.requestNeedsCheck,
            color: AppColors.error,
          ),
        if (row.isUnattached)
          StateBadge(
            icon: Icons.link_off,
            text: l10n.deliveryUnattachedBadge,
            color: AppColors.warning,
          ),
        if (view.isNoteMissing && !row.isCancelled)
          StateBadge(
            icon: Icons.receipt_long,
            text: l10n.deliveryNoteMissingBadge,
            color: AppColors.warning,
          ),
        if (row.conformity == 'WithReserve')
          StateBadge(
            icon: Icons.report,
            text: conformityLabel(l10n, row.conformity),
            color: AppColors.warning,
          ),
      ],
    );
  }
}

/// Une livraison dans une liste : numero (ou « Numero en attente »), materiau, quantite **avec
/// unite** (et son equivalent dans la demande), date, fournisseur, etat.
class DeliveryTile extends StatelessWidget {
  const DeliveryTile({required this.view, required this.onTap, super.key});

  final DeliveryView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final row = view.row;
    final quantity = row.quantity;
    final inRequest = row.quantityInRequest;
    final supplier = deliverySupplierName(view);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row.number == null
                  ? Text(
                      l10n.materialNumberPending,
                      style: theme.textTheme.titleSmall,
                    )
                  : LtrText(row.number!, style: context.keyValueStyle),
              const SizedBox(height: 4),
              Text(
                Formatters.isolateName(deliveryProductName(view, languageCode)),
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
              if (inRequest != null &&
                  quantity != null &&
                  quantity != inRequest)
                Text(
                  Formatters.isolateLtr(
                    '${formatQuantity(l10n, quantity)} = '
                    '${formatQuantity(l10n, inRequest)}',
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
              if (supplier != null)
                Text(
                  Formatters.isolateName(supplier),
                  style: theme.textTheme.bodyLarge,
                ),
              Text(
                Formatters.isolateLtr(Formatters.date(row.deliveryDate)),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              DeliveryStatusLine(view: view),
            ],
          ),
        ),
      ),
    );
  }
}
