import { Stack, Title } from "@mantine/core";
import { useTranslation } from "react-i18next";
import { useParams } from "react-router-dom";

import { DeliveriesBrowserContainer } from "../containers/DeliveriesBrowser.container";

/** Page « Livraisons » (route `/materials/deliveries`) ; `:siteId/:deliveryId` ouvre le tiroir de détail. */
const DeliveriesSection = () => {
  const { t } = useTranslation("materials");
  const { siteId, deliveryId } = useParams<{ siteId: string; deliveryId: string }>();

  return (
    <Stack gap="md">
      <title>{t("deliveries.title")}</title>
      <Title order={1}>{t("deliveries.title")}</Title>
      <DeliveriesBrowserContainer open={siteId && deliveryId ? { siteId, deliveryId } : undefined} />
    </Stack>
  );
};

export default DeliveriesSection;
