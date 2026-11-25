import { Group, List, Text } from "@mantine/core";
import { IconUser } from "@tabler/icons-react";
import { useTranslation } from "react-i18next";

import type { SiteMemberResponse } from "@chantier-frontend/api-core";

/** Personnes affectées au chantier : nom et rôle, jamais de téléphone (H-17). Lecture seule (lot Administration). */
export const SiteMembersList = ({ members }: { members: readonly SiteMemberResponse[] }) => {
  const { t } = useTranslation(["sites", "common"]);

  if (members.length === 0) return <Text c="dimmed">{t("sites:detail.noMembers")}</Text>;

  return (
    <List listStyleType="none" spacing="xs">
      {members.map((member) => (
        <List.Item key={member.userId}>
          <Group gap="xs">
            <IconUser size={18} aria-hidden />
            <bdi>{member.fullName}</bdi>
            <Text span c="dimmed">
              · {t(`common:roles.${member.role as "Admin"}`, { defaultValue: member.role })}
            </Text>
          </Group>
        </List.Item>
      ))}
    </List>
  );
};
