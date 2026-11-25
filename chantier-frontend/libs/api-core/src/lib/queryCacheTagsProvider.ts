export type EntityTag<K extends string> = { type: K; id: string | number };

type WithId = { id: string | number };

/**
 * Étiquettes de cache pour `providesTags` : une par élément, plus `LIST` pour invalider la liste
 * (mêmes règles que Kardinal).
 */
export const queryCacheTagsProvider = <K extends string>(
  entityType: K,
  input?: WithId | WithId[] | null,
  options: { includeList?: boolean } = { includeList: true },
): EntityTag<K>[] => {
  if (!input) {
    return options.includeList ? [{ type: entityType, id: "LIST" }] : [];
  }

  if (Array.isArray(input)) {
    const tags = input.map((item) => ({ type: entityType, id: item.id }));
    return options.includeList ? [...tags, { type: entityType, id: "LIST" }] : tags;
  }

  return [{ type: entityType, id: input.id }];
};
