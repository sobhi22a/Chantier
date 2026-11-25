import { formatElevation } from "./formatters";

export const ROOM_TYPES = [
  "Classroom",
  "Corridor",
  "Canteen",
  "Refectory",
  "Kitchen",
  "Office",
  "Sanitary",
  "TechnicalRoom",
  "Facade",
  "Other",
] as const;
export type RoomType = (typeof ROOM_TYPES)[number];

/** Les champs d'une zone nécessaires à son libellé (valeurs renvoyées par l'API). */
export interface ZoneLabelInput {
  block: string;
  elevation?: number | null;
  roomType?: RoomType | null;
  roomNumber?: number | null;
  roomLabel?: string | null;
}

export interface ZoneLabelParts {
  block: string;
  /** `+3,40 m` : à afficher de gauche à droite. */
  elevation: string | null;
  /** `Classe 02`. */
  room: string | null;
}

export interface ZoneLabelTexts {
  /** Nom traduit d'un type de local. */
  roomTypeName: (type: RoomType) => string;
  /** Symbole de l'unité de la cote (mètre). */
  meter: string;
}

const ROOM_NUMBER_WIDTH = 2;

/** Libellé d'une zone en trois morceaux : `Bloc 01` · `+3,40 m` · `Classe 02` (CA-009.2). */
export const buildZoneLabelParts = (zone: ZoneLabelInput, texts: ZoneLabelTexts): ZoneLabelParts => {
  const elevation =
    zone.elevation === null || zone.elevation === undefined
      ? null
      : `${formatElevation(zone.elevation)} ${texts.meter}`;

  let room: string | null = null;
  if (zone.roomType === "Other") {
    room = zone.roomLabel?.trim() || texts.roomTypeName("Other");
  } else if (zone.roomType) {
    const name = texts.roomTypeName(zone.roomType);
    room = zone.roomNumber ? `${name} ${String(zone.roomNumber).padStart(ROOM_NUMBER_WIDTH, "0")}` : name;
  }

  return { block: zone.block, elevation, room };
};

export const ZONE_LABEL_SEPARATOR = " · ";

/** Même libellé en texte brut (journaux, tests, `title`). Dans une page, préférer le composant `ZoneLabel`. */
export const formatZoneLabel = (zone: ZoneLabelInput, texts: ZoneLabelTexts): string => {
  const parts = buildZoneLabelParts(zone, texts);
  return [parts.block, parts.elevation, parts.room]
    .filter((part): part is string => Boolean(part))
    .join(ZONE_LABEL_SEPARATOR);
};
