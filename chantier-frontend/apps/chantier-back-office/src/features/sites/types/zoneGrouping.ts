import type { ZoneResponse } from "@chantier-frontend/api-core";
import { ROOM_TYPES } from "@chantier-frontend/i18n";

export interface ZoneBlockGroup {
  block: string;
  zones: ZoneResponse[];
}

const roomTypeRank = (zone: ZoneResponse): number => (zone.roomType ? ROOM_TYPES.indexOf(zone.roomType) : -1);

/** Tri d'affichage : du plus bas au plus haut (une zone sans cote en premier), puis type de local, numéro, libellé (CA-009.2). */
export const compareZones = (a: ZoneResponse, b: ZoneResponse): number => {
  const elevationA = a.elevation ?? Number.NEGATIVE_INFINITY;
  const elevationB = b.elevation ?? Number.NEGATIVE_INFINITY;
  if (elevationA !== elevationB) return elevationA < elevationB ? -1 : 1;
  return (
    roomTypeRank(a) - roomTypeRank(b) ||
    (a.roomNumber ?? 0) - (b.roomNumber ?? 0) ||
    (a.roomLabel ?? "").localeCompare(b.roomLabel ?? "")
  );
};

/** Regroupe les zones par bloc (ordre naturel : « Bloc 2 » avant « Bloc 10 »), chaque bloc trié par `compareZones`. */
export const groupZonesByBlock = (zones: readonly ZoneResponse[]): ZoneBlockGroup[] => {
  const byBlock = new Map<string, ZoneResponse[]>();
  for (const zone of zones) {
    byBlock.set(zone.block, [...(byBlock.get(zone.block) ?? []), zone]);
  }
  return [...byBlock.entries()]
    .sort(([a], [b]) => a.localeCompare(b, "fr", { numeric: true }))
    .map(([block, items]) => ({ block, zones: [...items].sort(compareZones) }));
};
