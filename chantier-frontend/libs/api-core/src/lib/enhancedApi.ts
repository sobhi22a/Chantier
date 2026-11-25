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
  },
});
