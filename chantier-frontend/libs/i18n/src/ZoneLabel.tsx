import { Fragment, type ReactNode } from "react";
import { useTranslation } from "react-i18next";

import { Ltr } from "./Ltr";
import { buildZoneLabelParts, ZONE_LABEL_SEPARATOR, type ZoneLabelInput } from "./zoneLabelParts";

export interface ZoneLabelProps {
  zone: ZoneLabelInput;
  /** Sans le bloc : pour une ligne rangée sous un titre de bloc. Une zone réduite au bloc affiche alors « Bloc entier ». */
  hideBlock?: boolean;
}

/** `Bloc 01 · +3,40 m · Classe 02`, la cote restant lisible de gauche à droite en arabe. */
export const ZoneLabel = ({ zone, hideBlock = false }: ZoneLabelProps) => {
  const { t } = useTranslation(["sites", "common"]);
  const parts = buildZoneLabelParts(zone, {
    roomTypeName: (type) => t(`sites:roomTypes.${type}`),
    meter: t("common:units.meter"),
  });

  const nodes: ReactNode[] = [];
  if (!hideBlock) nodes.push(<bdi key="block">{parts.block}</bdi>);
  if (parts.elevation) nodes.push(<Ltr key="elevation">{parts.elevation}</Ltr>);
  if (parts.room) nodes.push(<bdi key="room">{parts.room}</bdi>);
  if (nodes.length === 0) nodes.push(<Fragment key="whole">{t("sites:zones.wholeBlock")}</Fragment>);

  return (
    <span>
      {nodes.map((node, index) => (
        <Fragment key={index}>
          {index > 0 ? ZONE_LABEL_SEPARATOR : null}
          {node}
        </Fragment>
      ))}
    </span>
  );
};
