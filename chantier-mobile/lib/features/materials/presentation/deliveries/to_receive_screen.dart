import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/quantity_format.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/theme/terrain_styles.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/domain/algeria_date.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/order_info.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/to_receive_listing.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_widgets.dart';
import 'package:chantier_mobile/features/zones/presentation/widgets/option_chips.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// « A recevoir » (US-MAT-006) : les commandes attendues (commandees ou livrees partiellement),
/// la date prevue la plus proche en premier ; recherche par fournisseur, materiau ou numero et
/// filtres « Aujourd'hui · Cette semaine · En retard ». Tout vient de la base locale : complet hors
/// ligne. Un appui sur une commande ouvre « Recevoir » (quantite = reste).
class ToReceiveScreen extends StatefulWidget {
  const ToReceiveScreen({
    required this.user,
    required this.onOpen,
    this.onWithoutRequest,
    DateTime Function()? now,
    super.key,
  }) : _now = now;

  final AuthUser user;
  final void Function(RequestView view) onOpen;

  /// « Livraison sans demande » : absent sans la permission `Deliveries.Create`.
  final VoidCallback? onWithoutRequest;
  final DateTime Function()? _now;

  @override
  State<ToReceiveScreen> createState() => _ToReceiveScreenState();
}

class _ToReceiveScreenState extends State<ToReceiveScreen> {
  ReceiveFilter _filter = ReceiveFilter.all;
  String _query = '';

  String _filterLabel(AppLocalizations l10n, ReceiveFilter filter) =>
      switch (filter) {
        ReceiveFilter.all => l10n.receiveFilterAll,
        ReceiveFilter.today => l10n.receiveFilterToday,
        ReceiveFilter.week => l10n.receiveFilterWeek,
        ReceiveFilter.late => l10n.receiveFilterLate,
      };

  Widget _header(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: l10n.toReceiveSearchHint,
        ),
        onChanged: (value) => setState(() => _query = value),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final filter in ReceiveFilter.values)
            OptionChip(
              selected: _filter == filter,
              onSelected: () => setState(() => _filter = filter),
              child: (style) => Text(_filterLabel(l10n, filter), style: style),
            ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<RequestsCubit>().state;
    final languageCode = Localizations.localeOf(context).languageCode;
    final today = AlgeriaDate.today((widget._now ?? DateTime.now)().toUtc());
    final items = filterToReceive(
      state.all,
      filter: _filter,
      today: today,
      languageCode: languageCode,
      query: _query,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.toReceiveTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: !state.loaded
                  ? const Center(child: CircularProgressIndicator())
                  // En-tete (recherche + filtres) **dans la zone defilante** (D-3) ;
                  // `ListView.builder` : reste fluide avec 100 commandes a recevoir.
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.screenPadding),
                      itemCount: items.isEmpty ? 2 : items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _header(l10n),
                          );
                        }
                        if (items.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.toReceiveEmpty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }
                        final item = items[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ToReceiveTile(
                            key: ValueKey(item.id),
                            view: item,
                            today: today,
                            canRecord: widget.user.canRecordDelivery,
                            onTap: () => widget.onOpen(item),
                          ),
                        );
                      },
                    ),
            ),
            if (widget.onWithoutRequest != null)
              Padding(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.onWithoutRequest,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        AppSizes.primaryButtonHeight,
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.toReceiveWithoutRequest),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToReceiveTile extends StatelessWidget {
  const _ToReceiveTile({
    required this.view,
    required this.today,
    required this.canRecord,
    required this.onTap,
    super.key,
  });

  final RequestView view;
  final DateTime today;
  final bool canRecord;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final row = view.row;
    final expected = expectedDateOf(view);
    final reference = expected ?? row.neededBy;
    final late = reference.isBefore(today);
    final remaining = row.remainingQuantity ?? row.quantity;
    final supplier = row.order?.supplierName;

    return Card(
      child: InkWell(
        // Seulement avec le droit de saisir une livraison : sinon la commande s'ouvre en detail.
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: row.hasNumber
                        ? LtrText(row.number!, style: context.keyValueStyle)
                        : Text(
                            l10n.materialNumberPending,
                            style: theme.textTheme.titleSmall,
                          ),
                  ),
                  if (view.isStatusProvisional)
                    StateBadge(
                      icon: Icons.schedule,
                      text: l10n.materialToConfirm,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.isolateName(requestProductName(row, languageCode)),
                style: theme.textTheme.titleMedium,
              ),
              if (supplier != null)
                Text(
                  Formatters.isolateName(supplier),
                  style: theme.textTheme.bodyLarge,
                ),
              const SizedBox(height: 4),
              if (remaining != null)
                Text(
                  l10n.toReceiveRemaining(quantityDisplay(l10n, remaining)),
                  style: context.keyValueStyle,
                ),
              const SizedBox(height: 4),
              Text(
                expected == null
                    ? l10n.toReceiveNoDate
                    : l10n.toReceiveExpectedOn(
                        Formatters.isolateLtr(Formatters.date(expected)),
                      ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: late ? AppColors.error : null,
                ),
              ),
              if (late)
                StateBadge(
                  icon: Icons.warning_amber,
                  text: l10n.receiveFilterLate,
                  color: AppColors.error,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
