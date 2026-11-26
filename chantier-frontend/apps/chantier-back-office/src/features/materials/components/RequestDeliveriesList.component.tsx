import { Anchor, Table, Text, Title } from "@mantine/core";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

import type { RequestDeliveryItem } from "@chantier-frontend/api-core";
import { formatDateOnly, Ltr, QuantityText } from "@chantier-frontend/i18n";

import { EquivalentQuantity } from "./EquivalentQuantity.component";
import { DeliveryStatusBadge } from "./DeliveryBadges.component";

export interface RequestDeliveriesListProps {
  deliveries: readonly RequestDeliveryItem[];
  /** Adresse de la fiche d'une livraison. */
  detailHref: (delivery: RequestDeliveryItem) => string;
}

/**
 * Livraisons d'une demande, annulées comprises (barrées, hors totaux). Chaque quantité garde SON unité de saisie, et son
 * équivalent dans l'unité de la demande quand elle est convertible : jamais deux unités additionnées.
 */
export const RequestDeliveriesList = ({ deliveries, detailHref }: RequestDeliveriesListProps) => {
  const { t } = useTranslation("materials");

  return (
    <>
      <Title order={3} size="h4">
        {t("detail.deliveriesTitle")}
      </Title>
      {deliveries.length === 0 ? (
        <Text c="dimmed">{t("detail.noDeliveries")}</Text>
      ) : (
        <Table.ScrollContainer minWidth={420}>
          <Table aria-label={t("detail.deliveriesTitle")}>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>{t("detail.deliveryColumns.number")}</Table.Th>
                <Table.Th>{t("detail.deliveryColumns.date")}</Table.Th>
                <Table.Th>{t("detail.deliveryColumns.quantity")}</Table.Th>
                <Table.Th>{t("detail.deliveryColumns.note")}</Table.Th>
                <Table.Th>{t("detail.deliveryColumns.status")}</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {deliveries.map((delivery) => {
                const date = formatDateOnly(delivery.deliveryDate);
                const cancelled = delivery.status === "Cancelled";
                const sameUnit = delivery.quantityInRequestUnit?.unit === delivery.quantity.unit;
                return (
                  <Table.Tr key={delivery.id} style={cancelled ? { textDecoration: "line-through" } : undefined}>
                    <Table.Td fw={700}>
                      <Anchor component={Link} to={detailHref(delivery)} aria-label={t("detail.openDelivery", { number: delivery.number })}>
                        <Ltr>{delivery.number}</Ltr>
                      </Anchor>
                    </Table.Td>
                    <Table.Td>{date ? <Ltr>{date}</Ltr> : "—"}</Table.Td>
                    <Table.Td>
                      <QuantityText quantity={delivery.quantity} />
                      {delivery.quantityInRequestUnit && !sameUnit ? (
                        <EquivalentQuantity quantity={delivery.quantityInRequestUnit} />
                      ) : null}
                    </Table.Td>
                    <Table.Td>{delivery.deliveryNoteNumber ? <Ltr>{delivery.deliveryNoteNumber}</Ltr> : "—"}</Table.Td>
                    <Table.Td>
                      <DeliveryStatusBadge status={delivery.status} conformity={delivery.conformity} />
                    </Table.Td>
                  </Table.Tr>
                );
              })}
            </Table.Tbody>
          </Table>
        </Table.ScrollContainer>
      )}
    </>
  );
};
