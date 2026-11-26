/**
 * Catalogue des permissions du lot « demandes de matériaux » (contrat `docs/api/demandes-materiaux-livraisons.md`, ADR 0012) :
 * `Ressource.Action`. Le serveur renvoie la liste de l'utilisateur dans `GET /auth/me` ; le client s'en sert seulement pour
 * **ne pas afficher** ce qui est interdit (le serveur refuse de toute façon). Aucune permission n'est déduite du rôle.
 */
export const MATERIAL_PERMISSIONS = [
  "Products.View",
  "Products.Create",
  "Products.Update",
  "Suppliers.View",
  "Suppliers.Create",
  "Suppliers.Update",
  "SupplierPhone.View",
  "Prices.View",
  "Requests.View",
  "Requests.Create",
  "Requests.Update",
  "Requests.UpdateAny",
  "Requests.Approve",
  "Requests.Cancel",
  "Requests.CancelAny",
  "Requests.Receive",
  "Requests.Settle",
  "Requests.Archive",
  "Requests.LinkProduct",
  "Orders.Create",
  "Orders.Update",
  "Orders.Cancel",
  "Deliveries.View",
  "Deliveries.Create",
  "Deliveries.Update",
  "Deliveries.Attach",
  "DeliveryPhotos.Create",
  "DeliveryPhotos.View",
] as const;

export type MaterialPermission = (typeof MATERIAL_PERMISSIONS)[number];

/**
 * Le suivi d'un chantier (cinq vues, totaux, montants) s'adresse à ceux qui gèrent l'approvisionnement : il suffit d'une de ces
 * permissions. Le chef d'équipe n'a que « Mes demandes » (CA-MAT-013.8) ; le serveur répond aussi `GET /follow-up` à tout porteur de
 * `Requests.View`, donc ceci ne sert qu'à ne pas afficher une page qui n'est pas la sienne. À remplacer par une permission dédiée
 * si l'architecte la crée (question ouverte du rapport).
 */
export const FOLLOW_UP_PERMISSIONS: readonly MaterialPermission[] = [
  "Requests.UpdateAny",
  "Requests.Approve",
  "Requests.Settle",
  "Orders.Create",
  "Prices.View",
];
