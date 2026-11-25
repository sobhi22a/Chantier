import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/widgets/sync_labels.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Barre d'etat de synchronisation, **en haut de tous les ecrans** (CA-013.1) : icone et texte,
/// compteurs exacts. Un appui ouvre « Envois en attente » ([onTap]).
class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({required this.onTap, this.now, super.key});

  final VoidCallback onTap;

  /// Horloge injectable pour les tests.
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = context.watch<SyncStatusCubit>().state;
    final colors = syncIndicatorColors(status.indicator);
    final text = syncIndicatorText(l10n, status, (now ?? DateTime.now)());

    return Semantics(
      button: true,
      label: '$text. ${l10n.syncDetailsHint}',
      excludeSemantics: true,
      child: Material(
        color: colors.background,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  status.indicator == SyncIndicator.syncing
                      ? SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: colors.foreground,
                          ),
                        )
                      : Icon(
                          syncIndicatorIcon(status.indicator),
                          color: colors.foreground,
                          size: 24,
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colors.foreground,
                    textDirection: Directionality.of(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
