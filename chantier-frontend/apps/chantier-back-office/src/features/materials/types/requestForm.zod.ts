import { z } from "zod";

import type { CreateRequestRequest, UpdateRequestRequest } from "@chantier-frontend/api-core";
import { MEASURE_UNITS } from "@chantier-frontend/i18n";

import { checkQuantity, normalizeQuantityText } from "./quantityMirror";
import { REQUEST_PRIORITIES, type RequestDetail } from "./requestTypes";

export const FREE_NAME_MIN = 3;
export const FREE_NAME_MAX = 100;
export const NOTE_MAX = 200;
const DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

export type ProductMode = "catalog" | "free";

// Les messages sont des clés de traduction, traduites à l'affichage (ADR 0007). Le serveur reste juge de chaque règle :
// ces contrôles évitent un aller-retour inutile (le client n'a jamais autorité).
export const requestFormSchema = z
  .object({
    siteId: z.string().min(1, "materials:form.siteRequired"),
    productMode: z.enum(["catalog", "free"]),
    productId: z.string(),
    freeProductName: z.string().trim().max(FREE_NAME_MAX, "materials:form.freeNameInvalid"),
    quantity: z.string(),
    unit: z.union([z.enum(MEASURE_UNITS), z.literal("")]),
    zoneId: z.string(),
    neededBy: z.string().regex(DATE_PATTERN, "materials:form.dateRequired").nullable(),
    priority: z.enum(REQUEST_PRIORITIES),
    note: z.string().max(NOTE_MAX, "materials:form.noteTooLong"),
  })
  .superRefine((values, context) => {
    if (values.productMode === "catalog" && values.productId === "") {
      context.addIssue({ code: "custom", path: ["productId"], message: "materials:form.productRequired" });
    }
    if (values.productMode === "free" && values.freeProductName.trim().length < FREE_NAME_MIN) {
      context.addIssue({ code: "custom", path: ["freeProductName"], message: "materials:form.freeNameInvalid" });
    }
    if (values.unit === "") {
      context.addIssue({ code: "custom", path: ["unit"], message: "materials:form.unitRequired" });
    }
    const text = normalizeQuantityText(values.quantity);
    if (values.quantity.trim() === "") {
      context.addIssue({ code: "custom", path: ["quantity"], message: "materials:form.quantityRequired" });
    } else if (text === null) {
      context.addIssue({ code: "custom", path: ["quantity"], message: "materials:form.quantityInvalid" });
    } else if (values.unit !== "") {
      const problem = checkQuantity(text, values.unit);
      if (problem === "QUANTITE_ENTIERE_REQUISE") context.addIssue({ code: "custom", path: ["quantity"], message: "errors:QUANTITE_ENTIERE_REQUISE" });
      else if (problem) context.addIssue({ code: "custom", path: ["quantity"], message: "materials:form.quantityInvalid" });
    }
  });

export type RequestFormValues = z.infer<typeof requestFormSchema>;

export const emptyRequestFormValues = (defaults: Partial<RequestFormValues> = {}): RequestFormValues => ({
  siteId: "",
  productMode: "catalog",
  productId: "",
  freeProductName: "",
  quantity: "",
  unit: "",
  zoneId: "",
  neededBy: null,
  priority: "Normal",
  note: "",
  ...defaults,
});

const quantityToText = (value: number): string => String(value).replace(".", ",");

export const requestToFormValues = (request: RequestDetail): RequestFormValues => {
  const catalog = request.product.productId !== null;
  return {
    siteId: request.siteId,
    productMode: catalog ? "catalog" : "free",
    productId: request.product.productId ?? "",
    freeProductName: catalog ? "" : (request.product.freeName ?? ""),
    quantity: quantityToText(request.quantity.value),
    unit: request.quantity.unit,
    zoneId: request.zoneId ?? "",
    neededBy: request.neededBy,
    priority: request.priority,
    note: request.note ?? "",
  };
};

const quantityBody = (values: RequestFormValues) => ({
  value: Number(normalizeQuantityText(values.quantity)),
  unit: values.unit === "" ? null : values.unit,
});

/** Création depuis le back-office : pas de `clientId` (réservé au mobile hors ligne). */
export const toCreateRequestRequest = (values: RequestFormValues): CreateRequestRequest => ({
  productId: values.productMode === "catalog" ? values.productId : null,
  freeProductName: values.productMode === "free" ? values.freeProductName.trim() : null,
  quantity: quantityBody(values),
  zoneId: values.zoneId === "" ? null : values.zoneId,
  neededBy: values.neededBy,
  priority: values.priority,
  note: values.note.trim() === "" ? null : values.note.trim(),
});

/**
 * Modification : seuls les champs présents changent. Après la validation, produit, quantité, unité et zone sont verrouillés
 * (`DEMANDE_VERROUILLEE`) : on n'envoie alors que date, urgence et remarque. Une zone vidée n'est pas envoyée : `PUT` ne sait pas
 * retirer une zone (écart n°6 du contrat) ; une clé absente ne change rien.
 */
export const toUpdateRequestRequest = (values: RequestFormValues, version: string, allFields: boolean): UpdateRequestRequest => ({
  version,
  neededBy: values.neededBy,
  priority: values.priority,
  // Une chaîne vide efface la remarque (contrat).
  note: values.note.trim(),
  ...(allFields
    ? {
        productId: values.productMode === "catalog" ? values.productId : null,
        freeProductName: values.productMode === "free" ? values.freeProductName.trim() : null,
        quantity: quantityBody(values),
        ...(values.zoneId === "" ? {} : { zoneId: values.zoneId }),
      }
    : {}),
});
