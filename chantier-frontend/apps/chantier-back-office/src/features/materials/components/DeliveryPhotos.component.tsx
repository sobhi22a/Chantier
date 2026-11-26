import { Alert, Badge, Button, FileInput, Group, Image, Loader, Modal, SimpleGrid, Stack, Text, Title, UnstyledButton } from "@mantine/core";
import { IconAlertTriangle, IconPhotoPlus } from "@tabler/icons-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";

import { usePhotoContentQuery, type DeliveryPhotoItem } from "@chantier-frontend/api-core";
import { Ltr } from "@chantier-frontend/i18n";

/**
 * Photo du bon lue avec la session (cookie) : jamais d'URL publique (ADR 0013). Le JPEG se charge à la demande ; un clic
 * l'agrandit. Une photo dont l'envoi n'est pas terminé (`Pending`) n'a pas de fichier : elle est signalée, pas affichée.
 */
const PhotoThumb = ({ siteId, photo, index }: { siteId: string; photo: DeliveryPhotoItem; index: number }) => {
  const { t } = useTranslation("materials");
  const [opened, setOpened] = useState(false);
  const pending = photo.contentStatus !== "Uploaded";
  const { data: url, isLoading, isError } = usePhotoContentQuery({ siteId, photoId: photo.id }, { skip: pending });

  if (pending) {
    return (
      <Badge color="orange" variant="light" size="lg" leftSection={<IconAlertTriangle size={14} aria-hidden />}>
        {t("deliveries.photos.pending")}
      </Badge>
    );
  }
  if (isLoading) return <Loader size="sm" aria-label={t("deliveries.photos.loading")} />;
  if (isError || !url) {
    return (
      <Text size="sm" c="dimmed">
        {t("deliveries.photos.unavailable")}
      </Text>
    );
  }

  return (
    <>
      <UnstyledButton onClick={() => setOpened(true)} aria-label={t("deliveries.photos.open", { index })} mih={24}>
        <Image src={url} alt={t("deliveries.photos.alt", { index })} h={110} w="auto" fit="cover" radius="sm" loading="lazy" />
      </UnstyledButton>
      <Modal opened={opened} onClose={() => setOpened(false)} size="xl" title={t("deliveries.photos.alt", { index })} closeButtonProps={{ "aria-label": t("deliveries.photos.close") }}>
        <Image src={url} alt={t("deliveries.photos.alt", { index })} fit="contain" mah="75vh" />
      </Modal>
    </>
  );
};

export interface DeliveryPhotosProps {
  siteId: string;
  /** Photos renvoyées par le serveur : absentes sans `DeliveryPhotos.View`. */
  photos: readonly DeliveryPhotoItem[] | null | undefined;
  photoCount: number;
  canView: boolean;
  /** `DeliveryPhotos.Create` et livraison encore modifiable. */
  canAdd: boolean;
  max: number;
  uploading: boolean;
  /** Message traduit de la dernière erreur d'envoi. */
  error: string | null;
  onAdd: (file: File) => void;
  /** Un échec reprenable (réseau, serveur) : « Réessayer l'envoi » reprend la même photo, sans en créer une autre. */
  canRetry?: boolean;
  onRetry?: () => void;
}

/** Photos du bon : vignettes authentifiées, 5 au plus, ajout d'un JPEG réduit avant l'envoi. */
export const DeliveryPhotos = ({ siteId, photos, photoCount, canView, canAdd, max, uploading, error, onAdd, canRetry = false, onRetry }: DeliveryPhotosProps) => {
  const { t } = useTranslation("materials");
  // Les photos en attente d'envoi occupent aussi une place (24 h) : on compte celles que le serveur liste, pas seulement les reçues.
  const used = Math.max(photoCount, photos?.length ?? 0);
  const atLimit = used >= max;

  return (
    <Stack gap="sm" role="group" aria-label={t("deliveries.photos.title")}>
      <Group justify="space-between" align="center">
        <Title order={3} size="h4">
          {t("deliveries.photos.title")}
        </Title>
        <Text size="sm" c="dimmed">
          <Ltr>{t("deliveries.photos.count", { count: used, max })}</Ltr>
        </Text>
      </Group>

      {canView ? (
        photos && photos.length > 0 ? (
          <SimpleGrid cols={{ base: 2, sm: 3 }} spacing="sm">
            {photos.map((photo, position) => (
              <PhotoThumb key={photo.id} siteId={siteId} photo={photo} index={position + 1} />
            ))}
          </SimpleGrid>
        ) : (
          <Text c="dimmed">{t("deliveries.photos.none")}</Text>
        )
      ) : (
        <Text c="dimmed">{t("deliveries.photos.forbidden")}</Text>
      )}

      {error ? (
        <Alert color="red" variant="light" icon={<IconAlertTriangle aria-hidden />} role="alert">
          <Stack gap="xs" align="flex-start">
            {error}
            {canRetry && onRetry ? (
              <Button variant="default" size="compact-md" onClick={onRetry} disabled={uploading}>
                {t("deliveries.photos.retry")}
              </Button>
            ) : null}
          </Stack>
        </Alert>
      ) : null}

      {canAdd ? (
        atLimit ? (
          <Text size="sm" c="orange.9">
            {t("deliveries.photos.limit", { count: max })}
          </Text>
        ) : (
          <FileInput
            label={t("deliveries.photos.add")}
            description={t("deliveries.photos.addHelp")}
            accept="image/jpeg"
            leftSection={<IconPhotoPlus size={16} aria-hidden />}
            value={null}
            disabled={uploading}
            onChange={(file) => {
              if (file) onAdd(file);
            }}
          />
        )
      ) : null}
      {uploading ? (
        <Group gap="xs" role="status">
          <Loader size="xs" />
          <Text size="sm">{t("deliveries.photos.sending")}</Text>
        </Group>
      ) : null}
    </Stack>
  );
};
