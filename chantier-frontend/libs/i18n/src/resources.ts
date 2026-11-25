import arAuth from "./locales/ar/auth.json";
import arCommon from "./locales/ar/common.json";
import arErrors from "./locales/ar/errors.json";
import arSites from "./locales/ar/sites.json";
import frAuth from "./locales/fr/auth.json";
import frCommon from "./locales/fr/common.json";
import frErrors from "./locales/fr/errors.json";
import frSites from "./locales/fr/sites.json";

export const NAMESPACES = ["common", "auth", "sites", "errors"] as const;
export type Namespace = (typeof NAMESPACES)[number];

/** Le français fait référence pour les types des clés ; l'arabe doit avoir les mêmes clés (test de parité). */
export const resourcesFr = { common: frCommon, auth: frAuth, sites: frSites, errors: frErrors } as const;
export const resourcesAr = { common: arCommon, auth: arAuth, sites: arSites, errors: arErrors } as const;

export const resources = {
  fr: resourcesFr,
  ar: resourcesAr,
} as const;
