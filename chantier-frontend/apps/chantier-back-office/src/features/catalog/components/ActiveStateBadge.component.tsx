import { Badge } from "@mantine/core";
import { IconCircleCheck, IconCircleOff } from "@tabler/icons-react";
import { useTranslation } from "react-i18next";

/** État actif / désactivé : texte ET icône, jamais la couleur seule. */
export const ActiveStateBadge = ({ isActive }: { isActive: boolean }) => {
  const { t } = useTranslation("catalog");
  return isActive ? (
    <Badge color="green" variant="light" size="lg" leftSection={<IconCircleCheck size={14} aria-hidden />}>
      {t("state.active")}
    </Badge>
  ) : (
    <Badge color="gray" variant="light" size="lg" leftSection={<IconCircleOff size={14} aria-hidden />}>
      {t("state.inactive")}
    </Badge>
  );
};
