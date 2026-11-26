import { Button, Group, Pagination, SegmentedControl, Stack, Text } from "@mantine/core";
import { IconArchive, IconPlus } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useLocation, useNavigate } from "react-router-dom";

import {
  useApiErrorMessage,
  useCrossSiteRequestsListQuery,
  useRequestsArchiveBatchMutation,
  type BatchItemResult,
  type MaterialRequestResponse,
} from "@chantier-frontend/api-core";
import { usePermissions } from "@chantier-frontend/authentication";
import { GenericConfirmDialogComponent, GenericEmptyComponent, GenericErrorComponent, GenericLoaderComponent, useNotifications } from "@chantier-frontend/user-interface";

import { BACK_OFFICE_ROUTES, requestDetailPath } from "../../../app/providers/router/navigationRoutes";
import { BatchResultsModal } from "../components/BatchResultsModal.component";
import { RequestFilters } from "../components/RequestFilters.component";
import { RequestsTable, type RequestSortColumn } from "../components/RequestsTable.component";
import { groupBySite, REQUEST_VIEWS } from "../types/requestTypes";
import { RequestDetailDrawerContainer } from "./RequestDetailDrawer.container";
import { RequestFormModalContainer } from "./RequestFormModal.container";
import { useRequestFilters } from "./useRequestFilters";

export const ARCHIVE_BATCH_LIMIT = 100;

/** Une demande ouverte par adresse (`/materials/requests/:siteId/:requestId`) s'affiche dans un tiroir au-dessus de la liste. */
export interface RequestsBrowserContainerProps {
  open?: { siteId: string; requestId: string };
}

/**
 * Demandes de matériaux (CA-MAT-002) : vues « à suivre », terminées, refusées et annulées, archivées ; filtres, tri, page et
 * recherche côté serveur, tous dans l'URL. Le serveur ne renvoie que les chantiers affectés ; chaque ligne porte le code du chantier.
 */
export const RequestsBrowserContainer = ({ open }: RequestsBrowserContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const navigate = useNavigate();
  const location = useLocation();
  const { can } = usePermissions();
  const { describe, getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const { state, query, update, params, hasFilters } = useRequestFilters({ defaultSort: undefined });
  const [creating, setCreating] = useState(false);

  const { data, isLoading, isError, error, refetch } = useCrossSiteRequestsListQuery(query);
  const totalPages = data ? Math.max(1, Math.ceil(data.totalCount / data.pageSize)) : 1;

  // La sélection d'un lot d'archivage reste valable d'une page à l'autre, mais pas d'un filtre à l'autre.
  const selectionScope = [...params.entries()].filter(([key]) => key !== "page").map(([key, value]) => `${key}=${value}`).join("&");

  const closeDrawer = () => void navigate({ pathname: BACK_OFFICE_ROUTES.MATERIAL_REQUESTS, search: location.search });

  return (
    <Stack gap="md">
      <Group justify="space-between" align="flex-end" wrap="wrap">
        <SegmentedControl
          aria-label={t("materials:list.viewsLabel")}
          value={state.view}
          onChange={(value) => update({ view: value === "toFollow" ? null : value })}
          data={REQUEST_VIEWS.map((view) => ({ value: view, label: t(`materials:views.${view}`) }))}
        />
        {can("Requests.Create") ? (
          <Button leftSection={<IconPlus size={18} aria-hidden />} onClick={() => setCreating(true)}>
            {t("materials:list.create")}
          </Button>
        ) : null}
      </Group>

      <RequestFilters state={state} update={update} hasFilters={hasFilters} showMine />

      {isLoading ? <GenericLoaderComponent /> : null}
      {isError ? <GenericErrorComponent {...describe(error)} onRetry={() => void refetch()} /> : null}

      {data && data.items.length === 0 ? (
        <GenericEmptyComponent
          message={hasFilters ? t("materials:list.noResults") : t("materials:list.empty")}
          action={
            <Button variant="default" onClick={() => void refetch()}>
              {t("common:actions.refresh")}
            </Button>
          }
        />
      ) : null}

      {data && data.items.length > 0 ? (
        <RequestsList
          key={selectionScope}
          requests={data.items}
          totalCount={data.totalCount}
          totalPages={totalPages}
          page={state.page}
          sort={state.sort}
          view={state.view}
          showSite={state.siteId === ""}
          search={location.search}
          canArchive={can("Requests.Archive")}
          onUpdate={update}
          onError={(error) => showNotification({ type: "error", message: getMessage(error) })}
        />
      ) : null}

      {creating ? <RequestFormModalContainer defaultSiteId={state.siteId || undefined} onClose={() => setCreating(false)} /> : null}
      {open ? <RequestDetailDrawerContainer siteId={open.siteId} requestId={open.requestId} onClose={closeDrawer} /> : null}
    </Stack>
  );
};

interface RequestsListProps {
  requests: readonly MaterialRequestResponse[];
  totalCount: number;
  totalPages: number;
  page: number;
  sort: string;
  view: string;
  showSite: boolean;
  search: string;
  canArchive: boolean;
  onUpdate: (changes: Record<string, string | null>) => void;
  onError: (error: unknown) => void;
}

/** Tableau, pagination et lot d'archivage (demandes terminées uniquement, 100 au plus). */
const RequestsList = ({ requests, totalCount, totalPages, page, sort, view, showSite, search, canArchive, onUpdate, onError }: RequestsListProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const [selected, setSelected] = useState<Map<string, MaterialRequestResponse>>(new Map());
  const [confirming, setConfirming] = useState(false);
  const [results, setResults] = useState<{ results: BatchItemResult[]; numbers: Map<string, string> } | null>(null);
  const [archiveBatch, { isLoading: isArchiving }] = useRequestsArchiveBatchMutation();

  // Archiver : seulement les demandes terminées (Refusée, Annulée, Réceptionnée) qui ne le sont pas encore.
  const canSelect = canArchive && (view === "received" || view === "closed");

  const toggle = (request: MaterialRequestResponse) =>
    setSelected((previous) => {
      const next = new Map(previous);
      if (next.has(request.id)) next.delete(request.id);
      else if (next.size < ARCHIVE_BATCH_LIMIT) next.set(request.id, request);
      return next;
    });

  const togglePage = (checked: boolean) =>
    setSelected((previous) => {
      const next = new Map(previous);
      for (const request of requests) {
        if (!checked) next.delete(request.id);
        else if (next.size < ARCHIVE_BATCH_LIMIT) next.set(request.id, request);
      }
      return next;
    });

  const archiveSelection = async () => {
    const chosen = [...selected.values()];
    setConfirming(false);
    const bySite = groupBySite(chosen);
    const collected: BatchItemResult[] = [];
    try {
      // Un lot par chantier : l'archivage est une route de chantier, chaque demande est tracée individuellement.
      for (const [siteId, siteRequests] of bySite) {
        const response = await archiveBatch({ siteId, requestIdsBody: { requestIds: siteRequests.map((request) => request.id) } }).unwrap();
        collected.push(...response.results);
      }
    } catch (error) {
      onError(error);
    }
    if (collected.length > 0) {
      setResults({ results: collected, numbers: new Map(chosen.map((request) => [request.id, request.number])) });
      setSelected(new Map());
    }
  };

  const onSort = (column: RequestSortColumn) => onUpdate({ sort: sort === column ? `-${column}` : sort === `-${column}` ? null : column });

  return (
    <>
      {canSelect && selected.size > 0 ? (
        <Group>
          <Text role="status">{t("materials:list.selection", { count: selected.size })}</Text>
          <Button variant="default" leftSection={<IconArchive size={16} aria-hidden />} onClick={() => setConfirming(true)}>
            {t("materials:list.archiveSelection")}
          </Button>
          <Text size="sm" c="dimmed">
            {t("materials:list.archiveLimit")}
          </Text>
        </Group>
      ) : null}

      <RequestsTable
        requests={requests}
        showSite={showSite}
        sort={sort}
        onSort={onSort}
        detailHref={(request) => requestDetailPath(BACK_OFFICE_ROUTES.MATERIAL_REQUESTS, request.siteId, request.id, search)}
        selection={
          canSelect ? { selectedIds: new Set(selected.keys()), limit: ARCHIVE_BATCH_LIMIT, onToggle: toggle, onTogglePage: togglePage } : undefined
        }
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

      <GenericConfirmDialogComponent
        opened={confirming}
        title={t("materials:archive.batchTitle", { count: selected.size })}
        message={t("materials:archive.batchMessage")}
        confirmLabel={t("materials:archive.confirm")}
        loading={isArchiving}
        onConfirm={() => void archiveSelection()}
        onCancel={() => setConfirming(false)}
      />

      {results ? (
        <BatchResultsModal
          title={t("materials:archive.batchTitle", { count: results.results.length })}
          results={results.results}
          numberOf={(requestId) => results.numbers.get(requestId) ?? requestId}
          appliedLabel={t("materials:batch.archived")}
          onClose={() => setResults(null)}
        />
      ) : null}
    </>
  );
};
