import { Stack, Title } from "@mantine/core";
import { useTranslation } from "react-i18next";
import { useParams } from "react-router-dom";

import { ToOrderContainer } from "../containers/ToOrder.container";

/** Page « Demandes à commander » (route `/materials/to-order`) ; `:siteId/:requestId` ouvre le tiroir de détail. */
const ToOrderSection = () => {
  const { t } = useTranslation("materials");
  const { siteId, requestId } = useParams<{ siteId: string; requestId: string }>();

  return (
    <Stack gap="md">
      <title>{t("toOrder.title")}</title>
      <Title order={1}>{t("toOrder.title")}</Title>
      <ToOrderContainer open={siteId && requestId ? { siteId, requestId } : undefined} />
    </Stack>
  );
};

export default ToOrderSection;
