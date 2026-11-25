import { zodResolver } from "@hookform/resolvers/zod";
import { Alert, Autocomplete, Button, Group, NumberInput, Paper, Select, Stack, Text, TextInput } from "@mantine/core";
import { IconAlertOctagon, IconAlertTriangle } from "@tabler/icons-react";
import { useState } from "react";
import { Controller, useForm, useWatch } from "react-hook-form";
import { useTranslation } from "react-i18next";

import { isApiError, useApiErrorMessage, type ZoneResponse } from "@chantier-frontend/api-core";
import { formatElevation, ROOM_TYPES, ZoneLabel } from "@chantier-frontend/i18n";
import { applyServerErrors, useFieldError } from "@chantier-frontend/user-interface";

import {
  ELEVATION_MAX,
  ELEVATION_MIN,
  parseElevation,
  zoneFormSchema,
  zoneToFormValues,
  type ZoneFormValues,
} from "../types/zoneForm.zod";

export interface ZoneFormProps {
  mode: "create" | "edit";
  initialValues: ZoneFormValues;
  /** Blocs déjà utilisés dans ce chantier (suggestions, la saisie libre reste possible). */
  knownBlocks: readonly string[];
  /** Renvoie l'erreur du serveur le cas échéant ; `undefined` si l'enregistrement a réussi. */
  onSubmit: (values: ZoneFormValues) => Promise<unknown>;
  onCancel: () => void;
  onConflictReload?: (current: ZoneResponse) => void;
}

const meterRange = (value: number) => `${formatElevation(value)} m`;

/** Formulaire zone : bloc, cote signée en mètres (unité non modifiable), type de local, numéro, libellé libre si « Autre ». */
export const ZoneForm = ({ mode, initialValues, knownBlocks, onSubmit, onCancel, onConflictReload }: ZoneFormProps) => {
  const { t } = useTranslation(["sites", "common"]);
  const fieldError = useFieldError();
  const { describe } = useApiErrorMessage();
  const [submitError, setSubmitError] = useState<unknown>(null);

  const {
    register,
    control,
    handleSubmit,
    setError,
    setValue,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<ZoneFormValues>({ resolver: zodResolver(zoneFormSchema), defaultValues: initialValues });

  const values = useWatch({ control });
  const previewElevation = parseElevation(values.elevation ?? "");

  const submit = async (formValues: ZoneFormValues) => {
    setSubmitError(null);
    const error = await onSubmit(formValues);
    if (!error) return;
    const isConflict = isApiError(error) && error.code === "CONFLIT_VERSION";
    // ZONE_EXISTANTE n'a pas de champ propre : alerte en tête du formulaire.
    if (isConflict || !applyServerErrors(error, setError)) setSubmitError(error);
  };

  const conflictCurrent =
    isApiError(submitError) && submitError.code === "CONFLIT_VERSION" ? (submitError.current as ZoneResponse | undefined) : undefined;
  const generalError = submitError && !conflictCurrent ? describe(submitError) : null;

  const reloadAfterConflict = () => {
    if (!conflictCurrent) return;
    reset(zoneToFormValues(conflictCurrent));
    onConflictReload?.(conflictCurrent);
    setSubmitError(null);
  };

  const roomType = values.roomType ?? "";

  return (
    <form onSubmit={(event) => void handleSubmit(submit)(event)} noValidate>
      <Stack gap="md">
        {conflictCurrent ? (
          <Alert color="orange" variant="light" icon={<IconAlertTriangle aria-hidden />} title={t("sites:conflict.title")} role="alert">
            <Stack gap="xs" align="flex-start">
              <Text>{t("sites:zones.conflictMessage", { name: conflictCurrent.updatedByName ?? "—" })}</Text>
              <Button variant="default" onClick={reloadAfterConflict}>
                {t("sites:conflict.reload")}
              </Button>
            </Stack>
          </Alert>
        ) : null}
        {generalError ? (
          <Alert color="red" variant="light" icon={<IconAlertOctagon aria-hidden />} title={t("sites:zones.generalError")} role="alert">
            <Text>{generalError.message}</Text>
            {generalError.reference ? (
              <Text size="sm" c="dimmed">
                {generalError.reference}
              </Text>
            ) : null}
          </Alert>
        ) : null}

        <Controller
          control={control}
          name="block"
          render={({ field }) => (
            <Autocomplete
              label={t("sites:zones.block")}
              required
              data={[...knownBlocks]}
              error={fieldError(errors.block)}
              value={field.value}
              onChange={field.onChange}
            />
          )}
        />

        <TextInput
          label={t("sites:zones.elevation")}
          description={
            <>
              {t("sites:zones.elevationHelp")}{" "}
              {t("sites:zones.elevationRange", { min: meterRange(ELEVATION_MIN), max: meterRange(ELEVATION_MAX) })}
            </>
          }
          inputMode="decimal"
          dir="ltr"
          // L'unité est toujours le mètre : affichée à côté de la valeur, jamais modifiable.
          rightSection={<Text size="sm">{t("common:units.meter")}</Text>}
          error={fieldError(errors.elevation)}
          {...register("elevation")}
        />

        <Controller
          control={control}
          name="roomType"
          render={({ field }) => (
            <Select
              label={t("sites:zones.roomType")}
              placeholder={t("sites:zones.roomTypeNone")}
              clearable
              data={ROOM_TYPES.map((type) => ({ value: type, label: t(`sites:roomTypes.${type}`) }))}
              error={fieldError(errors.roomType)}
              value={field.value || null}
              onChange={(value) => {
                field.onChange(value ?? "");
                // Le libellé libre n'existe que pour « Autre » ; le numéro exige un type de local.
                if (value !== "Other") setValue("roomLabel", "");
                if (!value) setValue("roomNumber", "");
              }}
            />
          )}
        />

        {roomType !== "" ? (
          <Controller
            control={control}
            name="roomNumber"
            render={({ field }) => (
              <NumberInput
                label={t("sites:zones.roomNumber")}
                min={1}
                max={999}
                allowDecimal={false}
                allowNegative={false}
                dir="ltr"
                error={fieldError(errors.roomNumber)}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
        ) : null}

        {roomType === "Other" ? (
          <TextInput label={t("sites:zones.roomLabel")} error={fieldError(errors.roomLabel)} {...register("roomLabel")} />
        ) : null}

        <Paper withBorder p="sm" aria-live="polite">
          <Text size="sm" c="dimmed">
            {t("sites:zones.preview")}
          </Text>
          <Text fw={600}>
            <ZoneLabel
              zone={{
                block: values.block?.trim() || "…",
                elevation: previewElevation === null || Number.isNaN(previewElevation) ? null : previewElevation,
                roomType: values.roomType === "" || values.roomType === undefined ? null : values.roomType,
                roomNumber: values.roomNumber === "" || values.roomNumber === undefined ? null : values.roomNumber,
                roomLabel: values.roomLabel,
              }}
            />
          </Text>
        </Paper>

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

