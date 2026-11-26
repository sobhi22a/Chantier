import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/domain/algeria_date.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_widgets.dart';
import 'package:chantier_mobile/features/zones/presentation/widgets/option_chips.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// « Demandes » d'un chantier (US-MAT-002) : A suivre, Terminees, Refusees et annulees,
/// Archivees ; « Mes demandes » par defaut pour un chef d'equipe ; recherche (numero, materiau,
/// remarque). Tout vient de la base locale : complet hors ligne.
class RequestsScreen extends StatefulWidget {
  const RequestsScreen({
    required this.user,
    required this.zones,
    required this.onOpen,
    this.onNew,
    this.onOpenApprovals,
    DateTime Function()? now,
    super.key,
  }) : _now = now;

  final AuthUser user;
  final Stream<List<ZoneRow>> zones;
  final void Function(RequestView view) onOpen;

  /// « Nouvelle demande » : absent sans la permission `Requests.Create` (jamais grise).
  final VoidCallback? onNew;

  /// « A valider » : absent sans la permission `Requests.Approve`.
  final VoidCallback? onOpenApprovals;
  final DateTime Function()? _now;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  static const _views = [
    RequestListView.toFollow,
    RequestListView.received,
    RequestListView.closed,
    RequestListView.archived,
  ];

  late final Stream<List<ZoneRow>> _zones = widget.zones;

  String _viewLabel(AppLocalizations l10n, RequestListView view) =>
      switch (view) {
        RequestListView.received => l10n.requestsViewReceived,
        RequestListView.closed => l10n.requestsViewClosed,
        RequestListView.archived => l10n.requestsViewArchived,
        _ => l10n.requestsViewToFollow,
      };

  /// Recherche et pastilles de vue : un `Wrap` qui passe a la ligne, jamais une hauteur fixe.
  Widget _header(
    AppLocalizations l10n,
    RequestsCubit cubit,
    RequestsState state,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: l10n.requestsSearchHint,
        ),
        onChanged: cubit.search,
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final view in _views)
            OptionChip(
              selected: state.view == view,
              onSelected: () => cubit.selectView(view),
              child: (style) => Text(_viewLabel(l10n, view), style: style),
            ),
          OptionChip(
            selected: state.mineOnly,
            onSelected: () => cubit.setMineOnly(value: !state.mineOnly),
            child: (style) => Text(l10n.requestsMine, style: style),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<RequestsCubit>();
    final state = context.watch<RequestsCubit>().state;
    final languageCode = Localizations.localeOf(context).languageCode;
    final today = AlgeriaDate.today((widget._now ?? DateTime.now)().toUtc());
    final items = cubit.visible(languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.requestsTitle),
        actions: [
          if (widget.onOpenApprovals != null)
            TextButton(
              onPressed: widget.onOpenApprovals,
              child: Text(l10n.approvalsTitle),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ZoneRow>>(
                stream: _zones,
                builder: (context, snapshot) {
                  final zones = zonesById(snapshot.data ?? const []);
                  final showItems = state.loaded && items.isNotEmpty;
                  // `ListView.builder` : reste fluide avec des centaines de demandes.
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    itemCount: showItems ? items.length + 1 : 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _header(l10n, cubit, state),
                        );
                      }
                      if (!state.loaded) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.requestsEmpty,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }
                      final item = items[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RequestTile(
                          key: ValueKey(item.id),
                          view: item,
                          zones: zones,
                          today: today,
                          onTap: () => widget.onOpen(item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (widget.onNew != null)
              Padding(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.onNew,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.requestNew),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
