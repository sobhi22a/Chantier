import { chantierApi } from "../generated/chantierApi";
import { BACK_OFFICE_ENTITY_TAGS as TAGS } from "./entitiesTags.config";
import { queryCacheTagsProvider } from "./queryCacheTagsProvider";

/**
 * RTK Query invalide aussi après une mutation en ÉCHEC : sans ce garde-fou, un refus (mauvais mot de passe, 422…)
 * relancerait la lecture du profil ou des listes pour rien (et ferait clignoter l'écran).
 */
const onSuccess =
  <Arg>(tags: (arg: Arg) => readonly { type: (typeof TAGS)[keyof typeof TAGS]; id: string }[]) =>
  (_result: unknown, error: unknown, arg: Arg) =>
    error ? [] : [...tags(arg)];

const LIST = { id: "LIST" } as const;

/** Compteurs et totaux du suivi d'un chantier : ils changent avec tout statut de demande ou de livraison. */
const followUpTag = (siteId: string) => ({ type: TAGS.FOLLOW_UP, id: siteId });

/** Une action sur une demande relit sa fiche, toutes les listes (le statut change, donc la vue aussi) et le suivi du chantier. */
const requestTags = (arg: { siteId: string; requestId: string }) => [
  { type: TAGS.REQUESTS, id: arg.requestId },
  { type: TAGS.REQUESTS, ...LIST },
  followUpTag(arg.siteId),
];

/** Un lot relit chaque fiche concernée et les listes (même si une partie du lot est refusée : le résultat dit laquelle). */
const batchTags = (arg: { siteId: string; requestIdsBody: { requestIds: string[] } }) => [
  ...arg.requestIdsBody.requestIds.map((id) => ({ type: TAGS.REQUESTS, id })),
  { type: TAGS.REQUESTS, ...LIST },
  followUpTag(arg.siteId),
];

/**
 * Une commande change le statut, le reçu et les montants de la demande, et le montant de ses livraisons (nouveau prix) :
 * on relit la demande, les listes de demandes et de livraisons, et le suivi.
 */
const orderTags = (arg: { siteId: string; requestId: string }) => [...requestTags(arg), { type: TAGS.DELIVERIES, ...LIST }];

/**
 * Une livraison recalcule le statut de sa demande (dans les deux sens) : on relit la livraison, les livraisons, la demande
 * qu'elle touche (`requestId` de la réponse) et le suivi. Une livraison sans demande ne touche que les listes de demandes.
 */
const deliveryTags =
  <Arg extends { siteId: string }>(deliveryIdOf: (arg: Arg) => string | null) =>
  (result: { requestId?: string | null } | undefined, error: unknown, arg: Arg) => {
    if (error) return [];
    const deliveryId = deliveryIdOf(arg);
    return [
      ...(deliveryId ? [{ type: TAGS.DELIVERIES, id: deliveryId }] : []),
      { type: TAGS.DELIVERIES, ...LIST },
      { type: TAGS.REQUESTS, ...LIST },
      ...(result?.requestId ? [{ type: TAGS.REQUESTS, id: result.requestId }] : []),
      followUpTag(arg.siteId),
    ];
  };
const ME = [{ type: TAGS.ME, id: "CURRENT" }] as const;

/**
 * Étiquettes de cache ajoutées aux endpoints générés (le fichier généré n'est jamais modifié).
 * Une mutation invalide les étiquettes de ce qu'elle change : les listes et fiches se relisent seules.
 */
export const enhancedApi = chantierApi.enhanceEndpoints({
  endpoints: {
    // Session
    authMe: { providesTags: [...ME] },
    authLogin: { invalidatesTags: onSuccess(() => ME) },
    authLogout: { invalidatesTags: onSuccess(() => ME) },
    authChangePassword: { invalidatesTags: onSuccess(() => ME) },
    authUpdateLanguage: { invalidatesTags: onSuccess(() => ME) },

    // Référentiel géographique
    referenceWilayas: { providesTags: [{ type: TAGS.REFERENCE, ...LIST }] },
    referenceCommunes: { providesTags: (_result, _error, arg) => [{ type: TAGS.REFERENCE, id: arg.code }] },

    // Chantiers
    sitesList: { providesTags: (result) => queryCacheTagsProvider(TAGS.SITES, result?.items) },
    sitesGet: { providesTags: (result) => (result ? queryCacheTagsProvider(TAGS.SITES, result) : []) },
    sitesCreate: { invalidatesTags: onSuccess(() => [{ type: TAGS.SITES, ...LIST }]) },
    sitesUpdate: { invalidatesTags: onSuccess((arg: { siteId: string }) => [{ type: TAGS.SITES, id: arg.siteId }, { type: TAGS.SITES, ...LIST }]) },
    sitesArchive: { invalidatesTags: onSuccess((arg: { siteId: string }) => [{ type: TAGS.SITES, id: arg.siteId }, { type: TAGS.SITES, ...LIST }]) },
    sitesRestore: { invalidatesTags: onSuccess((arg: { siteId: string }) => [{ type: TAGS.SITES, id: arg.siteId }, { type: TAGS.SITES, ...LIST }]) },

    // Zones : la liste d'un chantier se relit après toute modification de ses zones.
    zonesList: { providesTags: (result, _error, arg) => [...queryCacheTagsProvider(TAGS.ZONES, result?.items), { type: TAGS.ZONES, id: `SITE-${arg.siteId}` }] },
    zonesGet: { providesTags: (result) => (result ? queryCacheTagsProvider(TAGS.ZONES, result) : []) },
    zonesCreate: { invalidatesTags: onSuccess((arg: { siteId: string }) => [{ type: TAGS.ZONES, id: `SITE-${arg.siteId}` }]) },
    zonesUpdate: { invalidatesTags: onSuccess((arg: { siteId: string; zoneId: string }) => [{ type: TAGS.ZONES, id: arg.zoneId }, { type: TAGS.ZONES, id: `SITE-${arg.siteId}` }]) },
    zonesArchive: { invalidatesTags: onSuccess((arg: { siteId: string; zoneId: string }) => [{ type: TAGS.ZONES, id: arg.zoneId }, { type: TAGS.ZONES, id: `SITE-${arg.siteId}` }]) },
    zonesRestore: { invalidatesTags: onSuccess((arg: { siteId: string; zoneId: string }) => [{ type: TAGS.ZONES, id: arg.zoneId }, { type: TAGS.ZONES, id: `SITE-${arg.siteId}` }]) },

    // Affectations (lecture seule dans le socle ; l'écran d'affectation est dans le lot Administration)
    siteMembersList: { providesTags: (_result, _error, arg) => [{ type: TAGS.MEMBERS, id: arg.siteId }] },
    siteMembersAssign: { invalidatesTags: onSuccess((arg: { siteId: string }) => [{ type: TAGS.MEMBERS, id: arg.siteId }]) },
    siteMembersRemove: { invalidatesTags: onSuccess((arg: { siteId: string }) => [{ type: TAGS.MEMBERS, id: arg.siteId }]) },

    // Catalogue des matériaux (global, tenu par les Achats et l'Admin) : désactiver ne supprime jamais.
    productsList: { providesTags: (result) => queryCacheTagsProvider(TAGS.PRODUCTS, result?.items) },
    productsGet: { providesTags: (result) => (result ? queryCacheTagsProvider(TAGS.PRODUCTS, result) : []) },
    productsCreate: { invalidatesTags: onSuccess(() => [{ type: TAGS.PRODUCTS, ...LIST }]) },
    productsUpdate: { invalidatesTags: onSuccess((arg: { productId: string }) => [{ type: TAGS.PRODUCTS, id: arg.productId }, { type: TAGS.PRODUCTS, ...LIST }]) },
    productsActivate: { invalidatesTags: onSuccess((arg: { productId: string }) => [{ type: TAGS.PRODUCTS, id: arg.productId }, { type: TAGS.PRODUCTS, ...LIST }]) },
    productsDeactivate: { invalidatesTags: onSuccess((arg: { productId: string }) => [{ type: TAGS.PRODUCTS, id: arg.productId }, { type: TAGS.PRODUCTS, ...LIST }]) },

    suppliersList: { providesTags: (result) => queryCacheTagsProvider(TAGS.SUPPLIERS, result?.items) },
    suppliersGet: { providesTags: (result) => (result ? queryCacheTagsProvider(TAGS.SUPPLIERS, result) : []) },
    suppliersCreate: { invalidatesTags: onSuccess(() => [{ type: TAGS.SUPPLIERS, ...LIST }]) },
    suppliersUpdate: { invalidatesTags: onSuccess((arg: { supplierId: string }) => [{ type: TAGS.SUPPLIERS, id: arg.supplierId }, { type: TAGS.SUPPLIERS, ...LIST }]) },
    suppliersActivate: { invalidatesTags: onSuccess((arg: { supplierId: string }) => [{ type: TAGS.SUPPLIERS, id: arg.supplierId }, { type: TAGS.SUPPLIERS, ...LIST }]) },
    suppliersDeactivate: { invalidatesTags: onSuccess((arg: { supplierId: string }) => [{ type: TAGS.SUPPLIERS, id: arg.supplierId }, { type: TAGS.SUPPLIERS, ...LIST }]) },

    materialSettingsGet: { providesTags: [{ type: TAGS.MATERIAL_SETTINGS, ...LIST }] },

    // Demandes : le serveur calcule statut, reçu, reste et écart ; toute action relit la liste et la fiche touchées.
    requestsList: { providesTags: (result) => queryCacheTagsProvider(TAGS.REQUESTS, result?.items) },
    crossSiteRequestsList: { providesTags: (result) => queryCacheTagsProvider(TAGS.REQUESTS, result?.items) },
    requestsGet: { providesTags: (_result, _error, arg) => [{ type: TAGS.REQUESTS, id: arg.requestId }] },
    requestsCreate: { invalidatesTags: onSuccess(() => [{ type: TAGS.REQUESTS, ...LIST }]) },
    requestsUpdate: { invalidatesTags: onSuccess(requestTags) },
    requestsApprove: { invalidatesTags: onSuccess(requestTags) },
    requestsReject: { invalidatesTags: onSuccess(requestTags) },
    requestsCancel: { invalidatesTags: onSuccess(requestTags) },
    requestsReceive: { invalidatesTags: onSuccess(requestTags) },
    requestsSettle: { invalidatesTags: onSuccess(requestTags) },
    requestsLinkProduct: { invalidatesTags: onSuccess(requestTags) },
    requestsArchive: { invalidatesTags: onSuccess(requestTags) },
    requestsRestore: { invalidatesTags: onSuccess(requestTags) },
    requestsApproveBatch: { invalidatesTags: onSuccess(batchTags) },
    requestsArchiveBatch: { invalidatesTags: onSuccess(batchTags) },

    // Commandes (une par demande) : le serveur recalcule statut, reçu, montant ; rien n'est calculé ici.
    ordersCreate: { invalidatesTags: onSuccess(orderTags) },
    ordersUpdate: { invalidatesTags: onSuccess(orderTags) },
    ordersCancel: { invalidatesTags: onSuccess(orderTags) },

    // Livraisons : une saisie, une correction, une annulation ou un rattachement recalculent la demande liée.
    deliveriesList: { providesTags: (result) => queryCacheTagsProvider(TAGS.DELIVERIES, result?.items) },
    deliveriesGet: { providesTags: (_result, _error, arg) => [{ type: TAGS.DELIVERIES, id: arg.deliveryId }, { type: TAGS.DELIVERIES, ...LIST }] },
    deliveriesCreate: { invalidatesTags: deliveryTags<{ siteId: string }>(() => null) },
    deliveriesUpdate: { invalidatesTags: deliveryTags<{ siteId: string; deliveryId: string }>((arg) => arg.deliveryId) },
    deliveriesCancel: { invalidatesTags: deliveryTags<{ siteId: string; deliveryId: string }>((arg) => arg.deliveryId) },
    deliveriesAttach: {
      invalidatesTags: (result, error, arg) =>
        error
          ? []
          : [
              { type: TAGS.DELIVERIES, id: arg.deliveryId },
              { type: TAGS.DELIVERIES, ...LIST },
              { type: TAGS.REQUESTS, id: arg.attachBody.requestId },
              { type: TAGS.REQUESTS, ...LIST },
              followUpTag(arg.siteId),
              ...(result?.requestId ? [{ type: TAGS.REQUESTS, id: result.requestId }] : []),
            ],
    },
    // Une photo change `photoCount`, `photos` et le badge « BL manquant » de sa livraison.
    photosCreate: { invalidatesTags: onSuccess((arg: { deliveryId: string }) => [{ type: TAGS.DELIVERIES, id: arg.deliveryId }, { type: TAGS.DELIVERIES, ...LIST }]) },
    photosUpload: {
      invalidatesTags: (result, error) =>
        error || !result ? [] : [{ type: TAGS.DELIVERIES, id: result.deliveryId }, { type: TAGS.DELIVERIES, ...LIST }],
    },

    followUpGet: { providesTags: (_result, _error, arg) => [followUpTag(arg.siteId)] },
  },
});
