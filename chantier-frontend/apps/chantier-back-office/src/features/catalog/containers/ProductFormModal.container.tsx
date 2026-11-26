import { Modal } from "@mantine/core";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import { useProductsCreateMutation, useProductsUpdateMutation, type ProductResponse } from "@chantier-frontend/api-core";
import { useQuantityFormatter } from "@chantier-frontend/i18n";
import { GenericConfirmDialogComponent, useNotifications } from "@chantier-frontend/user-interface";

import { ProductForm } from "../components/ProductForm.component";
import {
  bagMassChanged,
  emptyProductFormValues,
  parseBagMass,
  productToFormValues,
  toCreateProductRequest,
  toUpdateProductRequest,
  type ProductFormValues,
} from "../types/productForm.zod";

export interface ProductFormModalContainerProps {
  /** Produit à modifier ; absent pour une création. */
  product?: ProductResponse;
  onClose: () => void;
}

/**
 * Création et modification d'un produit (avec `version`). Changer la masse du sac demande une confirmation :
 * le serveur recalcule alors les conversions des demandes ouvertes sans toucher aux quantités saisies (CA-MAT-015.3).
 */
export const ProductFormModalContainer = ({ product, onClose }: ProductFormModalContainerProps) => {
  const { t } = useTranslation(["catalog", "common"]);
  const { showNotification } = useNotifications();
  const { quantityText } = useQuantityFormatter();
  const [editedProduct, setEditedProduct] = useState<ProductResponse | undefined>(product);
  const [pendingMassChange, setPendingMassChange] = useState<ProductFormValues | null>(null);
  const [createProduct] = useProductsCreateMutation();
  const [updateProduct] = useProductsUpdateMutation();

  const save = async (values: ProductFormValues): Promise<unknown> => {
    try {
      if (editedProduct) {
        await updateProduct({
          productId: editedProduct.id,
          updateProductRequest: toUpdateProductRequest(values, editedProduct.version),
        }).unwrap();
      } else {
        await createProduct({ createProductRequest: toCreateProductRequest(values) }).unwrap();
      }
      showNotification({ type: "success", message: editedProduct ? t("catalog:productForm.updated") : t("catalog:productForm.created") });
      onClose();
      return undefined;
    } catch (error) {
      return error;
    }
  };

  const handleSubmit = async (values: ProductFormValues): Promise<unknown> => {
    if (editedProduct && bagMassChanged(editedProduct, values)) {
      setPendingMassChange(values);
      return undefined;
    }
    return save(values);
  };

  const confirmMassChange = async () => {
    const values = pendingMassChange;
    setPendingMassChange(null);
    if (values) await save(values);
  };

  const newMass = pendingMassChange ? parseBagMass(pendingMassChange.bagMassKg) : null;

  return (
    <>
      <Modal
        opened
        onClose={onClose}
        size="lg"
        title={editedProduct ? t("catalog:productForm.editTitle") : t("catalog:productForm.createTitle")}
        closeButtonProps={{ "aria-label": t("common:actions.close") }}
      >
        <ProductForm
          key={editedProduct?.version ?? "new"}
          mode={editedProduct ? "edit" : "create"}
          initialValues={editedProduct ? productToFormValues(editedProduct) : emptyProductFormValues()}
          onSubmit={handleSubmit}
          onCancel={onClose}
          onConflictReload={setEditedProduct}
        />
      </Modal>
      <GenericConfirmDialogComponent
        opened={pendingMassChange !== null}
        title={t("catalog:productForm.bagMassChangeTitle")}
        message={t("catalog:productForm.bagMassChangeMessage", { mass: newMass === null ? "" : quantityText({ value: Number(newMass), unit: "kg" }) })}
        confirmLabel={t("catalog:productForm.bagMassChangeConfirm")}
        onConfirm={() => void confirmMassChange()}
        onCancel={() => setPendingMassChange(null)}
      />
    </>
  );
};
