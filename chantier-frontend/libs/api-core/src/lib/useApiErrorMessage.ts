import { useTranslation } from "react-i18next";

import { isApiError, UNKNOWN_ERROR_CODE } from "./apiError";

export interface ApiErrorMessage {
  /** Message traduit selon le `code` (jamais le texte du serveur) ; code inconnu : message générique. */
  message: string;
  /** « Référence pour le support : … » quand le serveur a fourni un `traceId`. */
  reference: string | null;
}

/**
 * Traduit une erreur d'API (`ApiError`) dans la langue courante : `errors:<CODE>` (ADR 0007).
 * Un code que le client ne connaît pas (ensemble ouvert) donne le message générique plus la référence du support.
 */
export const useApiErrorMessage = () => {
  const { t, i18n } = useTranslation("errors");

  // Les clés viennent du serveur (code d'erreur) : elles ne peuvent pas être typées à l'avance.
  // `i18n.t` lit la langue AU MOMENT DE L'APPEL : une erreur qui arrive juste après un changement de langue
  // (fermeture d'un rendu précédent) s'affiche quand même dans la bonne langue.
  const translate = (key: string, options?: Record<string, unknown>): string =>
    (i18n.t as unknown as (key: string, options?: Record<string, unknown>) => string)(key, { ns: "errors", ...options });

  const getMessage = (error: unknown): string => {
    const code = isApiError(error) ? error.code : UNKNOWN_ERROR_CODE;
    return i18n.exists(`errors:${code}`) ? translate(code) : translate(UNKNOWN_ERROR_CODE);
  };

  const getReference = (error: unknown): string | null =>
    isApiError(error) && error.traceId ? translate("reference", { traceId: error.traceId }) : null;

  const describe = (error: unknown): ApiErrorMessage => ({ message: getMessage(error), reference: getReference(error) });

  return { t, getMessage, getReference, describe };
};
