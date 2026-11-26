import type { MaterialRequestResponse } from "@chantier-frontend/api-core";
import type { CanCheck } from "@chantier-frontend/authentication";

import { ARCHIVABLE_STATUSES, OPEN_STATUSES } from "./requestTypes";

export interface RequestActionAvailability {
  edit: boolean;
  /** Produit, quantité, unité et zone modifiables (demande encore « Demandée »). */
  editAllFields: boolean;
  cancel: boolean;
  approve: boolean;
  linkProduct: boolean;
  archive: boolean;
  restore: boolean;
  /** Commander une demande validée (Achats). */
  order: boolean;
  editOrder: boolean;
  /** Annuler une commande sans livraison : la demande redevient « Validée ». */
  cancelOrder: boolean;
  /** Accepter le manque d'une demande livrée partiellement. */
  settle: boolean;
  /** Réceptionner une demande livrée (chef de chantier). */
  receive: boolean;
  /** Saisir une livraison pour cette demande (commandée, livrée partiellement ou validée : livraison avant commande). */
  registerDelivery: boolean;
}

const NONE: RequestActionAvailability = {
  edit: false,
  editAllFields: false,
  cancel: false,
  approve: false,
  linkProduct: false,
  archive: false,
  restore: false,
  order: false,
  editOrder: false,
  cancelOrder: false,
  settle: false,
  receive: false,
  registerDelivery: false,
};

/**
 * Actions proposées pour une demande (CA-MAT-009.1) : une action interdite n'est pas affichée. Le serveur refuse de toute
 * façon (INTERDIT, TRANSITION_INTERDITE) : ceci ne sert qu'à ne pas montrer ce qui échouera.
 * Règle de ressource : « la sienne seulement » pour modifier (Requests.Update) et annuler (Requests.Cancel).
 */
export const requestActionsFor = (request: MaterialRequestResponse, can: CanCheck, userId: string | null): RequestActionAvailability => {
  if (request.archivedAt) return { ...NONE, restore: can("Requests.Archive") };

  const own = userId !== null && request.requestedById === userId;
  const isRequested = request.status === "Requested";
  const editableAfterApproval = ["Validated", "Ordered", "PartiallyDelivered"].includes(request.status);

  return {
    edit: (isRequested && ((can("Requests.Update") && own) || can("Requests.UpdateAny"))) || (editableAfterApproval && can("Requests.UpdateAny")),
    editAllFields: isRequested,
    cancel: (isRequested || request.status === "Validated") && (can("Requests.CancelAny") || (can("Requests.Cancel") && own)),
    approve: isRequested && can("Requests.Approve"),
    linkProduct: request.product.productId === null && OPEN_STATUSES.includes(request.status) && can("Requests.LinkProduct"),
    archive: ARCHIVABLE_STATUSES.includes(request.status) && can("Requests.Archive"),
    restore: false,
    order: request.status === "Validated" && !request.order && can("Orders.Create"),
    editOrder: Boolean(request.order) && (request.status === "Ordered" || request.status === "PartiallyDelivered") && can("Orders.Update"),
    // Le serveur refuse l'annulation dès qu'une livraison existe (TRANSITION_INTERDITE) : « Commandée » = aucune livraison retenue.
    cancelOrder: Boolean(request.order) && request.status === "Ordered" && can("Orders.Cancel"),
    settle: request.status === "PartiallyDelivered" && can("Requests.Settle"),
    receive: request.status === "Delivered" && can("Requests.Receive"),
    registerDelivery: ["Validated", "Ordered", "PartiallyDelivered"].includes(request.status) && can("Deliveries.Create"),
  };
};
