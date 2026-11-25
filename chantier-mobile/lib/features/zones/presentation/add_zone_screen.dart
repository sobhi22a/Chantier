import 'dart:async';
import 'dart:convert';

import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/utils/client_id.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:chantier_mobile/features/zones/domain/zone_format.dart';
import 'package:chantier_mobile/features/zones/domain/zone_rules.dart';
import 'package:chantier_mobile/features/zones/presentation/widgets/option_chips.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _ElevationMode { chip, custom, none }

/// « Ajouter une zone » (US-SOCLE-011), **hors ligne** : bloc et cote preselectionnes (derniere
/// zone utilisee), type de local en pastilles, numero avec « + / − », « Enregistrer ».
/// 5 gestes depuis « Mes chantiers », moins de 30 s (CA-011.1).
///
/// Le `clientId` est cree a l'ouverture du formulaire ; le bouton est inactif des l'appui
/// (anti-doublon, CA-011.4).
class AddZoneScreen extends StatefulWidget {
  const AddZoneScreen({
    required this.siteId,
    required this.userId,
    required this.repository,
    this.replacing,
    super.key,
  });

  final String siteId;
  final String userId;
  final ZonesRepository repository;

  /// « Corriger » : l'operation refusee a remplacer ; le formulaire reprend ses valeurs.
  final OutboxRow? replacing;

  @override
  State<AddZoneScreen> createState() => _AddZoneScreenState();
}

class _AddZoneScreenState extends State<AddZoneScreen> {
  /// Cree a l'ouverture du formulaire, jamais a l'envoi.
  final String _clientId = generateClientId();

  List<ZoneRow> _zones = const [];
  bool _loaded = false;
  bool _saving = false;

  String? _block;
  bool _newBlock = false;
  final _blockController = TextEditingController();

  _ElevationMode _elevationMode = _ElevationMode.chip;
  Decimal? _elevation;
  final _elevationController = TextEditingController();
  String? _elevationError;

  String? _roomType;
  int _roomNumber = 1;
  bool _numberTouched = false;
  final _roomLabelController = TextEditingController();
  String? _roomLabelError;
  String? _blockError;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _blockController.dispose();
    _elevationController.dispose();
    _roomLabelController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final zones = await widget.repository.watchZones(widget.siteId).first;
    final replacing = widget.replacing;
    final last = replacing == null
        ? await widget.repository.lastUsedZone(widget.userId)
        : null;
    if (!mounted) return;
    setState(() {
      _zones = zones;
      _loaded = true;
      if (replacing != null) {
        _applyPayload(replacing);
      } else if (last != null && last.siteId == widget.siteId) {
        // Derniere zone utilisee : bloc et cote preselectionnes (CA-011.1).
        _block = last.block;
        _elevation = last.elevation;
        _elevationMode = last.elevation == null
            ? _ElevationMode.none
            : _ElevationMode.chip;
      } else if (zones.isNotEmpty) {
        _block = zones.first.block;
        _elevation = zones.first.elevation;
        _elevationMode = zones.first.elevation == null
            ? _ElevationMode.none
            : _ElevationMode.chip;
      } else {
        _newBlock = true;
        _elevationMode = _ElevationMode.custom;
      }
      _roomNumber = _nextRoomNumber();
    });
  }

  /// « Corriger » : reprend les valeurs de la saisie refusee.
  void _applyPayload(OutboxRow row) {
    final payload = Map<String, Object?>.from(
      jsonDecode(row.payloadJson) as Map,
    );
    final block = payload['block'] as String?;
    if (block != null) {
      if (_zones.any((z) => z.block == block)) {
        _block = block;
      } else {
        _newBlock = true;
        _blockController.text = block;
      }
    }
    final elevation = payload['elevation'];
    if (elevation is num) {
      _elevation = Decimal.parse(elevation.toStringAsFixed(2));
      final known = _zones.any(
        (z) => z.block == block && z.elevation == _elevation,
      );
      if (known) {
        _elevationMode = _ElevationMode.chip;
      } else {
        _elevationMode = _ElevationMode.custom;
        _elevationController.text = _elevation!
            .toStringAsFixed(2)
            .replaceAll('.', ',');
      }
    } else {
      _elevationMode = _ElevationMode.none;
    }
    _roomType = payload['roomType'] as String?;
    _roomNumber = (payload['roomNumber'] as int?) ?? 1;
    _numberTouched = true;
    _roomLabelController.text = (payload['roomLabel'] as String?) ?? '';
  }

  /// Numero suivant libre pour (bloc, cote, type) : souvent aucun reglage a faire (5 gestes).
  int _nextRoomNumber() {
    if (_roomType == null) return 1;
    final used = [
      for (final z in _zones)
        if (z.block == _effectiveBlock &&
            z.elevation == _effectiveElevation &&
            z.roomType == _roomType &&
            z.roomNumber != null)
          z.roomNumber!,
    ];
    return used.isEmpty ? 1 : used.reduce((a, b) => a > b ? a : b) + 1;
  }

  String? get _effectiveBlock =>
      _newBlock ? _blockController.text.trim() : _block;

  Decimal? get _effectiveElevation => switch (_elevationMode) {
    _ElevationMode.chip => _elevation,
    _ElevationMode.none => null,
    _ElevationMode.custom => ZoneRules.parseElevation(
      _elevationController.text,
    ).value,
  };

  void _refreshNumber() {
    if (!_numberTouched) _roomNumber = _nextRoomNumber();
  }

  List<String> get _blocks => [
    for (final block in {for (final z in _zones) z.block}) block,
  ];

  List<Decimal> get _elevations {
    final values = {
      for (final z in _zones)
        if (z.block == _block && z.elevation != null) z.elevation!,
    }.toList()..sort();
    return values;
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final block = _effectiveBlock ?? '';
    String? blockError;
    String? elevationError;
    String? labelError;
    Decimal? elevation;

    if (block.isEmpty || block.length > ZoneRules.blockMaxLength) {
      blockError = l10n.zoneBlockRequired;
    }
    switch (_elevationMode) {
      case _ElevationMode.chip:
        elevation = _elevation;
      case _ElevationMode.none:
        elevation = null;
      case _ElevationMode.custom:
        final parsed = ZoneRules.parseElevation(_elevationController.text);
        elevation = parsed.value;
        elevationError = switch (parsed.problem) {
          null => null,
          ElevationProblem.invalid => l10n.zoneElevationInvalid,
          ElevationProblem.outOfRange => l10n.zoneElevationOutOfRange(
            ZoneRules.minLabel,
            ZoneRules.maxLabel,
          ),
        };
    }
    final roomLabel = _roomLabelController.text.trim();
    if (_roomType == 'Other' && roomLabel.isEmpty) {
      labelError = l10n.zoneRoomLabelRequired;
    }

    if (blockError != null || elevationError != null || labelError != null) {
      setState(() {
        _blockError = blockError;
        _elevationError = elevationError;
        _roomLabelError = labelError;
      });
      unawaited(HapticFeedback.heavyImpact());
      return;
    }

    // Bouton inactif des l'appui : un second appui ne part pas (anti-doublon).
    setState(() {
      _saving = true;
      _blockError = _elevationError = _roomLabelError = null;
    });

    final preview = ZoneRow(
      id: _clientId,
      siteId: widget.siteId,
      block: block,
      elevation: elevation,
      roomType: _roomType,
      // Pas de numero sans local, ni pour « Autre » (libelle libre a la place).
      roomNumber: (_roomType == null || _roomType == 'Other')
          ? null
          : _roomNumber,
      roomLabel: _roomType == 'Other' ? roomLabel : null,
      version: 0,
      isPending: true,
      createdAt: DateTime.now().toUtc(),
    );
    final result = await widget.repository.save(
      NewZone(
        clientId: _clientId,
        siteId: widget.siteId,
        userId: widget.userId,
        block: block,
        elevation: elevation,
        roomType: preview.roomType,
        roomNumber: preview.roomNumber,
        roomLabel: preview.roomLabel,
        label: zoneLabel(l10n, preview),
      ),
      replacing: widget.replacing,
    );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case ZoneSaved():
        unawaited(HapticFeedback.mediumImpact());
        messenger.showSnackBar(SnackBar(content: Text(l10n.zoneSavedPending)));
        Navigator.of(context).pop(true);
      case ZoneAlreadyExists(:final existing):
        // Doublon : on ouvre la zone existante, aucune saisie en double (CA-011.4).
        unawaited(HapticFeedback.heavyImpact());
        await widget.repository.rememberZone(widget.userId, existing.id);
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.zoneExists)));
        Navigator.of(context).pop(false);
      case ZoneAlreadySaved():
        Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.zoneAddTitle)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          section(l10n.zoneBlock, _blockSection(l10n)),
                          section(l10n.zoneElevation, _elevationSection(l10n)),
                          section(l10n.zoneRoomType, _roomSection(l10n)),
                          if (_roomType != null && _roomType != 'Other')
                            section(l10n.zoneRoomNumber, _numberStepper(l10n)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Text(l10n.zoneSave),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _blockSection(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OptionChips<String>(
        options: _blocks,
        selected: _newBlock ? null : _block,
        searchHint: l10n.zoneSearchHint,
        searchText: (b) => b,
        labelBuilder: (context, block, style) => LtrText(block, style: style),
        onSelected: (block) => setState(() {
          _block = block;
          _newBlock = false;
          _elevation = null;
          _elevationMode = _ElevationMode.chip;
          _refreshNumber();
        }),
        trailing: [
          OptionChip(
            selected: _newBlock,
            onSelected: () => setState(() {
              _newBlock = true;
              _refreshNumber();
            }),
            child: (style) => Text(l10n.zoneBlockNew, style: style),
          ),
        ],
      ),
      if (_newBlock) ...[
        const SizedBox(height: 12),
        TextField(
          controller: _blockController,
          maxLength: ZoneRules.blockMaxLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.zoneBlockNewLabel,
            errorText: _blockError,
          ),
          onChanged: (_) => setState(_refreshNumber),
        ),
      ] else if (_blockError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _blockError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
    ],
  );

  Widget _elevationSection(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OptionChips<Decimal>(
        options: _newBlock ? const [] : _elevations,
        selected: _elevationMode == _ElevationMode.chip ? _elevation : null,
        searchHint: l10n.zoneSearchHint,
        searchText: signedElevation,
        labelBuilder: (context, value, style) =>
            LtrText(elevationWithUnit(value), style: style),
        onSelected: (value) => setState(() {
          _elevation = value;
          _elevationMode = _ElevationMode.chip;
          _elevationError = null;
          _refreshNumber();
        }),
        trailing: [
          OptionChip(
            selected: _elevationMode == _ElevationMode.custom,
            onSelected: () => setState(() {
              _elevationMode = _ElevationMode.custom;
              _refreshNumber();
            }),
            child: (style) => Text(l10n.zoneElevationOther, style: style),
          ),
          OptionChip(
            selected: _elevationMode == _ElevationMode.none,
            onSelected: () => setState(() {
              _elevationMode = _ElevationMode.none;
              _elevationError = null;
              _refreshNumber();
            }),
            child: (style) => Text(l10n.zoneElevationNone, style: style),
          ),
        ],
      ),
      if (_elevationMode == _ElevationMode.custom) ...[
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _elevationController,
                // Clavier numerique decimal, avec le signe ; des lettres sont impossibles a saisir.
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,+\-−]')),
                ],
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: l10n.zoneElevationLabel,
                  // L'unite est toujours le metre : affichee, non modifiable.
                  suffixText: 'm',
                  helperText: l10n.zoneElevationHelp(
                    ZoneRules.minLabel,
                    ZoneRules.maxLabel,
                  ),
                  errorText: _elevationError,
                ),
                onChanged: (_) => setState(() {
                  _elevationError = null;
                  _refreshNumber();
                }),
              ),
            ),
            const SizedBox(width: 8),
            // Touche +/- : change le signe sans repasser par le clavier.
            IconButton.outlined(
              tooltip: '+ / −',
              icon: const Icon(Icons.exposure),
              onPressed: _toggleSign,
            ),
          ],
        ),
      ],
    ],
  );

  void _toggleSign() {
    final text = _elevationController.text.trim();
    final flipped = text.startsWith('-') || text.startsWith('−')
        ? text.substring(1)
        : '-$text';
    _elevationController.value = TextEditingValue(
      text: flipped,
      selection: TextSelection.collapsed(offset: flipped.length),
    );
    setState(() => _elevationError = null);
  }

  Widget _roomSection(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OptionChips<String>(
        options: roomTypeValues,
        selected: _roomType,
        searchThreshold: 99,
        searchText: (t) => t,
        labelBuilder: (context, type, style) =>
            Text(roomTypeLabel(l10n, type), style: style),
        onSelected: (type) => setState(() {
          _roomType = type;
          _numberTouched = false;
          _roomNumber = _nextRoomNumber();
        }),
        trailing: [
          OptionChip(
            selected: _roomType == null,
            onSelected: () => setState(() => _roomType = null),
            child: (style) => Text(l10n.zoneRoomNone, style: style),
          ),
        ],
      ),
      if (_roomType == 'Other') ...[
        const SizedBox(height: 12),
        TextField(
          controller: _roomLabelController,
          maxLength: ZoneRules.roomLabelMaxLength,
          decoration: InputDecoration(
            labelText: l10n.zoneRoomLabel,
            errorText: _roomLabelError,
          ),
          onChanged: (_) => setState(() => _roomLabelError = null),
        ),
      ],
    ],
  );

  /// Numero avec « − » et « + » de 56 dp (CA-011.1) ; chiffres 0-9, toujours de gauche a droite.
  Widget _numberStepper(AppLocalizations l10n) => Row(
    children: [
      IconButton.filledTonal(
        tooltip: l10n.zoneRoomNumberLess,
        iconSize: 32,
        constraints: const BoxConstraints.tightFor(width: 56, height: 56),
        icon: const Icon(Icons.remove),
        onPressed: _roomNumber > ZoneRules.roomNumberMin
            ? () => setState(() {
                _roomNumber--;
                _numberTouched = true;
              })
            : null,
      ),
      Expanded(
        child: Center(
          child: LtrText(
            _roomNumber.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      IconButton.filledTonal(
        tooltip: l10n.zoneRoomNumberMore,
        iconSize: 32,
        constraints: const BoxConstraints.tightFor(width: 56, height: 56),
        icon: const Icon(Icons.add),
        onPressed: _roomNumber < ZoneRules.roomNumberMax
            ? () => setState(() {
                _roomNumber++;
                _numberTouched = true;
              })
            : null,
      ),
    ],
  );
}
