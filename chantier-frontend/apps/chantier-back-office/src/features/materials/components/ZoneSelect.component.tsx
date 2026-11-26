import { Select } from "@mantine/core";
import { useDebouncedValue } from "@mantine/hooks";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import { useZonesGetQuery, useZonesListQuery, type ZoneResponse } from "@chantier-frontend/api-core";
import { formatZoneLabel } from "@chantier-frontend/i18n";

const SEARCH_DEBOUNCE_MS = 300;
const SUGGESTIONS = 50;

/** Libellé texte d'une zone : « Bloc 01 · +10,20 m ». */
export const useZoneLabelText = () => {
  const { t } = useTranslation(["sites", "common"]);
  return (zone: ZoneResponse): string =>
    formatZoneLabel(zone, { roomTypeName: (type) => t(`sites:roomTypes.${type}`), meter: t("common:units.meter") });
};

export interface ZoneSelectProps {
  siteId: string;
  value: string | null;
  onChange: (zoneId: string | null) => void;
  label: string;
  placeholder: string;
  error?: string;
  disabled?: boolean;
  description?: string;
}

/**
 * Choix d'une zone d'un chantier avec recherche côté serveur (un chantier peut avoir des milliers de zones) ;
 * la zone déjà choisie reste affichée même si elle n'est pas dans les suggestions.
 */
export const ZoneSelect = ({ siteId, value, onChange, label, placeholder, error, disabled, description }: ZoneSelectProps) => {
  const zoneLabel = useZoneLabelText();
  const [search, setSearch] = useState("");
  const [debounced] = useDebouncedValue(search.trim(), SEARCH_DEBOUNCE_MS);
  const hasSite = siteId !== "";

  const { data: suggestions } = useZonesListQuery({ siteId, q: debounced || undefined, pageSize: SUGGESTIONS }, { skip: !hasSite });
  const { data: selected } = useZonesGetQuery({ siteId, zoneId: value ?? "" }, { skip: !hasSite || !value });

  const zones = [...(suggestions?.items ?? [])];
  if (selected && !zones.some((zone) => zone.id === selected.id)) zones.unshift(selected);

  return (
    <Select
      label={label}
      description={description}
      placeholder={placeholder}
      searchable
      clearable
      disabled={disabled || !hasSite}
      data={zones.map((zone) => ({ value: zone.id, label: zoneLabel(zone) }))}
      // La recherche se fait côté serveur : pas de second filtrage local.
      filter={({ options }) => options}
      searchValue={search}
      onSearchChange={setSearch}
      value={value}
      onChange={onChange}
      error={error}
    />
  );
};
