import { Stack, Title } from "@mantine/core";
import { useTranslation } from "react-i18next";

import { ProductsBrowserContainer } from "../containers/ProductsBrowser.container";

/** Page « Produits du catalogue » (route `/catalog/products`). */
const ProductsSection = () => {
  const { t } = useTranslation("catalog");

  return (
    <Stack gap="md">
      <title>{t("products.title")}</title>
      <Title order={1}>{t("products.title")}</Title>
      <ProductsBrowserContainer />
    </Stack>
  );
};

export default ProductsSection;
