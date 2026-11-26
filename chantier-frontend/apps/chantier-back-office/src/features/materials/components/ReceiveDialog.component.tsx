import { Button, Group, Modal, Stack, Text, Textarea } from "@mantine/core";
import { useState } from "react";
import { useTranslation } from "react-i18next";

export interface ReceiveDialogProps {
  title: string;
  noteMaxLength: number;
  loading: boolean;
  onConfirm: (note: string | null) => void;
  onCancel: () => void;
}

/** Réceptionner une demande livrée (CA-MAT-008.3) : un geste, remarque facultative. */
export const ReceiveDialog = ({ title, noteMaxLength, loading, onConfirm, onCancel }: ReceiveDialogProps) => {
  const { t } = useTranslation(["materials", "common"]);
  const [note, setNote] = useState("");

  return (
    <Modal opened onClose={onCancel} title={title} centered closeButtonProps={{ "aria-label": t("common:actions.close") }}>
      <Stack gap="md">
        <Text>{t("materials:receive.message")}</Text>
        <Textarea
          label={t("materials:receive.note")}
          maxLength={noteMaxLength}
          autosize
          minRows={2}
          value={note}
          onChange={(event) => setNote(event.currentTarget.value)}
        />
        <Group justify="flex-end">
          <Button variant="default" onClick={onCancel} disabled={loading}>
            {t("common:actions.cancel")}
          </Button>
          <Button loading={loading} onClick={() => onConfirm(note.trim() === "" ? null : note.trim())}>
            {t("materials:receive.confirm")}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
};
