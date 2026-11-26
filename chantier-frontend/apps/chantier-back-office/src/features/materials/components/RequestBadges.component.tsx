import { Badge } from "@mantine/core";
import {
  IconAlertOctagon,
  IconAlertTriangle,
  IconBan,
  IconCircleCheck,
  IconClock,
  IconCircleDot,
  IconMinus,
  IconTruckDelivery,
  IconX,
} from "@tabler/icons-react";
import type { ReactNode } from "react";
import { useTranslation } from "react-i18next";

import type { Priority, RequestStatus } from "@chantier-frontend/api-core";

// Rouge = urgent ou bloqué, orange = en retard ou urgent, vert = terminé. Toujours doublé d'une icône ET d'un libellé.
const STATUS_STYLE: Record<RequestStatus, { color: string; icon: ReactNode }> = {
  Requested: { color: "blue", icon: <IconClock size={14} aria-hidden /> },
  Validated: { color: "blue", icon: <IconCircleDot size={14} aria-hidden /> },
  Ordered: { color: "blue", icon: <IconTruckDelivery size={14} aria-hidden /> },
  PartiallyDelivered: { color: "cyan", icon: <IconTruckDelivery size={14} aria-hidden /> },
  Delivered: { color: "green", icon: <IconCircleCheck size={14} aria-hidden /> },
  Received: { color: "green", icon: <IconCircleCheck size={14} aria-hidden /> },
  Rejected: { color: "gray", icon: <IconX size={14} aria-hidden /> },
  Cancelled: { color: "gray", icon: <IconBan size={14} aria-hidden /> },
};

export const RequestStatusBadge = ({ status }: { status: RequestStatus }) => {
  const { t } = useTranslation("materials");
  const style = STATUS_STYLE[status] ?? STATUS_STYLE.Requested;
  return (
    <Badge color={style.color} variant="light" size="lg" leftSection={style.icon}>
      {t(`status.${status}`, { defaultValue: status })}
    </Badge>
  );
};

const PRIORITY_STYLE: Record<Priority, { color: string; icon: ReactNode }> = {
  Normal: { color: "gray", icon: <IconMinus size={14} aria-hidden /> },
  Urgent: { color: "orange", icon: <IconAlertTriangle size={14} aria-hidden /> },
  Blocking: { color: "red", icon: <IconAlertOctagon size={14} aria-hidden /> },
};

export const PriorityBadge = ({ priority }: { priority: Priority }) => {
  const { t } = useTranslation("materials");
  const style = PRIORITY_STYLE[priority] ?? PRIORITY_STYLE.Normal;
  return (
    <Badge color={style.color} variant={priority === "Normal" ? "light" : "filled"} size="lg" leftSection={style.icon}>
      {t(`priority.${priority}`, { defaultValue: priority })}
    </Badge>
  );
};

/** « En retard de N jours » : orange, icône et texte ; rien quand la demande n'est pas en retard. */
export const OverdueBadge = ({ days }: { days: number }) => {
  const { t } = useTranslation("materials");
  if (days <= 0) return null;
  return (
    <Badge color="orange" variant="filled" size="lg" leftSection={<IconClock size={14} aria-hidden />}>
      {t("list.overdue", { count: days })}
    </Badge>
  );
};
