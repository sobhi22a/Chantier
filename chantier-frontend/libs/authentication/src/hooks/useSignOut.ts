import { useNavigate } from "react-router-dom";

import { ApplicationApiService, useApiErrorMessage, useAuthLogoutMutation } from "@chantier-frontend/api-core";
import { useAppChantierDispatch } from "@chantier-frontend/state-store";
import { useNotifications } from "@chantier-frontend/user-interface";

import { AUTHENTICATION_ROUTES } from "../utilities/resources";

/**
 * Déconnexion : le serveur ferme la session, puis tout le cache de données est vidé
 * (un autre utilisateur du même navigateur ne voit rien de la session précédente).
 */
export const useSignOut = () => {
  const [logout, { isLoading }] = useAuthLogoutMutation();
  const dispatch = useAppChantierDispatch();
  const navigate = useNavigate();
  const { showNotification } = useNotifications();
  const { getMessage } = useApiErrorMessage();

  const signOut = async (): Promise<void> => {
    try {
      await logout({ logoutRequest: {} }).unwrap();
    } catch (error) {
      showNotification({ type: "error", message: getMessage(error) });
      return;
    }
    dispatch(ApplicationApiService.util.resetApiState());
    void navigate(AUTHENTICATION_ROUTES.SIGN_IN, { replace: true });
  };

  return { signOut, isSigningOut: isLoading };
};
