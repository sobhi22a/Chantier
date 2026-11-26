import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/features/zones/presentation/widgets/option_chips.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Motif choisi : un code de la liste du serveur et, pour `Other`, une remarque obligatoire.
typedef ChosenReason = ({String code, String? note});

/// Feuille de choix d'un motif (refus, annulation) : liste de pastilles, remarque obligatoire
/// pour « Autre » (CA-MAT-003.4, CA-MAT-004.4). Retourne `null` si l'utilisateur renonce.
Future<ChosenReason?> showReasonSheet(
  BuildContext context, {
  required String title,
  required List<String> reasons,
  required String confirmLabel,
  required int noteMaxLength,
}) => showModalBottomSheet<ChosenReason>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (sheetContext) => _ReasonSheet(
    title: title,
    reasons: reasons,
    confirmLabel: confirmLabel,
    noteMaxLength: noteMaxLength,
  ),
);

class _ReasonSheet extends StatefulWidget {
  const _ReasonSheet({
    required this.title,
    required this.reasons,
    required this.confirmLabel,
    required this.noteMaxLength,
  });

  final String title;
  final List<String> reasons;
  final String confirmLabel;
  final int noteMaxLength;

  @override
  State<_ReasonSheet> createState() => _ReasonSheetState();
}

class _ReasonSheetState extends State<_ReasonSheet> {
  String? _code;
  final _note = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _confirm() {
    final l10n = AppLocalizations.of(context);
    final code = _code;
    if (code == null) {
      setState(() => _error = l10n.requestReasonRequired);
      return;
    }
    final note = _note.text.trim();
    if (code == 'Other' && note.isEmpty) {
      setState(() => _error = l10n.requestReasonNoteRequired);
      return;
    }
    Navigator.of(context).pop((code: code, note: note.isEmpty ? null : note));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        0,
        AppSizes.screenPadding,
        AppSizes.screenPadding + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            OptionChips<String>(
              options: widget.reasons,
              selected: _code,
              searchThreshold: 99,
              searchText: (code) => code,
              labelBuilder: (context, code, style) =>
                  Text(reasonLabel(l10n, code), style: style),
              onSelected: (code) => setState(() {
                _code = code;
                _error = null;
              }),
            ),
            if (_code == 'Other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                maxLength: widget.noteMaxLength,
                decoration: InputDecoration(
                  labelText: l10n.requestReasonNoteLabel,
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _confirm, child: Text(widget.confirmLabel)),
          ],
        ),
      ),
    );
  }
}
