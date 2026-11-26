import { Button, Group, Select, TextInput } from "@mantine/core";
import { DatePickerInput } from "@mantine/dates";
import { useDebouncedCallback } from "@mantine/hooks";
import { IconFilterOff, IconSearch } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import type { SiteResponse } from "@chantier-frontend/api-core";
import { pickLocalizedName, useLanguage } from "@chantier-frontend/i18n";

import type { DeliveryFilterState } from "../containers/useDeliveryFilters";
import { DELIVERY_STATUSES } from "../types/deliveryTypes";

const SEARCH_DEBOUNCE_MS = 300;

export interface DeliveryFiltersProps {
  state: DeliveryFilterState;
  update: (changes: Record<string, string | null>) => void;
  hasFilters: boolean;
  sites: readonly SiteResponse[];
}

/** Filtres de la liste des livraisons : chantier (obligatoire, la route est celle d'un chantier), recherche, état, période. Tout est dans l'URL. */
export const DeliveryFilters = ({ state, update, hasFilters, sites }: DeliveryFiltersProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { language } = useLanguage();
  // La saisie est locale (réactive) ; l'URL, et donc la requête, suit avec un léger délai.
  const [searchText, setSearchText] = useState(state.q);
  const updateSearch = useDebouncedCallback((value: string) => update({ q: value.trim() }), SEARCH_DEBOUNCE_MS);

  return (
    <Group align="flex-end" wrap="wrap" role="search">
      <Select
        label={t("materials:deliveries.filters.site")}
        placeholder={t("materials:deliveries.filters.sitePlaceholder")}
        searchable
        allowDeselect={false}
        data={sites.map((site) => ({ value: site.id, label: `${site.code} · ${pickLocalizedName(site, language)}` }))}
        value={state.siteId === "" ? null : state.siteId}
        onChange={(value) => update({ siteId: value, tab: null, q: null, status: null, from: null, to: null })}
      />
      <TextInput
        label={t("materials:deliveries.filters.search")}
        placeholder={t("materials:deliveries.filters.searchPlaceholder")}
        leftSection={<IconSearch size={16} aria-hidden />}
        value={searchText}
        onChange={(event) => {
          setSearchText(event.currentTarget.value);
          updateSearch(event.currentTarget.value);
        }}
      />
      <Select
        label={t("materials:deliveries.filters.status")}
        placeholder={t("materials:deliveries.filters.allStatuses")}
        clearable
        data={DELIVERY_STATUSES.map((status) => ({ value: status, label: t(`materials:deliveries.status.${status}`) }))}
        value={state.status ?? null}
        onChange={(value) => update({ status: value })}
      />
      <DatePickerInput label={t("materials:deliveries.filters.from")} valueFormat="DD/MM/YYYY" clearable value={state.from} onChange={(value) => update({ from: value })} />
      <DatePickerInput label={t("materials:deliveries.filters.to")} valueFormat="DD/MM/YYYY" clearable value={state.to} onChange={(value) => update({ to: value })} />
      {hasFilters ? (
        <Button
          variant="default"
          leftSection={<IconFilterOff size={16} aria-hidden />}
          onClick={() => {
            setSearchText("");
            update({ q: null, status: null, from: null, to: null });
          }}
        >
          {t("materials:deliveries.filters.reset")}
        </Button>
      ) : null}
    </Group>
  );
};
