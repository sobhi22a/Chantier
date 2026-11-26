import { Table, Text, Title } from "@mantine/core";
import { useTranslation } from "react-i18next";

import type { ToOrderTotalLine } from "@chantier-frontend/api-core";
import { QuantityText } from "@chantier-frontend/i18n";

export interface ToOrderTotalsProps {
  lines: readonly ToOrderTotalLine[];
}

/**
 * Totaux à commander par produit (CA-MAT-013.2) : le serveur additionne dans la famille d'unités convertibles
 * (400 sacs = 20 T) et sépare les unités non convertibles (24 m³ et 10 T de sable = deux lignes). Le client affiche
 * ces lignes telles quelles : il n'additionne jamais deux quantités.
 */
export const ToOrderTotals = ({ lines }: ToOrderTotalsProps) => {
  const { t } = useTranslation("materials");

  return (
    <section aria-label={t("toOrder.totalsTitle")}>
      <Title order={2} size="h4" mb="xs">
        {t("toOrder.totalsTitle")}
      </Title>
      {lines.length === 0 ? (
        <Text c="dimmed">{t("toOrder.totalsEmpty")}</Text>
      ) : (
        <Table.ScrollContainer minWidth={420}>
          <Table>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>{t("toOrder.totalsColumns.product")}</Table.Th>
                <Table.Th>{t("toOrder.totalsColumns.total")}</Table.Th>
                <Table.Th>{t("toOrder.totalsColumns.equivalent")}</Table.Th>
                <Table.Th>{t("toOrder.totalsColumns.requests")}</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {lines.map((line, index) => (
                // Un même produit peut avoir deux lignes (unités non convertibles) : l'unité fait partie de la clé.
                <Table.Tr key={`${line.productId ?? line.name}-${line.total.unit}-${index}`}>
                  <Table.Td>
                    <bdi>{line.name}</bdi>
                  </Table.Td>
                  <Table.Td fw={700}>
                    <QuantityText quantity={line.total} />
                  </Table.Td>
                  <Table.Td>{line.massEquivalent ? <QuantityText quantity={line.massEquivalent} /> : "—"}</Table.Td>
                  <Table.Td>{t("toOrder.requestCount", { count: line.requestCount })}</Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        </Table.ScrollContainer>
      )}
    </section>
  );
};
