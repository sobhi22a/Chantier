import type { ReactNode } from "react";
import { Navigate } from "react-router-dom";

import { usePermissions, type PermissionAction } from "../hooks/usePermissions";
import { AUTHENTICATION_ROUTES, type PermissionResourceKey } from "../utilities/resources";

/** Laisse passer si l'utilisateur a la permission, sinon l'envoie sur `/unauthorized` (le serveur refuse aussi). */
const PermissionsGuardComponent = ({
  resourceKey,
  action = "View",
  children,
}: {
  resourceKey: PermissionResourceKey;
  action?: PermissionAction;
  children: ReactNode;
}) => {
  const { can } = usePermissions();
  return can(resourceKey, action) ? children : <Navigate to={AUTHENTICATION_ROUTES.UNAUTHORIZED} replace />;
};

export default PermissionsGuardComponent;
