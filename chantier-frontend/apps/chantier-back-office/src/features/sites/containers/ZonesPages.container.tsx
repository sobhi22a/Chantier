import type { ReactNode } from "react";

import { useZonesListQuery, type ZoneResponse } from "@chantier-frontend/api-core";

export interface ZonesPagesState {
  /** Toutes les zones chargées jusqu'ici (pages déjà lues comprises). */
  zones: ZoneResponse[];
  isLoading: boolean;
  error: unknown;
  refetch: () => void;
}

interface ZonesPagesProps {
  siteId: string;
  includeArchived: boolean;
  render: (state: ZonesPagesState) => ReactNode;
  /** Interne : curseur de la page à lire et zones des pages précédentes. */
  cursor?: string;
  previous?: ZoneResponse[];
}

const PAGE_SIZE = 200;

/**
 * Lit les zones d'un chantier page après page (curseur du serveur) sans effet : chaque page est une requête
 * RTK Query mise en cache, la suivante est rendue dès que `nextCursor` est connu. Une modification de zone
 * invalide l'étiquette du chantier : toutes les pages sont relues.
 */
export const ZonesPagesContainer = ({ siteId, includeArchived, render, cursor, previous = [] }: ZonesPagesProps) => {
  const { data, isError, error, refetch } = useZonesListQuery({
    siteId,
    includeArchived: includeArchived || undefined,
    pageSize: PAGE_SIZE,
    cursor,
  });
  const zones = [...previous, ...(data?.items ?? [])];

  if (data?.nextCursor) {
    return (
      <ZonesPagesContainer
        siteId={siteId}
        includeArchived={includeArchived}
        cursor={data.nextCursor}
        previous={zones}
        render={render}
      />
    );
  }

  return <>{render({ zones, isLoading: !data && !isError, error: isError ? error : undefined, refetch: () => void refetch() })}</>;
};
