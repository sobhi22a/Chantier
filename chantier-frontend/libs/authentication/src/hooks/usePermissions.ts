import { selectUserAuthState, useAppChantierSelector } from "@chantier-frontend/state-store";

import type { PermissionResourceKey } from "../utilities/resources";

export type PermissionAction = "View" | "Create" | "Update" | "Delete";

/**
 * Permissions de l'utilisateur connecté (issues de `GET /auth/me`).
 * Sert à **ne pas afficher** ce qui est interdit (CA-003.1) : le serveur refuse de toute façon.
 */
export const usePermissions = () => {
  const { claims } = useAppChantierSelector(selectUserAuthState);

  const can = (resource: PermissionResourceKey, action: PermissionAction = "View"): boolean =>
    claims?.[resource]?.[action] === true;

  return { can, isReady: claims !== null };
};
