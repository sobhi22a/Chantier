import 'dart:async';

import 'package:chantier_mobile/core/l10n/locale_cubit.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Choix de la langue en un geste (CA-014.1) : francais / arabe.
/// Reutilise par l'ecran de connexion (CA-001.8) et les reglages.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({this.onChanged, super.key});

  /// Appele apres le changement (par exemple pour memoriser la langue du compte).
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = context.watch<LocaleCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.languageLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: LocaleCubit.french,
              label: Text(l10n.languageFrench),
            ),
            ButtonSegment(
              value: LocaleCubit.arabic,
              label: Text(l10n.languageArabic),
            ),
          ],
          selected: {locale.languageCode},
          onSelectionChanged: (selection) {
            final code = selection.first;
            unawaited(context.read<LocaleCubit>().setLanguage(code));
            onChanged?.call(code);
          },
        ),
      ],
    );
  }
}
