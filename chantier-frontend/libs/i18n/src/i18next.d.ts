import type { resourcesFr } from "./resources";

declare module "i18next" {
  interface CustomTypeOptions {
    defaultNS: "common";
    resources: typeof resourcesFr;
  }
}
