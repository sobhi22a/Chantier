import 'dart:async';

/// Combine deux flux : emet `combiner(a, b)` des que **chacun** a emis une premiere valeur, puis a
/// chaque nouvelle valeur de l'un ou de l'autre. Aucune dependance supplementaire (pas de `rxdart`).
///
/// Les abonnements aux flux sources naissent a l'ecoute et sont annules a la fin de l'ecoute.
Stream<R> combineLatest2<A, B, R>(
  Stream<A> first,
  Stream<B> second,
  R Function(A a, B b) combiner,
) {
  late StreamController<R> controller;
  StreamSubscription<A>? firstSubscription;
  StreamSubscription<B>? secondSubscription;
  A? latestFirst;
  B? latestSecond;
  var hasFirst = false;
  var hasSecond = false;
  var openSources = 2;

  void emit() {
    if (hasFirst && hasSecond && !controller.isClosed) {
      controller.add(combiner(latestFirst as A, latestSecond as B));
    }
  }

  void sourceDone() {
    openSources--;
    if (openSources == 0 && !controller.isClosed) unawaited(controller.close());
  }

  controller = StreamController<R>(
    onListen: () {
      firstSubscription = first.listen(
        (value) {
          latestFirst = value;
          hasFirst = true;
          emit();
        },
        onError: controller.addError,
        onDone: sourceDone,
      );
      secondSubscription = second.listen(
        (value) {
          latestSecond = value;
          hasSecond = true;
          emit();
        },
        onError: controller.addError,
        onDone: sourceDone,
      );
    },
    onCancel: () async {
      await firstSubscription?.cancel();
      await secondSubscription?.cancel();
    },
  );
  return controller.stream;
}

/// Combine autant de flux que voulu : emet `combiner(valeurs)` des que **chacun** a emis une
/// premiere valeur, puis a chaque nouvelle valeur de l'un d'eux. [values] suit l'ordre de
/// [sources].
Stream<R> combineLatestAll<R>(
  List<Stream<Object?>> sources,
  R Function(List<Object?> values) combiner,
) {
  late StreamController<R> controller;
  final subscriptions = <StreamSubscription<Object?>>[];
  final latest = List<Object?>.filled(sources.length, null);
  final received = List<bool>.filled(sources.length, false);
  var openSources = sources.length;

  controller = StreamController<R>(
    onListen: () {
      for (var index = 0; index < sources.length; index++) {
        subscriptions.add(
          sources[index].listen(
            (value) {
              latest[index] = value;
              received[index] = true;
              if (received.every((ok) => ok) && !controller.isClosed) {
                controller.add(combiner(List<Object?>.of(latest)));
              }
            },
            onError: controller.addError,
            onDone: () {
              openSources--;
              if (openSources == 0 && !controller.isClosed) {
                unawaited(controller.close());
              }
            },
          ),
        );
      }
    },
    onCancel: () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    },
  );
  return controller.stream;
}

/// Limite la cadence d'un flux : la **premiere** valeur passe tout de suite, puis, pendant [window],
/// les suivantes sont regroupees et seule la **derniere** est emise a la fin de la fenetre. Pendant
/// une premiere synchronisation (35 pages ecrites a la suite), une liste ouverte ne se recompose
/// qu'une fois par fenetre au lieu de 35 fois (R2-07). [window] nul : flux inchange.
Stream<T> throttleLatest<T>(Stream<T> source, Duration window) {
  if (window == Duration.zero) return source;
  late StreamController<T> controller;
  StreamSubscription<T>? subscription;
  Timer? timer;
  T? pending;
  var hasPending = false;

  void release() {
    timer = null;
    if (hasPending && !controller.isClosed) {
      final value = pending as T;
      hasPending = false;
      pending = null;
      controller.add(value);
      timer = Timer(window, release);
    }
  }

  controller = StreamController<T>(
    onListen: () {
      subscription = source.listen(
        (value) {
          if (timer == null) {
            controller.add(value);
            timer = Timer(window, release);
          } else {
            pending = value;
            hasPending = true;
          }
        },
        onError: controller.addError,
        onDone: () {
          timer?.cancel();
          if (hasPending && !controller.isClosed) {
            controller.add(pending as T);
          }
          unawaited(controller.close());
        },
      );
    },
    onCancel: () async {
      timer?.cancel();
      await subscription?.cancel();
    },
  );
  return controller.stream;
}
