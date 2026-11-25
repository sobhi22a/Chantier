import { Button, Checkbox, Group, Pagination, Select, Stack, Text, TextInput } from "@mantine/core";
import { useDebouncedCallback } from "@mantine/hooks";
import { IconPlus, IconSearch } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate, useSearchParams } from "react-router-dom";

import { useApiErrorMessage, useSitesListQuery, type SiteType } from "@chantier-frontend/api-core";
import { PERMISSIONS_RESOURCES, usePermissions } from "@chantier-frontend/authentication";
import { GenericEmptyComponent, GenericErrorComponent, GenericLoaderComponent } from "@chantier-frontend/user-interface";

import { siteDetailPath } from "../../../app/providers/router/navigationRoutes";
import { SitesTable } from "../components/SitesTable.component";
import { SITE_TYPES } from "../types/siteForm.zod";
import { SiteFormModalContainer } from "./SiteFormModal.container";

export const SITES_PAGE_SIZE = 20;
const SEARCH_DEBOUNCE_MS = 300;

const isSiteType = (value: string | null): value is SiteType => SITE_TYPES.some((type) => type === value);

/**
 * « Mes chantiers » : filtres et page dans l'URL (lien partageable), pagination et recherche côté serveur.
 * Le serveur ne renvoie que les chantiers affectés ; un autre n'apparaît jamais, même dans la recherche (CT-3).
 */
export const SitesBrowserContainer = () => {
  const { t } = useTranslation(["sites", "common"]);
  const navigate = useNavigate();
  const { can } = usePermissions();
  const { describe } = useApiErrorMessage();
  const [params, setParams] = useSearchParams();
  const [creating, setCreating] = useState(false);

  const q = params.get("q") ?? "";
  const typeParam = params.get("type");
  const type = isSiteType(typeParam) ? typeParam : undefined;
  const includeArchived = params.get("archived") === "1";
  const page = Math.max(1, Number(params.get("page")) || 1);

  // La saisie est locale (réactive) ; l'URL, et donc la requête, suit avec un léger délai.
  const [searchText, setSearchText] = useState(q);

  const updateParams = (changes: Record<string, string | null>) =>
    setParams(
      (previous) => {
        const next = new URLSearchParams(previous);
        for (const [key, value] of Object.entries(changes)) {
          if (value === null || value === "") next.delete(key);
          else next.set(key, value);
        }
        // Tout changement de filtre revient à la première page.
        if (!("page" in changes)) next.delete("page");
        return next;
      },
      { replace: true },
    );
  const updateSearch = useDebouncedCallback((value: string) => updateParams({ q: value.trim() }), SEARCH_DEBOUNCE_MS);

  const { data, isLoading, isError, error, refetch } = useSitesListQuery({
    q: q || undefined,
    type,
    includeArchived: includeArchived || undefined,
    page,
    pageSize: SITES_PAGE_SIZE,
  });

  const hasFilters = q !== "" || type !== undefined || includeArchived;
  const totalPages = data ? Math.max(1, Math.ceil(data.totalCount / data.pageSize)) : 1;

  return (
    <Stack gap="md">
      <Group justify="space-between" align="flex-end" wrap="wrap">
        <Group align="flex-end" wrap="wrap">
          <TextInput
            label={t("sites:list.searchLabel")}
            placeholder={t("sites:list.searchPlaceholder")}
            leftSection={<IconSearch size={16} aria-hidden />}
            value={searchText}
            onChange={(event) => {
              setSearchText(event.currentTarget.value);
              updateSearch(event.currentTarget.value);
            }}
          />
          <Select
            label={t("sites:list.typeFilter")}
            placeholder={t("sites:list.typeFilterAll")}
            clearable
            data={SITE_TYPES.map((value) => ({ value, label: t(`sites:types.${value}`) }))}
            value={type ?? null}
            onChange={(value) => updateParams({ type: value })}
          />
          <Checkbox
            label={t("sites:list.showArchived")}
            checked={includeArchived}
            onChange={(event) => updateParams({ archived: event.currentTarget.checked ? "1" : null })}
            mb={6}
          />
        </Group>
        {can(PERMISSIONS_RESOURCES.SITES, "Create") ? (
          <Button leftSection={<IconPlus size={18} aria-hidden />} onClick={() => setCreating(true)}>
            {t("sites:list.create")}
          </Button>
        ) : null}
      </Group>

      {isLoading ? <GenericLoaderComponent /> : null}

      {isError ? <GenericErrorComponent {...describe(error)} onRetry={() => void refetch()} /> : null}

      {data && data.items.length === 0 ? (
        <GenericEmptyComponent
          message={hasFilters ? t("sites:list.noResults") : t("sites:list.empty")}
          action={
            hasFilters ? undefined : (
              <Button variant="default" onClick={() => void refetch()}>
                {t("common:actions.refresh")}
              </Button>
            )
          }
        />
      ) : null}

      {data && data.items.length > 0 ? (
        <>
          <SitesTable sites={data.items} />
          <Group justify="space-between">
            <Text size="sm" c="dimmed">
              {t("common:pagination.total", { count: data.totalCount })}
            </Text>
            {totalPages > 1 ? (
              <Pagination
                total={totalPages}
                value={page}
                onChange={(value) => updateParams({ page: value > 1 ? String(value) : null })}
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
        <SiteFormModalContainer
          onClose={() => setCreating(false)}
          onSaved={(site) => {
            setCreating(false);
            void navigate(siteDetailPath(site.id));
          }}
        />
      ) : null}
    </Stack>
  );
};
