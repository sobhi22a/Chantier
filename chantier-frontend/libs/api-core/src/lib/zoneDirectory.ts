import type { CursorPageOfZoneResponse, ZoneResponse } from "../generated/chantierApi";
import { ApplicationApiService } from "./ApplicationApi.service";
import { BACK_OFFICE_ENTITY_TAGS } from "./entitiesTags.config";

const PAGE_SIZE = 200;
/** 5 pages au plus (1 000 zones) : au-delà, les zones absentes se lisent une à une (cache RTK par identifiant). */
const MAX_PAGES = 5;

export interface ZoneDirectoryArg {
  siteId: string;
}

/**
 * Annuaire des zones d'un chantier, lu par pages groupées (200 zones par appel) et partagé par toutes les lignes d'une liste :
 * une liste de 50 demandes ne fait plus 50 lectures `GET /zones/{id}` (revue R2-06, limiteur de 300 requêtes par minute).
 * Il porte l'étiquette de la liste des zones du chantier : toute création, modification ou archivage de zone le relit.
 * Les zones archivées y figurent (une ancienne demande garde son libellé).
 */
export const zoneDirectoryApi = ApplicationApiService.injectEndpoints({
  endpoints: (build) => ({
    zoneDirectory: build.query<Record<string, ZoneResponse>, ZoneDirectoryArg>({
      async queryFn({ siteId }, _api, _extra, baseQuery) {
        const directory: Record<string, ZoneResponse> = {};
        let cursor: string | undefined;
        for (let page = 0; page < MAX_PAGES; page += 1) {
          const result = await baseQuery({
            url: `/api/v1/sites/${siteId}/zones`,
            params: { pageSize: PAGE_SIZE, includeArchived: true, ...(cursor ? { cursor } : {}) },
          });
          if (result.error) return { error: result.error };
          const body = result.data as CursorPageOfZoneResponse;
          for (const zone of body.items) directory[zone.id] = zone;
          if (!body.nextCursor) break;
          cursor = body.nextCursor;
        }
        return { data: directory };
      },
      providesTags: (_result, _error, arg) => [{ type: BACK_OFFICE_ENTITY_TAGS.ZONES, id: `SITE-${arg.siteId}` }],
    }),
  }),
});

export const { useZoneDirectoryQuery } = zoneDirectoryApi;
