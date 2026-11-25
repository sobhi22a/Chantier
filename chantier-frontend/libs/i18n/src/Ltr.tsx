import type { ReactNode } from "react";

export interface LtrProps {
  children: ReactNode;
  className?: string;
}

/**
 * Isole une valeur lue de gauche à droite (code `CH-ECO-UV18`, date, montant, cote) au milieu d'un texte arabe.
 * Sans cela, « +3,40 » s'afficherait « 3,40+ » dans une page de droite à gauche (CA-014.4).
 */
export const Ltr = ({ children, className }: LtrProps) => (
  <bdi dir="ltr" className={className}>
    {children}
  </bdi>
);
