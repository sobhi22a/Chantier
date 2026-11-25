import { makeSite } from "@chantier-frontend/testing";

import {
  emptySiteFormValues,
  siteFormSchema,
  siteToFormValues,
  toCreateSiteRequest,
  toUpdateSiteRequest,
  type SiteFormValues,
} from "./siteForm.zod";

const valid: SiteFormValues = {
  ...emptySiteFormValues(),
  code: "CH-ECO-UV18",
  name: "École UV18",
  wilaya: "Blida",
  commune: "Boufarik",
  owner: "Direction des équipements publics (fictive)",
  delayDays: 540,
  odsDate: "2026-03-02",
};

const issues = (values: SiteFormValues) => {
  const result = siteFormSchema.safeParse(values);
  return result.success ? [] : result.error.issues.map((issue) => `${issue.path.join(".")}:${issue.message}`);
};

describe("schéma de chantier", () => {
  it("accepte un chantier complet et un chantier sans marché", () => {
    expect(issues(valid)).toEqual([]);
    expect(issues({ ...valid, delayDays: "", odsDate: null, contractAmount: "" })).toEqual([]);
  });

  it.each(["", "ab", "ch-eco", "CH ECO", "-CH-ECO"])("refuse le code « %s »", (code) => {
    expect(issues({ ...valid, code })).toEqual(["code:sites:form.codeInvalid"]);
  });

  it("exige nom, wilaya, commune et maître d'ouvrage", () => {
    expect(issues({ ...valid, name: "", wilaya: "", commune: "", owner: "" }).sort()).toEqual([
      "commune:sites:form.required",
      "name:sites:form.required",
      "owner:sites:form.required",
      "wilaya:sites:form.required",
    ]);
  });

  it.each([0, -5, 1.5])("refuse le délai %s (entier de jours supérieur à 0, CA-008.5)", (delayDays) => {
    expect(issues({ ...valid, delayDays })).toEqual(["delayDays:sites:form.delayInvalid"]);
  });

  it("refuse une date d'ODS incomplète (CA-008.4)", () => {
    expect(issues({ ...valid, odsDate: "../08/2026" })).toEqual(["odsDate:errors:DATE_INVALIDE"]);
    expect(issues({ ...valid, odsDate: "2026-08" })).toEqual(["odsDate:errors:DATE_INVALIDE"]);
  });

  it("refuse un montant négatif", () => {
    expect(issues({ ...valid, contractAmount: -1 })).toEqual(["contractAmount:sites:form.numberInvalid"]);
  });

  it("exige latitude et longitude ensemble", () => {
    expect(issues({ ...valid, latitude: 36.5 })).toEqual(["longitude:sites:form.coordinatesTogether"]);
    expect(issues({ ...valid, longitude: 2.9 })).toEqual(["latitude:sites:form.coordinatesTogether"]);
    expect(issues({ ...valid, latitude: 36.5, longitude: 2.9 })).toEqual([]);
  });
});

describe("requêtes de chantier", () => {
  it("la création envoie le code et des null pour les champs vides", () => {
    expect(toCreateSiteRequest({ ...valid, nameAr: "", contractNumber: " " })).toEqual({
      code: "CH-ECO-UV18",
      name: "École UV18",
      nameAr: null,
      type: "School",
      wilaya: "Blida",
      commune: "Boufarik",
      owner: "Direction des équipements publics (fictive)",
      contractNumber: null,
      contractAmount: null,
      delayDays: 540,
      odsDate: "2026-03-02",
      latitude: null,
      longitude: null,
    });
  });

  it("la modification envoie la version lue et jamais le code (immuable)", () => {
    const request = toUpdateSiteRequest(siteToFormValues(makeSite()), "48213", true);
    expect(request.version).toBe("48213");
    expect(request).not.toHaveProperty("code");
    expect(request.contractAmount).toBe(185000000);
  });

  it("n'envoie pas le montant à un rôle qui ne le voit pas (le serveur l'effacerait)", () => {
    const withoutAmount = makeSite();
    delete withoutAmount.contractAmount;
    const request = toUpdateSiteRequest(siteToFormValues(withoutAmount), "1", false);
    expect(request).not.toHaveProperty("contractAmount");
  });

  it("recharge un chantier dans le formulaire (nom arabe absent = vide)", () => {
    expect(siteToFormValues(makeSite()).nameAr).toBe("");
    expect(siteToFormValues(makeSite({ nameAr: "مدرسة UV18" })).nameAr).toBe("مدرسة UV18");
  });
});
