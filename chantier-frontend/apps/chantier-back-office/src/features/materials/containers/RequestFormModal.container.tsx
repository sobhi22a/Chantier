import { Center, Loader, Modal } from "@mantine/core";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import {
  useMaterialSettingsGetQuery,
  useRequestsCreateMutation,
  useRequestsUpdateMutation,
  useSitesListQuery,
} from "@chantier-frontend/api-core";
import { todayDateOnly } from "@chantier-frontend/i18n";
import { useNotifications } from "@chantier-frontend/user-interface";

import { RequestForm } from "../components/RequestForm.component";
import { addDays } from "../types/quantityMirror";
import {
  emptyRequestFormValues,
  NOTE_MAX,
  requestToFormValues,
  toCreateRequestRequest,
  toUpdateRequestRequest,
  type RequestFormValues,
} from "../types/requestForm.zod";
import { asRequestDetail, type RequestDetail } from "../types/requestTypes";

export interface RequestFormModalContainerProps {
  /** Demande à modifier ; absente pour une création. */
  request?: RequestDetail;
  /** Chantier proposé à la création (filtre courant de la liste). */
  defaultSiteId?: string;
  onClose: () => void;
  onSaved?: (request: RequestDetail) => void;
}

const DEFAULT_NEEDED_BY_DAYS = 3;
const SITES_PAGE_SIZE = 200;

/** Création (numéro `DEM-nnn` donné par le serveur) et modification avec `version` ; avertit d'un doublon possible, sans bloquer. */
export const RequestFormModalContainer = ({ request, defaultSiteId, onClose, onSaved }: RequestFormModalContainerProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const { showNotification } = useNotifications();
  const [edited, setEdited] = useState<RequestDetail | undefined>(request);
  const [createRequest] = useRequestsCreateMutation();
  const [updateRequest] = useRequestsUpdateMutation();

  const isCreation = request === undefined;
  const settings = useMaterialSettingsGetQuery();
  const sites = useSitesListQuery({ pageSize: SITES_PAGE_SIZE }, { skip: !isCreation });
  // Les valeurs par défaut viennent du serveur (réglages) : on attend la réponse pour que `defaultValues` ne soit pas figé trop tôt.
  const ready = !settings.isLoading && (!isCreation || !sites.isLoading);

  const handleSubmit = async (values: RequestFormValues): Promise<unknown> => {
    try {
      let saved: RequestDetail;
      if (edited) {
        saved = asRequestDetail(
          await updateRequest({
            siteId: edited.siteId,
            requestId: edited.id,
            updateRequestRequest: toUpdateRequestRequest(values, edited.version, edited.status === "Requested"),
          }).unwrap(),
        );
        showNotification({ type: "success", message: t("materials:form.updated", { number: saved.number }) });
      } else {
        saved = asRequestDetail(await createRequest({ siteId: values.siteId, createRequestRequest: toCreateRequestRequest(values) }).unwrap());
        showNotification({ type: "success", message: t("materials:form.created", { number: saved.number }) });
        if (saved.possibleDuplicateOf) {
          showNotification({ type: "warning", message: t("materials:form.duplicateNotice", { number: saved.possibleDuplicateOf.number }) });
        }
      }
      onSaved?.(saved);
      onClose();
      return undefined;
    } catch (error) {
      return error;
    }
  };

  const defaultNeededBy = addDays(todayDateOnly(), settings.data?.defaultNeededByDays ?? DEFAULT_NEEDED_BY_DAYS);
  const activeSites = (sites.data?.items ?? []).filter((site) => site.archivedAt === null);
  const singleSiteId = activeSites.length === 1 ? (activeSites[0]?.id ?? "") : "";
  const initialValues = edited
    ? requestToFormValues(edited)
    : emptyRequestFormValues({
        neededBy: defaultNeededBy,
        siteId: defaultSiteId && activeSites.some((site) => site.id === defaultSiteId) ? defaultSiteId : singleSiteId,
      });

  return (
    <Modal
      opened
      onClose={onClose}
      size="lg"
      title={edited ? t("materials:form.editTitle", { number: edited.number }) : t("materials:form.createTitle")}
      closeButtonProps={{ "aria-label": t("common:actions.close") }}
    >
      {ready ? (
        <RequestForm
          key={edited?.version ?? "new"}
          mode={edited ? "edit" : "create"}
          initialValues={initialValues}
          sites={activeSites}
          request={edited}
          noteMaxLength={settings.data?.noteMaxLength ?? NOTE_MAX}
          onSubmit={handleSubmit}
          onCancel={onClose}
          onConflictReload={setEdited}
        />
      ) : (
        <Center py="xl">
          <Loader aria-label={t("common:state.loading")} />
        </Center>
      )}
    </Modal>
  );
};
