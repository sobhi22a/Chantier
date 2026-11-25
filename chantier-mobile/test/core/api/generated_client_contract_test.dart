import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CT-10 cote mobile : le client genere (`lib/core/api/generated/`) correspond au contrat
/// `docs/api/openapi.json`. Si le backend change le contrat sans que le client soit regenere
/// (`dart run swagger_parser` + `build_runner`), ces tests echouent ; la CI controle en plus
/// `git diff --exit-code` apres regeneration.
void main() {
  final spec =
      jsonDecode(File('../docs/api/openapi.json').readAsStringSync())
          as Map<String, dynamic>;
  final generatedDir = Directory('lib/core/api/generated');
  final clientSources = generatedDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('_client.dart'))
      .map((f) => f.readAsStringSync())
      .join('\n');

  String snake(String pascal) => pascal
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])([A-Z])'),
        (m) => '_${m.group(1)}',
      )
      .toLowerCase();

  test('le contrat est un OpenAPI 3.1', () {
    expect(spec['openapi'], startsWith('3.1'));
  });

  test('chaque operationId du contrat a sa methode generee', () {
    final missing = <String>[];
    final paths = spec['paths'] as Map<String, dynamic>;
    var count = 0;
    for (final item in paths.values) {
      for (final operation in (item as Map<String, dynamic>).values) {
        final id = (operation as Map<String, dynamic>)['operationId'] as String;
        count++;
        // Sites_List -> sitesList
        final parts = id.split('_');
        final method =
            parts.first[0].toLowerCase() +
            parts.first.substring(1) +
            parts.skip(1).join();
        if (!RegExp('\\b$method\\(').hasMatch(clientSources)) missing.add(id);
      }
    }

    expect(count, greaterThanOrEqualTo(26));
    expect(missing, isEmpty, reason: 'client a regenerer : $missing');
  });

  test('chaque chemin du contrat est appele par le client genere', () {
    final paths = (spec['paths'] as Map<String, dynamic>).keys;
    for (final path in paths) {
      expect(clientSources, contains("'$path'"), reason: path);
    }
  });

  test(
    'chaque schema du contrat a son modele genere, avec tous ses champs',
    () {
      final schemas =
          (spec['components'] as Map<String, dynamic>)['schemas']
              as Map<String, dynamic>;
      final problems = <String>[];
      schemas.forEach((name, schema) {
        final file = File('lib/core/api/generated/models/${snake(name)}.dart');
        if (!file.existsSync()) {
          problems.add('$name : modele absent');
          return;
        }
        final source = file.readAsStringSync();
        final properties =
            (schema as Map<String, dynamic>)['properties']
                as Map<String, dynamic>?;
        for (final property in properties?.keys ?? const <String>[]) {
          if (!RegExp('\\b$property[,})]').hasMatch(source)) {
            problems.add('$name.$property : champ absent du modele');
          }
        }
        final values = schema['enum'] as List<dynamic>?;
        for (final value in values ?? const []) {
          if (!source.contains("'$value'")) {
            problems.add('$name : valeur $value');
          }
        }
      });

      expect(problems, isEmpty);
    },
  );

  test('schemas utilises par le mobile : champs requis du contrat', () {
    final schemas =
        (spec['components'] as Map<String, dynamic>)['schemas']
            as Map<String, dynamic>;
    List<String> required(String name) =>
        List<String>.from((schemas[name] as Map)['required'] as List);

    expect(required('AuthResult'), ['user']);
    expect(
      required('SyncPullResponse'),
      containsAll(['changes', 'deleted', 'cursor', 'hasMore']),
    );
    expect(required('SyncPushResult'), containsAll(['clientId', 'status']));
    expect(
      required('SyncChange'),
      containsAll(['entity', 'id', 'siteId', 'version', 'data']),
    );
    expect(
      required('MeResponse'),
      containsAll(['permissions', 'permissionsVersion', 'mustChangePassword']),
    );
    // `contractAmount` est facultatif : absent sans la permission ContractAmount.View.
    expect(required('SiteResponse'), isNot(contains('contractAmount')));
  });
}
