import { Button, Center, Group, Paper, Stack, Text, Title } from "@mantine/core";
import { IconAlertTriangle } from "@tabler/icons-react";
import { Component, type ReactNode } from "react";
import { useTranslation } from "react-i18next";

export interface GenericErrorFallbackComponentProps {
  /** Type de l'erreur (`TypeError`…) : aide le support sans exposer de message ni de donnée. */
  errorName?: string;
}

/** Écran d'erreur : sert de repli à l'ErrorBoundary et d'`errorElement` au routeur. */
export const GenericErrorFallbackComponent = ({ errorName }: GenericErrorFallbackComponentProps) => {
  const { t } = useTranslation("common");

  return (
    <Center mih="100dvh" p="md">
      <Paper withBorder shadow="sm" p="xl" maw={560} w="100%" role="alert">
        <Stack gap="md">
          <Group gap="sm" wrap="nowrap">
            <IconAlertTriangle size={32} aria-hidden />
            <Title order={1} size="h3">
              {t("errorBoundary.title")}
            </Title>
          </Group>
          <Text>{t("errorBoundary.message")}</Text>
          {errorName ? (
            <Text size="sm" c="dimmed">
              {t("errorBoundary.reference")} : <bdi dir="ltr">{errorName}</bdi>
            </Text>
          ) : null}
          <Button onClick={() => window.location.assign("/")}>{t("errorBoundary.reload")}</Button>
        </Stack>
      </Paper>
    </Center>
  );
};

interface GenericErrorBoundaryProps {
  children: ReactNode;
}

interface GenericErrorBoundaryState {
  error: Error | null;
}

export class GenericErrorBoundaryComponent extends Component<GenericErrorBoundaryProps, GenericErrorBoundaryState> {
  override state: GenericErrorBoundaryState = { error: null };

  static getDerivedStateFromError(error: Error): GenericErrorBoundaryState {
    return { error };
  }

  override render(): ReactNode {
    if (this.state.error) {
      return <GenericErrorFallbackComponent errorName={this.state.error.name} />;
    }
    return this.props.children;
  }
}
