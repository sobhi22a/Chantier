import { Button, Group, Modal, Stack, Text } from "@mantine/core";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import {
  isApiError,
  useApiErrorMessage,
  useMaterialSettingsGetQuery,
  useRequestsApproveMutation,
  useRequestsArchiveMutation,
  useRequestsCancelMutation,
  useRequestsLinkProductMutation,
  useOrdersCancelMutation,
  useRequestsReceiveMutation,
  useRequestsRejectMutation,
  useRequestsRestoreMutation,
  useRequestsSettleMutation,
  useSuppliersListQuery,
  type MaterialRequestResponse,
  type ProductResponse,
} from "@chantier-frontend/api-core";
import { pickLocalizedName, useLanguage } from "@chantier-frontend/i18n";
import { GenericConfirmDialogComponent, useNotifications } from "@chantier-frontend/user-interface";

import { ApproveQuantityDialog } from "../components/ApproveQuantityDialog.component";
import { ProductSelect } from "../components/ProductSelect.component";
import { ReasonDialog } from "../components/ReasonDialog.component";
import { ReceiveDialog } from "../components/ReceiveDialog.component";
import { toReasonBody } from "../types/reasonForm.zod";
import { NOTE_MAX } from "../types/requestForm.zod";
import { OrderFormModalContainer } from "./OrderFormModal.container";

export type RequestActionKind =
  | "cancel"
  | "reject"
  | "approveQuantity"
  | "linkProduct"
  | "archive"
  | "restore"
  | "order"
  | "editOrder"
  | "cancelOrder"
  | "settle"
  | "receive";

/** Validation en un clic (CA-MAT-003.1) : notification de succès ou message traduit selon le `code` de l'erreur. */
export const useApproveRequest = () => {
  const { t } = useTranslation("materials");
  const { getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const [approve, { isLoading }] = useRequestsApproveMutation();

  const approveRequest = async (request: Pick<MaterialRequestResponse, "id" | "siteId" | "number">): Promise<boolean> => {
    try {
      await approve({ siteId: request.siteId, requestId: request.id, approveBody: {} }).unwrap();
      showNotification({ type: "success", message: t("approve.done", { number: request.number }) });
      return true;
    } catch (error) {
      showNotification({ type: "error", message: getMessage(error) });
      return false;
    }
  };

  return { approveRequest, isApproving: isLoading };
};

export interface RequestActionsContainerProps {
  request: MaterialRequestResponse;
  action: RequestActionKind;
  onClose: () => void;
}

/** Fenêtre de l'action choisie sur une demande : motif, autre quantité, rattachement d'un produit, archivage, restauration. */
export const RequestActionsContainer = ({ request, action, onClose }: RequestActionsContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const settings = useMaterialSettingsGetQuery();
  const [cancelRequest] = useRequestsCancelMutation();
  const [rejectRequest] = useRequestsRejectMutation();
  const [approveRequest] = useRequestsApproveMutation();
  const [linkProduct, linkState] = useRequestsLinkProductMutation();
  const [archiveRequest, archiveState] = useRequestsArchiveMutation();
  const [restoreRequest, restoreState] = useRequestsRestoreMutation();
  const [cancelOrder] = useOrdersCancelMutation();
  const [settleRequest] = useRequestsSettleMutation();
  const [receiveRequest, receiveState] = useRequestsReceiveMutation();
  const [pickedProduct, setPickedProduct] = useState<ProductResponse | null>(null);
  const { language } = useLanguage();
  // Fournisseur proposé à la commande : le catalogue ne dit pas « le dernier utilisé », mais s'il n'y a qu'un fournisseur actif
  // du produit, il est proposé ; sinon le choix reste à faire (jamais d'invention).
  const suppliers = useSuppliersListQuery({ isActive: true, pageSize: 200 }, { skip: action !== "order" });
  const productSuppliers = request.product.productId
    ? (suppliers.data?.items ?? []).filter((supplier) => supplier.productIds.includes(request.product.productId ?? ""))
    : [];
  const suggestedSupplierId = productSuppliers.length === 1 ? productSuppliers[0]?.id : undefined;

  const ids = { siteId: request.siteId, requestId: request.id };
  const noteMaxLength = settings.data?.noteMaxLength ?? NOTE_MAX;

  const done = (message: string) => {
    showNotification({ type: "success", message });
    onClose();
  };

  const run = async (call: () => Promise<unknown>, message: string): Promise<unknown> => {
    try {
      await call();
      done(message);
      return undefined;
    } catch (error) {
      return error;
    }
  };

  const confirm = async (call: () => Promise<unknown>, message: string) => {
    const error = await run(call, message);
    if (error) {
      showNotification({ type: "error", message: getMessage(error) });
      // Une demande modifiée entre-temps : la fiche se relit, la fenêtre se ferme.
      if (isApiError(error)) onClose();
    }
  };

  if (action === "order" || action === "editOrder") {
    // Les valeurs par défaut viennent du serveur : on attend la liste des fournisseurs pour ne pas figer un fournisseur périmé.
    if (action === "order" && suppliers.isLoading) return null;
    return <OrderFormModalContainer request={request} suggestedSupplierId={suggestedSupplierId} onClose={onClose} />;
  }

  if (action === "cancelOrder" || action === "settle") {
    if (!settings.data) return null;
    const isCancelOrder = action === "cancelOrder";
    return (
      <ReasonDialog
        title={t(isCancelOrder ? "materials:order.cancel.title" : "materials:settle.title", { number: request.number })}
        intro={t(isCancelOrder ? "materials:order.cancel.intro" : "materials:settle.intro")}
        confirmLabel={t(isCancelOrder ? "materials:order.cancel.confirm" : "materials:settle.confirm")}
        cancelLabel={isCancelOrder ? t("materials:order.cancel.keep") : undefined}
        reasons={isCancelOrder ? settings.data.reasons.orderCancellation : settings.data.reasons.settle}
        noteMaxLength={noteMaxLength}
        // Le motif libre d'une commande annulée est visible du terrain : aucun prix (revue R2-09).
        noteHint={isCancelOrder ? t("materials:reason.visibleNote") : undefined}
        onCancel={onClose}
        onSubmit={(values) =>
          run(
            () =>
              isCancelOrder
                ? cancelOrder({ ...ids, reasonBody: toReasonBody(values) }).unwrap()
                : settleRequest({ ...ids, reasonBody: toReasonBody(values) }).unwrap(),
            t(isCancelOrder ? "materials:order.cancel.done" : "materials:settle.done", { number: request.number }),
          )
        }
      />
    );
  }

  if (action === "receive") {
    return (
      <ReceiveDialog
        title={t("materials:receive.title", { number: request.number })}
        noteMaxLength={noteMaxLength}
        loading={receiveState.isLoading}
        onConfirm={(note) =>
          void confirm(() => receiveRequest({ ...ids, receiveBody: { note } }).unwrap(), t("materials:receive.done", { number: request.number }))
        }
        onCancel={onClose}
      />
    );
  }

  if (action === "cancel" || action === "reject") {
    if (!settings.data) return null;
    const isCancel = action === "cancel";
    return (
      <ReasonDialog
        title={t(isCancel ? "materials:cancel.title" : "materials:reject.title", { number: request.number })}
        intro={t(isCancel ? "materials:cancel.intro" : "materials:reject.intro")}
        confirmLabel={t(isCancel ? "materials:cancel.confirm" : "materials:reject.confirm")}
        cancelLabel={isCancel ? t("materials:cancel.keep") : undefined}
        reasons={isCancel ? settings.data.reasons.requestCancellation : settings.data.reasons.rejection}
        noteMaxLength={noteMaxLength}
        onCancel={onClose}
        onSubmit={(values) =>
          run(
            () =>
              isCancel
                ? cancelRequest({ ...ids, reasonBody: toReasonBody(values) }).unwrap()
                : rejectRequest({ ...ids, reasonBody: toReasonBody(values) }).unwrap(),
            t(isCancel ? "materials:cancel.done" : "materials:reject.done", { number: request.number }),
          )
        }
      />
    );
  }

  if (action === "approveQuantity") {
    return (
      <ApproveQuantityDialog
        request={request}
        onCancel={onClose}
        onSubmit={(quantity) =>
          run(
            () => approveRequest({ ...ids, approveBody: { quantity } }).unwrap(),
            t("materials:approve.done", { number: request.number }),
          )
        }
      />
    );
  }

  if (action === "linkProduct") {
    return (
      <Modal
        opened
        onClose={onClose}
        title={t("materials:linkProduct.title", { number: request.number })}
        closeButtonProps={{ "aria-label": t("common:actions.close") }}
      >
        <Stack gap="md">
          <Text>{t("materials:linkProduct.intro")}</Text>
          <ProductSelect
            label={t("materials:linkProduct.product")}
            placeholder={t("materials:form.productPlaceholder")}
            value={pickedProduct?.id ?? null}
            onChange={setPickedProduct}
          />
          <Group justify="flex-end">
            <Button variant="default" onClick={onClose}>
              {t("common:actions.cancel")}
            </Button>
            <Button
              disabled={pickedProduct === null}
              loading={linkState.isLoading}
              onClick={() =>
                pickedProduct
                  ? void confirm(
                      () => linkProduct({ ...ids, linkProductBody: { productId: pickedProduct.id } }).unwrap(),
                      t("materials:linkProduct.done", {
                        number: request.number,
                        product: pickLocalizedName({ name: pickedProduct.nameFr, nameAr: pickedProduct.nameAr }, language),
                      }),
                    )
                  : undefined
              }
            >
              {t("materials:linkProduct.confirm")}
            </Button>
          </Group>
        </Stack>
      </Modal>
    );
  }

  const isArchive = action === "archive";
  return (
    <GenericConfirmDialogComponent
      opened
      title={t(isArchive ? "materials:archive.title" : "materials:archive.restoreTitle", { number: request.number })}
      message={t(isArchive ? "materials:archive.message" : "materials:archive.restoreMessage")}
      confirmLabel={t(isArchive ? "materials:archive.confirm" : "materials:archive.restoreConfirm")}
      loading={archiveState.isLoading || restoreState.isLoading}
      onConfirm={() =>
        void confirm(
          () => (isArchive ? archiveRequest(ids).unwrap() : restoreRequest(ids).unwrap()),
          t(isArchive ? "materials:archive.done" : "materials:archive.restoreDone", { number: request.number }),
        )
      }
      onCancel={onClose}
    />
  );
};
