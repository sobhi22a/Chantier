import type { MaterialRequestDetailResponse, MaterialRequestResponse, RequestDeliveryItem, RequestHistoryItem } from "@chantier-frontend/api-core";

export const REQUEST_STATUSES = ["Requested", "Validated", "Rejected", "Ordered", "PartiallyDelivered", "Delivered", "Received", "Cancelled"] as const;
export const REQUEST_PRIORITIES = ["Normal", "Urgent", "Blocking"] as const;
/** Vues de la liste des demandes (CA-MAT-002.5) ; les autres vues du serveur viennent avec le suivi (W7). */
export const REQUEST_VIEWS = ["toFollow", "received", "closed", "archived"] as const;
export type RequestViewCode = (typeof REQUEST_VIEWS)[number];

/** Les cinq vues du suivi d'un chantier (CA-MAT-013.1) : chacune est une vue du serveur et un compteur de `GET /follow-up`. */
export const FOLLOW_UP_VIEWS = ["toApprove", "toOrder", "expected", "late", "toReceive"] as const;
export type FollowUpView = (typeof FOLLOW_UP_VIEWS)[number];
export const isFollowUpView = (value: string | null): value is FollowUpView => FOLLOW_UP_VIEWS.some((view) => view === value);

export const isRequestView = (value: string | null): value is RequestViewCode => REQUEST_VIEWS.some((view) => view === value);

/**
 * Détail d'une demande : le générateur d'OpenAPI rend tous les champs du détail facultatifs (héritage de schéma).
 * Le serveur les renvoie toujours : on les relit comme une demande complète plus son historique.
 */
export type RequestDetail = MaterialRequestResponse & { history?: RequestHistoryItem[]; deliveries?: RequestDeliveryItem[] | null };

export const asRequestDetail = (response: MaterialRequestDetailResponse): RequestDetail => response as RequestDetail;

/** Demandes dont l'état est définitif : les seules qu'on archive (CA-MAT-014.1). */
export const ARCHIVABLE_STATUSES: readonly string[] = ["Rejected", "Cancelled", "Received"];
export const OPEN_STATUSES: readonly string[] = ["Requested", "Validated", "Ordered", "PartiallyDelivered", "Delivered"];

/** Regroupe des demandes par chantier : les lots (valider, archiver) sont des routes de chantier. */
export const groupBySite = <T extends { siteId: string }>(requests: readonly T[]): Map<string, T[]> => {
  const grouped = new Map<string, T[]>();
  for (const request of requests) grouped.set(request.siteId, [...(grouped.get(request.siteId) ?? []), request]);
  return grouped;
};
