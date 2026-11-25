import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/theme/terrain_styles.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/features/sites/domain/site_format.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Chantier courant, visible en haut de chaque ecran : code et nom court (CA-010.1). Toucher
/// l'en-tete puis un chantier : 2 gestes, meme sans reseau (CA-010.3).
class CurrentSiteHeader extends StatelessWidget {
  const CurrentSiteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentSiteCubit>().state;
    if (!state.loaded || state.siteCount == 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final site = state.site;
    final canChange = state.siteCount > 1;

    final content = Row(
      children: [
        const Icon(Icons.apartment, color: AppColors.onPrimaryContainer),
        const SizedBox(width: 12),
        Expanded(
          child: site == null
              ? Text(
                  l10n.sitesChooseTitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onPrimaryContainer,
                  ),
                )
              : Row(
                  children: [
                    LtrText(
                      site.code,
                      style: context.keyValueStyle.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        siteDisplayName(site, languageCode),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        if (canChange)
          const Icon(Icons.unfold_more, color: AppColors.onPrimaryContainer),
      ],
    );

    return Material(
      color: AppColors.primaryContainer,
      child: InkWell(
        onTap: canChange ? () => showSiteChooser(context) : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Liste des chantiers affectes : un appui choisit le chantier courant et ferme la liste.
Future<void> showSiteChooser(BuildContext context) {
  final cubit = context.read<CurrentSiteCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) =>
        BlocProvider.value(value: cubit, child: const _SiteChooserSheet()),
  );
}

class _SiteChooserSheet extends StatelessWidget {
  const _SiteChooserSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<CurrentSiteCubit>().state;
    final languageCode = Localizations.localeOf(context).languageCode;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.sitesChooseTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final site in state.sites)
                    ListTile(
                      minTileHeight: 64,
                      selected: site.id == state.siteId,
                      leading: Icon(
                        site.id == state.siteId
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: LtrText(site.code, style: context.keyValueStyle),
                      subtitle: Text(siteDisplayName(site, languageCode)),
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        await context.read<CurrentSiteCubit>().select(site.id);
                        navigator.pop();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
