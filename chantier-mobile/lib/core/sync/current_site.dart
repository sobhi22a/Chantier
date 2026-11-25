import 'dart:async';

import 'package:chantier_mobile/core/utils/collation.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/user_prefs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentSiteState extends Equatable {
  const CurrentSiteState({
    this.site,
    this.sites = const [],
    this.loaded = false,
    this.removed = false,
  });

  /// Chantier courant (CA-010), `null` tant qu'il n'est pas choisi.
  final SiteRow? site;

  /// Chantiers affectes (hors archives), proposes au choix.
  final List<SiteRow> sites;

  int get siteCount => sites.length;

  /// Les chantiers et la preference ont ete lus au moins une fois.
  final bool loaded;

  /// Le chantier courant n'est plus affecte (ou archive) : message + nouveau choix (CA-010.4).
  final bool removed;

  String? get siteId => site?.id;

  /// Plusieurs chantiers et aucun courant : choisir avant toute saisie (CA-010.2).
  bool get needsChoice => loaded && site == null && siteCount > 0;

  @override
  List<Object?> get props => [site, sites, loaded, removed];
}

/// Chantier courant **par utilisateur** (CA-010.5), memorise localement (`user_prefs`) : change en
/// 2 gestes, meme sans reseau (CA-010.3).
///
/// * un seul chantier affecte : il est courant des la premiere connexion (CA-010.2) ;
/// * le chantier courant disparait apres une synchronisation (retrait d'affectation, archivage) :
///   il n'est plus courant, `removed` previent l'utilisateur et un nouveau choix est exige ;
/// * jamais repris par un autre compte : les preferences sont purgees a la deconnexion.
class CurrentSiteCubit extends Cubit<CurrentSiteState> {
  CurrentSiteCubit({required AppDatabase database, required String userId})
    : _db = database,
      _userId = userId,
      super(const CurrentSiteState()) {
    _subscriptions.addAll([
      database.sitesDao.watchSites().listen((sites) {
        _sites = sites;
        _sitesLoaded = true;
        unawaited(_recompute());
      }),
      database.userPrefsDao.watch(userId, UserPrefKeys.currentSiteId).listen((
        value,
      ) {
        _storedId = value;
        _prefLoaded = true;
        unawaited(_recompute());
      }),
    ]);
  }

  final AppDatabase _db;
  final String _userId;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  List<SiteRow> _sites = const [];
  String? _storedId;
  bool _sitesLoaded = false;
  bool _prefLoaded = false;
  bool _removed = false;

  /// Ouvrir un chantier le rend courant (CA-010.1).
  Future<void> select(String siteId) async {
    _removed = false;
    await _db.userPrefsDao.set(_userId, UserPrefKeys.currentSiteId, siteId);
  }

  /// Le message « chantier retire » a ete lu.
  void acknowledgeRemoved() {
    _removed = false;
    unawaited(_recompute());
  }

  Future<void> _recompute() async {
    if (isClosed || !_sitesLoaded || !_prefLoaded) return;
    final stored = _storedId;
    SiteRow? current;
    for (final site in _sites) {
      if (site.id == stored) current = site;
    }

    if (stored != null && current == null) {
      // Plus affecte (pierre tombale) ou archive : on oublie ce choix et on previent.
      _removed = true;
      await _db.userPrefsDao.remove(_userId, UserPrefKeys.currentSiteId);
      return; // l'effacement relance ce calcul
    }
    if (stored == null && _sites.length == 1) {
      // Un seul chantier : courant des la premiere connexion.
      await _db.userPrefsDao.set(
        _userId,
        UserPrefKeys.currentSiteId,
        _sites.single.id,
      );
      return;
    }
    if (isClosed) return;
    emit(
      CurrentSiteState(
        site: current,
        sites: [..._sites]..sort((a, b) => compareHuman(a.name, b.name)),
        loaded: true,
        removed: _removed,
      ),
    );
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
