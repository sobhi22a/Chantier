import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// R1-04 (MASVS-STORAGE-2) : aucune sauvegarde automatique Android de la base locale, non chiffree
/// au socle. Controle statique du manifeste : la CI le rejoue sans toolchain Android.
void main() {
  const manifestPath = 'android/app/src/main/AndroidManifest.xml';
  const debugManifestPath = 'android/app/src/debug/AndroidManifest.xml';
  late String manifest;

  setUpAll(() => manifest = File(manifestPath).readAsStringSync());

  test('allowBackup est desactive', () {
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, isNot(contains('android:allowBackup="true"')));
  });

  test(
    'regles d\'extraction (Android 12+) et de sauvegarde (Android 11-) declarees',
    () {
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
      expect(
        manifest,
        contains('android:fullBackupContent="@xml/backup_rules"'),
      );
    },
  );

  for (final rules in {
    'android/app/src/main/res/xml/data_extraction_rules.xml': [
      'cloud-backup',
      'device-transfer',
    ],
    'android/app/src/main/res/xml/backup_rules.xml': ['full-backup-content'],
  }.entries) {
    test(
      '${rules.key} : exclut base, preferences, fichiers et stockage externe',
      () {
        final xml = File(rules.key).readAsStringSync();

        for (final section in rules.value) {
          expect(xml, contains('<$section'), reason: section);
        }
        for (final domain in [
          'root',
          'file',
          'database',
          'sharedpref',
          'external',
        ]) {
          final excluded = RegExp(
            '<exclude domain="$domain"',
          ).allMatches(xml).length;
          expect(
            excluded,
            rules.value.length == 2 ? 2 : 1,
            reason: '$domain dans ${rules.key}',
          );
        }
        expect(xml, isNot(contains('<include')), reason: 'rien n\'est inclus');
      },
    );
  }

  test('aucun profil ne reactive la sauvegarde', () {
    expect(
      File(debugManifestPath).readAsStringSync(),
      isNot(contains('allowBackup')),
    );
    expect(
      File('android/app/src/profile/AndroidManifest.xml').readAsStringSync(),
      isNot(contains('allowBackup="true"')),
    );
  });

  test(
    'trafic en clair interdit hors debug, aucune permission de stockage ni de localisation au socle',
    () {
      expect(manifest, contains('android:usesCleartextTraffic="false"'));
      for (final permission in [
        'READ_EXTERNAL_STORAGE',
        'WRITE_EXTERNAL_STORAGE',
        'ACCESS_FINE_LOCATION',
        'CAMERA',
      ]) {
        expect(manifest, isNot(contains(permission)), reason: permission);
      }
    },
  );
}
