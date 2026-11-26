import { zodResolver } from "@hookform/resolvers/zod";
import { Button, Group, Modal, Stack, Text, TextInput } from "@mantine/core";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { z } from "zod";

import type { MaterialRequestResponse, MeasureUnit } from "@chantier-frontend/api-core";
import { useQuantityFormatter } from "@chantier-frontend/i18n";
import { applyServerErrors, useFieldError } from "@chantier-frontend/user-interface";

import { FormSubmitAlerts } from "../../../shared/components/FormSubmitAlerts";
import { checkQuantity, normalizeQuantityText } from "../types/quantityMirror";

const schema = z.object({ quantity: z.string() });
type Values = z.infer<typeof schema>;

export interface ApproveQuantityDialogProps {
  request: MaterialRequestResponse;
  /** Renvoie l'erreur du serveur le cas échéant ; `undefined` si la validation a réussi. */
  onSubmit: (quantity: { value: number; unit: MeasureUnit }) => Promise<unknown>;
  onCancel: () => void;
}

/**
 * « Valider avec une autre quantité » (CA-MAT-003.3) : l'unité reste celle de la demande, non modifiable ;
 * l'ancienne et la nouvelle quantités sont conservées dans l'historique par le serveur.
 */
export const ApproveQuantityDialog = ({ request, onSubmit, onCancel }: ApproveQuantityDialogProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { quantityText, unitLabel } = useQuantityFormatter();
  const fieldError = useFieldError();
  const [submitError, setSubmitError] = useState<unknown>(null);
  const unit = request.quantity.unit;

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<Values>({
    resolver: zodResolver(schema),
    defaultValues: { quantity: String(request.quantity.value).replace(".", ",") },
  });

  const submit = async (values: Values) => {
    setSubmitError(null);
    const text = normalizeQuantityText(values.quantity);
    if (!unit || text === null || checkQuantity(text, unit) !== null) {
      setError("quantity", { type: "validate", message: "materials:approve.quantityInvalid" });
      return;
    }
    const error = await onSubmit({ value: Number(text), unit });
    if (error && !applyServerErrors(error, setError, { QUANTITE_INVALIDE: "quantity", QUANTITE_ENTIERE_REQUISE: "quantity" })) {
      setSubmitError(error);
    }
  };

  return (
    <Modal
      opened
      onClose={onCancel}
      title={t("materials:approve.withQuantityTitle", { number: request.number })}
      closeButtonProps={{ "aria-label": t("common:actions.close") }}
    >
      <form onSubmit={(event) => void handleSubmit(submit)(event)} noValidate>
        <Stack gap="md">
          <Text>{t("materials:approve.requested", { quantity: quantityText(request.quantity) })}</Text>
          <FormSubmitAlerts error={submitError} generalTitle={t("common:state.error")} />
          <TextInput
            label={t("materials:approve.newQuantity")}
            description={t("materials:approve.unitFixed", { unit: unitLabel(unit, 2) })}
            required
            inputMode="decimal"
            dir="ltr"
            rightSection={<Text size="sm">{unitLabel(unit, 2)}</Text>}
            rightSectionWidth={64}
            error={fieldError(errors.quantity)}
            {...register("quantity")}
          />
          <Group justify="flex-end">
            <Button variant="default" onClick={onCancel} disabled={isSubmitting}>
              {t("common:actions.cancel")}
            </Button>
            <Button type="submit" loading={isSubmitting}>
              {t("materials:approve.confirm")}
            </Button>
          </Group>
        </Stack>
      </form>
    </Modal>
  );
};
