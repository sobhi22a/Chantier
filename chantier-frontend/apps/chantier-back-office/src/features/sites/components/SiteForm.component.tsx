import { zodResolver } from "@hookform/resolvers/zod";
import { Alert, Autocomplete, Button, Group, NumberInput, Select, Stack, Text, TextInput } from "@mantine/core";
import { DatePickerInput } from "@mantine/dates";
import { IconAlertOctagon, IconAlertTriangle } from "@tabler/icons-react";
import { useState } from "react";
import { Controller, useForm } from "react-hook-form";
import { useTranslation } from "react-i18next";

import {
  isApiError,
  useApiErrorMessage,
  type CommuneResponse,
  type SiteResponse,
  type WilayaResponse,
} from "@chantier-frontend/api-core";
import { useLanguage } from "@chantier-frontend/i18n";
import { applyServerErrors, useFieldError, type CodeToField } from "@chantier-frontend/user-interface";

import { siteFormSchema, siteToFormValues, SITE_TYPES, type SiteFormValues } from "../types/siteForm.zod";

export interface SiteFormProps {
  mode: "create" | "edit";
  initialValues: SiteFormValues;
  wilayas: readonly WilayaResponse[];
  communes: readonly CommuneResponse[];
  /** Appelé quand la wilaya change : le conteneur charge les communes de cette wilaya. */
  onWilayaChange: (wilayaName: string) => void;
  /** Le montant n'est modifiable que par un rôle qui le voit (`ContractAmount.View`). */
  canEditAmount: boolean;
  /** Renvoie l'erreur du serveur le cas échéant ; `undefined` si l'enregistrement a réussi. */
  onSubmit: (values: SiteFormValues) => Promise<unknown>;
  /** Code proposé par le serveur à partir du type et du nom (création). */
  onSuggestCode?: (type: SiteFormValues["type"], name: string) => Promise<string | undefined>;
  onCancel: () => void;
  /** Après un conflit de version : le conteneur adopte la version actuelle du serveur. */
  onConflictReload?: (current: SiteResponse) => void;
}

const CODE_TO_FIELD: CodeToField<SiteFormValues> = {
  CODE_CHANTIER_EXISTANT: "code",
  DATE_INVALIDE: "odsDate",
  QUANTITE_INVALIDE: "delayDays",
};

const numberInputProps = { decimalSeparator: ",", thousandSeparator: " ", dir: "ltr" } as const;

/** Formulaire chantier (création et modification) : react-hook-form + schéma Zod, erreurs du serveur champ par champ. */
export const SiteForm = ({
  mode,
  initialValues,
  wilayas,
  communes,
  onWilayaChange,
  canEditAmount,
  onSubmit,
  onSuggestCode,
  onCancel,
  onConflictReload,
}: SiteFormProps) => {
  const { t } = useTranslation(["sites", "common", "errors"]);
  const { language } = useLanguage();
  const fieldError = useFieldError();
  const { describe } = useApiErrorMessage();
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
  } = useForm<SiteFormValues>({ resolver: zodResolver(siteFormSchema), defaultValues: initialValues });

  const submit = async (values: SiteFormValues) => {
    setSubmitError(null);
    const error = await onSubmit(values);
    if (!error) return;
    // Un champ porte l'erreur quand c'est possible ; sinon (conflit, réseau, droits) une alerte en tête du formulaire.
    const isConflict = isApiError(error) && error.code === "CONFLIT_VERSION";
    if (isConflict || !applyServerErrors(error, setError, CODE_TO_FIELD)) setSubmitError(error);
  };

  const suggestCode = async () => {
    const { type, name } = getValues();
    if (!onSuggestCode || name.trim() === "") return;
    const code = await onSuggestCode(type, name.trim());
    if (code) setValue("code", code, { shouldValidate: true });
  };

  const reloadAfterConflict = () => {
    const current = isApiError(submitError) ? (submitError.current as SiteResponse | undefined) : undefined;
    if (!current) return;
    reset(siteToFormValues(current));
    onWilayaChange(current.wilaya);
    onConflictReload?.(current);
    setSubmitError(null);
  };

  const conflictCurrent = isApiError(submitError) && submitError.code === "CONFLIT_VERSION" ? (submitError.current as SiteResponse | undefined) : undefined;
  const generalError = submitError && !conflictCurrent ? describe(submitError) : null;

  const wilayaOptions = wilayas.map((wilaya) => ({
    value: wilaya.nameFr,
    label: language === "ar" && wilaya.nameAr ? wilaya.nameAr : wilaya.nameFr,
  }));

  return (
    <form onSubmit={(event) => void handleSubmit(submit)(event)} noValidate>
      <Stack gap="md">
        {conflictCurrent ? (
          <Alert color="orange" variant="light" icon={<IconAlertTriangle aria-hidden />} title={t("sites:conflict.title")} role="alert">
            <Stack gap="xs" align="flex-start">
              <Text>{t("sites:conflict.message", { name: conflictCurrent.updatedByName ?? "—" })}</Text>
              <Button variant="default" onClick={reloadAfterConflict}>
                {t("sites:conflict.reload")}
              </Button>
            </Stack>
          </Alert>
        ) : null}
        {generalError ? (
          <Alert color="red" variant="light" icon={<IconAlertOctagon aria-hidden />} title={t("sites:form.generalError")} role="alert">
            <Text>{generalError.message}</Text>
            {generalError.reference ? (
              <Text size="sm" c="dimmed">
                {generalError.reference}
              </Text>
            ) : null}
          </Alert>
        ) : null}

        <Group align="flex-start" grow wrap="wrap">
          <TextInput
            label={t("sites:detail.fields.code")}
            description={mode === "edit" ? t("sites:form.codeLocked") : t("sites:form.codeHelp")}
            readOnly={mode === "edit"}
            disabled={mode === "edit"}
            dir="ltr"
            required={mode === "create"}
            error={fieldError(errors.code)}
            rightSectionWidth={mode === "create" && onSuggestCode ? 150 : undefined}
            rightSection={
              mode === "create" && onSuggestCode ? (
                <Button size="compact-sm" variant="subtle" onClick={() => void suggestCode()}>
                  {t("sites:form.codeSuggest")}
                </Button>
              ) : undefined
            }
            {...register("code")}
          />
          <Controller
            control={control}
            name="type"
            render={({ field }) => (
              <Select
                label={t("sites:detail.fields.type")}
                required
                allowDeselect={false}
                data={SITE_TYPES.map((type) => ({ value: type, label: t(`sites:types.${type}`) }))}
                error={fieldError(errors.type)}
                value={field.value}
                onChange={(value) => field.onChange(value)}
              />
            )}
          />
        </Group>

        <TextInput
          label={t("sites:detail.fields.name")}
          required
          error={fieldError(errors.name)}
          {...register("name", {
            // Code proposé dès que le nom est saisi (CA-008.2) si l'utilisateur n'en a pas encore choisi.
            onBlur: () => {
              if (mode === "create" && getValues("code") === "") void suggestCode();
            },
          })}
        />
        <TextInput label={t("sites:detail.fields.nameAr")} dir="rtl" error={fieldError(errors.nameAr)} {...register("nameAr")} />

        <Group align="flex-start" grow wrap="wrap">
          <Controller
            control={control}
            name="wilaya"
            render={({ field }) => (
              <Select
                label={t("sites:detail.fields.wilaya")}
                placeholder={t("sites:form.wilayaPlaceholder")}
                required
                searchable
                data={wilayaOptions}
                error={fieldError(errors.wilaya)}
                value={field.value || null}
                onChange={(value) => {
                  field.onChange(value ?? "");
                  setValue("commune", "");
                  onWilayaChange(value ?? "");
                }}
              />
            )}
          />
          <Controller
            control={control}
            name="commune"
            render={({ field }) => (
              <Autocomplete
                label={t("sites:detail.fields.commune")}
                placeholder={t("sites:form.communePlaceholder")}
                required
                // Saisie libre acceptée : la liste des communes peut être incomplète (H-14, Q-11).
                data={communes.map((commune) => commune.nameFr)}
                error={fieldError(errors.commune)}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
        </Group>

        <TextInput label={t("sites:detail.fields.owner")} required error={fieldError(errors.owner)} {...register("owner")} />
        <TextInput
          label={t("sites:detail.fields.contractNumber")}
          dir="ltr"
          error={fieldError(errors.contractNumber)}
          {...register("contractNumber")}
        />

        <Group align="flex-start" grow wrap="wrap">
          {canEditAmount ? (
            <Controller
              control={control}
              name="contractAmount"
              render={({ field }) => (
                <NumberInput
                  {...numberInputProps}
                  label={t("sites:detail.fields.contractAmount")}
                  min={0}
                  decimalScale={2}
                  fixedDecimalScale
                  hideControls
                  rightSection={<Text size="sm">{t("common:units.currency")}</Text>}
                  rightSectionWidth={56}
                  error={fieldError(errors.contractAmount)}
                  value={field.value}
                  onChange={field.onChange}
                />
              )}
            />
          ) : null}
          <Controller
            control={control}
            name="delayDays"
            render={({ field }) => (
              <NumberInput
                {...numberInputProps}
                label={t("sites:detail.fields.delay")}
                min={1}
                allowDecimal={false}
                allowNegative={false}
                hideControls
                rightSection={<Text size="sm">{t("sites:form.delayUnit")}</Text>}
                rightSectionWidth={64}
                error={fieldError(errors.delayDays)}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
        </Group>

        <Controller
          control={control}
          name="odsDate"
          render={({ field }) => (
            <DatePickerInput
              label={t("sites:detail.fields.odsDate")}
              description={t("sites:form.odsHelp")}
              valueFormat="DD/MM/YYYY"
              clearable
              error={fieldError(errors.odsDate)}
              value={field.value}
              onChange={field.onChange}
            />
          )}
        />

        <Group align="flex-start" grow wrap="wrap">
          <Controller
            control={control}
            name="latitude"
            render={({ field }) => (
              <NumberInput
                {...numberInputProps}
                label={t("sites:detail.fields.latitude")}
                decimalScale={6}
                hideControls
                error={fieldError(errors.latitude)}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
          <Controller
            control={control}
            name="longitude"
            render={({ field }) => (
              <NumberInput
                {...numberInputProps}
                label={t("sites:detail.fields.longitude")}
                decimalScale={6}
                hideControls
                error={fieldError(errors.longitude)}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
        </Group>

        <Group justify="flex-end">
          <Button variant="default" onClick={onCancel} disabled={isSubmitting}>
            {t("common:actions.cancel")}
          </Button>
          <Button type="submit" loading={isSubmitting}>
            {t("common:actions.save")}
          </Button>
        </Group>
      </Stack>
    </form>
  );
};
