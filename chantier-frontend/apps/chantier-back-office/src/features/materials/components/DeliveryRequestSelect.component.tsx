import { Select } from "@mantine/core";
import { useDebouncedValue } from "@mantine/hooks";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import { useRequestsGetQuery, useRequestsListQuery, type MaterialRequestResponse } from "@chantier-frontend/api-core";
import { pickLocalizedName, useLanguage, useQuantityFormatter } from "@chantier-frontend/i18n";

const SEARCH_DEBOUNCE_MS = 300;
const SUGGESTIONS = 50;

/** Demandes qui acceptent une livraison rattachée : validée (livraison avant commande), commandée, livrée partiellement. */
export const ATTACHABLE_STATUSES: readonly string[] = ["Validated", "Ordered", "PartiallyDelivered"];

export interface DeliveryRequestSelectProps {
  siteId: string;
  /** Limiter aux demandes d'un produit du catalogue (rattachement : même produit obligatoire, `PRODUIT_DIFFERENT` sinon). */
  productId?: string;
  value: string | null;
  onChange: (request: MaterialRequestResponse | null) => void;
  label: string;
  placeholder: string;
  description?: string;
  error?: string;
  disabled?: boolean;
  required?: boolean;
  clearable?: boolean;
}

/** Choix d'une demande ouverte d'un chantier : numéro, produit et quantité AVEC unité dans le libellé. */
export const DeliveryRequestSelect = ({
  siteId,
  productId,
  value,
  onChange,
  label,
  placeholder,
  description,
  error,
  disabled,
  required = false,
  clearable = true,
}: DeliveryRequestSelectProps) => {
  const { t } = useTranslation("materials");
  const { language } = useLanguage();
  const { quantityText } = useQuantityFormatter();
  const [search, setSearch] = useState("");
  const [debounced] = useDebouncedValue(search.trim(), SEARCH_DEBOUNCE_MS);

  // La vue « à suivre » contient les demandes ouvertes ; on ne garde que celles qui acceptent une livraison.
  const { data } = useRequestsListQuery(
    { siteId, view: "toFollow", q: debounced || undefined, productId: productId || undefined, pageSize: SUGGESTIONS },
    { skip: siteId === "" },
  );
  const { data: selected } = useRequestsGetQuery({ siteId, requestId: value ?? "" }, { skip: !value || siteId === "" });

  const requests: MaterialRequestResponse[] = (data?.items ?? []).filter((request) => ATTACHABLE_STATUSES.includes(request.status));
  if (selected && !requests.some((request) => request.id === selected.id) && selected.id) {
    requests.unshift(selected as MaterialRequestResponse);
  }

  const optionLabel = (request: MaterialRequestResponse): string => {
    const name = request.product.productId
      ? pickLocalizedName({ name: request.product.name ?? "", nameAr: request.product.nameAr ?? null }, language)
      : (request.product.freeName ?? t("list.otherProduct"));
    return `${request.number} · ${name} · ${quantityText(request.quantity)}`;
  };

  return (
    <Select
      label={label}
      description={description}
      placeholder={placeholder}
      nothingFoundMessage={t("deliveries.form.requestNothing")}
      searchable
      clearable={clearable}
      required={required}
      disabled={disabled || siteId === ""}
      data={requests.map((request) => ({ value: request.id, label: optionLabel(request) }))}
      filter={({ options }) => options}
      searchValue={search}
      onSearchChange={setSearch}
      value={value}
      onChange={(id) => onChange(id ? (requests.find((request) => request.id === id) ?? null) : null)}
      error={error}
    />
  );
};
