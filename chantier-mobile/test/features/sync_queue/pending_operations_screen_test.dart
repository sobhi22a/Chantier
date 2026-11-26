import 'dart:async';

import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/sync_queue/presentation/pending_operations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/pump_app.dart';

class _MockOutbox extends Mock implements OutboxRepository {}

OutboxRow _row(
  int id,
  String clientId, {
  OutboxStatus status = OutboxStatus.pending,
  String? code,
  String label = 'Bloc 01 · +3,40 m · Classe 07',
  DateTime? createdAt,
  String entity = 'zone',
}) => OutboxRow(
  id: id,
  clientId: clientId,
  ownerUserId: 'user-a',
  entity: entity,
  operation: 'create',
  siteId: 'site-uv18',
  label: label,
  payloadJson: '{}',
  status: status,
  attempts: 0,
  lastErrorCode: code,
  createdAt: createdAt ?? DateTime.utc(2026, 11, 24, 6, 58),
);

void main() {
  late _MockOutbox outbox;
  late List<OutboxRow> corrected;
  late int syncCalls;

  setUpAll(() => registerFallbackValue(_row(0, 'x')));

  setUp(() {
    outbox = _MockOutbox();
    corrected = [];
    syncCalls = 0;
    when(() => outbox.abandon(any())).thenAnswer((_) async {});
  });

  Future<void> pump(
    WidgetTester tester, {
    required List<OutboxRow> rows,
    SyncStatusSnapshot status = const SyncStatusSnapshot(
      indicator: SyncIndicator.pending,
    ),
    Locale locale = const Locale('fr'),
    Future<SyncOutcome> Function()? onSyncNow,
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(() => outbox.watch('user-a')).thenAnswer((_) => Stream.value(rows));
    final sync = fakeSyncStatus(
      status,
      onSyncNow:
          onSyncNow ??
          () async {
            syncCalls++;
            return SyncOutcome.completed;
          },
    );
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: PendingOperationsScreen(
          userId: 'user-a',
          outbox: outbox,
          onCorrect: corrected.add,
        ),
        wrap: (app) =>
            BlocProvider<SyncStatusCubit>.value(value: sync, child: app),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
    'liste : type, libelle, date et heure de saisie, etat (CA-013.3)',
    (tester) async {
      await pump(tester, rows: [_row(1, 'c-1')]);

      expect(find.text('Envois en attente'), findsOneWidget);
      expect(find.text('Zone'), findsOneWidget);
      expect(
        findTextContaining('Bloc 01 · +3,40 m · Classe 07'),
        findsOneWidget,
      );
      expect(
        findTextContaining('Saisi le 24/11/2026 07:58'),
        findsOneWidget,
        reason: 'heure d\'Alger',
      );
      expect(find.text('En attente d\'envoi'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    },
  );

  testWidgets('demande de materiau : type traduit, « Voir » mene a A verifier', (
    tester,
  ) async {
    await pump(
      tester,
      rows: [
        _row(
          7,
          'r-1',
          entity: 'request',
          status: OutboxStatus.conflict,
          code: 'DEMANDE_VERROUILLEE',
          label: 'DEM-009 · Ciment CPJ 42,5 · 400 sac',
        ),
      ],
    );
    expect(find.text('Demande de matériau'), findsOneWidget);
    expect(find.text('À vérifier'), findsOneWidget);
    // Une demande se verifie sur son ecran (deux versions), pas par « Corriger ».
    expect(find.text('Corriger'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Voir'));
    expect(corrected.single.entity, 'request');
  });

  testWidgets('rien a envoyer', (tester) async {
    await pump(tester, rows: const []);

    expect(find.text('Rien à envoyer. Tout est à jour.'), findsOneWidget);
  });

  testWidgets('en cours d\'envoi', (tester) async {
    await pump(tester, rows: [_row(1, 'c-1', status: OutboxStatus.sending)]);

    expect(find.text('Envoi en cours'), findsOneWidget);
  });

  group('A verifier (CA-013.7)', () {
    testWidgets('motif traduit par code, deux choix : Corriger / Abandonner', (
      tester,
    ) async {
      await pump(
        tester,
        rows: [
          _row(
            1,
            'c-1',
            status: OutboxStatus.rejected,
            code: 'CHANTIER_ARCHIVE',
          ),
        ],
      );

      expect(find.text('À vérifier'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(
        find.text(
          'Motif : Ce chantier est archivé : plus aucune saisie n\'est possible.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Corriger'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Abandonner'), findsOneWidget);
    });

    testWidgets('motif en arabe', (tester) async {
      await pump(
        tester,
        locale: const Locale('ar'),
        rows: [
          _row(1, 'c-1', status: OutboxStatus.rejected, code: 'ZONE_EXISTANTE'),
        ],
      );

      expect(
        find.textContaining('هذه المنطقة موجودة مسبقا في هذه الورشة.'),
        findsOneWidget,
      );
      expect(find.text('تصحيح'), findsOneWidget);
      expect(find.text('إلغاء الإدخال'), findsOneWidget);
      expect(
        directionOf(tester, find.byType(PendingOperationsScreen)),
        TextDirection.rtl,
      );
    });

    testWidgets('code inconnu : message generique, jamais un code brut', (
      tester,
    ) async {
      await pump(
        tester,
        rows: [
          _row(1, 'c-1', status: OutboxStatus.rejected, code: 'CODE_DU_FUTUR'),
        ],
      );

      expect(find.textContaining('CODE_DU_FUTUR'), findsNothing);
      expect(find.textContaining('Une erreur est survenue'), findsOneWidget);
    });

    testWidgets('conflit', (tester) async {
      await pump(
        tester,
        rows: [
          _row(
            1,
            'c-1',
            status: OutboxStatus.conflict,
            code: 'CONFLIT_VERSION',
          ),
        ],
      );

      expect(find.textContaining('modifié entre-temps'), findsOneWidget);
    });

    testWidgets('« Corriger » ouvre le formulaire avec la saisie', (
      tester,
    ) async {
      final row = _row(
        1,
        'c-1',
        status: OutboxStatus.rejected,
        code: 'VALIDATION',
      );
      await pump(tester, rows: [row]);

      await tester.tap(find.widgetWithText(FilledButton, 'Corriger'));

      expect(corrected.single.clientId, 'c-1');
    });

    testWidgets(
      '« Abandonner » demande confirmation ; annuler ne supprime rien',
      (tester) async {
        await pump(
          tester,
          rows: [
            _row(1, 'c-1', status: OutboxStatus.rejected, code: 'VALIDATION'),
          ],
        );

        await tester.tap(find.widgetWithText(OutlinedButton, 'Abandonner'));
        await tester.pumpAndSettle();
        expect(find.text('Abandonner cette saisie ?'), findsOneWidget);
        await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
        await tester.pumpAndSettle();

        verifyNever(() => outbox.abandon(any()));
      },
    );

    testWidgets('« Abandonner » confirme : la saisie est supprimee', (
      tester,
    ) async {
      await pump(
        tester,
        rows: [
          _row(1, 'c-1', status: OutboxStatus.rejected, code: 'VALIDATION'),
        ],
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Abandonner'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Abandonner'),
        ),
      );
      await tester.pumpAndSettle();

      final abandoned =
          verify(() => outbox.abandon(captureAny())).captured.single
              as OutboxRow;
      expect(abandoned.clientId, 'c-1');
    });

    testWidgets(
      'saisie en attente : ni « Corriger » ni « Abandonner » (jamais supprimee sans decision)',
      (tester) async {
        await pump(tester, rows: [_row(1, 'c-1')]);

        expect(find.text('Corriger'), findsNothing);
        expect(find.text('Abandonner'), findsNothing);
      },
    );
  });

  group('« Synchroniser maintenant » (CA-013.5)', () {
    testWidgets('gros bouton, une synchronisation par appui', (tester) async {
      await pump(tester, rows: [_row(1, 'c-1')]);
      final button = find.ancestor(
        of: find.text('Synchroniser maintenant'),
        matching: find.bySubtype<FilledButton>(),
      );

      expect(tester.getSize(button).height, greaterThanOrEqualTo(56));
      await tester.tap(button);
      await tester.pump();

      expect(syncCalls, 1);
    });

    testWidgets(
      'pendant une synchronisation : bouton inactif (pas de double lancement)',
      (tester) async {
        await pump(
          tester,
          rows: [_row(1, 'c-1')],
          status: const SyncStatusSnapshot(indicator: SyncIndicator.syncing),
        );

        final button = tester.widget<FilledButton>(
          find.bySubtype<FilledButton>(),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets('echec : message, saisies conservees', (tester) async {
      await pump(
        tester,
        rows: [_row(1, 'c-1')],
        onSyncNow: () async => SyncOutcome.offline,
      );

      await tester.tap(find.text('Synchroniser maintenant'));
      await tester.pump();

      expect(
        find.text(
          'La synchronisation n\'a pas abouti. Vos saisies sont conservées.',
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets(
    '200 saisies : liste construite a la demande (fluide, CA-013.10)',
    (tester) async {
      final rows = [
        for (var i = 0; i < 200; i++)
          _row(
            i,
            'c-$i',
            createdAt: DateTime.utc(2026, 11, 24, 6).add(Duration(minutes: i)),
          ),
      ];
      await pump(tester, rows: rows);

      final built = find.byType(Card).evaluate().length;
      expect(
        built,
        lessThan(40),
        reason:
            'ListView.builder : seules les lignes visibles sont construites',
      );
      expect(find.byType(ListView), findsOneWidget);
    },
  );
}
