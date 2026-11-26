// Q3 : ecrans « demandes et livraisons » sur un petit telephone (320 x 568 dp) avec la police systeme agrandie (x2), en francais et en arabe (RTL),
// avec des textes tres longs (nom de produit libre de 100 lettres arabes, remarque de 200 caracteres, quantites enormes) : aucun debordement,
// les boutons principaux gardent leur hauteur de 56 dp et restent atteignables.
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/approvals/approvals_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/deliveries_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/deliveries_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/delivery_form_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/to_receive_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/to_reception_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/request_detail_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/request_form_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import '../support/materials_harness.dart';
import '../support/photo_support.dart';
import '../support/pump_app.dart';

/// 100 lettres arabes sans espace : le pire cas du retour a la ligne.
final _longArabic = List.filled(100, 'ع').join();

/// Remarque de 200 caracteres (lettres arabes avec espaces et signes).
final _longNote = List.filled(40, 'عاجل جدا').join(' ').substring(0, 200);

const _locales = [Locale('fr'), Locale('ar')];

/// Erreurs de rendu (debordements) collectees avec leur arbre complet : le message d'un `takeException` ne dit pas quel widget deborde.
final List<String> _renderErrors = [];
void Function(FlutterErrorDetails)? _previousOnError;

/// Echoue avec l'arbre du premier debordement (quel widget, de combien de pixels).
void _expectNoRenderError() {
  FlutterError.onError =
      _previousOnError; // le cadre de test l'exige avant toute assertion
  if (_renderErrors.isEmpty) return;
  final summary = <String>{};
  for (final error in _renderErrors) {
    final lines = error.split(String.fromCharCode(10));
    final overflow = lines.firstWhere(
      (line) =>
          line.contains('overflowed') ||
          line.contains('Exception') ||
          line.contains('Error'),
      orElse: () => lines.first,
    );
    final where = lines
        .where((line) => line.contains('chantier-mobile/lib'))
        .map((line) => line.substring(line.indexOf('lib/') + 4).trim())
        .take(1)
        .join(',');
    summary.add('$overflow @ $where');
  }
  fail('Debordements : ${summary.join(' ;; ')}');
}

void _smallScreenLargeFont(
  WidgetTester tester, {
  double fontScale = 2.0,
  Size size = const Size(320, 568),
}) {
  _renderErrors.clear();
  _previousOnError = FlutterError.onError;
  FlutterError.onError = (details) =>
      _renderErrors.add(details.toString(minLevel: DiagnosticLevel.info));
  // Meme si le test leve une exception avant l'assertion : le cadre de test exige le gestionnaire d'origine.
  addTearDown(() => FlutterError.onError = _previousOnError);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = fontScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

void main() {
  // Sans la vraie police, flutter_test mesure avec « Ahem » (1 em par caractere) et invente des debordements.
  setUpAll(() async {
    final loader = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Variable.ttf'));
    await loader.load();
  });

  late MaterialsHarness h;
  late PhotoTestBed bed;

  setUp(() {
    h = MaterialsHarness();
    bed = PhotoTestBed();
  });
  tearDown(() async {
    await h.dispose();
    bed.dispose();
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  /// Demonte l'ecran et laisse partir les minuteurs de Drift.
  Future<void> teardownScreen(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> seedLong() async {
    await h.seed();
    await h.db.suppliersDao.upsertIfNewer(supplierRow());
    await h.db.productsDao.upsertIfNewer(
      productRow(id: 'prod-long', nameFr: _longArabic, nameAr: _longArabic),
    );
    final dao = h.db.materialRequestsDao;
    await dao.upsertIfNewer(
      requestRow(
        id: 'q1',
        number: 'DEM-0001',
        productId: 'prod-long',
        productName: _longArabic,
        quantity: '999999999.999',
        unit: 'kg',
        priority: 'Blocking',
        neededBy: DateTime.utc(2026, 11, 1),
        historyJson:
            '[{"id":"e1","type":"Created","occurredAt":"2026-11-25T07:00:00Z","actorName":"$_longArabic","source":"Api"}]',
      ).copyWith(note: Value(_longNote)),
    );
    await dao.upsertIfNewer(
      requestRow(
        id: 'q2',
        number: 'DEM-0002',
        productId: null,
        productName: null,
        freeProductName: _longArabic,
        quantity: '12',
        unit: 'm3',
        status: 'Ordered',
        orderJson:
            '{"id":"o1","supplierId":"sup-sigma","supplierName":"$_longArabic","expectedDeliveryDate":"2026-11-26"}',
      ).copyWith(note: Value(_longNote)),
    );
    await dao.upsertIfNewer(
      requestRow(id: 'q3', number: 'DEM-0003', status: 'Delivered'),
    );
    await h.db.deliveriesDao.upsertIfNewer(
      deliveryRow(
        id: 'l1',
        requestId: 'q2',
        quantity: '999999999.999',
        unit: 't',
        inRequestQuantity: '999999999.999',
        inRequestUnit: 'kg',
      ),
    );
  }

  /// Boutons pleins : jamais plus bas que 56 dp, jamais hors de l'ecran apres defilement.
  void expectTouchTargets(WidgetTester tester) {
    for (final element in find.byType(FilledButton).evaluate()) {
      final box = element.renderObject! as RenderBox;
      expect(
        box.size.height,
        greaterThanOrEqualTo(56),
        reason: 'bouton de ${box.size.height} dp',
      );
    }
  }

  for (final locale in _locales) {
    final lang = locale.languageCode;
    final chef = chefChantier();
    final conductor = conducteur();
    final team = chefEquipe();

    Widget requestsList(AuthUser user) => BlocProvider(
      create: (_) => RequestsCubit(
        repository: h.materials,
        siteId: harnessSite,
        userId: user.id,
      ),
      child: RequestsScreen(
        user: user,
        zones: h.zones.watchZones(harnessSite),
        onOpen: (_) {},
        onNew: user.can('Requests.Create') ? () {} : null,
        onOpenApprovals: user.can('Requests.Approve') ? () {} : null,
        now: () => DateTime.utc(2026, 11, 25, 9),
      ),
    );

    Future<void> pumpScreen(
      WidgetTester tester,
      Widget Function() home, {
      double fontScale = 2.0,
    }) async {
      _smallScreenLargeFont(tester, fontScale: fontScale);
      await tester.runAsync(seedLong);
      await tester.pumpWidget(testApp(locale: locale, home: home()));
      await tester.pump();
      await settle(tester);
    }

    group('Demandes et livraisons : petit ecran + police x2 ($lang)', () {
      testWidgets(
        'liste des demandes : textes tres longs, pas de debordement',
        (tester) async {
          await pumpScreen(tester, () => requestsList(conductor));
          _expectNoRenderError();
          expect(find.byType(ListView), findsWidgets);
          await teardownScreen(tester);
        },
      );

      testWidgets('liste des demandes, police x1,3 (reglage courant)', (
        tester,
      ) async {
        await pumpScreen(tester, () => requestsList(conductor), fontScale: 1.3);
        _expectNoRenderError();
        await teardownScreen(tester);
      });

      testWidgets(
        'detail d une demande : remarque de 200 caracteres, quantite enorme avec unite',
        (tester) async {
          await pumpScreen(
            tester,
            () => BlocProvider(
              create: (_) => RequestDetailCubit(
                repository: h.materials,
                requestId: 'q1',
                userId: conductor.id,
              ),
              child: RequestDetailScreen(
                user: conductor,
                repository: h.materials,
                zones: h.zones.watchZones(harnessSite),
                onEdit: (_) {},
                onReview: (_) {},
              ),
            ),
          );
          _expectNoRenderError();
          // Jamais une quantite sans unite, meme enorme.
          final quantities = find.byWidgetPredicate(
            (w) =>
                w is RichText &&
                RegExp(
                  r'999[\s\S]*[^0-9\s.,  ]',
                ).hasMatch(w.text.toPlainText()),
          );
          // Liste paresseuse : on defile jusqu'a construire la ligne de la quantite.
          for (var i = 0; i < 15 && quantities.evaluate().isEmpty; i++) {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, -250),
            );
            await tester.pump();
          }
          expect(
            quantities,
            findsWidgets,
            reason: 'quantite enorme affichee avec son unite',
          );
          await teardownScreen(tester);
        },
      );

      testWidgets('a valider : actions atteignables, hauteur de 56 dp', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          () => BlocProvider(
            create: (_) => RequestsCubit(
              repository: h.materials,
              siteId: harnessSite,
              userId: conductor.id,
              view: RequestListView.toApprove,
            ),
            child: ApprovalsScreen(
              user: conductor,
              repository: h.materials,
              zones: h.zones.watchZones(harnessSite),
              onOpen: (_) {},
              now: () => DateTime.utc(2026, 11, 25, 9),
            ),
          ),
        );
        _expectNoRenderError();
        expectTouchTargets(tester);
        await teardownScreen(tester);
      });

      testWidgets(
        'nouvelle demande : Envoyer atteignable, 56 dp, pas de debordement',
        (tester) async {
          await pumpScreen(
            tester,
            () => RequestFormScreen(
              siteId: harnessSite,
              user: team,
              repository: h.materials,
              zonesRepository: h.zones,
              onSeeDuplicate: (_) {},
              now: () => h.clock,
            ),
          );
          _expectNoRenderError();
          final buttons = find.byType(FilledButton);
          expect(buttons, findsWidgets);
          await tester.ensureVisible(buttons.first);
          await tester.pump();
          _expectNoRenderError();
          expect(tester.getRect(buttons.first).bottom, lessThanOrEqualTo(568));
          expectTouchTargets(tester);
          await teardownScreen(tester);
        },
      );

      testWidgets('a recevoir et a receptionner : pas de debordement', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          () => BlocProvider(
            create: (_) => RequestsCubit(
              repository: h.materials,
              siteId: harnessSite,
              userId: chef.id,
              view: RequestListView.expected,
            ),
            child: ToReceiveScreen(
              user: chef,
              onOpen: (_) {},
              onWithoutRequest: () {},
              now: () => DateTime.utc(2026, 11, 25, 9),
            ),
          ),
        );
        _expectNoRenderError();
        await teardownScreen(tester);

        await pumpScreen(
          tester,
          () => BlocProvider(
            create: (_) => RequestsCubit(
              repository: h.materials,
              siteId: harnessSite,
              userId: chef.id,
              view: RequestListView.toReception,
            ),
            child: ToReceptionScreen(
              user: chef,
              repository: h.materials,
              zones: h.zones.watchZones(harnessSite),
              onOpen: (_) {},
              now: () => DateTime.utc(2026, 11, 25, 9),
            ),
          ),
        );
        _expectNoRenderError();
        expectTouchTargets(tester);
        await teardownScreen(tester);
      });

      testWidgets(
        'telephone courant 360 x 640, police x1,3 : les trois listes a en-tete fixe',
        (tester) async {
          final screens = <String, Widget Function()>{
            'demandes': () => requestsList(conductor),
            'a recevoir': () => BlocProvider(
              create: (_) => RequestsCubit(
                repository: h.materials,
                siteId: harnessSite,
                userId: chef.id,
                view: RequestListView.expected,
              ),
              child: ToReceiveScreen(
                user: chef,
                onOpen: (_) {},
                onWithoutRequest: () {},
                now: () => DateTime.utc(2026, 11, 25, 9),
              ),
            ),
            'livraisons': () => BlocProvider(
              create: (_) => DeliveriesCubit(
                repository: h.deliveries,
                siteId: harnessSite,
                userId: chef.id,
              ),
              child: DeliveriesScreen(
                user: chef,
                onOpen: (_) {},
                onNewWithoutRequest: () {},
              ),
            ),
          };
          final failures = <String>[];
          var seeded = false;
          for (final entry in screens.entries) {
            _smallScreenLargeFont(
              tester,
              fontScale: 1.3,
              size: const Size(360, 640),
            );
            if (!seeded) {
              await tester.runAsync(seedLong);
              seeded = true;
            }
            await tester.pumpWidget(
              testApp(locale: locale, home: entry.value()),
            );
            await tester.pump();
            await settle(tester);
            FlutterError.onError = _previousOnError;
            if (_renderErrors.isNotEmpty) {
              failures.add(
                '${entry.key}: ${_renderErrors.length} debordement(s)',
              );
            }
            await teardownScreen(tester);
          }
          expect(failures, isEmpty, reason: 'a 360 x 640 et police x1,3');
        },
      );

      testWidgets('livraisons : liste sans debordement', (tester) async {
        await pumpScreen(
          tester,
          () => BlocProvider(
            create: (_) => DeliveriesCubit(
              repository: h.deliveries,
              siteId: harnessSite,
              userId: chef.id,
            ),
            child: DeliveriesScreen(
              user: chef,
              onOpen: (_) {},
              onNewWithoutRequest: () {},
            ),
          ),
        );
        _expectNoRenderError();
        await teardownScreen(tester);
      });

      testWidgets('formulaire de reception : Enregistrer atteignable, 56 dp', (
        tester,
      ) async {
        _smallScreenLargeFont(tester);
        late RequestView request;
        await tester.runAsync(() async {
          await seedLong();
          request = (await h.materials.watchRequest('q2', chef.id).first)!;
        });
        await tester.pumpWidget(
          testApp(
            locale: locale,
            home: DeliveryFormScreen(
              siteId: harnessSite,
              user: chef,
              deliveries: h.deliveries,
              materials: h.materials,
              capture: FakePhotoCapture(bed),
              files: bed.files,
              request: request,
              onSeeDuplicate: (_) {},
              now: () => h.clock,
            ),
          ),
        );
        await tester.pump();
        await settle(tester);
        _expectNoRenderError();
        final save = find.byType(FilledButton);
        expect(save, findsWidgets);
        await tester.ensureVisible(save.last);
        await tester.pump();
        _expectNoRenderError();
        expect(tester.getRect(save.last).bottom, lessThanOrEqualTo(568));
        expectTouchTargets(tester);
        await teardownScreen(tester);
      });
    });
  }
}
