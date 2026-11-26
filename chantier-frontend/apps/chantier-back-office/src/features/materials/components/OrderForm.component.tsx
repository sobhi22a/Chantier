import { zodResolver } from "@hookform/resolvers/zod";
import { Alert, Button, Group, Stack, Text, Textarea, TextInput } from "@mantine/core";
import { DatePickerInput } from "@mantine/dates";
import { IconAlertTriangle } from "@tabler/icons-react";
import { useState } from "react";
import { Controller, useForm, useWatch } from "react-hook-form";
import { useTranslation } from "react-i18next";

import { isApiError } from "@chantier-frontend/api-core";
import { CURRENCY, todayDateOnly, useQuantityFormatter } from "@chantier-frontend/i18n";
import { applyServerErrors, useFieldError, type CodeToField } from "@chantier-frontend/user-interface";

import { FormSubmitAlerts } from "../../../shared/components/FormSubmitAlerts";
import { orderFormSchema, orderToFormValues, ORDER_NOTE_MAX, type OrderFormValues } from "../types/orderForm.zod";
import { daysBetween } from "../types/quantityMirror";
import type { RequestDetail } from "../types/requestTypes";
import { SupplierSelect } from "./SupplierSelect.component";

export interface OrderFormProps {
  mode: "create" | "edit";
  request: RequestDetail;
  initialValues: OrderFormValues;
  /** Prix et n° de bon de commande : seulement si le serveur les fournit à cet utilisateur (`Prices.View`). */
  withCommercial: boolean;
  onSubmit: (values: OrderFormValues) => Promise<unknown>;
  onCancel: () => void;
  onConflictReload?: (current: RequestDetail) => void;
}

const CODE_TO_FIELD: CodeToField<OrderFormValues> = {
  DATE_INVALIDE: "orderDate",
  FOURNISSEUR_INACTIF: "supplierId",
};

/**
 * Formulaire de commande (une par demande) : fournisseur, dates, prix unitaire HT avec son unité à côté, n° de bon de commande.
 * La quantité et l'unité sont celles de la demande (non modifiables) ; le montant est calculé et renvoyé par le serveur.
 */
export const OrderForm = ({ mode, request, initialValues, withCommercial, onSubmit, onCancel, onConflictReload }: OrderFormProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { quantityText, unitLabel } = useQuantityFormatter();
  const fieldError = useFieldError();
  const [submitError, setSubmitError] = useState<unknown>(null);

  const {
    register,
    control,
    handleSubmit,
    setError,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<OrderFormValues>({ resolver: zodResolver(orderFormSchema), defaultValues: initialValues });

  const values = useWatch({ control });
  const isEdit = mode === "edit";
  // Avertissement indicatif (jamais bloquant) : le serveur renvoie `plannedAfterNeedDays` après l'enregistrement.
  const lateDays = values.expectedDeliveryDate ? daysBetween(request.neededBy, values.expectedDeliveryDate) : 0;

  const submit = async (formValues: OrderFormValues) => {
    setSubmitError(null);
    const error = await onSubmit(formValues);
    if (!error) return;
    const isConflict = isApiError(error) && error.code === "CONFLIT_VERSION";
    if (isConflict || !applyServerErrors(error, setError, CODE_TO_FIELD)) setSubmitError(error);
  };

  return (
    <form onSubmit={(event) => void handleSubmit(submit)(event)} noValidate>
      <Stack gap="md">
        <FormSubmitAlerts<RequestDetail>
          error={submitError}
          generalTitle={t("materials:order.generalError")}
          conflict={{
            title: t("materials:order.conflictTitle"),
            message: (current) => t("materials:order.conflictMessage", { name: current.updatedByName ?? "—" }),
            reloadLabel: t("materials:order.conflictReload"),
            onReload: (current) => {
              reset(orderToFormValues(current));
              onConflictReload?.(current);
              setSubmitError(null);
            },
          }}
        />

        <Stack gap={2}>
          <Text>{t("materials:order.intro")}</Text>
          <Text fw={600}>{t("materials:order.orderedQuantity", { quantity: quantityText(request.quantity) })}</Text>
        </Stack>

        <Controller
          control={control}
          name="supplierId"
          render={({ field }) => (
            <SupplierSelect
              label={t("materials:order.supplier")}
              placeholder={t("materials:order.supplierPlaceholder")}
              value={field.value === "" ? null : field.value}
              onChange={(supplier) => field.onChange(supplier?.id ?? "")}
              error={fieldError(errors.supplierId)}
            />
          )}
        />

        <Group align="flex-start" grow wrap="wrap">
          <Controller
            control={control}
            name="orderDate"
            render={({ field }) => (
              <DatePickerInput
                label={t("materials:order.orderDate")}
                description={t("materials:order.dateHelp")}
                required
                // La date de commande se fixe à la création ; le serveur ne la modifie pas ensuite.
                disabled={isEdit}
                maxDate={todayDateOnly()}
                valueFormat="DD/MM/YYYY"
                error={fieldError(errors.orderDate)}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
          <Controller
            control={control}
            name="expectedDeliveryDate"
            render={({ field }) => (
              <DatePickerInput
                label={t("materials:order.expectedDate")}
                description={t("materials:order.dateHelp")}
                // Une date déjà posée se remplace, elle ne s'efface pas (écart n°11 du contrat).
                clearable={!isEdit || initialValues.expectedDeliveryDate === null}
                minDate={values.orderDate ?? undefined}
                valueFormat="DD/MM/YYYY"
                error={fieldError(errors.expectedDeliveryDate)}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
        </Group>
        {lateDays > 0 ? (
          <Alert color="orange" variant="light" icon={<IconAlertTriangle aria-hidden />} role="status">
            {t("materials:order.plannedAfterNeed", { count: lateDays })}
          </Alert>
        ) : null}

        {withCommercial ? (
          <Group align="flex-start" grow wrap="wrap">
            <TextInput
              label={t("materials:order.unitPrice")}
              description={t("materials:order.unitPriceHelp", { unit: unitLabel(request.quantity.unit, 1) })}
              inputMode="decimal"
              dir="ltr"
              rightSection={<Text size="sm" c="dimmed">{CURRENCY}</Text>}
              rightSectionWidth={52}
              error={fieldError(errors.unitPrice)}
              {...register("unitPrice")}
            />
            <TextInput
              label={t("materials:order.purchaseOrderNumber")}
              dir="ltr"
              error={fieldError(errors.purchaseOrderNumber)}
              {...register("purchaseOrderNumber")}
            />
          </Group>
        ) : null}

        <Textarea
          label={t("materials:order.note")}
          description={`${t("materials:form.noteCounter", { count: ORDER_NOTE_MAX })} ${t("materials:order.noteWarning")}`}
          maxLength={ORDER_NOTE_MAX}
          autosize
          minRows={2}
          error={fieldError(errors.note)}
          {...register("note")}
        />
        {isEdit ? (
          <Text size="sm" c="dimmed">
            {t("materials:order.cannotErase")}
          </Text>
        ) : null}

        <Group justify="flex-end">
          <Button variant="default" onClick={onCancel} disabled={isSubmitting}>
            {t("common:actions.cancel")}
          </Button>
          <Button type="submit" loading={isSubmitting}>
            {isEdit ? t("common:actions.save") : t("materials:actions.order")}
          </Button>
        </Group>
      </Stack>
    </form>
  );
};
