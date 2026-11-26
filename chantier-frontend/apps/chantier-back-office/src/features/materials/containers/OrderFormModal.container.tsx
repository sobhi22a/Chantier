import { Modal } from "@mantine/core";
import { useRef, useState } from "react";
import { useTranslation } from "react-i18next";

import { isApiError, useOrdersCreateMutation, useOrdersUpdateMutation } from "@chantier-frontend/api-core";
import { usePermissions } from "@chantier-frontend/authentication";
import { formatAmount } from "@chantier-frontend/i18n";
import { useNotifications } from "@chantier-frontend/user-interface";

import { OrderForm } from "../components/OrderForm.component";
import { emptyOrderFormValues, orderToFormValues, toCreateOrderRequest, toUpdateOrderRequest, type OrderFormValues } from "../types/orderForm.zod";
import { asRequestDetail, type RequestDetail } from "../types/requestTypes";

export interface OrderFormModalContainerProps {
  /** Demande commandée (modification) ou validée (création de la commande). */
  request: RequestDetail;
  /** Fournisseur proposé à la création : le dernier utilisé pour ce produit (CA-MAT-005.2), s'il est connu. */
  suggestedSupplierId?: string;
  onClose: () => void;
}

/**
 * Création et modification de la commande d'une demande (CA-MAT-005). Le `clientId` est posé une fois à l'ouverture : un double
 * appui sur « Commander » renvoie le même identifiant, donc une seule commande. Le montant affiché vient de la réponse du serveur.
 */
export const OrderFormModalContainer = ({ request, suggestedSupplierId, onClose }: OrderFormModalContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { can } = usePermissions();
  const { showNotification } = useNotifications();
  const [createOrder] = useOrdersCreateMutation();
  const [updateOrder] = useOrdersUpdateMutation();
  const [edited, setEdited] = useState<RequestDetail>(request);
  const clientId = useRef(crypto.randomUUID());

  const isEdit = request.order !== null && request.order !== undefined;
  // Prix et n° de bon de commande : seulement avec `Prices.View` (le serveur les omet sinon).
  const withCommercial = can("Prices.View");

  const handleSubmit = async (values: OrderFormValues): Promise<unknown> => {
    const ids = { siteId: edited.siteId, requestId: edited.id };
    try {
      const saved = asRequestDetail(
        isEdit
          ? await updateOrder({ ...ids, updateOrderRequest: toUpdateOrderRequest(values, edited, withCommercial) }).unwrap()
          : await createOrder({ ...ids, createOrderRequest: toCreateOrderRequest(values, clientId.current, withCommercial) }).unwrap(),
      );
      // Le montant est celui du serveur (quantité × prix, arrondi loin de zéro) ; absent sans `Prices.View` ou sans prix.
      const amount = saved.order?.commercial?.amount;
      showNotification({
        type: "success",
        message:
          amount !== null && amount !== undefined
            ? t("materials:order.createdWithAmount", { number: saved.number, amount: formatAmount(amount) })
            : t(isEdit ? "materials:order.updated" : "materials:order.created", { number: saved.number }),
      });
      if (saved.order && saved.order.plannedAfterNeedDays > 0) {
        showNotification({ type: "warning", message: t("materials:order.plannedAfterNeed", { count: saved.order.plannedAfterNeedDays }) });
      }
      onClose();
      return undefined;
    } catch (error) {
      // Déjà commandée (autre `clientId`) : message clair, la fiche se relit toute seule (étiquettes de cache).
      if (isApiError(error) && error.code === "COMMANDE_EXISTANTE") {
        showNotification({ type: "warning", message: t("materials:order.alreadyOrdered") });
        onClose();
        return undefined;
      }
      return error;
    }
  };

  const initialValues = isEdit
    ? orderToFormValues(edited)
    : emptyOrderFormValues({ supplierId: suggestedSupplierId ?? "" });

  return (
    <Modal
      opened
      onClose={onClose}
      size="lg"
      title={t(isEdit ? "materials:order.editTitle" : "materials:order.createTitle", { number: request.number })}
      closeButtonProps={{ "aria-label": t("common:actions.close") }}
    >
      <OrderForm
        key={edited.order?.version ?? "new"}
        mode={isEdit ? "edit" : "create"}
        request={edited}
        initialValues={initialValues}
        withCommercial={withCommercial}
        onSubmit={handleSubmit}
        onCancel={onClose}
        onConflictReload={setEdited}
      />
    </Modal>
  );
};
