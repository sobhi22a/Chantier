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
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/zones/domain/zone_format.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// « A verifier » (US-MAT-010, ADR 0011) : une saisie de demande refusee ou en conflit.
///
/// **Votre version** et **Version du serveur** cote a cote ; le serveur garde sa version, rien
/// n'est supprime tant que l'utilisateur n'a pas choisi, et chaque choix est explicite :
///
/// * « Garder la version du serveur » (avec confirmation) : la saisie est abandonnee ;
/// * « Refaire ma modification » : champ modifie ailleurs (`CONFLIT_VERSION`), formulaire
///   preremplie avec les valeurs du serveur et ma modification ;
/// * « Creer une nouvelle demande avec mes valeurs » : demande verrouillee ou close ;
/// * « Corriger ma saisie » : creation refusee, formulaire preremplie.
class ConflictReviewScreen extends StatelessWidget {
  const ConflictReviewScreen({
    required this.userId,
    required this.operationId,
    required this.outbox,
    required this.repository,
    required this.zones,
    required this.onRedo,
    required this.onCreateNew,
    required this.onCorrectCreate,
    super.key,
  });

  final String userId;

  /// Identifiant (`id`) de la ligne de la file d'envoi.
  final int operationId;
  final OutboxRepository outbox;
  final MaterialsRepository repository;
  final Stream<List<ZoneRow>> zones;

  /// Formulaire de correction de la demande : [request] (etat du serveur) avec [draft] (mes valeurs).
  final void Function(
    MaterialRequestRow request,
    RequestDraft draft,
    OutboxRow operation,
  )
  onRedo;

  /// Nouvelle demande preremplie avec mes valeurs, qui remplace la saisie [operation].
  final void Function(RequestDraft draft, OutboxRow operation) onCreateNew;

  /// Creation refusee : formulaire preremplie avec ma saisie.
  final void Function(RequestDraft draft, OutboxRow operation) onCorrectCreate;

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

  final ConflictReviewScreen screen;
  final OutboxRow operation;

  @override
  State<_Review> createState() => _ReviewState();
}

class _ReviewState extends State<_Review> {
  late final Stream<List<ZoneRow>> _zones = widget.screen.zones;
  MaterialRequestRow? _request;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final request = await widget.screen.repository.requestFor(widget.operation);
    if (!mounted) return;
    setState(() {
      _request = request;
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.conflictKeepServerTitle),
        content: Text(l10n.conflictKeepServerBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.conflictKeepServer),
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

  /// Valeur d'un champ, prete a afficher (quantite avec unite, date complete, urgence traduite).
  String _show(
    AppLocalizations l10n,
    String field,
    Object? value,
    Map<String, ZoneRow> zones,
  ) {
    if (value == null || (value is String && value.isEmpty)) {
      return l10n.fieldEmpty;
    }
    switch (field) {
      case RequestFieldKeys.quantity:
        if (value is Map) {
          final unit = MeasureUnit.tryParse('${value['unit']}');
          final number = Decimal.tryParse('${value['value']}');
          if (unit != null && number != null) {
            return quantityDisplay(l10n, Quantity(number, unit));
          }
        }
        return '$value';
      case RequestFieldKeys.neededBy:
        final date = DateTime.tryParse('$value');
        return date == null
            ? '$value'
            : Formatters.isolateLtr(Formatters.date(date));
      case RequestFieldKeys.priority:
        return priorityLabel(l10n, '$value');
      case RequestFieldKeys.zoneId:
        final zone = zones['$value'];
        return zone == null ? '—' : zoneLabelForDisplay(l10n, zone);
      default:
        return '$value';
    }
  }

  List<_Line> _yourLines(AppLocalizations l10n, Map<String, ZoneRow> zones) {
    final payload = _op.payload;
    if (_op.operation == RequestEntity.update) {
      final changes = payload['changes'];
      if (changes is! Map) return const [];
      return [
        for (final entry in changes.entries)
          _Line(
            requestFieldLabel(l10n, '${entry.key}'),
            _show(l10n, '${entry.key}', entry.value, zones),
            flagged: _conflictFields.contains('${entry.key}'),
          ),
      ];
    }
    if (_op.operation == RequestEntity.transition) {
      final action = switch (_op.transitionAction) {
        RequestEntity.approve => l10n.conflictActionApprove,
        RequestEntity.reject => l10n.conflictActionReject,
        RequestEntity.cancel => l10n.conflictActionCancel,
        RequestEntity.receive => l10n.conflictActionReceive,
        _ => '${_op.transitionAction}',
      };
      return [
        _Line(null, l10n.conflictYourAction(action)),
        if (payload['quantity'] != null)
          _Line(
            l10n.fieldQuantity,
            _show(l10n, RequestFieldKeys.quantity, payload['quantity'], zones),
          ),
        if (payload['reasonCode'] is String)
          _Line(
            l10n.requestDetailReason,
            reasonLabel(l10n, payload['reasonCode']! as String),
          ),
      ];
    }
    // Creation refusee : la saisie complete.
    return [
      for (final field in [
        RequestFieldKeys.freeProductName,
        RequestFieldKeys.quantity,
        RequestFieldKeys.neededBy,
        RequestFieldKeys.priority,
        RequestFieldKeys.note,
      ])
        if (payload[field] != null)
          _Line(
            requestFieldLabel(l10n, field),
            _show(l10n, field, payload[field], zones),
          ),
    ];
  }

  List<_Line> _serverLines(AppLocalizations l10n, Map<String, ZoneRow> zones) {
    final server = _server;
    if (server.isEmpty) return const [];
    final fields = _op.operation == RequestEntity.update
        ? [
            for (final entry
                in (_op.payload['changes'] as Map? ?? const {}).keys)
              '$entry',
          ]
        : const <String>[];
    final status = server['status'];
    return [
      if (status is String)
        _Line(
          null,
          l10n.conflictServerStatus(requestStatusLabel(l10n, status)),
        ),
      for (final field in fields)
        _Line(
          requestFieldLabel(l10n, field),
          _show(l10n, field, server[field], zones),
          flagged: _conflictFields.contains(field),
        ),
      if (_op.operation != RequestEntity.update &&
          server['statusReason'] is Map)
        _Line(
          l10n.requestDetailReason,
          reasonLabel(l10n, '${(server['statusReason']! as Map)['code']}'),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final screen = widget.screen;
    final request = _request;
    final code = _op.lastErrorCode;
    final reason = errorMessageForCode(l10n, code) ?? l10n.errorUnknown;

    final isUpdate = _op.operation == RequestEntity.update;
    final isCreate = _op.operation == RequestEntity.create;
    final canRedo =
        isUpdate && code == 'CONFLIT_VERSION' && request != null && _loaded;
    final canCreateNew = isUpdate && !canRedo && request != null && _loaded;
    final changes = isUpdate
        ? Map<String, Object?>.from(
            (_op.payload['changes'] as Map?) ?? const {},
          )
        : const <String, Object?>{};

    return StreamBuilder<List<ZoneRow>>(
      stream: _zones,
      builder: (context, snapshot) {
        final zones = {
          for (final z in snapshot.data ?? const <ZoneRow>[]) z.id: z,
        };
        final yours = _yourLines(l10n, zones);
        final servers = _serverLines(l10n, zones);
        return ListView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          children: [
            Text(_op.label, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              // « La demande n'est plus complete » : une livraison annulee entre-temps a fait
              // repasser la demande a « Livree partiellement » (CA-MAT-008.8).
              _op.transitionAction == RequestEntity.receive &&
                      code == 'TRANSITION_INTERDITE'
                  ? l10n.conflictRequestNotComplete
                  : l10n.pendingReason(reason),
              style: theme.textTheme.bodyLarge,
            ),
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
                  final draft = draftFromRow(request, changes: changes);
                  if (draft != null) screen.onRedo(request, draft, _op);
                },
                child: Text(l10n.conflictRedo),
              ),
            if (canCreateNew)
              FilledButton(
                onPressed: () {
                  final draft = draftFromRow(request, changes: changes);
                  if (draft != null) screen.onCreateNew(draft, _op);
                },
                child: Text(l10n.conflictCreateNew),
              ),
            if (isCreate)
              FilledButton(
                onPressed: () {
                  final draft = draftFromCreatePayload(_op.payload);
                  if (draft != null) screen.onCorrectCreate(draft, _op);
                },
                child: Text(l10n.conflictCorrect),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _keepServer,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  AppSizes.primaryButtonHeight,
                ),
              ),
              child: Text(
                isCreate ? l10n.pendingAbandon : l10n.conflictKeepServer,
              ),
            ),
          ],
        );
      },
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
