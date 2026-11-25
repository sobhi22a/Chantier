import { Anchor, Badge, Table } from "@mantine/core";
import { IconArchive, IconCircleDot } from "@tabler/icons-react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

import type { SiteResponse } from "@chantier-frontend/api-core";
import { formatDateOnly, Ltr, pickLocalizedName, useLanguage } from "@chantier-frontend/i18n";

import { siteDetailPath } from "../../../app/providers/router/navigationRoutes";

export const SiteStatusBadge = ({ archived }: { archived: boolean }) => {
  const { t } = useTranslation("sites");
  // Texte ET icône : le statut ne repose jamais sur la couleur seule.
  return archived ? (
    <Badge color="gray" variant="light" size="lg" leftSection={<IconArchive size={14} aria-hidden />}>
      {t("status.archived")}
    </Badge>
  ) : (
    <Badge color="blue" variant="light" size="lg" leftSection={<IconCircleDot size={14} aria-hidden />}>
      {t("status.active")}
    </Badge>
  );
};

/** Tableau « Mes chantiers » : code, nom dans la langue, commune / wilaya, fin contractuelle calculée par le serveur. */
export const SitesTable = ({ sites }: { sites: readonly SiteResponse[] }) => {
  const { t } = useTranslation("sites");
  const { language } = useLanguage();

  return (
    <Table.ScrollContainer minWidth={680}>
      <Table>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>{t("list.columns.code")}</Table.Th>
            <Table.Th>{t("list.columns.name")}</Table.Th>
            <Table.Th>{t("list.columns.location")}</Table.Th>
            <Table.Th>{t("list.columns.contractualEnd")}</Table.Th>
            <Table.Th>{t("list.columns.status")}</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {sites.map((site) => {
            const contractualEnd = formatDateOnly(site.contractualEndDate);
            return (
              <Table.Tr key={site.id}>
                <Table.Td fw={700}>
                  <Ltr>{site.code}</Ltr>
                </Table.Td>
                <Table.Td>
                  <Anchor component={Link} to={siteDetailPath(site.id)}>
                    {pickLocalizedName(site, language)}
                  </Anchor>
                </Table.Td>
                <Table.Td>
                  {site.commune} / {site.wilaya}
                </Table.Td>
                <Table.Td>{contractualEnd ? <Ltr>{contractualEnd}</Ltr> : t("detail.toBeDefined")}</Table.Td>
                <Table.Td>
                  <SiteStatusBadge archived={site.archivedAt !== null} />
                </Table.Td>
              </Table.Tr>
            );
          })}
        </Table.Tbody>
      </Table>
    </Table.ScrollContainer>
  );
};
