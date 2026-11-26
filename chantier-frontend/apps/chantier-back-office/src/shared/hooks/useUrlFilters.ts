import { useSearchParams } from "react-router-dom";

/**
 * Filtres, tri et page d'une liste dans l'URL (lien partageable, retour arrière fidèle).
 * Une valeur vide retire le paramètre ; tout changement de filtre revient à la première page.
 */
export const useUrlFilters = () => {
  const [params, setParams] = useSearchParams();

  const update = (changes: Record<string, string | null>) =>
    setParams(
      (previous) => {
        const next = new URLSearchParams(previous);
        for (const [key, value] of Object.entries(changes)) {
          if (value === null || value === "") next.delete(key);
          else next.set(key, value);
        }
        if (!("page" in changes)) next.delete("page");
        return next;
      },
      { replace: true },
    );

  const page = Math.max(1, Number(params.get("page")) || 1);

  return { params, update, page };
};
