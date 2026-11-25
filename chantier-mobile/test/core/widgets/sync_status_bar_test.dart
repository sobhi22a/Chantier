import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/utils/collation.dart';
import 'package:chantier_mobile/core/widgets/stale_data_banner.dart';
import 'package:chantier_mobile/core/widgets/sync_labels.dart';
import 'package:chantier_mobile/core/widgets/sync_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../theme/app_theme_test.dart' show contrastRatio;

final _now = DateTime.utc(2026, 11, 24, 10, 15);

void main() {
  Future<void> pumpBar(
    WidgetTester tester,
    SyncStatusSnapshot status, {
    Locale locale = const Locale('fr'),
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: Scaffold(
          body: SyncStatusBar(onTap: onTap ?? () {}, now: () => _now),
        ),
        wrap: (app) => BlocProvider<SyncStatusCubit>.value(
          value: fakeSyncStatus(status),
          child: app,
        ),
      ),
    );
    await tester.pump();
  }

  group('Barre d\'etat : cinq etats, icone ET texte (CA-013.1)', () {
    final cases = <String, (SyncStatusSnapshot, String, IconData)>{
      'a jour avec l\'heure': (
        SyncStatusSnapshot(
          indicator: SyncIndicator.upToDate,
          lastSuccessAt: DateTime.utc(2026, 11, 24, 8, 30),
        ),
        'À jour · aujourd\'hui 09:30',
        Icons.check_circle,
      ),
      'hors ligne': (
        const SyncStatusSnapshot(indicator: SyncIndicator.offline),
        'Hors ligne',
        Icons.cloud_off,
      ),
      'hors ligne avec saisies': (
        const SyncStatusSnapshot(indicator: SyncIndicator.offline, toSend: 3),
        'Hors ligne · 3 à envoyer',
        Icons.cloud_off,
      ),
      'en attente': (
        const SyncStatusSnapshot(indicator: SyncIndicator.pending, toSend: 3),
        '3 à envoyer',
        Icons.upload,
      ),
      'probleme': (
        const SyncStatusSnapshot(indicator: SyncIndicator.problem, toCheck: 2),
        '2 à vérifier',
        Icons.error,
      ),
      'reconnexion': (
        const SyncStatusSnapshot(indicator: SyncIndicator.authRequired),
        'Reconnexion nécessaire',
        Icons.lock,
      ),
    };

    cases.forEach((name, spec) {
      testWidgets(name, (tester) async {
        await pumpBar(tester, spec.$1);

        expect(findTextContaining(spec.$2), findsOneWidget);
        expect(
          find.byIcon(spec.$3),
          findsOneWidget,
          reason: 'jamais la couleur seule',
        );
      });
    });

    testWidgets('en cours : texte et indicateur de progression', (
      tester,
    ) async {
      await pumpBar(
        tester,
        const SyncStatusSnapshot(indicator: SyncIndicator.syncing),
      );

      expect(find.text('Synchronisation…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('probleme du serveur sans saisie a verifier', (tester) async {
      await pumpBar(
        tester,
        const SyncStatusSnapshot(indicator: SyncIndicator.problem),
      );

      expect(find.text('Problème de synchronisation'), findsOneWidget);
    });

    testWidgets(
      'date complete quand la derniere synchro n\'est pas d\'aujourd\'hui (CA-013.8)',
      (tester) async {
        await pumpBar(
          tester,
          SyncStatusSnapshot(
            indicator: SyncIndicator.upToDate,
            lastSuccessAt: DateTime.utc(2026, 11, 22, 14, 5),
          ),
        );

        expect(find.textContaining('22/11/2026 15:05'), findsOneWidget);
      },
    );

    testWidgets(
      'cible tactile de 48 dp au moins, un appui ouvre « Envois en attente »',
      (tester) async {
        var taps = 0;
        await pumpBar(
          tester,
          const SyncStatusSnapshot(indicator: SyncIndicator.pending, toSend: 1),
          onTap: () => taps++,
        );

        expect(
          tester.getSize(find.byType(SyncStatusBar)).height,
          greaterThanOrEqualTo(48),
        );
        await tester.tap(find.byType(SyncStatusBar));
        expect(taps, 1);
      },
    );

    testWidgets('arabe : textes arabes, RTL, compteur lisible', (tester) async {
      await pumpBar(
        tester,
        const SyncStatusSnapshot(indicator: SyncIndicator.pending, toSend: 3),
        locale: const Locale('ar'),
      );

      expect(
        directionOf(tester, find.byType(SyncStatusBar)),
        TextDirection.rtl,
      );
      expect(find.text('3 في انتظار الإرسال'), findsOneWidget);
    });

    testWidgets('arabe : hors ligne', (tester) async {
      await pumpBar(
        tester,
        const SyncStatusSnapshot(indicator: SyncIndicator.offline),
        locale: const Locale('ar'),
      );

      expect(find.text('بدون اتصال'), findsOneWidget);
    });
  });

  group('Couleurs de l\'indicateur : contraste >= 7:1', () {
    for (final indicator in SyncIndicator.values) {
      test(indicator.name, () {
        final colors = syncIndicatorColors(indicator);

        expect(
          contrastRatio(colors.foreground, colors.background),
          greaterThanOrEqualTo(7),
        );
      });
    }
  });

  group('Bandeau « Donnees du ... » (CA-012.5)', () {
    Future<void> pumpBanner(
      WidgetTester tester,
      SyncStatusSnapshot status, {
      Locale locale = const Locale('fr'),
    }) async {
      await tester.pumpWidget(
        testApp(
          locale: locale,
          home: const Scaffold(body: StaleDataBanner()),
          wrap: (app) => BlocProvider<SyncStatusCubit>.value(
            value: fakeSyncStatus(status),
            child: app,
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('au-dela de 24 h : date et heure completes', (tester) async {
      await pumpBanner(
        tester,
        SyncStatusSnapshot(
          indicator: SyncIndicator.pending,
          isStale: true,
          lastSuccessAt: DateTime.utc(2026, 11, 22, 14, 5),
        ),
      );

      expect(find.textContaining('Données du'), findsOneWidget);
      expect(find.textContaining('22/11/2026 15:05'), findsOneWidget);
    });

    testWidgets('en arabe', (tester) async {
      await pumpBanner(
        tester,
        SyncStatusSnapshot(
          indicator: SyncIndicator.pending,
          isStale: true,
          lastSuccessAt: DateTime.utc(2026, 11, 22, 14, 5),
        ),
        locale: const Locale('ar'),
      );

      expect(find.textContaining('بيانات بتاريخ'), findsOneWidget);
    });

    testWidgets('donnees recentes : aucun bandeau', (tester) async {
      await pumpBanner(
        tester,
        SyncStatusSnapshot(
          indicator: SyncIndicator.upToDate,
          lastSuccessAt: DateTime.utc(2026, 11, 24, 9),
        ),
      );

      expect(find.textContaining('Données du'), findsNothing);
    });

    testWidgets(
      'jamais synchronise : pas de bandeau (c\'est l\'ecran de preparation)',
      (tester) async {
        await pumpBanner(
          tester,
          const SyncStatusSnapshot(indicator: SyncIndicator.syncing),
        );

        expect(find.textContaining('Données du'), findsNothing);
      },
    );
  });

  group('Tri « lecture humaine »', () {
    test('les accents ne rejettent pas « École » apres « Z »', () {
      final names = [
        'Logements OL40',
        'École UV18',
        'Zone industrielle',
        'Atelier',
      ]..sort(compareHuman);

      expect(names, [
        'Atelier',
        'École UV18',
        'Logements OL40',
        'Zone industrielle',
      ]);
    });

    test('cle sans accents ni majuscules', () {
      expect(collationKey('Éléphant À Çà'), 'elephant a ca');
    });

    test('texte arabe inchange', () {
      expect(collationKey('مدرسة'), 'مدرسة');
    });
  });

  test('couleurs de la barre : memes que la charte', () {
    expect(
      syncIndicatorColors(SyncIndicator.problem).background,
      AppColors.errorContainer,
    );
  });
}
