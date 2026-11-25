import { useDispatch, useSelector, type TypedUseSelectorHook } from "react-redux";

import type { ChantierAppDispatch, ChantierRootState } from "./store";

export const useAppChantierDispatch = () => useDispatch<ChantierAppDispatch>();
export const useAppChantierSelector: TypedUseSelectorHook<ChantierRootState> = useSelector;
