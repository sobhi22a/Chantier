import { Alert, Anchor, Button, Checkbox, Divider, Group, Paper, Stack, Text, Title } from "@mantine/core";
import { IconArchive, IconArchiveOff, IconArrowLeft, IconInfoCircle, IconPencil, IconPlus } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

import {
  isApiError,
  useApiErrorMessage,
  useSiteMembersListQuery,
  useSitesArchiveMutation,
  useSitesGetQuery,
  useSitesRestoreMutation,
  useZonesArchiveMutation,
  useZonesRestoreMutation,
  type ZoneResponse,
} from "@chantier-frontend/api-core";
import { PERMISSIONS_RESOURCES, usePermissions } from "@chantier-frontend/authentication";
import { Ltr, pickLocalizedName, useLanguage } from "@chantier-frontend/i18n";
import {
  GenericConfirmDialogComponent,
  GenericEmptyComponent,
  GenericErrorComponent,
  GenericLoaderComponent,
  useNotifications,
} from "@chantier-frontend/user-interface";

import { BACK_OFFICE_ROUTES } from "../../../app/providers/router/navigationRoutes";
import { AuditLine } from "../components/AuditLine.component";
import { SiteInfo } from "../components/SiteInfo.component";
import { SiteMembersList } from "../components/SiteMembersList.component";
import { SiteStatusBadge } from "../components/SitesTable.component";
import { ZonesByBlock } from "../components/ZonesByBlock.component";
import { SiteFormModalContainer } from "./SiteFormModal.container";
import { ZoneFormModalContainer } from "./ZoneFormModal.container";
import { ZonesPagesContainer } from "./ZonesPages.container";

type Dialog =
  | { kind: "editSite" }
  | { kind: "archiveSite" }
  | { kind: "restoreSite" }
  | { kind: "addZone" }
  | { kind: "editZone"; zone: ZoneResponse }
  | { kind: "archiveZone"; zone: ZoneResponse }
  | { kind: "restoreZone"; zone: ZoneResponse };

/**
 * Fiche d'un chantier : informations, zones par bloc, personnes affectées, traçabilité.
 * Les actions n'apparaissent que si l'utilisateur a la permission (jamais grisées) ; le serveur refuse de toute façon.
 */
export const SiteDetailContainer = ({ siteId }: { siteId: string }) => {
  const { t } = useTranslation(["sites", "common"]);
  const { language } = useLanguage();
  const { can } = usePermissions();
  const { describe, getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const [dialog, setDialog] = useState<Dialog | null>(null);
  const [showArchivedZones, setShowArchivedZones] = useState(false);

  const { data: site, isLoading, isError, error, refetch } = useSitesGetQuery({ siteId });
  // Les personnes affectées ne sont demandées qu'une fois le chantier chargé (un chantier introuvable n'a rien à lister).
  const canSeeMembers = can(PERMISSIONS_RESOURCES.SITE_MEMBERS, "View");
  const { data: members } = useSiteMembersListQuery({ siteId }, { skip: !canSeeMembers || !site });

  const [archiveSite, archiveSiteState] = useSitesArchiveMutation();
  const [restoreSite, restoreSiteState] = useSitesRestoreMutation();
  const [archiveZone, archiveZoneState] = useZonesArchiveMutation();
  const [restoreZone, restoreZoneState] = useZonesRestoreMutation();

  const closeDialog = () => setDialog(null);

  const run = async (action: () => Promise<unknown>, successMessage: string) => {
    try {
      await action();
      showNotification({ type: "success", message: successMessage });
    } catch (caught) {
      showNotification({ type: "error", message: getMessage(caught) });
    } finally {
      closeDialog();
    }
  };

  if (isLoading) return <GenericLoaderComponent />;

  if (isError || !site) {
    // 404 : chantier absent ou non affecté, même réponse (CA-006.2). Pas de « Réessayer » : ça ne changerait rien.
    const notFound = isApiError(error) && error.status === 404;
    return (
      <Stack gap="md">
        <BackToList />
        <GenericErrorComponent {...describe(error)} onRetry={notFound ? undefined : () => void refetch()} />
      </Stack>
    );
  }

  const archived = site.archivedAt !== null;
  const siteName = pickLocalizedName(site, language);
  const canEditZones = !archived && can(PERMISSIONS_RESOURCES.ZONES, "Update");
  const canArchiveZones = !archived && can(PERMISSIONS_RESOURCES.ZONES, "Delete");
  const canAddZone = !archived && can(PERMISSIONS_RESOURCES.ZONES, "Create");

  return (
    <Stack gap="lg">
      <title>{siteName}</title>
      <BackToList />

      <Group justify="space-between" align="flex-start" wrap="wrap">
        <Stack gap={4}>
          <Title order={1}>{siteName}</Title>
          <Group gap="sm">
            <Text fw={700} size="lg">
              <Ltr>{site.code}</Ltr>
            </Text>
            <SiteStatusBadge archived={archived} />
          </Group>
        </Stack>
        <Group>
          {!archived && can(PERMISSIONS_RESOURCES.SITES, "Update") ? (
            <Button variant="default" leftSection={<IconPencil size={18} aria-hidden />} onClick={() => setDialog({ kind: "editSite" })}>
              {t("common:actions.edit")}
            </Button>
          ) : null}
          {!archived && can(PERMISSIONS_RESOURCES.SITES, "Delete") ? (
            <Button variant="default" leftSection={<IconArchive size={18} aria-hidden />} onClick={() => setDialog({ kind: "archiveSite" })}>
              {t("common:actions.archive")}
            </Button>
          ) : null}
          {archived && can(PERMISSIONS_RESOURCES.SITES, "Delete") ? (
            <Button variant="default" leftSection={<IconArchiveOff size={18} aria-hidden />} onClick={() => setDialog({ kind: "restoreSite" })}>
              {t("common:actions.restore")}
            </Button>
          ) : null}
        </Group>
      </Group>

      {archived ? (
        <Alert color="gray" variant="light" icon={<IconInfoCircle aria-hidden />}>
          {t("sites:detail.archivedBanner")}
        </Alert>
      ) : null}

      <Paper withBorder p="md">
        <Stack gap="lg">
          <SiteInfo site={site} />
        </Stack>
      </Paper>

      <Paper withBorder p="md" component="section" aria-labelledby="site-zones">
        <Group justify="space-between" mb="sm" wrap="wrap">
          <Title order={2} size="h4" id="site-zones">
            {t("sites:detail.sections.zones")}
          </Title>
          <Group>
            <Checkbox
              label={t("sites:zones.showArchived")}
              checked={showArchivedZones}
              onChange={(event) => setShowArchivedZones(event.currentTarget.checked)}
            />
            {canAddZone ? (
              <Button leftSection={<IconPlus size={18} aria-hidden />} onClick={() => setDialog({ kind: "addZone" })}>
                {t("sites:zones.add")}
              </Button>
            ) : null}
          </Group>
        </Group>
        <ZonesPagesContainer
          siteId={siteId}
          includeArchived={showArchivedZones}
          render={({ zones, isLoading: zonesLoading, error: zonesError, refetch: refetchZones }) => {
            if (zonesLoading) return <GenericLoaderComponent />;
            if (zonesError) return <GenericErrorComponent {...describe(zonesError)} onRetry={refetchZones} />;
            const knownBlocks = [...new Set(zones.map((zone) => zone.block))];
            return (
              <>
                {zones.length === 0 ? (
                  <GenericEmptyComponent message={t("sites:detail.noZones")} />
                ) : (
                  <ZonesByBlock
                    zones={zones}
                    canEdit={canEditZones}
                    canArchive={canArchiveZones}
                    onEdit={(zone) => setDialog({ kind: "editZone", zone })}
                    onArchive={(zone) => setDialog({ kind: "archiveZone", zone })}
                    onRestore={(zone) => setDialog({ kind: "restoreZone", zone })}
                  />
                )}
                {dialog?.kind === "addZone" || dialog?.kind === "editZone" ? (
                  <ZoneFormModalContainer
                    siteId={siteId}
                    zone={dialog.kind === "editZone" ? dialog.zone : undefined}
                    knownBlocks={knownBlocks}
                    onClose={closeDialog}
                  />
                ) : null}
              </>
            );
          }}
        />
      </Paper>

      {canSeeMembers ? (
        <Paper withBorder p="md" component="section" aria-labelledby="site-members">
          <Title order={2} size="h4" id="site-members" mb="sm">
            {t("sites:detail.sections.members")}
          </Title>
          <SiteMembersList members={members?.items ?? []} />
        </Paper>
      ) : null}

      <Divider />
      <AuditLine audit={site} />

      {dialog?.kind === "editSite" ? (
        <SiteFormModalContainer site={site} onClose={closeDialog} onSaved={closeDialog} />
      ) : null}

      <GenericConfirmDialogComponent
        opened={dialog?.kind === "archiveSite"}
        danger
        title={t("sites:archive.confirmTitle")}
        message={t("sites:archive.confirmMessage")}
        confirmLabel={t("common:actions.archive")}
        loading={archiveSiteState.isLoading}
        onCancel={closeDialog}
        onConfirm={() => void run(() => archiveSite({ siteId }).unwrap(), t("sites:archive.done"))}
      />
      <GenericConfirmDialogComponent
        opened={dialog?.kind === "restoreSite"}
        title={t("sites:archive.restoreTitle")}
        message={t("sites:archive.restoreMessage")}
        confirmLabel={t("common:actions.restore")}
        loading={restoreSiteState.isLoading}
        onCancel={closeDialog}
        onConfirm={() => void run(() => restoreSite({ siteId }).unwrap(), t("sites:archive.restored"))}
      />
      <GenericConfirmDialogComponent
        opened={dialog?.kind === "archiveZone"}
        danger
        title={t("sites:zones.archiveConfirmTitle")}
        message={t("sites:zones.archiveConfirmMessage")}
        confirmLabel={t("common:actions.archive")}
        loading={archiveZoneState.isLoading}
        onCancel={closeDialog}
        onConfirm={() =>
          dialog?.kind === "archiveZone" &&
          void run(() => archiveZone({ siteId, zoneId: dialog.zone.id }).unwrap(), t("sites:zones.archivedDone"))
        }
      />
      <GenericConfirmDialogComponent
        opened={dialog?.kind === "restoreZone"}
        title={t("sites:zones.restoreConfirmTitle")}
        message={t("sites:zones.restoreConfirmMessage")}
        confirmLabel={t("common:actions.restore")}
        loading={restoreZoneState.isLoading}
        onCancel={closeDialog}
        onConfirm={() =>
          dialog?.kind === "restoreZone" &&
          void run(() => restoreZone({ siteId, zoneId: dialog.zone.id }).unwrap(), t("sites:zones.restoredDone"))
        }
      />
    </Stack>
  );
};

const BackToList = () => {
  const { t } = useTranslation("sites");
  return (
    <Anchor component={Link} to={BACK_OFFICE_ROUTES.SITES}>
      <Group gap={4} wrap="nowrap" component="span">
        <IconArrowLeft size={16} className="rtl-flip" aria-hidden />
        {t("detail.backToList")}
      </Group>
    </Anchor>
  );
};

