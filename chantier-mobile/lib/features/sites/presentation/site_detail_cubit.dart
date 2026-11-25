import 'dart:async';

import 'package:chantier_mobile/core/utils/collation.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SiteDetailState extends Equatable {
  const SiteDetailState({
    this.site,
    this.zones = const [],
    this.members = const [],
    this.loaded = false,
  });

  /// `null` apres lecture : chantier absent du telephone (introuvable, CA-007.7).
  final SiteRow? site;
  final List<ZoneRow> zones;
  final List<SiteMemberRow> members;
  final bool loaded;

  @override
  List<Object?> get props => [site, zones, members, loaded];
}

/// Fiche d'un chantier : toute la fiche vient de la base locale, donc disponible hors ligne
/// (CA-007.5).
class SiteDetailCubit extends Cubit<SiteDetailState> {
  SiteDetailCubit({required SitesRepository repository, required String siteId})
    : super(const SiteDetailState()) {
    _subscriptions.addAll([
      repository.watchSite(siteId).listen((value) {
        _site = value;
        _loaded = true;
        _publish();
      }),
      repository.watchZones(siteId).listen((value) {
        _zones = value;
        _publish();
      }),
      repository.watchMembers(siteId).listen((value) {
        _members = value;
        _publish();
      }),
    ]);
  }

  final List<StreamSubscription<Object?>> _subscriptions = [];
  SiteRow? _site;
  List<ZoneRow> _zones = const [];
  List<SiteMemberRow> _members = const [];
  var _loaded = false;

  void _publish() {
    if (isClosed) return;
    emit(
      SiteDetailState(
        site: _site,
        zones: _zones,
        members: [..._members]
          ..sort((a, b) => compareHuman(a.fullName, b.fullName)),
        loaded: _loaded,
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
