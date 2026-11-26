import { Button, Group, Table } from "@mantine/core";
import { useTranslation } from "react-i18next";

import type { ProductResponse } from "@chantier-frontend/api-core";
import { QuantityText, pickLocalizedName, useLanguage, useQuantityFormatter } from "@chantier-frontend/i18n";

import { ActiveStateBadge } from "./ActiveStateBadge.component";

export interface ProductsTableProps {
  products: readonly ProductResponse[];
  canUpdate: boolean;
  onEdit: (product: ProductResponse) => void;
  onToggle: (product: ProductResponse) => void;
}

/** Catalogue : produit dans la langue, catégorie, unités autorisées, unité par défaut, masse du sac (avec son unité), état. */
export const ProductsTable = ({ products, canUpdate, onEdit, onToggle }: ProductsTableProps) => {
  const { t } = useTranslation(["catalog", "common"]);
  const { language } = useLanguage();
  const { unitLabel } = useQuantityFormatter();

  return (
    <Table.ScrollContainer minWidth={760}>
      <Table>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>{t("catalog:products.columns.name")}</Table.Th>
            <Table.Th>{t("catalog:products.columns.category")}</Table.Th>
            <Table.Th>{t("catalog:products.columns.units")}</Table.Th>
            <Table.Th>{t("catalog:products.columns.defaultUnit")}</Table.Th>
            <Table.Th>{t("catalog:products.columns.bagMass")}</Table.Th>
            <Table.Th>{t("catalog:products.columns.state")}</Table.Th>
            {canUpdate ? <Table.Th>{t("catalog:products.columns.actions")}</Table.Th> : null}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {products.map((product) => {
            const name = pickLocalizedName({ name: product.nameFr, nameAr: product.nameAr }, language);
            return (
              <Table.Tr key={product.id}>
                <Table.Td fw={700}>
                  <bdi>{name}</bdi>
                </Table.Td>
                <Table.Td>{t(`catalog:categories.${product.category}`)}</Table.Td>
                <Table.Td>{product.allowedUnits.map((unit) => unitLabel(unit, 2)).join(" · ")}</Table.Td>
                <Table.Td>{unitLabel(product.defaultUnit, 2)}</Table.Td>
                <Table.Td>
                  {product.bagMassKg === null ? (
                    t("catalog:products.noBag")
                  ) : (
                    <QuantityText quantity={{ value: product.bagMassKg, unit: "kg" }} />
                  )}
                </Table.Td>
                <Table.Td>
                  <ActiveStateBadge isActive={product.isActive} />
                </Table.Td>
                {canUpdate ? (
                  <Table.Td>
                    <Group gap="xs" wrap="nowrap">
                      <Button variant="default" size="compact-md" aria-label={t("catalog:products.edit", { name })} onClick={() => onEdit(product)}>
                        {t("common:actions.edit")}
                      </Button>
                      <Button
                        variant="default"
                        size="compact-md"
                        aria-label={t(product.isActive ? "catalog:products.deactivate" : "catalog:products.activate", { name })}
                        onClick={() => onToggle(product)}
                      >
                        {t(product.isActive ? "common:actions.deactivate" : "common:actions.activate")}
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
