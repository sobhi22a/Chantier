import 'dart:async';

import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/l10n/quantity_format.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/theme/terrain_styles.dart';
import 'package:chantier_mobile/core/utils/client_id.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/data/deliveries_repository.dart';
import 'package:chantier_mobile/features/materials/data/history_remote.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/data/supplier_contact.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/order_info.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/request_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/delivery_widgets.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/history_section.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/reason_sheet.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_labels.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_widgets.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/supplier_call_button.dart';
import 'package:chantier_mobile/features/zones/domain/zone_format.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Detail d'une demande (US-MAT-002) : informations, statut (« a confirmer » s'il vient d'une
/// saisie en attente), motif, historique (qui, quand, ancien -> nouveau statut), actions selon
/// les permissions : **Corriger** et **Annuler** (avec motif). Aucun prix, aucun telephone.
class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({
    required this.user,
    required this.repository,
    required this.zones,
    required this.onEdit,
    this.onReview,
    this.deliveries,
    this.contact,
    this.dialer,
    this.onReceive,
    this.onOpenDelivery,
    this.onReception,
    this.history,
    super.key,
  });

  final AuthUser user;
  final MaterialsRepository repository;
  final Stream<List<ZoneRow>> zones;
  final void Function(RequestView view) onEdit;

  /// Ouvre « A verifier » pour la saisie en conflit de cette demande.
  final void Function(RequestView view)? onReview;

  /// Livraisons de la demande (absentes : la section n'apparait pas).
  final DeliveriesRepository? deliveries;

  /// « Appeler le fournisseur » : numero lu en ligne, jamais stocke (avec `SupplierPhone.View`).
  final SupplierContactSource? contact;
  final PhoneDialer? dialer;

  /// « Recevoir une livraison » : ouvre le formulaire (avec `Deliveries.Create`).
  final void Function(RequestView view)? onReceive;
  final void Function(DeliveryView view)? onOpenDelivery;

  /// « Receptionner » (1 geste) : demande livree, avec `Requests.Receive`.
  final void Function(RequestView view)? onReception;

  /// Lecture de l'historique en ligne (`null` : seulement ce que le telephone sait deja).
  final HistorySource? history;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late final Stream<List<ZoneRow>> _zones = widget.zones;
  bool _cancelling = false;

  Future<void> _cancel(RequestView view) async {
    final l10n = AppLocalizations.of(context);
    final settings = await widget.repository.settings();
    if (!mounted) return;
    final reason = await showReasonSheet(
      context,
      title: l10n.requestCancelTitle,
      reasons: settings.reasons['requestCancellation'] ?? const ['Other'],
      confirmLabel: l10n.requestCancelConfirm,
      noteMaxLength: settings.noteMaxLength,
    );
    if (reason == null || !mounted || _cancelling) return;
    setState(() => _cancelling = true);
    final result = await widget.repository.cancel(
      view: view,
      userId: widget.user.id,
      clientId: generateClientId(),
      label: requestOperationLabel(l10n, view.row),
      reasonCode: reason.code,
      reasonNote: reason.note,
    );
    unawaited(HapticFeedback.mediumImpact());
    if (!mounted) return;
    setState(() => _cancelling = false);
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
    final state = context.watch<RequestDetailCubit>().state;
    final view = state.view;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: view == null || !view.row.hasNumber
            ? Text(l10n.requestsTitle)
            : LtrText(view.row.number!),
      ),
      body: !state.loaded
          ? const Center(child: CircularProgressIndicator())
          : view == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.requestDetailNotFound,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : SafeArea(
              child: StreamBuilder<List<ZoneRow>>(
                stream: _zones,
                builder: (context, snapshot) {
                  final zones = zonesById(snapshot.data ?? const []);
                  return _body(context, view, zones, languageCode);
                },
              ),
            ),
    );
  }

  Widget _body(
    BuildContext context,
    RequestView view,
    Map<String, ZoneRow> zones,
    String languageCode,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final row = view.row;
    final quantity = row.quantity;
    final zone = row.zoneId == null ? null : zones[row.zoneId];
    final canEdit = widget.user.canEditRequest(row) && !view.needsCheck;
    final canCancel = widget.user.canCancelRequest(row) && !view.needsCheck;
    final order = row.order;
    final canReceiveDelivery =
        widget.onReceive != null &&
        widget.user.canRecordDelivery &&
        canRecordFor(row) &&
        !view.needsCheck;
    final canReception =
        widget.onReception != null &&
        widget.user.canReceiveRequests &&
        row.archivedAt == null &&
        row.statusValue == RequestStatus.delivered;

    Widget line(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

    final items = <Widget Function(BuildContext)>[
      (_) => Text(
        Formatters.isolateName(requestProductName(row, languageCode)),
        style: theme.textTheme.titleLarge,
      ),
      (_) => const SizedBox(height: 4),
      (ctx) => Text(
        quantity == null
            ? '${row.quantityValue} ${row.quantityUnit}'
            : quantityDisplay(l10n, quantity),
        style: ctx.keyValueStyle,
      ),
      (_) => const SizedBox(height: 8),
      (_) => RequestStatusLine(view: view),
      if (view.needsCheck && widget.onReview != null)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: FilledButton(
            onPressed: () => widget.onReview!(view),
            child: Text(l10n.pendingView),
          ),
        ),
      if (view.hasPendingApproval)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: StateBadge(icon: Icons.schedule, text: l10n.approvalPending),
        ),
      (_) => const SizedBox(height: 12),
      (_) => line(
        l10n.requestFormNeededBy,
        LtrText(Formatters.date(row.neededBy)),
      ),
      (_) => line(
        l10n.requestFormPriority,
        Text(priorityLabel(l10n, row.priority)),
      ),
      (_) => line(
        l10n.requestDetailZone,
        Text(
          zone == null ? l10n.requestZoneNone : zoneLabelForDisplay(l10n, zone),
        ),
      ),
      if ((row.note ?? '').isNotEmpty)
        (_) => line(l10n.requestDetailNote, Text(row.note!)),
      if (row.statusReasonCode != null)
        (_) => line(
          l10n.requestDetailReason,
          Text(
            [
              reasonLabel(l10n, row.statusReasonCode!),
              if ((row.statusReasonNote ?? '').isNotEmpty)
                row.statusReasonNote!,
            ].join(' · '),
          ),
        ),
      if (row.requestedByName != null)
        (_) => line(
          l10n.requestFormProduct,
          Text(
            l10n.requestDetailRequestedBy(
              Formatters.isolateName(row.requestedByName!),
            ),
          ),
        ),
      if (row.receivedQuantity != null)
        (_) => line(
          l10n.requestDetailReceived,
          Text(quantityDisplay(l10n, row.receivedQuantity!)),
        ),
      if (row.remainingQuantity != null)
        (_) => line(
          l10n.requestDetailRemaining,
          Text(quantityDisplay(l10n, row.remainingQuantity!)),
        ),
      if (row.varianceQuantity != null)
        (_) => line(
          l10n.requestDetailVariance,
          Text(quantityDisplay(l10n, row.varianceQuantity!)),
        ),
      if (row.possibleDuplicateOfNumber != null)
        (_) => line(
          l10n.requestFormSeeDuplicate,
          Text(
            l10n.requestDetailDuplicate(
              Formatters.isolateLtr(row.possibleDuplicateOfNumber!),
            ),
          ),
        ),
      if (row.clientCreatedAt != null)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            l10n.requestDetailSavedAt(
              Formatters.isolateLtr(
                Formatters.dateTime(row.clientCreatedAt!.toUtc()),
              ),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      if (order?.supplierName != null)
        (_) => line(
          l10n.requestDetailSupplier,
          Text(Formatters.isolateName(order!.supplierName!)),
        ),
      if (order?.expectedDeliveryDate != null)
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            l10n.requestDetailExpected(
              Formatters.isolateLtr(
                Formatters.date(order!.expectedDeliveryDate!),
              ),
            ),
            style: theme.textTheme.bodyLarge,
          ),
        ),
      // « Appeler le fournisseur » : seulement avec `SupplierPhone.View`, numero lu en ligne.
      if (order?.supplierId != null &&
          widget.user.canCallSuppliers &&
          widget.contact != null &&
          widget.dialer != null)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SupplierCallButton(
            supplierId: order!.supplierId!,
            supplierName: order.supplierName,
            contact: widget.contact!,
            dialer: widget.dialer!,
          ),
        ),
      if (canReceiveDelivery)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: FilledButton.icon(
            onPressed: () => widget.onReceive!(view),
            icon: const Icon(Icons.local_shipping),
            label: Text(l10n.requestActionReceive),
          ),
        ),
      if (canReception)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: FilledButton.icon(
            onPressed: () => widget.onReception!(view),
            icon: const Icon(Icons.inventory),
            label: Text(l10n.requestActionReception),
          ),
        ),
      if (widget.deliveries != null && row.siteId.isNotEmpty)
        (_) => _RequestDeliveries(
          repository: widget.deliveries!,
          view: view,
          userId: widget.user.id,
          onOpen: widget.onOpenDelivery,
        ),
      if (canEdit || canCancel)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canEdit)
                FilledButton.icon(
                  onPressed: () => widget.onEdit(view),
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.requestActionEdit),
                ),
              if (canEdit && canCancel) const SizedBox(height: 12),
              if (canCancel)
                OutlinedButton.icon(
                  onPressed: _cancelling ? null : () => _cancel(view),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    minimumSize: const Size.fromHeight(
                      AppSizes.primaryButtonHeight,
                    ),
                  ),
                  icon: const Icon(Icons.cancel),
                  label: Text(l10n.requestActionCancel),
                ),
            ],
          ),
        ),
      // Historique lu a la demande, avec reseau ; sinon « indisponible hors ligne » (R2-02).
      (_) => HistorySection(
        key: ValueKey('history-${row.id}'),
        localJson: row.historyJson,
        reloadKey: view.stored.version,
        loadable: !view.isNotYetSent,
        loader: widget.history == null
            ? null
            : () => widget.history!.requestHistory(row.siteId, row.id),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index](context),
    );
  }
}

/// Livraisons d'une demande (annulees comprises, hors totaux) : numero, quantite **avec unite**,
/// date, etat. Lues dans la base locale, saisies en attente comprises.
class _RequestDeliveries extends StatefulWidget {
  const _RequestDeliveries({
    required this.repository,
    required this.view,
    required this.userId,
    this.onOpen,
  });

  final DeliveriesRepository repository;
  final RequestView view;
  final String userId;
  final void Function(DeliveryView view)? onOpen;

  @override
  State<_RequestDeliveries> createState() => _RequestDeliveriesState();
}

class _RequestDeliveriesState extends State<_RequestDeliveries> {
  late final Stream<List<DeliveryView>> _stream = widget.repository
      .watchDeliveries(widget.view.row.siteId, widget.userId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<List<DeliveryView>>(
      stream: _stream,
      builder: (context, snapshot) {
        final mine = deliveriesOfRequest(
          groupByRequest(snapshot.data ?? const []),
          widget.view,
        )..sort((a, b) => a.row.deliveryDate.compareTo(b.row.deliveryDate));
        if (mine.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.requestDetailDeliveries,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final delivery in mine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DeliveryTile(
                    key: ValueKey(delivery.id),
                    view: delivery,
                    onTap: () => widget.onOpen?.call(delivery),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
