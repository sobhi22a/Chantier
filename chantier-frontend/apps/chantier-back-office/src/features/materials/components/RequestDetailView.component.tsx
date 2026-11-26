import { Alert, Divider, Group, Stack, Text, Title } from "@mantine/core";
import { IconAlertTriangle, IconArchive, IconCircleCheck, IconTruckDelivery } from "@tabler/icons-react";
import type { ReactNode } from "react";
import { useTranslation } from "react-i18next";

import { useZoneDirectoryQuery, useZonesGetQuery } from "@chantier-frontend/api-core";
import { formatDateOnly, formatDateTime, formatPercent, Ltr, pickLocalizedName, QuantityText, useLanguage } from "@chantier-frontend/i18n";

import type { RequestDetail } from "../types/requestTypes";
import { OverdueBadge, PriorityBadge, RequestStatusBadge } from "./RequestBadges.component";
import { RequestDeliveriesList } from "./RequestDeliveriesList.component";
import { RequestOrderSummary } from "./RequestOrderSummary.component";
import { RequestHistory } from "./RequestHistory.component";
import { useZoneLabelText } from "./ZoneSelect.component";

const Field = ({ label, children }: { label: string; children: ReactNode }) => (
  <Stack gap={0}>
    <Text size="sm" c="dimmed">
      {label}
    </Text>
    <Text component="div">{children}</Text>
  </Stack>
);

/**
 * Zone d'une demande : lue dans l'annuaire du chantier (une lecture groupée partagée par toutes les lignes, revue R2-06), et
 * seulement si elle en est absente (chantier de plus de 1 000 zones) par son identifiant (cache RTK). « Non précisée » sans zone.
 */
export const RequestZoneText = ({ siteId, zoneId }: { siteId: string; zoneId: string | null | undefined }) => {
  const { t } = useTranslation("materials");
  const zoneLabel = useZoneLabelText();
  const directory = useZoneDirectoryQuery({ siteId }, { skip: !zoneId });
  const fromDirectory = zoneId ? directory.data?.[zoneId] : undefined;
  // Lecture individuelle : seulement quand l'annuaire est arrivé sans cette zone (ou en erreur).
  const needsFallback = Boolean(zoneId) && fromDirectory === undefined && !directory.isLoading && !directory.isUninitialized;
  const { data: single } = useZonesGetQuery({ siteId, zoneId: zoneId ?? "" }, { skip: !needsFallback });
  const zone = fromDirectory ?? single;
  if (!zoneId) return <>{t("list.noZone")}</>;
  return <bdi>{zone ? zoneLabel(zone) : "…"}</bdi>;
};

/** Nom du produit : catalogue dans la langue courante, ou nom libre marqué « Hors catalogue ». */
export const useProductDisplay = () => {
  const { t } = useTranslation("materials");
  const { language } = useLanguage();
  return (product: RequestDetail["product"]): { name: string; isFree: boolean } => {
    if (product.productId !== null && product.name) {
      return { name: pickLocalizedName({ name: product.name, nameAr: product.nameAr }, language), isFree: false };
    }
    return { name: product.freeName ?? t("list.otherProduct"), isFree: true };
  };
};

/** Contenu du tiroir de détail : champs, reste et écart avec unité, doublon, historique. Les actions sont dans le conteneur. */
export interface RequestDetailViewProps {
  request: RequestDetail;
  /** Adresse de la fiche d'une livraison (tiroir de la liste des livraisons). */
  deliveryHref: (siteId: string, deliveryId: string) => string;
}

export const RequestDetailView = ({ request, deliveryHref }: RequestDetailViewProps) => {
  const { t } = useTranslation("materials");
  const productDisplay = useProductDisplay();
  const product = productDisplay(request.product);
  const neededBy = formatDateOnly(request.neededBy);
  const created = formatDateTime(request.createdAt);
  const updated = formatDateTime(request.updatedAt);
  const archived = formatDateTime(request.archivedAt);
  const reasonCode = request.statusReason?.code;

  return (
    <Stack gap="md">
      <Group gap="xs">
        <RequestStatusBadge status={request.status} />
        <PriorityBadge priority={request.priority} />
        <OverdueBadge days={request.overdueDays} />
      </Group>

      {request.archivedAt ? (
        <Alert color="gray" variant="light" icon={<IconArchive aria-hidden />} role="note">
          {t("detail.archivedBanner", { name: request.archivedByName ?? "—", date: archived ?? "" })}
        </Alert>
      ) : null}
      {request.possibleDuplicateOf ? (
        <Alert color="orange" variant="light" icon={<IconAlertTriangle aria-hidden />} role="note">
          {t("detail.duplicate", { number: request.possibleDuplicateOf.number })}
        </Alert>
      ) : null}
      {request.hasDeliveryWithoutOrder ? (
        <Alert color="orange" variant="light" icon={<IconTruckDelivery aria-hidden />} role="note">
          {t("detail.withoutOrder")}
        </Alert>
      ) : null}
      {request.isSettled ? (
        <Alert color="green" variant="light" icon={<IconCircleCheck aria-hidden />} role="note">
          {t("detail.settled")}
        </Alert>
      ) : null}

      <Group align="flex-start" grow wrap="wrap">
        <Field label={t("detail.fields.site")}>{request.siteCode ? <Ltr>{request.siteCode}</Ltr> : "—"}</Field>
        <Field label={t("detail.fields.neededBy")}>{neededBy ? <Ltr>{neededBy}</Ltr> : "—"}</Field>
      </Group>
      <Field label={t("detail.fields.product")}>
        <bdi>{product.name}</bdi>
        {product.isFree ? ` (${t("detail.freeProduct")})` : ""}
      </Field>
      <Field label={t("detail.fields.quantity")}>
        <QuantityText quantity={request.quantity} />
      </Field>
      <Field label={t("detail.fields.zone")}>
        <RequestZoneText siteId={request.siteId} zoneId={request.zoneId} />
      </Field>
      <Field label={t("detail.fields.note")}>{request.note ? <bdi>{request.note}</bdi> : t("detail.noNote")}</Field>
      <Field label={t("detail.fields.requestedBy")}>{request.requestedByName ? <bdi>{request.requestedByName}</bdi> : "—"}</Field>
      {reasonCode ? (
        <Field label={t("detail.fields.statusReason")}>
          {t(`reasons.${reasonCode}`, { defaultValue: reasonCode })}
          {request.statusReason?.note ? ` — ${request.statusReason.note}` : ""}
        </Field>
      ) : null}

      {request.receivedQuantity || request.remainingQuantity || request.variance ? (
        <>
          <Divider />
          <Group align="flex-start" grow wrap="wrap">
            {request.receivedQuantity ? (
              <Field label={t("detail.fields.received")}>
                <QuantityText quantity={request.receivedQuantity} />
              </Field>
            ) : null}
            {request.remainingQuantity ? (
              <Field label={t("detail.fields.remaining")}>
                <QuantityText quantity={request.remainingQuantity} />
              </Field>
            ) : null}
            {request.variance ? (
              <Field label={t("detail.fields.variance")}>
                <QuantityText quantity={request.variance} />
                {/* Pourcentage calculé par le serveur : affiché tel quel, jamais recalculé. */}{" "}
                <Ltr>{formatPercent(request.variance.percent)}</Ltr>
              </Field>
            ) : null}
          </Group>
        </>
      ) : null}

      {request.order ? (
        <>
          <Divider />
          <RequestOrderSummary order={request.order} quantity={request.quantity} />
        </>
      ) : null}

      {request.deliveries ? (
        <>
          <Divider />
          <RequestDeliveriesList deliveries={request.deliveries} detailHref={(delivery) => deliveryHref(request.siteId, delivery.id)} />
        </>
      ) : null}

      <Text size="sm" c="dimmed">
        {t("detail.createdBy", { name: request.createdByName ?? "—", date: created ?? "" })}
        {request.updatedAt ? ` · ${t("detail.updatedBy", { name: request.updatedByName ?? "—", date: updated ?? "" })}` : ""}
      </Text>

      <Divider />
      <Title order={3} size="h4">
        {t("detail.history")}
      </Title>
      <RequestHistory history={request.history ?? []} />
    </Stack>
  );
};
