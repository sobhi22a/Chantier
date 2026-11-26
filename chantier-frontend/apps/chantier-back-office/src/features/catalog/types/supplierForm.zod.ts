import { z } from "zod";

import type { CreateSupplierRequest, SupplierResponse, UpdateSupplierRequest } from "@chantier-frontend/api-core";

const NAME_MAX = 150;

/** Format algérien : 05, 06 ou 07 suivi de 8 chiffres, espaces facultatifs (contrat). Le serveur reste juge. */
const PHONE_PATTERN = /^0[5-7](?:\s?\d){8}$/;

export const supplierFormSchema = z.object({
  name: z.string().trim().min(1, "catalog:supplierForm.nameRequired").max(NAME_MAX, "catalog:supplierForm.nameRequired"),
  phone: z.string().trim().refine((value) => value === "" || PHONE_PATTERN.test(value), "catalog:supplierForm.phoneInvalid"),
  productIds: z.array(z.string()),
});

export type SupplierFormValues = z.infer<typeof supplierFormSchema>;

export const emptySupplierFormValues = (): SupplierFormValues => ({ name: "", phone: "", productIds: [] });

export const supplierToFormValues = (supplier: SupplierResponse): SupplierFormValues => ({
  name: supplier.name,
  phone: supplier.phone ?? "",
  productIds: [...supplier.productIds],
});

/** Le téléphone n'est envoyé que si l'utilisateur peut le voir : sinon on ne touche pas à une valeur qu'il ne connaît pas. */
const toSupplierBody = (values: SupplierFormValues, includePhone: boolean): CreateSupplierRequest => ({
  name: values.name.trim(),
  productIds: values.productIds,
  ...(includePhone ? { phone: values.phone.trim() === "" ? null : values.phone.trim() } : {}),
});

export const toCreateSupplierRequest = (values: SupplierFormValues, includePhone: boolean): CreateSupplierRequest =>
  toSupplierBody(values, includePhone);

export const toUpdateSupplierRequest = (values: SupplierFormValues, version: string, includePhone: boolean): UpdateSupplierRequest => ({
  version,
  ...toSupplierBody(values, includePhone),
});
