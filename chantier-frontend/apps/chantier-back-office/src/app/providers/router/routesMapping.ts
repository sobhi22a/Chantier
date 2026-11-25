import { PERMISSIONS_RESOURCES } from "@chantier-frontend/authentication";

import { BACK_OFFICE_ROUTES } from "./navigationRoutes";

/** Première route autorisée à l'ouverture de `/` : ordre = priorité (au socle, une seule entrée). */
export const DEFAULT_ROUTES = [{ resourceKey: PERMISSIONS_RESOURCES.SITES, path: BACK_OFFICE_ROUTES.SITES }] as const;
