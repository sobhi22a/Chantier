/** Étiquettes de cache RTK Query (plan socle, W3 : SITES, ZONES, MEMBERS, ME, REFERENCE). */
export const BACK_OFFICE_ENTITY_TAGS = {
  SITES: "SITES",
  ZONES: "ZONES",
  MEMBERS: "MEMBERS",
  ME: "ME",
  REFERENCE: "REFERENCE",
} as const;

export type BackOfficeEntityTag = (typeof BACK_OFFICE_ENTITY_TAGS)[keyof typeof BACK_OFFICE_ENTITY_TAGS];
