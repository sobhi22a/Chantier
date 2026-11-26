import 'dart:async';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsState extends Equatable {
  const RequestsState({
    this.all = const [],
    this.view = RequestListView.toFollow,
    this.mineOnly = false,
    this.query = '',
    this.loaded = false,
  });

  /// Toutes les demandes du chantier, saisies en attente comprises (surcouche).
  final List<RequestView> all;
  final RequestListView view;

  /// « Mes demandes » : seulement celles de l'utilisateur.
  final bool mineOnly;
  final String query;
  final bool loaded;

  /// Nombre de demandes a verifier (saisie refusee ou en conflit), pour le bandeau.
  int get needsCheckCount => all.where((item) => item.needsCheck).length;

  RequestsState copyWith({
    List<RequestView>? all,
    RequestListView? view,
    bool? mineOnly,
    String? query,
    bool? loaded,
  }) => RequestsState(
    all: all ?? this.all,
    view: view ?? this.view,
    mineOnly: mineOnly ?? this.mineOnly,
    query: query ?? this.query,
    loaded: loaded ?? this.loaded,
  );

  @override
  List<Object?> get props => [all, view, mineOnly, query, loaded];
}

/// Liste des demandes d'un chantier, lue dans la base locale (jamais le reseau).
///
/// [mineOnly] initial : « Mes demandes » par defaut pour un chef d'equipe (CA-MAT-002.2).
class RequestsCubit extends Cubit<RequestsState> {
  RequestsCubit({
    required MaterialsRepository repository,
    required String siteId,
    required this.userId,
    bool mineOnly = false,
    RequestListView view = RequestListView.toFollow,
  }) : super(RequestsState(mineOnly: mineOnly, view: view)) {
    _subscription = repository.watchRequests(siteId, userId).listen((items) {
      if (!isClosed) emit(state.copyWith(all: items, loaded: true));
    });
  }

  final String userId;
  late final StreamSubscription<List<RequestView>> _subscription;

  void selectView(RequestListView view) => emit(state.copyWith(view: view));

  void setMineOnly({required bool value}) =>
      emit(state.copyWith(mineOnly: value));

  void search(String query) => emit(state.copyWith(query: query));

  /// Demandes de la vue choisie, filtrees et triees.
  List<RequestView> visible(String languageCode) => filterRequests(
    state.all,
    view: state.view,
    languageCode: languageCode,
    mineUserId: state.mineOnly ? userId : null,
    query: state.query,
  );

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

/// Une demande et ses saisies en attente (detail).
class RequestDetailState extends Equatable {
  const RequestDetailState({this.view, this.loaded = false});

  /// `null` apres lecture : demande absente du telephone.
  final RequestView? view;
  final bool loaded;

  @override
  List<Object?> get props => [view, loaded];
}

class RequestDetailCubit extends Cubit<RequestDetailState> {
  RequestDetailCubit({
    required MaterialsRepository repository,
    required String requestId,
    required String userId,
  }) : super(const RequestDetailState()) {
    _subscription = repository.watchRequest(requestId, userId).listen((view) {
      if (!isClosed) emit(RequestDetailState(view: view, loaded: true));
    });
  }

  late final StreamSubscription<RequestView?> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

/// Zones d'un chantier par identifiant (affichage « Bloc 01 · +3,40 m · Classe 07 »).
Map<String, ZoneRow> zonesById(Iterable<ZoneRow> zones) => {
  for (final zone in zones) zone.id: zone,
};
