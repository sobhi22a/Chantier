import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/theme/terrain_styles.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_form_rules.dart';
import 'package:chantier_mobile/features/sites/domain/site_format.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_cubit.dart';
import 'package:chantier_mobile/features/zones/domain/zone_format.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Fiche d'un chantier (US-SOCLE-007) : informations, zones groupees par bloc, personnes
/// affectees. Entierement lue dans la base locale : complete hors ligne (CA-007.5).
class SiteDetailScreen extends StatelessWidget {
  const SiteDetailScreen({
    required this.onAddZone,
    this.onOpenRequests,
    this.onNewRequest,
    this.onOpenApprovals,
    this.onOpenToReceive,
    this.onOpenToReception,
    this.onOpenDeliveries,
    super.key,
  });

  /// Ouvre l'ajout de zone (visible seulement avec la permission `Zones.Create`).
  final void Function(SiteRow site) onAddZone;

  /// Actions rapides des demandes de materiaux (US-MAT) : chacune n'apparait **que** si
  /// l'utilisateur en a la permission (jamais grisee).
  final void Function(SiteRow site)? onOpenRequests;
  final void Function(SiteRow site)? onNewRequest;
  final void Function(SiteRow site)? onOpenApprovals;

  /// Livraisons : « A recevoir », « A receptionner », « Livraisons » (chacune seulement avec sa
  /// permission, jamais grisee).
  final void Function(SiteRow site)? onOpenToReceive;
  final void Function(SiteRow site)? onOpenToReception;
  final void Function(SiteRow site)? onOpenDeliveries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<SiteDetailCubit>().state;
    final site = state.site;
    final user = context.watch<AuthBloc>().state.user;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          site == null ? l10n.sitesTitle : siteDisplayName(site, languageCode),
        ),
      ),
      body: !state.loaded
          ? const Center(child: CircularProgressIndicator())
          : site == null
          // Chantier absent du telephone : « introuvable », jamais un detail technique (CA-007.7).
          ? Center(
              child: Text(
                l10n.siteNotFound,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : _lazyBody(
              context,
              state: state,
              site: site,
              languageCode: languageCode,
              canAdd:
                  site.archivedAt == null &&
                  (user?.can(Permissions.zonesCreate) ?? false),
              user: user,
            ),
    );
  }

  bool _canCreateRequest(SiteRow site, AuthUser? user) =>
      onNewRequest != null &&
      site.archivedAt == null &&
      (user?.can(Permissions.requestsCreate) ?? false);

  bool _canViewRequests(AuthUser? user) =>
      onOpenRequests != null && (user?.can(Permissions.requestsView) ?? false);

  bool _canApprove(AuthUser? user) =>
      onOpenApprovals != null &&
      (user?.can(Permissions.requestsApprove) ?? false);

  bool _canToReceive(AuthUser? user) =>
      onOpenToReceive != null && (user?.canRecordDelivery ?? false);

  bool _canToReception(AuthUser? user) =>
      onOpenToReception != null && (user?.canReceiveRequests ?? false);

  bool _canDeliveries(AuthUser? user) =>
      onOpenDeliveries != null &&
      (user?.can(Permissions.deliveriesView) ?? false);

  bool _hasMaterialActions(SiteRow site, AuthUser? user) =>
      _canCreateRequest(site, user) ||
      _canViewRequests(user) ||
      _canApprove(user) ||
      _canToReceive(user) ||
      _canToReception(user) ||
      _canDeliveries(user);

  /// Fiche **paresseuse** (R1-15) : blocs, zones et personnes sont aplatis en une seule liste
  /// d'elements construits a la demande par `ListView.builder`. Une centaine de zones (ecoles,
  /// logements) ne reconstruit que ce qui est visible, meme quand une premiere synchro reecrit la
  /// table par pages de 200.
  Widget _lazyBody(
    BuildContext context, {
    required SiteDetailState state,
    required SiteRow site,
    required String languageCode,
    required bool canAdd,
    required AuthUser? user,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    const gap = SizedBox(height: 24);
    final items = <Widget Function(BuildContext)>[
      (_) => _InfoCard(site: site, languageCode: languageCode),
      (_) => gap,
      if (_hasMaterialActions(site, user))
        (_) => _MaterialActions(
          onNew: _canCreateRequest(site, user)
              ? () => onNewRequest!(site)
              : null,
          onOpen: _canViewRequests(user) ? () => onOpenRequests!(site) : null,
          onApprove: _canApprove(user) ? () => onOpenApprovals!(site) : null,
          onToReceive: _canToReceive(user)
              ? () => onOpenToReceive!(site)
              : null,
          onToReception: _canToReception(user)
              ? () => onOpenToReception!(site)
              : null,
          onDeliveries: _canDeliveries(user)
              ? () => onOpenDeliveries!(site)
              : null,
        ),
      if (_hasMaterialActions(site, user)) (_) => gap,
      (_) => _ZonesHeader(canAdd: canAdd, onAdd: () => onAddZone(site)),
      (_) => const SizedBox(height: 8),
    ];

    if (state.zones.isEmpty) {
      items.add(
        (_) => Text(l10n.siteNoZones, style: theme.textTheme.bodyLarge),
      );
    } else {
      String? currentBlock;
      for (final zone in state.zones) {
        if (zone.block != currentBlock) {
          currentBlock = zone.block;
          final block = zone.block;
          items.add(
            (context) => Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: LtrText(block, style: context.keyValueStyle),
            ),
          );
        }
        items.add((_) => ZoneTile(key: ValueKey(zone.id), zone: zone));
      }
    }

    if (state.members.isNotEmpty) {
      items
        ..add((_) => gap)
        ..add(
          (_) => Text(l10n.siteMembersTitle, style: theme.textTheme.titleLarge),
        )
        ..add((_) => const SizedBox(height: 8));
      for (final member in state.members) {
        items.add((_) => _MemberTile(key: ValueKey(member.id), member: member));
      }
    }
    items
      ..add((_) => gap)
      ..add((_) => _AuditLines(site: site));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index](context),
    );
  }
}

/// Actions rapides des demandes de materiaux : « + Demande » (56 dp), « Demandes », « A valider ».
class _MaterialActions extends StatelessWidget {
  const _MaterialActions({
    this.onNew,
    this.onOpen,
    this.onApprove,
    this.onToReceive,
    this.onToReception,
    this.onDeliveries,
  });

  final VoidCallback? onNew;
  final VoidCallback? onOpen;
  final VoidCallback? onApprove;
  final VoidCallback? onToReceive;
  final VoidCallback? onToReception;
  final VoidCallback? onDeliveries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.requestsTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (onNew != null)
          FilledButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add),
            label: Text(l10n.requestNew),
          ),
        if (onOpen != null) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onOpen,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSizes.primaryButtonHeight),
            ),
            child: Text(l10n.requestsOpen),
          ),
        ],
        if (onApprove != null) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onApprove,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSizes.primaryButtonHeight),
            ),
            child: Text(l10n.approvalsTitle),
          ),
        ],
        for (final (action, label) in [
          (onToReceive, l10n.toReceiveTitle),
          (onToReception, l10n.toReceptionTitle),
          (onDeliveries, l10n.deliveriesTitle),
        ])
          if (action != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: action,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  AppSizes.primaryButtonHeight,
                ),
              ),
              child: Text(label),
            ),
          ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.site, required this.languageCode});

  final SiteRow site;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amount = site.contractAmount;
    final coordinates = coordinatesText(site);
    final end = site.contractualEndDate;
    final ods = site.odsDate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LtrText(site.code, style: context.keyValueStyle),
            if (site.archivedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.sitesArchivedBadge,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: AppColors.warning),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _Line(l10n.siteType, Text(siteTypeLabel(l10n, site.type))),
            _Line(l10n.siteWilaya, Text(site.wilaya)),
            _Line(l10n.siteCommune, Text(site.commune)),
            if (coordinates != null)
              _Line(l10n.siteCoordinates, LtrText(coordinates)),
            _Line(l10n.siteOwner, Text(site.owner)),
            if (site.contractNumber != null)
              _Line(l10n.siteContractNumber, LtrText(site.contractNumber!)),
            // Pas de ligne du tout sans la permission : le champ n'existe pas (CA-007.4).
            if (amount != null)
              _Line(
                l10n.siteContractAmount,
                LtrText(contractAmountText(amount)),
              ),
            if (site.delayDays != null)
              _Line(l10n.siteDelay, Text(l10n.siteDelayDays(site.delayDays!))),
            if (ods != null) _Line(l10n.siteOds, LtrText(Formatters.date(ods))),
            // « A definir » : pas de date inventee (CA-007.3).
            _Line(
              l10n.siteEndDate,
              end == null
                  ? Text(l10n.siteToDefine)
                  : LtrText(Formatters.date(end)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyLarge,
              child: value,
            ),
          ),
        ],
      ),
    );
  }
}

/// Titre « Zones » et bouton « + Zone » (absent, jamais grise, sans la permission).
class _ZonesHeader extends StatelessWidget {
  const _ZonesHeader({required this.canAdd, required this.onAdd});

  final bool canAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.siteZonesTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (canAdd)
          FilledButton.tonal(onPressed: onAdd, child: Text(l10n.zoneAddButton)),
      ],
    );
  }
}

/// Une zone : cote signee et local ; marque « En attente d'envoi » si creee hors ligne.
class ZoneTile extends StatelessWidget {
  const ZoneTile({required this.zone, super.key});

  final ZoneRow zone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final elevation = zone.elevation;
    final room = roomLabelText(l10n, zone);
    final title = [
      if (elevation != null)
        Formatters.isolateLtr(elevationWithUnit(elevation)),
      ?room,
    ].join(' · ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title.isEmpty ? '—' : title),
      trailing: zone.isPending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 18, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  l10n.zonePendingBadge,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                ),
              ],
            )
          : null,
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, super.key});

  final SiteMemberRow member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person),
      // Nom et role seulement : jamais de telephone (CA-017.4).
      title: Text(Formatters.isolateName(member.fullName)),
      subtitle: Text(roleLabel(l10n, member.role)),
    );
  }
}

class _AuditLines extends StatelessWidget {
  const _AuditLines({required this.site});

  final SiteRow site;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant);
    String when(DateTime value) =>
        Formatters.isolateLtr(Formatters.dateTime(value));
    final updatedAt = site.updatedAt;
    final updatedBy = site.updatedByName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.siteCreatedBy(
            Formatters.isolateName(site.createdByName),
            when(site.createdAt),
          ),
          style: style,
        ),
        if (updatedAt != null && updatedBy != null)
          Text(
            l10n.siteUpdatedBy(
              Formatters.isolateName(updatedBy),
              when(updatedAt),
            ),
            style: style,
          ),
      ],
    );
  }
}
