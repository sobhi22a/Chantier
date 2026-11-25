/**
 * URL de base de l'API (variable `VITE_BACKEND_API_BASE_URL`).
 * Lue au premier appel et non à l'import : un test ou un outil qui importe la bibliothèque
 * sans lancer de requête n'a pas besoin de la définir.
 */
export const getApiBaseUrl = (): string => {
  const value = import.meta.env.VITE_BACKEND_API_BASE_URL;
  if (!value) {
    throw new Error("VITE_BACKEND_API_BASE_URL n'est pas définie (voir .env.example).");
  }
  return value.replace(/\/+$/, "");
};
