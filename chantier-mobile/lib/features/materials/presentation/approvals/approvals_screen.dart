import 'dart:async';

import 'package:chantier_mobile/core/l10n/error_messages.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/utils/client_id.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/domain/algeria_date.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/quantity_mirror.dart';
import 'package:chantier_mobile/features/materials/domain/request_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/reason_sheet.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_labels.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_widgets.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// « A valider » (US-MAT-003) : les demandes en attente de decision du conducteur. **Valider en
/// 2 gestes** (ouvrir l'ecran, « Valider »), refuser avec un motif, valider avec une autre
/// quantite. Hors ligne : la decision est enregistree, marquee « Validation en attente
/// d'envoi », et le serveur tranche a l'envoi (il gagne toujours sur les statuts).
class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({
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
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  late final Stream<List<ZoneRow>> _zones = widget.zones;

  /// Demandes dont une decision vient d'etre enregistree (bouton inactif des l'appui).
  final Set<String> _busy = {};

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _approve(RequestView view, {Quantity? quantity}) async {
    final l10n = AppLocalizations.of(context);
    if (!_busy.add(view.id)) return;
    setState(() {});
    final result = await widget.repository.approve(
      view: view,
      userId: widget.user.id,
      clientId: generateClientId(),
      label: requestOperationLabel(l10n, view.row, quantity: quantity),
      quantity: quantity,
    );
    unawaited(HapticFeedback.mediumImpact());
    if (!mounted) return;
    _snack(
      result == QueueResult.queued
          ? l10n.requestActionQueued
          : l10n.requestActionAlreadyQueued,
    );
  }

  Future<void> _reject(RequestView view) async {
    final l10n = AppLocalizations.of(context);
    final settings = await widget.repository.settings();
    if (!mounted) return;
    final reason = await showReasonSheet(
      context,
      title: l10n.approvalRejectTitle,
      reasons: settings.reasons['rejection'] ?? const ['Other'],
      confirmLabel: l10n.approvalRejectConfirm,
      noteMaxLength: settings.noteMaxLength,
    );
    if (reason == null || !mounted) return;
    if (!_busy.add(view.id)) return;
    setState(() {});
    final result = await widget.repository.reject(
      view: view,
      userId: widget.user.id,
      clientId: generateClientId(),
      label: requestOperationLabel(l10n, view.row),
      reasonCode: reason.code,
      reasonNote: reason.note,
    );
    unawaited(HapticFeedback.mediumImpact());
    if (!mounted) return;
    _snack(
      result == QueueResult.queued
          ? l10n.requestActionQueued
          : l10n.requestActionAlreadyQueued,
    );
  }

  Future<void> _adjust(RequestView view) async {
    final quantity = view.row.quantity;
    if (quantity == null) return;
    final adjusted = await showDialog<Quantity>(
      context: context,
      builder: (_) => _AdjustDialog(initial: quantity),
    );
    if (adjusted == null || !mounted) return;
    await _approve(view, quantity: adjusted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<RequestsCubit>().state;
    final languageCode = Localizations.localeOf(context).languageCode;
    final today = AlgeriaDate.today((widget._now ?? DateTime.now)().toUtc());
    final items = context.read<RequestsCubit>().visible(languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.approvalsTitle)),
      body: SafeArea(
        child: !state.loaded
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.approvalsEmpty,
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
                      final waiting =
                          view.hasPendingOperation || _busy.contains(view.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RequestTile(
                          key: ValueKey(view.id),
                          view: view,
                          zones: zones,
                          today: today,
                          onTap: () => widget.onOpen(view),
                          footer: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: waiting
                                ? StateBadge(
                                    icon: Icons.schedule,
                                    text: l10n.approvalPending,
                                  )
                                : _Actions(
                                    onApprove: () => _approve(view),
                                    onReject: () => _reject(view),
                                    onAdjust: () => _adjust(view),
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

class _Actions extends StatelessWidget {
  const _Actions({
    required this.onApprove,
    required this.onReject,
    required this.onAdjust,
  });

  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onAdjust;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onApprove,
          icon: const Icon(Icons.check),
          label: Text(l10n.approvalApprove),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  minimumSize: const Size.fromHeight(AppSizes.minTapTarget),
                ),
                child: Text(l10n.approvalReject),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: onAdjust,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSizes.minTapTarget),
                ),
                child: Text(l10n.approvalAdjust),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// « Valider avec une autre quantite » : meme unite que la demande (affichee, non modifiable).
class _AdjustDialog extends StatefulWidget {
  const _AdjustDialog({required this.initial});

  final Quantity initial;

  @override
  State<_AdjustDialog> createState() => _AdjustDialogState();
}

class _AdjustDialogState extends State<_AdjustDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial.value.toString().replaceAll('.', ','),
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final l10n = AppLocalizations.of(context);
    final value = parseAdjustedValue(_controller.text);
    final quantity = value == null
        ? null
        : Quantity(value, widget.initial.unit);
    final code = quantity == null
        ? 'QUANTITE_INVALIDE'
        : QuantityMirror.check(quantity);
    if (code != null) {
      setState(() => _error = errorMessageForCode(l10n, code));
      return;
    }
    Navigator.of(context).pop(quantity);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.approvalAdjustTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: l10n.requestFormQuantity,
          // Unite affichee, non modifiable : une quantite n'existe pas sans unite.
          suffixText: unitLabel(l10n, widget.initial.unit.code),
          errorText: _error,
        ),
        onChanged: (_) => setState(() => _error = null),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _confirm,
          child: Text(l10n.approvalAdjustConfirm),
        ),
      ],
    );
  }
}
