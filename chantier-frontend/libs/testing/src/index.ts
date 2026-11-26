// Outils de test partagés (jamais importés par le code applicatif) : faux serveur MSW et données fictives.
export { API_BASE_URL, apiUrl, problem, server, setupMockServer } from "./server";
export {
  DELIVERY_LIV006_ID,
  MATERIAL_MATRIX,
  PERMISSIONS_BY_ROLE,
  PHOTO_BL_ID,
  PRODUCT_CEMENT_ID,
  PRODUCT_SAND_ID,
  REQUEST_DEM009_ID,
  SITE_OL40_ID,
  SITE_UV18_ID,
  SUPPLIER_SIGMA_ID,
  makeDelivery,
  makeDeliveryDetail,
  makeFollowUp,
  makeMaterialSettings,
  makeMe,
  makeMember,
  makeOrder,
  makePhoto,
  makeProduct,
  makeRequest,
  makeRequestDetail,
  makeSite,
  makeSupplier,
  makeZone,
} from "./fixtures";
export type { TestRole } from "./fixtures";
