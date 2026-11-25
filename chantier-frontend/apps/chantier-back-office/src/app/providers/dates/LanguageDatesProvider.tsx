import { DatesProvider } from "@mantine/dates";
// Enregistrement des locales dayjs. `ar-dz` garde les chiffres 0-9 (la locale `ar` générique passerait
// aux chiffres arabes orientaux, contre H-10).
import "dayjs/locale/ar-dz";
import "dayjs/locale/fr";
import type { ReactNode } from "react";

import { useLanguage, type Language } from "@chantier-frontend/i18n";

const DAYJS_LOCALE: Record<Language, string> = { fr: "fr", ar: "ar-dz" };

// La semaine de travail algérienne commence le dimanche (hypothèse à confirmer, paramétrable ici).
const FIRST_DAY_OF_WEEK = 0;

/** Calendriers Mantine (`@mantine/dates`) dans la langue courante. */
export const LanguageDatesProvider = ({ children }: { children: ReactNode }) => {
  const { language } = useLanguage();

  return (
    <DatesProvider settings={{ locale: DAYJS_LOCALE[language], firstDayOfWeek: FIRST_DAY_OF_WEEK }}>
      {children}
    </DatesProvider>
  );
};
