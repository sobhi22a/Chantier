import 'package:chantier_mobile/core/storage/token_pair.dart';
import 'package:chantier_mobile/core/storage/token_store.dart';

/// Stockage de jetons en memoire pour les tests.
class MemoryTokenStore implements TokenStore {
  MemoryTokenStore([this._tokens]);

  TokenPair? _tokens;
  int saveCount = 0;
  int clearCount = 0;

  TokenPair? get current => _tokens;

  @override
  Future<TokenPair?> read() async => _tokens;

  @override
  Future<void> save(TokenPair tokens) async {
    saveCount++;
    _tokens = tokens;
  }

  @override
  Future<void> clear() async {
    clearCount++;
    _tokens = null;
  }
}
