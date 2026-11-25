import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bandeau non bloquant « Donnees du JJ/MM/AAAA HH:MM » au-dela de 24 h sans synchronisation
/// reussie (CA-012.5, H-12). Rien ne bloque la saisie.
class StaleDataBanner extends StatelessWidget {
  const StaleDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<SyncStatusCubit>().state;
    final last = status.lastSuccessAt;
    if (!status.isStale || last == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.warningContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.history, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                // La date reste lisible de gauche a droite en arabe : isolee dans le message.
                l10n.syncStaleBanner(
                  Formatters.isolateLtr(Formatters.dateTime(last)),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
