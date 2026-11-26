import 'dart:convert';
import 'dart:io';

import 'package:chantier_mobile/core/utils/sha256.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vecteurs officiels FIPS 180-4 / NIST : l'empreinte d'une photo de bon est declaree au serveur
/// et comparee a celle du fichier recu (ADR 0013) ; une erreur ici bloquerait tous les envois.
void main() {
  String hex(String text) => Sha256.hex(utf8.encode(text));

  test('texte vide', () {
    expect(
      hex(''),
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
  });

  test('abc', () {
    expect(
      hex('abc'),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  test('message de deux blocs (56 octets)', () {
    expect(
      hex('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'),
      '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
    );
  });

  test('un million de « a »', () {
    expect(
      Sha256.hex(List<int>.filled(1000000, 0x61)),
      'cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0',
    );
  });

  test('longueurs autour de la frontiere de bloc (55, 56, 63, 64, 65)', () {
    // Valeurs de reference calculees avec `sha256sum` sur des `a` repetes.
    const expected = {
      55: '9f4390f8d30c2dd92ec9f095b65e2b9ae9b0a925a5258e241c9f1e910f734318',
      56: 'b35439a4ac6f0948b6d6f9e3c6af0f5f590ce20f1bde7090ef7970686ec6738a',
      63: '7d3e74a05d7db15bce4ad9ec0658ea98e3f06eeecf16b4c6fff2da457ddc2f34',
      64: 'ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb',
      65: '635361c48bb9eab14198e76ea8ab7f1a41685d6ad62aa9146d301d4f17eb0ae0',
    };
    expected.forEach((length, digest) {
      expect(
        Sha256.hex(List<int>.filled(length, 0x61)),
        digest,
        reason: '$length',
      );
    });
  });

  test('empreinte d un fichier, calculee dans un isolat', () async {
    final directory = Directory.systemTemp.createTempSync('chantier_sha_');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File('${directory.path}/abc.bin')
      ..writeAsBytesSync(utf8.encode('abc'));
    expect(
      await Sha256.hexOfFile(file),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });
}
