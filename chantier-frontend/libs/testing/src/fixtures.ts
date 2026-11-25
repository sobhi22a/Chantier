import type { MeResponse, SiteMemberResponse, SiteResponse, ZoneResponse } from "@chantier-frontend/api-core";

// Données entièrement fictives (skill metier-chantier, donnees-test.md : « École UV18 »).

export type TestRole = "Admin" | "Direction" | "ConducteurTravaux" | "Achats" | "ChefChantier" | "ChefEquipe";

const VIEW = ["Sites.View", "Zones.View", "SiteMembers.View"];

/** Permissions par rôle : matrice de l'ADR 0005. */
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
  ],
  Direction: [...VIEW, "ContractAmount.View"],
  ConducteurTravaux: [...VIEW, "Zones.Create", "Zones.Update", "Zones.Delete", "ContractAmount.View"],
  Achats: [...VIEW],
  ChefChantier: [...VIEW, "Zones.Create", "Zones.Update"],
  ChefEquipe: [...VIEW],
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
