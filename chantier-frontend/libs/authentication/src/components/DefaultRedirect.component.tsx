import { Navigate } from "react-router-dom";

import { usePermissions } from "../hooks/usePermissions";
import { AUTHENTICATION_ROUTES, type PermissionResourceKey } from "../utilities/resources";

/** Envoie sur la première route que l'utilisateur a le droit de voir (ordre du tableau), sinon `/unauthorized`. */
const DefaultRedirectComponent = ({
  routes,
}: {
  routes: ReadonlyArray<{ resourceKey: PermissionResourceKey; path: string }>;
}) => {
  const { can } = usePermissions();
  const target = routes.find((route) => can(route.resourceKey, "View"));
  return <Navigate to={target?.path ?? AUTHENTICATION_ROUTES.UNAUTHORIZED} replace />;
};

export default DefaultRedirectComponent;
