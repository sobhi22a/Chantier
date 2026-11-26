import { Select } from "@mantine/core";
import { useDebouncedValue } from "@mantine/hooks";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import { useSuppliersGetQuery, useSuppliersListQuery, type SupplierResponse } from "@chantier-frontend/api-core";

const SEARCH_DEBOUNCE_MS = 300;
const SUGGESTIONS = 50;

export interface SupplierSelectProps {
  value: string | null;
  onChange: (supplier: SupplierResponse | null) => void;
  label: string;
  placeholder: string;
  error?: string;
  disabled?: boolean;
  required?: boolean;
  clearable?: boolean;
}

/**
 * Fournisseur du catalogue : seuls les fournisseurs actifs se proposent pour une nouvelle saisie ; un fournisseur désactivé
 * déjà choisi (commande existante) reste affiché. Le téléphone n'est jamais lu ici.
 */
export const SupplierSelect = ({ value, onChange, label, placeholder, error, disabled, required = true, clearable = false }: SupplierSelectProps) => {
  const { t } = useTranslation("materials");
  const [search, setSearch] = useState("");
  const [debounced] = useDebouncedValue(search.trim(), SEARCH_DEBOUNCE_MS);

  const { data: suggestions } = useSuppliersListQuery({ q: debounced || undefined, isActive: true, pageSize: SUGGESTIONS });
  const { data: selected } = useSuppliersGetQuery({ supplierId: value ?? "" }, { skip: !value });

  const suppliers = [...(suggestions?.items ?? [])];
  if (selected && !suppliers.some((supplier) => supplier.id === selected.id)) suppliers.unshift(selected);

  return (
    <Select
      label={label}
      placeholder={placeholder}
      nothingFoundMessage={t("order.supplierNothing")}
      searchable
      clearable={clearable}
      required={required}
      disabled={disabled}
      data={suppliers.map((supplier) => ({ value: supplier.id, label: supplier.name }))}
      filter={({ options }) => options}
      searchValue={search}
      onSearchChange={setSearch}
      value={value}
      onChange={(id) => onChange(id ? (suppliers.find((supplier) => supplier.id === id) ?? null) : null)}
      error={error}
    />
  );
};
