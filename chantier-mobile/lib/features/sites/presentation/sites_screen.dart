import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/theme/terrain_styles.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/sites/domain/site_format.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_cubit.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// « Mes chantiers » (US-SOCLE-006) : liste lue **uniquement** dans la base locale, disponible
/// hors ligne (CA-006.5, CA-012.1). Tirer vers le bas lance une synchronisation.
class SitesScreen extends StatelessWidget {
  const SitesScreen({
    required this.onOpenSite,
    required this.onOpenSettings,
    super.key,
  });

  /// Ouvre la fiche (le chantier devient courant avant, CA-010.1).
  final void Function(SiteRow site) onOpenSite;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sitesTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings),
            onPressed: onOpenSettings,
          ),
        ],
      ),
      body: SitesView(onOpenSite: onOpenSite),
    );
  }
}

/// Corps de l'ecran (separe pour les tests de widgets).
class SitesView extends StatelessWidget {
  const SitesView({required this.onOpenSite, super.key});

  final void Function(SiteRow site) onOpenSite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sites = context.watch<SitesCubit>().state;
    final sync = context.watch<SyncStatusCubit>().state;
    final current = context.watch<CurrentSiteCubit>().state;
    final languageCode = Localizations.localeOf(context).languageCode;

    // Tirer pour synchroniser : un seul appui = une seule synchronisation.
    Future<void> refresh() => context.read<SyncStatusCubit>().syncNow();

    if (!sites.loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final preparing = !sync.initialSyncDone && sites.totalCount == 0;
    final children = <Widget>[
      if (current.removed)
        _Notice(
          icon: Icons.link_off,
          text: l10n.sitesCurrentRemoved,
          onClose: () => context.read<CurrentSiteCubit>().acknowledgeRemoved(),
        )
      else if (current.needsChoice && current.siteCount > 1)
        _Notice(icon: Icons.touch_app, text: l10n.sitesChooseRequired),
      if (!preparing &&
          sync.indicator == SyncIndicator.offline &&
          sync.lastSuccessAt != null)
        _DataFromLine(last: sync.lastSuccessAt!),
      if (preparing)
        _Preparing(sync: sync, onRetry: refresh)
      else ...[
        if (sites.showSearch || sites.query.isNotEmpty)
          _SearchField(initial: sites.query),
        _ArchivedSwitch(value: sites.showArchived),
        if (sites.sites.isEmpty)
          _EmptyState(
            text: sites.query.isNotEmpty || sites.totalCount > 0
                ? l10n.sitesNoResult
                : l10n.sitesEmpty,
            showRefresh: sites.totalCount == 0,
            onRefresh: refresh,
          )
        else
          for (final site in _currentFirst(sites.sites, current.siteId))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SiteCard(
                site: site,
                languageCode: languageCode,
                isCurrent: site.id == current.siteId,
                onTap: () => onOpenSite(site),
              ),
            ),
      ],
    ];

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: children,
      ),
    );
  }

  /// Le chantier courant en premier (CA-006.7).
  static List<SiteRow> _currentFirst(List<SiteRow> sites, String? currentId) =>
      [
        for (final site in sites)
          if (site.id == currentId) site,
        for (final site in sites)
          if (site.id != currentId) site,
      ];
}

class SiteCard extends StatelessWidget {
  const SiteCard({
    required this.site,
    required this.languageCode,
    required this.isCurrent,
    required this.onTap,
    super.key,
  });

  final SiteRow site;
  final String languageCode;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: isCurrent
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              side: const BorderSide(color: AppColors.primary, width: 3),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LtrText(site.code, style: context.keyValueStyle),
                    ),
                    if (isCurrent)
                      _Badge(
                        icon: Icons.push_pin,
                        text: l10n.sitesCurrentBadge,
                        color: AppColors.primary,
                      ),
                    if (site.archivedAt != null)
                      _Badge(
                        icon: Icons.inventory_2,
                        text: l10n.sitesArchivedBadge,
                        color: AppColors.warning,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  siteDisplayName(site, languageCode),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  '${site.commune} · ${site.wilaya}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      initialValue: initial,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: AppLocalizations.of(context).sitesSearchHint,
      ),
      onChanged: context.read<SitesCubit>().setQuery,
    ),
  );
}

class _ArchivedSwitch extends StatelessWidget {
  const _ArchivedSwitch({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(AppLocalizations.of(context).sitesShowArchived),
    value: value,
    onChanged: (v) => context.read<SitesCubit>().setShowArchived(value: v),
  );
}

class _Preparing extends StatelessWidget {
  const _Preparing({required this.sync, required this.onRetry});

  final SyncStatusSnapshot sync;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final offline =
        sync.indicator == SyncIndicator.offline ||
        sync.indicator == SyncIndicator.problem ||
        sync.indicator == SyncIndicator.authRequired;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          if (offline) ...[
            const Icon(Icons.cloud_off, size: 48, color: AppColors.warning),
            const SizedBox(height: 16),
            Text(
              l10n.sitesFirstSyncOffline,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.actionRetry)),
          ] else ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(l10n.sitesPreparing, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              l10n.sitesPreparingCount(sync.itemsReceived),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.text,
    required this.showRefresh,
    required this.onRefresh,
  });

  final String text;
  final bool showRefresh;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (showRefresh) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRefresh,
            child: Text(AppLocalizations.of(context).actionRefresh),
          ),
        ],
      ],
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, this.onClose});

  final IconData icon;
  final String text;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: AppColors.warning),
            ),
        ],
      ),
    ),
  );
}

/// « Donnees du JJ/MM/AAAA HH:MM » quand on lit sans reseau (CA-006.5).
class _DataFromLine extends StatelessWidget {
  const _DataFromLine({required this.last});

  final DateTime last;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      AppLocalizations.of(
        context,
      ).sitesDataFrom(Formatters.isolateLtr(Formatters.dateTime(last))),
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
    ),
  );
}
