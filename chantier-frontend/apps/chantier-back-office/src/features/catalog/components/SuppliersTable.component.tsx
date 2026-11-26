import { Button, Group, Table, Text } from "@mantine/core";
import { useTranslation } from "react-i18next";

import type { ProductResponse, SupplierResponse } from "@chantier-frontend/api-core";
import { Ltr, pickLocalizedName, useLanguage } from "@chantier-frontend/i18n";

import { ActiveStateBadge } from "./ActiveStateBadge.component";

const VISIBLE_PRODUCTS = 3;

export interface SuppliersTableProps {
  suppliers: readonly SupplierResponse[];
  /** Produits du catalogue connus (noms des produits fournis) ; un produit inconnu est ignoré. */
  products: readonly ProductResponse[];
  /** Colonne téléphone : seulement avec `SupplierPhone.View` (le serveur n'envoie pas le numéro sinon). */
  showPhone: boolean;
  canUpdate: boolean;
  onEdit: (supplier: SupplierResponse) => void;
  onToggle: (supplier: SupplierResponse) => void;
}

/** Fournisseurs : nom, téléphone (selon la permission), produits fournis, état. */
export const SuppliersTable = ({ suppliers, products, showPhone, canUpdate, onEdit, onToggle }: SuppliersTableProps) => {
  const { t } = useTranslation(["catalog", "common"]);
  const { language } = useLanguage();

  const productName = (id: string): string | null => {
    const product = products.find((candidate) => candidate.id === id);
    return product ? pickLocalizedName({ name: product.nameFr, nameAr: product.nameAr }, language) : null;
  };

  return (
    <Table.ScrollContainer minWidth={680}>
      <Table>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>{t("catalog:suppliers.columns.name")}</Table.Th>
            {showPhone ? <Table.Th>{t("catalog:suppliers.columns.phone")}</Table.Th> : null}
            <Table.Th>{t("catalog:suppliers.columns.products")}</Table.Th>
            <Table.Th>{t("catalog:suppliers.columns.state")}</Table.Th>
            {canUpdate ? <Table.Th>{t("catalog:suppliers.columns.actions")}</Table.Th> : null}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {suppliers.map((supplier) => {
            const names = supplier.productIds.map(productName).filter((name): name is string => name !== null);
            return (
              <Table.Tr key={supplier.id}>
                <Table.Td fw={700}>
                  <bdi>{supplier.name}</bdi>
                </Table.Td>
                {showPhone ? <Table.Td>{supplier.phone ? <Ltr>{supplier.phone}</Ltr> : t("catalog:suppliers.noPhone")}</Table.Td> : null}
                <Table.Td>
                  {names.length === 0 ? (
                    t("catalog:suppliers.noProducts")
                  ) : (
                    <Text size="sm">
                      {names.slice(0, VISIBLE_PRODUCTS).join(" · ")}
                      {names.length > VISIBLE_PRODUCTS ? ` ${t("catalog:suppliers.moreProducts", { count: names.length - VISIBLE_PRODUCTS })}` : ""}
                    </Text>
                  )}
                </Table.Td>
                <Table.Td>
                  <ActiveStateBadge isActive={supplier.isActive} />
                </Table.Td>
                {canUpdate ? (
                  <Table.Td>
                    <Group gap="xs" wrap="nowrap">
                      <Button variant="default" size="compact-md" aria-label={t("catalog:suppliers.edit", { name: supplier.name })} onClick={() => onEdit(supplier)}>
                        {t("common:actions.edit")}
                      </Button>
                      <Button
                        variant="default"
                        size="compact-md"
                        aria-label={t(supplier.isActive ? "catalog:suppliers.deactivate" : "catalog:suppliers.activate", { name: supplier.name })}
                        onClick={() => onToggle(supplier)}
                      >
                        {t(supplier.isActive ? "common:actions.deactivate" : "common:actions.activate")}
                      </Button>
                    </Group>
                  </Table.Td>
                ) : null}
              </Table.Tr>
            );
          })}
        </Table.Tbody>
      </Table>
    </Table.ScrollContainer>
  );
};
