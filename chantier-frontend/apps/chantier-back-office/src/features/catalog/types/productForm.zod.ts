import { z } from "zod";

import type { CreateProductRequest, ProductResponse, UpdateProductRequest } from "@chantier-frontend/api-core";
import { MEASURE_UNITS } from "@chantier-frontend/i18n";

import { normalizeQuantityText, parseMilli } from "../../materials/types/quantityMirror";

export const PRODUCT_CATEGORIES = ["Binders", "Steel", "Masonry", "Aggregates", "Admixtures", "FinishingWorks", "Other"] as const;
export type ProductCategoryCode = (typeof PRODUCT_CATEGORIES)[number];

const NAME_MAX = 150;

/** Texte de masse de sac → texte au point décimal si > 0 avec trois décimales au plus, sinon `null`. */
export const parseBagMass = (input: string): string | null => {
  const text = normalizeQuantityText(input);
  const milli = text === null ? null : parseMilli(text);
  return text !== null && milli !== null && milli > 0n ? text : null;
};

// Les messages sont des clés de traduction (ADR 0007). Le serveur reste juge de chaque règle.
export const productFormSchema = z
  .object({
    nameFr: z.string().trim().min(1, "catalog:productForm.nameRequired").max(NAME_MAX, "catalog:productForm.nameRequired"),
    nameAr: z.string().trim().max(NAME_MAX),
    category: z.enum(PRODUCT_CATEGORIES),
    allowedUnits: z.array(z.enum(MEASURE_UNITS)).min(1, "catalog:productForm.unitsRequired"),
    defaultUnit: z.union([z.enum(MEASURE_UNITS), z.literal("")]),
    bagMassKg: z.string(),
  })
  .superRefine((values, context) => {
    if (values.defaultUnit === "") {
      context.addIssue({ code: "custom", path: ["defaultUnit"], message: "catalog:productForm.defaultRequired" });
    } else if (!values.allowedUnits.includes(values.defaultUnit)) {
      context.addIssue({ code: "custom", path: ["defaultUnit"], message: "catalog:productForm.defaultNotAllowed" });
    }
    if (values.allowedUnits.includes("sac")) {
      if (values.bagMassKg.trim() === "") {
        context.addIssue({ code: "custom", path: ["bagMassKg"], message: "errors:MASSE_SAC_OBLIGATOIRE" });
      } else if (parseBagMass(values.bagMassKg) === null) {
        context.addIssue({ code: "custom", path: ["bagMassKg"], message: "catalog:productForm.bagMassInvalid" });
      }
    }
  });

export type ProductFormValues = z.infer<typeof productFormSchema>;

export const emptyProductFormValues = (): ProductFormValues => ({
  nameFr: "",
  nameAr: "",
  category: "Other",
  allowedUnits: [],
  defaultUnit: "",
  bagMassKg: "",
});

const massToText = (value: number | null): string => (value === null ? "" : String(value).replace(".", ","));

export const productToFormValues = (product: ProductResponse): ProductFormValues => ({
  nameFr: product.nameFr,
  nameAr: product.nameAr ?? "",
  category: product.category,
  allowedUnits: [...product.allowedUnits],
  defaultUnit: product.defaultUnit,
  bagMassKg: massToText(product.bagMassKg),
});

const toProductBody = (values: ProductFormValues): CreateProductRequest => {
  const bagMass = values.allowedUnits.includes("sac") ? parseBagMass(values.bagMassKg) : null;
  return {
    nameFr: values.nameFr.trim(),
    nameAr: values.nameAr.trim() === "" ? null : values.nameAr.trim(),
    category: values.category,
    allowedUnits: values.allowedUnits,
    defaultUnit: values.defaultUnit === "" ? null : values.defaultUnit,
    bagMassKg: bagMass === null ? null : Number(bagMass),
  };
};

export const toCreateProductRequest = (values: ProductFormValues): CreateProductRequest => toProductBody(values);

export const toUpdateProductRequest = (values: ProductFormValues, version: string): UpdateProductRequest => ({
  version,
  ...toProductBody(values),
});

/** La masse du sac change-t-elle ? (confirmation avant de l'enregistrer, CA-MAT-015.3) */
export const bagMassChanged = (before: ProductResponse, values: ProductFormValues): boolean => {
  const after = values.allowedUnits.includes("sac") ? parseBagMass(values.bagMassKg) : null;
  const afterMilli = after === null ? null : parseMilli(after);
  const beforeMilli = before.bagMassKg === null ? null : parseMilli(String(before.bagMassKg));
  return before.bagMassKg !== null && afterMilli !== beforeMilli;
};
