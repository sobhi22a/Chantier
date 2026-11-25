import { ActionIcon, Badge, Button, Group, List, Stack, Text, UnstyledButton } from "@mantine/core";
import { IconArchive, IconArchiveOff, IconChevronDown, IconChevronUp, IconPencil } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import type { ZoneResponse } from "@chantier-frontend/api-core";
import { formatZoneLabel, ZoneLabel, type RoomType } from "@chantier-frontend/i18n";

import { groupZonesByBlock } from "../types/zoneGrouping";

/** Au-delà de ce nombre de zones, les blocs sont repliés à l'ouverture (fiche légère même avec 5 000 zones). */
export const COLLAPSE_ABOVE_ZONES = 150;
/** Nombre de zones affichées d'un bloc à l'ouverture, puis ajoutées à chaque « Afficher plus ». */
export const ZONES_PER_STEP = 100;

export interface ZonesByBlockProps {
  zones: readonly ZoneResponse[];
  /** Actions absentes (et non grisées) quand l'utilisateur n'a pas la permission ou que le chantier est archivé. */
  canEdit: boolean;
  canArchive: boolean;
  onEdit: (zone: ZoneResponse) => void;
  onArchive: (zone: ZoneResponse) => void;
  onRestore: (zone: ZoneResponse) => void;
}

/**
 * Zones groupées par bloc ; dans chaque bloc, du plus bas au plus haut, cote signée (`+3,40 m`).
 * Performance (S-1) : au-delà de 150 zones les blocs sont repliés, et un bloc ouvert montre ses zones par tranches de
 * 100. Le nombre de nœuds du DOM reste borné quel que soit le nombre de zones du chantier.
 */
export const ZonesByBlock = ({ zones, canEdit, canArchive, onEdit, onArchive, onRestore }: ZonesByBlockProps) => {
  const { t } = useTranslation(["sites", "common"]);
  // Choix de l'utilisateur seulement ; sans choix, l'état par défaut dépend du nombre total de zones (pas d'effet).
  const [toggled, setToggled] = useState<ReadonlyMap<string, boolean>>(new Map());
  const [shown, setShown] = useState<ReadonlyMap<string, number>>(new Map());
  const openByDefault = zones.length <= COLLAPSE_ABOVE_ZONES;

  const isOpen = (block: string): boolean => toggled.get(block) ?? openByDefault;
  const toggle = (block: string) => setToggled((previous) => new Map(previous).set(block, !isOpen(block)));
  const showMore = (block: string) =>
    setShown((previous) => new Map(previous).set(block, (previous.get(block) ?? ZONES_PER_STEP) + ZONES_PER_STEP));

  // Texte lu par les lecteurs d'écran pour les boutons d'action : libellé complet de la zone.
  const plainLabel = (zone: ZoneResponse): string =>
    formatZoneLabel(zone, {
      roomTypeName: (type: RoomType) => t(`sites:roomTypes.${type}`),
      meter: t("common:units.meter"),
    });

  return (
    <Stack gap="lg">
      {groupZonesByBlock(zones).map((group) => {
        const open = isOpen(group.block);
        const visibleCount = shown.get(group.block) ?? ZONES_PER_STEP;
        const visibleZones = group.zones.slice(0, visibleCount);
        const regionId = `zones-block-${group.block}`;

        return (
          <section key={group.block} aria-label={group.block}>
            <UnstyledButton
              onClick={() => toggle(group.block)}
              aria-expanded={open}
              aria-controls={regionId}
              w="100%"
              mb="xs"
              py={6}
            >
              <Group justify="space-between" wrap="nowrap">
                <Group gap="xs" wrap="nowrap">
                  {open ? <IconChevronUp size={18} aria-hidden /> : <IconChevronDown size={18} aria-hidden />}
                  <Text component="h3" fw={700} m={0}>
                    <bdi>{group.block}</bdi>
                  </Text>
                </Group>
                <Text size="sm" c="dimmed">
                  {t("sites:zones.blockCount", { count: group.zones.length })}
                </Text>
              </Group>
            </UnstyledButton>
            <div id={regionId} hidden={!open}>
              {open ? (
                <>
                  <List listStyleType="none" spacing="xs">
                    {visibleZones.map((zone) => {
                      const archived = zone.archivedAt !== null;
                      return (
                        <List.Item key={zone.id} styles={{ itemWrapper: { width: "100%" }, itemLabel: { width: "100%" } }}>
                          <Group justify="space-between" wrap="nowrap">
                            <Group gap="sm">
                              <Text td={archived ? "line-through" : undefined} c={archived ? "dimmed" : undefined}>
                                <ZoneLabel zone={zone} hideBlock />
                              </Text>
                              {archived ? (
                                <Badge color="gray" variant="light" leftSection={<IconArchive size={14} aria-hidden />}>
                                  {t("sites:zones.archived")}
                                </Badge>
                              ) : null}
                            </Group>
                            <Group gap="xs" wrap="nowrap">
                              {canEdit && !archived ? (
                                <ActionIcon
                                  variant="subtle"
                                  color="gray"
                                  aria-label={t("sites:zones.editAria", { zone: plainLabel(zone) })}
                                  onClick={() => onEdit(zone)}
                                >
                                  <IconPencil size={18} aria-hidden />
                                </ActionIcon>
                              ) : null}
                              {canArchive && !archived ? (
                                <ActionIcon
                                  variant="subtle"
                                  color="gray"
                                  aria-label={t("sites:zones.archiveAria", { zone: plainLabel(zone) })}
                                  onClick={() => onArchive(zone)}
                                >
                                  <IconArchive size={18} aria-hidden />
                                </ActionIcon>
                              ) : null}
                              {canArchive && archived ? (
                                <ActionIcon
                                  variant="subtle"
                                  color="gray"
                                  aria-label={t("sites:zones.restoreAria", { zone: plainLabel(zone) })}
                                  onClick={() => onRestore(zone)}
                                >
                                  <IconArchiveOff size={18} aria-hidden />
                                </ActionIcon>
                              ) : null}
                            </Group>
                          </Group>
                        </List.Item>
                      );
                    })}
                  </List>
                  {group.zones.length > visibleCount ? (
                    <Group mt="sm" gap="sm">
                      <Button variant="default" onClick={() => showMore(group.block)}>
                        {t("sites:zones.loadMore")}
                      </Button>
                      <Text size="sm" c="dimmed">
                        {t("sites:zones.shownOf", { shown: visibleCount, total: group.zones.length })}
                      </Text>
                    </Group>
                  ) : null}
                </>
              ) : null}
            </div>
          </section>
        );
      })}
    </Stack>
  );
};
