import { Button, Group, Pagination, SegmentedControl, Stack, Text } from "@mantine/core";
import { IconPlus } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useLocation, useNavigate } from "react-router-dom";

import {
  useApiErrorMessage,
  useDeliveriesListQuery,
  useLazyRequestsGetQuery,
  useRequestsReceiveMutation,
  useSitesListQuery,
} from "@chantier-frontend/api-core";
import { usePermissions } from "@chantier-frontend/authentication";
import { GenericEmptyComponent, GenericErrorComponent, GenericLoaderComponent, useNotifications } from "@chantier-frontend/user-interface";

import { BACK_OFFICE_ROUTES, requestDetailPath } from "../../../app/providers/router/navigationRoutes";
import { DeliveriesTable, type DeliverySortColumn } from "../components/DeliveriesTable.component";
import { DeliveryFilters } from "../components/DeliveryFilters.component";
import { ReceiveDialog } from "../components/ReceiveDialog.component";
import { DELIVERY_TABS, type DeliveryDetail } from "../types/deliveryTypes";
import { DeliveryDetailDrawerContainer } from "./DeliveryDetailDrawer.container";
import { DeliveryFormModalContainer } from "./DeliveryFormModal.container";
import { useDeliveryFilters } from "./useDeliveryFilters";

const SITES_PAGE_SIZE = 200;

/** Une livraison ouverte par adresse (`/materials/deliveries/:siteId/:deliveryId`) s'affiche dans un tiroir au-dessus de la liste. */
export interface DeliveriesBrowserContainerProps {
  open?: { siteId: string; deliveryId: string };
}

/**
 * Livraisons d'un chantier (CA-MAT-011.8) : onglets « Non rattachées », « À compléter » (BL manquant), « Avec réserve », filtres,
 * tri, page et recherche côté serveur, tous dans l'URL. Nouvelle livraison : `?create=1` (avec `requestId` depuis une demande).
 */
export const DeliveriesBrowserContainer = ({ open }: DeliveriesBrowserContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const navigate = useNavigate();
  const location = useLocation();
  const { can } = usePermissions();
  const { describe, getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const [receivePrompt, setReceivePrompt] = useState<{ siteId: string; requestId: string; number: string } | null>(null);
  const [loadRequest] = useLazyRequestsGetQuery();
  const [receiveRequest, receiveState] = useRequestsReceiveMutation();

  const sites = useSitesListQuery({ pageSize: SITES_PAGE_SIZE });
  const activeSites = (sites.data?.items ?? []).filter((site) => site.archivedAt === null);
  // La route des livraisons est celle d'un chantier : le seul chantier de l'utilisateur est choisi d'office.
  const { state, query, update, params, hasFilters } = useDeliveryFilters(activeSites.length === 1 ? (activeSites[0]?.id ?? "") : "");

  const { data, isLoading, isError, error, refetch } = useDeliveriesListQuery(query, { skip: state.siteId === "" });
  const totalPages = data ? Math.max(1, Math.ceil(data.totalCount / data.pageSize)) : 1;

  const creating = params.get("create") === "1";
  const closeCreation = () => update({ create: null, requestId: null });
  const closeDrawer = () => void navigate({ pathname: BACK_OFFICE_ROUTES.MATERIAL_DELIVERIES, search: location.search });

  // Après une livraison : on ouvre sa fiche (photos du bon) et, si elle complète la commande, on propose de réceptionner (CA-MAT-006.13).
  const afterSave = async (saved: DeliveryDetail) => {
    void navigate({ pathname: requestDetailPath(BACK_OFFICE_ROUTES.MATERIAL_DELIVERIES, saved.siteId, saved.id) });
    if (!saved.requestId || !can("Requests.Receive")) return;
    try {
      const request = await loadRequest({ siteId: saved.siteId, requestId: saved.requestId }, false).unwrap();
      if (request.status === "Delivered") setReceivePrompt({ siteId: saved.siteId, requestId: saved.requestId, number: request.number ?? saved.requestNumber ?? "" });
    } catch {
      // La proposition de réception est un confort : la livraison est déjà enregistrée.
    }
  };

  const receive = async (note: string | null) => {
    if (!receivePrompt) return;
    try {
      await receiveRequest({ siteId: receivePrompt.siteId, requestId: receivePrompt.requestId, receiveBody: { note } }).unwrap();
      showNotification({ type: "success", message: t("materials:receive.done", { number: receivePrompt.number }) });
    } catch (caught) {
      showNotification({ type: "error", message: getMessage(caught) });
    }
    setReceivePrompt(null);
  };

  const onSort = (column: DeliverySortColumn) => update({ sort: state.sort === column ? `-${column}` : state.sort === `-${column}` ? null : column });

  return (
    <Stack gap="md">
      <Group justify="space-between" align="flex-end" wrap="wrap">
        <SegmentedControl
          aria-label={t("materials:deliveries.tabsLabel")}
          value={state.tab}
          onChange={(value) => update({ tab: value === "all" ? null : value })}
          data={DELIVERY_TABS.map((tab) => ({ value: tab, label: t(`materials:deliveries.tabs.${tab}`) }))}
        />
        {can("Deliveries.Create") ? (
          <Button leftSection={<IconPlus size={18} aria-hidden />} onClick={() => update({ create: "1" })}>
            {t("materials:deliveries.create")}
          </Button>
        ) : null}
      </Group>

      <DeliveryFilters state={state} update={update} hasFilters={hasFilters} sites={activeSites} />

      {state.siteId === "" && sites.data ? <Text c="dimmed">{t("materials:deliveries.needSite")}</Text> : null}
      {isLoading ? <GenericLoaderComponent /> : null}
      {isError ? <GenericErrorComponent {...describe(error)} onRetry={() => void refetch()} /> : null}

      {data && data.items.length === 0 ? (
        <GenericEmptyComponent
          message={hasFilters || state.tab !== "all" ? t("materials:deliveries.noResults") : t("materials:deliveries.empty")}
          action={
            <Button variant="default" onClick={() => void refetch()}>
              {t("common:actions.refresh")}
            </Button>
          }
        />
      ) : null}

      {data && data.items.length > 0 ? (
        <>
          <DeliveriesTable
            deliveries={data.items}
            sort={state.sort}
            onSort={onSort}
            detailHref={(delivery) => requestDetailPath(BACK_OFFICE_ROUTES.MATERIAL_DELIVERIES, delivery.siteId, delivery.id, location.search)}
          />
          <Group justify="space-between">
            <Text size="sm" c="dimmed">
              {t("common:pagination.total", { count: data.totalCount })}
            </Text>
            {totalPages > 1 ? (
              <Pagination
                total={totalPages}
                value={state.page}
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

      {creating ? (
        <DeliveryFormModalContainer
          siteId={params.get("siteId") ?? (state.siteId || undefined)}
          requestId={params.get("requestId") ?? undefined}
          onClose={closeCreation}
          onSaved={(saved) => void afterSave(saved)}
        />
      ) : null}
      {open ? <DeliveryDetailDrawerContainer siteId={open.siteId} deliveryId={open.deliveryId} onClose={closeDrawer} /> : null}
      {receivePrompt ? (
        <ReceiveDialog
          title={t("materials:receive.ask", { number: receivePrompt.number })}
          noteMaxLength={200}
          loading={receiveState.isLoading}
          onConfirm={(note) => void receive(note)}
          onCancel={() => setReceivePrompt(null)}
        />
      ) : null}
    </Stack>
  );
};
