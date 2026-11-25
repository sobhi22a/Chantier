import type { FieldValues, Path, UseFormSetError } from "react-hook-form";

import { isApiError } from "@chantier-frontend/api-core";

/** Code d'erreur métier → champ du formulaire qui doit le porter (ex. `ZONE_EXISTANTE` n'a pas de champ : alerte du formulaire). */
export type CodeToField<T extends FieldValues> = Partial<Record<string, Path<T>>>;

/**
 * Rattache une erreur Problem Details aux champs du formulaire.
 * Les messages posés sont des **clés de traduction** (`errors:<CODE>`), traduites à l'affichage par `useFieldError` :
 * le texte du serveur n'est jamais affiché tel quel. Renvoie `true` si au moins un champ a été renseigné.
 */
export const applyServerErrors = <T extends FieldValues>(
  error: unknown,
  setError: UseFormSetError<T>,
  codeToField: CodeToField<T> = {},
): boolean => {
  if (!isApiError(error)) return false;

  let attached = false;
  const field = codeToField[error.code];
  if (field) {
    setError(field, { type: "server", message: `errors:${error.code}` });
    attached = true;
  }
  for (const name of Object.keys(error.errors ?? {})) {
    // Un champ déjà porteur du code métier garde son message précis.
    if (name === field) continue;
    setError(name as Path<T>, { type: "server", message: "errors:FIELD_INVALID" });
    attached = true;
  }
  return attached;
};
