import { Button, Group, Pagination, Select, Stack, Text, TextInput } from "@mantine/core";
import { useDebouncedCallback } from "@mantine/hooks";
import { IconPlus, IconSearch } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import {
  useApiErrorMessage,
  useProductsListQuery,
  useSuppliersActivateMutation,
  useSuppliersDeactivateMutation,
  useSuppliersListQuery,
  type SupplierResponse,
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
import { SuppliersTable } from "../components/SuppliersTable.component";
import { SupplierFormModalContainer } from "./SupplierFormModal.container";

export const SUPPLIERS_PAGE_SIZE = 20;
const SEARCH_DEBOUNCE_MS = 300;
const PRODUCT_NAMES_PAGE_SIZE = 200;

/** Fournisseurs : recherche et état dans l'URL, pagination côté serveur ; le téléphone suit `SupplierPhone.View`. */
export const SuppliersBrowserContainer = () => {
  const { t } = useTranslation(["catalog", "common"]);
  const { can } = usePermissions();
  const { describe, getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const { params, update, page } = useUrlFilters();
  const [editing, setEditing] = useState<SupplierResponse | "new" | null>(null);
  const [toggling, setToggling] = useState<SupplierResponse | null>(null);
  const [activate, { isLoading: isActivating }] = useSuppliersActivateMutation();
  const [deactivate, { isLoading: isDeactivating }] = useSuppliersDeactivateMutation();

  const q = params.get("q") ?? "";
  const stateParam = params.get("state");
  const isActive = stateParam === "active" ? true : stateParam === "inactive" ? false : undefined;

  const [searchText, setSearchText] = useState(q);
  const updateSearch = useDebouncedCallback((value: string) => update({ q: value.trim() }), SEARCH_DEBOUNCE_MS);

  const { data, isLoading, isError, error, refetch } = useSuppliersListQuery({ q: q || undefined, isActive, page, pageSize: SUPPLIERS_PAGE_SIZE });
  // Noms des produits fournis : lecture du catalogue (mise en cache, partagée avec le formulaire).
  const { data: products } = useProductsListQuery({ pageSize: PRODUCT_NAMES_PAGE_SIZE });

  const hasFilters = q !== "" || isActive !== undefined;
  const totalPages = data ? Math.max(1, Math.ceil(data.totalCount / data.pageSize)) : 1;

  const confirmToggle = async () => {
    const supplier = toggling;
    if (!supplier) return;
    try {
      if (supplier.isActive) await deactivate({ supplierId: supplier.id }).unwrap();
      else await activate({ supplierId: supplier.id }).unwrap();
      showNotification({ type: "success", message: t(supplier.isActive ? "catalog:suppliers.deactivated" : "catalog:suppliers.activated") });
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
            placeholder={t("catalog:suppliers.searchPlaceholder")}
            leftSection={<IconSearch size={16} aria-hidden />}
            value={searchText}
            onChange={(event) => {
              setSearchText(event.currentTarget.value);
              updateSearch(event.currentTarget.value);
            }}
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
        {can("Suppliers.Create") ? (
          <Button leftSection={<IconPlus size={18} aria-hidden />} onClick={() => setEditing("new")}>
            {t("catalog:suppliers.create")}
          </Button>
        ) : null}
      </Group>

      {isLoading ? <GenericLoaderComponent /> : null}
      {isError ? <GenericErrorComponent {...describe(error)} onRetry={() => void refetch()} /> : null}

      {data && data.items.length === 0 ? (
        <GenericEmptyComponent
          message={hasFilters ? t("catalog:suppliers.noResults") : t("catalog:suppliers.empty")}
          action={
            hasFilters ? (
              <Button
                variant="default"
                onClick={() => {
                  setSearchText("");
                  update({ q: null, state: null });
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
          <SuppliersTable
            suppliers={data.items}
            products={products?.items ?? []}
            showPhone={can("SupplierPhone.View")}
            canUpdate={can("Suppliers.Update")}
            onEdit={setEditing}
            onToggle={setToggling}
          />
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

      {editing ? <SupplierFormModalContainer supplier={editing === "new" ? undefined : editing} onClose={() => setEditing(null)} /> : null}

      <GenericConfirmDialogComponent
        opened={toggling !== null}
        title={t(toggling?.isActive ? "catalog:suppliers.deactivateTitle" : "catalog:suppliers.activateTitle")}
        message={t(toggling?.isActive ? "catalog:suppliers.deactivateMessage" : "catalog:suppliers.activateMessage", {
          name: toggling?.name ?? "",
        })}
        confirmLabel={t(toggling?.isActive ? "catalog:suppliers.deactivateConfirm" : "catalog:suppliers.activateConfirm")}
        danger={toggling?.isActive === true}
        loading={isActivating || isDeactivating}
        onConfirm={() => void confirmToggle()}
        onCancel={() => setToggling(null)}
      />
    </Stack>
  );
};
