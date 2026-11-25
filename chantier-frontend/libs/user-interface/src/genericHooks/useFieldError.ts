import type { FieldError } from "react-hook-form";
import { useTranslation } from "react-i18next";

/**
 * Message d'un champ de formulaire, traduit à l'affichage : Zod et le serveur posent des clés (`sites:form.required`,
 * `errors:ZONE_EXISTANTE`), jamais du texte (ADR 0007). Un changement de langue retraduit donc le message déjà affiché.
 */
export const useFieldError = () => {
  const { t } = useTranslation();
  // Les clés viennent des schémas et du serveur : elles ne peuvent pas être typées à l'avance.
  const translate = t as unknown as (key: string) => string;
  return (error: Pick<FieldError, "message"> | undefined): string | undefined =>
    error?.message ? translate(error.message) : undefined;
};
