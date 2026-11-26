import { Button, Group, Modal, Stack, Text } from "@mantine/core";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import {
  useApiErrorMessage,
  useDeliveriesAttachMutation,
  useDeliveriesCancelMutation,
  useMaterialSettingsGetQuery,
  type MaterialRequestResponse,
} from "@chantier-frontend/api-core";
import { useNotifications } from "@chantier-frontend/user-interface";

import { DeliveryRequestSelect } from "../components/DeliveryRequestSelect.component";
import { ReasonDialog } from "../components/ReasonDialog.component";
import { FormSubmitAlerts } from "../../../shared/components/FormSubmitAlerts";
import type { DeliveryDetail } from "../types/deliveryTypes";
import { toReasonBody } from "../types/reasonForm.zod";
import { NOTE_MAX } from "../types/requestForm.zod";

export type DeliveryActionKind = "cancel" | "attach";

export interface DeliveryActionsContainerProps {
  delivery: DeliveryDetail;
  action: DeliveryActionKind;
  onClose: () => void;
}

/** Fenêtre de l'action choisie sur une livraison : annulation avec motif, ou rattachement à une demande du même produit. */
export const DeliveryActionsContainer = ({ delivery, action, onClose }: DeliveryActionsContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const settings = useMaterialSettingsGetQuery();
  const [cancelDelivery] = useDeliveriesCancelMutation();
  const [attachDelivery, attachState] = useDeliveriesAttachMutation();
  const [picked, setPicked] = useState<MaterialRequestResponse | null>(null);
  const [attachError, setAttachError] = useState<unknown>(null);

  const ids = { siteId: delivery.siteId, deliveryId: delivery.id };

  if (action === "cancel") {
    if (!settings.data) return null;
    return (
      <ReasonDialog
        title={t("materials:deliveries.cancel.title", { number: delivery.number })}
        intro={t("materials:deliveries.cancel.intro")}
        confirmLabel={t("materials:deliveries.cancel.confirm")}
        cancelLabel={t("materials:deliveries.cancel.keep")}
        reasons={settings.data.reasons.deliveryCancellation}
        noteMaxLength={settings.data.noteMaxLength ?? NOTE_MAX}
        onCancel={onClose}
        onSubmit={async (values) => {
          try {
            await cancelDelivery({ ...ids, reasonBody: toReasonBody(values) }).unwrap();
            showNotification({ type: "success", message: t("materials:deliveries.cancel.done", { number: delivery.number }) });
            onClose();
            return undefined;
          } catch (error) {
            return error;
          }
        }}
      />
    );
  }

  const attach = async () => {
    if (!picked) return;
    setAttachError(null);
    try {
      await attachDelivery({ ...ids, attachBody: { requestId: picked.id } }).unwrap();
      showNotification({ type: "success", message: t("materials:deliveries.attach.done", { number: delivery.number, request: picked.number }) });
      onClose();
    } catch (error) {
      // PRODUIT_DIFFERENT, UNITES_INCOMPATIBLES, DEMANDE_NON_OUVERTE, LIVRAISON_DEJA_RATTACHEE : traduits selon le `code`.
      setAttachError(error);
      showNotification({ type: "error", message: getMessage(error) });
    }
  };

  return (
    <Modal opened onClose={onClose} title={t("materials:deliveries.attach.title", { number: delivery.number })} closeButtonProps={{ "aria-label": t("common:actions.close") }}>
      <Stack gap="md">
        <Text>{t("materials:deliveries.attach.intro")}</Text>
        <FormSubmitAlerts error={attachError} generalTitle={t("common:state.error")} />
        <DeliveryRequestSelect
          siteId={delivery.siteId}
          productId={delivery.product.productId ?? undefined}
          label={t("materials:deliveries.attach.request")}
          placeholder={t("materials:deliveries.attach.placeholder")}
          value={picked?.id ?? null}
          onChange={setPicked}
          required
          clearable={false}
        />
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose} disabled={attachState.isLoading}>
            {t("common:actions.cancel")}
          </Button>
          <Button disabled={picked === null} loading={attachState.isLoading} onClick={() => void attach()}>
            {t("materials:deliveries.attach.confirm")}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
};
