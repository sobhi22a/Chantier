import { Center, Loader, Stack, Text } from "@mantine/core";
import { useTranslation } from "react-i18next";

export interface GenericLoaderComponentProps {
  /** Texte lu par les lecteurs d'écran et affiché sous l'indicateur (défaut : « Chargement en cours… »). */
  loaderText?: string;
  height?: "85%" | "100%" | "100dvh";
}

const GenericLoaderComponent = ({ loaderText, height = "100%" }: GenericLoaderComponentProps) => {
  const { t } = useTranslation("common");

  return (
    <Center h={height} role="status" aria-live="polite">
      <Stack align="center" gap="xs">
        <Loader size={30} type="dots" aria-hidden />
        <Text size="md">{loaderText ?? t("state.loading")}</Text>
      </Stack>
    </Center>
  );
};

export default GenericLoaderComponent;
