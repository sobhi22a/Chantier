import 'package:chantier_mobile/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await db.sitesDao.upsertIfNewer(siteRow());
  });
  tearDown(() => db.close());

  test('upsert idempotent par version', () async {
    expect(
      await db.siteMembersDao.upsertIfNewer(memberRow(version: 300)),
      isTrue,
    );
    expect(
      await db.siteMembersDao.upsertIfNewer(memberRow(version: 300)),
      isFalse,
    );
    expect(
      await db.siteMembersDao.upsertIfNewer(
        memberRow(version: 10, fullName: 'Ancien'),
      ),
      isFalse,
    );
    expect(
      await db.siteMembersDao.upsertIfNewer(
        memberRow(version: 301, role: 'ConducteurTravaux'),
      ),
      isTrue,
    );

    expect(
      (await db.siteMembersDao.getById('member-1'))!.role,
      'ConducteurTravaux',
    );
  });

  test('liste des affectes triee par nom, sans casse', () async {
    await db.siteMembersDao.upsertIfNewer(
      memberRow(id: 'm1', fullName: 'zineb K.'),
    );
    await db.siteMembersDao.upsertIfNewer(
      memberRow(id: 'm2', fullName: 'Ahmed R.', version: 301),
    );
    await db.siteMembersDao.upsertIfNewer(
      memberRow(id: 'm3', fullName: 'Mourad B.', version: 302),
    );

    final rows = await db.siteMembersDao.watchBySite('site-uv18').first;

    expect(rows.map((r) => r.fullName), ['Ahmed R.', 'Mourad B.', 'zineb K.']);
  });

  test('pierre tombale : l\'affectation est supprimee', () async {
    await db.siteMembersDao.upsertIfNewer(memberRow());

    expect(await db.siteMembersDao.deleteMember('member-1'), 1);
    expect(await db.siteMembersDao.getById('member-1'), isNull);
  });

  test('aucune colonne telephone dans la table (CA-017.4)', () async {
    final columns = await db
        .customSelect('PRAGMA table_info(site_members)')
        .get();
    final names = columns.map((c) => c.read<String>('name')).toList();

    expect(
      names.where(
        (n) =>
            n.toLowerCase().contains('phone') ||
            n.toLowerCase().contains('tel'),
      ),
      isEmpty,
    );
  });
}
