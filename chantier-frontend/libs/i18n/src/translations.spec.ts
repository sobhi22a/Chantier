import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import { NAMESPACES, resourcesAr, resourcesFr } from "./resources";
import { ROOM_TYPES } from "./zoneLabelParts";

type Tree = { [key: string]: string | Tree };

const flatten = (tree: Tree, prefix = ""): Record<string, string> =>
  Object.entries(tree).reduce<Record<string, string>>((flat, [key, value]) => {
    const path = prefix ? `${prefix}.${key}` : key;
    return typeof value === "string" ? { ...flat, [path]: value } : { ...flat, ...flatten(value, path) };
  }, {});

const PLURAL_SUFFIX = /_(zero|one|two|few|many|other)$/;
const baseKey = (key: string) => key.replace(PLURAL_SUFFIX, "");
const pluralCategory = (key: string) => PLURAL_SUFFIX.exec(key)?.[1];

// `{{name}}`, `{{date, ltr}}` : seul le nom de la variable compte.
const placeholders = (text: string) =>
  [...text.matchAll(/\{\{\s*([\w.]+)\s*(?:,[^}]*)?\}\}/g)].map((match) => match[1]).sort();

const namespaces = (resources: Record<string, unknown>, ns: string) => flatten(resources[ns] as Tree);

describe("traductions FR / AR (ADR 0007, CA-014.5)", () => {
  describe.each([...NAMESPACES])("espace « %s »", (ns) => {
    const fr = namespaces(resourcesFr, ns);
    const ar = namespaces(resourcesAr, ns);

    it("a les mêmes clés en français et en arabe", () => {
      const frKeys = [...new Set(Object.keys(fr).map(baseKey))].sort();
      const arKeys = [...new Set(Object.keys(ar).map(baseKey))].sort();
      expect(arKeys).toEqual(frKeys);
    });

    it("n'a aucune valeur vide", () => {
      const empty = [...Object.entries(fr), ...Object.entries(ar)].filter(([, value]) => value.trim() === "");
      expect(empty).toEqual([]);
    });

    it("utilise les mêmes variables d'interpolation dans les deux langues", () => {
      const variablesByKey = (flat: Record<string, string>) =>
        Object.entries(flat).reduce<Record<string, string[]>>((byKey, [key, value]) => {
          const base = baseKey(key);
          byKey[base] = [...new Set([...(byKey[base] ?? []), ...placeholders(value)])].sort();
          return byKey;
        }, {});
      expect(variablesByKey(ar)).toEqual(variablesByKey(fr));
    });

    it("fournit toutes les formes de pluriel de chaque langue", () => {
      const required = (language: string) => {
        const categories = new Intl.PluralRules(language).resolvedOptions().pluralCategories;
        // `many` n'existe en français que pour les millions : « one » et « other » suffisent.
        return language === "fr" ? ["one", "other"] : [...categories];
      };
      const check = (flat: Record<string, string>, language: string) => {
        const forms = Object.keys(flat).reduce<Record<string, string[]>>((byKey, key) => {
          const category = pluralCategory(key);
          if (category) byKey[baseKey(key)] = [...(byKey[baseKey(key)] ?? []), category];
          return byKey;
        }, {});
        return Object.entries(forms).filter(([, found]) => !required(language).every((c) => found.includes(c)));
      };
      expect(check(fr, "fr")).toEqual([]);
      expect(check(ar, "ar")).toEqual([]);
    });
  });

  it("traduit tous les codes d'erreur du catalogue docs/api/codes-erreur.md, y compris les codes métier à venir", () => {
    const catalog = readFileSync(resolve(__dirname, "../../../../docs/api/codes-erreur.md"), "utf8");
    const codes = catalog
      .split("\n")
      .filter((line) => /^\|\s*`[A-Z]/.test(line))
      .flatMap((line) => [...(line.split("|")[1] ?? "").matchAll(/`([A-Z][A-Z_]+)`/g)].map((match) => match[1]));

    expect(codes.length).toBeGreaterThanOrEqual(24);
    const missingFr = codes.filter((code) => !(code in resourcesFr.errors));
    const missingAr = codes.filter((code) => !(code in resourcesAr.errors));
    expect(missingFr).toEqual([]);
    expect(missingAr).toEqual([]);
  });

  it("traduit les codes d'erreur propres au client (réseau, inconnu)", () => {
    for (const resource of [resourcesFr.errors, resourcesAr.errors]) {
      expect(resource.NETWORK).toBeTruthy();
      expect(resource.UNKNOWN).toBeTruthy();
    }
  });

  it("traduit chaque type de local, chaque type d'ouvrage et chaque rôle", () => {
    for (const resources of [resourcesFr, resourcesAr]) {
      expect(Object.keys(resources.sites.roomTypes).sort()).toEqual([...ROOM_TYPES].sort());
      expect(Object.keys(resources.sites.types).sort()).toEqual(["Housing", "Other", "PublicFacility", "School"]);
      expect(Object.keys(resources.common.roles).sort()).toEqual([
        "Achats",
        "Admin",
        "ChefChantier",
        "ChefEquipe",
        "ConducteurTravaux",
        "Direction",
      ]);
    }
  });

  it("reprend le vocabulaire arabe de docs/metier/socle.md", () => {
    expect(resourcesAr.sites.list.title).toBe("ورشاتي");
    expect(resourcesAr.sites.roomTypes.Classroom).toBe("قسم");
    expect(resourcesAr.sites.roomTypes.Corridor).toBe("رواق");
    expect(resourcesAr.sites.roomTypes.Canteen).toBe("مطعم مدرسي");
    expect(resourcesAr.sites.roomTypes.Refectory).toBe("قاعة الأكل");
    expect(resourcesAr.sites.roomTypes.Kitchen).toBe("مطبخ");
    expect(resourcesAr.sites.roomTypes.Facade).toBe("واجهة");
    expect(resourcesAr.auth.signIn.submit).toBe("تسجيل الدخول");
    expect(resourcesAr.auth.signOut.action).toBe("تسجيل الخروج");
    expect(resourcesAr.auth.signIn.username).toBe("اسم المستخدم");
    expect(resourcesAr.auth.signIn.password).toBe("كلمة المرور");
    expect(resourcesAr.sites.detail.fields.owner).toBe("صاحب المشروع");
    expect(resourcesAr.sites.detail.fields.contractNumber).toBe("رقم الصفقة");
    expect(resourcesAr.sites.detail.fields.wilaya).toBe("الولاية");
    expect(resourcesAr.sites.detail.fields.commune).toBe("البلدية");
    expect(resourcesAr.common.roles.Admin).toBe("المسؤول");
    expect(resourcesAr.common.roles.ChefChantier).toBe("رئيس الورشة");
    expect(resourcesAr.common.roles.ChefEquipe).toBe("رئيس الفريق");
    expect(resourcesAr.common.roles.ConducteurTravaux).toBe("مسؤول متابعة الأشغال");
  });

  it("garde les messages de CA-001.3 et CA-001.4 mot pour mot en français", () => {
    expect(resourcesFr.errors.IDENTIFIANTS_INVALIDES).toBe(
      "Identifiant ou mot de passe incorrect, ou compte inactif. Contactez votre administrateur.",
    );
    expect(resourcesFr.errors.TROP_D_ESSAIS).toBe("Trop d'essais, réessayez plus tard.");
    expect(resourcesFr.errors.ACCES_RETIRE).toBe("Accès retiré, contactez votre administrateur.");
  });
});
