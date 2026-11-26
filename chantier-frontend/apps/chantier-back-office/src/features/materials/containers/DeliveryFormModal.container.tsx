import { Center, Loader, Modal } from "@mantine/core";
import { useRef, useState } from "react";
import { useTranslation } from "react-i18next";

import {
  useDeliveriesCreateMutation,
  useDeliveriesUpdateMutation,
  useMaterialSettingsGetQuery,
  useRequestsGetQuery,
  useSitesListQuery,
} from "@chantier-frontend/api-core";
import { useNotifications } from "@chantier-frontend/user-interface";

import { DeliveryForm } from "../components/DeliveryForm.component";
import {
  deliveryToFormValues,
  emptyDeliveryFormValues,
  requestDefaults,
  toCreateDeliveryRequest,
  toUpdateDeliveryRequest,
  type DeliveryFormValues,
} from "../types/deliveryForm.zod";
import { asDeliveryDetail, type DeliveryDetail } from "../types/deliveryTypes";
import { asRequestDetail } from "../types/requestTypes";

export interface DeliveryFormModalContainerProps {
  /** Livraison corrigée ; absente pour une création. */
  delivery?: DeliveryDetail;
  /** Création : chantier et demande de départ (livraison saisie depuis une demande). */
  siteId?: string;
  requestId?: string;
  onClose: () => void;
  /** Après l'enregistrement : si fourni, remplace `onClose` (l'appelant ferme le formulaire en changeant d'adresse). */
  onSaved?: (saved: DeliveryDetail) => void;
}

const SITES_PAGE_SIZE = 200;

/**
 * Création (numéro `LIV-nnn` donné par le serveur) et correction d'une livraison avec `version`. Le `clientId` est posé à
 * l'ouverture : un double appui sur « Nouvelle livraison » renvoie le même identifiant, donc une seule livraison et un seul
 * numéro (CA-MAT-006.8). Une livraison n'est jamais refusée à cause du statut de la demande : elle est alors non rattachée.
 */
export const DeliveryFormModalContainer = ({ delivery, siteId, requestId, onClose, onSaved }: DeliveryFormModalContainerProps) => {
  const { t, i18n } = useTranslation(["materials", "common"]);
  const { showNotification } = useNotifications();
  const [edited, setEdited] = useState<DeliveryDetail | undefined>(delivery);
  const [createDelivery] = useDeliveriesCreateMutation();
  const [updateDelivery] = useDeliveriesUpdateMutation();
  const clientId = useRef(crypto.randomUUID());

  const isCreation = delivery === undefined;
  const settings = useMaterialSettingsGetQuery();
  const sites = useSitesListQuery({ pageSize: SITES_PAGE_SIZE }, { skip: !isCreation });
  // Demande de départ : la demande désignée à la création, ou la demande liée de la livraison corrigée.
  const startRequestId = isCreation ? requestId : delivery?.requestId;
  const startSiteId = isCreation ? siteId : delivery?.siteId;
  const startRequest = useRequestsGetQuery({ siteId: startSiteId ?? "", requestId: startRequestId ?? "" }, { skip: !startRequestId || !startSiteId });
  // Les valeurs par défaut viennent du serveur : on attend leur arrivée pour que `defaultValues` ne soit pas figé trop tôt.
  const ready = !settings.isLoading && (!isCreation || !sites.isLoading) && !startRequest.isLoading;
  const initialRequest = startRequest.data?.id ? asRequestDetail(startRequest.data) : null;

  const handleSubmit = async (values: DeliveryFormValues): Promise<unknown> => {
    try {
      let saved: DeliveryDetail;
      if (edited) {
        saved = asDeliveryDetail(
          await updateDelivery({ siteId: edited.siteId, deliveryId: edited.id, updateDeliveryRequest: toUpdateDeliveryRequest(values, edited) }).unwrap(),
        );
        showNotification({ type: "success", message: t("materials:deliveries.form.updated", { number: saved.number }) });
      } else {
        saved = asDeliveryDetail(await createDelivery({ siteId: values.siteId, createDeliveryRequest: toCreateDeliveryRequest(values, clientId.current) }).unwrap());
        // Non rattachée : la livraison est un fait de chantier, elle est enregistrée avec son motif (CA-MAT-010.6).
        const reasonKey = saved.unattachedReason ? `materials:deliveries.unattachedReason.${saved.unattachedReason}` : null;
        showNotification({
          type: saved.requestId || !reasonKey ? "success" : "warning",
          message:
            saved.requestId || !reasonKey
              ? t("materials:deliveries.form.created", { number: saved.number })
              : t("materials:deliveries.form.createdUnattached", { number: saved.number, reason: i18n.t(reasonKey) }),
        });
      }
      // Doublon de BL : jamais un refus, un avertissement (CA-MAT-006.9).
      if (saved.possibleDuplicateOf) {
        showNotification({ type: "warning", message: t("materials:deliveries.form.duplicateNotice", { number: saved.possibleDuplicateOf.number }) });
      }
      // L'appelant qui prend la suite (ouvrir la fiche) ferme le formulaire lui-même : fermer d'abord écraserait sa navigation.
      if (onSaved) onSaved(saved);
      else onClose();
      return undefined;
    } catch (error) {
      return error;
    }
  };

  const reserveReasons = settings.data?.reasons.reserve ?? [];
  const tolerancePercent = settings.data?.deliveryTolerancePercent ?? 0;
  const initialValues: DeliveryFormValues = edited
    ? deliveryToFormValues(edited)
    : emptyDeliveryFormValues({
        siteId: siteId ?? "",
        ...(initialRequest ? requestDefaults(initialRequest) : {}),
      });
  const activeSites = (sites.data?.items ?? []).filter((site) => site.archivedAt === null);
  // Un seul chantier affecté : il est choisi d'office.
  if (isCreation && initialValues.siteId === "" && activeSites.length === 1) initialValues.siteId = activeSites[0]?.id ?? "";

  const title = edited
    ? t("materials:deliveries.form.editTitle", { number: edited.number })
    : initialRequest
      ? t("materials:deliveries.form.createForTitle", { number: initialRequest.number })
      : t("materials:deliveries.form.createTitle");

  return (
    <Modal opened onClose={onClose} size="lg" title={title} closeButtonProps={{ "aria-label": t("common:actions.close") }}>
      {ready ? (
        <DeliveryForm
          key={edited?.version ?? "new"}
          mode={edited ? "edit" : "create"}
          initialValues={initialValues}
          sites={activeSites}
          initialRequest={initialRequest}
          delivery={edited}
          reserveReasons={reserveReasons}
          tolerancePercent={tolerancePercent}
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
