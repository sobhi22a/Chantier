import { AUTHENTICATION_ROUTES } from "@chantier-frontend/authentication";

/** Chemins du back-office (ADR 0007) : `/sign-in`, `/`, `/sites`, `/sites/:siteId`, `/unauthorized`. */
export const BACK_OFFICE_ROUTES = {
  BASE: AUTHENTICATION_ROUTES.BASE,
  SIGN_IN: AUTHENTICATION_ROUTES.SIGN_IN,
  CHANGE_PASSWORD: AUTHENTICATION_ROUTES.CHANGE_PASSWORD,
  UNAUTHORIZED: AUTHENTICATION_ROUTES.UNAUTHORIZED,
  SITES: "/sites",
  SITE_DETAIL: "/sites/:siteId",
} as const;

export type BackOfficeRouteKeysTypes = keyof typeof BACK_OFFICE_ROUTES;

export const siteDetailPath = (siteId: string): string => `${BACK_OFFICE_ROUTES.SITES}/${siteId}`;
