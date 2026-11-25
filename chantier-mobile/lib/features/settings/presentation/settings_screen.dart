import 'dart:async';

import 'package:chantier_mobile/core/config/app_version.dart';
import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/features/auth/domain/auth_repository.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/settings/presentation/language_selector.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reglages : langue en 2 gestes (CA-014.1), compte, version, deconnexion.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.authRepository,
    required this.onLogout,
    super.key,
  });

  final AuthRepository authRepository;

  /// Ouvre la confirmation de deconnexion (en deux temps si des saisies sont en attente).
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = context.watch<AuthBloc>().state.user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          children: [
            LanguageSelector(
              // Langue du compte : memorisee cote serveur quand le reseau le permet.
              onChanged: (code) =>
                  unawaited(authRepository.updateLanguage(code)),
            ),
            const SizedBox(height: 32),
            if (user != null) ...[
              Text(l10n.settingsAccount, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person),
                title: Text(Formatters.isolateName(user.fullName)),
                subtitle: Text(roleLabel(l10n, user.role)),
                trailing: LtrText(user.userName),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              l10n.settingsVersion(appVersion),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: Text(l10n.logoutTitle),
            ),
          ],
        ),
      ),
    );
  }
}
