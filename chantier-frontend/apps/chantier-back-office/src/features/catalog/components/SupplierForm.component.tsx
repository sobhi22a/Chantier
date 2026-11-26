import { zodResolver } from "@hookform/resolvers/zod";
import { Button, Group, MultiSelect, Stack, TextInput } from "@mantine/core";
import { useState } from "react";
import { Controller, useForm } from "react-hook-form";
import { useTranslation } from "react-i18next";

import { isApiError, type ProductResponse, type SupplierResponse } from "@chantier-frontend/api-core";
import { pickLocalizedName, useLanguage } from "@chantier-frontend/i18n";
import { applyServerErrors, useFieldError, type CodeToField } from "@chantier-frontend/user-interface";

import { FormSubmitAlerts } from "../../../shared/components/FormSubmitAlerts";
import { supplierFormSchema, supplierToFormValues, type SupplierFormValues } from "../types/supplierForm.zod";

export interface SupplierFormProps {
  mode: "create" | "edit";
  initialValues: SupplierFormValues;
  /** Produits du catalogue proposés comme produits fournis. */
  products: readonly ProductResponse[];
  /** Le téléphone n'existe dans le formulaire que pour un rôle qui le voit (`SupplierPhone.View`). */
  canEditPhone: boolean;
  /** Renvoie l'erreur du serveur le cas échéant ; `undefined` si l'enregistrement a réussi. */
  onSubmit: (values: SupplierFormValues) => Promise<unknown>;
  onCancel: () => void;
  onConflictReload?: (current: SupplierResponse) => void;
}

const CODE_TO_FIELD: CodeToField<SupplierFormValues> = { FOURNISSEUR_EXISTANT: "name" };

/** Formulaire fournisseur : nom unique, téléphone au format algérien (selon la permission), produits fournis. */
export const SupplierForm = ({ mode, initialValues, products, canEditPhone, onSubmit, onCancel, onConflictReload }: SupplierFormProps) => {
  const { t } = useTranslation(["catalog", "common"]);
  const { language } = useLanguage();
  const fieldError = useFieldError();
  const [submitError, setSubmitError] = useState<unknown>(null);

  const {
    register,
    control,
    handleSubmit,
    setError,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<SupplierFormValues>({ resolver: zodResolver(supplierFormSchema), defaultValues: initialValues });

  const submit = async (values: SupplierFormValues) => {
    setSubmitError(null);
    const error = await onSubmit(values);
    if (!error) return;
    const isConflict = isApiError(error) && error.code === "CONFLIT_VERSION";
    if (isConflict || !applyServerErrors(error, setError, CODE_TO_FIELD)) setSubmitError(error);
  };

  return (
    <form onSubmit={(event) => void handleSubmit(submit)(event)} noValidate>
      <Stack gap="md">
        <FormSubmitAlerts<SupplierResponse>
          error={submitError}
          generalTitle={t("catalog:supplierForm.generalError")}
          conflict={{
            title: t("catalog:supplierForm.conflictTitle"),
            message: (current) => t("catalog:supplierForm.conflictMessage", { name: current.updatedByName ?? "—" }),
            reloadLabel: t("catalog:supplierForm.conflictReload"),
            onReload: (current) => {
              reset(supplierToFormValues(current));
              onConflictReload?.(current);
              setSubmitError(null);
            },
          }}
        />

        <TextInput label={t("catalog:supplierForm.name")} required error={fieldError(errors.name)} {...register("name")} />

        {canEditPhone ? (
          <TextInput
            label={t("catalog:supplierForm.phone")}
            description={t("catalog:supplierForm.phoneHelp")}
            inputMode="tel"
            dir="ltr"
            error={fieldError(errors.phone)}
            {...register("phone")}
          />
        ) : null}

        <Controller
          control={control}
          name="productIds"
          render={({ field }) => (
            <MultiSelect
              label={t("catalog:supplierForm.products")}
              placeholder={t("catalog:supplierForm.productsPlaceholder")}
              nothingFoundMessage={t("catalog:supplierForm.productsNothing")}
              searchable
              clearable
              data={products.map((product) => ({ value: product.id, label: pickLocalizedName({ name: product.nameFr, nameAr: product.nameAr }, language) }))}
              value={field.value}
              onChange={field.onChange}
            />
          )}
        />

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
