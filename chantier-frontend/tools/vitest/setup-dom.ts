import { notifications } from "@mantine/notifications";
import { configure } from "@testing-library/dom";

// Compléments jsdom pour tester des composants Mantine (aucune de ces API n'existe dans jsdom).
if (!window.matchMedia) {
  window.matchMedia = (query: string): MediaQueryList => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: () => undefined,
    removeListener: () => undefined,
    addEventListener: () => undefined,
    removeEventListener: () => undefined,
    dispatchEvent: () => false,
  });
}

class ResizeObserverStub {
  observe(): void {}
  unobserve(): void {}
  disconnect(): void {}
}
globalThis.ResizeObserver ??= ResizeObserverStub;

Element.prototype.scrollIntoView ??= () => undefined;

// Les écrans Mantine + RTK Query + MSW sont lents quand toute la suite tourne en parallèle : une attente plus large évite les faux échecs
// (elle ne ralentit jamais un test qui réussit).
configure({ asyncUtilTimeout: 4000 });

// Le magasin de notifications Mantine est global au fichier de test : sans nettoyage, les notifications d'un test restent en file
// (limite de 3 affichées) et masquent celles du suivant.
afterEach(() => {
  notifications.clean();
});
