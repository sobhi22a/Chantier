import { Button, Group, Pagination, Select, Stack, Text, TextInput } from "@mantine/core";
import { useDebouncedCallback } from "@mantine/hooks";
import { IconPlus, IconSearch } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import {
  useApiErrorMessage,
  useProductsActivateMutation,
  useProductsDeactivateMutation,
  useProductsListQuery,
  type ProductCategory,
  type ProductResponse,
} from "@chantier-frontend/api-core";
import { usePermissions } from "@chantier-frontend/authentication";
import {
  GenericConfirmDialogComponent,
  GenericEmptyComponent,
  GenericErrorComponent,
  GenericLoaderComponent,
  useNotifications,
} from "@chantier-frontend/user-interface";

import { useUrlFilters } from "../../../shared/hooks/useUrlFilters";
import { ProductsTable } from "../components/ProductsTable.component";
import { PRODUCT_CATEGORIES } from "../types/productForm.zod";
import { ProductFormModalContainer } from "./ProductFormModal.container";

export const PRODUCTS_PAGE_SIZE = 20;
const SEARCH_DEBOUNCE_MS = 300;

const isCategory = (value: string | null): value is ProductCategory => PRODUCT_CATEGORIES.some((category) => category === value);

/** Catalogue des produits : recherche, catégorie et état dans l'URL, pagination côté serveur ; désactiver, jamais supprimer. */
export const ProductsBrowserContainer = () => {
  const { t } = useTranslation(["catalog", "common"]);
  const { can } = usePermissions();
  const { describe, getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const { params, update, page } = useUrlFilters();
  const [editing, setEditing] = useState<ProductResponse | "new" | null>(null);
  const [toggling, setToggling] = useState<ProductResponse | null>(null);
  const [activate, { isLoading: isActivating }] = useProductsActivateMutation();
  const [deactivate, { isLoading: isDeactivating }] = useProductsDeactivateMutation();

  const q = params.get("q") ?? "";
  const categoryParam = params.get("category");
  const category = isCategory(categoryParam) ? categoryParam : undefined;
  const stateParam = params.get("state");
  const isActive = stateParam === "active" ? true : stateParam === "inactive" ? false : undefined;

  // La saisie est locale (réactive) ; l'URL, et donc la requête, suit avec un léger délai.
  const [searchText, setSearchText] = useState(q);
  const updateSearch = useDebouncedCallback((value: string) => update({ q: value.trim() }), SEARCH_DEBOUNCE_MS);

  const { data, isLoading, isError, error, refetch } = useProductsListQuery({
    q: q || undefined,
    category,
    isActive,
    page,
    pageSize: PRODUCTS_PAGE_SIZE,
  });

  const hasFilters = q !== "" || category !== undefined || isActive !== undefined;
  const totalPages = data ? Math.max(1, Math.ceil(data.totalCount / data.pageSize)) : 1;
  const canCreate = can("Products.Create");
  const canUpdate = can("Products.Update");

  const confirmToggle = async () => {
    const product = toggling;
    if (!product) return;
    try {
      if (product.isActive) await deactivate({ productId: product.id }).unwrap();
      else await activate({ productId: product.id }).unwrap();
      showNotification({ type: "success", message: t(product.isActive ? "catalog:products.deactivated" : "catalog:products.activated") });
    } catch (caught) {
      showNotification({ type: "error", message: getMessage(caught) });
    } finally {
      setToggling(null);
    }
  };

  return (
    <Stack gap="md">
      <Group justify="space-between" align="flex-end" wrap="wrap">
        <Group align="flex-end" wrap="wrap">
          <TextInput
            label={t("catalog:filters.search")}
            placeholder={t("catalog:products.searchPlaceholder")}
            leftSection={<IconSearch size={16} aria-hidden />}
            value={searchText}
            onChange={(event) => {
              setSearchText(event.currentTarget.value);
              updateSearch(event.currentTarget.value);
            }}
          />
          <Select
            label={t("catalog:filters.category")}
            placeholder={t("catalog:filters.allCategories")}
            clearable
            data={PRODUCT_CATEGORIES.map((value) => ({ value, label: t(`catalog:categories.${value}`) }))}
            value={category ?? null}
            onChange={(value) => update({ category: value })}
          />
          <Select
            label={t("catalog:filters.state")}
            placeholder={t("catalog:filters.allStates")}
            clearable
            data={[
              { value: "active", label: t("catalog:state.active") },
              { value: "inactive", label: t("catalog:state.inactive") },
            ]}
            value={stateParam === "active" || stateParam === "inactive" ? stateParam : null}
            onChange={(value) => update({ state: value })}
          />
        </Group>
        {canCreate ? (
          <Button leftSection={<IconPlus size={18} aria-hidden />} onClick={() => setEditing("new")}>
            {t("catalog:products.create")}
          </Button>
        ) : null}
      </Group>

      {isLoading ? <GenericLoaderComponent /> : null}
      {isError ? <GenericErrorComponent {...describe(error)} onRetry={() => void refetch()} /> : null}

      {data && data.items.length === 0 ? (
        <GenericEmptyComponent
          message={hasFilters ? t("catalog:products.noResults") : t("catalog:products.empty")}
          action={
            hasFilters ? (
              <Button
                variant="default"
                onClick={() => {
                  setSearchText("");
                  update({ q: null, category: null, state: null });
                }}
              >
                {t("catalog:filters.reset")}
              </Button>
            ) : undefined
          }
        />
      ) : null}

      {data && data.items.length > 0 ? (
        <>
          <ProductsTable products={data.items} canUpdate={canUpdate} onEdit={setEditing} onToggle={setToggling} />
          <Group justify="space-between">
            <Text size="sm" c="dimmed">
              {t("common:pagination.total", { count: data.totalCount })}
            </Text>
            {totalPages > 1 ? (
              <Pagination
                total={totalPages}
                value={page}
                onChange={(value) => update({ page: value > 1 ? String(value) : null })}
                getControlProps={(control) => ({
                  "aria-label": control === "previous" ? t("common:actions.previous") : control === "next" ? t("common:actions.next") : undefined,
                })}
                getItemProps={(item) => ({ "aria-label": t("common:pagination.page", { page: item, total: totalPages }) })}
              />
            ) : null}
          </Group>
        </>
      ) : null}

      {editing ? <ProductFormModalContainer product={editing === "new" ? undefined : editing} onClose={() => setEditing(null)} /> : null}

      <GenericConfirmDialogComponent
        opened={toggling !== null}
        title={t(toggling?.isActive ? "catalog:products.deactivateTitle" : "catalog:products.activateTitle")}
        message={t(toggling?.isActive ? "catalog:products.deactivateMessage" : "catalog:products.activateMessage", {
          name: toggling?.nameFr ?? "",
        })}
        confirmLabel={t(toggling?.isActive ? "catalog:products.deactivateConfirm" : "catalog:products.activateConfirm")}
        danger={toggling?.isActive === true}
        loading={isActivating || isDeactivating}
        onConfirm={() => void confirmToggle()}
        onCancel={() => setToggling(null)}
      />
    </Stack>
  );
};
