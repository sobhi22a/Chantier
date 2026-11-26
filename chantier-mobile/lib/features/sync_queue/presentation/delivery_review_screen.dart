import 'dart:async';
import 'dart:convert';

import 'package:chantier_mobile/core/l10n/error_messages.dart';
import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/l10n/quantity_format.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/data/deliveries_repository.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// « A verifier » pour une livraison ou sa photo (US-MAT-010, ADR 0011), passe 2 :
/// **Votre version** et **Version du serveur** cote a cote ; le serveur garde sa version, rien
/// n'est supprime tant que l'utilisateur n'a pas choisi.
///
/// * livraison corrigee ailleurs (`CONFLIT_VERSION`) : « Refaire ma modification » (formulaire
///   preremplie avec les valeurs du serveur et ma modification) ;
/// * livraison annulee entre-temps, demande receptionnee (`DEMANDE_NON_OUVERTE`) : le serveur
///   gagne, « Garder la version du serveur » (avec confirmation) ;
/// * creation refusee (unites incompatibles, date...) : « Corriger ma saisie » ;
/// * photo refusee : l'ecran dit pourquoi, « Abandonner » (avec confirmation).
class DeliveryReviewScreen extends StatelessWidget {
  const DeliveryReviewScreen({
    required this.userId,
    required this.operationId,
    required this.outbox,
    required this.deliveries,
    required this.onRedo,
    required this.onCorrectCreate,
    super.key,
  });

  final String userId;
  final int operationId;
  final OutboxRepository outbox;
  final DeliveriesRepository deliveries;

  /// Formulaire de correction de la livraison [delivery] (etat du serveur) avec [draft] (mes valeurs).
  final void Function(
    DeliveryRow delivery,
    DeliveryDraft draft,
    OutboxRow operation,
  )
  onRedo;

  /// Creation refusee : formulaire preremplie avec ma saisie.
  final void Function(DeliveryDraft draft, OutboxRow operation) onCorrectCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.conflictTitle)),
      body: SafeArea(
        child: StreamBuilder<List<OutboxRow>>(
          stream: outbox.watch(userId),
          builder: (context, snapshot) {
            final rows = snapshot.data;
            if (rows == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final operation = rows
                .where((r) => r.id == operationId)
                .firstOrNull;
            if (operation == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.conflictGone,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            }
            return _Review(screen: this, operation: operation);
          },
        ),
      ),
    );
  }
}

class _Review extends StatefulWidget {
  const _Review({required this.screen, required this.operation});

  final DeliveryReviewScreen screen;
  final OutboxRow operation;

  @override
  State<_Review> createState() => _ReviewState();
}

class _ReviewState extends State<_Review> {
  DeliveryRow? _delivery;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final delivery = await widget.screen.deliveries.deliveryFor(
      widget.operation,
    );
    if (!mounted) return;
    setState(() {
      _delivery = delivery;
      _loaded = true;
    });
  }

  OutboxRow get _op => widget.operation;

  Map<String, Object?> get _server {
    final text = _op.conflictJson;
    if (text == null) return const {};
    try {
      final decoded = jsonDecode(text);
      return decoded is Map ? Map<String, Object?>.from(decoded) : const {};
    } on FormatException {
      return const {};
    }
  }

  List<String> get _conflictFields {
    final text = _op.conflictFields;
    if (text == null) return const [];
    try {
      final decoded = jsonDecode(text);
      return decoded is List ? [for (final f in decoded) '$f'] : const [];
    } on FormatException {
      return const [];
    }
  }

  Future<void> _keepServer() async {
    final l10n = AppLocalizations.of(context);
    final isPhoto = _op.isPhotoOperation;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isPhoto ? l10n.photoAbandon : l10n.conflictKeepServerTitle),
        content: Text(
          isPhoto ? l10n.photoAbandonBody : l10n.conflictKeepServerBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              isPhoto ? l10n.pendingAbandon : l10n.conflictKeepServer,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    unawaited(HapticFeedback.mediumImpact());
    await widget.screen.outbox.abandon(_op);
    if (mounted) Navigator.of(context).pop();
  }

  // --- Contenu -------------------------------------------------------------------------------------------

  String _show(AppLocalizations l10n, String field, Object? value) {
    if (value == null || (value is String && value.isEmpty)) {
      return l10n.fieldEmpty;
    }
    switch (field) {
      case DeliveryFieldKeys.quantity:
        if (value is Map) {
          final unit = MeasureUnit.tryParse('${value['unit']}');
          final number = Decimal.tryParse('${value['value']}');
          if (unit != null && number != null) {
            return quantityDisplay(l10n, Quantity(number, unit));
          }
        }
        return '$value';
      case DeliveryFieldKeys.deliveryDate:
        final date = DateTime.tryParse('$value');
        return date == null
            ? '$value'
            : Formatters.isolateLtr(Formatters.date(date));
      case DeliveryFieldKeys.deliveryNoteNumber:
        return Formatters.isolateLtr('$value');
      case DeliveryFieldKeys.conformity:
        return conformityLabel(l10n, '$value');
      case DeliveryFieldKeys.reserveReasonCode:
        return reasonLabel(l10n, '$value');
      default:
        return '$value';
    }
  }

  /// Valeur d'un champ dans l'etat du serveur (`DeliverySyncData`).
  Object? _serverValue(Map<String, Object?> server, String field) =>
      switch (field) {
        DeliveryFieldKeys.reserveReasonCode =>
          (server['reserve'] as Map?)?['code'],
        DeliveryFieldKeys.reserveNote => (server['reserve'] as Map?)?['note'],
        _ => server[field],
      };

  List<_Line> _yourLines(AppLocalizations l10n) {
    final payload = _op.payload;
    if (_op.isPhotoOperation) {
      final taken = DateTime.tryParse('${payload['takenAt']}');
      return [
        _Line(
          null,
          l10n.conflictYourPhoto(
            taken == null
                ? '—'
                : Formatters.isolateLtr(Formatters.dateTime(taken.toUtc())),
          ),
        ),
      ];
    }
    if (_op.operation == DeliveryEntity.update) {
      final changes = payload['changes'];
      if (changes is! Map) return const [];
      return [
        for (final entry in changes.entries)
          _Line(
            requestFieldLabel(l10n, '${entry.key}'),
            _show(l10n, '${entry.key}', entry.value),
            flagged: _conflictFields.contains('${entry.key}'),
          ),
      ];
    }
    if (_op.operation == DeliveryEntity.transition) {
      return [
        _Line(null, l10n.conflictYourAction(l10n.conflictActionCancel)),
        if (payload['reasonCode'] is String)
          _Line(
            l10n.deliveryDetailCancelReason,
            reasonLabel(l10n, payload['reasonCode']! as String),
          ),
      ];
    }
    // Creation refusee : la saisie complete.
    return [
      for (final field in [
        DeliveryFieldKeys.quantity,
        DeliveryFieldKeys.deliveryDate,
        DeliveryFieldKeys.deliveryNoteNumber,
        DeliveryFieldKeys.conformity,
      ])
        if (payload[field] != null)
          _Line(
            requestFieldLabel(l10n, field),
            _show(l10n, field, payload[field]),
          ),
    ];
  }

  List<_Line> _serverLines(AppLocalizations l10n) {
    final server = _server;
    if (server.isEmpty || _op.isPhotoOperation) return const [];
    final fields = _op.operation == DeliveryEntity.update
        ? [
            for (final key in (_op.payload['changes'] as Map? ?? const {}).keys)
              '$key',
          ]
        : const <String>[];
    final status = server['status'];
    return [
      if (status is String)
        _Line(
          null,
          l10n.conflictServerDeliveryStatus(deliveryStatusLabel(l10n, status)),
        ),
      for (final field in fields)
        _Line(
          requestFieldLabel(l10n, field),
          _show(l10n, field, _serverValue(server, field)),
          flagged: _conflictFields.contains(field),
        ),
    ];
  }

  /// Explication en toutes lettres du refus ou du conflit.
  String _explanation(AppLocalizations l10n) {
    final code = _op.lastErrorCode;
    if (_op.operation != DeliveryEntity.create && !_op.isPhotoOperation) {
      if (code == 'TRANSITION_INTERDITE') return l10n.conflictDeliveryCancelled;
      if (code == 'DEMANDE_NON_OUVERTE') {
        return l10n.conflictDeliveryRequestClosed;
      }
    }
    return l10n.pendingReason(
      errorMessageForCode(l10n, code) ?? l10n.errorUnknown,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final screen = widget.screen;
    final delivery = _delivery;
    final code = _op.lastErrorCode;

    final isUpdate = _op.operation == DeliveryEntity.update;
    final isCreate =
        _op.isDeliveryOperation && _op.operation == DeliveryEntity.create;
    final canRedo =
        isUpdate &&
        code == 'CONFLIT_VERSION' &&
        delivery != null &&
        _loaded &&
        !delivery.isCancelled;
    final changes = isUpdate
        ? Map<String, Object?>.from(
            (_op.payload['changes'] as Map?) ?? const {},
          )
        : const <String, Object?>{};
    final yours = _yourLines(l10n);
    final servers = _serverLines(l10n);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        Text(_op.label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(_explanation(l10n), style: theme.textTheme.bodyLarge),
        const SizedBox(height: 4),
        Text(
          l10n.conflictIntro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        if (_conflictFields.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.conflictFieldsInDisagreement(
              _conflictFields
                  .map((field) => requestFieldLabel(l10n, field))
                  .join(', '),
            ),
            style: theme.textTheme.titleSmall,
          ),
        ],
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, box) {
            final yourCard = _VersionCard(
              title: l10n.conflictYourVersion,
              lines: yours,
            );
            final serverCard = _VersionCard(
              title: l10n.conflictServerVersion,
              lines: servers,
            );
            // Cote a cote ; empiles sur un tres petit ecran ou avec une police agrandie.
            if (box.maxWidth < 400 || servers.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  yourCard,
                  if (servers.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    serverCard,
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: yourCard),
                const SizedBox(width: 12),
                Expanded(child: serverCard),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        if (canRedo)
          FilledButton(
            onPressed: () {
              final draft = draftFromDeliveryChanges(
                delivery,
                changes: changes,
              );
              if (draft != null) screen.onRedo(delivery, draft, _op);
            },
            child: Text(l10n.conflictRedo),
          ),
        if (isCreate)
          FilledButton(
            onPressed: () {
              final draft = draftFromDeliveryPayload(_op.payload);
              if (draft != null) screen.onCorrectCreate(draft, _op);
            },
            child: Text(l10n.conflictCorrect),
          ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _keepServer,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSizes.primaryButtonHeight),
          ),
          child: Text(
            isCreate || _op.isPhotoOperation
                ? l10n.pendingAbandon
                : l10n.conflictKeepServer,
          ),
        ),
      ],
    );
  }
}

class _Line {
  const _Line(this.label, this.value, {this.flagged = false});

  final String? label;
  final String value;

  /// Champ en desaccord : signale par une icone **et** le texte, jamais la couleur seule.
  final bool flagged;
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({required this.title, required this.lines});

  final String title;
  final List<_Line> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (line.flagged)
                      const Padding(
                        padding: EdgeInsetsDirectional.only(end: 4),
                        child: Icon(
                          Icons.warning_amber,
                          size: 18,
                          color: AppColors.warning,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        line.label == null
                            ? line.value
                            : '${line.label} : ${line.value}',
                        style: theme.textTheme.bodyLarge,
                      ),
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
