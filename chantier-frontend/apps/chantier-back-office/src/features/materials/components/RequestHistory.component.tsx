import { List, Stack, Text } from "@mantine/core";
import { useTranslation } from "react-i18next";

import type { FieldChange, RequestHistoryItem } from "@chantier-frontend/api-core";
import { formatAmount, formatDateOnly, formatDateTime, Ltr, useQuantityFormatter } from "@chantier-frontend/i18n";

/** « 300 sac » (forme de l'historique du serveur) → « 300 sacs » dans la langue courante. */
const useChangeValue = () => {
  const { t } = useTranslation("materials");
  const { quantityText } = useQuantityFormatter();

  return (change: FieldChange, side: "old" | "new"): string | null => {
    const raw = change[side];
    if (raw === null || raw === "") return null;
    switch (change.field) {
      case "quantity": {
        const [value, unit] = raw.split(" ");
        return value && unit ? quantityText({ value: Number(value), unit }) : raw;
      }
      case "neededBy":
      case "deliveryDate":
      case "expectedDeliveryDate":
        return formatDateOnly(raw) ?? raw;
      case "priority":
        return t(`priority.${raw}`, { defaultValue: raw });
      case "conformity":
        return t(`deliveries.conformity.${raw}`, { defaultValue: raw });
      case "reserveReasonCode":
        return t(`reasons.${raw}`, { defaultValue: raw });
      // Prix de la commande (événement sensible : le serveur ne l'envoie qu'avec `Prices.View`) : en dinars, 2 décimales.
      case "unitPrice":
        return Number.isFinite(Number(raw)) ? formatAmount(Number(raw)) : raw;
      // Identifiants de produit, de zone, de fournisseur et de demande : jamais affichés tels quels.
      case "productId":
      case "zoneId":
      case "supplierId":
      case "requestId":
        return null;
      default:
        return raw;
    }
  };
};

/** Historique : qui, quand (heure du serveur, Algérie), ancien → nouveau statut, motif, valeurs modifiées (CA-MAT-002.2). */
export const RequestHistory = ({ history }: { history: readonly RequestHistoryItem[] }) => {
  const { t, i18n } = useTranslation("materials");
  const changeValue = useChangeValue();

  if (history.length === 0) return <Text c="dimmed">{t("detail.noHistory")}</Text>;

  return (
    <List spacing="sm" listStyleType="none" m={0} p={0} aria-label={t("detail.history")}>
      {history.map((event) => {
        const date = formatDateTime(event.occurredAt);
        const deviceDate = formatDateTime(event.deviceAt);
        return (
          <List.Item key={event.id}>
            <Stack gap={2}>
              <Text fw={600}>{t(`events.${event.type}`, { defaultValue: event.type })}</Text>
              <Text size="sm" c="dimmed">
                {event.actorName ? <bdi>{event.actorName}</bdi> : null}
                {event.actorName && date ? " · " : null}
                {date ? <Ltr>{date}</Ltr> : null}
              </Text>
              {event.fromStatus && event.toStatus ? (
                <Text size="sm">
                  {t(`status.${event.fromStatus}`, { defaultValue: event.fromStatus })} {i18n.dir() === "rtl" ? "←" : "→"}{" "}
                  {t(`status.${event.toStatus}`, { defaultValue: event.toStatus })}
                </Text>
              ) : null}
              {event.type === "StatusRecomputed" && event.reasonCode ? (
                <Text size="sm">{t(`recompute.${event.reasonCode}`, { number: event.reasonNote ?? "", defaultValue: t("events.StatusRecomputed") })}</Text>
              ) : event.reasonCode ? (
                <Text size="sm">
                  {t("detail.fields.statusReason")} : {t(`reasons.${event.reasonCode}`, { defaultValue: event.reasonCode })}
                  {event.reasonNote ? ` — ${event.reasonNote}` : ""}
                </Text>
              ) : null}
              {(event.changes ?? []).map((change) => {
                const before = changeValue(change, "old");
                const after = changeValue(change, "new");
                return (
                  <Text size="sm" key={change.field}>
                    {t(`fields.${change.field}`, { defaultValue: change.field })}
                    {before !== null || after !== null ? (
                      <>
                        {" : "}
                        {before ?? "—"} {i18n.dir() === "rtl" ? "←" : "→"} {after ?? "—"}
                      </>
                    ) : null}
                  </Text>
                );
              })}
              {deviceDate ? (
                <Text size="xs" c="dimmed">
                  {t("detail.offlineEntry", { date: deviceDate })}
                </Text>
              ) : null}
            </Stack>
          </List.Item>
        );
      })}
    </List>
  );
};
