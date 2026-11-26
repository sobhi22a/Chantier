import { Alert, Group, Stack, Text, Title } from "@mantine/core";
import { IconAlertTriangle } from "@tabler/icons-react";
import type { ReactNode } from "react";
import { useTranslation } from "react-i18next";

import type { OrderResponse } from "@chantier-frontend/api-core";
import { formatAmount, formatDateOnly, Ltr, useQuantityFormatter, type QuantityValue } from "@chantier-frontend/i18n";

const Line = ({ label, children }: { label: string; children: ReactNode }) => (
  <Stack gap={0}>
    <Text size="sm" c="dimmed">
      {label}
    </Text>
    <Text component="div">{children}</Text>
  </Stack>
);

export interface RequestOrderSummaryProps {
  order: OrderResponse;
  /** Unité de la commande (celle de la demande) : le prix unitaire se lit « par sac », jamais sans unité. */
  quantity: QuantityValue;
}

/**
 * Commande d'une demande : fournisseur, dates et, SEULEMENT si le serveur fournit `commercial` (permission `Prices.View`),
 * prix unitaire, montant, valeur reçue et n° de bon de commande. Rien n'est déduit du rôle ni recalculé ici.
 */
export const RequestOrderSummary = ({ order, quantity }: RequestOrderSummaryProps) => {
  const { t } = useTranslation("materials");
  const { unitLabel } = useQuantityFormatter();
  const orderDate = formatDateOnly(order.orderDate);
  const expected = formatDateOnly(order.expectedDeliveryDate);
  const commercial = order.commercial ?? null;

  return (
    <Stack gap="sm" aria-label={t("detail.orderTitle")} role="group">
      <Title order={3} size="h4">
        {t("detail.orderTitle")}
      </Title>
      {order.plannedAfterNeedDays > 0 ? (
        <Alert color="orange" variant="light" icon={<IconAlertTriangle aria-hidden />} role="note">
          {t("order.plannedAfterNeed", { count: order.plannedAfterNeedDays })}
        </Alert>
      ) : null}
      <Group align="flex-start" grow wrap="wrap">
        <Line label={t("order.summary.supplier")}>{order.supplierName ? <bdi>{order.supplierName}</bdi> : "—"}</Line>
        <Line label={t("order.summary.orderDate")}>{orderDate ? <Ltr>{orderDate}</Ltr> : "—"}</Line>
        <Line label={t("order.summary.expectedDate")}>{expected ? <Ltr>{expected}</Ltr> : t("order.summary.notSet")}</Line>
      </Group>
      {commercial ? (
        <Group align="flex-start" grow wrap="wrap">
          <Line label={t("order.summary.unitPrice")}>
            {commercial.unitPrice === null ? (
              t("order.summary.toFill")
            ) : (
              t("order.summary.perUnit", { price: formatAmount(commercial.unitPrice), unit: unitLabel(quantity.unit, 1) })
            )}
          </Line>
          <Line label={t("order.summary.amount")}>{commercial.amount === null ? "—" : <Ltr>{formatAmount(commercial.amount)}</Ltr>}</Line>
          <Line label={t("order.summary.receivedValue")}>
            {commercial.receivedValue === null ? "—" : <Ltr>{formatAmount(commercial.receivedValue)}</Ltr>}
          </Line>
          <Line label={t("order.summary.purchaseOrderNumber")}>
            {commercial.purchaseOrderNumber ? <Ltr>{commercial.purchaseOrderNumber}</Ltr> : "—"}
          </Line>
        </Group>
      ) : null}
      {order.note ? (
        <Line label={t("order.summary.note")}>
          <bdi>{order.note}</bdi>
        </Line>
      ) : null}
    </Stack>
  );
};
