import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/data/deliveries_repository.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';

import 'fixtures.dart';
import 'test_database.dart';

const harnessSite = 'site-uv18';
const harnessProduct = 'prod-ciment';

/// Chef d'equipe : signale et suit **ses** demandes.
AuthUser chefEquipe({String id = 'user-equipe'}) => AuthUser(
  id: id,
  userName: 'equipe.dev',
  fullName: 'Nadir S.',
  role: 'ChefEquipe',
  language: 'fr',
  mustChangePassword: false,
  permissions: const [
    'Requests.View',
    'Requests.Create',
    'Requests.Update',
    'Requests.Cancel',
    'Deliveries.View',
  ],
  permissionsVersion: 'v1',
);

/// Chef de chantier : saisit tout sur ses chantiers (pas de validation ni d'annulation des autres).
AuthUser chefChantier({String id = 'user-chef'}) => AuthUser(
  id: id,
  userName: 'chef.dev',
  fullName: 'Mourad B.',
  role: 'ChefChantier',
  language: 'fr',
  mustChangePassword: false,
  permissions: const [
    'Requests.View',
    'Requests.Create',
    'Requests.Update',
    'Requests.UpdateAny',
    'Requests.Cancel',
    'Requests.Receive',
    'Deliveries.View',
    'Deliveries.Create',
    'Deliveries.Update',
    'Deliveries.Attach',
    'DeliveryPhotos.Create',
    'DeliveryPhotos.View',
    'SupplierPhone.View',
  ],
  permissionsVersion: 'v1',
);

/// Conducteur de travaux : valide, refuse, annule toutes les demandes.
AuthUser conducteur({String id = 'user-conducteur'}) => AuthUser(
  id: id,
  userName: 'conducteur.dev',
  fullName: 'Karim A.',
  role: 'ConducteurTravaux',
  language: 'fr',
  mustChangePassword: false,
  permissions: const [
    'Requests.View',
    'Requests.Create',
    'Requests.Update',
    'Requests.UpdateAny',
    'Requests.Approve',
    'Requests.Cancel',
    'Requests.CancelAny',
    'Deliveries.View',
    'Deliveries.Create',
    'Deliveries.Update',
    'Deliveries.Attach',
    'DeliveryPhotos.Create',
    'DeliveryPhotos.View',
    'SupplierPhone.View',
  ],
  permissionsVersion: 'v1',
);

/// Base en memoire, depots et donnees fictives du chantier « Ecole UV18 » (ciment, sable, zone).
class MaterialsHarness {
  MaterialsHarness({DateTime? now})
    : clock = now ?? DateTime.utc(2026, 11, 25, 9) {
    db = createTestDatabase();
    outbox = OutboxRepository(db);
    materials = MaterialsRepository(
      database: db,
      outbox: outbox,
      now: () => clock,
    );
    deliveries = DeliveriesRepository(
      database: db,
      outbox: outbox,
      now: () => clock,
    );
    zones = ZonesRepository(database: db, outbox: outbox, now: () => clock);
  }

  late final AppDatabase db;
  late final OutboxRepository outbox;
  late final MaterialsRepository materials;
  late final DeliveriesRepository deliveries;
  late final ZonesRepository zones;
  DateTime clock;

  Future<void> seed({bool withHistory = false}) async {
    await db.sitesDao.upsertIfNewer(siteRow());
    await db.zonesDao.upsertIfNewer(zoneRow());
    await db.productsDao.upsertIfNewer(productRow());
    await db.productsDao.upsertIfNewer(
      productRow(
        id: 'prod-sable',
        nameFr: 'Sable 0/3',
        nameAr: 'رمل 0/3',
        category: 'Aggregates',
        allowedUnits: const ['m3', 't'],
        defaultUnit: 'm3',
        bagMassKg: null,
        version: 401,
      ),
    );
    await db.productsDao.upsertIfNewer(
      productRow(
        id: 'prod-rond',
        nameFr: 'Rond HA Ø12',
        nameAr: null,
        category: 'Steel',
        allowedUnits: const ['t', 'kg', 'u'],
        defaultUnit: 't',
        bagMassKg: null,
        version: 402,
      ),
    );
    if (withHistory) {
      await db.materialRequestsDao.upsertIfNewer(
        requestRow(
          id: 'old-1',
          number: 'DEM-001',
          createdAt: DateTime.utc(2026, 11, 20),
          status: 'Received',
        ),
      );
    }
  }

  Future<void> dispose() => db.close();
}
