import { Stack, Title } from "@mantine/core";
import { useTranslation } from "react-i18next";
import { useParams } from "react-router-dom";

import { ToApproveContainer } from "../containers/ToApprove.container";

/** Page « Demandes à valider » (route `/materials/to-approve`) ; `:siteId/:requestId` ouvre le tiroir de détail. */
const ToApproveSection = () => {
  const { t } = useTranslation("materials");
  const { siteId, requestId } = useParams<{ siteId: string; requestId: string }>();

  return (
    <Stack gap="md">
      <title>{t("toApprove.title")}</title>
      <Title order={1}>{t("toApprove.title")}</Title>
      <ToApproveContainer open={siteId && requestId ? { siteId, requestId } : undefined} />
    </Stack>
  );
};

export default ToApproveSection;
