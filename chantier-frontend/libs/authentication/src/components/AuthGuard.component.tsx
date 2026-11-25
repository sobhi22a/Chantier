import type { ReactNode } from "react";
import { Navigate, useLocation } from "react-router-dom";

import { selectUserAuthState, useAppChantierSelector } from "@chantier-frontend/state-store";

import { AUTHENTICATION_ROUTES } from "../utilities/resources";

/**
 * - `authenticated` : session valide et mot de passe définitif (sinon connexion, ou changement de mot de passe).
 * - `authenticated-any` : session valide, même avec un mot de passe provisoire (page de changement de mot de passe).
 * - `anonymous` : page de connexion ; un utilisateur déjà connecté est renvoyé là d'où il venait.
 */
export type AuthGuardAccess = "authenticated" | "authenticated-any" | "anonymous";

interface LocationState {
  from?: string;
}

const AuthGuardComponent = ({ access = "authenticated", children }: { access?: AuthGuardAccess; children: ReactNode }) => {
  const location = useLocation();
  // La session vient de la tranche Redux (alimentée par `GET /auth/me`) : s'abonner ici à la requête
  // la relancerait à chaque montage tant qu'elle est en erreur (RTK Query relit une requête échouée).
  const { isAuthenticated, mustChangePassword } = useAppChantierSelector(selectUserAuthState);
  const session = isAuthenticated ? { mustChangePassword } : undefined;

  if (access === "anonymous") {
    if (!session) return children;
    if (session.mustChangePassword) return <Navigate to={AUTHENTICATION_ROUTES.CHANGE_PASSWORD} replace />;
    const from = (location.state as LocationState | null)?.from;
    return <Navigate to={from ?? AUTHENTICATION_ROUTES.BASE} replace />;
  }

  if (!session) {
    const from = `${location.pathname}${location.search}`;
    return <Navigate to={AUTHENTICATION_ROUTES.SIGN_IN} replace state={{ from } satisfies LocationState} />;
  }

  if (access === "authenticated" && session.mustChangePassword) {
    return <Navigate to={AUTHENTICATION_ROUTES.CHANGE_PASSWORD} replace />;
  }

  return children;
};

export default AuthGuardComponent;
