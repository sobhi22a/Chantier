import 'dart:io';

import 'package:chantier_mobile/core/config/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la version affichee est celle de pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final declared = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);

    expect(appVersion, declared);
  });
}
