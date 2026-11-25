import { queryCacheTagsProvider } from "./queryCacheTagsProvider";

describe("queryCacheTagsProvider", () => {
  it("renvoie l'étiquette LIST quand il n'y a pas de données", () => {
    expect(queryCacheTagsProvider("SITES")).toEqual([{ type: "SITES", id: "LIST" }]);
    expect(queryCacheTagsProvider("SITES", null, { includeList: false })).toEqual([]);
  });

  it("renvoie une étiquette par élément plus LIST pour une liste", () => {
    const tags = queryCacheTagsProvider("ZONES", [{ id: "a" }, { id: "b" }]);
    expect(tags).toEqual([
      { type: "ZONES", id: "a" },
      { type: "ZONES", id: "b" },
      { type: "ZONES", id: "LIST" },
    ]);
  });

  it("peut omettre LIST", () => {
    expect(queryCacheTagsProvider("ZONES", [{ id: 1 }], { includeList: false })).toEqual([{ type: "ZONES", id: 1 }]);
  });

  it("renvoie une seule étiquette pour un élément", () => {
    expect(queryCacheTagsProvider("SITES", { id: "x" })).toEqual([{ type: "SITES", id: "x" }]);
  });
});
