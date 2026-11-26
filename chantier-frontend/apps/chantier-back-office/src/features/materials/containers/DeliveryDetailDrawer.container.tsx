import { Button, Drawer, Group, Stack } from "@mantine/core";
import { IconBan, IconLink, IconPackageImport, IconPencil } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import { useApiErrorMessage, useDeliveriesGetQuery, useMaterialSettingsGetQuery, useRequestsGetQuery, useRequestsReceiveMutation } from "@chantier-frontend/api-core";
import { usePermissions } from "@chantier-frontend/authentication";
import { GenericErrorComponent, GenericLoaderComponent, useNotifications } from "@chantier-frontend/user-interface";

import { BACK_OFFICE_ROUTES, requestDetailPath } from "../../../app/providers/router/navigationRoutes";
import { DeliveryDetailView } from "../components/DeliveryDetailView.component";
import { DeliveryPhotos } from "../components/DeliveryPhotos.component";
import { ReceiveDialog } from "../components/ReceiveDialog.component";
import { asDeliveryDetail, isCancelled } from "../types/deliveryTypes";
import { DeliveryActionsContainer, type DeliveryActionKind } from "./DeliveryActions.container";
import { DeliveryFormModalContainer } from "./DeliveryFormModal.container";
import { useDeliveryPhotoUpload } from "./useDeliveryPhotoUpload";

export interface DeliveryDetailDrawerContainerProps {
  siteId: string;
  deliveryId: string;
  onClose: () => void;
}

/**
 * Tiroir de détail d'une livraison : historique, photos du bon, et les actions que le rôle permet (corriger, annuler, rattacher,
 * réceptionner la demande). Une action interdite est absente, pas grisée ; le serveur refuse de toute façon.
 */
export const DeliveryDetailDrawerContainer = ({ siteId, deliveryId, onClose }: DeliveryDetailDrawerContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { can } = usePermissions();
  const { describe, getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const [action, setAction] = useState<DeliveryActionKind | null>(null);
  const [editing, setEditing] = useState(false);
  const [receiving, setReceiving] = useState(false);
  const [receiveRequest, receiveState] = useRequestsReceiveMutation();

  const { data, isLoading, isError, error, refetch } = useDeliveriesGetQuery({ siteId, deliveryId });
  const delivery = data ? asDeliveryDetail(data) : undefined;
  const settings = useMaterialSettingsGetQuery();

  // La demande liée dit si la livraison est encore modifiable (`Received` : correction et annulation refusées) et si on peut la réceptionner.
  const linkedRequestId = delivery?.requestId ?? null;
  const linkedRequest = useRequestsGetQuery({ siteId, requestId: linkedRequestId ?? "" }, { skip: linkedRequestId === null });
  const requestReceived = linkedRequest.data?.status === "Received";

  const photoUpload = useDeliveryPhotoUpload({
    siteId,
    deliveryId,
    number: delivery?.number ?? "",
    maxPhotoBytes: settings.data?.maxPhotoBytes,
  });

  const cancelled = delivery ? isCancelled(delivery) : false;
  const canChange = delivery !== undefined && !cancelled && !requestReceived;
  const canView = can("DeliveryPhotos.View");

  const receive = async (note: string | null) => {
    if (!linkedRequestId) return;
    try {
      await receiveRequest({ siteId, requestId: linkedRequestId, receiveBody: { note } }).unwrap();
      showNotification({ type: "success", message: t("materials:receive.done", { number: delivery?.requestNumber ?? "" }) });
      setReceiving(false);
    } catch (caught) {
      showNotification({ type: "error", message: getMessage(caught) });
      setReceiving(false);
    }
  };

  return (
    <Drawer
      opened
      onClose={onClose}
      position="right"
      size="lg"
      title={delivery ? t("materials:deliveries.detail.title", { number: delivery.number }) : t("materials:deliveries.detail.loading")}
      closeButtonProps={{ "aria-label": t("common:actions.close") }}
    >
      {isLoading ? <GenericLoaderComponent /> : null}
      {isError ? <GenericErrorComponent {...describe(error)} onRetry={() => void refetch()} /> : null}

      {delivery ? (
        <Stack gap="md">
          <Group gap="xs" role="group" aria-label={t("materials:deliveries.detail.actions")}>
            {canChange && can("Deliveries.Update") ? (
              <Button variant="default" leftSection={<IconPencil size={16} aria-hidden />} onClick={() => setEditing(true)}>
                {t("materials:deliveries.actions.edit")}
              </Button>
            ) : null}
            {canChange && can("Deliveries.Update") ? (
              <Button color="red" variant="light" leftSection={<IconBan size={16} aria-hidden />} onClick={() => setAction("cancel")}>
                {t("materials:deliveries.actions.cancel")}
              </Button>
            ) : null}
            {!cancelled && !delivery.requestId && can("Deliveries.Attach") ? (
              <Button variant="default" leftSection={<IconLink size={16} aria-hidden />} onClick={() => setAction("attach")}>
                {t("materials:deliveries.actions.attach")}
              </Button>
            ) : null}
            {linkedRequest.data?.status === "Delivered" && can("Requests.Receive") ? (
              <Button leftSection={<IconPackageImport size={16} aria-hidden />} onClick={() => setReceiving(true)}>
                {t("materials:actions.receive")}
              </Button>
            ) : null}
          </Group>

          <DeliveryDetailView
            delivery={delivery}
            requestReceived={requestReceived}
            requestHref={delivery.requestId ? requestDetailPath(BACK_OFFICE_ROUTES.MATERIAL_REQUESTS, delivery.siteId, delivery.requestId) : undefined}
            photos={
              <DeliveryPhotos
                siteId={siteId}
                photos={delivery.photos}
                photoCount={delivery.photoCount}
                canView={canView}
                canAdd={canChange && can("DeliveryPhotos.Create")}
                max={settings.data?.maxPhotosPerDelivery ?? 5}
                uploading={photoUpload.uploading}
                error={photoUpload.error}
                onAdd={(file) => void photoUpload.add(file)}
                canRetry={photoUpload.canRetry}
                onRetry={photoUpload.retry}
              />
            }
          />

          {action ? <DeliveryActionsContainer delivery={delivery} action={action} onClose={() => setAction(null)} /> : null}
          {editing ? <DeliveryFormModalContainer delivery={delivery} onClose={() => setEditing(false)} /> : null}
          {receiving ? (
            <ReceiveDialog
              title={t("materials:receive.title", { number: delivery.requestNumber ?? "" })}
              noteMaxLength={settings.data?.noteMaxLength ?? 200}
              loading={receiveState.isLoading}
              onConfirm={(note) => void receive(note)}
              onCancel={() => setReceiving(false)}
            />
          ) : null}
        </Stack>
      ) : null}
    </Drawer>
  );
};
