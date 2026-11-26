import { Anchor, Group, Table, Text, UnstyledButton } from "@mantine/core";
import { IconArrowDown, IconArrowUp, IconSelector } from "@tabler/icons-react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

import type { DeliveryResponse } from "@chantier-frontend/api-core";
import { formatAmount, formatDateOnly, Ltr, QuantityText } from "@chantier-frontend/i18n";

import { isCancelled } from "../types/deliveryTypes";
import { DeliveryStatusBadge, MissingNoteBadge, UnattachedBadge } from "./DeliveryBadges.component";
import { EquivalentQuantity } from "./EquivalentQuantity.component";
import { useProductDisplay } from "./RequestDetailView.component";

export type DeliverySortColumn = "number" | "deliveryDate";

export interface DeliveriesTableProps {
  deliveries: readonly DeliveryResponse[];
  /** Adresse de la fiche (tiroir) d'une livraison ; conserve les filtres de la liste. */
  detailHref: (delivery: DeliveryResponse) => string;
  sort: string;
  onSort: (column: DeliverySortColumn) => void;
}

const SortHeader = ({ column, sort, onSort, label }: { column: DeliverySortColumn; sort: string; onSort: (column: DeliverySortColumn) => void; label: string }) => {
  const { t } = useTranslation("materials");
  const direction = sort === column ? "ascending" : sort === `-${column}` ? "descending" : "none";
  const icon = direction === "ascending" ? <IconArrowUp size={14} aria-hidden /> : direction === "descending" ? <IconArrowDown size={14} aria-hidden /> : <IconSelector size={14} aria-hidden />;
  return (
    <Table.Th aria-sort={direction}>
      <UnstyledButton onClick={() => onSort(column)} aria-label={t("deliveries.sortBy", { column: label })} mih={24}>
        <Group gap={4} wrap="nowrap">
          <Text fw={700} size="sm">
            {label}
          </Text>
          {icon}
        </Group>
      </UnstyledButton>
    </Table.Th>
  );
};

/**
 * Tableau des livraisons : numéro, date, produit, fournisseur, quantité reçue AVEC son unité (et son équivalent dans l'unité de
 * la demande, jamais additionné), n° de BL ou badge « BL manquant », demande ou badge « Non rattachée », état. La colonne
 * « Valeur » n'existe que si le serveur a fourni `commercial` (permission `Prices.View`) : rien n'est déduit du rôle.
 */
export const DeliveriesTable = ({ deliveries, detailHref, sort, onSort }: DeliveriesTableProps) => {
  const { t } = useTranslation("materials");
  const productDisplay = useProductDisplay();
  const showAmount = deliveries.some((delivery) => delivery.commercial !== null && delivery.commercial !== undefined);

  return (
    <Table.ScrollContainer minWidth={980}>
      <Table>
        <Table.Thead>
          <Table.Tr>
            <SortHeader column="number" sort={sort} onSort={onSort} label={t("deliveries.columns.number")} />
            <SortHeader column="deliveryDate" sort={sort} onSort={onSort} label={t("deliveries.columns.date")} />
            <Table.Th>{t("deliveries.columns.product")}</Table.Th>
            <Table.Th>{t("deliveries.columns.supplier")}</Table.Th>
            <Table.Th>{t("deliveries.columns.quantity")}</Table.Th>
            <Table.Th>{t("deliveries.columns.note")}</Table.Th>
            <Table.Th>{t("deliveries.columns.request")}</Table.Th>
            <Table.Th>{t("deliveries.columns.status")}</Table.Th>
            {showAmount ? <Table.Th>{t("deliveries.columns.amount")}</Table.Th> : null}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {deliveries.map((delivery) => {
            const product = productDisplay(delivery.product);
            const date = formatDateOnly(delivery.deliveryDate);
            const cancelled = isCancelled(delivery);
            const inRequestUnit = delivery.quantityInRequestUnit;
            const converted = inRequestUnit && inRequestUnit.unit !== delivery.quantity.unit ? inRequestUnit : null;
            return (
              <Table.Tr key={delivery.id} style={cancelled ? { textDecoration: "line-through" } : undefined}>
                <Table.Td fw={700}>
                  <Anchor component={Link} to={detailHref(delivery)} aria-label={t("deliveries.openDetail", { number: delivery.number })}>
                    <Ltr>{delivery.number}</Ltr>
                  </Anchor>
                </Table.Td>
                <Table.Td>{date ? <Ltr>{date}</Ltr> : "—"}</Table.Td>
                <Table.Td>
                  <bdi>{product.name}</bdi>
                  {product.isFree ? (
                    <Text size="xs" c="dimmed">
                      {t("list.otherProduct")}
                    </Text>
                  ) : null}
                </Table.Td>
                <Table.Td>
                  {delivery.supplierName ? <bdi>{delivery.supplierName}</bdi> : delivery.freeSupplierName ? <bdi>{delivery.freeSupplierName}</bdi> : "—"}
                  {!delivery.supplierName && delivery.freeSupplierName ? (
                    <Text size="xs" c="dimmed">
                      {t("deliveries.freeSupplier")}
                    </Text>
                  ) : null}
                </Table.Td>
                <Table.Td>
                  <QuantityText quantity={delivery.quantity} />
                  {converted ? (
                    <EquivalentQuantity quantity={converted} />
                  ) : null}
                </Table.Td>
                <Table.Td>{delivery.deliveryNoteNumber ? <Ltr>{delivery.deliveryNoteNumber}</Ltr> : delivery.missingNote ? <MissingNoteBadge /> : "—"}</Table.Td>
                <Table.Td>{delivery.requestNumber ? <Ltr>{delivery.requestNumber}</Ltr> : <UnattachedBadge />}</Table.Td>
                <Table.Td>
                  <DeliveryStatusBadge status={delivery.status} conformity={delivery.conformity} />
                </Table.Td>
                {showAmount ? <Table.Td>{delivery.commercial ? <Ltr>{formatAmount(delivery.commercial.amount)}</Ltr> : "—"}</Table.Td> : null}
              </Table.Tr>
            );
          })}
        </Table.Tbody>
      </Table>
    </Table.ScrollContainer>
  );
};
