import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Ecran de demarrage pendant la restauration de la session (lecture locale : quelques
/// instants, aucun reseau, CA-012.1).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appName, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
