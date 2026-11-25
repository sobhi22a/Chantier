import 'package:bloc_test/bloc_test.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fixtures.dart';
import '../../support/pump_app.dart';

class _MockDetailCubit extends MockCubit<SiteDetailState>
    implements SiteDetailCubit {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  late List<SiteRow> addZoneRequests;

  setUp(() => addZoneRequests = []);

  Future<void> pumpDetail(
    WidgetTester tester, {
    required SiteDetailState state,
    AuthUser? user,
    Locale locale = const Locale('fr'),
    Size viewport = const Size(800, 4000),
  }) async {
    // Par defaut un ecran haut : `ListView` ne construit que ce qui est visible.
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cubit = _MockDetailCubit();
    whenListen(
      cubit,
      const Stream<SiteDetailState>.empty(),
      initialState: state,
    );
    final auth = _MockAuthBloc();
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: AuthState.authenticated(user ?? testUser()),
    );
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: SiteDetailScreen(onAddZone: addZoneRequests.add),
        wrap: (app) => MultiBlocProvider(
          providers: [
            BlocProvider<SiteDetailCubit>.value(value: cubit),
            BlocProvider<AuthBloc>.value(value: auth),
          ],
          child: app,
        ),
      ),
    );
    await tester.pump();
  }

  final uv18 = siteRow(
    contractAmount: Decimal.parse('185000000.00'),
    odsDate: DateTime.utc(2026, 3, 2),
    contractualEndDate: DateTime.utc(2027, 8, 24),
  );

  SiteDetailState full({
    SiteRow? site,
    List<ZoneRow> zones = const [],
    List<SiteMemberRow> members = const [],
  }) => SiteDetailState(
    site: site ?? uv18,
    zones: zones,
    members: members,
    loaded: true,
  );

  group('Fiche (CA-007)', () {
    testWidgets('informations completes, calcul du serveur affiche tel quel', (
      tester,
    ) async {
      await pumpDetail(tester, state: full());

      expect(find.text('CH-ECO-UV18'), findsOneWidget);
      expect(find.text('École'), findsOneWidget);
      expect(find.text('Blida'), findsOneWidget);
      expect(find.text('Boufarik'), findsOneWidget);
      expect(
        find.text('Direction des équipements publics (fictive)'),
        findsOneWidget,
      );
      expect(find.text('M-2026-UV18-001'), findsOneWidget);
      expect(find.text('540 jours'), findsOneWidget);
      expect(find.text('02/03/2026'), findsOneWidget, reason: 'ODS');
      expect(
        find.text('24/08/2027'),
        findsOneWidget,
        reason: 'fin contractuelle du serveur (CA-007.2)',
      );
      expect(findTextContaining('Créé par Farid L. le'), findsOneWidget);
    });

    testWidgets(
      'montant visible avec la permission : 185 000 000,00 DZD (CA-007.8)',
      (tester) async {
        await pumpDetail(tester, state: full());

        expect(find.text('Montant'), findsOneWidget);
        expect(
          find.widgetWithText(LtrText, '185 000 000,00 DZD'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'sans la permission : la ligne « Montant » n\'existe pas (CA-007.4)',
      (tester) async {
        await pumpDetail(
          tester,
          state: full(site: siteRow(odsDate: DateTime.utc(2026, 3, 2))),
        );

        expect(find.text('Montant'), findsNothing);
        expect(find.textContaining('DZD'), findsNothing);
      },
    );

    testWidgets(
      'sans date d\'ODS ou sans delai : « A definir », pas de date inventee (CA-007.3)',
      (tester) async {
        await pumpDetail(tester, state: full(site: siteRow()));

        expect(find.text('Fin contractuelle'), findsOneWidget);
        expect(find.text('À définir'), findsOneWidget);
      },
    );

    testWidgets(
      'coordonnees ecrites a la place de la carte, hors ligne (CA-007.5)',
      (tester) async {
        await pumpDetail(tester, state: full());

        expect(find.text('Coordonnées GPS'), findsOneWidget);
        expect(
          find.widgetWithText(LtrText, '36,575000 ; 2,912000'),
          findsOneWidget,
        );
        expect(find.textContaining('carte'), findsNothing);
      },
    );

    testWidgets('chantier absent du telephone : « introuvable »', (
      tester,
    ) async {
      await pumpDetail(tester, state: const SiteDetailState(loaded: true));

      expect(find.text('Chantier introuvable.'), findsOneWidget);
    });

    testWidgets('chargement local', (tester) async {
      await pumpDetail(tester, state: const SiteDetailState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'personnes affectees : nom et role, jamais de telephone (CA-017.4)',
      (tester) async {
        await pumpDetail(
          tester,
          state: full(
            members: [
              memberRow(id: 'm1', fullName: 'Mourad B.', role: 'ChefChantier'),
              memberRow(
                id: 'm2',
                fullName: 'Karim S.',
                role: 'ConducteurTravaux',
                version: 301,
              ),
            ],
          ),
        );

        expect(find.text('Personnes affectées'), findsOneWidget);
        expect(findTextContaining('Mourad B.'), findsOneWidget);
        expect(find.text('Chef de chantier'), findsOneWidget);
        expect(find.text('Conducteur de travaux'), findsOneWidget);
        expect(find.textContaining('0550'), findsNothing);
      },
    );

    testWidgets('chantier archive : badge', (tester) async {
      await pumpDetail(
        tester,
        state: full(site: siteRow(archivedAt: DateTime.utc(2026, 11, 1))),
      );

      expect(find.text('Archivé'), findsOneWidget);
    });
  });

  group('Zones : groupees par bloc, cote signee, du plus bas au plus haut', () {
    final zones = [
      zoneRow(id: 'z1', elevation: '-1.90', roomNumber: 1),
      zoneRow(id: 'z2', elevation: '0.00', roomNumber: 1, version: 201),
      zoneRow(id: 'z3', elevation: '3.40', roomNumber: 2, version: 202),
      zoneRow(
        id: 'z4',
        block: 'Bloc 02',
        elevation: '3.40',
        roomType: 'Canteen',
        roomNumber: null,
        version: 203,
      ),
    ];

    testWidgets('cotes signees et local ; blocs en titre', (tester) async {
      await pumpDetail(tester, state: full(zones: zones));

      expect(find.text('Bloc 01'), findsOneWidget);
      expect(find.text('Bloc 02'), findsOneWidget);
      expect(findTextContaining('−1,90 m · Classe 01'), findsOneWidget);
      expect(findTextContaining('±0,00 m · Classe 01'), findsOneWidget);
      expect(findTextContaining('+3,40 m · Classe 02'), findsOneWidget);
      expect(findTextContaining('+3,40 m · Cantine'), findsOneWidget);
    });

    testWidgets('l\'ordre du plus bas au plus haut est conserve', (
      tester,
    ) async {
      await pumpDetail(tester, state: full(zones: zones));

      final tops = [
        for (final text in ['−1,90 m', '±0,00 m', '+3,40 m · Classe 02'])
          tester.getTopLeft(findTextContaining(text)).dy,
      ];
      expect(tops, [...tops]..sort());
    });

    testWidgets('zone creee hors ligne : « En attente d\'envoi » avec icone', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        state: full(zones: [pendingZoneRow(clientId: 'c-1')]),
      );

      expect(find.text('En attente d\'envoi'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('aucune zone : message', (tester) async {
      await pumpDetail(tester, state: full());

      expect(find.text('Aucune zone pour ce chantier.'), findsOneWidget);
    });

    testWidgets(
      'arabe : RTL, type de local traduit, cote jamais retournee (CA-014.4)',
      (tester) async {
        await pumpDetail(
          tester,
          locale: const Locale('ar'),
          state: full(zones: zones),
        );

        expect(
          directionOf(tester, find.byType(SiteDetailScreen)),
          TextDirection.rtl,
        );
        expect(findTextContaining('قسم 02'), findsOneWidget);
        expect(findTextContaining('مطعم مدرسي'), findsOneWidget);
        // La cote est isolee en gauche-a-droite : « +3,40 m », jamais « 3,40+ m ».
        expect(findTextContaining('+3,40 m'), findsWidgets);
        expect(findTextContaining('3,40+'), findsNothing);
      },
    );

    testWidgets('arabe : codes, dates et montants de gauche a droite', (
      tester,
    ) async {
      await pumpDetail(tester, locale: const Locale('ar'), state: full());

      for (final text in [
        'CH-ECO-UV18',
        '24/08/2027',
        '02/03/2026',
        '185 000 000,00 DZD',
      ]) {
        final element = tester.element(find.text(text));
        expect(Directionality.of(element), TextDirection.ltr, reason: text);
      }
      expect(find.text('النهاية التعاقدية'), findsOneWidget);
    });
  });

  group('Fiche paresseuse (R1-15)', () {
    final many = [
      for (var b = 1; b <= 10; b++)
        for (var n = 1; n <= 30; n++)
          zoneRow(
            id: 'z-$b-$n',
            block: 'Bloc ${b.toString().padLeft(2, '0')}',
            roomNumber: n,
            version: b * 100 + n,
          ),
    ];

    testWidgets('300 zones : seules les lignes visibles sont construites', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        state: full(zones: many),
        viewport: const Size(400, 1500),
      );

      expect(
        find.byType(ZoneTile).evaluate().length,
        lessThan(40),
        reason: '300 zones, ecran de 1500 px',
      );
      expect(find.byType(ZoneTile).evaluate(), isNotEmpty);
    });

    testWidgets(
      'defiler jusquau bout : les dernieres zones, puis les personnes, sont atteignables',
      (tester) async {
        await pumpDetail(
          tester,
          viewport: const Size(400, 800),
          state: full(
            zones: many,
            members: [memberRow(id: 'm1', fullName: 'Mourad B.')],
          ),
        );

        await tester.scrollUntilVisible(
          findTextContaining('Mourad B.'),
          400,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump();

        expect(findTextContaining('Mourad B.'), findsOneWidget);
        expect(find.text('Personnes affectées'), findsOneWidget);
      },
    );

    testWidgets('les zones dun meme bloc sont regroupees sous un seul titre', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        state: full(
          zones: [
            zoneRow(id: 'a', roomNumber: 1),
            zoneRow(id: 'b', roomNumber: 2, version: 201),
            zoneRow(id: 'c', block: 'Bloc 02', roomNumber: 1, version: 202),
          ],
        ),
      );

      expect(find.text('Bloc 01'), findsOneWidget);
      expect(find.text('Bloc 02'), findsOneWidget);
    });
  });

  group('« + Zone » selon les droits (CA-011.8)', () {
    testWidgets('visible avec la permission Zones.Create', (tester) async {
      await pumpDetail(tester, state: full());

      expect(find.text('+ Zone'), findsOneWidget);
      await tester.tap(find.text('+ Zone'));
      expect(addZoneRequests.single.id, uv18.id);
    });

    testWidgets('absent (pas grise) sans la permission, ex. chef d\'equipe', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        state: full(),
        user: testUser(
          role: 'ChefEquipe',
          permissions: const ['Sites.View', 'Zones.View'],
        ),
      );

      expect(find.text('+ Zone'), findsNothing);
    });

    testWidgets('absent sur un chantier archive (CA-011.9)', (tester) async {
      await pumpDetail(
        tester,
        state: full(site: siteRow(archivedAt: DateTime.utc(2026, 11, 1))),
      );

      expect(find.text('+ Zone'), findsNothing);
    });

    testWidgets('arabe : « + منطقة »', (tester) async {
      await pumpDetail(tester, locale: const Locale('ar'), state: full());

      expect(find.text('+ منطقة'), findsOneWidget);
    });
  });
}
