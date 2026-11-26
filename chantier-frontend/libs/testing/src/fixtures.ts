import type {
  DeliveryDetailResponse,
  DeliveryResponse,
  FollowUpResponse,
  MaterialRequestDetailResponse,
  MaterialRequestResponse,
  MaterialSettingsResponse,
  MeResponse,
  OrderResponse,
  PhotoResponse,
  ProductResponse,
  SiteMemberResponse,
  SiteResponse,
  SupplierResponse,
  ZoneResponse,
} from "@chantier-frontend/api-core";

// Données entièrement fictives (skill metier-chantier, donnees-test.md : « École UV18 »).

export type TestRole = "Admin" | "Direction" | "ConducteurTravaux" | "Achats" | "ChefChantier" | "ChefEquipe";

const VIEW = ["Sites.View", "Zones.View", "SiteMembers.View"];

/**
 * Matrice des permissions du lot « demandes de matériaux » (contrat `docs/api/demandes-materiaux-livraisons.md`, ADR 0012) :
 * permission → rôles qui l'ont. Reprise telle quelle du contrat ; le serveur reste juge (test `MaterialPermissionMatrixTests`).
 */
export const MATERIAL_MATRIX: Record<string, readonly TestRole[]> = {
  "Products.View": ["Admin", "Direction", "ConducteurTravaux", "Achats", "ChefChantier", "ChefEquipe"],
  "Suppliers.View": ["Admin", "Direction", "ConducteurTravaux", "Achats", "ChefChantier", "ChefEquipe"],
  "Products.Create": ["Admin", "Achats"],
  "Products.Update": ["Admin", "Achats"],
  "Suppliers.Create": ["Admin", "Achats"],
  "Suppliers.Update": ["Admin", "Achats"],
  "SupplierPhone.View": ["Admin", "ConducteurTravaux", "Achats", "ChefChantier"],
  "Prices.View": ["Admin", "Direction", "ConducteurTravaux", "Achats"],
  "Requests.View": ["Admin", "Direction", "ConducteurTravaux", "Achats", "ChefChantier", "ChefEquipe"],
  "Deliveries.View": ["Admin", "Direction", "ConducteurTravaux", "Achats", "ChefChantier", "ChefEquipe"],
  "Requests.Create": ["Admin", "ConducteurTravaux", "ChefChantier", "ChefEquipe"],
  "Requests.Update": ["Admin", "ConducteurTravaux", "ChefChantier", "ChefEquipe"],
  "Requests.UpdateAny": ["Admin", "ConducteurTravaux", "ChefChantier"],
  "Requests.Approve": ["Admin", "ConducteurTravaux"],
  "Requests.Cancel": ["Admin", "ConducteurTravaux", "ChefChantier", "ChefEquipe"],
  "Requests.CancelAny": ["Admin", "ConducteurTravaux"],
  "Requests.Receive": ["Admin", "ChefChantier"],
  "Requests.Settle": ["Admin", "ConducteurTravaux", "Achats"],
  "Requests.Archive": ["Admin", "ConducteurTravaux"],
  "Requests.LinkProduct": ["Admin", "Achats"],
  "Orders.Create": ["Admin", "Achats"],
  "Orders.Update": ["Admin", "Achats"],
  "Orders.Cancel": ["Admin", "Achats"],
  "Deliveries.Create": ["Admin", "ConducteurTravaux", "Achats", "ChefChantier"],
  "Deliveries.Update": ["Admin", "ConducteurTravaux", "Achats", "ChefChantier"],
  "Deliveries.Attach": ["Admin", "ConducteurTravaux", "Achats", "ChefChantier"],
  "DeliveryPhotos.Create": ["Admin", "ConducteurTravaux", "Achats", "ChefChantier"],
  "DeliveryPhotos.View": ["Admin", "Direction", "ConducteurTravaux", "Achats", "ChefChantier"],
};

const materialPermissions = (role: TestRole): string[] =>
  Object.entries(MATERIAL_MATRIX)
    .filter(([, roles]) => roles.includes(role))
    .map(([permission]) => permission);

/** Permissions par rôle : matrice de l'ADR 0005 (socle) et du contrat des matériaux (ADR 0012). */
export const PERMISSIONS_BY_ROLE: Record<TestRole, string[]> = {
  Admin: [
    "AllSites.View",
    ...VIEW,
    "Sites.Create",
    "Sites.Update",
    "Sites.Delete",
    "Zones.Create",
    "Zones.Update",
    "Zones.Delete",
    "SiteMembers.Update",
    "ContractAmount.View",
    ...materialPermissions("Admin"),
  ],
  Direction: [...VIEW, "ContractAmount.View", ...materialPermissions("Direction")],
  ConducteurTravaux: [
    ...VIEW,
    "Zones.Create",
    "Zones.Update",
    "Zones.Delete",
    "ContractAmount.View",
    ...materialPermissions("ConducteurTravaux"),
  ],
  Achats: [...VIEW, ...materialPermissions("Achats")],
  ChefChantier: [...VIEW, "Zones.Create", "Zones.Update", ...materialPermissions("ChefChantier")],
  ChefEquipe: [...VIEW, ...materialPermissions("ChefEquipe")],
};

export const makeMe = (role: TestRole = "ChefChantier", overrides: Partial<MeResponse> = {}): MeResponse => ({
  id: "00000000-0000-7000-8000-000000000001",
  userName: `${role.toLowerCase()}.dev`,
  fullName: "Mourad B.",
  phoneNumber: null,
  role,
  language: "fr",
  permissions: PERMISSIONS_BY_ROLE[role],
  permissionsVersion: "a41f09c2",
  mustChangePassword: false,
  ...overrides,
});

export const SITE_UV18_ID = "00000000-0000-7000-8000-0000000000a1";
export const SITE_OL40_ID = "00000000-0000-7000-8000-0000000000a2";

export const makeSite = (overrides: Partial<SiteResponse> = {}): SiteResponse => ({
  id: SITE_UV18_ID,
  code: "CH-ECO-UV18",
  name: "École UV18",
  nameAr: null,
  type: "School",
  wilaya: "Blida",
  commune: "Boufarik",
  latitude: 36.575,
  longitude: 2.912,
  owner: "Direction des équipements publics (fictive)",
  contractNumber: "M-2026-UV18-001",
  contractAmount: 185000000,
  delayDays: 540,
  odsDate: "2026-03-02",
  contractualEndDate: "2027-08-24",
  archivedAt: null,
  archivedByName: null,
  version: "48213",
  createdAt: "2026-11-24T08:00:00Z",
  createdByName: "Farid L.",
  updatedAt: null,
  updatedByName: null,
  ...overrides,
});

export const makeZone = (overrides: Partial<ZoneResponse> = {}): ZoneResponse => ({
  id: "00000000-0000-7000-8000-0000000000b1",
  siteId: SITE_UV18_ID,
  clientId: null,
  clientCreatedAt: null,
  block: "Bloc 01",
  elevation: 3.4,
  roomType: "Classroom",
  roomNumber: 2,
  roomLabel: null,
  archivedAt: null,
  archivedByName: null,
  version: "48230",
  createdAt: "2026-11-24T08:05:00Z",
  createdByName: "Farid L.",
  updatedAt: null,
  updatedByName: null,
  ...overrides,
});

export const makeMember = (overrides: Partial<SiteMemberResponse> = {}): SiteMemberResponse => ({
  userId: "00000000-0000-7000-8000-0000000000c1",
  fullName: "Mourad B.",
  role: "ChefChantier",
  assignedAt: "2026-11-24T08:10:00Z",
  ...overrides,
});

export const PRODUCT_CEMENT_ID = "00000000-0000-7000-8000-0000000000d1";
export const PRODUCT_SAND_ID = "00000000-0000-7000-8000-0000000000d2";
export const REQUEST_DEM009_ID = "00000000-0000-7000-8000-0000000000e9";
export const SUPPLIER_SIGMA_ID = "00000000-0000-7000-8000-0000000000f1";
export const DELIVERY_LIV006_ID = "00000000-0000-7000-8000-000000000a06";
export const PHOTO_BL_ID = "00000000-0000-7000-8000-000000000b01";

/** Ciment CPJ 42,5 : sacs de 50 kg (donnees-test.md). Fictif. */
export const makeProduct = (overrides: Partial<ProductResponse> = {}): ProductResponse => ({
  id: PRODUCT_CEMENT_ID,
  nameFr: "Ciment CPJ 42,5",
  nameAr: "إسمنت CPJ 42,5",
  category: "Binders",
  allowedUnits: ["sac", "t", "kg"],
  defaultUnit: "sac",
  bagMassKg: 50,
  isActive: true,
  deactivatedAt: null,
  version: "47000",
  createdAt: "2026-11-24T08:00:00Z",
  createdByName: "Farid L.",
  updatedAt: null,
  updatedByName: null,
  ...overrides,
});

export const makeSupplier = (overrides: Partial<SupplierResponse> = {}): SupplierResponse => ({
  id: SUPPLIER_SIGMA_ID,
  name: "Cimenterie Sigma (fictive)",
  phone: "0550 00 00 21",
  productIds: [PRODUCT_CEMENT_ID],
  isActive: true,
  deactivatedAt: null,
  version: "47001",
  createdAt: "2026-11-24T08:00:00Z",
  createdByName: "Farid L.",
  updatedAt: null,
  updatedByName: null,
  ...overrides,
});

/** DEM-009 : 300 sacs de ciment pour le Bloc 01, urgence bloquante (plan, contrat « Réponses »). */
export const makeRequest = (overrides: Partial<MaterialRequestResponse> = {}): MaterialRequestResponse => ({
  id: REQUEST_DEM009_ID,
  siteId: SITE_UV18_ID,
  siteCode: "CH-ECO-UV18",
  clientId: null,
  clientCreatedAt: null,
  number: "DEM-009",
  product: { productId: PRODUCT_CEMENT_ID, name: "Ciment CPJ 42,5", nameAr: "إسمنت CPJ 42,5", freeName: null },
  quantity: { value: 300, unit: "sac" },
  zoneId: "00000000-0000-7000-8000-0000000000b1",
  neededBy: "2026-11-28",
  priority: "Blocking",
  note: "Dalle +10,20",
  status: "Requested",
  statusReason: null,
  isSettled: false,
  overdueDays: 0,
  possibleDuplicateOf: null,
  requestedById: "00000000-0000-7000-8000-000000000001",
  requestedByName: "Mourad B.",
  archivedAt: null,
  archivedByName: null,
  version: "51010",
  createdAt: "2026-11-25T07:00:00Z",
  createdByName: "Mourad B.",
  updatedAt: null,
  updatedByName: null,
  ...overrides,
});

export const makeRequestDetail = (
  overrides: Partial<MaterialRequestDetailResponse> = {},
): MaterialRequestDetailResponse => ({
  ...makeRequest(),
  history: [
    {
      id: "00000000-0000-7000-8000-0000000000a9",
      type: "Created",
      fromStatus: null,
      toStatus: "Requested",
      reasonCode: null,
      reasonNote: null,
      changes: null,
      actorName: "Mourad B.",
      occurredAt: "2026-11-25T07:00:00Z",
      deviceAt: null,
      source: "Api",
    },
  ],
  ...overrides,
});

export const makeMaterialSettings = (overrides: Partial<MaterialSettingsResponse> = {}): MaterialSettingsResponse => ({
  defaultNeededByDays: 3,
  deliveryTolerancePercent: 0,
  maxPhotosPerDelivery: 5,
  maxPhotoBytes: 5242880,
  noteMaxLength: 200,
  reasons: {
    rejection: ["AlreadyOrdered", "StockSufficient", "QuantityToReview", "OverBudget", "Other"],
    requestCancellation: ["EntryError", "NoLongerNeeded", "Duplicate", "Other"],
    orderCancellation: ["SupplierUnavailable", "PriceRefused", "Other"],
    settle: ["SupplierWillNotDeliver", "QuantitySufficient", "Other"],
    deliveryCancellation: ["DoubleEntry", "QuantityError", "RefusedAtReception", "Other"],
    reserve: ["QuantityMissing", "DamagedProduct", "WrongProduct", "Other"],
  },
  ...overrides,
});

/** Commande de DEM-009 : 300 sacs à 780,00 DZD = 234 000,00 DZD. `commercial` : retirer pour un rôle sans `Prices.View`. */
export const makeOrder = (overrides: Partial<OrderResponse> = {}): OrderResponse => ({
  id: "00000000-0000-7000-8000-000000000c09",
  supplierId: SUPPLIER_SIGMA_ID,
  supplierName: "Cimenterie Sigma (fictive)",
  orderDate: "2026-11-25",
  expectedDeliveryDate: "2026-11-26",
  plannedAfterNeedDays: 0,
  note: null,
  version: "51002",
  commercial: { unitPrice: 780, amount: 234000, receivedValue: 0, purchaseOrderNumber: "BC-2026-044" },
  ...overrides,
});

/** Livraison LIV-006 : 10 T de ciment pour DEM-005 (= 200 sacs). Le prix n'y figure que dans `commercial`. */
export const makeDelivery = (overrides: Partial<DeliveryResponse> = {}): DeliveryResponse => ({
  id: DELIVERY_LIV006_ID,
  siteId: SITE_UV18_ID,
  clientId: null,
  clientCreatedAt: null,
  number: "LIV-006",
  requestId: REQUEST_DEM009_ID,
  requestNumber: "DEM-009",
  unattachedReason: null,
  supplierId: SUPPLIER_SIGMA_ID,
  supplierName: "Cimenterie Sigma (fictive)",
  freeSupplierName: null,
  product: { productId: PRODUCT_CEMENT_ID, name: "Ciment CPJ 42,5", nameAr: "إسمنت CPJ 42,5", freeName: null },
  quantity: { value: 10, unit: "t" },
  quantityInRequestUnit: { value: 200, unit: "sac" },
  deliveryDate: "2026-11-04",
  deliveryNoteNumber: "BL-4471",
  missingNote: false,
  conformity: "Conform",
  reserve: null,
  status: "Recorded",
  cancelReason: null,
  possibleDuplicateOf: null,
  photoCount: 0,
  photos: [],
  commercial: { amount: 156000 },
  version: "49800",
  createdAt: "2026-11-04T09:00:00Z",
  createdByName: "Mourad B.",
  updatedAt: null,
  updatedByName: null,
  ...overrides,
});

export const makeDeliveryDetail = (overrides: Partial<DeliveryDetailResponse> = {}): DeliveryDetailResponse => ({
  ...makeDelivery(),
  history: [
    {
      id: "00000000-0000-7000-8000-000000000d01",
      type: "DeliveryRegistered",
      fromStatus: null,
      toStatus: null,
      reasonCode: null,
      reasonNote: null,
      changes: null,
      actorName: "Mourad B.",
      occurredAt: "2026-11-04T09:00:00Z",
      deviceAt: null,
      source: "Api",
    },
  ],
  ...overrides,
});

export const makePhoto = (overrides: Partial<PhotoResponse> = {}): PhotoResponse => ({
  id: PHOTO_BL_ID,
  siteId: SITE_UV18_ID,
  deliveryId: DELIVERY_LIV006_ID,
  clientId: null,
  takenAt: "2026-11-04T08:10:00Z",
  contentType: "image/jpeg",
  sizeBytes: 1480000,
  contentStatus: "Uploaded",
  uploadedAt: "2026-11-04T08:11:00Z",
  version: "49801",
  createdAt: "2026-11-04T08:10:00Z",
  ...overrides,
});

/** Suivi d'un chantier : 400 sacs de ciment à commander = 20 T (jamais mélangés avec d'autres unités). */
export const makeFollowUp = (overrides: Partial<FollowUpResponse> = {}): FollowUpResponse => ({
  counters: { toApprove: 2, toOrder: 1, expected: 3, late: 1, toReceive: 1 },
  toOrderTotals: [
    { productId: PRODUCT_CEMENT_ID, name: "Ciment CPJ 42,5", total: { value: 400, unit: "sac" }, massEquivalent: { value: 20, unit: "t" }, requestCount: 3 },
    { productId: PRODUCT_SAND_ID, name: "Sable 0/3", total: { value: 24, unit: "m3" }, massEquivalent: null, requestCount: 1 },
  ],
  commercial: { orderedAmount: 2206000, receivedValue: 1950000 },
  ...overrides,
});
