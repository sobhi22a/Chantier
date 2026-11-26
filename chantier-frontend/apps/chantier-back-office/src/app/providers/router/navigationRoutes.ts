import { AUTHENTICATION_ROUTES } from "@chantier-frontend/authentication";

/** Chemins du back-office (ADR 0007) : `/sign-in`, `/`, `/sites`, `/materials/*`, `/catalog/*`, `/unauthorized`. */
export const BACK_OFFICE_ROUTES = {
  BASE: AUTHENTICATION_ROUTES.BASE,
  SIGN_IN: AUTHENTICATION_ROUTES.SIGN_IN,
  CHANGE_PASSWORD: AUTHENTICATION_ROUTES.CHANGE_PASSWORD,
  UNAUTHORIZED: AUTHENTICATION_ROUTES.UNAUTHORIZED,
  SITES: "/sites",
  SITE_DETAIL: "/sites/:siteId",
  MATERIAL_REQUESTS: "/materials/requests",
  MATERIAL_TO_APPROVE: "/materials/to-approve",
  MATERIAL_TO_ORDER: "/materials/to-order",
  MATERIAL_DELIVERIES: "/materials/deliveries",
  MATERIAL_FOLLOW_UP: "/materials/follow-up",
  CATALOG_PRODUCTS: "/catalog/products",
  CATALOG_SUPPLIERS: "/catalog/suppliers",
} as const;

export type BackOfficeRouteKeysTypes = keyof typeof BACK_OFFICE_ROUTES;

export const siteDetailPath = (siteId: string): string => `${BACK_OFFICE_ROUTES.SITES}/${siteId}`;

/**
 * Fiche d'une demande ou d'une livraison ouverte dans un tiroir au-dessus de sa liste : `/materials/requests/:siteId/:requestId`
 * (lien partageable). `search` conserve les filtres de la liste.
 */
export const requestDetailPath = (base: string, siteId: string, requestId: string, search = ""): string =>
  `${base}/${siteId}/${requestId}${search}`;

/** Nouvelle livraison, éventuellement pour une demande : la liste des livraisons ouvre son formulaire (`?create=1`, lien partageable). */
export const newDeliveryPath = (siteId?: string, requestId?: string): string => {
  const params = new URLSearchParams({ create: "1" });
  if (siteId) params.set("siteId", siteId);
  if (requestId) params.set("requestId", requestId);
  return `${BACK_OFFICE_ROUTES.MATERIAL_DELIVERIES}?${params.toString()}`;
};
