import 'dart:async';

import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Deconnexion (CA-002.3, CT-23).
///
/// * Rien en attente : une simple confirmation.
/// * « N saisies ne sont pas encore envoyees » : « Envoyer d'abord » et « Rester connecte » en gros
///   et en premier ; « Se deconnecter quand meme » petit, en dernier, avec une **seconde
///   confirmation**. Les saisies restent sur le telephone, pour leur auteur seul.
class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  bool _sending = false;
  bool _sendFailed = false;

  Future<void> _sendFirst() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _sendFailed = false;
    });
    final outcome = await context.read<SyncStatusCubit>().syncNow();
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sendFailed = outcome != SyncOutcome.completed;
    });
  }

  Future<void> _logoutAnyway() async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<AuthBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutAnywayTitle),
        content: Text(l10n.logoutAnywayBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.logoutStay),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.logoutConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      unawaited(HapticFeedback.mediumImpact());
      bloc.add(const AuthLogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = context.watch<SyncStatusCubit>().state;
    final pending = status.toSend + status.toCheck;
    final submitting = context.watch<AuthBloc>().state.isSubmitting;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.logoutTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (pending == 0) ...[
                Text(l10n.logoutConfirmBody, style: theme.textTheme.bodyLarge),
                const Spacer(),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () => context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        ),
                  child: Text(l10n.logoutConfirm),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(l10n.logoutStay),
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: AppColors.warning,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.logoutPendingTitle(pending),
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                if (_sendFailed) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.logoutSendFailed,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const Spacer(),
                FilledButton.icon(
                  onPressed: _sending || submitting ? null : _sendFirst,
                  icon: _sending
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Icon(Icons.upload),
                  label: Text(
                    _sending ? l10n.logoutSending : l10n.logoutSendFirst,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(l10n.logoutStay),
                ),
                const SizedBox(height: 24),
                // Petit et en dernier : l'action la plus risquee est la moins accessible.
                Align(
                  child: TextButton(
                    onPressed: _sending || submitting ? null : _logoutAnyway,
                    child: Text(
                      l10n.logoutAnyway,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
