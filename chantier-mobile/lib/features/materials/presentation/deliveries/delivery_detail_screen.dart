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
import 'package:chantier_mobile/features/materials/data/photo_capture.dart';
import 'package:chantier_mobile/features/materials/data/photo_files.dart';
import 'package:chantier_mobile/features/materials/data/photo_remote.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_listing.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/material_settings.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/deliveries_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/delivery_widgets.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/history_section.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/photo_widgets.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/reason_sheet.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Detail d'une livraison (US-MAT-007, 011, 012) : quantite **avec unite** et equivalent dans la
/// demande, date, fournisseur, bon, reserve, photos du bon (chargees a la demande, avec reseau),
/// historique. Actions selon les permissions : **Corriger**, **Annuler** (motif obligatoire) et
/// **ajouter une photo** (« on peut completer plus tard »). Aucun prix, aucun montant.
class DeliveryDetailScreen extends StatefulWidget {
  const DeliveryDetailScreen({
    required this.user,
    required this.deliveries,
    required this.materials,
    required this.capture,
    required this.files,
    required this.viewer,
    required this.onEdit,
    this.onOpenRequest,
    this.onReview,
    this.history,
    super.key,
  });

  final AuthUser user;
  final DeliveriesRepository deliveries;
  final MaterialsRepository materials;
  final PhotoCapture capture;
  final PhotoFiles files;
  final PhotoViewer viewer;
  final void Function(DeliveryView view) onEdit;

  /// Ouvre la demande liee.
  final void Function(String requestId)? onOpenRequest;

  /// Ouvre « A verifier » pour la saisie en conflit de cette livraison.
  final void Function(DeliveryView view)? onReview;

  /// Lecture de l'historique en ligne (`null` : seulement ce que le telephone sait deja).
  final HistorySource? history;

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  bool _cancelling = false;
  bool _addingPhotos = false;
  List<CapturedPhoto> _newPhotos = const [];
  MaterialRequestRow? _request;
  String? _requestLoadedFor;
  MaterialSettings _settings = const MaterialSettings();
  late final Stream<List<PendingPhotoFileRow>> _pendingFiles = widget.deliveries
      .watchPendingFiles(widget.user.id);

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  @override
  void dispose() {
    for (final photo in _newPhotos) {
      unawaited(widget.files.delete(widget.user.id, photo.relativePath));
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await widget.materials.settings();
    if (mounted) setState(() => _settings = settings);
  }

  Future<void> _loadRequest(String? requestId) async {
    if (requestId == null || _requestLoadedFor == requestId) return;
    _requestLoadedFor = requestId;
    final view = await widget.materials
        .watchRequest(requestId, widget.user.id)
        .first;
    if (mounted) setState(() => _request = view?.row);
  }

  Future<void> _cancel(DeliveryView view) async {
    final l10n = AppLocalizations.of(context);
    final reason = await showReasonSheet(
      context,
      title: l10n.deliveryCancelTitle,
      reasons: _settings.reasons['deliveryCancellation'] ?? const ['Other'],
      confirmLabel: l10n.deliveryCancelConfirm,
      noteMaxLength: _settings.noteMaxLength,
    );
    if (reason == null || !mounted || _cancelling) return;
    setState(() => _cancelling = true);
    final result = await widget.deliveries.cancel(
      view: view,
      userId: widget.user.id,
      clientId: generateClientId(),
      label: _label(l10n, view.row),
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

  String _label(AppLocalizations l10n, DeliveryRow row) => [
    if (row.number != null) row.number!,
    row.productName ?? row.freeProductName ?? '',
    // Une unite inconnue de cette version est affichee telle que recue.
    if (row.quantity != null)
      formatQuantity(l10n, row.quantity!)
    else
      '${row.quantityValue} ${row.quantityUnit}',
  ].join(' · ');

  Future<void> _savePhotos(DeliveryView view) async {
    if (_newPhotos.isEmpty || _addingPhotos) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _addingPhotos = true);
    final result = await widget.deliveries.addPhotos(
      view: view,
      userId: widget.user.id,
      photos: _newPhotos,
      photoLabel: l10n.pendingEntityPhoto,
      maxPhotos: _settings.maxPhotosPerDelivery,
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case DeliverySaved():
        unawaited(HapticFeedback.mediumImpact());
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.requestActionQueued)),
        );
        setState(() {
          _newPhotos = const [];
          _addingPhotos = false;
        });
      case DeliveryTooManyPhotos():
        unawaited(HapticFeedback.heavyImpact());
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.photoMax(_settings.maxPhotosPerDelivery.toString()),
            ),
          ),
        );
        setState(() => _addingPhotos = false);
      default:
        setState(() => _addingPhotos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<DeliveryDetailCubit>().state;
    final view = state.view;
    unawaited(_loadRequest(view?.row.requestId));
    return Scaffold(
      appBar: AppBar(
        title: view == null || view.row.number == null
            ? Text(l10n.deliveriesTitle)
            : LtrText(view.row.number!),
      ),
      body: !state.loaded
          ? const Center(child: CircularProgressIndicator())
          : view == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.deliveryDetailNotFound,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : SafeArea(child: _body(context, view, state.photos)),
    );
  }

  Widget _body(
    BuildContext context,
    DeliveryView view,
    List<DeliveryPhotoRow> photos,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final row = view.row;
    final quantity = row.quantity;
    final inRequest = row.quantityInRequest;
    final supplier = deliverySupplierName(view);
    final canCorrect =
        widget.user.canCorrectDelivery(row, _request) && !view.needsCheck;
    final canAddPhotos =
        widget.user.canAddDeliveryPhotos &&
        !row.isCancelled &&
        _request?.statusValue?.code != 'Received';

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
        Formatters.isolateName(deliveryProductName(view, languageCode)),
        style: theme.textTheme.titleLarge,
      ),
      (_) => const SizedBox(height: 4),
      (ctx) => Text(
        quantity == null
            ? '${row.quantityValue} ${row.quantityUnit}'
            : quantityDisplay(l10n, quantity),
        style: ctx.keyValueStyle,
      ),
      if (inRequest != null && quantity != null && quantity != inRequest)
        (_) => Text(
          Formatters.isolateLtr(
            '${formatQuantity(l10n, quantity)} = '
            '${formatQuantity(l10n, inRequest)}',
          ),
          style: theme.textTheme.titleMedium,
        ),
      (_) => const SizedBox(height: 8),
      (_) => DeliveryStatusLine(view: view),
      if (view.needsCheck && widget.onReview != null)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: FilledButton(
            onPressed: () => widget.onReview!(view),
            child: Text(l10n.pendingView),
          ),
        ),
      (_) => const SizedBox(height: 12),
      (_) => line(
        l10n.deliveryDetailDate,
        LtrText(Formatters.date(row.deliveryDate)),
      ),
      if (supplier != null)
        (_) => line(
          l10n.deliveryDetailSupplier,
          Text(Formatters.isolateName(supplier)),
        ),
      if (row.deliveryNoteNumber != null)
        (_) => line(l10n.deliveryDetailNote, LtrText(row.deliveryNoteNumber!)),
      if (row.requestId != null && _request?.number != null)
        (_) => line(
          l10n.deliveryDetailRequest,
          widget.onOpenRequest == null
              ? LtrText(_request!.number!)
              : TextButton(
                  onPressed: () => widget.onOpenRequest!(row.requestId!),
                  child: LtrText(_request!.number!),
                ),
        ),
      if (row.isUnattached && row.unattachedReason != null)
        (_) => line(
          l10n.deliveryDetailUnattachedReason,
          Text(unattachedReasonLabel(l10n, row.unattachedReason!)),
        ),
      if (row.reserveReasonCode != null)
        (_) => line(
          l10n.deliveryDetailReserve,
          Text(
            [
              reasonLabel(l10n, row.reserveReasonCode!),
              if ((row.reserveNote ?? '').isNotEmpty) row.reserveNote!,
            ].join(' · '),
          ),
        ),
      if (row.cancelReasonCode != null)
        (_) => line(
          l10n.deliveryDetailCancelReason,
          Text(
            [
              reasonLabel(l10n, row.cancelReasonCode!),
              if ((row.cancelReasonNote ?? '').isNotEmpty)
                row.cancelReasonNote!,
            ].join(' · '),
          ),
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
      if (row.isUnattached && widget.user.canAttachDeliveries)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            l10n.deliveryAttachInfo,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      if (row.clientCreatedAt != null)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            l10n.deliveryDetailSavedAt(
              Formatters.isolateLtr(
                Formatters.dateTime(row.clientCreatedAt!.toUtc()),
              ),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      (_) => const SizedBox(height: 16),
      (_) => Text(l10n.deliveryDetailPhotos, style: theme.textTheme.titleLarge),
      (_) => const SizedBox(height: 8),
      (_) => photos.isEmpty
          ? Text(l10n.deliveryDetailNoPhotos)
          : StreamBuilder<List<PendingPhotoFileRow>>(
              stream: _pendingFiles,
              builder: (context, snapshot) => DeliveryPhotoGallery(
                photos: photos,
                siteId: row.siteId,
                viewer: widget.viewer,
                files: widget.files,
                ownerUserId: widget.user.id,
                pendingPaths: {
                  for (final file
                      in snapshot.data ?? const <PendingPhotoFileRow>[])
                    file.clientId: file.relativePath,
                },
                canView: widget.user.canViewDeliveryPhotos,
              ),
            ),
      if (canAddPhotos)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PhotoCaptureSection(
                ownerUserId: widget.user.id,
                capture: widget.capture,
                files: widget.files,
                photos: _newPhotos,
                alreadyTaken: photos.length,
                maxPhotos: _settings.maxPhotosPerDelivery,
                maxBytes: _settings.maxPhotoBytes,
                onChanged: (next) => setState(() => _newPhotos = next),
              ),
              if (_newPhotos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FilledButton(
                    onPressed: _addingPhotos ? null : () => _savePhotos(view),
                    child: Text(l10n.requestEditSave),
                  ),
                ),
            ],
          ),
        ),
      if (canCorrect)
        (_) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () => widget.onEdit(view),
                icon: const Icon(Icons.edit),
                label: Text(l10n.deliveryActionEdit),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _cancelling ? null : () => _cancel(view),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  minimumSize: const Size.fromHeight(
                    AppSizes.primaryButtonHeight,
                  ),
                ),
                icon: const Icon(Icons.cancel),
                label: Text(l10n.deliveryActionCancel),
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
            : () => widget.history!.deliveryHistory(row.siteId, row.id),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index](context),
    );
  }
}
