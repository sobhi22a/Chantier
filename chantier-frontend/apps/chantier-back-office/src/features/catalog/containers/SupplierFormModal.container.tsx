import { Modal } from "@mantine/core";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import {
  useProductsListQuery,
  useSuppliersCreateMutation,
  useSuppliersUpdateMutation,
  type SupplierResponse,
} from "@chantier-frontend/api-core";
import { usePermissions } from "@chantier-frontend/authentication";
import { useNotifications } from "@chantier-frontend/user-interface";

import { SupplierForm } from "../components/SupplierForm.component";
import {
  emptySupplierFormValues,
  supplierToFormValues,
  toCreateSupplierRequest,
  toUpdateSupplierRequest,
  type SupplierFormValues,
} from "../types/supplierForm.zod";

export interface SupplierFormModalContainerProps {
  /** Fournisseur à modifier ; absent pour une création. */
  supplier?: SupplierResponse;
  onClose: () => void;
}

const PRODUCTS_PAGE_SIZE = 200;

/** Création et modification d'un fournisseur (avec `version`) ; le téléphone n'est envoyé qu'avec `SupplierPhone.View`. */
export const SupplierFormModalContainer = ({ supplier, onClose }: SupplierFormModalContainerProps) => {
  const { t } = useTranslation(["catalog", "common"]);
  const { can } = usePermissions();
  const { showNotification } = useNotifications();
  const [editedSupplier, setEditedSupplier] = useState<SupplierResponse | undefined>(supplier);
  const [createSupplier] = useSuppliersCreateMutation();
  const [updateSupplier] = useSuppliersUpdateMutation();
  const { data: products } = useProductsListQuery({ pageSize: PRODUCTS_PAGE_SIZE });
  const canEditPhone = can("SupplierPhone.View");

  const handleSubmit = async (values: SupplierFormValues): Promise<unknown> => {
    try {
      if (editedSupplier) {
        await updateSupplier({
          supplierId: editedSupplier.id,
          updateSupplierRequest: toUpdateSupplierRequest(values, editedSupplier.version, canEditPhone),
        }).unwrap();
      } else {
        await createSupplier({ createSupplierRequest: toCreateSupplierRequest(values, canEditPhone) }).unwrap();
      }
      showNotification({ type: "success", message: editedSupplier ? t("catalog:supplierForm.updated") : t("catalog:supplierForm.created") });
      onClose();
      return undefined;
    } catch (error) {
      return error;
    }
  };

  return (
    <Modal
      opened
      onClose={onClose}
      title={editedSupplier ? t("catalog:supplierForm.editTitle") : t("catalog:supplierForm.createTitle")}
      closeButtonProps={{ "aria-label": t("common:actions.close") }}
    >
      <SupplierForm
        key={editedSupplier?.version ?? "new"}
        mode={editedSupplier ? "edit" : "create"}
        initialValues={editedSupplier ? supplierToFormValues(editedSupplier) : emptySupplierFormValues()}
        products={products?.items ?? []}
        canEditPhone={canEditPhone}
        onSubmit={handleSubmit}
        onCancel={onClose}
        onConflictReload={setEditedSupplier}
      />
    </Modal>
  );
};
