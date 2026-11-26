import 'dart:async';

import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/history_tile.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Historique d'une demande ou d'une livraison, **lu a la demande** (R2-02) : la synchronisation
/// n'envoie plus l'historique. Avec reseau il se charge ; sans reseau (ou si le serveur refuse) :
/// « Historique indisponible hors ligne », jamais une page vide ni une erreur technique. Il n'est
/// jamais ecrit en base.
///
/// * [loader] : lecture en ligne (`null` : seulement [localJson], cas d'un test ou d'un ecran
///   sans acces reseau) ;
/// * [localJson] : evenements deja presents sur le telephone (ancien format de synchronisation) ;
///   affiches s'ils existent et que la lecture en ligne echoue ;
/// * [reloadKey] : l'historique est relu quand la ressource change (nouvelle version) ;
/// * [loadable] : faux pour une saisie jamais envoyee (le serveur ne la connait pas encore).
class HistorySection extends StatefulWidget {
  const HistorySection({
    required this.localJson,
    this.loader,
    this.reloadKey,
    this.loadable = true,
    super.key,
  });

  final String? localJson;
  final Future<String?> Function()? loader;
  final Object? reloadKey;
  final bool loadable;

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

enum _Phase { loading, loaded, unavailable }

class _HistorySectionState extends State<HistorySection> {
  _Phase _phase = _Phase.loading;
  List<RequestHistoryEvent> _events = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(HistorySection old) {
    super.didUpdateWidget(old);
    if (old.reloadKey != widget.reloadKey) unawaited(_load());
  }

  Future<void> _load() async {
    final local = parseHistory(widget.localJson);
    final loader = widget.loader;
    if (loader == null || !widget.loadable) {
      _set(_Phase.loaded, local);
      return;
    }
    if (_events.isEmpty && local.isNotEmpty) _set(_Phase.loading, local);
    try {
      final text = await loader();
      _set(_Phase.loaded, parseHistory(text));
    } on ApiException {
      // Hors ligne (ou refus) : ce que le telephone sait deja, sinon « indisponible ».
      _set(
        local.isEmpty && _events.isEmpty ? _Phase.unavailable : _Phase.loaded,
        local.isNotEmpty ? local : _events,
      );
    }
  }

  void _set(_Phase phase, List<RequestHistoryEvent> events) {
    if (!mounted) return;
    setState(() {
      _phase = phase;
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final showTitle =
        _events.isNotEmpty ||
        _phase == _Phase.unavailable ||
        (_phase == _Phase.loading && widget.loader != null && widget.loadable);
    if (!showTitle) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.requestDetailHistory, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_phase == _Phase.loading && _events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          if (_phase == _Phase.unavailable)
            Row(
              children: [
                const Icon(Icons.cloud_off, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.historyUnavailableOffline,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          for (final event in _events) HistoryTile(event: event),
        ],
      ),
    );
  }
}
