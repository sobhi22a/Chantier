import { Center, Loader, Modal } from "@mantine/core";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import {
  useLazySitesSuggestCodeQuery,
  useReferenceCommunesQuery,
  useReferenceWilayasQuery,
  useSitesListQuery,
  useSitesCreateMutation,
  useSitesUpdateMutation,
  type SiteResponse,
} from "@chantier-frontend/api-core";
import { PERMISSIONS_RESOURCES, usePermissions } from "@chantier-frontend/authentication";
import { useNotifications } from "@chantier-frontend/user-interface";

import { SiteForm } from "../components/SiteForm.component";
import {
  emptySiteFormValues,
  siteToFormValues,
  toCreateSiteRequest,
  toUpdateSiteRequest,
  type SiteFormValues,
} from "../types/siteForm.zod";

export interface SiteFormModalContainerProps {
  /** Chantier à modifier ; absent pour une création. */
  site?: SiteResponse;
  onClose: () => void;
  onSaved: (site: SiteResponse) => void;
}

/** Charge le référentiel géographique, propose un code et enregistre (création ou modification avec `version`). */
export const SiteFormModalContainer = ({ site, onClose, onSaved }: SiteFormModalContainerProps) => {
  const { t } = useTranslation(["sites", "common"]);
  const { can } = usePermissions();
  const { showNotification } = useNotifications();
  const [editedSite, setEditedSite] = useState<SiteResponse | undefined>(site);

  // CA-008.6 : à la création, la wilaya (et le maître d'ouvrage) du dernier chantier créé sont proposés.
  // Source : le serveur (le chantier le plus récent visible, archivés compris), donc identique d'un poste à l'autre
  // et sans rien stocker dans le navigateur. Le formulaire attend la réponse pour que les valeurs soient dans ses
  // valeurs initiales (sinon un champ déjà saisi serait écrasé).
  const isCreation = site === undefined;
  const lastSiteQuery = useSitesListQuery(
    { sort: "-createdAt", pageSize: 1, includeArchived: true },
    { skip: !isCreation, refetchOnMountOrArgChange: true },
  );
  const lastSite = lastSiteQuery.data?.items[0];
  // Prêt seulement quand la réponse date d'APRÈS l'ouverture du formulaire : une valeur déjà en cache pourrait être
  // périmée (un autre administrateur a pu créer un chantier entre-temps).
  const [openedAt] = useState(() => Date.now());
  const lastSiteSettled = !isCreation || lastSiteQuery.isError || (lastSiteQuery.fulfilledTimeStamp ?? 0) >= openedAt;
  const [chosenWilaya, setChosenWilaya] = useState<string | null>(null);
  const wilayaName = chosenWilaya ?? site?.wilaya ?? lastSite?.wilaya ?? "";

  const { data: wilayas = [] } = useReferenceWilayasQuery();
  const wilayaCode = wilayas.find((wilaya) => wilaya.nameFr === wilayaName)?.code;
  const { data: communes = [] } = useReferenceCommunesQuery({ code: wilayaCode ?? "" }, { skip: !wilayaCode });

  const [createSite] = useSitesCreateMutation();
  const [updateSite] = useSitesUpdateMutation();
  const [suggestCode] = useLazySitesSuggestCodeQuery();

  const canEditAmount = can(PERMISSIONS_RESOURCES.CONTRACT_AMOUNT, "View");

  const handleSubmit = async (values: SiteFormValues): Promise<unknown> => {
    try {
      const saved = editedSite
        ? await updateSite({
            siteId: editedSite.id,
            updateSiteRequest: toUpdateSiteRequest(values, editedSite.version, canEditAmount),
          }).unwrap()
        : await createSite({ createSiteRequest: toCreateSiteRequest(values) }).unwrap();
      showNotification({ type: "success", message: editedSite ? t("sites:form.updated") : t("sites:form.created") });
      onSaved(saved);
      return undefined;
    } catch (error) {
      return error;
    }
  };

  const handleSuggestCode = async (type: SiteFormValues["type"], name: string): Promise<string | undefined> => {
    const result = await suggestCode({ type, name }).unwrap().catch(() => undefined);
    return result?.code;
  };

  const initialValues = editedSite
    ? siteToFormValues(editedSite)
    : { ...emptySiteFormValues(), wilaya: lastSite?.wilaya ?? "", owner: lastSite?.owner ?? "" };

  return (
    <Modal
      opened
      onClose={onClose}
      size="lg"
      title={editedSite ? t("sites:form.editTitle") : t("sites:form.createTitle")}
      closeButtonProps={{ "aria-label": t("common:actions.close") }}
    >
      {lastSiteSettled ? (
        <SiteForm
          mode={editedSite ? "edit" : "create"}
          initialValues={initialValues}
          wilayas={wilayas}
          communes={communes}
          onWilayaChange={setChosenWilaya}
          canEditAmount={canEditAmount}
          onSubmit={handleSubmit}
          onSuggestCode={editedSite ? undefined : handleSuggestCode}
          onCancel={onClose}
          onConflictReload={setEditedSite}
        />
      ) : (
        <Center py="xl">
          <Loader aria-label={t("common:state.loading")} />
        </Center>
      )}
    </Modal>
  );
};
