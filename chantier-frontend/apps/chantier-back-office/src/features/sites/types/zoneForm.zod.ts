import { z } from "zod";

import type { CreateZoneRequest, UpdateZoneRequest, ZoneResponse } from "@chantier-frontend/api-core";
import { ROOM_TYPES, type RoomType } from "@chantier-frontend/i18n";

/** Bornes de la cote en mètres (H-15). Le serveur les applique (paramétrables) : ici, simple confort de saisie. */
export const ELEVATION_MIN = -20;
export const ELEVATION_MAX = 60;
export const ROOM_NUMBER_MAX = 999;

// `3,4` et `3.4` donnent +3,40 (CA-011.2) ; deux décimales au plus ; le signe moins peut être « − » ou « - ».
const ELEVATION_PATTERN = /^[+\-−]?\d{1,2}(?:[.,]\d{1,2})?$/;

/** Cote saisie → nombre. Vide : `null`. Illisible : `Number.NaN`. `±0` et `0` valent zéro. */
export const parseElevation = (text: string): number | null => {
  const trimmed = text.trim();
  if (trimmed === "") return null;
  const value = trimmed.replace(/^\u00b1/, "");
  if (!ELEVATION_PATTERN.test(value)) return Number.NaN;
  return Number(value.replace("\u2212", "-").replace(",", "."));
};

export const zoneFormSchema = z
  .object({
    block: z.string().trim().min(1, "sites:zones.blockRequired").max(50, "sites:zones.blockRequired"),
    elevation: z.string(),
    roomType: z.union([z.enum(ROOM_TYPES), z.literal("")]),
    roomNumber: z.union([z.number().min(1, "sites:zones.roomNumberInvalid").max(ROOM_NUMBER_MAX, "sites:zones.roomNumberInvalid").refine(Number.isInteger, "sites:zones.roomNumberInvalid"), z.literal("")], {
      error: "sites:zones.roomNumberInvalid",
    }),
    roomLabel: z.string().trim().max(100),
  })
  .superRefine((values, context) => {
    const elevation = parseElevation(values.elevation);
    if (elevation !== null && Number.isNaN(elevation)) {
      context.addIssue({ code: "custom", path: ["elevation"], message: "sites:zones.elevationInvalid" });
    } else if (elevation !== null && (elevation < ELEVATION_MIN || elevation > ELEVATION_MAX)) {
      context.addIssue({ code: "custom", path: ["elevation"], message: "sites:zones.elevationOutOfRange" });
    }
  });

export type ZoneFormValues = z.infer<typeof zoneFormSchema>;

export const emptyZoneFormValues = (defaults: Partial<ZoneFormValues> = {}): ZoneFormValues => ({
  block: "",
  elevation: "",
  roomType: "",
  roomNumber: "",
  roomLabel: "",
  ...defaults,
});

const elevationToText = (value: number | null | undefined): string =>
  value === null || value === undefined ? "" : String(value).replace(".", ",");

export const zoneToFormValues = (zone: ZoneResponse): ZoneFormValues => ({
  block: zone.block,
  elevation: elevationToText(zone.elevation),
  roomType: zone.roomType ?? "",
  roomNumber: zone.roomNumber ?? "",
  roomLabel: zone.roomLabel ?? "",
});

const toZoneBody = (values: ZoneFormValues): Omit<CreateZoneRequest, "clientId" | "clientCreatedAt"> => {
  const roomType: RoomType | null = values.roomType === "" ? null : values.roomType;
  const elevation = parseElevation(values.elevation);
  return {
    block: values.block.trim(),
    elevation: elevation === null || Number.isNaN(elevation) ? null : elevation,
    roomType,
    // Le numéro exige un type de local ; le libellé libre n'existe que pour « Autre » (serveur : H-07).
    roomNumber: roomType === null || values.roomNumber === "" ? null : values.roomNumber,
    roomLabel: roomType === "Other" && values.roomLabel.trim() !== "" ? values.roomLabel.trim() : null,
  };
};

// Créée depuis le back-office : pas de clientId (réservé au mobile hors ligne).
export const toCreateZoneRequest = (values: ZoneFormValues): CreateZoneRequest => toZoneBody(values);

export const toUpdateZoneRequest = (values: ZoneFormValues, version: string): UpdateZoneRequest => ({
  version,
  ...toZoneBody(values),
});
