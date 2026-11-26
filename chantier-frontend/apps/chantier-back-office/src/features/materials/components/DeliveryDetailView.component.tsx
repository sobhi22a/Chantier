import { Alert, Anchor, Divider, Group, Stack, Text, Title } from "@mantine/core";
import { IconAlertTriangle, IconBan, IconLinkOff, IconLock } from "@tabler/icons-react";
import type { ReactNode } from "react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

import { formatAmount, formatDateOnly, formatDateTime, Ltr, QuantityText } from "@chantier-frontend/i18n";

import type { DeliveryDetail } from "../types/deliveryTypes";
import { isCancelled } from "../types/deliveryTypes";
import { DeliveryStatusBadge, MissingNoteBadge, UnattachedBadge } from "./DeliveryBadges.component";
import { useProductDisplay } from "./RequestDetailView.component";
import { RequestHistory } from "./RequestHistory.component";

const Field = ({ label, children }: { label: string; children: ReactNode }) => (
  <Stack gap={0}>
    <Text size="sm" c="dimmed">
      {label}
    </Text>
    <Text component="div">{children}</Text>
  </Stack>
);

export interface DeliveryDetailViewProps {
  delivery: DeliveryDetail;
  /** La demande liée est réceptionnée : la livraison ne se corrige plus (`DEMANDE_NON_OUVERTE`). */
  requestReceived: boolean;
  /** Adresse de la demande liée (tiroir de la liste des demandes) ; absente : numéro non cliquable. */
  requestHref?: string;
  /** Zone des photos (composant et état d'envoi sont gérés par le conteneur). */
  photos: ReactNode;
}

/**
 * Contenu du tiroir d'une livraison : état, demande, quantité avec unité (et équivalent dans l'unité de la demande), BL, réserve,
 * valeur (seulement si le serveur a fourni `commercial`), photos et historique. Les actions sont dans le conteneur.
 */
export const DeliveryDetailView = ({ delivery, requestReceived, requestHref, photos }: DeliveryDetailViewProps) => {
  const { t } = useTranslation("materials");
  const productDisplay = useProductDisplay();
  const product = productDisplay(delivery.product);
  const date = formatDateOnly(delivery.deliveryDate);
  const created = formatDateTime(delivery.createdAt);
  const updated = formatDateTime(delivery.updatedAt);
  const cancelled = isCancelled(delivery);
  const converted = delivery.quantityInRequestUnit && delivery.quantityInRequestUnit.unit !== delivery.quantity.unit;
  const supplier = delivery.supplierName ?? delivery.freeSupplierName;
  const reasonCode = delivery.cancelReason?.code;

  return (
    <Stack gap="md">
      <Group gap="xs">
        <DeliveryStatusBadge status={delivery.status} conformity={delivery.conformity} />
        {delivery.requestId === null || delivery.requestId === undefined ? <UnattachedBadge /> : null}
        {delivery.missingNote ? <MissingNoteBadge /> : null}
      </Group>

      {cancelled ? (
        <Alert color="gray" variant="light" icon={<IconBan aria-hidden />} role="note">
          {t("deliveries.detail.cancelledBanner")}
        </Alert>
      ) : null}
      {!delivery.requestId && delivery.unattachedReason ? (
        <Alert color="orange" variant="light" icon={<IconLinkOff aria-hidden />} role="note">
          {t("deliveries.detail.unattachedBanner", { reason: t(`deliveries.unattachedReason.${delivery.unattachedReason}`) })}
        </Alert>
      ) : null}
      {delivery.possibleDuplicateOf ? (
        <Alert color="orange" variant="light" icon={<IconAlertTriangle aria-hidden />} role="note">
          {t("deliveries.detail.duplicate", { number: delivery.possibleDuplicateOf.number })}
        </Alert>
      ) : null}
      {requestReceived && !cancelled ? (
        <Alert color="blue" variant="light" icon={<IconLock aria-hidden />} role="note">
          {t("deliveries.detail.receivedBanner")}
        </Alert>
      ) : null}

      <Group align="flex-start" grow wrap="wrap">
        <Field label={t("deliveries.detail.fields.date")}>{date ? <Ltr>{date}</Ltr> : "—"}</Field>
        <Field label={t("deliveries.detail.fields.request")}>
          {delivery.requestNumber ? (
            requestHref ? (
              <Anchor component={Link} to={requestHref} aria-label={t("deliveries.detail.openRequest", { number: delivery.requestNumber })}>
                <Ltr>{delivery.requestNumber}</Ltr>
              </Anchor>
            ) : (
              <Ltr>{delivery.requestNumber}</Ltr>
            )
          ) : (
            t("deliveries.noRequest")
          )}
        </Field>
      </Group>
      <Field label={t("deliveries.detail.fields.product")}>
        <bdi>{product.name}</bdi>
        {product.isFree ? ` (${t("detail.freeProduct")})` : ""}
      </Field>
      <Field label={t("deliveries.detail.fields.supplier")}>{supplier ? <bdi>{supplier}</bdi> : "—"}</Field>
      <Group align="flex-start" grow wrap="wrap">
        <Field label={t("deliveries.detail.fields.quantity")}>
          <QuantityText quantity={delivery.quantity} />
        </Field>
        {converted ? (
          <Field label={t("deliveries.detail.fields.inRequestUnit")}>
            <QuantityText quantity={delivery.quantityInRequestUnit} />
          </Field>
        ) : null}
      </Group>
      <Field label={t("deliveries.detail.fields.note")}>{delivery.deliveryNoteNumber ? <Ltr>{delivery.deliveryNoteNumber}</Ltr> : t("deliveries.detail.noNote")}</Field>
      {delivery.conformity === "WithReserve" && delivery.reserve ? (
        <Field label={t("deliveries.detail.fields.reserve")}>
          {t(`reasons.${delivery.reserve.code}`, { defaultValue: delivery.reserve.code })}
          {delivery.reserve.note ? ` — ${delivery.reserve.note}` : ""}
        </Field>
      ) : null}
      {reasonCode ? (
        <Field label={t("deliveries.detail.fields.cancelReason")}>
          {t(`reasons.${reasonCode}`, { defaultValue: reasonCode })}
          {delivery.cancelReason?.note ? ` — ${delivery.cancelReason.note}` : ""}
        </Field>
      ) : null}
      {/* Valeur calculée par le serveur (quantité × prix de la commande) : présente seulement avec `Prices.View`. */}
      {delivery.commercial ? (
        <Field label={t("deliveries.detail.fields.amount")}>
          <Ltr>{formatAmount(delivery.commercial.amount)}</Ltr>
        </Field>
      ) : null}

      <Divider />
      {photos}

      <Text size="sm" c="dimmed">
        {t("deliveries.detail.createdBy", { name: delivery.createdByName ?? "—", date: created ?? "" })}
        {delivery.updatedAt ? ` · ${t("deliveries.detail.updatedBy", { name: delivery.updatedByName ?? "—", date: updated ?? "" })}` : ""}
      </Text>

      <Divider />
      <Title order={3} size="h4">
        {t("deliveries.detail.history")}
      </Title>
      <RequestHistory history={delivery.history ?? []} />
    </Stack>
  );
};
