import type { Direction } from "./languages";
import { useLanguage } from "./useLanguage";

/** Sens d'écriture de la langue courante : `rtl` en arabe, `ltr` en français. */
export const useDirection = (): Direction => useLanguage().direction;
