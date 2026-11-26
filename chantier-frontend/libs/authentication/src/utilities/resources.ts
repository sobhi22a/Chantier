export const AUTHENTICATION_ROUTES = {
  BASE: "/",
  SIGN_IN: "/sign-in",
  CHANGE_PASSWORD: "/change-password",
  UNAUTHORIZED: "/unauthorized",
  WILD_CARD: "*",
} as const;

export type AuthRouteKeysTypes = keyof typeof AUTHENTICATION_ROUTES;

/**
 * Ressources du catalogue de permissions du serveur (`Ressource.Action`, ADR 0005).
 * Le serveur reste juge : ces clés servent à masquer ce que l'utilisateur ne peut pas faire.
 */
export const PERMISSIONS_RESOURCES = {
  SITES: "Sites",
  ZONES: "Zones",
  SITE_MEMBERS: "SiteMembers",
  ALL_SITES: "AllSites",
  CONTRACT_AMOUNT: "ContractAmount",
  PRODUCTS: "Products",
  SUPPLIERS: "Suppliers",
  REQUESTS: "Requests",
} as const;

export type PermissionResourceKey = (typeof PERMISSIONS_RESOURCES)[keyof typeof PERMISSIONS_RESOURCES];
