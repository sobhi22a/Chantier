import 'dart:convert';

import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:chantier_mobile/database/converters/material_json_guard.dart';

/// Historique d'une demande ou d'une livraison, lu **a la demande** (R2-02) : la synchronisation
/// n'envoie plus `history[]` (toujours vide), le detail le lit par `GET /requests/{id}` et
/// `GET /deliveries/{id}` quand le reseau est la.
abstract interface class HistorySource {
  /// Historique **assaini** (jamais un prix : evenement sensible et champs commerciaux retires,
  /// ADR 0012) sous forme de texte JSON, ou `null` si la ressource n'en renvoie pas. Leve une
  /// `ApiException` typee (reseau, session...).
  Future<String?> requestHistory(String siteId, String requestId);

  Future<String?> deliveryHistory(String siteId, String deliveryId);

  /// Vide la copie gardee en memoire (deconnexion, changement de compte).
  void clear();
}

/// Lecture par le client HTTP de l'application. Le corps est lu **tel quel** (pas par les modeles
/// generes : un statut de depart absent y est refuse). Rien n'est ecrit en base : une copie en
/// memoire seulement, jamais synchronisee, sert de secours quand le reseau manque ensuite.
class HistoryRemoteSource implements HistorySource {
  HistoryRemoteSource(this._client);

  final DioClient _client;
  final Map<String, String?> _memory = {};

  @override
  Future<String?> requestHistory(String siteId, String requestId) =>
      _read('/sites/$siteId/requests/$requestId', 'request:$requestId');

  @override
  Future<String?> deliveryHistory(String siteId, String deliveryId) =>
      _read('/sites/$siteId/deliveries/$deliveryId', 'delivery:$deliveryId');

  Future<String?> _read(String path, String key) async {
    final Map<String, dynamic>? data;
    try {
      data = (await _client.get<Map<String, dynamic>>(path)).data;
    } on ApiException catch (error) {
      // Plus de reseau : la copie lue plus tot pendant cette session, sinon l'erreur.
      if ((error is NetworkApiException || error is TimeoutApiException) &&
          _memory.containsKey(key)) {
        return _memory[key];
      }
      rethrow;
    }
    final history = data?['history'];
    final text = history is List
        ? MaterialJsonGuard.sanitizeHistory(jsonEncode(history))
        : null;
    _memory[key] = text;
    return text;
  }

  @override
  void clear() => _memory.clear();
}
