import { Select } from "@mantine/core";
import { useDebouncedValue } from "@mantine/hooks";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import { useProductsGetQuery, useProductsListQuery, type ProductResponse } from "@chantier-frontend/api-core";
import { pickLocalizedName, useLanguage } from "@chantier-frontend/i18n";

const SEARCH_DEBOUNCE_MS = 300;
const SUGGESTIONS = 50;

export interface ProductSelectProps {
  value: string | null;
  /** Reçoit le produit complet (unités autorisées, masse du sac) : le formulaire en a besoin pour l'unité et l'équivalence. */
  onChange: (product: ProductResponse | null) => void;
  label: string;
  placeholder: string;
  error?: string;
  disabled?: boolean;
  /** Seuls les produits actifs se proposent pour une nouvelle saisie ; un produit désactivé reste affiché s'il est déjà choisi. */
  activeOnly?: boolean;
  /** Champ obligatoire d'un formulaire (défaut) ; faux pour un filtre. */
  required?: boolean;
}

export const ProductSelect = ({ value, onChange, label, placeholder, error, disabled, activeOnly = true, required = true }: ProductSelectProps) => {
  const { t } = useTranslation("materials");
  const { language } = useLanguage();
  const [search, setSearch] = useState("");
  const [debounced] = useDebouncedValue(search.trim(), SEARCH_DEBOUNCE_MS);

  const { data: suggestions } = useProductsListQuery({ q: debounced || undefined, isActive: activeOnly ? true : undefined, pageSize: SUGGESTIONS });
  const { data: selected } = useProductsGetQuery({ productId: value ?? "" }, { skip: !value });

  const products = [...(suggestions?.items ?? [])];
  if (selected && !products.some((product) => product.id === selected.id)) products.unshift(selected);

  return (
    <Select
      label={label}
      placeholder={placeholder}
      nothingFoundMessage={t("form.productNothing")}
      searchable
      clearable
      required={required}
      disabled={disabled}
      data={products.map((product) => ({ value: product.id, label: pickLocalizedName({ name: product.nameFr, nameAr: product.nameAr }, language) }))}
      filter={({ options }) => options}
      searchValue={search}
      onSearchChange={setSearch}
      value={value}
      onChange={(id) => onChange(id ? (products.find((product) => product.id === id) ?? null) : null)}
      error={error}
    />
  );
};

/** Produit d'une demande (catalogue) lu par son identifiant : unités autorisées et masse du sac pour l'équivalence. */
export const useCatalogProduct = (productId: string | null | undefined): ProductResponse | undefined =>
  useProductsGetQuery({ productId: productId ?? "" }, { skip: !productId }).data;
