import { NavLink, Stack, Text } from "@mantine/core";
import { IconBuilding } from "@tabler/icons-react";
import { useTranslation } from "react-i18next";
import { Link, useLocation } from "react-router-dom";

import { PERMISSIONS_RESOURCES, usePermissions } from "@chantier-frontend/authentication";

import { BACK_OFFICE_ROUTES } from "../../../providers/router/navigationRoutes";

/** Menu latéral : section « Chantiers » avec une seule entrée au socle (« Mes chantiers »). */
export const SidebarNavigation = ({ onNavigate }: { onNavigate?: () => void }) => {
  const { t } = useTranslation("common");
  const { can } = usePermissions();
  const { pathname } = useLocation();

  return (
    <nav aria-label={t("nav.menu")}>
      <Stack gap="xs">
        <Text component="h2" size="xs" fw={700} tt="uppercase" c="dimmed" m={0}>
          {t("nav.sites")}
        </Text>
        {can(PERMISSIONS_RESOURCES.SITES, "View") ? (
          <NavLink
            component={Link}
            to={BACK_OFFICE_ROUTES.SITES}
            label={t("nav.mySites")}
            leftSection={<IconBuilding size={20} aria-hidden />}
            active={pathname === BACK_OFFICE_ROUTES.SITES || pathname.startsWith(`${BACK_OFFICE_ROUTES.SITES}/`)}
            onClick={onNavigate}
          />
        ) : null}
      </Stack>
    </nav>
  );
};
