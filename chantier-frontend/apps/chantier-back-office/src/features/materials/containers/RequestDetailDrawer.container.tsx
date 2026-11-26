import { Button, Drawer, Group, Stack } from "@mantine/core";
import { IconArchive, IconArrowBackUp, IconCheck, IconLink, IconPackageImport, IconPencil, IconShoppingCart, IconTruckDelivery, IconX } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";

import { useApiErrorMessage, useRequestsGetQuery } from "@chantier-frontend/api-core";
import { usePermissions } from "@chantier-frontend/authentication";
import { selectUserAuthState, useAppChantierSelector } from "@chantier-frontend/state-store";
import { GenericErrorComponent, GenericLoaderComponent } from "@chantier-frontend/user-interface";

import { BACK_OFFICE_ROUTES, newDeliveryPath, requestDetailPath } from "../../../app/providers/router/navigationRoutes";
import { RequestDetailView } from "../components/RequestDetailView.component";
import { requestActionsFor } from "../types/requestActions";
import { asRequestDetail } from "../types/requestTypes";
import { RequestActionsContainer, useApproveRequest, type RequestActionKind } from "./RequestActions.container";
import { RequestFormModalContainer } from "./RequestFormModal.container";

export interface RequestDetailDrawerContainerProps {
  siteId: string;
  requestId: string;
  onClose: () => void;
}

/**
 * Tiroir de détail d'une demande (CA-MAT-002.2) : historique, reste et écart avec unité, et les actions que le rôle
 * permet. Une action interdite est absente, pas grisée (CA-MAT-009.1) ; le serveur refuse de toute façon.
 */
export const RequestDetailDrawerContainer = ({ siteId, requestId, onClose }: RequestDetailDrawerContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const navigate = useNavigate();
  const { can } = usePermissions();
  const { describe } = useApiErrorMessage();
  const { userId } = useAppChantierSelector(selectUserAuthState);
  const { approveRequest, isApproving } = useApproveRequest();
  const [action, setAction] = useState<RequestActionKind | null>(null);
  const [editing, setEditing] = useState(false);

  const { data, isLoading, isError, error, refetch } = useRequestsGetQuery({ siteId, requestId });
  const request = data ? asRequestDetail(data) : undefined;
  const available = request ? requestActionsFor(request, can, userId) : undefined;

  return (
    <Drawer
      opened
      onClose={onClose}
      position="right"
      size="lg"
      title={request ? t("materials:detail.title", { number: request.number }) : t("materials:detail.loading")}
      closeButtonProps={{ "aria-label": t("common:actions.close") }}
    >
      {isLoading ? <GenericLoaderComponent /> : null}
      {isError ? <GenericErrorComponent {...describe(error)} onRetry={() => void refetch()} /> : null}

      {request && available ? (
        <Stack gap="md">
          <Group gap="xs" role="group" aria-label={t("materials:detail.actions")}>
            {available.approve ? (
              <>
                <Button leftSection={<IconCheck size={16} aria-hidden />} loading={isApproving} onClick={() => void approveRequest(request)}>
                  {t("materials:actions.approve")}
                </Button>
                <Button variant="default" onClick={() => setAction("approveQuantity")}>
                  {t("materials:actions.approveWithQuantity")}
                </Button>
                <Button color="red" variant="light" leftSection={<IconX size={16} aria-hidden />} onClick={() => setAction("reject")}>
                  {t("materials:actions.reject")}
                </Button>
              </>
            ) : null}
            {available.order ? (
              <Button leftSection={<IconShoppingCart size={16} aria-hidden />} onClick={() => setAction("order")}>
                {t("materials:actions.order")}
              </Button>
            ) : null}
            {available.registerDelivery ? (
              <Button
                variant="default"
                leftSection={<IconTruckDelivery size={16} aria-hidden />}
                onClick={() => void navigate(newDeliveryPath(request.siteId, request.id))}
              >
                {t("materials:actions.registerDelivery")}
              </Button>
            ) : null}
            {available.editOrder ? (
              <Button variant="default" leftSection={<IconPencil size={16} aria-hidden />} onClick={() => setAction("editOrder")}>
                {t("materials:actions.editOrder")}
              </Button>
            ) : null}
            {available.cancelOrder ? (
              <Button color="red" variant="light" onClick={() => setAction("cancelOrder")}>
                {t("materials:actions.cancelOrder")}
              </Button>
            ) : null}
            {available.settle ? (
              <Button variant="default" onClick={() => setAction("settle")}>
                {t("materials:actions.settle")}
              </Button>
            ) : null}
            {available.receive ? (
              <Button leftSection={<IconPackageImport size={16} aria-hidden />} onClick={() => setAction("receive")}>
                {t("materials:actions.receive")}
              </Button>
            ) : null}
            {available.edit ? (
              <Button variant="default" leftSection={<IconPencil size={16} aria-hidden />} onClick={() => setEditing(true)}>
                {t("materials:actions.edit")}
              </Button>
            ) : null}
            {available.cancel ? (
              <Button color="red" variant="light" onClick={() => setAction("cancel")}>
                {t("materials:actions.cancel")}
              </Button>
            ) : null}
            {available.linkProduct ? (
              <Button variant="default" leftSection={<IconLink size={16} aria-hidden />} onClick={() => setAction("linkProduct")}>
                {t("materials:actions.linkProduct")}
              </Button>
            ) : null}
            {available.archive ? (
              <Button variant="default" leftSection={<IconArchive size={16} aria-hidden />} onClick={() => setAction("archive")}>
                {t("materials:actions.archive")}
              </Button>
            ) : null}
            {available.restore ? (
              <Button variant="default" leftSection={<IconArrowBackUp size={16} aria-hidden />} onClick={() => setAction("restore")}>
                {t("materials:actions.restore")}
              </Button>
            ) : null}
          </Group>

          <RequestDetailView
            request={request}
            deliveryHref={(deliverySiteId, deliveryId) => requestDetailPath(BACK_OFFICE_ROUTES.MATERIAL_DELIVERIES, deliverySiteId, deliveryId)}
          />

          {action ? <RequestActionsContainer request={request} action={action} onClose={() => setAction(null)} /> : null}
          {editing ? <RequestFormModalContainer request={request} onClose={() => setEditing(false)} /> : null}
        </Stack>
      ) : null}
    </Drawer>
  );
};
