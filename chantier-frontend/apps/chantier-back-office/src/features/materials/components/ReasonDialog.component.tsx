import { zodResolver } from "@hookform/resolvers/zod";
import { Button, Group, Modal, Select, Stack, Text, Textarea } from "@mantine/core";
import { useState } from "react";
import { Controller, useForm, useWatch } from "react-hook-form";
import { useTranslation } from "react-i18next";

import { applyServerErrors, useFieldError } from "@chantier-frontend/user-interface";

import { FormSubmitAlerts } from "../../../shared/components/FormSubmitAlerts";
import { OTHER_REASON, reasonFormSchema, type ReasonFormValues } from "../types/reasonForm.zod";

export interface ReasonDialogProps {
  title: string;
  intro: string;
  confirmLabel: string;
  cancelLabel?: string;
  /** Liste de motifs du cas, telle que publiée par le serveur (ensemble ouvert : un code inconnu s'affiche tel quel). */
  reasons: readonly string[];
  noteMaxLength: number;
  /** Avertissement ajouté sous la remarque (par exemple « visible du terrain : aucun prix »). */
  noteHint?: string;
  /** Renvoie l'erreur du serveur le cas échéant ; `undefined` si l'action a réussi. */
  onSubmit: (values: ReasonFormValues) => Promise<unknown>;
  onCancel: () => void;
}

/** Motif obligatoire (refus, annulation, solde…) : liste du serveur, remarque obligatoire pour « Autre ». */
export const ReasonDialog = ({ title, intro, confirmLabel, cancelLabel, reasons, noteMaxLength, noteHint, onSubmit, onCancel }: ReasonDialogProps) => {
  const { t, i18n } = useTranslation(["materials", "common"]);
  const fieldError = useFieldError();
  const [submitError, setSubmitError] = useState<unknown>(null);

  const {
    register,
    control,
    handleSubmit,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<ReasonFormValues>({ resolver: zodResolver(reasonFormSchema), defaultValues: { reasonCode: "", reasonNote: "" } });
  const code = useWatch({ control, name: "reasonCode" });

  const reasonLabel = (reason: string): string => (i18n.exists(`materials:reasons.${reason}`) ? t(`materials:reasons.${reason}`) : reason);

  const submit = async (values: ReasonFormValues) => {
    setSubmitError(null);
    const error = await onSubmit(values);
    if (error && !applyServerErrors(error, setError)) setSubmitError(error);
  };

  return (
    <Modal opened onClose={onCancel} title={title} closeButtonProps={{ "aria-label": t("common:actions.close") }}>
      <form onSubmit={(event) => void handleSubmit(submit)(event)} noValidate>
        <Stack gap="md">
          <Text>{intro}</Text>
          <FormSubmitAlerts error={submitError} generalTitle={t("common:state.error")} />
          <Controller
            control={control}
            name="reasonCode"
            render={({ field }) => (
              <Select
                label={t("materials:reason.label")}
                placeholder={t("materials:reason.placeholder")}
                required
                allowDeselect={false}
                data={reasons.map((reason) => ({ value: reason, label: reasonLabel(reason) }))}
                error={fieldError(errors.reasonCode)}
                value={field.value === "" ? null : field.value}
                onChange={(value) => field.onChange(value ?? "")}
              />
            )}
          />
          <Textarea
            label={t("materials:reason.note")}
            description={noteHint ? `${t("materials:reason.noteHelp", { count: noteMaxLength })} ${noteHint}` : t("materials:reason.noteHelp", { count: noteMaxLength })}
            required={code === OTHER_REASON}
            maxLength={noteMaxLength}
            autosize
            minRows={2}
            error={fieldError(errors.reasonNote)}
            {...register("reasonNote")}
          />
          <Group justify="flex-end">
            <Button variant="default" onClick={onCancel} disabled={isSubmitting}>
              {cancelLabel ?? t("common:actions.cancel")}
            </Button>
            <Button type="submit" color="red" loading={isSubmitting}>
              {confirmLabel}
            </Button>
          </Group>
        </Stack>
      </form>
    </Modal>
  );
};
