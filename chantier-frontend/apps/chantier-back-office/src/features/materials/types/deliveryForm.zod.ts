import { z } from "zod";

import type { CreateDeliveryRequest, MaterialRequestResponse, UpdateDeliveryRequest } from "@chantier-frontend/api-core";
import { MEASURE_UNITS, todayDateOnly } from "@chantier-frontend/i18n";

import { DELIVERY_NOTE_MAX, FREE_NAME_MAX, FREE_NAME_MIN, type DeliveryDetail } from "./deliveryTypes";
import { checkQuantity, normalizeQuantityText } from "./quantityMirror";

export const RESERVE_NOTE_MAX = 200;
const DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;
export const OTHER_REASON = "Other";

// Les messages sont des clés de traduction (ADR 0007). Le serveur reste juge de chaque règle : ces contrôles évitent un
// aller-retour inutile (le client n'a jamais autorité sur un calcul ou un statut).
export const deliveryFormSchema = z
  .object({
    mode: z.enum(["create", "edit"]),
    siteId: z.string(),
    requestId: z.string(),
    productMode: z.enum(["catalog", "free"]),
    productId: z.string(),
    freeProductName: z.string().trim().max(FREE_NAME_MAX, "materials:deliveries.form.freeNameInvalid"),
    supplierMode: z.enum(["catalog", "free"]),
    supplierId: z.string(),
    freeSupplierName: z.string().trim().max(FREE_NAME_MAX, "materials:deliveries.form.freeNameInvalid"),
    quantity: z.string(),
    unit: z.union([z.enum(MEASURE_UNITS), z.literal("")]),
    deliveryDate: z.string().regex(DATE_PATTERN, "materials:deliveries.form.dateRequired").nullable(),
    deliveryNoteNumber: z.string().max(DELIVERY_NOTE_MAX, "materials:deliveries.form.noteTooLong"),
    conformity: z.enum(["Conform", "WithReserve"]),
    reserveReasonCode: z.string(),
    reserveNote: z.string().max(RESERVE_NOTE_MAX, "materials:deliveries.form.reasonNoteTooLong"),
  })
  .superRefine((values, context) => {
    const issue = (path: string, message: string) => context.addIssue({ code: "custom", path: [path], message });

    if (values.mode === "create") {
      if (values.siteId === "") issue("siteId", "materials:deliveries.form.siteRequired");
      // Avec une demande, le produit est celui de la demande (le serveur le force : `PRODUIT_DIFFERENT` sinon).
      if (values.requestId === "") {
        if (values.productMode === "catalog" && values.productId === "") issue("productId", "materials:deliveries.form.productRequired");
        if (values.productMode === "free" && values.freeProductName.trim().length < FREE_NAME_MIN) {
          issue("freeProductName", "materials:deliveries.form.freeNameInvalid");
        }
      }
      if (values.supplierMode === "catalog" && values.supplierId === "") issue("supplierId", "materials:deliveries.form.supplierRequired");
      if (values.supplierMode === "free" && values.freeSupplierName.trim().length < FREE_NAME_MIN) {
        issue("freeSupplierName", "materials:deliveries.form.freeNameInvalid");
      }
    }

    if (values.unit === "") issue("unit", "materials:deliveries.form.unitRequired");
    const text = normalizeQuantityText(values.quantity);
    if (values.quantity.trim() === "") issue("quantity", "materials:deliveries.form.quantityRequired");
    else if (text === null) issue("quantity", "materials:deliveries.form.quantityInvalid");
    else if (values.unit !== "") {
      const problem = checkQuantity(text, values.unit);
      if (problem === "QUANTITE_ENTIERE_REQUISE") issue("quantity", "errors:QUANTITE_ENTIERE_REQUISE");
      else if (problem) issue("quantity", "materials:deliveries.form.quantityInvalid");
    }

    if (values.deliveryDate === null) issue("deliveryDate", "materials:deliveries.form.dateRequired");
    else if (values.deliveryDate > todayDateOnly()) issue("deliveryDate", "materials:deliveries.form.dateFuture");

    if (values.conformity === "WithReserve") {
      if (values.reserveReasonCode === "") issue("reserveReasonCode", "materials:deliveries.form.reasonRequired");
      if (values.reserveReasonCode === OTHER_REASON && values.reserveNote.trim() === "") {
        issue("reserveNote", "materials:deliveries.form.reasonNoteRequired");
      }
    }
  });

export type DeliveryFormValues = z.infer<typeof deliveryFormSchema>;

export const emptyDeliveryFormValues = (defaults: Partial<DeliveryFormValues> = {}): DeliveryFormValues => ({
  mode: "create",
  siteId: "",
  requestId: "",
  productMode: "catalog",
  productId: "",
  freeProductName: "",
  supplierMode: "catalog",
  supplierId: "",
  freeSupplierName: "",
  quantity: "",
  unit: "",
  deliveryDate: todayDateOnly(),
  deliveryNoteNumber: "",
  conformity: "Conform",
  reserveReasonCode: "",
  reserveNote: "",
  ...defaults,
});

/**
 * Valeurs proposées quand on choisit une demande (CA-MAT-006.1) : produit et unité de la demande, quantité = reste à livrer,
 * fournisseur de la commande. Toutes viennent du serveur ; le client ne calcule rien.
 */
export const requestDefaults = (request: MaterialRequestResponse): Partial<DeliveryFormValues> => {
  const remaining = request.remainingQuantity ?? request.quantity;
  return {
    requestId: request.id,
    productMode: request.product.productId ? "catalog" : "free",
    productId: request.product.productId ?? "",
    freeProductName: request.product.freeName ?? "",
    unit: request.quantity.unit,
    quantity: quantityToText(remaining.value),
    ...(request.order?.supplierId ? { supplierMode: "catalog" as const, supplierId: request.order.supplierId } : {}),
  };
};

const quantityToText = (value: number): string => String(value).replace(".", ",");

export const deliveryToFormValues = (delivery: DeliveryDetail): DeliveryFormValues => ({
  mode: "edit",
  siteId: delivery.siteId,
  requestId: delivery.requestId ?? "",
  productMode: delivery.product.productId !== null ? "catalog" : "free",
  productId: delivery.product.productId ?? "",
  freeProductName: delivery.product.freeName ?? "",
  supplierMode: delivery.supplierId ? "catalog" : "free",
  supplierId: delivery.supplierId ?? "",
  freeSupplierName: delivery.freeSupplierName ?? "",
  quantity: quantityToText(delivery.quantity.value),
  unit: delivery.quantity.unit,
  deliveryDate: delivery.deliveryDate,
  deliveryNoteNumber: delivery.deliveryNoteNumber ?? "",
  conformity: delivery.conformity,
  reserveReasonCode: delivery.reserve?.code ?? "",
  reserveNote: delivery.reserve?.note ?? "",
});

const quantityBody = (values: DeliveryFormValues) => ({
  value: Number(normalizeQuantityText(values.quantity)),
  unit: values.unit === "" ? null : values.unit,
});

const nullIfEmpty = (value: string): string | null => (value.trim() === "" ? null : value.trim());

/** Création : `clientId` posé à l'ouverture du formulaire (un double appui renvoie la même livraison, un seul numéro). */
export const toCreateDeliveryRequest = (values: DeliveryFormValues, clientId: string): CreateDeliveryRequest => ({
  clientId,
  requestId: nullIfEmpty(values.requestId),
  supplierId: values.supplierMode === "catalog" ? values.supplierId : null,
  freeSupplierName: values.supplierMode === "free" ? values.freeSupplierName.trim() : null,
  // Avec une demande, c'est le produit de la demande : on n'en envoie pas un autre.
  productId: values.requestId === "" && values.productMode === "catalog" ? values.productId : null,
  freeProductName: values.requestId === "" && values.productMode === "free" ? values.freeProductName.trim() : null,
  quantity: quantityBody(values),
  deliveryDate: values.deliveryDate,
  deliveryNoteNumber: nullIfEmpty(values.deliveryNoteNumber),
  conformity: values.conformity,
  reserveReasonCode: values.conformity === "WithReserve" ? values.reserveReasonCode : null,
  reserveNote: values.conformity === "WithReserve" ? nullIfEmpty(values.reserveNote) : null,
});

/**
 * Correction : seuls les champs modifiés partent. Une valeur déjà posée (n° de BL, remarque) se remplace mais ne s'efface pas
 * (écart n°19 du contrat) : un champ vidé n'est pas envoyé.
 */
export const toUpdateDeliveryRequest = (values: DeliveryFormValues, delivery: DeliveryDetail): UpdateDeliveryRequest => {
  const initial = deliveryToFormValues(delivery);
  const body: UpdateDeliveryRequest = { version: delivery.version };
  const quantity = quantityBody(values);
  if (quantity.value !== delivery.quantity.value || quantity.unit !== delivery.quantity.unit) body.quantity = quantity;
  if (values.deliveryDate !== initial.deliveryDate) body.deliveryDate = values.deliveryDate;
  const note = values.deliveryNoteNumber.trim();
  if (note !== "" && note !== initial.deliveryNoteNumber) body.deliveryNoteNumber = note;
  if (values.conformity !== initial.conformity) body.conformity = values.conformity;
  if (values.conformity === "WithReserve") {
    if (values.reserveReasonCode !== initial.reserveReasonCode) body.reserveReasonCode = values.reserveReasonCode;
    const reserveNote = values.reserveNote.trim();
    if (reserveNote !== "" && reserveNote !== initial.reserveNote) body.reserveNote = reserveNote;
  }
  return body;
};
