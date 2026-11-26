import { NavLink, Stack, Text } from "@mantine/core";
import { IconBuilding, IconChartBar, IconChecklist, IconClipboardList, IconPackage, IconPackageImport, IconShoppingCart, IconTruck } from "@tabler/icons-react";
import type { ReactNode } from "react";
import { useTranslation } from "react-i18next";
import { Link, useLocation } from "react-router-dom";

import { FOLLOW_UP_PERMISSIONS, PERMISSIONS_RESOURCES, usePermissions } from "@chantier-frontend/authentication";

import { BACK_OFFICE_ROUTES } from "../../../providers/router/navigationRoutes";

const Section = ({ title, children }: { title: string; children: ReactNode }) => (
  <Stack gap="xs">
    <Text component="h2" size="xs" fw={700} tt="uppercase" c="dimmed" m={0}>
      {title}
    </Text>
    {children}
  </Stack>
);

/**
 * Menu latéral : « Chantiers », « Approvisionnement » et « Catalogue ». Une entrée interdite n'est pas affichée
 * (le serveur refuse de toute façon) ; une section sans entrée disparaît.
 */
export const SidebarNavigation = ({ onNavigate }: { onNavigate?: () => void }) => {
  const { t } = useTranslation("common");
  const { can } = usePermissions();
  const { pathname } = useLocation();

  const isActive = (route: string) => pathname === route || pathname.startsWith(`${route}/`);
  const item = (route: string, label: string, icon: ReactNode) => (
    <NavLink component={Link} to={route} label={label} leftSection={icon} active={isActive(route)} onClick={onNavigate} />
  );

  const canSeeSites = can(PERMISSIONS_RESOURCES.SITES, "View");
  const canSeeRequests = can(PERMISSIONS_RESOURCES.REQUESTS, "View");
  const canApprove = can("Requests.Approve");
  const canOrder = can("Orders.Create");
  const canSeeDeliveries = can("Deliveries.View");
  const canSeeFollowUp = FOLLOW_UP_PERMISSIONS.some((permission) => can(permission));
  const canSeeProducts = can(PERMISSIONS_RESOURCES.PRODUCTS, "View");
  const canSeeSuppliers = can(PERMISSIONS_RESOURCES.SUPPLIERS, "View");

  return (
    <nav aria-label={t("nav.menu")}>
      <Stack gap="lg">
        <Section title={t("nav.sites")}>
          {canSeeSites ? item(BACK_OFFICE_ROUTES.SITES, t("nav.mySites"), <IconBuilding size={20} aria-hidden />) : null}
        </Section>
        {canSeeRequests || canApprove || canOrder || canSeeDeliveries ? (
          <Section title={t("nav.supply")}>
            {canSeeRequests
              ? item(BACK_OFFICE_ROUTES.MATERIAL_REQUESTS, t("nav.requests"), <IconClipboardList size={20} aria-hidden />)
              : null}
            {canApprove
              ? item(BACK_OFFICE_ROUTES.MATERIAL_TO_APPROVE, t("nav.toApprove"), <IconChecklist size={20} aria-hidden />)
              : null}
            {canOrder
              ? item(BACK_OFFICE_ROUTES.MATERIAL_TO_ORDER, t("nav.toOrder"), <IconShoppingCart size={20} aria-hidden />)
              : null}
            {canSeeDeliveries
              ? item(BACK_OFFICE_ROUTES.MATERIAL_DELIVERIES, t("nav.deliveries"), <IconPackageImport size={20} aria-hidden />)
              : null}
            {canSeeFollowUp
              ? item(BACK_OFFICE_ROUTES.MATERIAL_FOLLOW_UP, t("nav.followUp"), <IconChartBar size={20} aria-hidden />)
              : null}
          </Section>
        ) : null}
        {canSeeProducts || canSeeSuppliers ? (
          <Section title={t("nav.catalog")}>
            {canSeeProducts
              ? item(BACK_OFFICE_ROUTES.CATALOG_PRODUCTS, t("nav.products"), <IconPackage size={20} aria-hidden />)
              : null}
            {canSeeSuppliers
              ? item(BACK_OFFICE_ROUTES.CATALOG_SUPPLIERS, t("nav.suppliers"), <IconTruck size={20} aria-hidden />)
              : null}
          </Section>
        ) : null}
      </Stack>
    </nav>
  );
};
