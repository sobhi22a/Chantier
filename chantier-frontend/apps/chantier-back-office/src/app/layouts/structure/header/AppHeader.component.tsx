import { Burger, Group, Text } from "@mantine/core";
import { useTranslation } from "react-i18next";

import { useApiErrorMessage, useAuthMeQuery, useAuthUpdateLanguageMutation } from "@chantier-frontend/api-core";
import { LanguageSwitcher, type Language } from "@chantier-frontend/i18n";
import { useNotifications } from "@chantier-frontend/user-interface";

import { UserMenu } from "./UserMenu.component";

export interface AppHeaderProps {
  menuOpened: boolean;
  onToggleMenu: () => void;
}

/** En-tête : titre, choix de langue (mémorisé sur le compte : `PUT /auth/me/language`) et menu utilisateur. */
export const AppHeader = ({ menuOpened, onToggleMenu }: AppHeaderProps) => {
  const { t } = useTranslation("common");
  const { data: me } = useAuthMeQuery();
  const [updateLanguage] = useAuthUpdateLanguageMutation();
  const { showNotification } = useNotifications();
  const { getMessage } = useApiErrorMessage();

  // La langue change tout de suite à l'écran ; la mémorisation sur le compte vient ensuite. Un échec n'annule pas le choix.
  const rememberLanguage = async (language: Language) => {
    if (me?.language === language) return;
    try {
      await updateLanguage({ updateLanguageRequest: { language } }).unwrap();
    } catch (error) {
      showNotification({ type: "warning", message: getMessage(error) });
    }
  };

  return (
    <Group h="100%" px="md" justify="space-between" wrap="nowrap">
      <Group gap="sm" wrap="nowrap">
        <Burger opened={menuOpened} onClick={onToggleMenu} hiddenFrom="sm" size="sm" aria-label={t("nav.menu")} />
        <Text fw={700} size="lg">
          {t("app.title")}
        </Text>
      </Group>
      <Group gap="sm" wrap="nowrap">
        <LanguageSwitcher onLanguageChange={(language) => void rememberLanguage(language)} />
        <UserMenu />
      </Group>
    </Group>
  );
};
