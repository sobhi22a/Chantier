import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/zones/domain/zone_format.dart';
import 'package:chantier_mobile/features/zones/presentation/widgets/option_chips.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// Selecteur de zone **reutilisable** (US-SOCLE-009) : Bloc, puis Cote, puis Local, par
/// pastilles ; la derniere zone utilisee est preselectionnee ([initial]) ; au-dela de 8 valeurs,
/// une recherche libre (« cl 02 » retrouve « Classe 02 », CA-009.4).
///
/// Il ne montre que les zones du chantier recu (jamais celles d'un autre chantier, CA-009.5) et
/// pas les zones archivees (CA-009.6) : l'appelant fournit la liste. Lecture locale, hors ligne.
class ZonePicker extends StatefulWidget {
  const ZonePicker({
    required this.zones,
    required this.onChanged,
    this.initial,
    this.allowNone = false,
    super.key,
  });

  /// Zones proposees (non archivees, d'un seul chantier).
  final List<ZoneRow> zones;
  final ZoneRow? initial;

  /// Zone facultative : propose « Non precisee » (CA-009.7).
  final bool allowNone;

  /// Appele avec la zone choisie, ou `null` pour « Non precisee ».
  final ValueChanged<ZoneRow?> onChanged;

  @override
  State<ZonePicker> createState() => _ZonePickerState();
}

class _ZonePickerState extends State<ZonePicker> {
  String? _block;
  Decimal? _elevation;
  bool _elevationChosen = false;
  ZoneRow? _zone;
  bool _none = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null && widget.zones.any((z) => z.id == initial.id)) {
      _block = initial.block;
      _elevation = initial.elevation;
      _elevationChosen = true;
      _zone = initial;
    }
  }

  void _choose(ZoneRow? zone) {
    setState(() {
      _zone = zone;
      _none = zone == null;
    });
    widget.onChanged(zone);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final blocks = [
      for (final b in {for (final z in widget.zones) z.block}) b,
    ];
    final elevations =
        {
          for (final z in widget.zones)
            if (z.block == _block) z.elevation,
        }.toList()..sort((a, b) {
          if (a == null) return -1;
          if (b == null) return 1;
          return a.compareTo(b);
        });
    final rooms = [
      for (final z in widget.zones)
        if (z.block == _block && z.elevation == _elevation) z,
    ];

    Widget title(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.zones.length > 8) ...[
          _ZoneSearch(
            zones: widget.zones,
            selected: _zone,
            onSelected: _choose,
          ),
        ],
        if (widget.allowNone)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OptionChip(
              selected: _none,
              onSelected: () => _choose(null),
              child: (style) => Text(l10n.zonePickerNone, style: style),
            ),
          ),
        title(l10n.zoneBlock),
        OptionChips<String>(
          options: blocks,
          selected: _block,
          searchHint: l10n.zoneSearchHint,
          searchText: (b) => b,
          labelBuilder: (context, block, style) => LtrText(block, style: style),
          onSelected: (block) => setState(() {
            _block = block;
            _elevation = null;
            _elevationChosen = false;
            _zone = null;
          }),
        ),
        if (_block != null) ...[
          title(l10n.zoneElevation),
          OptionChips<Decimal?>(
            options: elevations,
            selected: _elevationChosen ? _elevation : null,
            searchHint: l10n.zoneSearchHint,
            searchText: (e) => e == null ? '' : signedElevation(e),
            labelBuilder: (context, value, style) => value == null
                ? Text(l10n.zoneElevationNone, style: style)
                : LtrText(elevationWithUnit(value), style: style),
            onSelected: (value) => setState(() {
              _elevation = value;
              _elevationChosen = true;
              _zone = null;
            }),
          ),
        ],
        if (_block != null && _elevationChosen) ...[
          title(l10n.zoneRoomType),
          OptionChips<ZoneRow>(
            options: rooms,
            selected: _zone,
            searchThreshold: 8,
            searchHint: l10n.zoneSearchHint,
            searchText: (z) => roomLabelText(l10n, z) ?? '',
            labelBuilder: (context, zone, style) =>
                Text(roomLabelText(l10n, zone) ?? '—', style: style),
            onSelected: _choose,
          ),
        ],
      ],
    );
  }
}

/// Recherche libre sur le libelle complet (bloc, cote, local) : tous les mots doivent y figurer.
class _ZoneSearch extends StatefulWidget {
  const _ZoneSearch({
    required this.zones,
    required this.selected,
    required this.onSelected,
  });

  final List<ZoneRow> zones;
  final ZoneRow? selected;
  final ValueChanged<ZoneRow> onSelected;

  @override
  State<_ZoneSearch> createState() => _ZoneSearchState();
}

class _ZoneSearchState extends State<_ZoneSearch> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    final results = tokens.isEmpty
        ? const <ZoneRow>[]
        : [
            for (final zone in widget.zones)
              if (tokens.every(
                (t) => zoneLabel(l10n, zone).toLowerCase().contains(t),
              ))
                zone,
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l10n.zoneSearchHint,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        if (tokens.isNotEmpty && results.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Text(l10n.zonePickerNoResult),
          ),
        for (final zone in results.take(20))
          ListTile(
            minTileHeight: 56,
            selected: zone.id == widget.selected?.id,
            title: Text(zoneLabelForDisplay(l10n, zone)),
            trailing: zone.id == widget.selected?.id
                ? const Icon(Icons.check)
                : null,
            onTap: () => widget.onSelected(zone),
          ),
      ],
    );
  }
}

/// Ouvre le selecteur dans une feuille : « Valider » renvoie la zone choisie, ou `null` si rien
/// n'a ete choisi ou si l'utilisateur ferme la feuille.
Future<ZoneRow?> showZonePicker(
  BuildContext context, {
  required List<ZoneRow> zones,
  ZoneRow? initial,
  bool allowNone = false,
}) {
  return showModalBottomSheet<ZoneRow>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      ZoneRow? chosen = initial;
      return StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.zonePickerTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: ZonePicker(
                      zones: zones,
                      initial: initial,
                      allowNone: allowNone,
                      onChanged: (zone) => setState(() => chosen = zone),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  // Pour rester sur la meme zone : un seul geste, « Valider » (CA-009.1).
                  onPressed: () => Navigator.of(sheetContext).pop(chosen),
                  child: Text(l10n.zonePickerConfirm),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
