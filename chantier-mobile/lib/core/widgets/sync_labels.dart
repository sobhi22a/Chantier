import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Derniere synchronisation reussie : `aujourd'hui 10:15` ou `24/11/2026 10:15` (CA-013.8),
/// toujours complete, jamais une date partielle. Heure d'Alger.
String whenLabel(AppLocalizations l10n, DateTime utc, DateTime now) {
  final local = utc.toUtc().add(Formatters.algiersOffset);
  final today = now.toUtc().add(Formatters.algiersOffset);
  final sameDay =
      local.year == today.year &&
      local.month == today.month &&
      local.day == today.day;
  if (!sameDay) return Formatters.isolateLtr(Formatters.dateTime(utc));
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return l10n.syncWhenToday(Formatters.isolateLtr('$hh:$mm'));
}

/// Texte de l'indicateur : compteurs exacts (CT-24).
String syncIndicatorText(
  AppLocalizations l10n,
  SyncStatusSnapshot status,
  DateTime now,
) {
  final last = status.lastSuccessAt;
  return switch (status.indicator) {
    SyncIndicator.upToDate =>
      last == null
          ? l10n.syncUpToDate
          : l10n.syncUpToDateAt(whenLabel(l10n, last, now)),
    SyncIndicator.offline =>
      status.toSend > 0
          ? '${l10n.syncOffline} · ${l10n.syncPending(status.toSend)}'
          : l10n.syncOffline,
    SyncIndicator.pending => l10n.syncPending(status.toSend),
    SyncIndicator.syncing => l10n.syncSyncing,
    SyncIndicator.problem =>
      status.toCheck > 0
          ? l10n.syncProblem(status.toCheck)
          : l10n.syncProblemServer,
    SyncIndicator.authRequired => l10n.syncAuthRequired,
  };
}

/// Une icone **et** un texte : l'etat n'est jamais porte par la couleur seule (CA-013.1).
IconData syncIndicatorIcon(SyncIndicator indicator) => switch (indicator) {
  SyncIndicator.upToDate => Icons.check_circle,
  SyncIndicator.offline => Icons.cloud_off,
  SyncIndicator.pending => Icons.upload,
  SyncIndicator.syncing => Icons.sync,
  SyncIndicator.problem => Icons.error,
  SyncIndicator.authRequired => Icons.lock,
};

/// Couleurs de fond et de texte (contraste >= 7:1, verifie par test).
({Color background, Color foreground}) syncIndicatorColors(
  SyncIndicator indicator,
) => switch (indicator) {
  SyncIndicator.upToDate => (
    background: AppColors.successContainer,
    foreground: AppColors.success,
  ),
  SyncIndicator.offline => (
    background: AppColors.surfaceContainer,
    foreground: AppColors.onSurface,
  ),
  SyncIndicator.pending || SyncIndicator.syncing => (
    background: AppColors.primaryContainer,
    foreground: AppColors.onPrimaryContainer,
  ),
  SyncIndicator.problem => (
    background: AppColors.errorContainer,
    foreground: AppColors.onErrorContainer,
  ),
  SyncIndicator.authRequired => (
    background: AppColors.warningContainer,
    foreground: AppColors.warning,
  ),
};
