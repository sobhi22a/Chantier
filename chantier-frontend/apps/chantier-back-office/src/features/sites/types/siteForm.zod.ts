import { z } from "zod";

import type { CreateSiteRequest, SiteResponse, SiteType, UpdateSiteRequest } from "@chantier-frontend/api-core";

export const SITE_TYPES = ["School", "Housing", "PublicFacility", "Other"] as const satisfies readonly SiteType[];

// Les messages sont des clés de traduction, traduites à l'affichage (ADR 0007). Le serveur reste juge :
// ces règles évitent seulement un aller-retour inutile.
const required = "sites:form.required";
const numberInvalid = "sites:form.numberInvalid";

const optionalNumber = (schema: z.ZodNumber) => z.union([schema, z.literal("")], { error: numberInvalid });

export const siteFormSchema = z.object({
  code: z.string().trim().regex(/^[A-Z0-9][A-Z0-9-]{2,29}$/, "sites:form.codeInvalid"),
  name: z.string().trim().min(1, required).max(200),
  nameAr: z.string().trim().max(200),
  type: z.enum(SITE_TYPES, { error: required }),
  wilaya: z.string().trim().min(1, required).max(100),
  commune: z.string().trim().min(1, required).max(100),
  owner: z.string().trim().min(1, required).max(200),
  contractNumber: z.string().trim().max(100),
  contractAmount: optionalNumber(z.number().min(0, numberInvalid)),
  delayDays: optionalNumber(z.number().min(1, "sites:form.delayInvalid").refine(Number.isInteger, "sites:form.delayInvalid")),
  // Date complète `YYYY-MM-DD` choisie au calendrier ; jamais saisie à la main (CA-008.4).
  odsDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "errors:DATE_INVALIDE").nullable(),
  latitude: optionalNumber(z.number().min(-90, numberInvalid).max(90, numberInvalid)),
  longitude: optionalNumber(z.number().min(-180, numberInvalid).max(180, numberInvalid)),
}).superRefine((values, context) => {
  // Latitude et longitude vont ensemble (contrat : « va avec la longitude »).
  if ((values.latitude === "") !== (values.longitude === "")) {
    const missing = values.latitude === "" ? "latitude" : "longitude";
    context.addIssue({ code: "custom", path: [missing], message: "sites:form.coordinatesTogether" });
  }
});

export type SiteFormValues = z.infer<typeof siteFormSchema>;

export const emptySiteFormValues = (): SiteFormValues => ({
  code: "",
  name: "",
  nameAr: "",
  type: "School",
  wilaya: "",
  commune: "",
  owner: "",
  contractNumber: "",
  contractAmount: "",
  delayDays: "",
  odsDate: null,
  latitude: "",
  longitude: "",
});

export const siteToFormValues = (site: SiteResponse): SiteFormValues => ({
  code: site.code,
  name: site.name,
  nameAr: site.nameAr ?? "",
  type: site.type,
  wilaya: site.wilaya,
  commune: site.commune,
  owner: site.owner,
  contractNumber: site.contractNumber ?? "",
  contractAmount: site.contractAmount ?? "",
  delayDays: site.delayDays ?? "",
  odsDate: site.odsDate ?? null,
  latitude: site.latitude ?? "",
  longitude: site.longitude ?? "",
});

const textOrNull = (value: string): string | null => (value.trim() === "" ? null : value.trim());
const numberOrNull = (value: number | ""): number | null => (value === "" ? null : value);

type SiteBody = Omit<CreateSiteRequest, "code">;

const toSiteBody = (values: SiteFormValues): SiteBody => ({
  name: values.name.trim(),
  nameAr: textOrNull(values.nameAr),
  type: values.type,
  wilaya: values.wilaya.trim(),
  commune: values.commune.trim(),
  owner: values.owner.trim(),
  contractNumber: textOrNull(values.contractNumber),
  contractAmount: numberOrNull(values.contractAmount),
  delayDays: numberOrNull(values.delayDays),
  odsDate: values.odsDate,
  latitude: numberOrNull(values.latitude),
  longitude: numberOrNull(values.longitude),
});

export const toCreateSiteRequest = (values: SiteFormValues): CreateSiteRequest => ({
  code: values.code.trim(),
  ...toSiteBody(values),
});

/** `contractAmount` n'est envoyé que si l'utilisateur peut le voir : sinon le serveur effacerait le montant. */
export const toUpdateSiteRequest = (values: SiteFormValues, version: string, includeAmount: boolean): UpdateSiteRequest => {
  const { contractAmount, ...body } = toSiteBody(values);
  return { version, ...body, ...(includeAmount ? { contractAmount } : {}) };
};
