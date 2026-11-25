import type { Language } from "./languages";

/** Nom arabe s'il existe et que l'interface est en arabe, sinon nom français (H-20, CA-014.6). */
export const pickLocalizedName = (names: { name: string; nameAr?: string | null }, language: Language): string => {
  const arabicName = names.nameAr?.trim();
  return language === "ar" && arabicName ? arabicName : names.name;
};
