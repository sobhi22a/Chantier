import { zodResolver } from "@hookform/resolvers/zod";
import { Button, Checkbox, Group, Input, Select, Stack, Text, TextInput } from "@mantine/core";
import { useState } from "react";
import { Controller, useForm, useWatch } from "react-hook-form";
import { useTranslation } from "react-i18next";

import { isApiError, type ProductResponse } from "@chantier-frontend/api-core";
import { MEASURE_UNITS, useQuantityFormatter } from "@chantier-frontend/i18n";
import { applyServerErrors, useFieldError, type CodeToField } from "@chantier-frontend/user-interface";

import { FormSubmitAlerts } from "../../../shared/components/FormSubmitAlerts";
import {
  PRODUCT_CATEGORIES,
  productFormSchema,
  productToFormValues,
  type ProductFormValues,
} from "../types/productForm.zod";

export interface ProductFormProps {
  mode: "create" | "edit";
  initialValues: ProductFormValues;
  /** Renvoie l'erreur du serveur le cas échéant ; `undefined` si l'enregistrement a réussi (ou attend une confirmation). */
  onSubmit: (values: ProductFormValues) => Promise<unknown>;
  onCancel: () => void;
  onConflictReload?: (current: ProductResponse) => void;
}

const CODE_TO_FIELD: CodeToField<ProductFormValues> = {
  PRODUIT_EXISTANT: "nameFr",
  MASSE_SAC_OBLIGATOIRE: "bagMassKg",
  UNITE_NON_AUTORISEE: "defaultUnit",
};

/** Formulaire produit : nom FR (et AR), catégorie, unités autorisées dans la liste du référentiel, unité par défaut, masse du sac. */
export const ProductForm = ({ mode, initialValues, onSubmit, onCancel, onConflictReload }: ProductFormProps) => {
  const { t } = useTranslation(["catalog", "common"]);
  const { unitLabel, unitName } = useQuantityFormatter();
  const fieldError = useFieldError();
  const [submitError, setSubmitError] = useState<unknown>(null);

  const {
    register,
    control,
    handleSubmit,
    setError,
    setValue,
    getValues,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<ProductFormValues>({ resolver: zodResolver(productFormSchema), defaultValues: initialValues });

  const allowedUnits = useWatch({ control, name: "allowedUnits" }) ?? [];

  const submit = async (values: ProductFormValues) => {
    setSubmitError(null);
    const error = await onSubmit(values);
    if (!error) return;
    const isConflict = isApiError(error) && error.code === "CONFLIT_VERSION";
    if (isConflict || !applyServerErrors(error, setError, CODE_TO_FIELD)) setSubmitError(error);
  };

  const toggleUnit = (unit: (typeof MEASURE_UNITS)[number], checked: boolean) => {
    const next = checked ? MEASURE_UNITS.filter((candidate) => candidate === unit || allowedUnits.includes(candidate)) : allowedUnits.filter((candidate) => candidate !== unit);
    setValue("allowedUnits", next, { shouldValidate: true });
    // Une unité par défaut retirée de la liste est effacée ; la première unité cochée devient le défaut (CA-MAT-015.1).
    const current = getValues("defaultUnit");
    if (current !== "" && !next.includes(current)) setValue("defaultUnit", "");
    if (getValues("defaultUnit") === "" && next[0]) setValue("defaultUnit", next[0], { shouldValidate: true });
  };

  return (
    <form onSubmit={(event) => void handleSubmit(submit)(event)} noValidate>
      <Stack gap="md">
        <FormSubmitAlerts<ProductResponse>
          error={submitError}
          generalTitle={t("catalog:productForm.generalError")}
          conflict={{
            title: t("catalog:productForm.conflictTitle"),
            message: (current) => t("catalog:productForm.conflictMessage", { name: current.updatedByName ?? "—" }),
            reloadLabel: t("catalog:productForm.conflictReload"),
            onReload: (current) => {
              reset(productToFormValues(current));
              onConflictReload?.(current);
              setSubmitError(null);
            },
          }}
        />

        <TextInput label={t("catalog:productForm.nameFr")} required error={fieldError(errors.nameFr)} {...register("nameFr")} />
        <TextInput
          label={t("catalog:productForm.nameAr")}
          description={t("catalog:productForm.nameArHelp")}
          dir="rtl"
          lang="ar"
          error={fieldError(errors.nameAr)}
          {...register("nameAr")}
        />

        <Controller
          control={control}
          name="category"
          render={({ field }) => (
            <Select
              label={t("catalog:productForm.category")}
              required
              allowDeselect={false}
              data={PRODUCT_CATEGORIES.map((value) => ({ value, label: t(`catalog:categories.${value}`) }))}
              error={fieldError(errors.category)}
              value={field.value}
              onChange={(value) => field.onChange(value ?? "Other")}
            />
          )}
        />

        <Input.Wrapper
          label={t("catalog:productForm.allowedUnits")}
          description={t("catalog:productForm.allowedUnitsHelp")}
          withAsterisk
          error={fieldError(errors.allowedUnits)}
        >
          <Group mt="xs" gap="md" role="group" aria-label={t("catalog:productForm.allowedUnits")}>
            {MEASURE_UNITS.map((unit) => (
              <Checkbox
                key={unit}
                label={unitName(unit)}
                checked={allowedUnits.includes(unit)}
                onChange={(event) => toggleUnit(unit, event.currentTarget.checked)}
              />
            ))}
          </Group>
        </Input.Wrapper>

        <Controller
          control={control}
          name="defaultUnit"
          render={({ field }) => (
            <Select
              label={t("catalog:productForm.defaultUnit")}
              placeholder={t("catalog:productForm.defaultUnitPlaceholder")}
              required
              allowDeselect={false}
              data={allowedUnits.map((unit) => ({ value: unit, label: unitName(unit) }))}
              error={fieldError(errors.defaultUnit)}
              value={field.value === "" ? null : field.value}
              onChange={(value) => field.onChange(value ?? "")}
            />
          )}
        />

        {allowedUnits.includes("sac") ? (
          <TextInput
            label={t("catalog:productForm.bagMass")}
            description={t("catalog:productForm.bagMassHelp")}
            required
            inputMode="decimal"
            dir="ltr"
            // L'unité est toujours le kilogramme : affichée à côté de la valeur, jamais modifiable.
            rightSection={<Text size="sm">{unitLabel("kg")}</Text>}
            rightSectionWidth={44}
            error={fieldError(errors.bagMassKg)}
            {...register("bagMassKg")}
          />
        ) : null}

        <Group justify="flex-end">
          <Button variant="default" onClick={onCancel} disabled={isSubmitting}>
            {t("common:actions.cancel")}
          </Button>
          <Button type="submit" loading={isSubmitting}>
            {mode === "create" ? t("common:actions.create") : t("common:actions.save")}
          </Button>
        </Group>
      </Stack>
    </form>
  );
};
