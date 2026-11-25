import { Center, Loader, Overlay } from "@mantine/core";
import { useTranslation } from "react-i18next";

import { selectIsNetworkLoading } from "@chantier-frontend/api-core";
import { useAppChantierSelector } from "@chantier-frontend/state-store";

/** Voile de chargement affiché tant qu'une requête vers l'API est en cours. */
export const GlobalLoader = () => {
  const { t } = useTranslation("common");
  const loading = useAppChantierSelector(selectIsNetworkLoading);

  if (!loading) return null;

  return (
    <Overlay zIndex={9999} backgroundOpacity={0.4} color="#000" role="status" aria-live="polite">
      <Center h="100%">
        <Loader size="lg" aria-label={t("state.loading")} />
      </Center>
    </Overlay>
  );
};

export default GlobalLoader;
