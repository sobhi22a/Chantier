import { Button, Menu, Text } from "@mantine/core";
import { IconChevronDown, IconKey, IconLogout, IconUser } from "@tabler/icons-react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

import { useAuthMeQuery } from "@chantier-frontend/api-core";
import { AUTHENTICATION_ROUTES, useSignOut } from "@chantier-frontend/authentication";

/** Menu de l'utilisateur : nom, rôle, changement de mot de passe, déconnexion. */
export const UserMenu = () => {
  const { t } = useTranslation(["auth", "common"]);
  const { data: me } = useAuthMeQuery();
  const { signOut, isSigningOut } = useSignOut();

  if (!me) return null;

  return (
    <Menu position="bottom-end" withinPortal>
      <Menu.Target>
        <Button
          variant="subtle"
          leftSection={<IconUser size={18} aria-hidden />}
          rightSection={<IconChevronDown size={16} aria-hidden />}
          aria-label={t("auth:userMenu.label")}
        >
          <bdi>{me.fullName}</bdi>
        </Button>
      </Menu.Target>
      <Menu.Dropdown>
        <Menu.Label>
          {t("auth:userMenu.role")} : {t(`common:roles.${me.role as "Admin"}`, { defaultValue: me.role })}
        </Menu.Label>
        <Menu.Item component={Link} to={AUTHENTICATION_ROUTES.CHANGE_PASSWORD} leftSection={<IconKey size={16} aria-hidden />}>
          {t("auth:userMenu.changePassword")}
        </Menu.Item>
        <Menu.Item leftSection={<IconLogout size={16} aria-hidden />} onClick={() => void signOut()} disabled={isSigningOut}>
          <Text span>{t("auth:signOut.action")}</Text>
        </Menu.Item>
      </Menu.Dropdown>
    </Menu>
  );
};
