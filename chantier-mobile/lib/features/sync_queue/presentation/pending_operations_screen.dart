import 'dart:async';

import 'package:chantier_mobile/core/l10n/error_messages.dart';
import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// « Envois en attente » (CA-013.3, CA-013.7) : la liste des saisies du compte connecte (type,
/// libelle, date et heure de saisie, etat), « Synchroniser maintenant », et pour chaque saisie
/// refusee ou en conflit : **Corriger** ou **Abandonner** (avec confirmation). Rien n'est supprime
/// sans decision de l'utilisateur.
class PendingOperationsScreen extends StatelessWidget {
  const PendingOperationsScreen({
    required this.userId,
    required this.outbox,
    required this.onCorrect,
    super.key,
  });

  final String userId;
  final OutboxRepository outbox;

  /// « Corriger » : ouvre le formulaire pre-rempli (remplace la saisie refusee).
  final void Function(OutboxRow row) onCorrect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sync = context.watch<SyncStatusCubit>().state;
    final busy = sync.indicator == SyncIndicator.syncing;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pendingTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<OutboxRow>>(
                stream: outbox.watch(userId),
                builder: (context, snapshot) {
                  final rows = snapshot.data ?? const <OutboxRow>[];
                  if (snapshot.hasData && rows.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.pendingEmpty,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  }
                  // `ListView.builder` : reste fluide avec 200 saisies en attente (CA-013.10).
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    itemCount: rows.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OperationCard(
                        row: rows[index],
                        onCorrect: () => onCorrect(rows[index]),
                        onAbandon: () => _confirmAbandon(context, rows[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  // Un double appui lance une seule synchronisation (execution unique du moteur).
                  onPressed: busy ? null : () => _syncNow(context),
                  icon: busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Icon(Icons.sync),
                  label: Text(l10n.syncNow),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncNow(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await context.read<SyncStatusCubit>().syncNow();
    if (outcome != SyncOutcome.completed &&
        outcome != SyncOutcome.notSignedIn) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pendingSyncFailed)));
    }
  }

  Future<void> _confirmAbandon(BuildContext context, OutboxRow row) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.pendingAbandonTitle),
        content: Text(l10n.pendingAbandonBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.pendingAbandon),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      unawaited(HapticFeedback.mediumImpact());
      await outbox.abandon(row);
    }
  }
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({
    required this.row,
    required this.onCorrect,
    required this.onAbandon,
  });

  final OutboxRow row;
  final VoidCallback onCorrect;
  final VoidCallback onAbandon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final toCheck =
        row.status == OutboxStatus.rejected ||
        row.status == OutboxStatus.conflict;
    final (icon, status, color) = switch (row.status) {
      OutboxStatus.pending => (
        Icons.schedule,
        l10n.pendingStatusPending,
        AppColors.primary,
      ),
      OutboxStatus.sending => (
        Icons.sync,
        l10n.pendingStatusSending,
        AppColors.primary,
      ),
      OutboxStatus.conflict || OutboxStatus.rejected => (
        Icons.error,
        l10n.pendingStatusToCheck,
        AppColors.error,
      ),
    };
    final entity = row.entity == 'zone' ? l10n.pendingEntityZone : row.entity;
    final reason = toCheck
        ? (errorMessageForCode(l10n, row.lastErrorCode) ?? l10n.errorUnknown)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entity, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            // Libelle enregistre a la saisie : bloc et cote isoles de gauche a droite.
            Text(_isolateLabel(row.label), style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              l10n.pendingSavedAt(
                Formatters.isolateLtr(
                  Formatters.dateTime(row.createdAt.toUtc()),
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                // `Expanded` : a 320 dp et police x2, « En attente d'envoi » passe a la ligne.
                Expanded(
                  child: Text(
                    status,
                    style: theme.textTheme.labelLarge?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            if (reason != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.pendingReason(reason),
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (toCheck) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onCorrect,
                      child: Text(l10n.pendingCorrect),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAbandon,
                      child: Text(l10n.pendingAbandon),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// `Zone Bloc 01 · +3,40 m · Classe 07` : les segments separes par « · » gardent leur sens de
  /// lecture gauche-a-droite quand le libelle contient des codes et des cotes.
  static String _isolateLabel(String label) => label
      .split(' · ')
      .map(
        (part) =>
            RegExp(r'[A-Za-z0-9+−±]').hasMatch(part) &&
                !RegExp(r'[؀-ۿ]').hasMatch(part)
            ? Formatters.isolateLtr(part)
            : part,
      )
      .join(' · ');
}
