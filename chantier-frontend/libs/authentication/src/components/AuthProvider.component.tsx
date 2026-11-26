import { useEffect, useRef, type ReactNode } from "react";
import { useTranslation } from "react-i18next";

import { ApplicationApiService, useApiErrorMessage, useAuthMeQuery, isApiError } from "@chantier-frontend/api-core";
import { isLanguage, toLanguage } from "@chantier-frontend/i18n";
import { useAppChantierDispatch } from "@chantier-frontend/state-store";
import { GenericErrorComponent, GenericLoaderComponent } from "@chantier-frontend/user-interface";

/**
 * Charge la session (`GET /auth/me`) et applique la langue du compte.
 * Une absence de session (401) n'est pas une erreur : les gardes redirigent vers la connexion.
 * Une vraie panne (réseau, serveur) est affichée avec « Réessayer ».
 */
const AuthProviderComponent = ({ children }: { children: ReactNode }) => {
  const { i18n } = useTranslation();
  const { data: me, isLoading, isError, error, refetch } = useAuthMeQuery();
  const { describe } = useApiErrorMessage();
  const dispatch = useAppChantierDispatch();

  // Cache de données (prix, photos `blob:`) : vidé dès que la session se termine sans déconnexion volontaire (401 définitif, expiration)
  // ou qu'un autre compte se connecte dans le même onglet (revue R3-03). On ne réagit qu'à une TRANSITION : vider le cache relit
  // `GET /auth/me`, et réagir à l'état « sans profil » provoquerait une boucle.
  const knownUser = useRef<string | null>(null);
  const sessionEnded = isError && isApiError(error) && error.status === 401;
  const currentId = isError ? undefined : me?.id;
  useEffect(() => {
    const previous = knownUser.current;
    if (currentId) {
      knownUser.current = currentId;
      if (previous !== null && previous !== currentId) dispatch(ApplicationApiService.util.resetApiState());
    } else if (sessionEnded && previous !== null) {
      knownUser.current = null;
      dispatch(ApplicationApiService.util.resetApiState());
    }
  }, [currentId, sessionEnded, dispatch]);

  // Synchronisation avec un système externe (i18next) : la langue enregistrée sur le compte s'applique UNE fois par
  // ouverture de session. Ensuite, le choix fait à l'écran l'emporte (il est mémorisé sur le compte par l'en-tête).
  const userId = isError ? undefined : me?.id;
  const accountLanguage = isError ? undefined : me?.language;
  const appliedFor = useRef<string | null>(null);
  useEffect(() => {
    if (!userId) {
      appliedFor.current = null;
      return;
    }
    if (appliedFor.current === userId) return;
    appliedFor.current = userId;
    if (isLanguage(accountLanguage) && toLanguage(i18n.language) !== accountLanguage) {
      void i18n.changeLanguage(accountLanguage);
    }
  }, [userId, accountLanguage, i18n]);

  if (isLoading) return <GenericLoaderComponent height="100dvh" />;

  const sessionAbsent = isApiError(error) && error.status === 401;
  if (isError && !sessionAbsent) {
    const { message, reference } = describe(error);
    return <GenericErrorComponent message={message} reference={reference} onRetry={() => void refetch()} />;
  }

  return children;
};

export default AuthProviderComponent;
