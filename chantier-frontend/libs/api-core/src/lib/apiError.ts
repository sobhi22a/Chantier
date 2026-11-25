import type { FetchBaseQueryError } from "@reduxjs/toolkit/query";

/**
 * Erreur normalisée de l'API (Problem Details, RFC 9457) : c'est la seule forme d'erreur que voient les écrans.
 * `code` est le code métier stable (`ZONE_EXISTANTE`…) que l'interface traduit ; `title` et `detail` ne sont qu'un repli.
 */
export interface ApiError {
  /** Statut HTTP, ou `NETWORK` quand le serveur n'a pas répondu. */
  status: number | "NETWORK";
  code: string;
  title?: string;
  detail?: string;
  /** Détail par champ (400 `VALIDATION`) : nom du champ en camelCase, puis les messages. */
  errors?: Record<string, string[]>;
  /** Référence à communiquer au support. */
  traceId?: string;
  /** 409 `CONFLIT_VERSION` : état actuel de la ressource. */
  current?: unknown;
}

export const NETWORK_ERROR_CODE = "NETWORK";
export const UNKNOWN_ERROR_CODE = "UNKNOWN";

export const isApiError = (value: unknown): value is ApiError =>
  typeof value === "object" &&
  value !== null &&
  typeof (value as ApiError).code === "string" &&
  ((value as ApiError).status === "NETWORK" || typeof (value as ApiError).status === "number");

const FALLBACK_CODE_BY_STATUS: Record<number, string> = {
  401: "NON_AUTHENTIFIE",
  403: "INTERDIT",
  404: "INTROUVABLE",
  429: "TROP_DE_REQUETES",
};

const isRecord = (value: unknown): value is Record<string, unknown> => typeof value === "object" && value !== null;

const asString = (value: unknown): string | undefined => (typeof value === "string" ? value : undefined);

const asFieldErrors = (value: unknown): Record<string, string[]> | undefined => {
  if (!isRecord(value)) return undefined;
  const entries = Object.entries(value).filter(
    (entry): entry is [string, string[]] => Array.isArray(entry[1]) && entry[1].every((item) => typeof item === "string"),
  );
  return entries.length > 0 ? Object.fromEntries(entries) : undefined;
};

/** Convertit l'erreur de `fetchBaseQuery` en `ApiError`, sans jamais copier le corps brut d'une réponse inattendue. */
export const toApiError = (error: FetchBaseQueryError): ApiError => {
  // Réponse non JSON (page d'erreur d'un proxy…) : on garde le statut HTTP, jamais le corps.
  const status = error.status === "PARSING_ERROR" ? error.originalStatus : error.status;
  if (typeof status !== "number") {
    return { status: "NETWORK", code: NETWORK_ERROR_CODE };
  }

  const body = isRecord((error as { data?: unknown }).data) ? ((error as { data: Record<string, unknown> }).data) : {};
  const fallback = status >= 500 ? "ERREUR_INTERNE" : (FALLBACK_CODE_BY_STATUS[status] ?? UNKNOWN_ERROR_CODE);

  return {
    status,
    code: asString(body["code"]) ?? fallback,
    title: asString(body["title"]),
    detail: asString(body["detail"]),
    errors: asFieldErrors(body["errors"]),
    traceId: asString(body["traceId"]),
    current: body["current"],
  };
};
