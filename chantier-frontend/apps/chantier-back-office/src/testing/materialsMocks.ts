import { http, HttpResponse } from "msw";

import type {
  DeliveryDetailResponse,
  DeliveryResponse,
  FollowUpResponse,
  MaterialRequestDetailResponse,
  MaterialRequestResponse,
  ProductResponse,
  SiteResponse,
  SupplierResponse,
  ZoneResponse,
} from "@chantier-frontend/api-core";
import {
  SITE_OL40_ID,
  SITE_UV18_ID,
  apiUrl,
  makeDelivery,
  makeDeliveryDetail,
  makeFollowUp,
  makeMaterialSettings,
  makeProduct,
  makeRequest,
  makeRequestDetail,
  makeSite,
  makeSupplier,
  makeZone,
  server,
} from "@chantier-frontend/testing";

export const paged = <T>(items: T[], totalCount = items.length, page = 1, pageSize = 20) => ({ items, page, pageSize, totalCount });

export interface MaterialsMockOptions {
  requests?: MaterialRequestResponse[];
  totalCount?: number;
  products?: ProductResponse[];
  suppliers?: SupplierResponse[];
  sites?: SiteResponse[];
  zones?: ZoneResponse[];
  detail?: MaterialRequestDetailResponse;
  deliveries?: DeliveryResponse[];
  deliveryDetail?: DeliveryDetailResponse;
  followUp?: FollowUpResponse;
}

/** Lectures communes des écrans de matériaux : chantiers, zones, produits, réglages. Les listes de demandes se posent à part. */
export const mockMaterialsReads = (
  options: MaterialsMockOptions = {},
): { listRequests: URL[]; siteRequests: URL[]; listDeliveries: URL[]; followUpCalls: string[] } => {
  const listRequests: URL[] = [];
  const siteRequests: URL[] = [];
  const listDeliveries: URL[] = [];
  const followUpCalls: string[] = [];
  const zones = options.zones ?? [makeZone({ id: "00000000-0000-7000-8000-0000000000b1", block: "Bloc 01", elevation: 10.2, roomType: null, roomNumber: null })];
  server.use(
    http.get(apiUrl("/sites"), () =>
      HttpResponse.json(paged(options.sites ?? [makeSite(), makeSite({ id: SITE_OL40_ID, code: "CH-LOG-OL40", name: "40 logements", type: "Housing" })])),
    ),
    http.get(apiUrl("/sites/:siteId/zones"), () => HttpResponse.json({ items: zones, nextCursor: null })),
    http.get(apiUrl("/sites/:siteId/zones/:zoneId"), ({ params }) => {
      const zone = zones.find((candidate) => candidate.id === params["zoneId"]) ?? zones[0];
      return HttpResponse.json(zone);
    }),
    http.get(apiUrl("/products"), () => HttpResponse.json(paged(options.products ?? [makeProduct()]))),
    http.get(apiUrl("/products/:productId"), ({ params }) => {
      const product = (options.products ?? [makeProduct()]).find((candidate) => candidate.id === params["productId"]);
      return product ? HttpResponse.json(product) : new HttpResponse(null, { status: 404 });
    }),
    http.get(apiUrl("/suppliers"), () => HttpResponse.json(paged(options.suppliers ?? [makeSupplier()]))),
    http.get(apiUrl("/suppliers/:supplierId"), ({ params }) => {
      const supplier = (options.suppliers ?? [makeSupplier()]).find((candidate) => candidate.id === params["supplierId"]);
      return supplier ? HttpResponse.json(supplier) : new HttpResponse(null, { status: 404 });
    }),
    http.get(apiUrl("/settings/materials"), () => HttpResponse.json(makeMaterialSettings())),
    http.get(apiUrl("/requests"), ({ request }) => {
      listRequests.push(new URL(request.url));
      const items = options.requests ?? [makeRequest()];
      return HttpResponse.json(paged(items, options.totalCount ?? items.length));
    }),
    // Routes de chantier (liste d'un chantier, livraisons, suivi) : listes de demandes du suivi et des sélecteurs de livraison.
    http.get(apiUrl("/sites/:siteId/requests"), ({ request }) => {
      siteRequests.push(new URL(request.url));
      const items = options.requests ?? [makeRequest()];
      return HttpResponse.json(paged(items, options.totalCount ?? items.length));
    }),
    http.get(apiUrl("/sites/:siteId/requests/:requestId"), () => HttpResponse.json(options.detail ?? makeRequestDetail())),
    http.get(apiUrl("/sites/:siteId/deliveries"), ({ request }) => {
      listDeliveries.push(new URL(request.url));
      const items = options.deliveries ?? [makeDelivery()];
      return HttpResponse.json(paged(items, options.totalCount ?? items.length));
    }),
    http.get(apiUrl("/sites/:siteId/deliveries/:deliveryId"), () => HttpResponse.json(options.deliveryDetail ?? makeDeliveryDetail())),
    http.get(apiUrl("/sites/:siteId/follow-up"), ({ params }) => {
      followUpCalls.push(String(params["siteId"]));
      return HttpResponse.json(options.followUp ?? makeFollowUp());
    }),
  );
  return { listRequests, siteRequests, listDeliveries, followUpCalls };
};

export { SITE_UV18_ID };
