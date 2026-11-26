import { useAuthMeQuery, type CrossSiteRequestsListApiArg, type Priority } from "@chantier-frontend/api-core";

import { useUrlFilters } from "../../../shared/hooks/useUrlFilters";
import { isRequestView, REQUEST_PRIORITIES, type RequestViewCode } from "../types/requestTypes";

export const REQUESTS_PAGE_SIZE = 20;

const isPriority = (value: string | null): value is Priority => REQUEST_PRIORITIES.some((priority) => priority === value);
const isDateOnly = (value: string | null): value is string => value !== null && /^\d{4}-\d{2}-\d{2}$/.test(value);

export interface RequestFilterState {
  view: RequestViewCode;
  q: string;
  siteId: string;
  priority: Priority | undefined;
  productId: string;
  zoneId: string;
  from: string | null;
  to: string | null;
  mine: boolean;
  sort: string;
  page: number;
}

/**
 * Filtres, vue, tri et page d'une liste de demandes, lus dans l'URL (lien partageable, CA-MAT-002) et convertis en
 * paramètres de `GET /requests`. Le chef d'équipe voit « Mes demandes » par défaut (`mine=0` pour tout voir).
 */
export const useRequestFilters = (options: { fixedView?: string; defaultSort?: string; pageSize?: number } = {}) => {
  const { params, update, page } = useUrlFilters();
  const { data: me } = useAuthMeQuery();

  const viewParam = params.get("view");
  const priorityParam = params.get("priority");
  const fromParam = params.get("from");
  const toParam = params.get("to");
  const mineParam = params.get("mine");
  const defaultMine = me?.role === "ChefEquipe" && options.fixedView === undefined;

  const state: RequestFilterState = {
    view: isRequestView(viewParam) ? viewParam : "toFollow",
    q: params.get("q") ?? "",
    siteId: params.get("siteId") ?? "",
    priority: isPriority(priorityParam) ? priorityParam : undefined,
    productId: params.get("productId") ?? "",
    zoneId: params.get("zoneId") ?? "",
    from: isDateOnly(fromParam) ? fromParam : null,
    to: isDateOnly(toParam) ? toParam : null,
    mine: mineParam === "1" || (mineParam === null && defaultMine),
    sort: params.get("sort") ?? options.defaultSort ?? "",
    page,
  };

  const query: CrossSiteRequestsListApiArg = {
    view: options.fixedView ?? state.view,
    siteId: state.siteId || undefined,
    priority: state.priority,
    productId: state.productId || undefined,
    // Une zone n'a de sens que dans un chantier : le filtre est ignoré sans chantier.
    zoneId: state.siteId && state.zoneId ? state.zoneId : undefined,
    from: state.from ?? undefined,
    to: state.to ?? undefined,
    q: state.q || undefined,
    mine: state.mine || undefined,
    sort: state.sort || undefined,
    page: state.page,
    pageSize: options.pageSize ?? REQUESTS_PAGE_SIZE,
  };

  const hasFilters =
    state.q !== "" || state.siteId !== "" || state.priority !== undefined || state.productId !== "" || state.zoneId !== "" || state.from !== null || state.to !== null || (state.mine && mineParam === "1");

  return { state, query, update, params, hasFilters, mineParam };
};
