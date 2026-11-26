import { Text } from "@mantine/core";
import { useTranslation } from "react-i18next";

import { useQuantityFormatter, type QuantityValue } from "@chantier-frontend/i18n";

/** « = 200 sacs » : la quantité d'une livraison dans l'unité de la demande, telle que le serveur l'a calculée (jamais additionnée). */
export const EquivalentQuantity = ({ quantity }: { quantity: QuantityValue }) => {
  const { t } = useTranslation("materials");
  const { quantityText } = useQuantityFormatter();
  return (
    <Text size="xs" c="dimmed" component="div">
      {t("detail.equivalentTo", { quantity: quantityText(quantity) })}
    </Text>
  );
};
