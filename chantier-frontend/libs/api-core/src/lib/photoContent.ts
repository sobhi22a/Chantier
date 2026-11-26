import { ApplicationApiService } from "./ApplicationApi.service";

export interface PhotoContentArg {
  siteId: string;
  photoId: string;
}

/**
 * Contenu d'une photo de bon de livraison (ADR 0013) : lecture authentifiée par le cookie de session, jamais d'URL publique.
 * Le JPEG est lu en binaire puis exposé par une URL d'objet locale (`blob:`), seule valeur gardée dans le cache (sérialisable).
 * L'URL est libérée quand la dernière vue qui la lit disparaît du cache. Sans droit, le serveur répond 404 (indiscernable d'une
 * photo absente) : l'écran n'appelle ce point d'accès que pour une photo envoyée et avec `DeliveryPhotos.View`.
 */
export const photoContentApi = ApplicationApiService.injectEndpoints({
  endpoints: (build) => ({
    photoContent: build.query<string, PhotoContentArg>({
      query: ({ siteId, photoId }) => ({
        url: `/api/v1/sites/${siteId}/photos/${photoId}/content`,
        responseHandler: async (response) => URL.createObjectURL(await response.blob()),
      }),
      keepUnusedDataFor: 120,
      async onCacheEntryAdded(_arg, { cacheDataLoaded, cacheEntryRemoved }) {
        let url: string | undefined;
        try {
          url = (await cacheDataLoaded).data;
        } catch {
          // Lecture refusée ou échouée : rien à libérer.
        }
        await cacheEntryRemoved;
        if (url) URL.revokeObjectURL(url);
      },
    }),
  }),
});

export const { usePhotoContentQuery } = photoContentApi;
