import 'dart:async';

import 'package:chantier_mobile/core/utils/collation.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SitesState extends Equatable {
  const SitesState({
    this.sites = const [],
    this.totalCount = 0,
    this.query = '',
    this.showArchived = false,
    this.loaded = false,
  });

  /// Chantiers a afficher (filtres par la recherche).
  final List<SiteRow> sites;

  /// Chantiers avant la recherche : decide si le champ de recherche est utile.
  final int totalCount;
  final String query;
  final bool showArchived;
  final bool loaded;

  /// Recherche proposee au-dela de 5 chantiers (plan M7, CA-006.6).
  bool get showSearch => totalCount > 5;

  @override
  List<Object?> get props => [sites, totalCount, query, showArchived, loaded];
}

/// « Mes chantiers » : lecture **uniquement** depuis la base locale (flux Drift), jamais le reseau.
/// Archives masques par defaut (CA-006.8) ; recherche par nom (francais ou arabe) ou code.
class SitesCubit extends Cubit<SitesState> {
  SitesCubit(this._repository) : super(const SitesState()) {
    _listen();
  }

  final SitesRepository _repository;
  StreamSubscription<List<SiteRow>>? _subscription;
  List<SiteRow> _all = const [];
  var _query = '';
  var _showArchived = false;
  var _loaded = false;

  void _listen() {
    unawaited(_subscription?.cancel());
    _subscription = _repository
        .watchSites(includeArchived: _showArchived)
        .listen((sites) {
          _all = sites;
          _loaded = true;
          _publish();
        });
  }

  void setQuery(String query) {
    _query = query;
    _publish();
  }

  void setShowArchived({required bool value}) {
    if (_showArchived == value) return;
    _showArchived = value;
    _listen();
  }

  void _publish() {
    if (isClosed) return;
    final needle = _query.trim().toLowerCase();
    final filtered = needle.isEmpty
        ? _all
        : [
            for (final site in _all)
              if (site.name.toLowerCase().contains(needle) ||
                  (site.nameAr ?? '').toLowerCase().contains(needle) ||
                  site.code.toLowerCase().contains(needle))
                site,
          ];
    // Tri « lecture humaine » (accents ignores) : SQLite ne sait plier que l'ASCII.
    final sorted = [...filtered]..sort((a, b) => compareHuman(a.name, b.name));
    emit(
      SitesState(
        sites: sorted,
        totalCount: _all.length,
        query: _query,
        showArchived: _showArchived,
        loaded: _loaded,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
