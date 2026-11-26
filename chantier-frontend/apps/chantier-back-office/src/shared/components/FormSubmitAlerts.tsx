import { Alert, Button, Stack, Text } from "@mantine/core";
import { IconAlertOctagon, IconAlertTriangle } from "@tabler/icons-react";

import { isApiError, useApiErrorMessage } from "@chantier-frontend/api-core";

export interface FormSubmitAlertsProps<Current> {
  /** Erreur renvoyée par le serveur à l'enregistrement (`null` : rien à afficher). */
  error: unknown;
  /** Titre de l'alerte générale (« Le produit n'a pas pu être enregistré »). */
  generalTitle: string;
  /** 409 `CONFLIT_VERSION` (modifications) : le serveur renvoie l'état actuel (`current`) ; l'utilisateur le recharge. */
  conflict?: {
    title: string;
    message: (current: Current) => string;
    reloadLabel: string;
    onReload: (current: Current) => void;
  };
}

/** Alertes en tête d'un formulaire : conflit de version (avec « Recharger ») ou erreur générale traduite selon le `code`. */
export const FormSubmitAlerts = <Current,>({ error, generalTitle, conflict }: FormSubmitAlertsProps<Current>) => {
  const { describe } = useApiErrorMessage();
  if (!error) return null;

  const current =
    conflict && isApiError(error) && error.code === "CONFLIT_VERSION" ? (error.current as Current | undefined) : undefined;
  if (conflict && current) {
    return (
      <Alert color="orange" variant="light" icon={<IconAlertTriangle aria-hidden />} title={conflict.title} role="alert">
        <Stack gap="xs" align="flex-start">
          <Text>{conflict.message(current)}</Text>
          <Button variant="default" onClick={() => conflict.onReload(current)}>
            {conflict.reloadLabel}
          </Button>
        </Stack>
      </Alert>
    );
  }

  const { message, reference } = describe(error);
  return (
    <Alert color="red" variant="light" icon={<IconAlertOctagon aria-hidden />} title={generalTitle} role="alert">
      <Text>{message}</Text>
      {reference ? (
        <Text size="sm" c="dimmed">
          {reference}
        </Text>
      ) : null}
    </Alert>
  );
};
