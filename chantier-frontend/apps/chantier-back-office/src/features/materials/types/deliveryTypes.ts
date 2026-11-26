import type { DeliveryDetailResponse, DeliveryResponse, RequestHistoryItem, UnattachedReason } from "@chantier-frontend/api-core";

/** Onglets rapides de la liste des livraisons (CA-MAT-011.8, 007.7, 006.6) : chacun correspond à un filtre du serveur. */
export const DELIVERY_TABS = ["all", "unattached", "missingNote", "withReserve"] as const;
export type DeliveryTab = (typeof DELIVERY_TABS)[number];
export const isDeliveryTab = (value: string | null): value is DeliveryTab => DELIVERY_TABS.some((tab) => tab === value);

export const DELIVERY_STATUSES = ["Recorded", "Cancelled"] as const;
export const UNATTACHED_REASONS: readonly UnattachedReason[] = ["NoRequestChosen", "RequestNotOpen", "RequestMissing"];

/** Unités de masse convertibles entre elles avec la masse du sac (sac, kg, T) : les seules conversions autorisées. */
export const MASS_UNITS: readonly string[] = ["sac", "kg", "t"];

export const DELIVERY_NOTE_MAX = 30;
export const FREE_NAME_MIN = 3;
export const FREE_NAME_MAX = 100;

/**
 * Détail d'une livraison : le générateur d'OpenAPI rend tous les champs du détail facultatifs (héritage de schéma).
 * Le serveur les renvoie toujours : on les relit comme une livraison complète plus son historique.
 */
export type DeliveryDetail = DeliveryResponse & { history?: RequestHistoryItem[] };

export const asDeliveryDetail = (response: DeliveryDetailResponse): DeliveryDetail => response as DeliveryDetail;

/** Une livraison annulée n'est plus modifiable (`TRANSITION_INTERDITE`) ; on ne propose pas ce qui échouera. */
export const isCancelled = (delivery: Pick<DeliveryResponse, "status">): boolean => delivery.status === "Cancelled";
