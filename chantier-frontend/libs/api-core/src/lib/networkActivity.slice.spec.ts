import {
  apiCallEnded,
  apiCallStarted,
  networkActivityReducer,
  selectIsNetworkLoading,
  type NetworkActivityState,
} from "./networkActivity.slice";

describe("networkActivity", () => {
  const initial: NetworkActivityState = { activeRequests: 0 };

  it("compte les requêtes en cours", () => {
    let state = networkActivityReducer(initial, apiCallStarted());
    state = networkActivityReducer(state, apiCallStarted());
    expect(state.activeRequests).toBe(2);
    expect(selectIsNetworkLoading({ networkActivity: state })).toBe(true);

    state = networkActivityReducer(state, apiCallEnded());
    state = networkActivityReducer(state, apiCallEnded());
    expect(selectIsNetworkLoading({ networkActivity: state })).toBe(false);
  });

  it("ne descend jamais sous zéro", () => {
    expect(networkActivityReducer(initial, apiCallEnded()).activeRequests).toBe(0);
  });

  it("considère l'absence de tranche comme « pas de chargement »", () => {
    expect(selectIsNetworkLoading({})).toBe(false);
  });
});
