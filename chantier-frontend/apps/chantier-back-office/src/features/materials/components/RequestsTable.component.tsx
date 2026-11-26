import { Anchor, Checkbox, Group, Table, Text, UnstyledButton } from "@mantine/core";
import { IconArrowDown, IconArrowUp, IconSelector } from "@tabler/icons-react";
import type { ReactNode } from "react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

import type { MaterialRequestResponse } from "@chantier-frontend/api-core";
import { formatDateOnly, Ltr, QuantityText, todayDateOnly } from "@chantier-frontend/i18n";

import { OverdueBadge, PriorityBadge, RequestStatusBadge } from "./RequestBadges.component";
import { RequestZoneText, useProductDisplay } from "./RequestDetailView.component";

export type RequestSortColumn = "number" | "neededBy" | "priority";

export interface RequestsTableProps {
  requests: readonly MaterialRequestResponse[];
  /** Adresse de la fiche (tiroir) d'une demande ; conserve les filtres de la liste. */
  detailHref: (request: MaterialRequestResponse) => string;
  showSite: boolean;
  sort: string;
  onSort: (column: RequestSortColumn) => void;
  /** Sélection pour un lot (valider ou archiver) ; absente : pas de case à cocher. */
  selection?: {
    selectedIds: ReadonlySet<string>;
    /** Nombre maximal de demandes d'un lot (50 pour valider, 100 pour archiver). */
    limit: number;
    onToggle: (request: MaterialRequestResponse) => void;
    onTogglePage: (checked: boolean) => void;
  };
  /** Actions d'une ligne (valider, refuser…), rendues dans une dernière colonne. */
  renderActions?: (request: MaterialRequestResponse) => ReactNode;
  actionsLabel?: string;
  /** Colonnes de la commande (fournisseur, livraison prévue) : vues « Attendues » et « En retard » du suivi. */
  showOrder?: boolean;
}

const SortHeader = ({ column, sort, onSort, label }: { column: RequestSortColumn; sort: string; onSort: (column: RequestSortColumn) => void; label: string }) => {
  const { t } = useTranslation("materials");
  const direction = sort === column ? "ascending" : sort === `-${column}` ? "descending" : "none";
  const icon = direction === "ascending" ? <IconArrowUp size={14} aria-hidden /> : direction === "descending" ? <IconArrowDown size={14} aria-hidden /> : <IconSelector size={14} aria-hidden />;
  return (
    <Table.Th aria-sort={direction}>
      <UnstyledButton onClick={() => onSort(column)} aria-label={t("list.sortBy", { column: label })} mih={24}>
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

/** Tableau des demandes : numéro, chantier, produit, quantité AVEC unité, zone, pour le, urgence et statut (icône et texte), retard. */
export const RequestsTable = ({ requests, detailHref, showSite, sort, onSort, selection, renderActions, actionsLabel, showOrder = false }: RequestsTableProps) => {
  const { t } = useTranslation("materials");
  const productDisplay = useProductDisplay();
  const allChecked = selection !== undefined && requests.length > 0 && requests.every((request) => selection.selectedIds.has(request.id));
  const someChecked = selection !== undefined && requests.some((request) => selection.selectedIds.has(request.id));
  const limitReached = selection !== undefined && selection.selectedIds.size >= selection.limit;

  return (
    <Table.ScrollContainer minWidth={900}>
      <Table>
        <Table.Thead>
          <Table.Tr>
            {selection ? (
              <Table.Th w={44}>
                <Checkbox
                  aria-label={t("list.selectAll")}
                  checked={allChecked}
                  indeterminate={someChecked && !allChecked}
                  onChange={(event) => selection.onTogglePage(event.currentTarget.checked)}
                />
              </Table.Th>
            ) : null}
            <SortHeader column="number" sort={sort} onSort={onSort} label={t("list.columns.number")} />
            {showSite ? <Table.Th>{t("list.columns.site")}</Table.Th> : null}
            <Table.Th>{t("list.columns.product")}</Table.Th>
            <Table.Th>{t("list.columns.quantity")}</Table.Th>
            <Table.Th>{t("list.columns.zone")}</Table.Th>
            <SortHeader column="neededBy" sort={sort} onSort={onSort} label={t("list.columns.neededBy")} />
            <SortHeader column="priority" sort={sort} onSort={onSort} label={t("list.columns.priority")} />
            <Table.Th>{t("list.columns.status")}</Table.Th>
            {showOrder ? <Table.Th>{t("list.columns.supplier")}</Table.Th> : null}
            {showOrder ? <Table.Th>{t("list.columns.expected")}</Table.Th> : null}
            {renderActions ? <Table.Th>{actionsLabel}</Table.Th> : null}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {requests.map((request) => {
            const product = productDisplay(request.product);
            const neededBy = formatDateOnly(request.neededBy);
            const checked = selection?.selectedIds.has(request.id) ?? false;
            return (
              <Table.Tr key={request.id} bg={checked ? "var(--mantine-color-primary-0)" : undefined}>
                {selection ? (
                  <Table.Td>
                    <Checkbox
                      aria-label={t("list.selectRow", { number: request.number })}
                      checked={checked}
                      // Au-delà de la limite d'un lot, seules les cases déjà cochées restent actives (pour pouvoir les décocher).
                      disabled={!checked && limitReached}
                      onChange={() => selection.onToggle(request)}
                    />
                  </Table.Td>
                ) : null}
                <Table.Td fw={700}>
                  <Anchor component={Link} to={detailHref(request)} aria-label={t("actions.openDetail", { number: request.number })}>
                    <Ltr>{request.number}</Ltr>
                  </Anchor>
                </Table.Td>
                {showSite ? <Table.Td>{request.siteCode ? <Ltr>{request.siteCode}</Ltr> : null}</Table.Td> : null}
                <Table.Td>
                  <bdi>{product.name}</bdi>
                  {product.isFree ? (
                    <Text size="xs" c="dimmed">
                      {t("list.otherProduct")}
                    </Text>
                  ) : null}
                </Table.Td>
                <Table.Td>
                  <QuantityText quantity={request.quantity} />
                </Table.Td>
                <Table.Td>
                  <RequestZoneText siteId={request.siteId} zoneId={request.zoneId} />
                </Table.Td>
                <Table.Td>
                  {neededBy ? <Ltr>{neededBy}</Ltr> : "—"}
                  <OverdueBadge days={request.overdueDays} />
                </Table.Td>
                <Table.Td>
                  <PriorityBadge priority={request.priority} />
                </Table.Td>
                <Table.Td>
                  <RequestStatusBadge status={request.status} />
                </Table.Td>
                {showOrder ? <Table.Td>{request.order?.supplierName ? <bdi>{request.order.supplierName}</bdi> : "—"}</Table.Td> : null}
                {showOrder ? (
                  <Table.Td>
                    {request.order?.expectedDeliveryDate ? <Ltr>{formatDateOnly(request.order.expectedDeliveryDate) ?? "—"}</Ltr> : "—"}
                    {request.order?.expectedDeliveryDate && request.order.expectedDeliveryDate < todayDateOnly() ? (
                      <Text size="xs" c="orange.9" fw={600}>
                        {t("followUp.lateOrder")}
                      </Text>
                    ) : null}
                  </Table.Td>
                ) : null}
                {renderActions ? <Table.Td>{renderActions(request)}</Table.Td> : null}
              </Table.Tr>
            );
          })}
        </Table.Tbody>
      </Table>
    </Table.ScrollContainer>
  );
};
