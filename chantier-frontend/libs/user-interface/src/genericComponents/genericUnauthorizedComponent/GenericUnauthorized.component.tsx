import { Button, Center, Stack, Text, Title } from "@mantine/core";
import { IconLock } from "@tabler/icons-react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

/** Page « Accès non autorisé » (route `/unauthorized`). */
const GenericUnauthorizedComponent = () => {
  const { t } = useTranslation("common");

  return (
    <Center py="xl">
      <Stack align="center" gap="sm">
        <IconLock size={48} aria-hidden />
        <title>{t("unauthorized.title")}</title>
        <Title order={1} size="h2">
          {t("unauthorized.title")}
        </Title>
        <Text ta="center">{t("unauthorized.message")}</Text>
        <Button component={Link} to="/" variant="default">
          {t("unauthorized.backHome")}
        </Button>
      </Stack>
    </Center>
  );
};

export default GenericUnauthorizedComponent;
