import { Stack, Text } from "@mantine/core";
import { useTranslation } from "react-i18next";

import { formatDateTime } from "@chantier-frontend/i18n";

export interface AuditInfo {
  createdAt: string;
  createdByName: string | null;
  updatedAt: string | null;
  updatedByName: string | null;
  archivedAt?: string | null;
  archivedByName?: string | null;
}

const NO_NAME = "—";

/** « Créé par … le … » : qui et quand, à l'heure du serveur converti en heure d'Algérie (CA-016.1, CA-016.2). */
export const AuditLine = ({ audit }: { audit: AuditInfo }) => {
  const { t } = useTranslation("sites");
  const created = formatDateTime(audit.createdAt);
  const updated = formatDateTime(audit.updatedAt);
  const archived = formatDateTime(audit.archivedAt);

  return (
    <Stack gap={2}>
      {created ? (
        <Text size="sm" c="dimmed">
          {t("detail.createdBy", { name: audit.createdByName ?? NO_NAME, date: created })}
        </Text>
      ) : null}
      {updated ? (
        <Text size="sm" c="dimmed">
          {t("detail.updatedBy", { name: audit.updatedByName ?? NO_NAME, date: updated })}
        </Text>
      ) : null}
      {archived ? (
        <Text size="sm" c="dimmed">
          {t("detail.archivedBy", { name: audit.archivedByName ?? NO_NAME, date: archived })}
        </Text>
      ) : null}
    </Stack>
  );
};
