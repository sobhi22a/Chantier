import { Button, Group, Pagination, Stack, Text } from "@mantine/core";
import { IconCheck, IconX } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useLocation, useNavigate } from "react-router-dom";

import {
  useApiErrorMessage,
  useCrossSiteRequestsListQuery,
  useRequestsApproveBatchMutation,
  type BatchItemResult,
  type MaterialRequestResponse,
} from "@chantier-frontend/api-core";
import { GenericEmptyComponent, GenericErrorComponent, GenericLoaderComponent, useNotifications } from "@chantier-frontend/user-interface";

import { BACK_OFFICE_ROUTES, requestDetailPath } from "../../../app/providers/router/navigationRoutes";
import { BatchResultsModal } from "../components/BatchResultsModal.component";
import { RequestFilters } from "../components/RequestFilters.component";
import { RequestsTable, type RequestSortColumn } from "../components/RequestsTable.component";
import { groupBySite } from "../types/requestTypes";
import { RequestActionsContainer, useApproveRequest, type RequestActionKind } from "./RequestActions.container";
import { RequestDetailDrawerContainer } from "./RequestDetailDrawer.container";
import { useRequestFilters } from "./useRequestFilters";

/** Un lot valide 50 demandes au plus (contrat) ; la page de la liste a la même taille. */
export const APPROVE_BATCH_LIMIT = 50;

export interface ToApproveContainerProps {
  open?: { siteId: string; requestId: string };
}

/**
 * File « À valider » du conducteur sur tous ses chantiers (CA-MAT-003) : valider en un clic, refuser avec un motif,
 * valider avec une autre quantité, ou sélectionner jusqu'à 50 demandes. Les appels d'un lot sont regroupés par chantier
 * et chaque demande est tracée individuellement ; celles qui échouent sont listées avec leur motif.
 */
export const ToApproveContainer = ({ open }: ToApproveContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const navigate = useNavigate();
  const location = useLocation();
  const { describe } = useApiErrorMessage();
  const { state, query, update, params, hasFilters } = useRequestFilters({ fixedView: "toApprove", pageSize: APPROVE_BATCH_LIMIT });

  const { data, isLoading, isError, error, refetch } = useCrossSiteRequestsListQuery(query);
  const totalPages = data ? Math.max(1, Math.ceil(data.totalCount / data.pageSize)) : 1;
  // La sélection reste valable d'une page à l'autre, mais pas d'un filtre à l'autre.
  const selectionScope = [...params.entries()].filter(([key]) => key !== "page").map(([key, value]) => `${key}=${value}`).join("&");

  return (
    <Stack gap="md">
      <RequestFilters state={state} update={update} hasFilters={hasFilters} />

      {isLoading ? <GenericLoaderComponent /> : null}
      {isError ? <GenericErrorComponent {...describe(error)} onRetry={() => void refetch()} /> : null}

      {data && data.items.length === 0 ? (
        <GenericEmptyComponent
          message={hasFilters ? t("materials:list.noResults") : t("materials:toApprove.empty")}
          action={
            <Button variant="default" onClick={() => void refetch()}>
              {t("common:actions.refresh")}
            </Button>
          }
        />
      ) : null}

      {data && data.items.length > 0 ? (
        <ApprovalList
          key={selectionScope}
          requests={data.items}
          totalCount={data.totalCount}
          totalPages={totalPages}
          page={state.page}
          sort={state.sort}
          showSite={state.siteId === ""}
          search={location.search}
          onUpdate={update}
        />
      ) : null}

      {open ? (
        <RequestDetailDrawerContainer
          siteId={open.siteId}
          requestId={open.requestId}
          onClose={() => void navigate({ pathname: BACK_OFFICE_ROUTES.MATERIAL_TO_APPROVE, search: location.search })}
        />
      ) : null}
    </Stack>
  );
};

interface ApprovalListProps {
  requests: readonly MaterialRequestResponse[];
  totalCount: number;
  totalPages: number;
  page: number;
  sort: string;
  showSite: boolean;
  search: string;
  onUpdate: (changes: Record<string, string | null>) => void;
}

const ApprovalList = ({ requests, totalCount, totalPages, page, sort, showSite, search, onUpdate }: ApprovalListProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const { approveRequest, isApproving } = useApproveRequest();
  const [approveBatch, { isLoading: isBatching }] = useRequestsApproveBatchMutation();
  const [selected, setSelected] = useState<Map<string, MaterialRequestResponse>>(new Map());
  const [rowAction, setRowAction] = useState<{ request: MaterialRequestResponse; action: RequestActionKind } | null>(null);
  const [results, setResults] = useState<{ results: BatchItemResult[]; numbers: Map<string, string> } | null>(null);

  const toggle = (request: MaterialRequestResponse) =>
    setSelected((previous) => {
      const next = new Map(previous);
      if (next.has(request.id)) next.delete(request.id);
      else if (next.size < APPROVE_BATCH_LIMIT) next.set(request.id, request);
      return next;
    });

  const togglePage = (checked: boolean) =>
    setSelected((previous) => {
      const next = new Map(previous);
      for (const request of requests) {
        if (!checked) next.delete(request.id);
        else if (next.size < APPROVE_BATCH_LIMIT) next.set(request.id, request);
      }
      return next;
    });

  const approveSelection = async () => {
    const chosen = [...selected.values()];
    const collected: BatchItemResult[] = [];
    try {
      for (const [siteId, siteRequests] of groupBySite(chosen)) {
        const response = await approveBatch({ siteId, requestIdsBody: { requestIds: siteRequests.map((request) => request.id) } }).unwrap();
        collected.push(...response.results);
      }
    } catch (error) {
      showNotification({ type: "error", message: getMessage(error) });
    }
    if (collected.length > 0) {
      setResults({ results: collected, numbers: new Map(chosen.map((request) => [request.id, request.number])) });
      setSelected(new Map());
    }
  };

  const onSort = (column: RequestSortColumn) => onUpdate({ sort: sort === column ? `-${column}` : sort === `-${column}` ? null : column });

  return (
    <>
      {selected.size > 0 ? (
        <Group>
          <Text role="status">{t("materials:list.selection", { count: selected.size })}</Text>
          <Button leftSection={<IconCheck size={16} aria-hidden />} loading={isBatching} onClick={() => void approveSelection()}>
            {t("materials:toApprove.approveSelection")}
          </Button>
          <Text size="sm" c={selected.size >= APPROVE_BATCH_LIMIT ? "orange.9" : "dimmed"}>
            {selected.size >= APPROVE_BATCH_LIMIT ? t("materials:toApprove.limitReached") : t("materials:toApprove.selectionLimit")}
          </Text>
        </Group>
      ) : null}

      <RequestsTable
        requests={requests}
        showSite={showSite}
        sort={sort}
        onSort={onSort}
        detailHref={(request) => requestDetailPath(BACK_OFFICE_ROUTES.MATERIAL_TO_APPROVE, request.siteId, request.id, search)}
        selection={{ selectedIds: new Set(selected.keys()), limit: APPROVE_BATCH_LIMIT, onToggle: toggle, onTogglePage: togglePage }}
        actionsLabel={t("materials:detail.actions")}
        renderActions={(request) => (
          <Group gap="xs" wrap="nowrap">
            <Button size="compact-md" loading={isApproving} aria-label={`${t("materials:actions.approve")} ${request.number}`} onClick={() => void approveRequest(request)}>
              {t("materials:actions.approve")}
            </Button>
            <Button size="compact-md" variant="default" aria-label={`${t("materials:actions.approveWithQuantity")} ${request.number}`} onClick={() => setRowAction({ request, action: "approveQuantity" })}>
              {t("materials:actions.approveWithQuantity")}
            </Button>
            <Button size="compact-md" color="red" variant="light" leftSection={<IconX size={14} aria-hidden />} aria-label={`${t("materials:actions.reject")} ${request.number}`} onClick={() => setRowAction({ request, action: "reject" })}>
              {t("materials:actions.reject")}
            </Button>
          </Group>
        )}
      />

      <Group justify="space-between">
        <Text size="sm" c="dimmed">
          {t("common:pagination.total", { count: totalCount })}
        </Text>
        {totalPages > 1 ? (
          <Pagination
            total={totalPages}
            value={page}
            onChange={(value) => onUpdate({ page: value > 1 ? String(value) : null })}
            getControlProps={(control) => ({
              "aria-label": control === "previous" ? t("common:actions.previous") : control === "next" ? t("common:actions.next") : undefined,
            })}
            getItemProps={(item) => ({ "aria-label": t("common:pagination.page", { page: item, total: totalPages }) })}
          />
        ) : null}
      </Group>

      {rowAction ? <RequestActionsContainer request={rowAction.request} action={rowAction.action} onClose={() => setRowAction(null)} /> : null}
      {results ? (
        <BatchResultsModal
          title={t("materials:toApprove.resultsTitle")}
          results={results.results}
          numberOf={(requestId) => results.numbers.get(requestId) ?? requestId}
          appliedLabel={t("materials:batch.applied")}
          onClose={() => setResults(null)}
        />
      ) : null}
    </>
  );
};
