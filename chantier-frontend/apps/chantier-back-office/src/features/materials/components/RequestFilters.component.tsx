import { Button, Checkbox, Group, Select, TextInput } from "@mantine/core";
import { DatePickerInput } from "@mantine/dates";
import { useDebouncedCallback } from "@mantine/hooks";
import { IconFilterOff, IconSearch } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import { useSitesListQuery } from "@chantier-frontend/api-core";
import { pickLocalizedName, useLanguage } from "@chantier-frontend/i18n";

import type { RequestFilterState } from "../containers/useRequestFilters";
import { REQUEST_PRIORITIES } from "../types/requestTypes";
import { ProductSelect } from "./ProductSelect.component";
import { ZoneSelect } from "./ZoneSelect.component";

const SEARCH_DEBOUNCE_MS = 300;
const SITES_PAGE_SIZE = 200;

export interface RequestFiltersProps {
  state: RequestFilterState;
  update: (changes: Record<string, string | null>) => void;
  hasFilters: boolean;
  /** Case « Mes demandes » (liste des demandes seulement). */
  showMine?: boolean;
}

/** Filtres communs des listes de demandes : recherche, chantier, urgence, produit, zone, période. Tout est dans l'URL. */
export const RequestFilters = ({ state, update, hasFilters, showMine = false }: RequestFiltersProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { language } = useLanguage();
  const { data: sites } = useSitesListQuery({ pageSize: SITES_PAGE_SIZE });
  // La saisie est locale (réactive) ; l'URL, et donc la requête, suit avec un léger délai.
  const [searchText, setSearchText] = useState(state.q);
  const updateSearch = useDebouncedCallback((value: string) => update({ q: value.trim() }), SEARCH_DEBOUNCE_MS);

  return (
    <Group align="flex-end" wrap="wrap" role="search">
      <TextInput
        label={t("materials:list.searchLabel")}
        placeholder={t("materials:list.searchPlaceholder")}
        leftSection={<IconSearch size={16} aria-hidden />}
        value={searchText}
        onChange={(event) => {
          setSearchText(event.currentTarget.value);
          updateSearch(event.currentTarget.value);
        }}
      />
      <Select
        label={t("materials:list.siteFilter")}
        placeholder={t("materials:list.allSites")}
        clearable
        searchable
        data={(sites?.items ?? []).map((site) => ({ value: site.id, label: `${site.code} · ${pickLocalizedName(site, language)}` }))}
        value={state.siteId === "" ? null : state.siteId}
        // La zone appartient à un chantier : changer de chantier retire le filtre de zone.
        onChange={(value) => update({ siteId: value, zoneId: null })}
      />
      <Select
        label={t("materials:list.priorityFilter")}
        placeholder={t("materials:list.allPriorities")}
        clearable
        data={REQUEST_PRIORITIES.map((priority) => ({ value: priority, label: t(`materials:priority.${priority}`) }))}
        value={state.priority ?? null}
        onChange={(value) => update({ priority: value })}
      />
      <ProductSelect
        label={t("materials:list.productFilter")}
        placeholder={t("materials:list.productFilterPlaceholder")}
        required={false}
        activeOnly={false}
        value={state.productId === "" ? null : state.productId}
        onChange={(product) => update({ productId: product?.id ?? null })}
      />
      <ZoneSelect
        siteId={state.siteId}
        label={t("materials:list.zoneFilter")}
        placeholder={state.siteId === "" ? t("materials:list.zoneFilterNeedsSite") : t("materials:list.zoneFilterPlaceholder")}
        value={state.zoneId === "" ? null : state.zoneId}
        onChange={(value) => update({ zoneId: value })}
      />
      <DatePickerInput
        label={t("materials:list.from")}
        valueFormat="DD/MM/YYYY"
        clearable
        value={state.from}
        onChange={(value) => update({ from: value })}
      />
      <DatePickerInput
        label={t("materials:list.to")}
        valueFormat="DD/MM/YYYY"
        clearable
        value={state.to}
        onChange={(value) => update({ to: value })}
      />
      {showMine ? (
        <Checkbox
          label={t("materials:list.mine")}
          checked={state.mine}
          onChange={(event) => update({ mine: event.currentTarget.checked ? "1" : "0" })}
          mb={6}
        />
      ) : null}
      {hasFilters ? (
        <Button
          variant="default"
          leftSection={<IconFilterOff size={16} aria-hidden />}
          onClick={() => {
            setSearchText("");
            update({ q: null, siteId: null, priority: null, productId: null, zoneId: null, from: null, to: null, mine: null });
          }}
        >
          {t("materials:list.resetFilters")}
        </Button>
      ) : null}
    </Group>
  );
};
