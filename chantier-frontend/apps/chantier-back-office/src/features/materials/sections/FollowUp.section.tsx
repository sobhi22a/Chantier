import { Stack, Title } from "@mantine/core";
import { useTranslation } from "react-i18next";
import { useParams } from "react-router-dom";

import { FollowUpContainer } from "../containers/FollowUp.container";

/** Page « Suivi des approvisionnements » (route `/materials/follow-up`) ; `:siteId/:requestId` ouvre le tiroir de détail. */
const FollowUpSection = () => {
  const { t } = useTranslation("materials");
  const { siteId, requestId } = useParams<{ siteId: string; requestId: string }>();

  return (
    <Stack gap="md">
      <title>{t("followUp.title")}</title>
      <Title order={1}>{t("followUp.title")}</Title>
      <FollowUpContainer open={siteId && requestId ? { siteId, requestId } : undefined} />
    </Stack>
  );
};

export default FollowUpSection;
