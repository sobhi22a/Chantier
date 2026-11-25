import { createI18n } from "./i18n";
import { LANGUAGE_STORAGE_KEY, getDirection, readStoredLanguage, toLanguage } from "./languages";
import { pickLocalizedName } from "./localizedName";

const ISOLATE_LTR = "\u2066";
const ISOLATE_FIRST_STRONG = "\u2068";
const ISOLATE_END = "\u2069";

describe("langues", () => {
  afterEach(() => {
    localStorage.clear();
    document.documentElement.removeAttribute("lang");
    document.documentElement.removeAttribute("dir");
  });

  it("ramène une variante régionale à la langue prise en charge", () => {
    expect(toLanguage("ar-DZ")).toBe("ar");
    expect(toLanguage("fr-FR")).toBe("fr");
    expect(toLanguage("en")).toBe("fr");
    expect(toLanguage(undefined)).toBe("fr");
  });

  it("donne le sens d'écriture : rtl en arabe, ltr en français", () => {
    expect(getDirection("ar")).toBe("rtl");
    expect(getDirection("ar-DZ")).toBe("rtl");
    expect(getDirection("fr")).toBe("ltr");
  });

  it("lit la langue mémorisée et retombe sur le français si la valeur est inconnue", () => {
    expect(readStoredLanguage()).toBe("fr");
    localStorage.setItem(LANGUAGE_STORAGE_KEY, "ar");
    expect(readStoredLanguage()).toBe("ar");
    localStorage.setItem(LANGUAGE_STORAGE_KEY, "klingon");
    expect(readStoredLanguage()).toBe("fr");
  });

  describe("instance i18next", () => {
    it("démarre en français avec lang=fr et dir=ltr sur <html>", () => {
      createI18n("fr");
      expect(document.documentElement.lang).toBe("fr");
      expect(document.documentElement.dir).toBe("ltr");
    });

    it("démarre en arabe avec lang=ar et dir=rtl sur <html>", () => {
      createI18n("ar");
      expect(document.documentElement.lang).toBe("ar");
      expect(document.documentElement.dir).toBe("rtl");
    });

    it("bascule FR → AR → FR sans rechargement : textes, lang et dir suivent", async () => {
      const instance = createI18n("fr");
      expect(instance.t("sites:list.title")).toBe("Mes chantiers");

      await instance.changeLanguage("ar");
      expect(instance.t("sites:list.title")).toBe("ورشاتي");
      expect(document.documentElement.lang).toBe("ar");
      expect(document.documentElement.dir).toBe("rtl");

      await instance.changeLanguage("fr");
      expect(instance.t("sites:list.title")).toBe("Mes chantiers");
      expect(document.documentElement.lang).toBe("fr");
      expect(document.documentElement.dir).toBe("ltr");
    });

    it("mémorise le choix dans localStorage (chantier.lang)", async () => {
      const instance = createI18n("fr");
      await instance.changeLanguage("ar");
      expect(localStorage.getItem(LANGUAGE_STORAGE_KEY)).toBe("ar");
    });

    it("ne touche ni à localStorage ni à <html> quand c'est désactivé", async () => {
      const instance = createI18n("fr", { persist: false, syncDocument: false });
      await instance.changeLanguage("ar");
      expect(localStorage.getItem(LANGUAGE_STORAGE_KEY)).toBeNull();
      expect(document.documentElement.getAttribute("dir")).toBeNull();
    });

    it("traduit un code d'erreur dans les deux langues", async () => {
      const instance = createI18n("fr", { persist: false, syncDocument: false });
      expect(instance.t("errors:ZONE_EXISTANTE")).toBe("Cette zone existe déjà.");
      await instance.changeLanguage("ar");
      expect(instance.t("errors:ZONE_EXISTANTE")).toBe("هذه المنطقة موجودة من قبل.");
    });

    it("isole les valeurs lues de gauche à droite dans les phrases arabes seulement", async () => {
      const instance = createI18n("fr", { persist: false, syncDocument: false });
      const values = { name: "Farid L.", date: "24/11/2026 11:15" };

      expect(instance.t("sites:detail.createdBy", values)).toBe("Créé par Farid L. le 24/11/2026 11:15");

      await instance.changeLanguage("ar");
      const arabic = instance.t("sites:detail.createdBy", values);
      expect(arabic).toContain(`${ISOLATE_LTR}24/11/2026 11:15${ISOLATE_END}`);
      expect(arabic).toContain(`${ISOLATE_FIRST_STRONG}Farid L.${ISOLATE_END}`);
    });

    it("accorde les jours selon les règles de pluriel de chaque langue", async () => {
      const instance = createI18n("fr", { persist: false, syncDocument: false });
      expect(instance.t("common:units.day", { count: 1 })).toBe("1 jour");
      expect(instance.t("common:units.day", { count: 540 })).toBe("540 jours");

      await instance.changeLanguage("ar");
      expect(instance.t("common:units.day", { count: 1 })).toBe("يوم واحد");
      expect(instance.t("common:units.day", { count: 2 })).toBe("يومان");
      expect(instance.t("common:units.day", { count: 5 })).toBe("5 أيام");
      expect(instance.t("common:units.day", { count: 30 })).toBe("30 يومًا");
      expect(instance.t("common:units.day", { count: 100 })).toBe("100 يوم");
      expect(instance.t("common:units.day", { count: 540 })).toBe("540 يومًا");
    });
  });
});

describe("pickLocalizedName (H-20)", () => {
  const site = { name: "École UV18", nameAr: "مدرسة UV18" };

  it("affiche le nom arabe en arabe quand il existe", () => {
    expect(pickLocalizedName(site, "ar")).toBe("مدرسة UV18");
  });

  it("affiche le nom français en français", () => {
    expect(pickLocalizedName(site, "fr")).toBe("École UV18");
  });

  it("retombe sur le nom français sans nom arabe", () => {
    expect(pickLocalizedName({ name: "École UV18", nameAr: null }, "ar")).toBe("École UV18");
    expect(pickLocalizedName({ name: "École UV18", nameAr: "  " }, "ar")).toBe("École UV18");
    expect(pickLocalizedName({ name: "École UV18" }, "ar")).toBe("École UV18");
  });
});
