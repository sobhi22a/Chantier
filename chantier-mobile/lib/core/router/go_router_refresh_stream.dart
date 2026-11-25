import 'dart:async';

import 'package:flutter/foundation.dart';

/// Fait reevaluer la redirection de GoRouter a chaque emission d'un flux (etat
/// d'authentification), comme `GoRouterRefreshStream` de Kardinal.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
