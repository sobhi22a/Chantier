import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Choix par **pastilles** (un appui, sans clavier) : bloc, cote, local. Au-dela de
/// [searchThreshold] valeurs, une recherche libre apparait (CA-011.11, CA-009.4).
///
/// La pastille choisie porte une coche : l'etat n'est jamais indique par la couleur seule.
class OptionChips<T> extends StatefulWidget {
  const OptionChips({
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.searchText,
    required this.onSelected,
    this.searchHint = '',
    this.searchThreshold = 8,
    this.trailing = const [],
    super.key,
  });

  final List<T> options;
  final T? selected;

  /// Contenu d'une pastille (par exemple un `LtrText` pour une cote).
  final Widget Function(BuildContext context, T option, TextStyle style)
  labelBuilder;

  /// Texte compare a la recherche.
  final String Function(T option) searchText;
  final ValueChanged<T> onSelected;
  final String searchHint;
  final int searchThreshold;

  /// Pastilles supplementaires (« Autre cote », « Sans cote »...), toujours visibles.
  final List<Widget> trailing;

  @override
  State<OptionChips<T>> createState() => _OptionChipsState<T>();
}

class _OptionChipsState<T> extends State<OptionChips<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final tokens = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    final visible = tokens.isEmpty
        ? widget.options
        : [
            for (final option in widget.options)
              if (tokens.every(
                (t) => widget.searchText(option).toLowerCase().contains(t),
              ))
                option,
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.options.length > widget.searchThreshold)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: widget.searchHint,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in visible)
              _Chip(
                selected: option == widget.selected,
                onSelected: () => widget.onSelected(option),
                child: (style) => widget.labelBuilder(context, option, style),
              ),
            ...widget.trailing,
          ],
        ),
      ],
    );
  }
}

/// Pastille de 48 dp de haut au moins (gants), coche quand elle est choisie.
class OptionChip extends StatelessWidget {
  const OptionChip({
    required this.selected,
    required this.onSelected,
    required this.child,
    super.key,
  });

  final bool selected;
  final VoidCallback onSelected;
  final Widget Function(TextStyle style) child;

  @override
  Widget build(BuildContext context) =>
      _Chip(selected: selected, onSelected: onSelected, child: child);
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.selected,
    required this.onSelected,
    required this.child,
  });

  final bool selected;
  final VoidCallback onSelected;
  final Widget Function(TextStyle style) child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.labelLarge!;
    final style = base.copyWith(
      color: selected ? AppColors.onPrimary : AppColors.onSurface,
    );
    return ChoiceChip(
      selected: selected,
      showCheckmark: true,
      checkmarkColor: AppColors.onPrimary,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.outline, width: 1.5),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      labelPadding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: (AppSizes.minTapTarget - 24) / 2,
      ),
      label: child(style),
      onSelected: (_) => onSelected(),
    );
  }
}
