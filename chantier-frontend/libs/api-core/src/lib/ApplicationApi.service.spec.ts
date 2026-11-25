import { configureStore } from "@reduxjs/toolkit";

import { ApplicationApiService } from "./ApplicationApi.service";
import { networkActivityReducer, type NetworkActivityState } from "./networkActivity.slice";

const pingApi = ApplicationApiService.injectEndpoints({
  endpoints: (builder) => ({
    ping: builder.query<{ ok: boolean }, void>({ query: () => "/api/v1/ping" }),
  }),
});

const createStore = () =>
  configureStore({
    reducer: {
      networkActivity: networkActivityReducer,
      [ApplicationApiService.reducerPath]: ApplicationApiService.reducer,
    },
    middleware: (getDefault) => getDefault().concat(ApplicationApiService.middleware),
  });

describe("ApplicationApiService", () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("appelle l'API configurée avec le cookie de session et décompte l'activité réseau", async () => {
    const seen: Request[] = [];
    const activitySeenDuringCall: NetworkActivityState[] = [];
    const store = createStore();
    vi.stubGlobal("fetch", async (request: Request) => {
      seen.push(request);
      activitySeenDuringCall.push(store.getState().networkActivity);
      return new Response(JSON.stringify({ ok: true }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    });

    const result = await store.dispatch(pingApi.endpoints.ping.initiate());

    expect(result.data).toEqual({ ok: true });
    expect(seen).toHaveLength(1);
    expect(seen[0].url).toBe("http://api.test/api/v1/ping");
    expect(seen[0].credentials).toBe("include");
    expect(seen[0].headers.get("accept")).toBe("application/json");
    expect(activitySeenDuringCall[0].activeRequests).toBe(1);
    expect(store.getState().networkActivity.activeRequests).toBe(0);
  });

  it("remet le compteur à zéro même quand la requête échoue", async () => {
    const store = createStore();
    vi.stubGlobal("fetch", async () => new Response("{}", { status: 500 }));

    const result = await store.dispatch(pingApi.endpoints.ping.initiate(undefined, { forceRefetch: true }));

    expect(result.isError).toBe(true);
    expect(store.getState().networkActivity.activeRequests).toBe(0);
  });
});
