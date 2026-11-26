import { z } from "zod";

import type { CreateOrderRequest, UpdateOrderRequest } from "@chantier-frontend/api-core";
import { todayDateOnly } from "@chantier-frontend/i18n";

import type { RequestDetail } from "./requestTypes";

export const PURCHASE_ORDER_MAX = 50;
export const ORDER_NOTE_MAX = 200;
const DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;
/** Prix en dinars : jusqu'à deux décimales, virgule ou point. Le serveur reste juge (> 0, 2 décimales au plus). */
const PRICE_PATTERN = /^\d+(?:[.,]\d{1,2})?$/;

export const parsePrice = (text: string): number | null => {
  const trimmed = text.replace(/[\s\u00A0]/g, "");
  if (!PRICE_PATTERN.test(trimmed)) return null;
  const value = Number(trimmed.replace(",", "."));
  return value > 0 ? value : null;
};

// Les messages sont des clés de traduction (ADR 0007) ; chaque règle est aussi contrôlée par le serveur.
export const orderFormSchema = z
  .object({
    supplierId: z.string().min(1, "materials:order.supplierRequired"),
    orderDate: z.string().regex(DATE_PATTERN, "materials:order.dateRequired").nullable(),
    expectedDeliveryDate: z.string().regex(DATE_PATTERN, "materials:order.dateRequired").nullable(),
    unitPrice: z.string(),
    purchaseOrderNumber: z.string().max(PURCHASE_ORDER_MAX, "materials:order.purchaseOrderTooLong"),
    note: z.string().max(ORDER_NOTE_MAX, "materials:order.noteTooLong"),
  })
  .superRefine((values, context) => {
    if (values.orderDate === null) {
      context.addIssue({ code: "custom", path: ["orderDate"], message: "materials:order.dateRequired" });
    } else if (values.orderDate > todayDateOnly()) {
      context.addIssue({ code: "custom", path: ["orderDate"], message: "materials:order.orderDateFuture" });
    }
    if (values.orderDate !== null && values.expectedDeliveryDate !== null && values.expectedDeliveryDate < values.orderDate) {
      context.addIssue({ code: "custom", path: ["expectedDeliveryDate"], message: "materials:order.expectedBeforeOrder" });
    }
    if (values.unitPrice.trim() !== "" && parsePrice(values.unitPrice) === null) {
      context.addIssue({ code: "custom", path: ["unitPrice"], message: "materials:order.priceInvalid" });
    }
  });

export type OrderFormValues = z.infer<typeof orderFormSchema>;

export const emptyOrderFormValues = (defaults: Partial<OrderFormValues> = {}): OrderFormValues => ({
  supplierId: "",
  orderDate: todayDateOnly(),
  expectedDeliveryDate: null,
  unitPrice: "",
  purchaseOrderNumber: "",
  note: "",
  ...defaults,
});

const priceToText = (value: number | null | undefined): string => (value === null || value === undefined ? "" : String(value).replace(".", ","));

export const orderToFormValues = (request: RequestDetail): OrderFormValues => {
  const order = request.order;
  return {
    supplierId: order?.supplierId ?? "",
    orderDate: order?.orderDate ?? todayDateOnly(),
    expectedDeliveryDate: order?.expectedDeliveryDate ?? null,
    unitPrice: priceToText(order?.commercial?.unitPrice),
    purchaseOrderNumber: order?.commercial?.purchaseOrderNumber ?? "",
    note: order?.note ?? "",
  };
};

const nullIfEmpty = (value: string): string | null => (value.trim() === "" ? null : value.trim());

/**
 * Création : le prix et le n° de bon de commande ne partent que si l'utilisateur y a droit (`withCommercial`, issu de
 * `Prices.View`). `clientId` rend un renvoi idempotent (CA-MAT-005.5). Le montant n'est jamais envoyé : le serveur le calcule.
 */
export const toCreateOrderRequest = (values: OrderFormValues, clientId: string, withCommercial: boolean): CreateOrderRequest => ({
  clientId,
  supplierId: values.supplierId,
  orderDate: values.orderDate,
  expectedDeliveryDate: values.expectedDeliveryDate,
  note: nullIfEmpty(values.note),
  ...(withCommercial
    ? { unitPrice: values.unitPrice.trim() === "" ? null : parsePrice(values.unitPrice), purchaseOrderNumber: nullIfEmpty(values.purchaseOrderNumber) }
    : {}),
});

/**
 * Modification : une valeur déjà posée se remplace mais ne s'efface pas (écart n°11 du contrat) ; une clé absente ou nulle
 * ne change rien. On n'envoie donc que ce qui a changé et n'est pas vide.
 */
export const toUpdateOrderRequest = (values: OrderFormValues, request: RequestDetail, withCommercial: boolean): UpdateOrderRequest => {
  const initial = orderToFormValues(request);
  const body: UpdateOrderRequest = { version: request.order?.version ?? "" };
  if (values.supplierId !== initial.supplierId) body.supplierId = values.supplierId;
  if (values.expectedDeliveryDate !== null && values.expectedDeliveryDate !== initial.expectedDeliveryDate) body.expectedDeliveryDate = values.expectedDeliveryDate;
  if (values.note.trim() !== "" && values.note.trim() !== initial.note) body.note = values.note.trim();
  if (withCommercial) {
    const price = values.unitPrice.trim() === "" ? null : parsePrice(values.unitPrice);
    if (price !== null && values.unitPrice.trim() !== initial.unitPrice) body.unitPrice = price;
    if (values.purchaseOrderNumber.trim() !== "" && values.purchaseOrderNumber.trim() !== initial.purchaseOrderNumber) {
      body.purchaseOrderNumber = values.purchaseOrderNumber.trim();
    }
  }
  return body;
};
