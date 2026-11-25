import 'dart:math';

import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:flutter_test/flutter_test.dart';

class _Constant implements Random {
  _Constant(this.value);

  final double value;

  @override
  bool nextBool() => true;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => 0;
}

void main() {
  group('Backoff (5 s a 5 min, avec aleas)', () {
    test('sans aleas : 5, 10, 20, 40, 80, 160 s puis plafond a 300 s', () {
      final backoff = Backoff(random: _Constant(1));

      expect(
        [for (var i = 1; i <= 8; i++) backoff.delay(i).inSeconds],
        [5, 10, 20, 40, 80, 160, 300, 300],
      );
    });

    test('l\'aleas retire au plus la moitie du delai', () {
      final low = Backoff(random: _Constant(0));
      final high = Backoff(random: _Constant(1));

      expect(low.delay(3).inMilliseconds, 10000);
      expect(high.delay(3).inMilliseconds, 20000);
    });

    test(
      'jamais sous 2,5 s ni au-dessus de 5 min, meme apres tres longtemps',
      () {
        final backoff = Backoff(random: Random(7));

        for (var failures = 1; failures < 200; failures++) {
          final delay = backoff.delay(failures);
          expect(
            delay,
            greaterThanOrEqualTo(const Duration(milliseconds: 2500)),
          );
          expect(delay, lessThanOrEqualTo(const Duration(minutes: 5)));
        }
      },
    );

    test('deux telephones n\'ont pas le meme delai (aleas)', () {
      final delays = {
        for (var seed = 0; seed < 20; seed++)
          Backoff(random: Random(seed)).delay(4).inMilliseconds,
      };

      expect(delays.length, greaterThan(10));
    });

    test('Retry-After du serveur : plancher respecte', () {
      final backoff = Backoff(random: _Constant(1));

      expect(
        backoff.delay(1, minimum: const Duration(minutes: 10)),
        const Duration(minutes: 10),
      );
      expect(
        backoff.delay(3, minimum: const Duration(seconds: 1)),
        const Duration(seconds: 20),
      );
    });

    test('nombre d\'echecs invalide : traite comme le premier', () {
      expect(Backoff(random: _Constant(1)).delay(0).inSeconds, 5);
    });
  });
}
