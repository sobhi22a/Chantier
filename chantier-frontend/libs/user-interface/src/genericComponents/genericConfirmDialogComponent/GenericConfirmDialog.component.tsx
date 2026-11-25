import { Button, Group, Modal, Text } from "@mantine/core";
import { useTranslation } from "react-i18next";

export interface GenericConfirmDialogComponentProps {
  opened: boolean;
  title: string;
  message: string;
  /** Libellé du bouton de confirmation (défaut : « Confirmer »). */
  confirmLabel?: string;
  /** Action sensible (archivage) : bouton rouge, toujours accompagné de son libellé. */
  danger?: boolean;
  loading?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

/** Confirmation explicite avant une action qui change l'état d'un élément (archiver, restaurer). */
const GenericConfirmDialogComponent = ({
  opened,
  title,
  message,
  confirmLabel,
  danger = false,
  loading = false,
  onConfirm,
  onCancel,
}: GenericConfirmDialogComponentProps) => {
  const { t } = useTranslation("common");

  return (
    <Modal opened={opened} onClose={onCancel} title={title} centered closeButtonProps={{ "aria-label": t("actions.close") }}>
      <Text mb="lg">{message}</Text>
      <Group justify="flex-end">
        <Button variant="default" onClick={onCancel} disabled={loading}>
          {t("actions.cancel")}
        </Button>
        <Button color={danger ? "red" : undefined} onClick={onConfirm} loading={loading}>
          {confirmLabel ?? t("actions.confirm")}
        </Button>
      </Group>
    </Modal>
  );
};

export default GenericConfirmDialogComponent;
