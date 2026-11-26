import 'dart:async';

import 'package:chantier_mobile/core/l10n/error_messages.dart';
import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/delivery_photos_dao.dart';
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
    this.pendingFiles,
    this.onAbandonFile,
    super.key,
  });

  final String userId;
  final OutboxRepository outbox;

  /// « Corriger » : ouvre le formulaire pre-rempli (remplace la saisie refusee).
  final void Function(OutboxRow row) onCorrect;

  /// Fichiers de photos en attente d'envoi (« Photo en attente d'envoi (2) ») : la photo n'est
  /// jamais perdue si l'envoi echoue, elle part des que le reseau le permet (CA-MAT-007.2).
  final Stream<List<PendingPhotoFileRow>>? pendingFiles;

  /// « Abandonner » un fichier refuse par le serveur (apres confirmation).
  final Future<void> Function(PendingPhotoFileRow file)? onAbandonFile;

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
            if (pendingFiles != null)
              StreamBuilder<List<PendingPhotoFileRow>>(
                stream: pendingFiles,
                builder: (context, snapshot) => _PendingPhotos(
                  files: snapshot.data ?? const [],
                  onAbandon: onAbandonFile,
                ),
              ),
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
    // Une demande, une livraison ou une photo se verifie sur son ecran « A verifier ».
    final isRequest = row.entity != 'zone';
    final entity = switch (row.entity) {
      'zone' => l10n.pendingEntityZone,
      'request' => l10n.pendingEntityRequest,
      'delivery' => l10n.pendingEntityDelivery,
      'photo' => l10n.pendingEntityPhoto,
      _ => row.entity,
    };
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
                      // Une demande se verifie sur son ecran « A verifier » (deux versions).
                      child: Text(
                        isRequest ? l10n.pendingView : l10n.pendingCorrect,
                      ),
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

/// « Photo en attente d'envoi (2) » et les fichiers refuses par le serveur (a abandonner ou a
/// laisser : le fichier est garde tant que l'utilisateur n'a pas decide).
class _PendingPhotos extends StatelessWidget {
  const _PendingPhotos({required this.files, this.onAbandon});

  final List<PendingPhotoFileRow> files;
  final Future<void> Function(PendingPhotoFileRow file)? onAbandon;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final refused = [
      for (final file in files)
        if (PhotoFileErrors.isPermanent(file.lastErrorCode)) file,
    ];
    final waiting = files.length - refused.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        AppSizes.screenPadding,
        AppSizes.screenPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (waiting > 0)
            Row(
              children: [
                const Icon(Icons.cloud_upload, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.photoPendingSendCount(waiting.toString()),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          for (final file in refused)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pendingPhotosRefused,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      errorMessageForCode(l10n, file.lastErrorCode) ??
                          l10n.errorUnknown,
                    ),
                    if (onAbandon != null)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => onAbandon!(file),
                          child: Text(l10n.photoAbandon),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
