import 'dart:async';

import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/utils/client_id.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/domain/algeria_date.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_labels.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_widgets.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// « A receptionner » (US-MAT-008) : les demandes **livrees**, a receptionner en **1 geste**
/// (ChefChantier). Marche sans reseau ; si une livraison annulee entre-temps a rendu la demande
/// incomplete, l'action passe dans « A verifier » (« La demande n'est plus complete »).
class ToReceptionScreen extends StatefulWidget {
  const ToReceptionScreen({
    required this.user,
    required this.repository,
    required this.zones,
    required this.onOpen,
    DateTime Function()? now,
    super.key,
  }) : _now = now;

  final AuthUser user;
  final MaterialsRepository repository;
  final Stream<List<ZoneRow>> zones;
  final void Function(RequestView view) onOpen;
  final DateTime Function()? _now;

  @override
  State<ToReceptionScreen> createState() => _ToReceptionScreenState();
}

class _ToReceptionScreenState extends State<ToReceptionScreen> {
  late final Stream<List<ZoneRow>> _zones = widget.zones;
  final Set<String> _busy = {};

  Future<void> _receive(RequestView view) async {
    if (_busy.contains(view.id)) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy.add(view.id));
    final result = await widget.repository.receive(
      view: view,
      userId: widget.user.id,
      clientId: generateClientId(),
      label: requestOperationLabel(l10n, view.row),
    );
    unawaited(HapticFeedback.mediumImpact());
    if (!mounted) return;
    setState(() => _busy.remove(view.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == QueueResult.queued
              ? l10n.requestActionQueued
              : l10n.requestActionAlreadyQueued,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<RequestsCubit>().state;
    final languageCode = Localizations.localeOf(context).languageCode;
    final today = AlgeriaDate.today((widget._now ?? DateTime.now)().toUtc());
    final items = filterRequests(
      state.all,
      view: RequestListView.toReception,
      languageCode: languageCode,
    );
    final canReceive = widget.user.canReceiveRequests;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.toReceptionTitle)),
      body: SafeArea(
        child: !state.loaded
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.toReceptionEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              )
            : StreamBuilder<List<ZoneRow>>(
                stream: _zones,
                builder: (context, snapshot) {
                  final zones = zonesById(snapshot.data ?? const []);
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final view = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RequestTile(
                          key: ValueKey(view.id),
                          view: view,
                          zones: zones,
                          today: today,
                          onTap: () => widget.onOpen(view),
                          // Un seul bouton, 56 dp : « Receptionner » (absent sans le droit).
                          footer: !canReceive
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: _busy.contains(view.id)
                                          ? null
                                          : () => _receive(view),
                                      icon: const Icon(Icons.inventory),
                                      label: Text(l10n.toReceptionAction),
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
