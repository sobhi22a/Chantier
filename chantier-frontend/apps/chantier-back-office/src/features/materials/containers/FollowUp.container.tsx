import { Anchor, Button, Card, Group, Pagination, Select, SimpleGrid, Stack, Text, Title } from "@mantine/core";
import { useTranslation } from "react-i18next";
import { Link, useLocation, useNavigate } from "react-router-dom";

import { useApiErrorMessage, useFollowUpGetQuery, useRequestsListQuery, useSitesListQuery } from "@chantier-frontend/api-core";
import { formatAmount, Ltr, pickLocalizedName, useLanguage } from "@chantier-frontend/i18n";
import { GenericEmptyComponent, GenericErrorComponent, GenericLoaderComponent } from "@chantier-frontend/user-interface";

import { BACK_OFFICE_ROUTES, requestDetailPath } from "../../../app/providers/router/navigationRoutes";
import { useUrlFilters } from "../../../shared/hooks/useUrlFilters";
import { RequestsTable, type RequestSortColumn } from "../components/RequestsTable.component";
import { ToOrderTotals } from "../components/ToOrderTotals.component";
import { FOLLOW_UP_VIEWS, isFollowUpView, type FollowUpView } from "../types/requestTypes";
import { RequestDetailDrawerContainer } from "./RequestDetailDrawer.container";

const SITES_PAGE_SIZE = 200;
export const FOLLOW_UP_PAGE_SIZE = 20;

export interface FollowUpContainerProps {
  open?: { siteId: string; requestId: string };
}

/**
 * Suivi d'un chantier (CA-MAT-013) : cinq vues avec compteurs (À valider, À commander, Attendues, En retard, À réceptionner),
 * totaux à commander par produit et par unité, et montants du chantier SEULEMENT si le serveur les fournit (`Prices.View`).
 * Compteurs, totaux et montants viennent du serveur : le client n'additionne rien. Chantier, vue, tri et page sont dans l'URL.
 */
export const FollowUpContainer = ({ open }: FollowUpContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { language } = useLanguage();
  const navigate = useNavigate();
  const location = useLocation();
  const { describe } = useApiErrorMessage();
  const { params, update, page } = useUrlFilters();

  const sites = useSitesListQuery({ pageSize: SITES_PAGE_SIZE });
  const activeSites = (sites.data?.items ?? []).filter((site) => site.archivedAt === null);
  // Le suivi est celui d'un chantier : le seul chantier de l'utilisateur est choisi d'office.
  const siteId = params.get("siteId") ?? (activeSites.length === 1 ? (activeSites[0]?.id ?? "") : "");
  const viewParam = params.get("view");
  const view: FollowUpView = isFollowUpView(viewParam) ? viewParam : "toApprove";
  const sort = params.get("sort") ?? "";

  const followUp = useFollowUpGetQuery({ siteId }, { skip: siteId === "" });
  const list = useRequestsListQuery({ siteId, view, sort: sort || undefined, page, pageSize: FOLLOW_UP_PAGE_SIZE }, { skip: siteId === "" });
  const totalPages = list.data ? Math.max(1, Math.ceil(list.data.totalCount / list.data.pageSize)) : 1;

  const onSort = (column: RequestSortColumn) => update({ sort: sort === column ? `-${column}` : sort === `-${column}` ? null : column });
  const counters = followUp.data?.counters;

  return (
    <Stack gap="md">
      <Select
        label={t("materials:followUp.site")}
        placeholder={t("materials:followUp.sitePlaceholder")}
        searchable
        allowDeselect={false}
        data={activeSites.map((site) => ({ value: site.id, label: `${site.code} · ${pickLocalizedName(site, language)}` }))}
        value={siteId === "" ? null : siteId}
        onChange={(value) => update({ siteId: value, view: null, sort: null })}
        maw={420}
      />

      {siteId === "" ? (
        sites.data ? <Text c="dimmed">{t("materials:followUp.needSite")}</Text> : <GenericLoaderComponent />
      ) : (
        <>
          {followUp.isError ? <GenericErrorComponent {...describe(followUp.error)} onRetry={() => void followUp.refetch()} /> : null}

          <SimpleGrid cols={{ base: 2, sm: 3, lg: 5 }} spacing="sm" role="group" aria-label={t("materials:followUp.viewsLabel")}>
            {FOLLOW_UP_VIEWS.map((code) => {
              const count = counters?.[code];
              const selected = code === view;
              const label = t(`materials:followUp.counters.${code}`);
              return (
                <Card
                  key={code}
                  withBorder
                  padding="sm"
                  radius="md"
                  // Le chiffre vient du serveur. Rouge = en retard : toujours doublé du libellé « En retard ».
                  style={selected ? { borderColor: "var(--mantine-color-primary-6)", borderWidth: 2 } : undefined}
                >
                  <Anchor
                    component="button"
                    type="button"
                    onClick={() => update({ view: code === "toApprove" ? null : code })}
                    aria-pressed={selected}
                    aria-label={t("materials:followUp.counterLabel", { label, count: count ?? 0 })}
                    underline="never"
                    c="inherit"
                    mih={44}
                  >
                    <Text size="sm" fw={600}>
                      {label}
                    </Text>
                    <Text size="xl" fw={700} c={code === "late" && (count ?? 0) > 0 ? "orange.9" : undefined}>
                      <Ltr>{count ?? "…"}</Ltr>
                    </Text>
                  </Anchor>
                </Card>
              );
            })}
          </SimpleGrid>

          {followUp.data?.commercial ? (
            <Card withBorder padding="sm" radius="md" role="group" aria-label={t("materials:followUp.amounts.title")}>
              <Title order={2} size="h5" mb="xs">
                {t("materials:followUp.amounts.title")}
              </Title>
              <Group gap="xl">
                <Stack gap={0}>
                  <Text size="sm" c="dimmed">
                    {t("materials:followUp.amounts.ordered")}
                  </Text>
                  <Text fw={700}>
                    <Ltr>{formatAmount(followUp.data.commercial.orderedAmount)}</Ltr>
                  </Text>
                </Stack>
                <Stack gap={0}>
                  <Text size="sm" c="dimmed">
                    {t("materials:followUp.amounts.received")}
                  </Text>
                  <Text fw={700}>
                    <Ltr>{formatAmount(followUp.data.commercial.receivedValue)}</Ltr>
                  </Text>
                </Stack>
              </Group>
              <Text size="xs" c="dimmed" mt="xs">
                {t("materials:followUp.amounts.currencyNote")}
              </Text>
            </Card>
          ) : null}

          {view === "toOrder" && followUp.data ? <ToOrderTotals lines={followUp.data.toOrderTotals} /> : null}

          <Title order={2} size="h4">
            {t(`materials:followUp.viewTitle.${view}`)}
          </Title>
          {list.isLoading ? <GenericLoaderComponent /> : null}
          {list.isError ? <GenericErrorComponent {...describe(list.error)} onRetry={() => void list.refetch()} /> : null}
          {list.data && list.data.items.length === 0 ? (
            <GenericEmptyComponent
              message={t("materials:followUp.empty")}
              action={
                <Button variant="default" onClick={() => void list.refetch()}>
                  {t("common:actions.refresh")}
                </Button>
              }
            />
          ) : null}
          {list.data && list.data.items.length > 0 ? (
            <>
              <RequestsTable
                requests={list.data.items}
                showSite={false}
                showOrder={view === "expected" || view === "late"}
                sort={sort}
                onSort={onSort}
                detailHref={(request) => requestDetailPath(BACK_OFFICE_ROUTES.MATERIAL_FOLLOW_UP, request.siteId, request.id, location.search)}
              />
              <Group justify="space-between">
                <Text size="sm" c="dimmed">
                  {t("common:pagination.total", { count: list.data.totalCount })}
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

          <Card withBorder padding="sm" radius="md">
            <Title order={2} size="h5" mb={4}>
              {t("materials:followUp.archive.title")}
            </Title>
            <Text size="sm" mb="xs">
              {t("materials:followUp.archive.intro")}
            </Text>
            <Group gap="sm">
              <Button component={Link} to={`${BACK_OFFICE_ROUTES.MATERIAL_REQUESTS}?siteId=${siteId}&view=received`} variant="default">
                {t("materials:followUp.archive.open")}
              </Button>
              <Button component={Link} to={`${BACK_OFFICE_ROUTES.MATERIAL_REQUESTS}?siteId=${siteId}&view=archived`} variant="default">
                {t("materials:followUp.archive.restore")}
              </Button>
            </Group>
          </Card>
        </>
      )}

      {open ? (
        <RequestDetailDrawerContainer
          siteId={open.siteId}
          requestId={open.requestId}
          onClose={() => void navigate({ pathname: BACK_OFFICE_ROUTES.MATERIAL_FOLLOW_UP, search: location.search })}
        />
      ) : null}
    </Stack>
  );
};
