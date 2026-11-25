import { AppShell } from "@mantine/core";
import { useDisclosure } from "@mantine/hooks";
import { useTranslation } from "react-i18next";
import { Outlet } from "react-router-dom";

import { AppHeader } from "../header/AppHeader.component";
import { SidebarNavigation } from "../sidebarNavigation/SidebarNavigation.component";

import "./dashboardLayout.style.scss";

/** Mise en page de l'espace connecté : en-tête, menu latéral (repliable sur téléphone) et contenu. */
export const DashboardLayout = () => {
  const { t } = useTranslation("common");
  const [menuOpened, { toggle, close }] = useDisclosure(false);

  return (
    <AppShell
      header={{ height: 64 }}
      navbar={{ width: 260, breakpoint: "sm", collapsed: { mobile: !menuOpened } }}
      padding="md"
    >
      <a className="skip-link" href="#main-content">
        {t("nav.skipToContent")}
      </a>
      <AppShell.Header>
        <AppHeader menuOpened={menuOpened} onToggleMenu={toggle} />
      </AppShell.Header>
      <AppShell.Navbar p="md">
        <SidebarNavigation onNavigate={close} />
      </AppShell.Navbar>
      <AppShell.Main id="main-content" tabIndex={-1}>
        <Outlet />
      </AppShell.Main>
    </AppShell>
  );
};

export default DashboardLayout;
