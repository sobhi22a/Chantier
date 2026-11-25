import { SimpleGrid, Text, Title } from "@mantine/core";
import type { ReactNode } from "react";
import { useTranslation } from "react-i18next";

import type { SiteResponse } from "@chantier-frontend/api-core";
import { formatAmount, formatDateOnly, formatNumber, Ltr, pickLocalizedName, useLanguage } from "@chantier-frontend/i18n";

const Field = ({ label, children }: { label: string; children: ReactNode }) => (
  <div>
    <Text component="dt" size="sm" c="dimmed">
      {label}
    </Text>
    <Text component="dd" m={0} fw={500}>
      {children}
    </Text>
  </div>
);

/**
 * Informations et marché d'un chantier. Les valeurs calculées (fin contractuelle) viennent du serveur ; le montant
 * n'existe que si le serveur l'a envoyé (CT-20) : sans permission, la ligne n'est pas affichée du tout.
 */
export const SiteInfo = ({ site }: { site: SiteResponse }) => {
  const { t } = useTranslation(["sites", "common"]);
  const { language } = useLanguage();
  const toBeDefined = t("sites:detail.toBeDefined");
  const odsDate = formatDateOnly(site.odsDate);
  const contractualEnd = formatDateOnly(site.contractualEndDate);
  const hasAmount = site.contractAmount !== undefined && site.contractAmount !== null;
  const coordinates =
    site.latitude !== null && site.longitude !== null
      ? [site.latitude, site.longitude].map((value) => formatNumber(value, { maximumFractionDigits: 6 })).join(" ; ")
      : null;

  return (
    <>
      <section aria-labelledby="site-general">
        <Title order={2} size="h4" id="site-general" mb="sm">
          {t("sites:detail.sections.general")}
        </Title>
        <SimpleGrid component="dl" cols={{ base: 1, sm: 2 }} spacing="md" m={0}>
          <Field label={t("sites:detail.fields.code")}>
            <Ltr>{site.code}</Ltr>
          </Field>
          <Field label={t("sites:detail.fields.name")}>{pickLocalizedName(site, language)}</Field>
          <Field label={t("sites:detail.fields.type")}>{t(`sites:types.${site.type}`)}</Field>
          <Field label={t("sites:detail.fields.wilaya")}>{site.wilaya}</Field>
          <Field label={t("sites:detail.fields.commune")}>{site.commune}</Field>
          {coordinates ? (
            <Field label={t("sites:detail.fields.coordinates")}>
              <Ltr>{coordinates}</Ltr>
            </Field>
          ) : null}
          <Field label={t("sites:detail.fields.owner")}>{site.owner}</Field>
        </SimpleGrid>
      </section>

      <section aria-labelledby="site-contract">
        <Title order={2} size="h4" id="site-contract" mb="sm">
          {t("sites:detail.sections.contract")}
        </Title>
        <SimpleGrid component="dl" cols={{ base: 1, sm: 2 }} spacing="md" m={0}>
          <Field label={t("sites:detail.fields.contractNumber")}>
            {site.contractNumber ? <Ltr>{site.contractNumber}</Ltr> : toBeDefined}
          </Field>
          {hasAmount ? (
            <Field label={t("sites:detail.fields.contractAmount")}>
              <Ltr>{formatAmount(site.contractAmount as number)}</Ltr>
            </Field>
          ) : null}
          <Field label={t("sites:detail.fields.delay")}>
            {site.delayDays ? t("common:units.day", { count: site.delayDays }) : toBeDefined}
          </Field>
          <Field label={t("sites:detail.fields.odsDate")}>{odsDate ? <Ltr>{odsDate}</Ltr> : toBeDefined}</Field>
          <Field label={t("sites:detail.fields.contractualEnd")}>
            {contractualEnd ? <Ltr>{contractualEnd}</Ltr> : toBeDefined}
          </Field>
        </SimpleGrid>
      </section>
    </>
  );
};
