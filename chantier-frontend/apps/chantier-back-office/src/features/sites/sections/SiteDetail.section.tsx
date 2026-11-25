import { useParams } from "react-router-dom";

import { SiteDetailContainer } from "../containers/SiteDetail.container";

/** Fiche d'un chantier (route `/sites/:siteId`). */
const SiteDetailSection = () => {
  const { siteId } = useParams<{ siteId: string }>();
  return siteId ? <SiteDetailContainer key={siteId} siteId={siteId} /> : null;
};

export default SiteDetailSection;
