import { Button, Group, Pagination, Stack, Text } from "@mantine/core";
import { IconShoppingCart } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useLocation, useNavigate } from "react-router-dom";

import {
  useApiErrorMessage,
  useCrossSiteRequestsListQuery,
  useFollowUpGetQuery,
  useSitesListQuery,
  type MaterialRequestResponse,
} from "@chantier-frontend/api-core";
import { usePermissions } from "@chantier-frontend/authentication";
import { GenericEmptyComponent, GenericErrorComponent, GenericLoaderComponent } from "@chantier-frontend/user-interface";

import { BACK_OFFICE_ROUTES, requestDetailPath } from "../../../app/providers/router/navigationRoutes";
import { RequestFilters } from "../components/RequestFilters.component";
import { RequestsTable, type RequestSortColumn } from "../components/RequestsTable.component";
import { ToOrderTotals } from "../components/ToOrderTotals.component";
import { RequestActionsContainer } from "./RequestActions.container";
import { RequestDetailDrawerContainer } from "./RequestDetailDrawer.container";
import { useRequestFilters } from "./useRequestFilters";

export const TO_ORDER_PAGE_SIZE = 50;

export interface ToOrderContainerProps {
  open?: { siteId: string; requestId: string };
}

/**
 * File « À commander » des Achats (CA-MAT-005.1) : demandes validées de tous les chantiers affectés, urgence puis date de besoin,
 * avec les totaux par produit et par unité du chantier choisi. « Commander » ouvre le formulaire de commande ; le montant n'est
 * jamais calculé ici (le serveur le renvoie, et seulement avec `Prices.View`).
 */
export const ToOrderContainer = ({ open }: ToOrderContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const navigate = useNavigate();
  const location = useLocation();
  const { describe } = useApiErrorMessage();
  const { can } = usePermissions();
  const { state, query, update, hasFilters } = useRequestFilters({ fixedView: "toOrder", pageSize: TO_ORDER_PAGE_SIZE });
  const [ordering, setOrdering] = useState<MaterialRequestResponse | null>(null);

  const { data, isLoading, isError, error, refetch } = useCrossSiteRequestsListQuery(query);
  const totalPages = data ? Math.max(1, Math.ceil(data.totalCount / data.pageSize)) : 1;

  // Les totaux sont ceux d'un chantier (route de suivi) : le chantier filtré, ou le seul chantier de l'utilisateur.
  const sites = useSitesListQuery({ pageSize: 200 });
  const activeSites = (sites.data?.items ?? []).filter((site) => site.archivedAt === null);
  const totalsSiteId = state.siteId !== "" ? state.siteId : activeSites.length === 1 ? (activeSites[0]?.id ?? "") : "";
  const followUp = useFollowUpGetQuery({ siteId: totalsSiteId }, { skip: totalsSiteId === "" });

  const onSort = (column: RequestSortColumn) =>
    update({ sort: state.sort === column ? `-${column}` : state.sort === `-${column}` ? null : column });

  return (
    <Stack gap="md">
      <RequestFilters state={state} update={update} hasFilters={hasFilters} />

      {totalsSiteId === "" ? (
        sites.data ? <Text c="dimmed">{t("materials:toOrder.totalsNeedSite")}</Text> : null
      ) : followUp.isLoading ? (
        <GenericLoaderComponent />
      ) : followUp.isError ? (
        <GenericErrorComponent {...describe(followUp.error)} onRetry={() => void followUp.refetch()} />
      ) : followUp.data ? (
        <ToOrderTotals lines={followUp.data.toOrderTotals} />
      ) : null}

      {isLoading ? <GenericLoaderComponent /> : null}
      {isError ? <GenericErrorComponent {...describe(error)} onRetry={() => void refetch()} /> : null}

      {data && data.items.length === 0 ? (
        <GenericEmptyComponent
          message={hasFilters ? t("materials:list.noResults") : t("materials:toOrder.empty")}
          action={
            <Button variant="default" onClick={() => void refetch()}>
              {t("common:actions.refresh")}
            </Button>
          }
        />
      ) : null}

      {data && data.items.length > 0 ? (
        <>
          <RequestsTable
            requests={data.items}
            showSite={state.siteId === ""}
            sort={state.sort}
            onSort={onSort}
            detailHref={(request) => requestDetailPath(BACK_OFFICE_ROUTES.MATERIAL_TO_ORDER, request.siteId, request.id, location.search)}
            actionsLabel={t("materials:detail.actions")}
            renderActions={
              can("Orders.Create")
                ? (request) => (
                    <Button
                      size="compact-md"
                      leftSection={<IconShoppingCart size={14} aria-hidden />}
                      aria-label={t("materials:toOrder.orderRow", { number: request.number })}
                      onClick={() => setOrdering(request)}
                    >
                      {t("materials:actions.order")}
                    </Button>
                  )
                : undefined
            }
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

      {ordering ? <RequestActionsContainer request={ordering} action="order" onClose={() => setOrdering(null)} /> : null}
      {open ? (
        <RequestDetailDrawerContainer
          siteId={open.siteId}
          requestId={open.requestId}
          onClose={() => void navigate({ pathname: BACK_OFFICE_ROUTES.MATERIAL_TO_ORDER, search: location.search })}
        />
      ) : null}
    </Stack>
  );
};
