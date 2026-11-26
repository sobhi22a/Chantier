import { selectUserAuthState, useAppChantierSelector } from "@chantier-frontend/state-store";

import type { MaterialPermission } from "../utilities/permissions";
import type { PermissionResourceKey } from "../utilities/resources";

export type PermissionAction = "View" | "Create" | "Update" | "Delete";

/** `can(PERMISSIONS_RESOURCES.SITES, "Create")` (format `claims`) ou `can("Requests.Approve")` (liste brute du serveur). */
export interface CanCheck {
  (permission: MaterialPermission): boolean;
  (resource: PermissionResourceKey, action?: PermissionAction): boolean;
}

/**
 * Permissions de l'utilisateur connecté (issues de `GET /auth/me`).
 * Sert à **ne pas afficher** ce qui est interdit (CA-003.1, CA-MAT-009.1) : le serveur refuse de toute façon.
 */
export const usePermissions = () => {
  const { claims, permissions } = useAppChantierSelector(selectUserAuthState);

  const can: CanCheck = (target: string, action?: PermissionAction): boolean =>
    target.includes(".")
      ? permissions.includes(target)
      : claims?.[target]?.[action ?? "View"] === true;

  return { can, isReady: claims !== null };
};
