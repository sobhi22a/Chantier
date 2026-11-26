/**
 * Préparation d'une photo de bon de livraison avant l'envoi (ADR 0013) : JPEG seulement, réduite à 1 600 px de grand côté,
 * qualité 0,7 (cible de 1 à 2 Mo). La réduction passe par un canvas, donc sans métadonnées EXIF ; le serveur retire de toute façon
 * celles qui resteraient. L'empreinte SHA-256 rend l'envoi du fichier idempotent et vérifie son intégrité.
 */
export const MAX_SIDE_PX = 1600;
export const JPEG_QUALITY = 0.7;
export const JPEG_TYPE = "image/jpeg";

export class PhotoImageError extends Error {
  constructor(readonly code: "notJpeg" | "unreadable") {
    super(code);
    this.name = "PhotoImageError";
  }
}

/** Un fichier est accepté s'il se déclare JPEG (type ou extension) ; le serveur vérifie les octets magiques. */
export const isJpegFile = (file: Pick<File, "type" | "name">): boolean =>
  file.type === JPEG_TYPE || (file.type === "" && /\.jpe?g$/i.test(file.name));

/** Dimensions après réduction : le grand côté ne dépasse pas `MAX_SIDE_PX`, jamais d'agrandissement. */
export const reducedSize = (width: number, height: number): { width: number; height: number } => {
  const longest = Math.max(width, height);
  if (longest <= MAX_SIDE_PX) return { width, height };
  const ratio = MAX_SIDE_PX / longest;
  return { width: Math.max(1, Math.round(width * ratio)), height: Math.max(1, Math.round(height * ratio)) };
};

/** Réduit une image JPEG dans un canvas. Lève `PhotoImageError("unreadable")` si le navigateur ne sait pas la lire. */
export const reduceJpeg = async (file: Blob): Promise<Blob> => {
  let bitmap: ImageBitmap;
  try {
    bitmap = await createImageBitmap(file, { imageOrientation: "from-image" });
  } catch {
    throw new PhotoImageError("unreadable");
  }
  try {
    const { width, height } = reducedSize(bitmap.width, bitmap.height);
    const canvas = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;
    const context = canvas.getContext("2d");
    if (!context) throw new PhotoImageError("unreadable");
    context.drawImage(bitmap, 0, 0, width, height);
    const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, JPEG_TYPE, JPEG_QUALITY));
    if (!blob) throw new PhotoImageError("unreadable");
    return blob;
  } finally {
    bitmap.close();
  }
};

/** Octets d'un blob : `arrayBuffer()` du navigateur, ou `FileReader` quand l'environnement n'en dispose pas (jsdom). */
const readBytes = (blob: Blob): Promise<ArrayBuffer> => {
  if (typeof blob.arrayBuffer === "function") return blob.arrayBuffer();
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result as ArrayBuffer);
    reader.onerror = () => reject(new PhotoImageError("unreadable"));
    reader.readAsArrayBuffer(blob);
  });
};

/** Empreinte SHA-256 en hexadécimal minuscule (64 caractères), calculée sur les octets envoyés. */
export const sha256Hex = async (blob: Blob): Promise<string> => {
  const digest = await crypto.subtle.digest("SHA-256", await readBytes(blob));
  return [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, "0")).join("");
};

export interface PreparedPhoto {
  blob: Blob;
  sizeBytes: number;
  sha256: string;
}

/** Fichier choisi → JPEG réduit, taille et empreinte. `reduce` est injectable pour les tests (jsdom n'a pas de canvas). */
export const preparePhoto = async (file: File, reduce: (file: Blob) => Promise<Blob> = reduceJpeg): Promise<PreparedPhoto> => {
  if (!isJpegFile(file)) throw new PhotoImageError("notJpeg");
  const blob = await reduce(file);
  return { blob, sizeBytes: blob.size, sha256: await sha256Hex(blob) };
};
