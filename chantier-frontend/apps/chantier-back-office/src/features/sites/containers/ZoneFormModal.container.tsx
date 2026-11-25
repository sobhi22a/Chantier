import { Modal } from "@mantine/core";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import { useZonesCreateMutation, useZonesUpdateMutation, type ZoneResponse } from "@chantier-frontend/api-core";
import { useNotifications } from "@chantier-frontend/user-interface";

import { ZoneForm } from "../components/ZoneForm.component";
import {
  emptyZoneFormValues,
  toCreateZoneRequest,
  toUpdateZoneRequest,
  zoneToFormValues,
  type ZoneFormValues,
} from "../types/zoneForm.zod";

export interface ZoneFormModalContainerProps {
  siteId: string;
  /** Zone à modifier ; absente pour une création. */
  zone?: ZoneResponse;
  knownBlocks: readonly string[];
  onClose: () => void;
}

export const ZoneFormModalContainer = ({ siteId, zone, knownBlocks, onClose }: ZoneFormModalContainerProps) => {
  const { t } = useTranslation(["sites", "common"]);
  const { showNotification } = useNotifications();
  const [editedZone, setEditedZone] = useState<ZoneResponse | undefined>(zone);
  const [createZone] = useZonesCreateMutation();
  const [updateZone] = useZonesUpdateMutation();

  const handleSubmit = async (values: ZoneFormValues): Promise<unknown> => {
    try {
      if (editedZone) {
        await updateZone({
          siteId,
          zoneId: editedZone.id,
          updateZoneRequest: toUpdateZoneRequest(values, editedZone.version),
        }).unwrap();
      } else {
        await createZone({ siteId, createZoneRequest: toCreateZoneRequest(values) }).unwrap();
      }
      showNotification({ type: "success", message: editedZone ? t("sites:zones.updated") : t("sites:zones.created") });
      onClose();
      return undefined;
    } catch (error) {
      return error;
    }
  };

  return (
    <Modal
      opened
      onClose={onClose}
      title={editedZone ? t("sites:zones.editTitle") : t("sites:zones.addTitle")}
      closeButtonProps={{ "aria-label": t("common:actions.close") }}
    >
      <ZoneForm
        mode={editedZone ? "edit" : "create"}
        initialValues={editedZone ? zoneToFormValues(editedZone) : emptyZoneFormValues({ block: knownBlocks[0] ?? "" })}
        knownBlocks={knownBlocks}
        onSubmit={handleSubmit}
        onCancel={onClose}
        onConflictReload={setEditedZone}
      />
    </Modal>
  );
};
