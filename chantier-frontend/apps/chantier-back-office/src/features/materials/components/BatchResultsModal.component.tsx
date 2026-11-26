import { Badge, Button, Group, Modal, Stack, Table, Text } from "@mantine/core";
import { IconAlertOctagon, IconCircleCheck, IconCircleDot } from "@tabler/icons-react";
import { useTranslation } from "react-i18next";

import type { BatchItemResult } from "@chantier-frontend/api-core";
import { Ltr } from "@chantier-frontend/i18n";

export interface BatchResultsModalProps {
  title: string;
  /** Résultat du lot, demande par demande (CA-MAT-003.9, CA-MAT-014.8). */
  results: readonly BatchItemResult[];
  /** Numéro affiché d'une demande (le lot ne renvoie que son identifiant). */
  numberOf: (requestId: string) => string;
  /** Libellé du résultat « traité » : « Validée » ou « Archivée ». */
  appliedLabel: string;
  onClose: () => void;
}

/**
 * Résultat d'un lot, demande par demande : chacune est traitée et tracée individuellement ; celles qui ne peuvent pas
 * l'être sont listées avec leur motif traduit selon le `code` (jamais le texte du serveur).
 */
export const BatchResultsModal = ({ title, results, numberOf, appliedLabel, onClose }: BatchResultsModalProps) => {
  const { t, i18n } = useTranslation(["materials", "errors", "common"]);
  const count = (outcome: string) => results.filter((result) => result.outcome === outcome).length;

  const reasonText = (code: string | null | undefined): string => {
    if (!code) return "—";
    return i18n.exists(`errors:${code}`) ? t(`errors:${code}`) : t("errors:UNKNOWN");
  };

  return (
    <Modal opened onClose={onClose} size="lg" title={title} closeButtonProps={{ "aria-label": t("common:actions.close") }}>
      <Stack gap="md">
        <Text role="status">
          {t("materials:batch.summary", { applied: count("applied"), duplicate: count("duplicate"), rejected: count("rejected") })}
        </Text>
        <Table.ScrollContainer minWidth={420}>
          <Table>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>{t("materials:batch.columns.request")}</Table.Th>
                <Table.Th>{t("materials:batch.columns.outcome")}</Table.Th>
                <Table.Th>{t("materials:batch.columns.reason")}</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {results.map((result) => (
                <Table.Tr key={result.requestId}>
                  <Table.Td fw={700}>
                    <Ltr>{numberOf(result.requestId)}</Ltr>
                  </Table.Td>
                  <Table.Td>
                    {result.outcome === "applied" ? (
                      <Badge color="green" variant="light" size="lg" leftSection={<IconCircleCheck size={14} aria-hidden />}>
                        {appliedLabel}
                      </Badge>
                    ) : result.outcome === "duplicate" ? (
                      <Badge color="blue" variant="light" size="lg" leftSection={<IconCircleDot size={14} aria-hidden />}>
                        {t("materials:batch.duplicate")}
                      </Badge>
                    ) : (
                      <Badge color="red" variant="light" size="lg" leftSection={<IconAlertOctagon size={14} aria-hidden />}>
                        {t("materials:batch.rejected")}
                      </Badge>
                    )}
                  </Table.Td>
                  <Table.Td>{result.outcome === "rejected" ? reasonText(result.code) : "—"}</Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        </Table.ScrollContainer>
        <Group justify="flex-end">
          <Button onClick={onClose}>{t("materials:batch.close")}</Button>
        </Group>
      </Stack>
    </Modal>
  );
};
