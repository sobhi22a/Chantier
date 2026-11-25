import { Stack, Title } from "@mantine/core";
import { useTranslation } from "react-i18next";

import { SitesBrowserContainer } from "../containers/SitesBrowser.container";

/** Page « Mes chantiers » (route `/sites`). */
const SitesBrowserSection = () => {
  const { t } = useTranslation("sites");

  return (
    <Stack gap="md">
      <title>{t("list.title")}</title>
      <Title order={1}>{t("list.title")}</Title>
      <SitesBrowserContainer />
    </Stack>
  );
};

export default SitesBrowserSection;
