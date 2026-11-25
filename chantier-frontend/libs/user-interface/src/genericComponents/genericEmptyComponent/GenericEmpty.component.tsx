import { Center, Stack, Text } from "@mantine/core";
import { IconInbox } from "@tabler/icons-react";
import type { ReactNode } from "react";
import { useTranslation } from "react-i18next";

export interface GenericEmptyComponentProps {
  /** Message déjà traduit (défaut : « Aucun élément à afficher. »). */
  message?: string;
  /** Action proposée (bouton « Actualiser », « Créer »…). */
  action?: ReactNode;
}

/** État « vide » d'une liste : toujours un texte, jamais un tableau blanc. */
const GenericEmptyComponent = ({ message, action }: GenericEmptyComponentProps) => {
  const { t } = useTranslation("common");

  return (
    <Center py="xl">
      <Stack align="center" gap="sm">
        <IconInbox size={40} aria-hidden />
        <Text ta="center">{message ?? t("state.empty")}</Text>
        {action}
      </Stack>
    </Center>
  );
};

export default GenericEmptyComponent;
