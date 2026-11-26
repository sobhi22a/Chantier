import type { DeliveriesListApiArg, DeliveryStatus } from "@chantier-frontend/api-core";

import { useUrlFilters } from "../../../shared/hooks/useUrlFilters";
import { DELIVERY_STATUSES, isDeliveryTab, type DeliveryTab } from "../types/deliveryTypes";

export const DELIVERIES_PAGE_SIZE = 20;

const isStatus = (value: string | null): value is DeliveryStatus => DELIVERY_STATUSES.some((status) => status === value);
const isDateOnly = (value: string | null): value is string => value !== null && /^\d{4}-\d{2}-\d{2}$/.test(value);

export interface DeliveryFilterState {
  siteId: string;
  tab: DeliveryTab;
  status: DeliveryStatus | undefined;
  q: string;
  from: string | null;
  to: string | null;
  sort: string;
  page: number;
}

/**
 * Chantier, onglet rapide, filtres, tri et page de la liste des livraisons, lus dans l'URL (lien partageable, CA-MAT-011.8) et
 * convertis en paramètres de `GET /sites/{siteId}/deliveries`. La route est celle d'un chantier : `siteId` vient de l'URL ou,
 * à défaut, du chantier proposé par l'écran (`fallbackSiteId`, par exemple le seul chantier de l'utilisateur).
 */
export const useDeliveryFilters = (fallbackSiteId: string) => {
  const { params, update, page } = useUrlFilters();

  const tabParam = params.get("tab");
  const statusParam = params.get("status");
  const fromParam = params.get("from");
  const toParam = params.get("to");

  const state: DeliveryFilterState = {
    siteId: params.get("siteId") ?? fallbackSiteId,
    tab: isDeliveryTab(tabParam) ? tabParam : "all",
    status: isStatus(statusParam) ? statusParam : undefined,
    q: params.get("q") ?? "",
    from: isDateOnly(fromParam) ? fromParam : null,
    to: isDateOnly(toParam) ? toParam : null,
    sort: params.get("sort") ?? "",
    page,
  };

  const query: DeliveriesListApiArg = {
    siteId: state.siteId,
    unattached: state.tab === "unattached" ? true : undefined,
    missingNote: state.tab === "missingNote" ? true : undefined,
    withReserve: state.tab === "withReserve" ? true : undefined,
    status: state.status,
    q: state.q || undefined,
    from: state.from ?? undefined,
    to: state.to ?? undefined,
    sort: state.sort || undefined,
    page: state.page,
    pageSize: DELIVERIES_PAGE_SIZE,
  };

  const hasFilters = state.q !== "" || state.status !== undefined || state.from !== null || state.to !== null;

  return { state, query, update, params, hasFilters };
};
