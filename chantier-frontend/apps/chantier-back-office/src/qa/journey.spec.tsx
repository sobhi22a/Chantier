import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import {
  SITE_UV18_ID,
  apiUrl,
  makeMe,
  makeMember,
  makeSite,
  makeZone,
  problem,
  server,
  setupMockServer,
} from "@chantier-frontend/testing";

import { renderApp } from "../testing/renderApp";

setupMockServer();

/**
 * Q1 : CA-017.1 / CT-14 côté web. Parcours complet (connexion refusée, connexion, Mes chantiers, fiche avec noms de
 * personnes, erreur serveur 500, déconnexion) avec TOUTE la sortie console capturée et le stockage du navigateur relu :
 * aucun identifiant, nom, téléphone, mot de passe ni jeton ne doit y figurer.
 */
const USER = "chef.dev";
const PASSWORD = "MotDePasse-Secret-QA-1";
const FULL_NAME = "Mourad B.";
const PHONE = "0550 00 00 15";
const OTHER_NAME = "Toufik G.";

const SECRETS = [USER, PASSWORD, FULL_NAME, OTHER_NAME, PHONE, "Farid L.", "Bearer", "accessToken", "refreshToken"];

const captured: string[] = [];

const capture = (...args: unknown[]) => {
  captured.push(
    args
      .map((arg) => {
        if (arg instanceof Error) return `${arg.name}: ${arg.message}\n${arg.stack ?? ""}`;
        if (typeof arg === "string") return arg;
        try {
          return JSON.stringify(arg);
        } catch {
          return String(arg);
        }
      })
      .join(" "),
  );
};

describe("aucune donnée personnelle dans la console ni dans le stockage du navigateur (CA-017.1, CT-14)", () => {
  beforeEach(() => {
    captured.length = 0;
    vi.spyOn(console, "log").mockImplementation(capture);
    vi.spyOn(console, "info").mockImplementation(capture);
    vi.spyOn(console, "warn").mockImplementation(capture);
    vi.spyOn(console, "error").mockImplementation(capture);
    vi.spyOn(console, "debug").mockImplementation(capture);
    window.localStorage.clear();
    window.sessionStorage.clear();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    document.documentElement.removeAttribute("lang");
    document.documentElement.removeAttribute("dir");
  });

  it("connexion refusée, connexion, liste, fiche, erreur 500 puis déconnexion ne laissent rien de personnel", async () => {
    let session = false;
    server.use(
      http.get(apiUrl("/auth/me"), () =>
        session ? HttpResponse.json(makeMe("ChefChantier", { phoneNumber: PHONE })) : problem(401, "NON_AUTHENTIFIE"),
      ),
      http.post(apiUrl("/auth/login"), async ({ request }) => {
        const body = (await request.json()) as { password: string };
        if (body.password !== PASSWORD) return problem(401, "IDENTIFIANTS_INVALIDES");
        session = true;
        return HttpResponse.json({
          user: { id: "x", userName: USER, fullName: FULL_NAME, role: "ChefChantier", language: "fr", mustChangePassword: false },
        });
      }),
      http.post(apiUrl("/auth/logout"), () => {
        session = false;
        return new HttpResponse(null, { status: 204 });
      }),
      http.get(apiUrl("/sites"), () => HttpResponse.json({ items: [makeSite()], page: 1, pageSize: 20, totalCount: 1 })),
      http.get(apiUrl("/sites/:siteId"), () => HttpResponse.json(makeSite())),
      http.get(apiUrl("/sites/:siteId/zones"), () =>
        HttpResponse.json({ items: [makeZone({ id: "z-1", block: "Bloc 01", elevation: 3.4, roomType: "Classroom", roomNumber: 2 })], nextCursor: null }),
      ),
      http.get(apiUrl("/sites/:siteId/members"), () =>
        HttpResponse.json({
          items: [
            makeMember({ userId: "u1", fullName: FULL_NAME, role: "ChefChantier" }),
            makeMember({ userId: "u2", fullName: OTHER_NAME, role: "ChefEquipe" }),
          ],
        }),
      ),
    );
    const user = userEvent.setup();
    const { router } = renderApp("/sites");
    await screen.findByRole("heading", { level: 1, name: "Connexion" });

    // 1. mauvais mot de passe
    await user.type(screen.getByLabelText("Identifiant"), USER);
    await user.type(screen.getByLabelText("Mot de passe"), "mauvais-mot-de-passe");
    await user.click(screen.getByRole("button", { name: "Se connecter" }));
    await screen.findByText(/Identifiant ou mot de passe incorrect/);

    // 2. bon mot de passe
    await user.clear(screen.getByLabelText("Mot de passe"));
    await user.type(screen.getByLabelText("Mot de passe"), PASSWORD);
    await user.click(screen.getByRole("button", { name: "Se connecter" }));
    await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });

    // 3. fiche d'un chantier (noms des personnes affectées)
    await router.navigate(`/sites/${SITE_UV18_ID}`);
    await screen.findByRole("heading", { level: 1, name: "École UV18" });
    await waitFor(() => expect(screen.getAllByText(OTHER_NAME).length).toBeGreaterThan(0));

    // 4. erreur serveur inattendue sur la liste
    server.use(http.get(apiUrl("/sites"), () => problem(500, "ERREUR_INTERNE")));
    await router.navigate("/sites");
    await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });

    // 5. déconnexion
    await user.click(screen.getByRole("button", { name: "Menu de l'utilisateur" }));
    await user.click(await screen.findByRole("menuitem", { name: "Se déconnecter" }));
    await screen.findByRole("heading", { level: 1, name: "Connexion" });

    const output = captured.join("\n");
    const stored = JSON.stringify({ ...window.localStorage }) + JSON.stringify({ ...window.sessionStorage });
    for (const secret of SECRETS) {
      expect(output, `console : « ${secret} »`).not.toContain(secret);
      expect(stored, `stockage du navigateur : « ${secret} »`).not.toContain(secret);
    }
    expect(document.cookie, "aucun jeton lisible par le script (cookie HttpOnly)").not.toMatch(/token|jwt|auth/i);
  });
});
