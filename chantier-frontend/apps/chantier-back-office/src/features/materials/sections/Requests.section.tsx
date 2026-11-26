import { Stack, Title } from "@mantine/core";
import { useParams } from "react-router-dom";
import { useTranslation } from "react-i18next";

import { RequestsBrowserContainer } from "../containers/RequestsBrowser.container";

/** Page « Demandes de matériaux » (route `/materials/requests`) ; `:siteId/:requestId` ouvre le tiroir de détail. */
const RequestsSection = () => {
  const { t } = useTranslation("materials");
  const { siteId, requestId } = useParams<{ siteId: string; requestId: string }>();

  return (
    <Stack gap="md">
      <title>{t("list.title")}</title>
      <Title order={1}>{t("list.title")}</Title>
      <RequestsBrowserContainer open={siteId && requestId ? { siteId, requestId } : undefined} />
    </Stack>
  );
};

export default RequestsSection;
