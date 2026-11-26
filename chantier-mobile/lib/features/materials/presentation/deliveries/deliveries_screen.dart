import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_listing.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/deliveries_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/delivery_widgets.dart';
import 'package:chantier_mobile/features/zones/presentation/widgets/option_chips.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// « Livraisons » d'un chantier (US-MAT-011, 012) : toutes, **non rattachees**, avec reserve, BL
/// manquant ; recherche par numero, materiau, fournisseur ou n° de bon. Tout vient de la base
/// locale : complet hors ligne.
class DeliveriesScreen extends StatelessWidget {
  const DeliveriesScreen({
    required this.user,
    required this.onOpen,
    this.onNewWithoutRequest,
    super.key,
  });

  final AuthUser user;
  final void Function(DeliveryView view) onOpen;

  /// « Livraison sans demande » : absent sans la permission `Deliveries.Create`.
  final VoidCallback? onNewWithoutRequest;

  String _filterLabel(AppLocalizations l10n, DeliveryListFilter filter) =>
      switch (filter) {
        DeliveryListFilter.all => l10n.deliveriesFilterAll,
        DeliveryListFilter.unattached => l10n.deliveriesFilterUnattached,
        DeliveryListFilter.withReserve => l10n.deliveriesFilterReserve,
        DeliveryListFilter.noteMissing => l10n.deliveriesFilterNoteMissing,
      };

  Widget _header(
    AppLocalizations l10n,
    DeliveriesCubit cubit,
    DeliveriesState state,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: l10n.deliveriesSearchHint,
        ),
        onChanged: cubit.search,
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final filter in DeliveryListFilter.values)
            OptionChip(
              selected: state.filter == filter,
              onSelected: () => cubit.selectFilter(filter),
              child: (style) => Text(_filterLabel(l10n, filter), style: style),
            ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DeliveriesCubit>();
    final state = context.watch<DeliveriesCubit>().state;
    final languageCode = Localizations.localeOf(context).languageCode;
    final items = cubit.visible(languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deliveriesTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: !state.loaded
                  ? const Center(child: CircularProgressIndicator())
                  // En-tete (recherche + filtres) **dans la zone defilante** (D-3) ;
                  // `ListView.builder` : 200 livraisons non rattachees restent fluides.
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.screenPadding),
                      itemCount: items.isEmpty ? 2 : items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _header(l10n, cubit, state),
                          );
                        }
                        if (items.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.deliveriesEmpty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }
                        final item = items[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DeliveryTile(
                            key: ValueKey(item.id),
                            view: item,
                            onTap: () => onOpen(item),
                          ),
                        );
                      },
                    ),
            ),
            if (onNewWithoutRequest != null && user.canRecordDelivery)
              Padding(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onNewWithoutRequest,
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
