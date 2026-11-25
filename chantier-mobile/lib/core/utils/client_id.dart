import 'dart:math';

/// `clientId` d'une saisie : GUID version 4 (aleatoire, `Random.secure`), **cree a l'ouverture du
/// formulaire**, pas a l'envoi (anti-doublon : un double appui ou un renvoi porte le meme
/// identifiant, le serveur est idempotent, regle 6).
String generateClientId([Random? random]) {
  final source = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => source.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3F) | 0x80; // variante RFC 4122
  String hex(int from, int to) => [
    for (var i = from; i < to; i++) bytes[i].toRadixString(16).padLeft(2, '0'),
  ].join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
