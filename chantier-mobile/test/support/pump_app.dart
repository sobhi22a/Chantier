import 'package:bloc_test/bloc_test.dart';
import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/theme/app_theme.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Application de test : theme terrain, francais/arabe (RTL automatique), blocs fournis.
Widget testApp({
  required Widget home,
  Locale locale = const Locale('fr'),
  Widget Function(Widget app)? wrap,
}) {
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    locale: locale,
    supportedLocales: const [Locale('fr'), Locale('ar')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
  return wrap == null ? app : wrap(app);
}

/// Direction du texte sous le widget trouve par [finder].
TextDirection directionOf(WidgetTester tester, Finder finder) =>
    Directionality.of(tester.element(finder.first));

class MockSyncStatusCubit extends MockCubit<SyncStatusSnapshot>
    implements SyncStatusCubit {}

class MockCurrentSiteCubit extends MockCubit<CurrentSiteState>
    implements CurrentSiteCubit {}

/// `SyncStatusCubit` simule : etat fixe, `syncNow` scriptable.
MockSyncStatusCubit fakeSyncStatus(
  SyncStatusSnapshot snapshot, {
  Future<SyncOutcome> Function()? onSyncNow,
}) {
  final cubit = MockSyncStatusCubit();
  whenListen(
    cubit,
    const Stream<SyncStatusSnapshot>.empty(),
    initialState: snapshot,
  );
  when(
    () => cubit.syncNow(),
  ).thenAnswer((_) => (onSyncNow ?? () async => SyncOutcome.completed)());
  return cubit;
}

/// Texte affiche contenant [expected], **sans compter les isolats de direction** (LRI/PDI, invisibles)
/// que l'interface insere autour des codes, dates et cotes pour l'arabe.
Finder findTextContaining(String expected) {
  final isolates = RegExp('[${Formatters.isolateLtr('')}]');
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        (widget.data ?? '').replaceAll(isolates, '').contains(expected),
    description: 'texte contenant "$expected"',
  );
}
