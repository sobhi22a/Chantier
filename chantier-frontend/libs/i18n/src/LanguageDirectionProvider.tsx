import { DirectionProvider, useDirection as useMantineDirection } from "@mantine/core";
import { useEffect, type ReactNode } from "react";

import type { Direction } from "./languages";
import { useDirection } from "./useDirection";

// Mantine garde son propre état de direction : on le met en phase avec la langue (système externe, d'où l'effet).
const MantineDirectionSync = ({ direction }: { direction: Direction }) => {
  const { dir, setDirection } = useMantineDirection();
  useEffect(() => {
    if (dir !== direction) setDirection(direction);
  }, [dir, direction, setDirection]);
  return null;
};

/** `DirectionProvider` de Mantine piloté par la langue : les composants Mantine passent en RTL avec l'arabe. */
export const LanguageDirectionProvider = ({ children }: { children: ReactNode }) => {
  const direction = useDirection();
  return (
    <DirectionProvider initialDirection={direction} detectDirection={false}>
      <MantineDirectionSync direction={direction} />
      {children}
    </DirectionProvider>
  );
};
