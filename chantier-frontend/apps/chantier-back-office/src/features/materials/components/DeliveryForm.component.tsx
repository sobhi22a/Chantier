import { zodResolver } from "@hookform/resolvers/zod";
import { Alert, Button, Group, SegmentedControl, Select, Stack, Text, Textarea, TextInput } from "@mantine/core";
import { DatePickerInput } from "@mantine/dates";
import { IconAlertTriangle, IconInfoCircle } from "@tabler/icons-react";
import { useState } from "react";
import { Controller, useForm, useWatch } from "react-hook-form";
import { useTranslation } from "react-i18next";

import { isApiError, type MaterialRequestResponse, type ProductResponse, type SiteResponse } from "@chantier-frontend/api-core";
import { formatPercent, MEASURE_UNITS, pickLocalizedName, todayDateOnly, useLanguage, useQuantityFormatter, type MeasureUnitCode } from "@chantier-frontend/i18n";
import { applyServerErrors, useFieldError, type CodeToField } from "@chantier-frontend/user-interface";

import { FormSubmitAlerts } from "../../../shared/components/FormSubmitAlerts";
import {
  deliveryFormSchema,
  deliveryToFormValues,
  OTHER_REASON,
  requestDefaults,
  RESERVE_NOTE_MAX,
  type DeliveryFormValues,
} from "../types/deliveryForm.zod";
import { DELIVERY_NOTE_MAX, MASS_UNITS, type DeliveryDetail } from "../types/deliveryTypes";
import {
  announceDelivery,
  equivalenceFor,
  milliToText,
  normalizeQuantityText,
  numberToMilli,
  parseMilli,
  type MilliQuantity,
} from "../types/quantityMirror";
import { DeliveryRequestSelect } from "./DeliveryRequestSelect.component";
import { ProductSelect, useCatalogProduct } from "./ProductSelect.component";
import { SupplierSelect } from "./SupplierSelect.component";

export interface DeliveryFormProps {
  mode: "create" | "edit";
  initialValues: DeliveryFormValues;
  /** Chantiers proposés à la création (affectés et non archivés). */
  sites: readonly SiteResponse[];
  /** Demande de départ : livraison saisie depuis une demande, ou demande de la livraison corrigée. */
  initialRequest: MaterialRequestResponse | null;
  /** Livraison corrigée : sa propre quantité est retirée du reçu cumulé pour annoncer le résultat de la correction. */
  delivery?: DeliveryDetail;
  /** Listes de motifs et tolérance du serveur (`GET /settings/materials`). */
  reserveReasons: readonly string[];
  tolerancePercent: number;
  onSubmit: (values: DeliveryFormValues) => Promise<unknown>;
  onCancel: () => void;
  onConflictReload?: (current: DeliveryDetail) => void;
}

const CODE_TO_FIELD: CodeToField<DeliveryFormValues> = {
  QUANTITE_INVALIDE: "quantity",
  QUANTITE_ENTIERE_REQUISE: "quantity",
  UNITE_OBLIGATOIRE: "unit",
  UNITE_NON_AUTORISEE: "unit",
  UNITES_INCOMPATIBLES: "unit",
  DATE_INVALIDE: "deliveryDate",
  PRODUIT_DIFFERENT: "productId",
  PRODUIT_INACTIF: "productId",
  FOURNISSEUR_INACTIF: "supplierId",
};

/**
 * Unités proposées pour une quantité reçue : avec une demande, celle de la commande ou une unité convertible (sac, kg, T avec
 * la masse du sac) ; sans demande, celles du produit du catalogue (toutes pour un produit hors catalogue). Jamais un texte libre.
 */
export const deliveryUnitOptions = (requestUnit: string | null, product: ProductResponse | undefined, free: boolean): MeasureUnitCode[] => {
  const known = (units: readonly string[]): MeasureUnitCode[] => MEASURE_UNITS.filter((unit) => units.includes(unit));
  if (requestUnit) {
    if (!MASS_UNITS.includes(requestUnit)) return known([requestUnit]);
    const fromProduct = product ? product.allowedUnits.filter((unit) => MASS_UNITS.includes(unit)) : [...MASS_UNITS];
    return known([...new Set([...fromProduct, requestUnit])]);
  }
  if (free) return [...MEASURE_UNITS];
  return known(product?.allowedUnits ?? []);
};

/**
 * Formulaire de livraison (création et correction) : demande liée, produit, fournisseur, quantité AVEC unité, date, n° de BL,
 * conformité et réserve. L'annonce « partielle / complète / surplus » est indicative : le serveur recalcule le statut
 * et sa valeur fait foi (le client n'écrit jamais un statut ni un total).
 */
export const DeliveryForm = ({
  mode,
  initialValues,
  sites,
  initialRequest,
  delivery,
  reserveReasons,
  tolerancePercent,
  onSubmit,
  onCancel,
  onConflictReload,
}: DeliveryFormProps) => {
  const { t, i18n } = useTranslation(["materials", "common"]);
  const { language } = useLanguage();
  const { quantityText, unitName } = useQuantityFormatter();
  const fieldError = useFieldError();
  const [submitError, setSubmitError] = useState<unknown>(null);
  const [selectedRequest, setSelectedRequest] = useState<MaterialRequestResponse | null>(initialRequest);
  const isEdit = mode === "edit";

  const {
    register,
    control,
    handleSubmit,
    setError,
    setValue,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<DeliveryFormValues>({ resolver: zodResolver(deliveryFormSchema), defaultValues: initialValues });

  const values = useWatch({ control });
  const siteId = values.siteId ?? "";
  const productMode = values.productMode ?? "catalog";
  const supplierMode = values.supplierMode ?? "catalog";
  const hasRequest = (values.requestId ?? "") !== "";
  const unit = values.unit ?? "";
  const conformity = values.conformity ?? "Conform";

  // Produit pour l'unité et la masse du sac : celui de la demande liée, sinon celui qu'on choisit.
  const catalogProductId = hasRequest ? (selectedRequest?.product.productId ?? null) : productMode === "catalog" ? (values.productId ?? null) : null;
  const catalogProduct = useCatalogProduct(catalogProductId);
  const unitOptions = deliveryUnitOptions(hasRequest ? (selectedRequest?.quantity.unit ?? null) : null, catalogProduct, !hasRequest && productMode === "free");

  const submit = async (formValues: DeliveryFormValues) => {
    setSubmitError(null);
    const error = await onSubmit(formValues);
    if (!error) return;
    const isConflict = isApiError(error) && error.code === "CONFLIT_VERSION";
    if (isConflict || !applyServerErrors(error, setError, CODE_TO_FIELD)) setSubmitError(error);
  };

  const chooseRequest = (request: MaterialRequestResponse | null) => {
    setSelectedRequest(request);
    setValue("requestId", request?.id ?? "", { shouldValidate: false });
    if (!request) return;
    // Valeurs par défaut issues du serveur : produit et unité de la demande, quantité = reste à livrer, fournisseur de la commande.
    for (const [name, value] of Object.entries(requestDefaults(request))) {
      setValue(name as keyof DeliveryFormValues, value as never, { shouldValidate: false });
    }
  };

  // Annonce avant l'enregistrement (CA-MAT-006.3) : indicative, calculée en BigInt (jamais en flottant).
  const enteredText = normalizeQuantityText(values.quantity ?? "");
  const enteredMilli = enteredText === null ? null : parseMilli(enteredText);
  const announcement = (() => {
    if (!selectedRequest || enteredMilli === null || enteredMilli <= 0n || unit === "") return null;
    const requestedUnit = selectedRequest.quantity.unit;
    let receivedMilli = selectedRequest.receivedQuantity ? numberToMilli(selectedRequest.receivedQuantity.value) : 0n;
    // Correction : la livraison corrigée est déjà dans le reçu cumulé ; on la retire avant d'ajouter la nouvelle quantité.
    if (isEdit && delivery && delivery.status === "Recorded" && delivery.quantityInRequestUnit) {
      receivedMilli -= numberToMilli(delivery.quantityInRequestUnit.value);
    }
    const requested: MilliQuantity = { milli: numberToMilli(selectedRequest.quantity.value), unit: requestedUnit };
    return announceDelivery({
      entered: { milli: enteredMilli, unit },
      requested,
      received: { milli: receivedMilli < 0n ? 0n : receivedMilli, unit: requestedUnit },
      bagMassKg: catalogProduct?.bagMassKg === null || catalogProduct?.bagMassKg === undefined ? null : String(catalogProduct.bagMassKg),
      tolerancePercent,
    });
  })();
  // Équivalence indicative sous la quantité (« 15 T = 300 sacs ») : jamais un chiffre qui fait foi.
  const equivalent =
    enteredMilli !== null && enteredMilli > 0n && unit !== "" && catalogProduct
      ? equivalenceFor({ milli: enteredMilli, unit }, catalogProduct.bagMassKg === null ? null : String(catalogProduct.bagMassKg))
      : null;
  const announce = (milli: bigint, announcedUnit: MeasureUnitCode) => quantityText({ value: Number(milliToText(milli)), unit: announcedUnit });

  // Date antérieure à la demande : avertissement seulement (CA-MAT-006.5). Les deux dates sont lues à l'heure d'Algérie.
  const requestDay = selectedRequest ? toAlgiersDay(selectedRequest.createdAt) : null;
  const dateBeforeRequest = requestDay !== null && values.deliveryDate !== null && values.deliveryDate !== undefined && values.deliveryDate < requestDay;

  const siteOptions = sites.map((site) => ({ value: site.id, label: `${site.code} · ${pickLocalizedName(site, language)}` }));
  const reasonLabel = (reason: string): string => (i18n.exists(`materials:reasons.${reason}`) ? t(`materials:reasons.${reason}`) : reason);

  return (
    <form onSubmit={(event) => void handleSubmit(submit)(event)} noValidate>
      <Stack gap="md">
        <FormSubmitAlerts<DeliveryDetail>
          error={submitError}
          generalTitle={t("materials:deliveries.form.generalError")}
          conflict={{
            title: t("materials:deliveries.form.conflictTitle"),
            message: (current) => t("materials:deliveries.form.conflictMessage", { name: current.updatedByName ?? "—" }),
            reloadLabel: t("materials:deliveries.form.conflictReload"),
            onReload: (current) => {
              reset(deliveryToFormValues(current));
              onConflictReload?.(current);
              setSubmitError(null);
            },
          }}
        />

        {!isEdit ? (
          <>
            <Controller
              control={control}
              name="siteId"
              render={({ field }) => (
                <Select
                  label={t("materials:deliveries.form.site")}
                  placeholder={t("materials:deliveries.form.sitePlaceholder")}
                  required
                  searchable
                  data={siteOptions}
                  error={fieldError(errors.siteId)}
                  value={field.value === "" ? null : field.value}
                  onChange={(value) => {
                    field.onChange(value ?? "");
                    // La demande appartient au chantier : un autre chantier la retire.
                    chooseRequest(null);
                  }}
                />
              )}
            />
            <Controller
              control={control}
              name="requestId"
              render={({ field }) => (
                <DeliveryRequestSelect
                  siteId={siteId}
                  label={t("materials:deliveries.form.request")}
                  description={t("materials:deliveries.form.requestHelp")}
                  placeholder={t("materials:deliveries.form.requestPlaceholder")}
                  value={field.value === "" ? null : field.value}
                  onChange={chooseRequest}
                  error={fieldError(errors.requestId)}
                />
              )}
            />

            {!hasRequest ? (
              <>
                <SegmentedControl
                  fullWidth
                  aria-label={t("materials:deliveries.form.product")}
                  value={productMode}
                  onChange={(value) => {
                    setValue("productMode", value === "free" ? "free" : "catalog");
                    setValue("unit", "");
                    setValue("productId", "");
                  }}
                  data={[
                    { value: "catalog", label: t("materials:deliveries.form.catalogProduct") },
                    { value: "free", label: t("materials:deliveries.form.otherProduct") },
                  ]}
                />
                {productMode === "catalog" ? (
                  <ProductSelect
                    label={t("materials:deliveries.form.product")}
                    placeholder={t("materials:deliveries.form.productPlaceholder")}
                    value={(values.productId ?? "") === "" ? null : (values.productId ?? null)}
                    onChange={(product) => {
                      setValue("productId", product?.id ?? "", { shouldValidate: true });
                      setValue("unit", product ? product.defaultUnit : "", { shouldValidate: true });
                    }}
                    error={fieldError(errors.productId)}
                  />
                ) : (
                  <TextInput
                    label={t("materials:deliveries.form.freeProductName")}
                    description={t("materials:deliveries.form.freeNameHelp")}
                    required
                    error={fieldError(errors.freeProductName)}
                    {...register("freeProductName")}
                  />
                )}
              </>
            ) : null}

            <SegmentedControl
              fullWidth
              aria-label={t("materials:deliveries.form.supplier")}
              value={supplierMode}
              onChange={(value) => {
                setValue("supplierMode", value === "free" ? "free" : "catalog");
                setValue("supplierId", "");
              }}
              data={[
                { value: "catalog", label: t("materials:deliveries.form.catalogSupplier") },
                { value: "free", label: t("materials:deliveries.form.otherSupplier") },
              ]}
            />
            {supplierMode === "catalog" ? (
              <SupplierSelect
                label={t("materials:deliveries.form.supplier")}
                placeholder={t("materials:deliveries.form.supplierPlaceholder")}
                value={(values.supplierId ?? "") === "" ? null : (values.supplierId ?? null)}
                onChange={(supplier) => setValue("supplierId", supplier?.id ?? "", { shouldValidate: true })}
                error={fieldError(errors.supplierId)}
              />
            ) : (
              <TextInput
                label={t("materials:deliveries.form.freeSupplierName")}
                description={t("materials:deliveries.form.freeNameHelp")}
                required
                error={fieldError(errors.freeSupplierName)}
                {...register("freeSupplierName")}
              />
            )}
          </>
        ) : null}

        <Group align="flex-start" grow wrap="wrap">
          <TextInput
            label={t("materials:deliveries.form.quantity")}
            description={t("materials:deliveries.form.quantityHelp")}
            required
            inputMode="decimal"
            dir="ltr"
            error={fieldError(errors.quantity)}
            {...register("quantity")}
          />
          <Controller
            control={control}
            name="unit"
            render={({ field }) => (
              <Select
                label={t("materials:deliveries.form.unit")}
                description={t("materials:deliveries.form.unitHelp")}
                placeholder={t("materials:deliveries.form.unitPlaceholder")}
                required
                allowDeselect={false}
                // Les unités se choisissent dans la liste, jamais en texte libre.
                data={unitOptions.map((code) => ({ value: code, label: unitName(code) }))}
                error={fieldError(errors.unit)}
                value={field.value === "" ? null : field.value}
                onChange={(value) => field.onChange(value ?? "")}
              />
            )}
          />
        </Group>

        {equivalent && enteredMilli !== null && unit !== "" ? (
          <Text size="sm" aria-live="polite">
            {t("materials:deliveries.form.equivalence", { from: announce(enteredMilli, unit), to: announce(equivalent.milli, equivalent.unit) })}
          </Text>
        ) : null}

        {announcement && selectedRequest ? (
          <Alert
            color={announcement.kind === "surplus" ? "orange" : "blue"}
            variant="light"
            icon={announcement.kind === "surplus" ? <IconAlertTriangle aria-hidden /> : <IconInfoCircle aria-hidden />}
            role="status"
          >
            {announcement.kind === "partial"
              ? t("materials:deliveries.form.announce.partial", { remaining: announce(announcement.remaining.milli, announcement.remaining.unit) })
              : announcement.kind === "complete"
                ? t("materials:deliveries.form.announce.complete")
                : t("materials:deliveries.form.announce.surplus", {
                    surplus: announce(announcement.surplus.milli, announcement.surplus.unit),
                    percent: formatPercent(Number(announcement.percentHundredths) / 100),
                  })}
          </Alert>
        ) : null}

        <Controller
          control={control}
          name="deliveryDate"
          render={({ field }) => (
            <DatePickerInput
              label={t("materials:deliveries.form.date")}
              description={t("materials:deliveries.form.dateHelp")}
              required
              maxDate={todayDateOnly()}
              valueFormat="DD/MM/YYYY"
              error={fieldError(errors.deliveryDate)}
              value={field.value}
              onChange={field.onChange}
            />
          )}
        />
        {dateBeforeRequest ? (
          <Alert color="orange" variant="light" icon={<IconAlertTriangle aria-hidden />} role="status">
            {t("materials:deliveries.form.dateBeforeRequest")}
          </Alert>
        ) : null}

        <TextInput
          label={t("materials:deliveries.form.note")}
          description={isEdit && (initialValues.deliveryNoteNumber ?? "") !== "" ? t("materials:deliveries.form.noteKeep") : t("materials:deliveries.form.noteHelp")}
          maxLength={DELIVERY_NOTE_MAX}
          dir="ltr"
          error={fieldError(errors.deliveryNoteNumber)}
          {...register("deliveryNoteNumber")}
        />

        <Controller
          control={control}
          name="conformity"
          render={({ field }) => (
            <SegmentedControl
              fullWidth
              aria-label={t("materials:deliveries.form.conformity")}
              value={field.value}
              onChange={field.onChange}
              data={[
                { value: "Conform", label: t("materials:deliveries.conformity.Conform") },
                { value: "WithReserve", label: t("materials:deliveries.conformity.WithReserve") },
              ]}
            />
          )}
        />
        {conformity === "WithReserve" ? (
          <>
            <Controller
              control={control}
              name="reserveReasonCode"
              render={({ field }) => (
                <Select
                  label={t("materials:deliveries.form.reasonLabel")}
                  placeholder={t("materials:deliveries.form.reasonPlaceholder")}
                  required
                  allowDeselect={false}
                  data={reserveReasons.map((reason) => ({ value: reason, label: reasonLabel(reason) }))}
                  error={fieldError(errors.reserveReasonCode)}
                  value={field.value === "" ? null : field.value}
                  onChange={(value) => field.onChange(value ?? "")}
                />
              )}
            />
            <Textarea
              label={t("materials:deliveries.form.reasonNote")}
              description={t("materials:deliveries.form.reasonNoteHelp", { count: RESERVE_NOTE_MAX })}
              required={values.reserveReasonCode === OTHER_REASON}
              maxLength={RESERVE_NOTE_MAX}
              autosize
              minRows={2}
              error={fieldError(errors.reserveNote)}
              {...register("reserveNote")}
            />
          </>
        ) : null}

        <Group justify="flex-end">
          <Button variant="default" onClick={onCancel} disabled={isSubmitting}>
            {t("common:actions.cancel")}
          </Button>
          <Button type="submit" loading={isSubmitting}>
            {isEdit ? t("common:actions.save") : t("materials:deliveries.create")}
          </Button>
        </Group>
      </Stack>
    </form>
  );
};

/** Jour (AAAA-MM-JJ) d'un horodatage du serveur, à l'heure d'Algérie : sert seulement à un avertissement indicatif. */
const toAlgiersDay = (instant: string): string | null => {
  const time = Date.parse(instant);
  if (Number.isNaN(time)) return null;
  return todayDateOnly(new Date(time));
};
