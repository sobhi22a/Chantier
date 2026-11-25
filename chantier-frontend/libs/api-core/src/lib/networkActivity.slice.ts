import { createSlice } from "@reduxjs/toolkit";

export interface NetworkActivityState {
  activeRequests: number;
}

const initialState: NetworkActivityState = {
  activeRequests: 0,
};

const slice = createSlice({
  name: "networkActivity",
  initialState,
  reducers: {
    apiCallStarted(state) {
      state.activeRequests += 1;
    },
    apiCallEnded(state) {
      state.activeRequests = Math.max(0, state.activeRequests - 1);
    },
  },
});

export const { apiCallStarted, apiCallEnded } = slice.actions;
export const networkActivityReducer = slice.reducer;

export const selectIsNetworkLoading = (state: { networkActivity?: NetworkActivityState }): boolean =>
  (state.networkActivity?.activeRequests ?? 0) > 0;
