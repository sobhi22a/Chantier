import { notifications } from "@mantine/notifications";
import { IconAlertOctagon, IconAlertTriangle, IconCircleCheck, IconInfoCircle } from "@tabler/icons-react";
import type { ReactNode } from "react";
import { useTranslation } from "react-i18next";

export type NotificationType = "info" | "success" | "warning" | "error";

export interface ShowNotificationOptions {
  type?: NotificationType;
  /** Message déjà traduit. */
  message: string;
  autoClose?: number | boolean;
}

// Couleur ET icône ET titre : l'information ne repose jamais sur la couleur seule.
const NOTIFICATION_STYLES: Record<NotificationType, { color: string; icon: ReactNode }> = {
  info: { color: "blue", icon: <IconInfoCircle size={20} aria-hidden /> },
  success: { color: "green", icon: <IconCircleCheck size={20} aria-hidden /> },
  warning: { color: "orange", icon: <IconAlertTriangle size={20} aria-hidden /> },
  error: { color: "red", icon: <IconAlertOctagon size={20} aria-hidden /> },
};

export const useNotifications = () => {
  const { i18n } = useTranslation("common");

  const showNotification = ({ type = "info", message, autoClose = 5000 }: ShowNotificationOptions): string =>
    notifications.show({
      // Langue lue au moment de l'appel (une notification peut suivre un changement de langue).
      title: i18n.t(`notifications.${type}`, { ns: "common" }),
      message,
      autoClose,
      withBorder: true,
      color: NOTIFICATION_STYLES[type].color,
      icon: NOTIFICATION_STYLES[type].icon,
    });

  const cleanNotifications = (): void => {
    notifications.clean();
  };

  return { showNotification, cleanNotifications };
};
