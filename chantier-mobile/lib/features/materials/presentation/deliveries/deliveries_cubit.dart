import 'dart:async';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/data/deliveries_repository.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_listing.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveriesState extends Equatable {
  const DeliveriesState({
    this.all = const [],
    this.filter = DeliveryListFilter.all,
    this.query = '',
    this.loaded = false,
  });

  /// Toutes les livraisons du chantier, saisies en attente comprises (surcouche).
  final List<DeliveryView> all;
  final DeliveryListFilter filter;
  final String query;
  final bool loaded;

  DeliveriesState copyWith({
    List<DeliveryView>? all,
    DeliveryListFilter? filter,
    String? query,
    bool? loaded,
  }) => DeliveriesState(
    all: all ?? this.all,
    filter: filter ?? this.filter,
    query: query ?? this.query,
    loaded: loaded ?? this.loaded,
  );

  @override
  List<Object?> get props => [all, filter, query, loaded];
}

/// Liste des livraisons d'un chantier, lue dans la base locale (jamais le reseau).
class DeliveriesCubit extends Cubit<DeliveriesState> {
  DeliveriesCubit({
    required DeliveriesRepository repository,
    required String siteId,
    required String userId,
    DeliveryListFilter filter = DeliveryListFilter.all,
  }) : super(DeliveriesState(filter: filter)) {
    _subscription = repository.watchDeliveries(siteId, userId).listen((items) {
      if (!isClosed) emit(state.copyWith(all: items, loaded: true));
    });
  }

  late final StreamSubscription<List<DeliveryView>> _subscription;

  void selectFilter(DeliveryListFilter filter) =>
      emit(state.copyWith(filter: filter));

  void search(String query) => emit(state.copyWith(query: query));

  List<DeliveryView> visible(String languageCode) => filterDeliveries(
    state.all,
    filter: state.filter,
    languageCode: languageCode,
    query: state.query,
  );

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

/// Une livraison, ses saisies en attente et ses photos (detail).
class DeliveryDetailState extends Equatable {
  const DeliveryDetailState({
    this.view,
    this.photos = const [],
    this.loaded = false,
  });

  /// `null` apres lecture : livraison absente du telephone.
  final DeliveryView? view;
  final List<DeliveryPhotoRow> photos;
  final bool loaded;

  @override
  List<Object?> get props => [view, photos, loaded];
}

class DeliveryDetailCubit extends Cubit<DeliveryDetailState> {
  DeliveryDetailCubit({
    required DeliveriesRepository repository,
    required String deliveryId,
    required String userId,
  }) : super(const DeliveryDetailState()) {
    _view = repository.watchDelivery(deliveryId, userId).listen((view) {
      if (!isClosed) {
        emit(
          DeliveryDetailState(view: view, photos: state.photos, loaded: true),
        );
      }
    });
    _photos = repository.watchPhotos(deliveryId).listen((photos) {
      if (!isClosed) {
        emit(
          DeliveryDetailState(
            view: state.view,
            photos: photos,
            loaded: state.loaded,
          ),
        );
      }
    });
  }

  late final StreamSubscription<DeliveryView?> _view;
  late final StreamSubscription<List<DeliveryPhotoRow>> _photos;

  @override
  Future<void> close() async {
    await _view.cancel();
    await _photos.cancel();
    return super.close();
  }
}
