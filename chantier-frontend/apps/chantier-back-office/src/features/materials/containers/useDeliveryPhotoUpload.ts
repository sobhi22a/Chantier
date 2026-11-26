import { useRef, useState } from "react";
import { useTranslation } from "react-i18next";

import { isApiError, useApiErrorMessage, usePhotosCreateMutation, usePhotosUploadMutation } from "@chantier-frontend/api-core";
import { useNotifications } from "@chantier-frontend/user-interface";

import { PhotoImageError, preparePhoto, type PreparedPhoto } from "../types/photoImage";

const DEFAULT_MAX_PHOTO_BYTES = 5_242_880;

export interface DeliveryPhotoUploadOptions {
  siteId: string;
  deliveryId: string;
  number: string;
  /** Taille maximale du JPEG envoyé (réglage du serveur) ; défaut 5 Mo. */
  maxPhotoBytes?: number;
}

/** Envoi interrompu qu'un nouvel essai peut reprendre : on garde le fichier réduit, le `clientId` et la photo déjà créée. */
interface Attempt {
  key: string;
  file: File;
  clientId: string;
  prepared: PreparedPhoto;
  /** Identifiant de la photo `Pending` créée par le premier essai : le nouvel essai ne refait que le `PUT`. */
  photoId?: string;
}

const fileKey = (file: File): string => `${file.name}:${file.size}:${file.lastModified}`;

/** Panne qu'un nouvel essai peut résoudre (réseau, serveur, `ERREUR_TEMPORAIRE`) ; un refus du serveur (413, 415, 422) ne se rejoue pas. */
const isRecoverable = (error: unknown): boolean => isApiError(error) && (error.status === "NETWORK" || error.status >= 500);

/**
 * Ajout d'une photo de bon (ADR 0013) en deux temps : métadonnées (`POST …/photos`, idempotent par `clientId`) puis fichier
 * (`PUT …/content`). Le JPEG est réduit avant l'envoi. Une photo `Pending` occupe une place 24 h (R2-05) : après un échec
 * reprenable, le nouvel essai (« Réessayer l'envoi », ou le même fichier choisi à nouveau) réutilise le même `clientId` et la photo
 * déjà créée, au lieu d'en créer une autre (revue R3-04). Un refus définitif du serveur abandonne l'essai.
 */
export const useDeliveryPhotoUpload = ({ siteId, deliveryId, number, maxPhotoBytes = DEFAULT_MAX_PHOTO_BYTES }: DeliveryPhotoUploadOptions) => {
  const { t } = useTranslation("materials");
  const { getMessage } = useApiErrorMessage();
  const { showNotification } = useNotifications();
  const [createPhoto] = usePhotosCreateMutation();
  const [uploadPhoto] = usePhotosUploadMutation();
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [canRetry, setCanRetry] = useState(false);
  const attempt = useRef<Attempt | null>(null);

  const run = async (file: File) => {
    setError(null);
    setCanRetry(false);
    setUploading(true);
    try {
      const key = fileKey(file);
      if (attempt.current?.key !== key) {
        const prepared = await preparePhoto(file);
        if (prepared.sizeBytes > maxPhotoBytes) {
          attempt.current = null;
          setError(t("deliveries.photos.tooBig"));
          return;
        }
        attempt.current = { key, file, clientId: crypto.randomUUID(), prepared };
      }
      const current = attempt.current as Attempt;
      if (!current.photoId) {
        const metadata = await createPhoto({
          siteId,
          deliveryId,
          createPhotoRequest: {
            clientId: current.clientId,
            takenAt: new Date(current.file.lastModified || Date.now()).toISOString(),
            contentType: "image/jpeg",
            sizeBytes: current.prepared.sizeBytes,
            sha256: current.prepared.sha256,
          },
        }).unwrap();
        current.photoId = metadata.id;
      }
      try {
        await uploadPhoto({ siteId, photoId: current.photoId, body: current.prepared.blob }).unwrap();
      } catch (uploadError) {
        // Fichier déjà reçu (un essai précédent est arrivé jusqu'au bout) : c'est un succès.
        if (!(isApiError(uploadError) && uploadError.code === "PHOTO_DEJA_ENVOYEE")) throw uploadError;
      }
      attempt.current = null;
      showNotification({ type: "success", message: t("deliveries.photos.sent", { number }) });
    } catch (caught) {
      if (caught instanceof PhotoImageError) {
        attempt.current = null;
        setError(t(caught.code === "notJpeg" ? "deliveries.photos.notJpeg" : "deliveries.photos.unreadable"));
      } else {
        const recoverable = isRecoverable(caught);
        if (!recoverable) attempt.current = null;
        setCanRetry(recoverable);
        setError(getMessage(caught));
      }
    } finally {
      setUploading(false);
    }
  };

  const retry = () => {
    if (attempt.current) void run(attempt.current.file);
  };

  return { add: run, retry, canRetry, uploading, error };
};
