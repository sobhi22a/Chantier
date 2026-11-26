import type { ReactNode } from "react";
import { Navigate } from "react-router-dom";

import { usePermissions, type PermissionAction } from "../hooks/usePermissions";
import type { MaterialPermission } from "../utilities/permissions";
import { AUTHENTICATION_ROUTES, type PermissionResourceKey } from "../utilities/resources";

type PermissionsGuardProps = { children: ReactNode } & (
  | { resourceKey: PermissionResourceKey; action?: PermissionAction; permission?: never; anyOf?: never }
  | { permission: MaterialPermission; resourceKey?: never; action?: never; anyOf?: never }
  | { anyOf: readonly MaterialPermission[]; permission?: never; resourceKey?: never; action?: never }
);

/**
 * Laisse passer si l'utilisateur a la permission (`resourceKey` + `action`, une permission nommée comme
 * `Requests.Approve`, ou l'une de plusieurs avec `anyOf`), sinon l'envoie sur `/unauthorized` (le serveur refuse aussi).
 */
const PermissionsGuardComponent = ({ resourceKey, action = "View", permission, anyOf, children }: PermissionsGuardProps) => {
  const { can } = usePermissions();
  const allowed = anyOf ? anyOf.some((candidate) => can(candidate)) : permission ? can(permission) : can(resourceKey as PermissionResourceKey, action);
  return allowed ? children : <Navigate to={AUTHENTICATION_ROUTES.UNAUTHORIZED} replace />;
};

export default PermissionsGuardComponent;
