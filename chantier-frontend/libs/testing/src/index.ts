// Outils de test partagés (jamais importés par le code applicatif) : faux serveur MSW et données fictives.
export { API_BASE_URL, apiUrl, problem, server, setupMockServer } from "./server";
export {
  PERMISSIONS_BY_ROLE,
  SITE_OL40_ID,
  SITE_UV18_ID,
  makeMe,
  makeMember,
  makeSite,
  makeZone,
} from "./fixtures";
export type { TestRole } from "./fixtures";
