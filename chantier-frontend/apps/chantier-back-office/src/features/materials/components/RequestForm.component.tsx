import { zodResolver } from "@hookform/resolvers/zod";
import { Alert, Button, Group, SegmentedControl, Select, Stack, Text, Textarea, TextInput } from "@mantine/core";
import { DatePickerInput } from "@mantine/dates";
import { IconAlertTriangle, IconLock } from "@tabler/icons-react";
import { useState } from "react";
import { Controller, useForm, useWatch } from "react-hook-form";
import { useTranslation } from "react-i18next";

import { isApiError, type ProductResponse, type SiteResponse } from "@chantier-frontend/api-core";
import { MEASURE_UNITS, pickLocalizedName, todayDateOnly, useLanguage, useQuantityFormatter } from "@chantier-frontend/i18n";
import { applyServerErrors, useFieldError, type CodeToField } from "@chantier-frontend/user-interface";

import { FormSubmitAlerts } from "../../../shared/components/FormSubmitAlerts";
import { equivalenceFor, milliToText, normalizeQuantityText, parseMilli } from "../types/quantityMirror";
import {
  requestFormSchema,
  requestToFormValues,
  type RequestFormValues,
} from "../types/requestForm.zod";
import { REQUEST_PRIORITIES, type RequestDetail } from "../types/requestTypes";
import { ProductSelect, useCatalogProduct } from "./ProductSelect.component";
import { ZoneSelect } from "./ZoneSelect.component";

export interface RequestFormProps {
  mode: "create" | "edit";
  initialValues: RequestFormValues;
  /** Chantiers proposés à la création (affectés et non archivés). */
  sites: readonly SiteResponse[];
  /** Demande modifiée : après la validation, produit, quantité, unité et zone sont verrouillés. */
  request?: RequestDetail;
  noteMaxLength: number;
  onSubmit: (values: RequestFormValues) => Promise<unknown>;
  onCancel: () => void;
  onConflictReload?: (current: RequestDetail) => void;
}

const CODE_TO_FIELD: CodeToField<RequestFormValues> = {
  QUANTITE_INVALIDE: "quantity",
  QUANTITE_ENTIERE_REQUISE: "quantity",
  UNITE_OBLIGATOIRE: "unit",
  UNITE_NON_AUTORISEE: "unit",
  DATE_INVALIDE: "neededBy",
  ZONE_HORS_CHANTIER: "zoneId",
  PRODUIT_INACTIF: "productId",
};

/**
 * Formulaire de demande (création et modification) : produit du catalogue ou « Autre produit », quantité avec son unité
 * (liste, jamais un texte libre), zone, date de besoin au calendrier, urgence, remarque. Le client affiche l'équivalence
 * (« 300 sacs = 15 T ») à titre indicatif ; le serveur décide de tout.
 */
export const RequestForm = ({ mode, initialValues, sites, request, noteMaxLength, onSubmit, onCancel, onConflictReload }: RequestFormProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { language } = useLanguage();
  const { quantityText, unitName } = useQuantityFormatter();
  const fieldError = useFieldError();
  const [submitError, setSubmitError] = useState<unknown>(null);
  const locked = request !== undefined && request.status !== "Requested";

  const {
    register,
    control,
    handleSubmit,
    setError,
    setValue,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<RequestFormValues>({ resolver: zodResolver(requestFormSchema), defaultValues: initialValues });

  const values = useWatch({ control });
  const productMode = values.productMode ?? "catalog";
  const productId = values.productId ?? "";
  const siteId = values.siteId ?? "";
  const catalogProduct = useCatalogProduct(productMode === "catalog" ? productId : null);

  const submit = async (formValues: RequestFormValues) => {
    setSubmitError(null);
    const error = await onSubmit(formValues);
    if (!error) return;
    const isConflict = isApiError(error) && error.code === "CONFLIT_VERSION";
    if (isConflict || !applyServerErrors(error, setError, CODE_TO_FIELD)) setSubmitError(error);
  };

  const chooseProduct = (product: ProductResponse | null) => {
    setValue("productId", product?.id ?? "", { shouldValidate: true });
    // L'unité du catalogue est préremplie ; elle se choisit toujours dans la liste des unités autorisées du produit.
    setValue("unit", product ? product.defaultUnit : "", { shouldValidate: true });
  };

  const unitOptions = productMode === "catalog" ? (catalogProduct?.allowedUnits ?? []) : [...MEASURE_UNITS];

  // Équivalence indicative (ADR 0014) : jamais un chiffre qui fait foi ; absente quand elle n'a pas de sens.
  const quantityTextValue = normalizeQuantityText(values.quantity ?? "");
  const milli = quantityTextValue === null ? null : parseMilli(quantityTextValue);
  const unit = values.unit ?? "";
  const equivalent =
    milli !== null && milli > 0n && unit !== "" && productMode === "catalog" && catalogProduct
      ? equivalenceFor({ milli, unit }, catalogProduct.bagMassKg === null ? null : String(catalogProduct.bagMassKg))
      : null;

  const neededBy = values.neededBy ?? null;
  const isPast = neededBy !== null && neededBy < todayDateOnly();

  const siteOptions = sites.map((site) => ({ value: site.id, label: `${site.code} · ${pickLocalizedName(site, language)}` }));

  return (
    <form onSubmit={(event) => void handleSubmit(submit)(event)} noValidate>
      <Stack gap="md">
        <FormSubmitAlerts<RequestDetail>
          error={submitError}
          generalTitle={t("materials:form.generalError")}
          conflict={{
            title: t("materials:form.conflictTitle"),
            message: (current) => t("materials:form.conflictMessage", { name: current.updatedByName ?? "—" }),
            reloadLabel: t("materials:form.conflictReload"),
            onReload: (current) => {
              reset(requestToFormValues(current));
              onConflictReload?.(current);
              setSubmitError(null);
            },
          }}
        />

        {locked ? (
          <Alert color="blue" variant="light" icon={<IconLock aria-hidden />} role="note">
            {t("materials:form.locked")}
          </Alert>
        ) : null}

        {mode === "create" ? (
          <Controller
            control={control}
            name="siteId"
            render={({ field }) => (
              <Select
                label={t("materials:form.site")}
                placeholder={t("materials:form.sitePlaceholder")}
                required
                searchable
                data={siteOptions}
                error={fieldError(errors.siteId)}
                value={field.value === "" ? null : field.value}
                onChange={(value) => {
                  field.onChange(value ?? "");
                  // La zone appartient au chantier : un autre chantier remet la zone à zéro.
                  setValue("zoneId", "");
                }}
              />
            )}
          />
        ) : null}

        <SegmentedControl
          fullWidth
          aria-label={t("materials:form.product")}
          disabled={locked}
          value={productMode}
          onChange={(value) => {
            setValue("productMode", value === "free" ? "free" : "catalog", { shouldValidate: false });
            setValue("unit", "");
            setValue("productId", "");
          }}
          data={[
            { value: "catalog", label: t("materials:form.catalogProduct") },
            { value: "free", label: t("materials:form.otherProduct") },
          ]}
        />

        {productMode === "catalog" ? (
          <ProductSelect
            label={t("materials:form.product")}
            placeholder={t("materials:form.productPlaceholder")}
            value={productId === "" ? null : productId}
            onChange={chooseProduct}
            disabled={locked}
            activeOnly={!locked}
            error={fieldError(errors.productId)}
          />
        ) : (
          <TextInput
            label={t("materials:form.freeProductName")}
            description={t("materials:form.freeProductHelp")}
            required
            disabled={locked}
            error={fieldError(errors.freeProductName)}
            {...register("freeProductName")}
          />
        )}

        <Group align="flex-start" grow wrap="wrap">
          <TextInput
            label={t("materials:form.quantity")}
            description={t("materials:form.quantityHelp")}
            required
            disabled={locked}
            inputMode="decimal"
            dir="ltr"
            error={fieldError(errors.quantity)}
            {...register("quantity")}
          />
          <Controller
            control={control}
            name="unit"
            render={({ field }) => (
              <Select
                label={t("materials:form.unit")}
                placeholder={t("materials:form.unitPlaceholder")}
                required
                allowDeselect={false}
                disabled={locked}
                // Les unités se choisissent dans la liste du référentiel, jamais en texte libre.
                data={unitOptions.map((code) => ({ value: code, label: unitName(code) }))}
                error={fieldError(errors.unit)}
                value={field.value === "" ? null : field.value}
                onChange={(value) => field.onChange(value ?? "")}
              />
            )}
          />
        </Group>

        {equivalent && milli !== null && unit !== "" ? (
          <Text size="sm" aria-live="polite">
            {t("materials:form.equivalence", {
              from: quantityText({ value: Number(milliToText(milli)), unit }),
              to: quantityText({ value: Number(milliToText(equivalent.milli)), unit: equivalent.unit }),
            })}
          </Text>
        ) : null}

        <Controller
          control={control}
          name="zoneId"
          render={({ field }) => (
            <ZoneSelect
              siteId={siteId}
              label={t("materials:form.zone")}
              placeholder={siteId === "" ? t("materials:form.zoneNeedsSite") : t("materials:form.zonePlaceholder")}
              value={field.value === "" ? null : field.value}
              onChange={(value) => field.onChange(value ?? "")}
              disabled={locked}
              error={fieldError(errors.zoneId)}
            />
          )}
        />

        <Controller
          control={control}
          name="neededBy"
          render={({ field }) => (
            <DatePickerInput
              label={t("materials:form.neededBy")}
              description={t("materials:form.neededByHelp")}
              required
              valueFormat="DD/MM/YYYY"
              error={fieldError(errors.neededBy)}
              value={field.value}
              onChange={field.onChange}
            />
          )}
        />
        {isPast ? (
          <Alert color="orange" variant="light" icon={<IconAlertTriangle aria-hidden />} role="status">
            {t("materials:form.pastDate")}
          </Alert>
        ) : null}

        <Controller
          control={control}
          name="priority"
          render={({ field }) => (
            <SegmentedControl
              fullWidth
              aria-label={t("materials:form.priority")}
              value={field.value}
              onChange={field.onChange}
              data={REQUEST_PRIORITIES.map((priority) => ({ value: priority, label: t(`materials:priority.${priority}`) }))}
            />
          )}
        />

        <Textarea
          label={t("materials:form.note")}
          description={t("materials:form.noteCounter", { count: noteMaxLength })}
          maxLength={noteMaxLength}
          autosize
          minRows={2}
          error={fieldError(errors.note)}
          {...register("note")}
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
