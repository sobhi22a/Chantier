import { Alert, Button, Stack, Text } from "@mantine/core";
import { IconAlertOctagon } from "@tabler/icons-react";
import { useTranslation } from "react-i18next";

export interface GenericErrorComponentProps {
  /** Message traduit selon le code d'erreur (voir `useApiErrorMessage`). */
  message: string;
  /** Référence pour le support (`traceId`). */
  reference?: string | null;
  onRetry?: () => void;
}

/** État « erreur » d'une liste ou d'une fiche : message, référence du support et « Réessayer ». */
const GenericErrorComponent = ({ message, reference, onRetry }: GenericErrorComponentProps) => {
  const { t } = useTranslation("common");

  return (
    <Alert color="red" variant="light" icon={<IconAlertOctagon aria-hidden />} title={t("state.error")} role="alert">
      <Stack gap="xs" align="flex-start">
        <Text>{message}</Text>
        {reference ? (
          <Text size="sm" c="dimmed">
            {reference}
          </Text>
        ) : null}
        {onRetry ? (
          <Button variant="default" onClick={onRetry}>
            {t("actions.retry")}
          </Button>
        ) : null}
      </Stack>
    </Alert>
  );
};

export default GenericErrorComponent;
