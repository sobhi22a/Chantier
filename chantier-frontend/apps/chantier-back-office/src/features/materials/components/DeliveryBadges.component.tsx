import { Badge, Group } from "@mantine/core";
import { IconAlertTriangle, IconBan, IconCircleCheck, IconFileOff, IconLinkOff } from "@tabler/icons-react";
import { useTranslation } from "react-i18next";

import type { Conformity, DeliveryStatus } from "@chantier-frontend/api-core";

// Orange = à traiter (réserve, non rattachée, BL manquant), vert = enregistrée, gris = annulée.
// Toujours doublé d'une icône ET d'un libellé.

export const ReserveBadge = () => {
  const { t } = useTranslation("materials");
  return (
    <Badge color="orange" variant="filled" size="lg" leftSection={<IconAlertTriangle size={14} aria-hidden />}>
      {t("deliveries.conformity.WithReserve")}
    </Badge>
  );
};

export const DeliveryStatusBadge = ({ status, conformity }: { status: DeliveryStatus; conformity?: Conformity }) => {
  const { t } = useTranslation("materials");
  if (status === "Cancelled") {
    return (
      <Badge color="gray" variant="light" size="lg" leftSection={<IconBan size={14} aria-hidden />}>
        {t("deliveries.status.Cancelled")}
      </Badge>
    );
  }
  return (
    <Group gap={4} wrap="wrap">
      <Badge color="green" variant="light" size="lg" leftSection={<IconCircleCheck size={14} aria-hidden />}>
        {t("deliveries.status.Recorded")}
      </Badge>
      {conformity === "WithReserve" ? <ReserveBadge /> : null}
    </Group>
  );
};

export const UnattachedBadge = () => {
  const { t } = useTranslation("materials");
  return (
    <Badge color="orange" variant="filled" size="lg" leftSection={<IconLinkOff size={14} aria-hidden />}>
      {t("deliveries.badges.unattached")}
    </Badge>
  );
};

export const MissingNoteBadge = () => {
  const { t } = useTranslation("materials");
  return (
    <Badge color="orange" variant="light" size="lg" leftSection={<IconFileOff size={14} aria-hidden />}>
      {t("deliveries.badges.missingNote")}
    </Badge>
  );
};
