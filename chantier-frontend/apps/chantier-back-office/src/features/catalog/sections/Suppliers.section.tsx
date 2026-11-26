import { Stack, Title } from "@mantine/core";
import { useTranslation } from "react-i18next";

import { SuppliersBrowserContainer } from "../containers/SuppliersBrowser.container";

/** Page « Fournisseurs » (route `/catalog/suppliers`). */
const SuppliersSection = () => {
  const { t } = useTranslation("catalog");

  return (
    <Stack gap="md">
      <title>{t("suppliers.title")}</title>
      <Title order={1}>{t("suppliers.title")}</Title>
      <SuppliersBrowserContainer />
    </Stack>
  );
};

export default SuppliersSection;
